import 'package:MoveSmart/api_service.dart';
import 'package:flutter/cupertino.dart';

class ReviewService {
  static const String _commUrl = "http://moving.stst.co.kr/api/Comm";

  /// 리뷰 목록 가져오기
  static Future<List<dynamic>> fetchReviews() async {
    try {
      final response = await ApiClient.get("$_commUrl/reviews");

      // 응답이 List가 아니면 빈 리스트 반환
      // 최대 10개의 리뷰만 반환
      return response is List
          ? (response.length > 10 ? response.take(10).toList() : response)
          : [];
    } catch (e) {
      debugPrint('리뷰 데이터 로드 실패: $e');
      return []; // 빈 리스트 반환
    }
  }

  /// 특정 리뷰 상세정보 가져오기
  static Future<Map<String, dynamic>?> fetchReviewDetail(String reviewId) async {
    try {
      final response = await ApiClient.get("$_commUrl/reviews/$reviewId");

      // 응답이 Map이 아니면 null 반환
      return response is Map<String, dynamic> ? response : null;
    } catch (e) {
      debugPrint('리뷰 상세 데이터 로드 실패: $e');
      return null; // null 반환
    }
  }
}