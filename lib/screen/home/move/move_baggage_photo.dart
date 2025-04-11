import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/home/move/modal/move_room_select.dart';
import 'package:MoveSmart/screen/home/move/modal/move_image_add.dart';
import 'move_baggage_photo_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'move_baggage_photo_view.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/utils/ui_mixins.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class RoomPhotoScreen extends ConsumerStatefulWidget {
  final bool isRegularMove;

  const RoomPhotoScreen({super.key, required this.isRegularMove});

  @override
  ConsumerState<RoomPhotoScreen> createState() => _RoomPhotoScreenState();
}

class _RoomPhotoScreenState extends ConsumerState<RoomPhotoScreen> with MoveFlowMixin {
  List<String> roomTypes = ['거실', '주방', '화장실'];
  List<List<XFile?>> selectedImages = List.generate(3, (_) => []);
  final ImagePicker _picker = ImagePicker();
  bool isEditing = false;


  @override
  void initState() {
    super.initState();

    // MoveFlowMixin의 isRegularMove 설정
    isRegularMove = widget.isRegularMove;

    _loadSavedData();
  }

  // 방 및 이미지 데이터 저장하기
  Future<void> _saveData() async {
    try {
      final moveNotifier = widget.isRegularMove
          ? ref.read(regularMoveProvider.notifier)
          : ref.read(specialMoveProvider.notifier);

      // 각 방의 이미지 경로 추출
      final Map<String, List<String>> roomImagePaths = {};
      for (int i = 0; i < roomTypes.length; i++) {
        final roomType = roomTypes[i];
        final images = selectedImages[i];
        final paths = images
            .where((image) => image != null)
            .map((image) => image!.path)
            .toList();
        roomImagePaths[roomType] = paths;
      }

      // Provider를 통해 데이터 저장
      await moveNotifier.saveAllRoomData(roomTypes, roomImagePaths);

      debugPrint('방 데이터 저장 완료');
    } catch (e) {
      debugPrint('데이터 저장 오류: $e');
    }
  }

  // 저장된 방 및 이미지 데이터 불러오기
  Future<void> _loadSavedData() async {
    try {
      final moveState = widget.isRegularMove
          ? ref.read(regularMoveProvider)
          : ref.read(specialMoveProvider);

      // Provider에서 데이터 가져오기
      final savedRoomTypes = moveState.moveData.roomTypes;
      final savedRoomImages = moveState.moveData.roomImages;

      if (savedRoomTypes.isNotEmpty) {
        setState(() {
          roomTypes = savedRoomTypes;
          selectedImages = List.generate(roomTypes.length, (i) {
            final roomType = roomTypes[i];
            final imagePaths = savedRoomImages[roomType] ?? [];
            return imagePaths.map((path) => XFile(path)).toList();
          });
        });
      }

      debugPrint('방 데이터 로드 완료');
    } catch (e) {
      debugPrint('데이터 로드 오류: $e');
    }
  }

  // 방 카테고리 클릭 시 모달 표시
// move_baggage_photo.dart 파일에서:
  Future<void> _showRoomSelectionDialog({int? roomIndex}) async {
    debugPrint('isRegularMove value: ${widget.isRegularMove}'); // 디버그 출력
    showRoomSelectionModal(
      context: context,
      title: roomIndex == null ? '방 추가하기' : '방 종류 변경',
      initialSelection: roomIndex != null ? roomTypes[roomIndex] : '거실',
      isRegularMove: widget.isRegularMove,  // 추가
      onConfirm: (String selectedRoom) {
        setState(() {
          if (roomIndex == null) {
            // 방 추가 모드
            roomTypes.add(selectedRoom);
            selectedImages.add([]);
          } else {
            // 방 이름 수정 모드
            roomTypes[roomIndex] = selectedRoom;
          }
        });
      },
    );
  }

  // 이미지 선택 옵션 표시 (카메라/갤러리)
  void _showImageSourceDialog(int roomIndex) {
    showImageSourceOptions(
      context: context,
      isRegularMove: widget.isRegularMove,
      onImagesSelected: (List<XFile>? images) {
        if (images != null && images.isNotEmpty) {
          setState(() {
            // 여러 이미지를 한 번에 추가
            selectedImages[roomIndex].addAll(images);
          });
        }
      },
      imagePicker: _picker,
    );
  }

  // 방 삭제 기능
  void _deleteRoom(int index) {
    setState(() {
      roomTypes.removeAt(index);
      selectedImages.removeAt(index);
    });
  }

