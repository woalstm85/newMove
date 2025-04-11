import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class ToggleOptionSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final IconData icon;

  const ToggleOptionSwitch({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 18,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: context.scaledFontSize(15),
            color: AppTheme.primaryText,
          ),
        ),
        Spacer(),
        Row(
          children: [
            Text(
              value ? '있음' : '없음',
              style: TextStyle(
                fontSize: context.scaledFontSize(14),
                color: AppTheme.secondaryText,
              ),
            ),
            SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
              activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ],
        ),
      ],
    );
  }
}