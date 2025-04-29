import 'package:flutter/material.dart';

/// 메뉴 아이템을 표현하는 데이터 모델
class MenuItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback onTap;
  final bool showSubtitle;

  const MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.showSubtitle = true,
  });
}

/// 메뉴 섹션을 표현하는 데이터 모델
class MenuSection {
  final String? title;
  final List<MenuItem> items;

  const MenuSection({
    this.title,
    required this.items,
  });
}