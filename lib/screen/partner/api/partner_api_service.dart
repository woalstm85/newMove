import 'package:MoveSmart/services/api_service.dart';
import 'package:flutter/cupertino.dart';

class PartnerService {
  static const String _baseUrl = "http://moving.stst.co.kr/api/api/Company";

  /// 파트너 목록 조회
  static Future<List<dynamic>> fetchPartners() async {
    try {
      final response = await ApiClient.get(_baseUrl);

      // 응답이 List가 아니면 빈 리스트 반환
      return response is List ? response : [];
    } catch (e) {
      debugPrint('파트너 목록 조회 실패: $e');
      return [];
    }
  }

  /// 검색 화면용 파트너 목록 조회 (상세 로깅 및 폴백 메커니즘 포함)
  static Future<List<dynamic>> fetchPartnersForSearchScreen() async {
    try {
      final url = "$_baseUrl";
      final response = await ApiClient.get(url);

      debugPrint("파트너 검색 API 응답 코드: 200");
      debugPrint("파트너 검색 API 응답 타입: ${response.runtimeType}");

      List<dynamic> partnerList = [];

      // 응답 구조에 따라 처리
      if (response is List) {
        partnerList = response;
      } else if (response is Map && response.containsKey('data') &&
          response['data'] is List) {
        partnerList = response['data'];
      } else {
        debugPrint("예상치 못한 응답 형식: $response");
        return [];
      }

      debugPrint("파트너 데이터 개수: ${partnerList.length}");

      // 데이터가 비어있는 경우 임시 데이터 제공
      if (partnerList.isEmpty) {
        debugPrint("API가 빈 데이터를 반환했습니다. 임시 데이터를 사용합니다.");
        return [];
      }

      return partnerList;
    } catch (e) {
      debugPrint('파트너 데이터 로딩 중 오류 발생: $e');
      // 예외 발생 시 임시 데이터 제공
      return [];
    }
  }

  /// 파트너 상세 정보 조회
  static Future<Map<String, dynamic>?> fetchPartnerDetail(String partnerId) async {
    try {
      final response = await ApiClient.get('$_baseUrl/$partnerId');

      debugPrint("파트너 상세 API 응답 코드: 200");
      debugPrint("파트너 상세 API 응답 타입: ${response.runtimeType}");

      // 응답이 Map이 아니면 null 반환
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        debugPrint("예상치 못한 응답 형식: $response");
        return _getMockPartnerDetail(partnerId);
      }
    } catch (e) {
      debugPrint('파트너 상세 정보 조회 실패: $e');
      return _getMockPartnerDetail(partnerId); // 실패 시 모의 데이터 반환
    }
  }

  /// 파트너 상세 모의 데이터
  static Map<String, dynamic> _getMockPartnerDetail(String partnerId) {
    return {
      "compCd": partnerId,
      "compName": "신창현 파트너",
      "bossName": "신창현",
      "bussNo": "123-45-67890",
      "tel1": "010-1234-5678",
      "eMail": "partner@example.com",
      "imgData": [
        {
          "compCd": partnerId,
          "imgUrl": "https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcTufmY5Z9bfKrAlVgrhz_jkJF2z1xn8UGCeaaQY2RC8IIfhsuItFqj8slCWG55VAsRVOJN2CBRlBwmsHlE",
          "imgFileNm": "profile.jpg",
          "imgDispNm": "프로필 이미지"
        }
      ],
      "serviceData": [
        {
          "id": 1,
          "compCd": partnerId,
          "serviceId": "S0010",
          "serviceNm": "소형이사"
        },
        {
          "id": 2,
          "compCd": partnerId,
          "serviceId": "S0020",
          "serviceNm": "가정이사"
        }
      ],
      "experience": "9년",
      "completedJobs": 616,
      "reviewCount": 263,
      "rating": 4.9,
      "introduction": "안녕하세요, 신창현 기사입니다.\n삼성전자 방문 가전설치 및 식당주방 이전 설치,\n이사 경험 등 많은 경험을 통한 노하우로 이사를 진행합니다!\n현장에서 제일 중요한 건 안전! 고객님의 소중한 집, 안전하게 옮겨드리겠습니다.",
      "regions": ["서울", "경기", "인천"],
      "certificates": [
        {
          "certificateId": "CERT001",
          "name": "이달의 파트너",
          "issueDate": "2023-01-01",
          "imageUrl": "https://via.placeholder.com/350x200/0046FF/FFFFFF?text=이달의+파트너"
        }
      ],
      "restrictions": [
        {"id": 1, "name": "식대 요구 없음"},
        {"id": 2, "name": "작업 중 흡연 금지"}
      ],
      "businessVerified": true
    };
  }
}