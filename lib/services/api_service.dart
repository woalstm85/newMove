import 'dart:convert';
import 'package:http/http.dart' as http;

/// 공통 API 클라이언트 - HTTP 요청을 추상화하고 표준화
class ApiClient {
  /// 기본 헤더 설정
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// GET 요청 메서드
  static Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('네트워크 오류 발생: $e');
    }
  }

  /// POST 요청 메서드
  static Future<dynamic> post(
      String url,
      {Object? body,
        Map<String, String>? headers}
      ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is String ? body : json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('네트워크 오류 발생: $e');
    }
  }

  /// 응답 처리 메서드
  static dynamic _handleResponse(http.Response response) {
    // 상태 코드 확인
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        // 빈 응답 본문 처리
        if (response.body.isEmpty) {
          return null;
        }

        // JSON 디코딩
        final dynamic decoded = json.decode(response.body);

        // 응답 구조 처리 (데이터 추출)
        if (decoded is Map && decoded.containsKey('data')) {
          return decoded['data'];
        }

        return decoded;
      } catch (e) {
        throw ApiException('응답 파싱 오류: $e');
      }
    } else {
      // 오류 상태 코드 처리
      throw ApiException(
          '요청 실패: ${response.statusCode}, 메시지: ${response.body}'
      );
    }
  }
}

/// 커스텀 API 예외 클래스
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}