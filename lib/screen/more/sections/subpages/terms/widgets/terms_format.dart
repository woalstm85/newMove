import 'package:flutter/material.dart';

/// 약관 텍스트 포맷팅을 담당하는 유틸리티 클래스
class TermsFormat {
  // 제목 패턴 (제X장, 제X조 등)에 따른 포맷팅
  static List<TextSpan> formatTraditionalTerms(String text) {
    final List<TextSpan> spans = [];

    // 제목 패턴 (제X장, 제X조 등)
    final titleRegex = RegExp(r"(제\s*\d+\s*[장조])");

    // 섹션 구분자 패턴 (예: "제 1 장 총칙" 같은 전체 라인)
    final sectionRegex = RegExp(r"^.*제\s*\d+\s*장.*$", multiLine: true);

    int lastMatchEnd = 0;

    // 섹션 제목 먼저 찾기
    final sectionMatches = sectionRegex.allMatches(text);
    final Set<String> sectionTitles = {};
    for (final match in sectionMatches) {
      sectionTitles.add(match.group(0)!);
    }

    // 일반 제목 패턴 찾기
    final matches = titleRegex.allMatches(text);

    for (final match in matches) {
      final matchText = text.substring(match.start, match.end);

      // 매치 이전 텍스트 추가
      if (match.start > lastMatchEnd) {
        final beforeText = text.substring(lastMatchEnd, match.start);
        // 섹션 제목인지 확인
        if (sectionTitles.any((title) => beforeText.contains(title))) {
          for (final sectionTitle in sectionTitles) {
            if (beforeText.contains(sectionTitle)) {
              final int titleStart = beforeText.indexOf(sectionTitle);

              // 섹션 제목 이전 텍스트
              if (titleStart > 0) {
                spans.add(TextSpan(
                  text: beforeText.substring(0, titleStart),
                  style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333)
                  ),
                ));
              }

              // 섹션 제목
              spans.add(TextSpan(
                text: sectionTitle,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  height: 2.0,
                  color: Color(0xFF333333),
                ),
              ));

              // 섹션 제목 이후 텍스트
              if (titleStart + sectionTitle.length < beforeText.length) {
                spans.add(TextSpan(
                  text: beforeText.substring(titleStart + sectionTitle.length),
                  style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF333333)
                  ),
                ));
              }
              break;
            }
          }
        } else {
          spans.add(TextSpan(
            text: beforeText,
            style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF333333)
            ),
          ));
        }
      }

      // 현재 매치 추가 (제X조 등)
      spans.add(TextSpan(
        text: matchText,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          height: 1.5,
          color: Color(0xFF333333),
        ),
      ));

      lastMatchEnd = match.end;
    }

    // 마지막 매치 이후 텍스트 추가
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF333333)
        ),
      ));
    }

    return spans;
  }

  // 개인정보처리방침 형식으로 포맷팅
  static List<TextSpan> formatPrivacyPolicy(String text) {
    final List<TextSpan> spans = [];

    // 메인 타이틀 패턴: 줄 시작에 숫자와 점이 있고 그 뒤에 텍스트가 오는 경우
    final RegExp mainTitleRegex = RegExp(r"^\s*(\d+)\.\s+([^\n]+)", multiLine: true);

    int lastIndex = 0;

    // 메인 타이틀 찾기
    final Iterable<RegExpMatch> matches = mainTitleRegex.allMatches(text);
    for (final match in matches) {
      // 매치 이전 텍스트 추가
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF333333),
          ),
        ));
      }

      // 타이틀 전체를 볼드 처리
      final fullTitle = match.group(0)!;
      spans.add(TextSpan(
        text: fullTitle,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          height: 1.8,
          color: Color(0xFF333333),
        ),
      ));

      lastIndex = match.end;
    }

    // 마지막 매치 이후 텍스트 추가
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Color(0xFF333333),
        ),
      ));
    }

    return spans;
  }

  // 파일 유형에 따라 다른 포맷팅 적용
  static List<TextSpan> formatTerms(String text, int fileIndex) {
    // 개인정보처리방침인 경우 (index = 1)
    if (fileIndex == 1) {
      return formatPrivacyPolicy(text);
    }
    // 다른 형식의 문서인 경우
    else {
      return formatTraditionalTerms(text);
    }
  }
}