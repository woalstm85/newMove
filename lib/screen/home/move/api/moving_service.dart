import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:MoveSmart/services/api_service.dart';

class MovingService {
  static const String _baseUrl = "http://moving.stst.co.kr/api/api";

  /// 특정 월의 이사 상태 데이터 가져오기
  static Future<Map<String, String>> fetchMovStatusForMonth(DateTime month) async {
    try {
      // 월의 시작일과 종료일 계산
      final DateTime startOfMonth = DateTime(month.year, month.month, 1);
      final DateTime endOfMonth = DateTime(month.year, month.month + 1, 0);

      // API 호출 URL 구성
      final url = '$_baseUrl/Est/dates?'
          'startDate=${DateFormat('yyyy-MM-dd').format(startOfMonth)}'
          '&endDate=${DateFormat('yyyy-MM-dd').format(endOfMonth)}';

      // API 요청
      final List<dynamic> data = await ApiClient.get(url);

      // 이사 상태 매핑
      Map<String, String> monthStatus = {};

      for (final item in data) {
        String status;
        int movCnt = item['movCnt'] ?? 0;

        // 이사 건수에 따른 상태 분류
        if (movCnt >= 0 && movCnt <= 3) {
          status = '여유';
        } else if (movCnt >= 4 && movCnt <= 6) {
          status = '보통';
        } else {
          status = '많음';
        }

        // 날짜 포맷팅
        String movDat = DateFormat('yyyy-MM-dd').format(DateTime.parse(item['movDat']));
        monthStatus[movDat] = status;
      }

      return monthStatus;
    } catch (e) {
      debugPrint('이사 상태 데이터 로드 실패: $e');
      return {}; // 빈 맵 반환
    }
  }

  /// 이삿짐 목록 가져오기
  static Future<List<dynamic>> fetchBaggageItems() async {
    try {
      final url = "$_baseUrl/LoadInfo";
      final response = await ApiClient.get(url);

      // 응답이 List가 아니면 빈 리스트 반환
      return response is List ? response : [];
    } catch (e) {
      debugPrint('이삿짐 목록 로드 실패: $e');
      return []; // 빈 리스트 반환
    }
  }
}