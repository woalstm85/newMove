import 'package:MoveSmart/api_service.dart';
import 'package:flutter/cupertino.dart';

class StoryService {
  static const String _baseUrl = "http://moving.stst.co.kr/api/api";

  /// 이달의 스토리 목록 가져오기
  static Future<List<dynamic>> fetchStoryList() async {
    try {
      final response = await ApiClient.get("$_baseUrl/Story");

      // 응답이 List가 아니면 빈 리스트 반환
      return response is List ? response : [];
    } catch (e) {
      debugPrint('스토리 목록 로드 실패: $e');
      return []; // 빈 리스트 반환
    }
  }
}