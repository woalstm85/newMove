import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/theme_constants.dart';
import '../../home_section/move_baggage_photo.dart';
import '../../home_section/move_baggage_list.dart';

class BaggageTypeModal extends StatefulWidget {
  const BaggageTypeModal({super.key});

  @override
  _BaggageTypeModalState createState() => _BaggageTypeModalState();
}

class _BaggageTypeModalState extends State<BaggageTypeModal> {
  bool? isPhotoSelected;
  bool? isListSelected;

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  Future<void> _loadSelection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPhotoSelected = prefs.getBool('isPhotoSelected') ?? false;
      isListSelected = prefs.getBool('isListSelected') ?? false;
    });
  }

  Future<void> _saveSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPhotoSelected', isPhotoSelected ?? false);
    await prefs.setBool('isListSelected', isListSelected ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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

              // 헤더
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.home_outlined,
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이사할 집 입력 방법',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '편하신 방법을 선택해주세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 24),

              // 선택 옵션
              Row(
                children: [
                  Expanded(
                    child: _buildOptionCard(
                      icon: Icons.camera_alt_outlined,
                      title: '방 사진 찍기',
                      isSelected: isPhotoSelected == true,
                      onTap: () {
                        setState(() {
                          if (isPhotoSelected == true) {
                            isPhotoSelected = null;
                          } else {
                            isPhotoSelected = true;
                            isListSelected = false;
                          }
                          _saveSelection();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildOptionCard(
                      icon: Icons.inventory_2_outlined,
                      title: '짐 목록 선택',
                      isSelected: isListSelected == true,
                      onTap: () {
                        setState(() {
                          if (isListSelected == true) {
                            isListSelected = null;
                          } else {
                            isListSelected = true;
                            isPhotoSelected = false;
                          }
                          _saveSelection();
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // 선택된 옵션 설명
              if (isPhotoSelected == true)
                _buildPhotoExplanationSection(),

              if (isListSelected == true)
                _buildListExplanationSection(),

              SizedBox(height: 24),

              // 확인 버튼
              ElevatedButton(
                onPressed: (isPhotoSelected == true || isListSelected == true)
                    ? () {
                  if (isPhotoSelected == true) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RoomPhotoScreen()));
                  } else {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const BaggageListScreen()));
                  }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 0,
                ),
                child: Text(
                  '다음 단계',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// 옵션 카드 위젯 (가운데 정렬 및 체크 아이콘 텍스트 밑으로)
  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height:80,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘 및 텍스트 행
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.3) : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.primaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // 체크 아이콘 (선택된 경우에만)
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 방 사진 찍기 설명 섹션
  Widget _buildPhotoExplanationSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExplanationItem(
            icon: Icons.camera_alt,
            title: '방 사진 촬영',
            description: '이사할 집의 방 사진을 찍어 직접 짐 정보를 입력합니다.',
          ),
          SizedBox(height: 12),
          _buildExplanationItem(
            icon: Icons.auto_awesome,
            title: '손쉬운 짐 확인',
            description: '촬영한 사진을 통해 필요한 짐과 공간을 정확하게 파악할 수 있습니다.',
          ),
        ],
      ),
    );
  }

  // 짐 목록 설명 섹션
  Widget _buildListExplanationSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExplanationItem(
            icon: Icons.list_alt,
            title: '짐 목록 선택',
            description: '미리 준비된 짐 목록에서 선택하여 짐 정보를 입력합니다.',
          ),
          SizedBox(height: 12),
          _buildExplanationItem(
            icon: Icons.check_box,
            title: '간편한 체크리스트',
            description: '가구, 가전제품 등 카테고리별로 정리된 목록에서 쉽게 선택할 수 있습니다.',
          ),
        ],
      ),
    );
  }

  // 설명 아이템
  Widget _buildExplanationItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.primaryText,
                ),
              ),
              SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
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
}