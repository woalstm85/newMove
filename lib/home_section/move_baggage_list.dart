import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/home_section/models/baggage_item.dart';
import 'package:MoveSmart/api_service.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'move_baggage_list_detail.dart';

class BaggageListScreen extends StatefulWidget {
  final bool isRegularMove;

  const BaggageListScreen({super.key, required this.isRegularMove});

  @override
  _BaggageListScreenState createState() => _BaggageListScreenState();
}

class _BaggageListScreenState extends State<BaggageListScreen> {
  // 새로운 데이터 구조 사용
  Map<String, List<BaggageItem>> selectedItemsMap = {};
  Map<String, List<Map<String, dynamic>>> categories = {};
  bool isLoading = true;
  String? selectedCategory;

  // 이사 유형에 따른 저장 키 접두사 가져오기
  String get _keyPrefix => widget.isRegularMove ? 'regular_' : 'special_';

  // 이사 유형에 따른 색상 설정
  Color get _primaryColor => widget.isRegularMove ? AppTheme.primaryColor : AppTheme.greenColor;

  // 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // 컨트롤러 해제
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchBaggageItems().then((_) {
      _loadSelectedItems();
      // 기본 선택 카테고리 설정
      if (categories.isNotEmpty) {
        setState(() {
          selectedCategory = categories.keys.first;
        });
      }
    });
  }

  Future<void> _saveSelectedItems() async {
    final prefs = await SharedPreferences.getInstance();

    // 새로운 데이터 구조를 JSON으로 변환
    final Map<String, dynamic> jsonData = {};
    selectedItemsMap.forEach((key, items) {
      jsonData[key] = items.map((item) => item.toJson()).toList();
    });

    final selectedItemsJson = json.encode(jsonData);
    await prefs.setString('${_keyPrefix}selectedItemsMap', selectedItemsJson);
  }

  Future<void> _loadSelectedItems() async {
    final prefs = await SharedPreferences.getInstance();

    final selectedItemsJson = prefs.getString('${_keyPrefix}selectedItemsMap');

    if (selectedItemsJson != null) {
      final Map<String, dynamic> jsonData = json.decode(selectedItemsJson);

      setState(() {
        selectedItemsMap.clear();
        jsonData.forEach((key, value) {
          final List<dynamic> itemsList = value;
          selectedItemsMap[key] = itemsList
              .map((itemJson) => BaggageItem.fromJson(itemJson))
              .toList();
        });
      });
    }
  }

  Future<void> fetchBaggageItems() async {
    try {
      final data = await ApiService.fetchBaggageItems();

      setState(() {
        categories = {};
        for (var item in data) {
          if (item['cateId'] != 'CT9999') {
            final category = item['cateNm'];
            if (!categories.containsKey(category)) {
              categories[category] = [];
            }
            categories[category]?.add({
              'cateId': item['cateId'],
              'loadCd': item['loadCd'],
              'loadNm': item['loadNm'],
              'subData': item['subData'], // subData 추가
              'iconPath': item['iconPath'],
            });
          }
        }
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 아이템 선택 토글 메서드
  void _toggleSelection(String category, Map<String, dynamic> itemData) {
    final String cateId = itemData['cateId'];
    final String loadCd = itemData['loadCd'];
    final String itemName = itemData['loadNm'];
    final String? iconPath = itemData['iconPath'];  // 직접 iconPath 필드 사용
    final key = createItemKey(cateId, loadCd);

    // 디버그 로깅 추가
    debugPrint('아이템 추가: $itemName, iconPath: $iconPath');
    debugPrint('아이템 데이터: $itemData');

    setState(() {
      if (!selectedItemsMap.containsKey(key)) {
        selectedItemsMap[key] = [];
      }

      // 새 아이템 추가 - iconPath 추가
      selectedItemsMap[key]!.add(BaggageItem(
        cateId: cateId,
        loadCd: loadCd,
        category: category,
        itemName: itemName,
        subData: itemData['subData'],
        iconPath: iconPath,  // 아이콘 경로 전달
      ));

      _saveSelectedItems(); // 상태 변경 후 저장
    });
  }

  // 아이템 감소 메서드 수정
  void _decreaseCount(String category, String itemName, String cateId, String loadCd) {
    final key = createItemKey(cateId, loadCd);

    if (selectedItemsMap.containsKey(key) && selectedItemsMap[key]!.isNotEmpty) {
      setState(() {
        // 해당 카테고리와 이름을 가진 아이템 중 마지막 항목 삭제
        final itemsToConsider = selectedItemsMap[key]!
            .where((item) => item.category == category && item.itemName == itemName)
            .toList();

        if (itemsToConsider.isNotEmpty) {
          final lastItem = itemsToConsider.last;
          selectedItemsMap[key]!.remove(lastItem);

          // 만약 해당 키의 리스트가 비었다면, 키 자체를 삭제
          if (selectedItemsMap[key]!.isEmpty) {
            selectedItemsMap.remove(key);
          }

          _saveSelectedItems(); // 상태 변경 후 저장
        }
      });
    }
  }

  // 선택된 항목의 총 개수를 계산
  int get totalSelectedItems {
    int total = 0;
    selectedItemsMap.forEach((_, items) {
      total += items.length;
    });
    return total;
  }

  // 선택된 카테고리
  void _setSelectedCategory(String category) {
    setState(() {
      selectedCategory = category;
    });

    // 스크롤 위치를 맨 위로 초기화 - Future 지연을 사용하여 더 안정적으로 처리
    Future.delayed(Duration.zero, () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0); // animateTo 대신 jumpTo를 사용하여 즉시 이동
      }
    });
  }

  // 모든 아이템의 플랫 리스트 얻기
  List<BaggageItem> get allSelectedItems {
    List<BaggageItem> allItems = [];
    selectedItemsMap.forEach((_, items) {
      allItems.addAll(items);
    });
    return allItems;
  }

  // 카테고리별 아이템 얻기
  List<BaggageItem> getItemsByCategory(String category) {
    return allSelectedItems.where((item) => item.category == category).toList();
  }

  Widget _buildSelectedHeader() {
    Map<String, int> itemCounts = {};
    Map<String, String?> itemIconPaths = {};
    List<BaggageItem> items = allSelectedItems;

    for (var item in items) {
      final itemName = item.itemName;

      if (itemCounts.containsKey(itemName)) {
        itemCounts[itemName] = itemCounts[itemName]! + 1;
      } else {
        itemCounts[itemName] = 1;

        final key = createItemKey(item.cateId, item.loadCd);
        if (selectedItemsMap.containsKey(key) && selectedItemsMap[key]!.isNotEmpty) {
          final firstItem = selectedItemsMap[key]!.first;

          // 카테고리의 아이템 리스트에서 iconPath 찾기
          final matchingCategoryItem = categories[firstItem.category]?.firstWhere(
                (categoryItem) => categoryItem['loadNm'] == firstItem.itemName,
            orElse: () => {'iconPath': null}, // 기본값을 가진 맵 반환
          );

          itemIconPaths[itemName] = matchingCategoryItem == null
              ? null
              : matchingCategoryItem['iconPath'] as String?;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 3.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '내 이삿짐',
                style: AppTheme.subheadingStyle.copyWith(
                  fontSize: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalSelectedItems개 선택',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 선택된 아이템이 있을 경우에만 표시
          if (items.isNotEmpty)
            Container(
              height: 58,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: itemCounts.entries.map((entry) {
                  final itemName = entry.key;
                  final count = entry.value;
                  final String? iconPath = itemIconPaths[itemName];

                  return Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: iconPath != null
                                  ? Image.network(
                                iconPath,
                                width: 20,  // 작은 크기로 조절
                                height: 20, // 작은 크기로 조절
                                fit: BoxFit.contain,
                              )
                                  : Icon(
                                Icons.inventory,
                                color: _primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              itemName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        if (count > 1)
                          Positioned(
                            right: 3,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 35,
                    color: AppTheme.subtleText,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '선택된 이삿짐이 없습니다',
                    style: TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 40, // 카테고리 탭의 높이 설정
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // 가로 스크롤 설정
        child: Row(
          children: categories.keys.map((category) {
            final isSelected = selectedCategory == category;

            return Padding(
              padding: const EdgeInsets.only(right: 8), // 카테고리 사이 간격
              child: GestureDetector(
                onTap: () => _setSelectedCategory(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? _primaryColor : AppTheme.borderSubColor, // 선택되지 않았을 때 테두리 색상
                      width: 1.0, // 테두리 두께
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 3.0,
                      ),
                    ],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.primaryText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBaggageItem(String category, Map<String, dynamic> item) {
    final String cateId = item['cateId'];
    final String loadCd = item['loadCd'];
    final String itemName = item['loadNm'];
    final String? iconPath = item['iconPath'];

    // 'icon' 관련 코드 제거
    final key = createItemKey(cateId, loadCd);

    // 선택된 개수 계산
    int selectedItemCount = 0;
    if (selectedItemsMap.containsKey(key)) {
      selectedItemCount = selectedItemsMap[key]!
          .where((baggageItem) => baggageItem.category == category && baggageItem.itemName == itemName)
          .length;
    }

    final bool isSelected = selectedItemCount > 0;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: isSelected
                ? _primaryColor
                : Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: () => _toggleSelection(category, item),
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: iconPath != null
                            ? Image.network(
                          iconPath,
                          width: 40,  // 원하는 크기로 조절 가능
                          height: 40, // 원하는 크기로 조절 가능
                          fit: BoxFit.contain, // 이미지의 비율 유지
                        )
                            : Icon(
                          Icons.inventory,
                          color: _primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        itemName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: AppTheme.primaryText,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 선택된 아이템 개수 표시
            if (isSelected && selectedItemCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    selectedItemCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),

            // 삭제 버튼
            if (isSelected)
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _decreaseCount(category, itemName, cateId, loadCd),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(AppTheme.cardRadius),
                      topLeft: Radius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(AppTheme.cardRadius - 2),
                          topLeft: Radius.circular(12),
                        ),
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovingTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: _primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '이삿짐 선택 가이드',
                style: AppTheme.subheadingStyle.copyWith(
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 팁 리스트
          _buildTipItem(
            icon: Icons.error_outline,
            title: '자주 누락되는 이삿짐',
            description: '베란다, 다용도실, 옷장 위의 물건들을 꼭 확인하세요.',
          ),
          const SizedBox(height: 12),

          _buildTipItem(
            icon: Icons.sort,
            title: '효율적인 짐 선택 방법',
            description: '최근 6개월간 사용하지 않은 물건은 처분을 고려해보세요.',
          ),
          const SizedBox(height: 12),

          _buildTipItem(
            icon: Icons.category_outlined,
            title: '카테고리별 주요 물품',
            description: '각 공간별로 물품을 분류하면 빠짐없이 선택할 수 있습니다.',
          ),
          const SizedBox(height: 12),

          _buildTipItem(
            icon: Icons.format_list_numbered,
            title: '짐 정리/포장 순서',
            description: '자주 사용하지 않는 물건부터 먼저 포장하세요.',
          ),
        ],
      ),
    );
  }

// 팁 아이템 위젯
  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: _primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      );
    }

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.subtleText,
            ),
            const SizedBox(height: 16),
            Text(
              '데이터를 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => fetchBaggageItems(),
              style: TextButton.styleFrom(
                foregroundColor: _primaryColor,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 현재 선택된 카테고리가 없거나 categories에 없는 경우 첫 번째 카테고리로 설정
    if (selectedCategory == null || !categories.containsKey(selectedCategory)) {
      selectedCategory = categories.keys.first;
    }

    final currentItems = categories[selectedCategory!] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 선택된 아이템 헤더
        _buildSelectedHeader(),

        const SizedBox(height: 15),

        // 카테고리 탭 UI
        _buildCategoryTabs(),

        const SizedBox(height: 15),

        // 현재 카테고리 제목
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category,
                size: 16,
                color: _primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              selectedCategory!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            const Spacer(),
            Text(
              '총 ${currentItems.length}개',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 그리드 뷰와 이삿짐 박스 섹션을 하나의 스크롤 뷰로 통합
        Expanded(
          child: currentItems.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: AppTheme.subtleText,
                ),
                const SizedBox(height: 16),
                Text(
                  '${selectedCategory!}에 해당하는 아이템이 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          )
              : SingleChildScrollView(
            controller: _scrollController, // 스크롤 컨트롤러 연결
            child: Column(
              children: [
                // 아이템 그리드
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: currentItems.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // 내부 스크롤 비활성화
                  itemBuilder: (context, index) {
                    return _buildBaggageItem(
                      selectedCategory!,
                      currentItems[index],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 이삿짐 선택 팁
                _buildMovingTips(),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          '내 이삿짐 목록',
          style: AppTheme.subheadingStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 도움말 버튼
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.primaryText),
            onPressed: () {
              _showHelpDialog();
            },
          ),
          // 전체 삭제 버튼
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.primaryText),
            onPressed: selectedItemsMap.isEmpty
                ? null
                : () {
              _showDeleteConfirmDialog();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        decoration: BoxDecoration(
          color: Colors.white,

        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: totalSelectedItems > 0
                ? () {
              // 다음 단계로 넘어가는 로직
              _proceedToNextStep();
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              disabledBackgroundColor: AppTheme.subtleText,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '다음 단계로',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 도움말 다이얼로그
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: _primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '이삿짐 선택 도움말',
              style: AppTheme.subheadingStyle.copyWith(fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(
                icon: Icons.category,
                title: '카테고리 선택',
                description: '상단 탭에서 물품 카테고리를 선택할 수 있습니다.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.add_circle_outline,
                title: '물품 추가',
                description: '물품 카드를 탭하면 해당 물품이 내 이삿짐 목록에 추가됩니다.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.remove_circle_outline,
                title: '물품 제거',
                description: '추가된 물품의 오른쪽 하단 - 버튼을 탭하면 해당 물품이 제거됩니다.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.inventory_2,
                title: '박스 개수',
                description: '이삿짐을 담을 박스의 개수를 설정합니다. + 또는 - 버튼으로 조절할 수 있습니다.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.delete_outline,
                title: '전체 삭제',
                description: '상단 메뉴의 삭제 버튼을 사용해 모든 선택 항목을 초기화할 수 있습니다.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 도움말 아이템 위젯
  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: _primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.warning,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '이삿짐 목록 초기화',
              style: AppTheme.subheadingStyle.copyWith(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          '선택한 모든 이삿짐 항목이 삭제됩니다. 계속하시겠습니까?',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.primaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.secondaryText,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedItemsMap.clear();  // 모든 항목 삭제
                _saveSelectedItems();
              });
              Navigator.pop(context);

              // 피드백 제공
              context.showSnackBar('이삿짐 목록이 초기화되었습니다.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  // 다음 단계로 진행
  void _proceedToNextStep() async {
    // 선택한 아이템과 박스 정보를 다음 화면으로 전달
    final int totalItemCount = totalSelectedItems;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      useSafeArea: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 바텀시트 핸들
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 요약 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '이삿짐 선택 완료',
                    style: AppTheme.subheadingStyle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 선택 요약
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.scaffoldBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // 왼쪽: 카테고리 수와 물품 수
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCompactSummaryItem(
                                icon: Icons.category_outlined,
                                title: '카테고리 수',
                                value: '${_getSelectedCategories().length}개',
                              ),
                              SizedBox(height: 12),
                              _buildCompactSummaryItem(
                                icon: Icons.inventory_2_outlined,
                                title: '총 선택 물품',
                                value: '$totalItemCount개',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 오른쪽: 안내 메시지
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '다음 단계',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              '각 항목의 상세 정보를 입력하고 이사 견적을 더 정확하게 받으세요.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 선택 목록 - 스크롤 가능한 영역
            Expanded(
              child: selectedItemsMap.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: AppTheme.subtleText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '선택된 항목이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // 카테고리를 2열로 표시
                  ...List.generate(
                    (_getSelectedCategories().length / 2).ceil(),
                        (index) {
                      final categories = _getSelectedCategories();
                      // 현재 행에 표시할, 첫 번째 카테고리
                      final firstIndex = index * 2;
                      final String firstCategory = categories[firstIndex];

                      // 두 번째 카테고리 (존재하는 경우)
                      final hasSecondCategory = firstIndex + 1 < categories.length;
                      final String? secondCategory = hasSecondCategory ? categories[firstIndex + 1] : null;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 첫 번째 카테고리 컬럼
                          Expanded(
                            child: _buildCategoryItemsColumn(firstCategory),
                          ),
                          SizedBox(width: 12),
                          // 두 번째 카테고리 컬럼 (있는 경우)
                          Expanded(
                            child: secondCategory != null
                                ? _buildCategoryItemsColumn(secondCategory)
                                : Container(), // 두 번째 카테고리가 없으면 빈 컨테이너
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // 하단 버튼
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '돌아가기',
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async  {
                          // 다음 화면으로 이동하는 로직
                          Navigator.pop(context); // 모달 닫기

                          // BaggageDetailScreen으로 이동
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BaggageDetailScreen(
                                selectedItemsMap: selectedItemsMap,
                                isRegularMove: widget.isRegularMove,
                              ),
                            ),
                          );

                          // 결과 데이터가 있으면 상태 업데이트
                          if (result != null && result is Map) {
                            setState(() {
                              // 삭제된 아이템이 반영된 새로운 selectedItemsMap으로 업데이트
                              if (result['selectedItemsMap'] != null) {
                                selectedItemsMap = result['selectedItemsMap'];
                              }
                              // 상태 저장
                              _saveSelectedItems();
                            });
                          }

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '계속하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItemsColumn(String category) {
    // 카테고리별로 물품을 그룹화하고 개수 집계
    Map<String, int> itemCountMap = {};

    // 해당 카테고리의 모든 아이템을 순회하며 개수 집계
    getItemsByCategory(category).forEach((item) {
      final itemName = item.itemName;

      if (itemCountMap.containsKey(itemName)) {
        itemCountMap[itemName] = itemCountMap[itemName]! + 1;
      } else {
        itemCountMap[itemName] = 1;
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _primaryColor,
            ),
          ),
        ),
        // 집계된 아이템과 개수를 표시
        ...itemCountMap.entries.map((entry) {
          final itemName = entry.key;
          final count = entry.value;

          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.scaffoldBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.success,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          itemName,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // 개수가 1개 이상일 때만 개수 표시
                      if (count > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${count}개',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 16), // 카테고리 사이 간격
      ],
    );
  }

  Widget _buildCompactSummaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: _primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryText,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 선택된 카테고리 목록 반환
  List<String> _getSelectedCategories() {
    Set<String> categories = {};

    // 모든 선택된 아이템을 순회하면서 카테고리 수집
    for (var item in allSelectedItems) {
      categories.add(item.category);
    }

    return categories.toList();
  }

}