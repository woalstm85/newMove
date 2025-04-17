import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

class MoveProgressBar extends StatelessWidget {
  final int currentStep;
  final bool isRegularMove;
  final List<String> stepLabels;

  const MoveProgressBar({
    Key? key,
    required this.currentStep,
    required this.isRegularMove,
    this.stepLabels = const ['일정', '주소', '물품', '상세', '서비스', '리뷰'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 이사 유형에 따른 색상 설정
    final Color primaryColor = isRegularMove ? AppTheme.primaryColor : AppTheme.greenColor;
    final Color secondaryColor = Colors.grey[300]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 단계 표시기
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), // 전체 컨테이너에 좌우 여백 추가
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 연결선 (배경)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: List.generate(5, (index) {
                      return Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            color: index < currentStep ? primaryColor : secondaryColor,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // 원형 지시자와 아이콘
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final bool isActive = index <= currentStep;
                    final bool isCurrent = index == currentStep;

                    // 아이콘 결정
                    IconData iconData;
                    if (index == 0) {
                      iconData = Icons.play_arrow_rounded; // 시작
                    } else if (index == 5) {
                      iconData = Icons.flag_rounded; // 끝
                    } else if (isActive && !isCurrent) {
                      iconData = Icons.check; // 완료된 단계
                    } else {
                      iconData = _getStepIcon(index); // 나머지 단계 아이콘
                    }

                    return Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? primaryColor : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive ? primaryColor : secondaryColor,
                          width: 1,
                        ),
                        boxShadow: isCurrent ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          )
                        ] : null,
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          color: isActive ? Colors.white : secondaryColor,
                          size: 14,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // 단계명 표시
          SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12), // 텍스트에도 동일한 여백 적용
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: Column(
                    children: [
                      Text(
                        stepLabels[index],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: index == currentStep ? FontWeight.bold : FontWeight.normal,
                          color: index == currentStep ? primaryColor :
                          index < currentStep ? Colors.black54 : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // 각 단계별 아이콘 반환
  IconData _getStepIcon(int step) {
    switch (step) {
      case 0:
        return Icons.calendar_month_rounded; // 일정
      case 1:
        return Icons.location_on_rounded; // 주소
      case 2:
        return Icons.inventory_2_rounded; // 물품
      case 3:
        return Icons.list_alt_rounded; // 상세
      case 4:
        return Icons.home_repair_service; // 서비스
      case 5:
        return Icons.flag_rounded; // 최종리뷰
      default:
        return Icons.circle;
    }
  }
}