import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

/// 공지사항 화면 관련 상수
class NoticeConstants {
  // 텍스트
  static const String appBarTitle = '공지사항';
  static const String totalCountFormat = '전체 %d건';
  static const String lastUpdatedLabel = '최근 업데이트:';
  static const String newLabel = 'NEW';
  static const String importantLabel = '중요';

  // 카테고리 관련
  static const Map<String, Color> categoryColors = {
    '공통': AppTheme.primaryColor,
    '청소': Colors.green,
    '이사': Colors.orange,
  };

  // 기본 카테고리 색상 (지정되지 않은 카테고리용)
  static const Color defaultCategoryColor = Color(0xFF666666);

  // 최신 공지 기준 일수 (7일 이내)
  static const int recentNoticeDays = 7;
}