import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/screen/more/models/menu_item_model.dart';

/// 재사용 가능한 메뉴 타일 위젯
class MenuTile extends StatelessWidget {
  final MenuItem item;

  const MenuTile({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: item.iconColor,
                  size: 20,
                ),
              ),
              SizedBox(width: context.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: context.scaledFontSize(16),
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    if (item.showSubtitle && item.subtitle != null)
                      SizedBox(height: context.smallPadding),
                    if (item.showSubtitle && item.subtitle != null)
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: context.scaledFontSize(13),
                          color: AppTheme.secondaryText,
                        ),
                      ),
                  ],
                ),
              ),
              if (item.trailing != null)
                Text(
                  item.trailing!,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (item.trailing == null)
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.secondaryText,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 메뉴 섹션을 표시하는 위젯
class MenuSectionWidget extends StatelessWidget {
  final MenuSection section;

  const MenuSectionWidget({
    Key? key,
    required this.section,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title != null)
            Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                section.title!,
                style: TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ...List.generate(
            section.items.length * 2 - 1,
                (index) {
              // 짝수 인덱스인 경우 메뉴 항목을 표시
              if (index % 2 == 0) {
                return MenuTile(item: section.items[index ~/ 2]);
              }
              // 홀수 인덱스인 경우 구분선을 표시 (마지막 항목 제외)
              else {
                return Divider(height: 1, indent: 20, endIndent: 20);
              }
            },
          ),
        ],
      ),
    );
  }
}