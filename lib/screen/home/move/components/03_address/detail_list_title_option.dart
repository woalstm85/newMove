import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class ListTileOption extends StatelessWidget {
  final String title;
  final String selectedOption;
  final IconData icon;
  final VoidCallback onTap;

  const ListTileOption({
    Key? key,
    required this.title,
    required this.selectedOption,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedOption != '선택'
                ? AppTheme.primaryColor.withOpacity(0.5)
                : AppTheme.borderColor,
            width: 1,
          ),
          boxShadow: selectedOption != '선택'
              ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(context.smallPadding),
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
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: context.scaledFontSize(15),
                color: AppTheme.primaryText,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selectedOption != '선택'
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                selectedOption,
                style: TextStyle(
                  fontSize: context.scaledFontSize(15),
                  fontWeight: selectedOption != '선택'
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selectedOption != '선택'
                      ? AppTheme.primaryColor
                      : AppTheme.secondaryText,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}