import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/theme_constants.dart';

class ImageSourceOptions {
  final BuildContext context;
  final Function(XFile?) onImageSelected;
  final ImagePicker picker;

  ImageSourceOptions({
    required this.context,
    required this.onImageSelected,
    ImagePicker? imagePicker,
  }) : picker = imagePicker ?? ImagePicker();

  // 카메라로 직접 사진 찍기
  Future<void> takePhoto() async {
    final XFile? takenImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (takenImage != null) {
      onImageSelected(takenImage);
    }
  }

  // 갤러리에서 사진 선택
  Future<void> pickFromGallery() async {
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      onImageSelected(pickedImage);
    }
  }

  // 모달 표시
  void showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ImageSourceModal(
          onCameraTap: () {
            Navigator.pop(context);
            takePhoto();
          },
          onGalleryTap: () {
            Navigator.pop(context);
            pickFromGallery();
          },
        );
      },
    );
  }
}

class ImageSourceModal extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const ImageSourceModal({
    super.key,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              Text(
                '사진 추가하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              SizedBox(height: 20),

              // 카메라 옵션
              _buildImageOptionButton(
                icon: Icons.camera_alt,
                title: '직접 사진 찍기',
                description: '카메라를 사용하여 바로 촬영합니다',
                onTap: onCameraTap,
              ),

              SizedBox(height: 12),

              // 갤러리 옵션
              _buildImageOptionButton(
                icon: Icons.photo_library,
                title: '갤러리에서 선택',
                description: '기존에 촬영된 사진을 선택합니다',
                onTap: onGalleryTap,
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 이미지 소스 선택 버튼
  Widget _buildImageOptionButton({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
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
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.secondaryText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// 쉽게 호출하기 위한 함수
void showImageSourceOptions({
  required BuildContext context,
  required Function(XFile?) onImageSelected,
  ImagePicker? imagePicker,
}) {
  final options = ImageSourceOptions(
    context: context,
    onImageSelected: onImageSelected,
    imagePicker: imagePicker,
  );

  options.showOptions();
}