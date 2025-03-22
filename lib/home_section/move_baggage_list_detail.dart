import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/theme_constants.dart';
import '../modal/home_modal/move_baggage_detail.dart';
import './models/baggage_item.dart';
import 'move_baggage_photo_view.dart';
import '../utils/ui_extensions.dart';


class BaggageDetailScreen extends StatefulWidget {
  final Map<String, List<BaggageItem>> selectedItemsMap; // 새로운 데이터 구조
  final bool isRegularMove;

  const BaggageDetailScreen({
    Key? key,
    required this.selectedItemsMap,
    required this.isRegularMove,
  }) : super(key: key);

  @override
  _BaggageDetailScreenState createState() => _BaggageDetailScreenState();
}

class _BaggageDetailScreenState extends State<BaggageDetailScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> photos = [];
  final PageController _pageController = PageController();
  int _currentPage = 0;

  TextEditingController memoController = TextEditingController();

  // 변경된 아이템 데이터 관리 (수정을 위해 복사)
  late Map<String, List<BaggageItem>> selectedItemsMap;

  // 이사 유형에 따른 저장 키 접두사
  String get _keyPrefix => widget.isRegularMove ? 'regular_' : 'special_';

  // 이사 유형에 따른 색상 설정
  Color get _primaryColor => widget.isRegularMove ? AppTheme.primaryColor : AppTheme.greenColor;

  Color get _primarySubColor => widget.isRegularMove ? AppTheme.greenColor : AppTheme.primaryColor;

  // 선택된 아이템을 카테고리별로 분류
  late Map<String, List<BaggageItem>> selectedItemsByCategory;

  // 상세정보 입력 완료율 계산
  int _getOptionsCompletionPercentage() {
    int totalItems = 0;
    int completedItems = 0;

    // 모든 아이템을 순회하며 옵션이 입력된 항목의 비율 계산
    getAllItems().forEach((item) {
      totalItems++;
      if (item.options.isNotEmpty) {
        completedItems++;
      }
    });

    if (totalItems == 0) return 0;
    return ((completedItems / totalItems) * 100).round();
  }

  @override
  void initState() {
    super.initState();
    // 위젯의 데이터를 복사하여 사용 (수정 가능하도록)
    selectedItemsMap = Map.from(widget.selectedItemsMap);
    // 각 항목 리스트도 복사
    selectedItemsMap.forEach((key, items) {
      selectedItemsMap[key] = List.from(items);
    });

    _organizeItemsByCategory();
    _loadState();
  }

  // 모든 아이템의 리스트 가져오기
  List<BaggageItem> getAllItems() {
    List<BaggageItem> allItems = [];
    selectedItemsMap.forEach((_, items) {
      allItems.addAll(items);
    });
    return allItems;
  }

  // 아이템을 카테고리별로 분류
  void _organizeItemsByCategory() {
    selectedItemsByCategory = {};

    // 모든 아이템을 순회하며 카테고리별로 분류
    selectedItemsMap.forEach((_, items) {
      for (var item in items) {
        final category = item.category;

        if (!selectedItemsByCategory.containsKey(category)) {
          selectedItemsByCategory[category] = [];
        }

        selectedItemsByCategory[category]!.add(item);
      }
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();

    // 아이템 데이터 저장
    final Map<String, dynamic> jsonData = {};
    selectedItemsMap.forEach((key, items) {
      jsonData[key] = items.map((item) => item.toJson()).toList();
    });

    final selectedItemsJson = json.encode(jsonData);
    await prefs.setString('${_keyPrefix}selectedItemsMap', selectedItemsJson);

    // 메모 저장
    await prefs.setString('${_keyPrefix}memo', memoController.text);

    // 사진 경로 저장
    List<String> photoPaths = photos.map((photo) => photo.path).toList();
    await prefs.setStringList('${_keyPrefix}photoPaths', photoPaths);
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // 선택된 아이템 데이터 불러오기 (이미 initState에서 widget으로부터 복사됨)

    // 메모 불러오기
    setState(() {
      memoController.text = prefs.getString('${_keyPrefix}memo') ?? '';
    });

    // 사진 경로 불러오기
    final photoPaths = prefs.getStringList('${_keyPrefix}photoPaths');
    if (photoPaths != null && photoPaths.isNotEmpty) {
      setState(() {
        photos = photoPaths.map((path) => XFile(path)).toList();
      });
    }
  }

  // 특정 아이템 삭제 메서드
  void _deleteItem(BaggageItem item) {
    // 해당 아이템의 키 찾기
    final key = createItemKey(item.cateId, item.loadCd);

    if (selectedItemsMap.containsKey(key)) {
      setState(() {
        // 아이템 삭제
        selectedItemsMap[key]!.remove(item);

        // 리스트가 비었으면 키 자체를 삭제
        if (selectedItemsMap[key]!.isEmpty) {
          selectedItemsMap.remove(key);
        }

        // 카테고리별 분류 다시하기
        _organizeItemsByCategory();

        // 변경사항 저장
        _saveState();
      });

      // 피드백 제공
      context.showSnackBar('${item.getDisplayName(getAllItems())} 항목이 삭제되었습니다');
    }
  }

  // 삭제 확인 다이얼로그
  void _showDeleteConfirmDialog(BaggageItem item) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text('항목 삭제'),
            content: Text(
                '${item.getDisplayName(getAllItems())} 항목을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '취소',
                  style: TextStyle(color: AppTheme.secondaryText),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _deleteItem(item);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('삭제', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  Future<void> selectImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage();

      if (selectedImages.isNotEmpty) {
        // 최대 12장까지만 허용
        final int remainingSlots = 12 - photos.length;
        final List<XFile> imagesToAdd = selectedImages.length <= remainingSlots
            ? selectedImages
            : selectedImages.sublist(0, remainingSlots);

        if (imagesToAdd.isNotEmpty) {
          // 선택 확인 다이얼로그 표시
          bool? confirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              // 이미지 개수에 따라 그리드 높이 동적 계산
              final int rowCount = (imagesToAdd.length / 3).ceil(); // 한 행에 3개씩 표시
              final double gridHeight = rowCount * 100.0; // 각 행 높이 100으로 계산
              final double maxHeight = MediaQuery.of(context).size.height * 0.6; // 최대 높이 제한
              final double dialogHeight = gridHeight < maxHeight ? gridHeight : maxHeight;

              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                '선택한 사진을 첨부하시겠습니까?',
                style: TextStyle(
                    fontSize: 17
                ),
              ),
                actions: [
                  TextButton(
                    child: Text('취소'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _primaryColor,
                    ),
                    child: Text('선택', style: TextStyle(color: Colors.white)),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
                content: SizedBox(
                  width: double.maxFinite,
                  height: dialogHeight, // 동적으로 계산된 높이 적용
                  child: GridView.builder(
                    itemCount: imagesToAdd.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(imagesToAdd[index].path),
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              );
            },
          );

          if (confirmed == true) {
            setState(() {
              photos.addAll(imagesToAdd);
              _saveState(); // 상태 저장
            });

            if (selectedImages.length > remainingSlots) {
              context.showSnackBar('최대 12장까지만 첨부할 수 있습니다.');
            }
          }
        }
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사진',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText
          ),
        ),
        SizedBox(height: 8),
        Text(
          '사진을 첨부하면 더 정확한 견적을 받을 수 있어요!\n(최대 12장, 사진 없어도 견적 신청 가능)',
          style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText
          ),
        ),
        SizedBox(height: 16),

        // 사진 추가 및 표시 영역
        Column(
          children: [
            // 사진 추가 옵션 버튼들
            Row(
              children: [
                // 카메라로 사진 찍기 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: photos.length < 12 ? _takePhoto : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: photos.length <12 ? _primaryColor : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '사진 찍기',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // 갤러리에서 선택 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: photos.length < 12 ? _pickFromGallery : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: photos.length < 12 ? _primaryColor : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library,
                            color: photos.length < 12 ? _primaryColor : Colors.grey[400],
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '갤러리에서 선택',
                            style: TextStyle(
                              color: photos.length < 12 ? _primaryColor : Colors.grey[400],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // 사진 카운터 표시 (있는 경우에만)
            if (photos.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${photos.length}/12장 첨부됨',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),

            SizedBox(height: 16),

            // 사진 섬네일 그리드
            photos.isEmpty
                ? _buildEmptyPhotoState()
                : Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              padding: EdgeInsets.all(12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return _buildPhotoThumbnail(index);
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        // 안내 컨테이너
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // photos.isNotEmpty로 조건부 렌더링
              if (photos.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '옮겨야 할 모든 짐의 사진을 등록해주세요!',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '사전에 협의되지 않은 항목에 대해서는 추가금이 발생할 수 있어요.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.secondaryText
                      ),
                    )
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사진을 등록하면 이런 점이 좋아요!',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor
                      ),
                    ),
                    SizedBox(height: 14),
                    _buildCheckedRow('짐 정보를 더 쉽게 설명할 수 있어요.'),
                    SizedBox(height: 8),
                    _buildCheckedRow('이사 견적을 더 정확하게 받을 수 있어요.'),
                    SizedBox(height: 8),
                    _buildCheckedRow('추가 비용 발생을 줄일 수 있어요.'),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

// 사진 없는 상태 표시
  Widget _buildEmptyPhotoState() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_back,
            color: Colors.grey[400],
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            '사진을 추가해주세요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '위 버튼을 눌러 사진을 추가할 수 있어요',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.subtleText,
            ),
          ),
        ],
      ),
    );
  }

