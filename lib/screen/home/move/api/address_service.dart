import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:MoveSmart/api_service.dart';

class AddressService {
  /// 행정안전부 주소 검색 API URL
  static const String _apiUrl = 'https://www.juso.go.kr/addrlink/addrLinkApi.do';

  /// 주소 검색 메서드
  static Future<List<Map<String, dynamic>>> searchAddress(
      String keyword,
      int page
      ) async {
    try {
      // .env 파일에서 API 키 로드
      final String apiKey = dotenv.env['ADDRESS_API_KEY'] ?? '';

      // API 요청 본문 구성
      final body = {
        'confmKey': apiKey,
        'currentPage': page.toString(),
        'countPerPage': '10',
        'keyword': keyword,
        'resultType': 'json',
      };

      // POST 요청 수행
      final response = await ApiClient.post(
        _apiUrl,
        body: body,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
      );

      // 응답 처리
      if (response != null &&
          response['results'] != null &&
          response['results']['common']['errorCode'] == '0') {

        final List<dynamic> juso = response['results']['juso'];

        return juso.map((address) => {
          'roadAddress': address['roadAddr'],
          'jibunAddress': address['jibunAddr'],
          'buildingName': address['bdNm'],
          'zonecode': address['zipNo'],
        }).toList();
      } else {
        // 오류 처리
        throw ApiException(
            response?['results']?['common']?['errorMessage'] ?? '알 수 없는 오류 발생'
        );
      }
    } catch (e) {
      // 예외 처리
      debugPrint('주소 검색 중 오류 발생: $e');
      return []; // 빈 리스트 반환
    }
  }
}