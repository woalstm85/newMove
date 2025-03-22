import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme_constants.dart';
import '../../home_section/move_calendar.dart';
import '../../providers/move_provider.dart';
import '../../utils/ui_extensions.dart';

class RegularMoveTypeModal extends ConsumerStatefulWidget {
  const RegularMoveTypeModal({super.key});

  @override
  ConsumerState<RegularMoveTypeModal> createState() => _RegularMoveTypeModalState();
}

class _RegularMoveTypeModalState extends ConsumerState<RegularMoveTypeModal> {
  String? selectedMoveType;

  @override
  void initState() {
    super.initState();
    _loadSelectedMoveType();
  }

  // 이사 타입을 Provider에서 불러오는 함수
  Future<void> _loadSelectedMoveType() async {
    final moveState = ref.read(regularMoveProvider);

    setState(() {
      selectedMoveType = moveState.moveData.selectedMoveType;
    });
  }

  // 선택한 이사 타입을 Provider에 저장하는 함수
  Future<void> _saveSelectedMoveType(String type) async {
    await ref.read(regularMoveProvider.notifier).setMoveType(type);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 24, right: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75, // 화면 높이의 85%로 제한
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
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
          Text(
            '일반이사 유형을 선택해 주세요',
            style: TextStyle(
              fontSize: context.scaledFontSize(22),
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
              fontSize: context.scaledFontSize(14),
              color: AppTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // 가로 배치된 이사 유형 옵션
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8), // 상하 여백 조정
            child: Row(
              children: [
                // 소형이사 옵션
                Expanded(
                  child: _buildMoveTypeOptionHorizontal(
                    'small_move',
                    Icons.home_outlined,
                    '소형이사',
                  ),
                ),

                const SizedBox(width: 12), // 버튼 사이 간격

                // 포장이사 옵션
                Expanded(
                  child: _buildMoveTypeOptionHorizontal(
                    'package_move',
                    Icons.inventory_2_outlined,
                    '가정이사',
                  ),
                ),
              ],
            ),
          ),

          // 선택된 이사 유형에 따른 정보 표시
          if (selectedMoveType != null)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: EdgeInsets.all(context.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppTheme.scaffoldBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: _buildSelectedTypeInfo(),
                ),
              ),
            ),

          // 확인 및 취소 버튼을 한 줄로 배치
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.secondaryText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppTheme.borderColor, width: 1.5),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        fontSize: context.scaledFontSize(16),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 확인 버튼
                Expanded(
                  child: ElevatedButton(

                    onPressed: selectedMoveType != null
                        ? () {
                      // 다음 단계로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarScreen(isRegularMove: true),
                        ),
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
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontSize: context.scaledFontSize(16),
                        fontWeight: FontWeight.bold,
                      ),
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

// 가로 배치용 이사 유형 옵션 위젯 - 아이콘과 텍스트를 한 줄로 배치
  Widget _buildMoveTypeOptionHorizontal(String type, IconData icon, String title) {
    bool isSelected = selectedMoveType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMoveType = type;
        });
        _saveSelectedMoveType(type);
      },
      child: Container(
        // width 속성 제거 - Expanded로 감쌌기 때문에 필요 없음
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderSSubColor,
            width: 1,
          ),
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.scaffoldBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : AppTheme.secondaryText,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryColor : AppTheme.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTypeInfo() {
    switch (selectedMoveType) {
      case 'small_move':
        return _buildSmallMoveInfo();
      case 'package_move':
        return _buildPackageMoveInfo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSmallMoveInfo() {
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
        richBulletPoint('원룸, 투룸, 오피스텔(20평 미만)', ' 고객님께 추천드려요.'),
        const SizedBox(height: 8),
        richBulletPoint('', '간소한 이사 절차로 빠르고 경제적인 이사가 가능합니다.'),
        const SizedBox(height: 8),
        richBulletPoint('', '주요 차량: 1~2.5톤 트럭'),
        const SizedBox(height: 8),
        richBulletPoint('', '이사종류: 일반/반포장/포장'),
        const SizedBox(height: 8),
        richBulletPoint('', '평균 작업 인원: 2명 이하'),
      ],
    );
  }

  Widget _buildPackageMoveInfo() {
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
                Icons.inventory_2_outlined,
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
        richBulletPoint('3룸, 20평대 이상 가정집', ' 고객님께 추천드려요.'),
        const SizedBox(height: 8),
        richBulletPoint('', '전문 포장재와 숙련된 인력으로 안전하게 모든 물품을 이동합니다.'),
        const SizedBox(height: 8),
        richBulletPoint('', '주요 차량: 2.5~5톤 트럭 이상'),
        const SizedBox(height: 8),
        richBulletPoint('', '이사종류: 전문 포장이사'),
        const SizedBox(height: 8),
        richBulletPoint('', '평균 작업 인원: 3명 이상'),
        const SizedBox(height: 8),
        richBulletPoint('', '물품파손 보험이 포함됩니다.'),
      ],
    );
  }

  Widget richBulletPoint(String boldText, String normalText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬 유지
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3), // 아이콘을 첫 줄 텍스트에 맞춤
          child: Icon(
            Icons.check_circle_outline,
            color: AppTheme.success,
            size: 16,
          ),
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