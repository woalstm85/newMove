import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/home/move/02_calendar.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class SpecialMoveTypeModal extends ConsumerStatefulWidget {
  const SpecialMoveTypeModal({super.key});

  @override
  ConsumerState<SpecialMoveTypeModal> createState() => _SpecialMoveTypeModalState();
}

class _SpecialMoveTypeModalState extends ConsumerState<SpecialMoveTypeModal> {
  String? selectedMoveType;

  @override
  void initState() {
    super.initState();
    _loadSelectedMoveType();
  }

  // 이사 타입을 Provider에서 불러오는 함수
  Future<void> _loadSelectedMoveType() async {
    final moveState = ref.read(specialMoveProvider);
    setState(() {
      selectedMoveType = moveState.moveData.selectedMoveType;
    });
  }

  // 선택한 이사 타입을 Provider에 저장하는 함수
  Future<void> _saveSelectedMoveType(String type) async {
    await ref.read(specialMoveProvider.notifier).setMoveType(type);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 24, right: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.76, // 화면 높이의 85%로 제한
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
          const SizedBox(height: 20),

          // 제목
          Text(
            '특수이사 유형을 선택해 주세요',
            style: TextStyle(
              fontSize: context.scaledFontSize(22),
              fontWeight: FontWeight.bold,
              color: AppTheme.greenColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // 부제목
          Text(
            '특별한 니즈에 맞는 맞춤형 서비스를 제공해 드립니다',
            style: TextStyle(
              fontSize: context.scaledFontSize(14),
              color: AppTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // 사무실이사 옵션
                Expanded(
                  child: _buildSimplifiedMoveTypeOption(
                    'office_move',
                    Icons.business_outlined,
                    '사무실 이사',
                  ),
                ),

                const SizedBox(width: 7), // 간격 줄이기

                // 보관이사 옵션
                Expanded(
                  child: _buildSimplifiedMoveTypeOption(
                    'storage_move',
                    Icons.storage_outlined,
                    '보관 이사',
                  ),
                ),

                const SizedBox(width: 7), // 간격 줄이기

                // 단순운송 옵션
                Expanded(
                  child: _buildSimplifiedMoveTypeOption(
                    'simple_transport',
                    Icons.local_shipping_outlined,
                    '단순 운송',
                  ),
                ),
              ],
            ),
          ),

          if (selectedMoveType != null)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.scaffoldBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.greenColor.withOpacity(0.3),
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
                        side: BorderSide(color: AppTheme.borderColor),
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
                            builder: (context) => CalendarScreen(isRegularMove: false)),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppTheme.greenColor,
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

  Widget _buildSimplifiedMoveTypeOption(String type, IconData icon, String title) {
    bool isSelected = selectedMoveType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMoveType = type;
        });
        _saveSelectedMoveType(type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.greenColor : AppTheme.borderColor,
            width: 1.5,
          ),
          color: isSelected ? AppTheme.greenColor.withOpacity(0.05) : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.greenColor : AppTheme.secondaryText,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.greenColor : AppTheme.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTypeInfo() {
    switch (selectedMoveType) {
      case 'office_move':
        return _buildOfficeMoveInfo();
      case 'storage_move':
        return _buildStorageMoveInfo();
      case 'simple_transport':
        return _buildSimpleTransportInfo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOfficeMoveInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.greenColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.business_outlined,
                color: AppTheme.greenColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '사무실 이사',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.greenColor,
                ),
              ),
            ],
          ),
        ),
        richBulletPoint('소규모 사무실, 스타트업, 중소기업', ' 고객님께 추천드려요.'),
        const SizedBox(height: 8),
        richBulletPoint('', '업무 중단을 최소화하는 체계적인 이사 계획을 제공합니다.'),
        const SizedBox(height: 8),
        richBulletPoint('', '주요 차량: 2.5~5톤 트럭 또는 사무실 규모에 맞는 차량'),
        const SizedBox(height: 8),
        richBulletPoint('', '평균 작업 인원: 3~5명'),
        const SizedBox(height: 8),
        richBulletPoint('', '주말 및 야간 이사 가능합니다.'),
      ],
    );
  }

  Widget _buildStorageMoveInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.greenColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.storage_outlined,
                color: AppTheme.greenColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '보관 이사',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.greenColor,
                ),
              ),
            ],
          ),
        ),
        richBulletPoint('계약 공백기, 임시 이주, 해외 체류', ' 고객님께 추천드려요.'),
        const SizedBox(height: 8),
        richBulletPoint('', '안전한 보관창고에서 고객님의 소중한 짐을 보관해 드립니다.'),
        const SizedBox(height: 8),
        richBulletPoint('', '보관 기간: 최소 1개월부터 최대 12개월'),
        const SizedBox(height: 8),
        richBulletPoint('', '공간 규모: 5~30평 다양한 규모의 보관 공간 제공'),
        const SizedBox(height: 8),
        richBulletPoint('', '보험 가입: 화재/도난/침수 등 보상 가능'),
        const SizedBox(height: 8),
        richBulletPoint('', '24시간 보안 시스템과 온습도 관리 시스템 운영'),
      ],
    );
  }

  Widget _buildSimpleTransportInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.greenColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: AppTheme.greenColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '단순 운송',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.greenColor,
                ),
              ),
            ],
          ),
        ),
        richBulletPoint('가구 1~2점, 대형 가전 제품', ' 이동이 필요한 고객님께 추천드려요.'),
        const SizedBox(height: 8),
        richBulletPoint('', '소량의 짐을 빠르고 안전하게 운송해 드립니다.'),
        const SizedBox(height: 8),
        richBulletPoint('', '가능 물품: 침대, 소파, 냉장고, 세탁기, 책상 등'),
        const SizedBox(height: 8),
        richBulletPoint('', '서비스 지역: 수도권 전 지역 (그 외 지역은 추가 비용 발생)'),
        const SizedBox(height: 8),
        richBulletPoint('', '예약 가능 시간: 당일 예약 가능 (오전 9시 ~ 오후 6시)'),
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