import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_constants.dart';

class BaggageListScreen extends StatefulWidget {
  const BaggageListScreen({super.key});

  @override
  _BaggageListScreenState createState() => _BaggageListScreenState();
}

class _BaggageListScreenState extends State<BaggageListScreen> {
  final Map<String, Map<String, dynamic>> selectedItems = {};
  int boxCount = 0;
  Map<String, List<Map<String, dynamic>>> categories = {};
  bool isLoading = true;
  String? selectedCategory;


  final List<IconData> icons = [
    Icons.bed,
    Icons.inventory,
    Icons.cabin,
    Icons.checkroom,
    Icons.door_back_door,
    Icons.storage,
    Icons.table_bar,
    Icons.bedroom_baby,
    Icons.chair,
    Icons.desk,
    Icons.chair_alt,
    Icons.shelves,
    Icons.tv,
    Icons.computer,
    Icons.ac_unit,
    Icons.local_laundry_service,
    Icons.air,
    Icons.dry_cleaning,
    Icons.cleaning_services,
    Icons.kitchen,
    Icons.microwave,
    Icons.water_damage,
    Icons.fireplace,
    Icons.crop_portrait,
    Icons.piano,
    Icons.water_damage,
    Icons.directions_bike,
    Icons.grass,
    Icons.event_seat,
    Icons.fence,
    Icons.child_friendly,
    Icons.book,
    Icons.dry,
  ];

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

    // Map을 JSON 문자열로 변환할 때 IconData는 제외
    final selectedItemsJson = json.encode(selectedItems.map((key, value) {
      var subData = Map<String, dynamic>.from(value['subData'] as Map<String, dynamic>);
      // icon 데이터 제거
      subData.remove('icon');

      return MapEntry(key, {
        'count': value['count'],
        'subData': subData,
      });
    }));

