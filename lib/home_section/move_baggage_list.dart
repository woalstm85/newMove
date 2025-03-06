import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'selected_baggage_screen.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';


class BaggageListScreen extends StatefulWidget {
  const BaggageListScreen({super.key});

  @override
  _BaggageListScreenState createState() => _BaggageListScreenState();
}

class _BaggageListScreenState extends State<BaggageListScreen> {
  final Map<String, Map<String, dynamic>> selectedItems = {}; // 수정: subData 포함
  int boxCount = 0;
  Map<String, List<Map<String, dynamic>>> categories = {};
  bool isLoading = true;

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

  @override
  void initState() {
    super.initState();
    fetchBaggageItems().then((_) {
      _loadSelectedItems(); // API 데이터를 먼저 불러온 후 저장된 상태 로드
    });
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

  Map<String, List<Map<String, dynamic>>> getSelectedItemsByCategory() {
    Map<String, List<Map<String, dynamic>>> selectedItemsByCategory = {};
    for (var category in categories.keys) {
      selectedItemsByCategory[category] = categories[category]!
          .where((item) => selectedItems.keys.any((key) => key.startsWith('$category|${item['loadNm']}')))
          .toList();
    }
    return selectedItemsByCategory;
  }

  Widget _buildBaggageItem(String category, Map<String, dynamic> item) {
    final itemName = item['loadNm'];
    final subData = item;  // subData는 item 전체라고 가정합니다
    final selectedItemCount = selectedItems.keys.where((key) => key.startsWith('$category|$itemName')).length;

    // 저장된 고정 아이콘 사용
    final IconData itemIcon = item['icon'] ?? Icons.inventory;

    return GestureDetector(
      onTap: () => _toggleSelection(category, itemName, subData),  // itemName과 subData 전달
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: selectedItemCount > 0 ? Colors.grey[100] : Colors.transparent,
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: selectedItemCount > 0 ? 0.3 : 1.0,
                  child: Icon(itemIcon, size: 50, color: Colors.black), // 랜덤으로 설정된 고정 아이콘 사용
                ),
                const SizedBox(height: 4),
                Text(itemName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black)),
              ],
            ),
          ),
          if (selectedItemCount > 0)
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () => _decreaseCount(category, itemName),
                child: Container(
                  color: Colors.indigo,
                  child: const Icon(Icons.remove, color: Colors.white, size: 35),
                ),
              ),
            ),
          if (selectedItemCount > 0)
            Positioned(
              top: 30,
              child: Text(
                selectedItemCount.toString(),
                style: const TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid(String category, List<Map<String, dynamic>> items) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: items.map((item) => _buildBaggageItem(category, item)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('짐 정보'),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                selectedItems.clear();
                _saveSelectedItems(); // 이 부분 추가
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '짐 카테고리',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '여기에서 짐 카테고리를 선택하세요.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              for (var category in categories.keys) ...[
                Text(
                  category,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildGrid(category, categories[category]!),
                const Divider(height: 30),
              ],
              const Text(
                '짐 박스',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. 다른 이삿짐이 있으신가요?\n'
                    '2. 실제 이사를 진행하면 예상보다 짐이 많습니다. 박스 개수를 최대한 넉넉하게 입력해 주세요.\n'
                    '3. 봉투나 가방에 담긴 작은 짐도 개수에 포함해 주세요.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(  // Column을 Expanded로 감싸기
                    flex: 1,  // 첫 번째 Column이 사용할 공간 비율
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/box.png',
                          width: 177,
                          height: 215,
                          fit: BoxFit.contain,  // cover에서 contain으로 변경
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '* 해당 샘플 박스는 사이즈 참고용 이미지입니다.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,  // 텍스트 중앙 정렬 추가
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(  // 두 번째 Column도 Expanded로 감싸기
                    flex: 1,  // 두 번째 Column이 사용할 공간 비율
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          boxCount > 0 ? '${boxCount - 4} ~ $boxCount' : '0',
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.indigoAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                onPressed: _decreaseBoxCount,
                                icon: const Icon(Icons.remove),
                                color: Colors.white,
                                iconSize: 20,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.indigoAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: IconButton(
                                onPressed: _increaseBoxCount,
                                icon: const Icon(Icons.add),
                                color: Colors.white,
                                iconSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '48 x 38 x 34 (cm)\n우체국 5호 박스 크기',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: selectedItems.isNotEmpty
              ? () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => SelectedBaggageScreen(
            //       selectedItemsByCategory: getSelectedItemsByCategory(),
            //       selectedItems: selectedItems,
            //       updateSelectedItems: (key) => setState(() => selectedItems.remove(key)),
            //     ),
            //   ),
            // ).then((_) => setState(() {}));
          }
              : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            backgroundColor: Colors.indigo,
            minimumSize: const Size(double.infinity, 60),
          ),
          child: const Text(
            '다음',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
