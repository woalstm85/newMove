import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/theme_constants.dart';
import '../modal/home_modal/move_room_select.dart'; // 방 선택 모달 임포트
import '../modal/home_modal/move_image_add.dart'; // 사진 소스 선택 모달 임포트

class RoomPhotoScreen extends StatefulWidget {
  const RoomPhotoScreen({super.key});

  @override
  _RoomPhotoScreenState createState() => _RoomPhotoScreenState();
}

class _RoomPhotoScreenState extends State<RoomPhotoScreen> {
  List<String> roomTypes = ['거실', '주방', '화장실'];
  List<List<XFile?>> selectedImages = List.generate(3, (_) => []);
  final ImagePicker _picker = ImagePicker();
  bool isEditing = false;

  // 방 카테고리 클릭 시 모달 표시
  Future<void> _showRoomSelectionDialog({int? roomIndex}) async {
    showRoomSelectionModal(
      context: context,
      title: roomIndex == null ? '방 추가하기' : '방 종류 변경',
      initialSelection: roomIndex != null ? roomTypes[roomIndex] : '거실',
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
      onImageSelected: (XFile? image) {
        if (image != null) {
          setState(() {
            selectedImages[roomIndex].add(image);
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
            fontSize: 18,
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
                color: AppTheme.primaryColor,
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
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: AppTheme.primaryColor,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '각 방마다 여러 장의 사진을 추가할 수 있어요',
                          style: TextStyle(
                            fontSize: 13,
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
                      color: AppTheme.primaryColor,
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
                              fontSize: 15,
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: ElevatedButton(
                  onPressed: _canProceed() ? () {
                    // 다음 단계로 이동하는 로직
                    Navigator.pop(context);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
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
                  child: const Text(
                    '확인',
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '위의 "방 추가하기" 버튼을 눌러\n방을 추가해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
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
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getRoomIcon(roomType),
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        roomType,
                        style: TextStyle(
                          fontSize: 16,
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
                        fontSize: 13,
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
                              color: AppTheme.primaryColor,
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '사진 추가',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryColor,
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '공간의 크기와 상태를 잘 보여주는\n사진을 촬영하면 더 정확한 견적이 가능해요',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.subtleText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 선택된 이미지 보여주기
  Widget _buildSelectedImage(int roomIndex, int imageIndex) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Stack(
        children: [
          Container(
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
          // 삭제 버튼
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