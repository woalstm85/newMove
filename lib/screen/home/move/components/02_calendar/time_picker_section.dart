import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class TimePickerSection extends StatelessWidget {
  final String? selectedTime;
  final Function() onTap;
  final Color iconColor;

  const TimePickerSection({
    Key? key,
    required this.selectedTime,
    required this.onTap,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(context.defaultPadding),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: iconColor,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedTime ?? "시간을 선택해주세요",
                      style: TextStyle(
                        color: selectedTime != null
                            ? AppTheme.primaryText
                            : AppTheme.secondaryText,
                        fontSize: context.scaledFontSize(16),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}