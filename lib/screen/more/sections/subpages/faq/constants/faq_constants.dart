import 'package:flutter/material.dart';

/// FAQ 화면 관련 상수
class FAQConstants {
  // 텍스트
  static const String appBarTitle = '자주 묻는 질문';
  static const String viewAnswerText = '답변 보기';
  static const String noFAQsMessage = '등록된 FAQ가 없습니다.';

  // 문자
  static const String questionChar = 'Q';
  static const String answerChar = 'A';

  // 스타일 관련
  static const double questionIconSize = 32.0;
  static const double answerIconSize = 32.0;
  static const double iconSpacing = 12.0;
  static const double questionFontSize = 15.0;
  static const double answerFontSize = 14.0;
  static const double lineHeight = 1.6;

  // 패딩 및 간격
  static const EdgeInsets itemPadding = EdgeInsets.all(16.0);
  static const EdgeInsets listPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const double listItemSpacing = 8.0;
}