// 사진 썸네일 아이템
  Widget _buildPhotoThumbnail(int index) {
    return GestureDetector(
      onTap: () => _showPhotoViewer(index),
      child: Stack(
        children: [
          // 썸네일 이미지
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(photos[index].path),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 삭제 버튼
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  photos.removeAt(index);
                  _saveState();
                });
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// 카메라로 사진 찍기
  Future<void> _takePhoto() async {
    try {
      final XFile? takenImage = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (takenImage != null) {
        if (photos.length < 12) {
          setState(() {
            photos.add(takenImage);
            _saveState();
          });
        } else {
          context.showSnackBar('최대 12장까지만 첨부할 수 있습니다.');
        }
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

// 갤러리에서 사진 선택
  Future<void> _pickFromGallery() async {
    try {
      // 기존 단일 선택 대신 다중 선택 함수 호출
      await selectImages();
    } catch (e) {
      print('Error picking images: $e');
    }
  }

// 전체화면 사진 뷰어 표시
  void _showPhotoViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(
          photos: photos,
          initialIndex: initialIndex,
          primaryColor: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildCheckedRow(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 10,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryText
          ),
        ),
      ],
    );
  }

  Widget _buildMemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '메모',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText
          ),
        ),
        SizedBox(height: 8),
        Text(
          '파트너에게 전달되어야 하는 정보를 입력해 주세요.',
          style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText
          ),
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black38),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: memoController,
            onChanged: (_) => _saveState(),
            maxLines: 5,
            decoration: InputDecoration(
              hintText: '입력한 짐 이외에 운동기구가 있어요.\n경유지 or 반려동물이 있어요.\n차량 동승 가능 여부를 알고 싶어요.\n냉장고, TV장은 버리고 갈 집이에요.',
              hintStyle: TextStyle(
                color: AppTheme.subtleText,
                fontSize: 14,
              ),
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

// 간결한 전문가 팁 섹션
  Widget _buildCompactExpertTips() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: _primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '이사 전문가 조언',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  _showDetailedTipsDialog();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: _primaryColor,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '모든 팁 보기',
                        style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // 4가지 주요 팁 카테고리를 아이콘과 제목만 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTipCategory(
                icon: Icons.savings,
                title: '비용 절약',
                color: Colors.green,
                onTap: () => _showSingleCategoryTipsDialog('비용 절약 팁', Icons.savings, Colors.green),
              ),
              _buildTipCategory(
                icon: Icons.event_note,
                title: '일정 관리',
                color: _primaryColor,
                onTap: () => _showSingleCategoryTipsDialog('일정 관리 팁', Icons.event_note, _primaryColor),
              ),
              _buildTipCategory(
                icon: Icons.all_inbox,
                title: '포장 꿀팁',
                color: Colors.orange,
                onTap: () => _showSingleCategoryTipsDialog('포장 꿀팁', Icons.all_inbox, Colors.orange),
              ),
              _buildTipCategory(
                icon: Icons.warning_amber,
                title: '확인사항',
                color: Colors.red,
                onTap: () => _showSingleCategoryTipsDialog('꼭 확인하세요!', Icons.warning_amber, Colors.red),
              ),
            ],
          ),

          SizedBox(height: 16),

          // 간략한 통계 정보
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: _primaryColor,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '정확한 정보를 입력한 고객 ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        TextSpan(
                          text: '95%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        TextSpan(
                          text: '가 긍정적 평가를 받았습니다.',
                          style: TextStyle(
                            fontSize: 13,
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
        ],
      ),
    );
  }

