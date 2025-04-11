import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class SelectedDateHeader extends StatelessWidget {
  final DateTime selectedDay;
  final String? selectedTime;
  final LinearGradient backgroundGradient;

  const SelectedDateHeader({
    Key? key,
    required this.selectedDay,
    required this.selectedTime,
    required this.backgroundGradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(selectedDay);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_available,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '선택한 이사 예정일',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: context.scaledFontSize(13),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.scaledFontSize(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (selectedTime != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                selectedTime!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}