  // BoxMemoScreen으로 이동
  void _navigateToBoxMemo() async {
    // 현재 데이터 저장
    await _saveData();

    // BoxMemoScreen으로 이동
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoxMemoScreen(
          isRegularMove: widget.isRegularMove,
        ),
      ),
    );

    // 돌아왔을 때 처리 (필요한 경우)
    if (result == true) {
      // 추가 처리 필요 시 구현
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          '방 사진 찍기',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: context.scaledFontSize(18),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
            child: Text(
              isEditing ? '완료' : '편집',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 설명 섹션
          Container(
            padding: const EdgeInsets.all(20.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${roomTypes.length}개의 방을 추가했어요',
                          style: TextStyle(
                            fontSize: context.scaledFontSize(16),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '각 방마다 여러 장의 사진을 추가할 수 있어요',
                          style: TextStyle(
                            fontSize: context.scaledFontSize(13),
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    _showRoomSelectionDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '방 추가하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.scaledFontSize(15),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // 방 리스트
          Expanded(
            child: roomTypes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              itemCount: roomTypes.length,
              itemBuilder: (context, roomIndex) {
                return _buildRoomItem(roomTypes[roomIndex], roomIndex);
              },
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
                padding: EdgeInsets.all(context.defaultPadding),
                child: ElevatedButton(
                  onPressed: _canProceed() ? () {
                    // 다음 단계로 이동
                    _navigateToBoxMemo();
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isRegularMove ? primaryColor : AppTheme.greenColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                  ),
                  child: Text(
                    '다음 단계로',
                    style: TextStyle(
                      fontSize: context.scaledFontSize(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 빈 상태 표시
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 60,
            color: AppTheme.secondaryText.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            '아직 추가된 방이 없어요',
            style: TextStyle(
              fontSize: context.scaledFontSize(18),
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '위의 "방 추가하기" 버튼을 눌러\n방을 추가해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.scaledFontSize(14),
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // 방 아이템 위젯
  Widget _buildRoomItem(String roomType, int roomIndex) {
    int imageCount = selectedImages[roomIndex].length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 방 헤더 (이름 + 편집/삭제)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _showRoomSelectionDialog(roomIndex: roomIndex);
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getRoomIcon(roomType),
                          size: 18,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        roomType,
                        style: TextStyle(
                          fontSize: context.scaledFontSize(16),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.secondaryText,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                if (isEditing)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppTheme.error,
                      size: 20,
                    ),
                    onPressed: () {
                      _deleteRoom(roomIndex);
                    },
                  ),
              ],
            ),

            SizedBox(height: 12),

            // 사진 추가 버튼과 썸네일 목록
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '$imageCount장의 사진',
                      style: TextStyle(
                        fontSize: context.scaledFontSize(13),
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    // 사진 추가 버튼
                    GestureDetector(
                      onTap: () => _showImageSourceDialog(roomIndex),
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: primaryColor,
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '사진 추가',
                              style: TextStyle(
                                fontSize: context.scaledFontSize(13),
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    // 선택된 이미지 목록
                    Expanded(
                      child: selectedImages[roomIndex].isEmpty
                          ? _buildEmptyImageHint()
                          : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            selectedImages[roomIndex].length,
                                (imageIndex) => _buildSelectedImage(
                              roomIndex,
                              imageIndex,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 방 아이콘 가져오기
  IconData _getRoomIcon(String roomType) {
    switch (roomType) {
      case '거실':
        return Icons.weekend;
      case '주방':
        return Icons.kitchen;
      case '안방':
      case '침실':
        return Icons.king_bed;
      case '화장실':
        return Icons.bathtub;
      case '현관':
        return Icons.door_front_door;
      case '베란다':
        return Icons.balcony;
      case '드레스룸':
        return Icons.checkroom;
      case '창고':
        return Icons.inventory;
      default:
        return Icons.home;
    }
  }

  // 이미지가 없을 때 힌트
  Widget _buildEmptyImageHint() {
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[200]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '사진을 추가해주세요',
            style: TextStyle(
              fontSize: context.scaledFontSize(14),
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '공간의 크기와 상태를 잘 보여주는\n사진을 촬영하면 더 정확한 견적이 가능해요',
            style: TextStyle(
              fontSize: context.scaledFontSize(12),
              color: AppTheme.subtleText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 선택된 이미지 보여주기
// move_baggage_photo.dart 파일의 _buildSelectedImage 메서드 수정

  Widget _buildSelectedImage(int roomIndex, int imageIndex) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Stack(
        children: [
          GestureDetector(  // 이 부분 추가 - 이미지 클릭 시 뷰어 열기
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoViewerScreen(
                    photos: selectedImages[roomIndex].whereType<XFile>().toList(),
                    initialIndex: imageIndex,
                    primaryColor: widget.isRegularMove ? AppTheme.primaryColor : AppTheme.greenColor,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(selectedImages[roomIndex][imageIndex]!.path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // 삭제 버튼 (기존 코드 유지)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedImages[roomIndex].removeAt(imageIndex);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 다음 단계로 진행할 수 있는지 확인
  bool _canProceed() {
    if (roomTypes.isEmpty) return false;

    // 최소한 하나의 방에 하나 이상의 사진이 있는지 확인
    for (var images in selectedImages) {
      if (images.isNotEmpty) return true;
    }

    return false;
  }
}