// 팁 카테고리 아이콘 위젯
  Widget _buildTipCategory({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

// 모든 팁을 보여주는 다이얼로그
  void _showDetailedTipsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: _primaryColor,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '이사 전문가 조언',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.secondaryText),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Divider(height: 1),

              // 내용 (스크롤 가능)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 비용 절약 팁
                      _buildTipSection(
                        title: '비용 절약 팁',
                        tips: [
                          '가구 규격을 정확히 입력하세요. 크기를 실제보다 작게 입력하면 추가 비용이 발생할 수 있습니다.',
                          '사전에 버릴 물건을 정리해 불필요한 운반을 줄이세요.',
                          '운반이 어려운 특수 물품은 미리 알려주세요. 준비가 필요한 경우가 있습니다.',
                          '이사 성수기(봄, 가을)를 피하면 비용이 절감될 수 있습니다.',
                          '포장 서비스가 필요한 물품을 명확히 구분해두세요.',
                        ],
                        icon: Icons.savings,
                        color: Colors.green,
                      ),

                      SizedBox(height: 20),

                      // 일정 관리 팁
                      _buildTipSection(
                        title: '일정 관리 팁',
                        tips: [
                          '최소 이사 2주 전에 파트너를 예약하세요. 특히 월말, 월초는 빨리 예약이 찹니다.',
                          '입주 청소는 이사 전날까지 완료하는 것이 좋습니다.',
                          '중요 물품(귀중품, 필수 생활용품)은 직접 운반할 계획을 세우세요.',
                          '이사 당일 날씨를 확인하고 우천 시 대비책을 마련해두세요.',
                          '새 집의 주차 공간과 엘리베이터 사용 규정을 미리 확인하세요.',
                        ],
                        icon: Icons.event_note,
                        color: _primaryColor,
                      ),

                      SizedBox(height: 20),

                      // 포장 꿀팁
                      _buildTipSection(
                        title: '포장 꿀팁',
                        tips: [
                          '깨지기 쉬운 물건은 옷이나 이불로 감싸 안전하게 포장하세요.',
                          '박스마다 내용물과 배치할 방 위치를 표시하면 정리가 쉬워집니다.',
                          '무거운 물건은 작은 박스에 나눠 담아 운반이 쉽게 하세요.',
                          '액체류는 뚜껑을 테이프로 고정하고 비닐로 한번 더 감싸세요.',
                          '전자제품의 코드는 묶어서 본체와 함께 포장하세요.',
                        ],
                        icon: Icons.all_inbox,
                        color: Colors.orange,
                      ),

                      SizedBox(height: 20),

                      // 주의 사항
                      _buildTipSection(
                        title: '꼭 확인하세요!',
                        tips: [
                          '현금, 보석, 중요 서류 등 귀중품은 반드시 직접 챙기세요.',
                          '이삿짐 보험 가입 여부를 확인하고 필요시 추가 보험을 고려하세요.',
                          '새로운 주소지를 정확히 공유하고, 특별한 접근 방법이 있다면 알려주세요.',
                          '파손 위험이 있는 물품은 미리 사진을 찍어두세요.',
                          '냉장고는 이사 전날 전원을 끄고 물기를 완전히 제거해야 합니다.',
                        ],
                        icon: Icons.warning_amber,
                        color: Colors.red,
                        isWarning: true,
                      ),

                      SizedBox(height: 20),

                      // 통계 정보
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '이렇게 작성하면 파트너 평가가 좋아요!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _primaryColor,
                              ),
                            ),
                            SizedBox(height: 12),
                            _buildStatDetail('물품 정보를 빠짐없이 기재한 고객', '95%', '긍정적 평가'),
                            SizedBox(height: 8),
                            _buildStatDetail('상세 정보를 정확히 입력한 고객', '93%', '원활한 이사 진행'),
                            SizedBox(height: 8),
                            _buildStatDetail('운반 시 주의사항을 사전에 안내한 고객', '90%', '만족도 향상'),
                            SizedBox(height: 8),
                            _buildStatDetail('특수 물품을 미리 고지한 고객', '89%', '추가 비용 없음'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 버튼
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// 단일 카테고리 팁 다이얼로그 표시
  void _showSingleCategoryTipsDialog(String title, IconData icon, Color color) {
    List<String> tips = [];

    // 카테고리별 팁 목록
    if (title == '비용 절약 팁') {
      tips = [
        '가구 규격을 정확히 입력하세요. 크기를 실제보다 작게 입력하면 추가 비용이 발생할 수 있습니다.',
        '사전에 버릴 물건을 정리해 불필요한 운반을 줄이세요.',
        '운반이 어려운 특수 물품은 미리 알려주세요. 준비가 필요한 경우가 있습니다.',
        '이사 성수기(봄, 가을)를 피하면 비용이 절감될 수 있습니다.',
        '포장 서비스가 필요한 물품을 명확히 구분해두세요.',
      ];
    } else if (title == '일정 관리 팁') {
      tips = [
        '최소 이사 2주 전에 파트너를 예약하세요. 특히 월말, 월초는 빨리 예약이 찹니다.',
        '입주 청소는 이사 전날까지 완료하는 것이 좋습니다.',
        '중요 물품(귀중품, 필수 생활용품)은 직접 운반할 계획을 세우세요.',
        '이사 당일 날씨를 확인하고 우천 시 대비책을 마련해두세요.',
        '새 집의 주차 공간과 엘리베이터 사용 규정을 미리 확인하세요.',
      ];
    } else if (title == '포장 꿀팁') {
      tips = [
        '깨지기 쉬운 물건은 옷이나 이불로 감싸 안전하게 포장하세요.',
        '박스마다 내용물과 배치할 방 위치를 표시하면 정리가 쉬워집니다.',
        '무거운 물건은 작은 박스에 나눠 담아 운반이 쉽게 하세요.',
        '액체류는 뚜껑을 테이프로 고정하고 비닐로 한번 더 감싸세요.',
        '전자제품의 코드는 묶어서 본체와 함께 포장하세요.',
      ];
    } else if (title == '꼭 확인하세요!') {
      tips = [
        '현금, 보석, 중요 서류 등 귀중품은 반드시 직접 챙기세요.',
        '이삿짐 보험 가입 여부를 확인하고 필요시 추가 보험을 고려하세요.',
        '새로운 주소지를 정확히 공유하고, 특별한 접근 방법이 있다면 알려주세요.',
        '파손 위험이 있는 물품은 미리 사진을 찍어두세요.',
        '냉장고는 이사 전날 전원을 끄고 물기를 완전히 제거해야 합니다.',
      ];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    title == '꼭 확인하세요!' ? Icons.priority_high : Icons.check_circle,
                    color: color,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: color,
            ),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

// 팁 섹션 위젯 (다이얼로그 내부용)
  Widget _buildTipSection({
    required String title,
    required List<String> tips,
    required IconData icon,
    required Color color,
    bool isWarning = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isWarning ? Icons.priority_high : Icons.check_circle,
                color: color,
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

// 통계 세부 정보 아이템
  Widget _buildStatDetail(String text, String percentage, String result) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: _primaryColor, size: 14),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '$text ($percentage)',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryText,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 상세정보 모달 표시
  void showItemDetailModal(BuildContext context, BaggageItem item) {
    // 현재 아이템의 모든 상세정보 가져오기
    List<BaggageItem> allItems = getAllItems();

    // 같은 종류의 다른 아이템 찾기 (같은 cateId, loadCd 가진 항목)
    List<BaggageItem> sameTypeItems = allItems.where((otherItem) =>
    otherItem.cateId == item.cateId &&
        otherItem.loadCd == item.loadCd &&
        otherItem != item &&
        otherItem.options.isEmpty // 상세정보가 입력되지 않은 항목만
    ).toList();

    // 중복 아이템의 표시 이름 리스트
    List<String> duplicateItemNames = sameTypeItems
        .map((i) => i.getDisplayName(allItems))
        .toList();

    // subData 처리 수정
    List<Map<String, dynamic>> processedSubData = [];

    // subData 타입에 따라 다르게 처리
    if (item.subData is Map<String, dynamic>) {
      // subData가 Map인 경우
      Map<String, dynamic> subDataMap = item.subData as Map<String, dynamic>;
      if (subDataMap.containsKey('subData')) {
        var subDataField = subDataMap['subData'];
        if (subDataField is List) {
          processedSubData = subDataField
              .where((e) => e is Map<String, dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }
      }
    } else if (item.subData is List) {
      // subData가 List인 경우
      List subDataList = item.subData as List;
      processedSubData = subDataList
          .where((e) => e is Map<String, dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemDetailModal(
          itemName: item.getDisplayName(allItems),
          preselectedOptions: item.options,
          subData: processedSubData,
          duplicateItems: duplicateItemNames,
          themeColor: _primaryColor,
          onConfirm: (options, duplicates) {
            setState(() {
              // 현재 아이템 옵션 업데이트
              item.options = options;

              // 중복 적용 대상 아이템 찾아서 업데이트
              for (int i = 0; i < duplicates.length; i++) {
                if (i < sameTypeItems.length) {
                  sameTypeItems[i].options = Map.from(options);
                }
              }

              _saveState(); // 상태 저장
            });
          },
        ),
      ),
    );
  }

  Widget _buildListItem(BaggageItem item) {
    // 현재 아이템의 표시 이름
    String displayName = item.getDisplayName(getAllItems());
    bool hasDetails = item.options.isNotEmpty;

    return GestureDetector(
      onTap: () {
        showItemDetailModal(context, item);
      },
      child: Container(
        // 상세 입력 유무에 따른 배경색 설정
        decoration: BoxDecoration(
          color: hasDetails
              ? _primaryColor.withOpacity(0.05) // 상세 입력 완료 시 연한 배경색
              : Colors.white,
          borderRadius: BorderRadius.circular(10), // 더 둥글게
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), // 마진 증가
        padding: const EdgeInsets.fromLTRB(0, 14.0, 12.0, 14.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppTheme.error),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(), // 최소 크기 제약 제거
              iconSize: 20,
              onPressed: () => _showDeleteConfirmDialog(item),
            ),

            // 항목 이름과 상세 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: hasDetails
                          ? AppTheme.primaryText
                          : AppTheme.secondaryText,
                    ),
                  ),
                  if (hasDetails)
                    const SizedBox(height: 4),
                  if (hasDetails)
                    Text(
                      item.options.values.join(', '),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // 상세정보 입력 버튼
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6), // 여백 증가
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasDetails ? _primaryColor : Colors.grey[300]!,
                  width: 1,
                ),
                boxShadow: [
                  if (!hasDetails)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasDetails ? '수정' : '입력',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: hasDetails ? _primaryColor : Colors.grey[600],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: hasDetails ? _primaryColor : Colors.grey[400],
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int getCountOfDetailedItemsByCategory(String category) {
    if (!selectedItemsByCategory.containsKey(category)) return 0;

    return selectedItemsByCategory[category]!
        .where((item) => item.options.isNotEmpty)
        .length;
  }

  int getSelectedItemCountForCategory(String category) {
    return selectedItemsByCategory[category]?.length ?? 0;
  }

  Widget _buildCategorySection(String category, List<BaggageItem> items) {
    // 입력 완료된 아이템 수와 백분율 계산
    int totalItems = items.length;
    int completedItems = items.where((item) => item.options.isNotEmpty).length;
    int percentage = totalItems > 0 ? ((completedItems / totalItems) * 100).round() : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.category,
                        size: 16,
                        color: _primaryColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: percentage == 100
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        percentage == 100 ? Icons.check_circle : Icons.pending,
                        size: 14,
                        color: _primarySubColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '$completedItems/$totalItems',
                        style: TextStyle(
                          color: _primarySubColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 진행률 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(_primarySubColor,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _primarySubColor,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // 아이템 목록
          ...items.map((item) => Column(
            children: [
              _buildListItem(item),
              if (items.indexOf(item) < items.length - 1)
                Divider(height: 1, indent: 16, endIndent: 16),
            ],
          )).toList(),

          SizedBox(height: 8),
        ],
      ),
    );
  }

  int getTotalSelectedItems() {
    return getAllItems().length;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // 이전 화면으로 돌아갈 때 변경된 selectedItemsMap 전달
      Navigator.pop(context, {
        'selectedItemsMap': selectedItemsMap
      });
      return false;  // false 반환하여 pop 동작 가로채기
    },
    child: Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          '상세 정보 입력',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () {
            // 뒤로가기 버튼 클릭 시에도 데이터 전달
            Navigator.pop(context, {
            'selectedItemsMap': selectedItemsMap
            });
          }
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: _primaryColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${getTotalSelectedItems()}',
                                          style: TextStyle(
                                              color: _primaryColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        TextSpan(
                                          text: '개 항목이 선택되었습니다',
                                          style: TextStyle(
                                              color: AppTheme.primaryText,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width - 100,
                                    child: Text(
                                      '추가 요금이 발생하지 않도록\n정확한 정보를 입력해 주세요.',
                                      style: TextStyle(
                                          color: AppTheme.secondaryText,
                                          fontSize: 13
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // 상태 요약 - 상세정보 입력 현황
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: _primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '항목 상세정보를 모두 입력해야 견적이 정확해집니다. ',
                                        style: TextStyle(
                                          color: AppTheme.secondaryText,
                                          fontSize: 13,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '작성률: ${_getOptionsCompletionPercentage()}%',
                                        style: TextStyle(
                                          color: _primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // 선택된 항목 카테고리별로 표시
                  for (var category in selectedItemsByCategory.keys)
                    _buildCategorySection(
                        category,
                        selectedItemsByCategory[category]!
                    ),

                  SizedBox(height: 16),
                  _buildCompactExpertTips(),

                  SizedBox(height: 30),
                  _buildPhotoSection(),

                  SizedBox(height: 30),
                  _buildMemoSection(),

                ],
              ),
            ),
          ),

          // 하단 버튼
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: ElevatedButton(
                  onPressed: () {
                    // 데이터 저장
                    _saveState();

                    // 다음 단계로 이동
                    // TODO: 여기에 견적 요청 화면으로 이동하는 코드 추가
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('견적 요청 화면으로 이동합니다'),
                        backgroundColor: _primaryColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                  ),
                  child: const Text(
                    '다음',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
}
