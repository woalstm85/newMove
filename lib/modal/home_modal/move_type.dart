import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/theme_constants.dart';
import '../../home_section/move_calendar.dart';

class MovingTypeModal extends StatefulWidget {
  const MovingTypeModal({super.key});

  @override
  _MovingTypeModalState createState() => _MovingTypeModalState();
}

class _MovingTypeModalState extends State<MovingTypeModal> {
  bool? isSmallMoveSelected = false;
  bool? isFamilyMoveSelected = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedMoveType();
  }

  // 이사 타입을 SharedPreferences에서 불러오는 함수
  Future<void> _loadSelectedMoveType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSmallMoveSelected = prefs.getBool('isSmallMoveSelected') ?? false;
      isFamilyMoveSelected = prefs.getBool('isFamilyMoveSelected') ?? false;
    });
  }

  // 선택한 이사 타입을 SharedPreferences에 저장하는 함수
  Future<void> _saveSelectedMoveType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSmallMoveSelected', isSmallMoveSelected ?? false);
    await prefs.setBool('isFamilyMoveSelected', isFamilyMoveSelected ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 제목
          const Text(
            '어떤 이사를 진행하시나요?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // 부제목
          Text(
            '이사 유형에 따라 맞춤 서비스를 제공해 드립니다',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // 이사 유형 선택 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isSmallMoveSelected = true;
                      isFamilyMoveSelected = false;
                    });
                    _saveSelectedMoveType();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: isSmallMoveSelected == true
                        ? AppTheme.primaryColor
                        : Colors.white,
                    foregroundColor: isSmallMoveSelected == true
                        ? Colors.white
                        : AppTheme.primaryText,
                    elevation: 0,
                    side: BorderSide(
                      color: isSmallMoveSelected == true
                          ? AppTheme.primaryColor
                          : AppTheme.borderColor,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: isSmallMoveSelected == true
                            ? Colors.white
                            : AppTheme.secondaryText,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '소형이사',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isSmallMoveSelected == true
                              ? Colors.white
                              : AppTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFamilyMoveSelected = true;
                      isSmallMoveSelected = false;
                    });
                    _saveSelectedMoveType();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: isFamilyMoveSelected == true
                        ? AppTheme.primaryColor
                        : Colors.white,
                    foregroundColor: isFamilyMoveSelected == true
                        ? Colors.white
                        : AppTheme.primaryText,
                    elevation: 0,
                    side: BorderSide(
                      color: isFamilyMoveSelected == true
                          ? AppTheme.primaryColor
                          : AppTheme.borderColor,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.apartment_outlined,
                        color: isFamilyMoveSelected == true
                            ? Colors.white
                            : AppTheme.secondaryText,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '가정이사',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isFamilyMoveSelected == true
                              ? Colors.white
                              : AppTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 선택된 이사 유형에 따른 정보 표시
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.scaffoldBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSmallMoveSelected == true || isFamilyMoveSelected == true
                    ? AppTheme.primaryColor.withOpacity(0.3)
                    : AppTheme.borderColor,
                width: 1.5,
              ),
            ),
            child: isSmallMoveSelected == true
                ? smallMoveInfo()
                : isFamilyMoveSelected == true
                ? familyMoveInfo()
                : initialInfo(),
          ),

          const SizedBox(height: 32),

          // 확인 버튼
          ElevatedButton(
            onPressed: (isSmallMoveSelected == true || isFamilyMoveSelected == true)
                ? () {
              // 다음 단계로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CalendarScreen()),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.subtleText,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              '확인',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 취소 버튼
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.secondaryText,
            ),
            child: const Text(
              '취소',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget initialInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                '이사 유형을 선택해 주세요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
        ),
        richBulletPoint('', '이사 정보만 입력하면 견적을 비교할 수 있어요.'),
        const SizedBox(height: 8),
        richBulletPoint('', "최종 리뷰에서 '파트너 찾기'를 통해 지정하고 견적 1건을 추가 요청할 수 있어요."),
      ],
    );
  }

  Widget smallMoveInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.home_outlined,
                color: AppTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '소형이사',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        richBulletPoint('원룸, 투룸, 20평대 미만', ' 고객님께 추천드려요.'),
        const SizedBox(height: 8),
        richBulletPoint('', '상황과 조건에 맞는 서비스를 선택하여 합리적으로 이사할 수 있어요.'),
        const SizedBox(height: 8),
        richBulletPoint('', '주요 차량: 1~2.5톤 트럭'),
        const SizedBox(height: 8),
        richBulletPoint('', '이사종류: 일반/반포장/포장'),
        const SizedBox(height: 8),
        richBulletPoint('', '평균 작업 인원: 2명 이하'),
      ],
    );
  }

  Widget familyMoveInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.apartment_outlined,
                color: AppTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '가정이사',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        richBulletPoint('3룸, 20평대 이상', ' 고객님께 추천드려요.'),
        const SizedBox(height: 8),
        richBulletPoint('', '가정집 전문 포장이사 업체를 통해 편리하게 이사할 수 있어요.'),
        const SizedBox(height: 8),
        richBulletPoint('', '주요 차량: 2.5~5톤 트럭 이상'),
        const SizedBox(height: 8),
        richBulletPoint('', '이사종류: 전문 포장이사'),
        const SizedBox(height: 8),
        richBulletPoint('', '평균 작업 인원: 3명 이상'),
      ],
    );
  }

  Widget richBulletPoint(String boldText, String normalText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: AppTheme.success,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: boldText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                TextSpan(
                  text: normalText,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: AppTheme.secondaryText,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}