    await prefs.setInt('boxCount', boxCount);
    await prefs.setString('selectedItems', selectedItemsJson);
  }

  Future<void> _loadSelectedItems() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      boxCount = prefs.getInt('boxCount') ?? 0;
    });

    final selectedItemsJson = prefs.getString('selectedItems');
    if (selectedItemsJson != null) {
      final decodedItems = json.decode(selectedItemsJson) as Map<String, dynamic>;

      setState(() {
        selectedItems.clear();
        decodedItems.forEach((key, value) {
          // 카테고리와 아이템 이름 추출
          final parts = key.split('|');
          if (parts.length >= 2) {
            final category = parts[0];
            final itemName = parts[1].replaceAll(RegExp(r'\(\d+\)'), '');

            // categories가 null이 아니고 해당 카테고리가 존재하는 경우에만 처리
            if (categories.containsKey(category)) {
              final itemsList = categories[category];
              if (itemsList != null) {
                // 원본 아이템 찾기
                final originalItem = itemsList.firstWhere(
                      (item) => item['loadNm'] == itemName,
                  orElse: () => {'icon': Icons.inventory},
                );

                // subData에 icon 추가
                var subData = Map<String, dynamic>.from(value['subData'] as Map<String, dynamic>);
                subData['icon'] = originalItem['icon'] ?? Icons.inventory;

                selectedItems[key] = {
                  'count': value['count'],
                  'subData': subData,
                };
              }
            }
          }
        });
      });
    }
  }

  Future<void> fetchBaggageItems() async {
    const url = 'http://moving.stst.co.kr/api/api/LoadInfo';
    final random = Random(); // 랜덤 인스턴스 생성

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;

        setState(() {
          categories = {};
          for (var item in data) {
            if (item['cateId'] != 'CT9999') {
              final category = item['cateNm'];
              if (!categories.containsKey(category)) {
                categories[category] = [];
              }
              categories[category]?.add({
                'loadCd': item['loadCd'],
                'loadNm': item['loadNm'],
                'subData': item['subData'], // subData 추가
                'icon': icons[random.nextInt(icons.length)], // 아이템별 랜덤 아이콘 추가
              });
            }
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }



  // 아이템 선택 토글 메서드 수정
  void _toggleSelection(String category, String itemName, Map<String, dynamic> subData) {
    int itemCount = selectedItems.keys.where((key) => key.startsWith('$category|$itemName')).length;
    final String key = '$category|$itemName(${itemCount + 1})';
    setState(() {
      selectedItems[key] = {
        'count': 1,
        'subData': subData,
      };
      _saveSelectedItems(); // 상태 변경 후 저장
    });

    // 피드백 제공
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName 추가됨', style: TextStyle(color: Colors.white),),
        duration: Duration(seconds: 1),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  // 아이템 감소 메서드 수정
  void _decreaseCount(String category, String item) {
    final keysToRemove = selectedItems.keys.where((key) => key.startsWith('$category|$item')).toList();

    if (keysToRemove.isNotEmpty) {
      setState(() {
        final lastKey = keysToRemove.last;
        if (selectedItems[lastKey]!['count'] > 1) {
          selectedItems[lastKey]!['count'] = selectedItems[lastKey]!['count'] - 1;
        } else {
          selectedItems.remove(lastKey);
        }
        _saveSelectedItems(); // 상태 변경 후 저장
      });

      // 피드백 제공
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$item 제거됨'),
          duration: Duration(seconds: 1),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
    }
  }

  // 박스 카운트 증가/감소 메서드 수정
  void _increaseBoxCount() {
    setState(() {
      boxCount += 5;
      _saveSelectedItems(); // 상태 변경 후 저장
    });
  }

  void _decreaseBoxCount() {
    setState(() {
      if (boxCount >= 5) {  // 5 이상일 때만 감소
        boxCount -= 5;
        _saveSelectedItems();
      }
    });
  }

  // 선택된 항목의 총 개수를 계산
  int get totalSelectedItems {
    return selectedItems.length;
  }

  // 선택된 카테고리 변경
  void _setSelectedCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  Widget _buildSelectedHeader() {
    // 같은 품목별로 개수를 집계
    Map<String, int> itemCounts = {};
    Map<String, IconData> itemIcons = {};

    selectedItems.forEach((key, value) {
      final parts = key.split('|');
      if (parts.length >= 2) {
        final itemName = parts[1].replaceAll(RegExp(r'\(\d+\)'), '');
        final combinedKey = itemName; // 아이템 이름만으로 키 생성

        if (itemCounts.containsKey(combinedKey)) {
          itemCounts[combinedKey] = itemCounts[combinedKey]! + 1;
        } else {
          itemCounts[combinedKey] = 1;
          itemIcons[combinedKey] = value['subData']['icon'] ?? Icons.inventory;
        }
      }
    });

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
        // border: Border.all(
        //   color: AppTheme.borderSubColor,
        //   width: 1.3,
        // ),
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
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),

                ),
                child: Text(
                  '$totalSelectedItems개 선택',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 선택된 아이템이 있을 경우에만 표시
          if (selectedItems.isNotEmpty)
            Container(
              height: 65,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: itemCounts.entries.map((entry) {
                  final itemName = entry.key;
                  final count = entry.value;
                  final IconData itemIcon = itemIcons[itemName] ?? Icons.inventory;

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
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                itemIcon,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
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
                    size: 48,
                    color: AppTheme.subtleText,
                  ),
                  const SizedBox(height: 8),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: categories.keys.map((category) {
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () => _setSelectedCategory(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 3.0,
                  ),
                ],
                // border: Border.all(
                //   color: isSelected ? AppTheme.primaryColor : AppTheme.borderSubColor,
                //   width: 1.3,
                // ),
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
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBaggageItem(String category, Map<String, dynamic> item) {
    final itemName = item['loadNm'];
    final IconData itemIcon = item['icon'] ?? Icons.inventory;
    final selectedItemCount = selectedItems.keys.where((key) => key.startsWith('$category|$itemName')).length;
    final bool isSelected = selectedItemCount > 0;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: () => _toggleSelection(category, itemName, item),
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : Color(0xFFF5F7FA),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          itemIcon,
                          size: 26,
                          color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 10),
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

            // 기존의 카운트와 삭제 버튼 부분은 그대로 유지
            if (isSelected && selectedItemCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
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
            if (isSelected)
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _decreaseCount(category, itemName),
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

  Widget _buildBoxCounter() {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '이삿짐 박스',
                style: AppTheme.subheadingStyle.copyWith(
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  // 가이드 정보 보여주기
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.secondaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text('박스 개수 가이드'),
                        ],
                      ),
                      content: Text(
                        '1. 실제 이사 시 예상보다 짐이 많은 경우가 많습니다.\n'
                            '2. 박스 개수를 넉넉하게 입력해 주세요.\n'
                            '3. 봉투나 가방에 담긴 작은 짐도 개수에 포함해 주세요.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryText,
                          height: 1.5,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('확인'),
                        ),
                      ],
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '가이드',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 박스 카운터 UI 간소화
          Row(
            children: [
              // 박스 이미지 부분
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.scaffoldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/box.png',
                  height: 90,
                  width: 90,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),

              // 카운터 부분
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '필요한 박스 개수',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '48 x 38 x 34 (cm)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          boxCount > 0 ? '${boxCount - 4} ~ $boxCount' : '0',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _decreaseBoxCount,
                            icon: const Icon(Icons.remove),
                            color: Colors.white,
                            iconSize: 18,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _increaseBoxCount,
                            icon: const Icon(Icons.add),
                            color: Colors.white,
                            iconSize: 18,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
                foregroundColor: AppTheme.primaryColor,
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

        const SizedBox(height: 16),

        // 카테고리 탭 UI
        _buildCategoryTabs(),

        const SizedBox(height: 16),

        // 현재 카테고리 제목
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category,
                size: 16,
                color: AppTheme.primaryColor,
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

        const SizedBox(height: 16),

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
            child: Column(
              children: [
                // 아이템 그리드
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
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

                // 박스 카운터 UI
                _buildBoxCounter(),

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
            onPressed: selectedItems.isEmpty
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              backgroundColor: AppTheme.primaryColor,
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
                const SizedBox(width: 8),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: AppTheme.primaryColor,
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
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
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
                selectedItems.clear();
                _saveSelectedItems();
              });
              Navigator.pop(context);

              // 피드백 제공
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('이삿짐 목록이 초기화되었습니다'),
                  duration: Duration(seconds: 2),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
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
  void _proceedToNextStep() {
    // 선택한 아이템과 박스 정보를 다음 화면으로 전달
    final int totalItemCount = selectedItems.length;

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
                      color: AppTheme.primaryColor,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '선택 내역 요약',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem(
                          icon: Icons.inventory_2_outlined,
                          title: '총 선택 물품',
                          value: '$totalItemCount개',
                        ),
                        _buildSummaryItem(
                          icon: Icons.category_outlined,
                          title: '카테고리 수',
                          value: '${_getSelectedCategories().length}개',
                        ),
                        _buildSummaryItem(
                          icon: Icons.archive_outlined,
                          title: '예상 박스 수',
                          value: '${boxCount}개',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 선택 물품 리스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '선택한 물품 목록',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${selectedItems.length}개 항목',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 선택 목록 - 스크롤 가능한 영역
            Expanded(
              child: selectedItems.isEmpty
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
                children: _getSelectedCategories().map((category) {
                  final items = _getItemsByCategory(category);

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
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      ...items.map((item) {
                        final parts = item.split('|');
                        final itemName = parts[1].replaceAll(RegExp(r'\(\d+\)'), '');

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
                                child: Text(
                                  itemName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primaryText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
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
                          side: BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '돌아가기',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // 다음 화면으로 이동하는 로직
                          Navigator.pop(context);
                          // TODO: 다음 화면으로 이동
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('다음 화면으로 이동합니다'),
                              duration: Duration(seconds: 2),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
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

  // 요약 아이템 위젯
  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  // 선택된 카테고리 목록 반환
  List<String> _getSelectedCategories() {
    Set<String> categories = {};

    for (var key in selectedItems.keys) {
      final parts = key.split('|');
      if (parts.isNotEmpty) {
        categories.add(parts[0]);
      }
    }

    return categories.toList();
  }

  // 카테고리별 아이템 목록 반환
  List<String> _getItemsByCategory(String category) {
    return selectedItems.keys
        .where((key) => key.startsWith('$category|'))
        .toList();
  }
}