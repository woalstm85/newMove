import 'package:MoveSmart/api_service.dart';
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
      return _getMockPartnerData(); // 실패 시 모의 데이터 반환
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
        return _getMockPartnerData();
      }

      debugPrint("파트너 데이터 개수: ${partnerList.length}");

      // 데이터가 비어있는 경우 임시 데이터 제공
      if (partnerList.isEmpty) {
        debugPrint("API가 빈 데이터를 반환했습니다. 임시 데이터를 사용합니다.");
        return _getMockPartnerData();
      }

      return partnerList;
    } catch (e) {
      debugPrint('파트너 데이터 로딩 중 오류 발생: $e');
      // 예외 발생 시 임시 데이터 제공
      return _getMockPartnerData();
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

  /// 파트너 목록 모의 데이터
  static List<dynamic> _getMockPartnerData() {
    return [
      {
        'compName': '이세영 파트너',
        'rating': 4.9,
        'completedJobs': 3085,
        'reviewCount': 1501,
        'experience': '9년차',
        'serviceData': [{'serviceNm': '이사 서비스'}],
        'regionNm': '서울',
        'easyPayment': true,
        'imgData': [{'imgUrl': 'https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcTufmY5Z9bfKrAlVgrhz_jkJF2z1xn8UGCeaaQY2RC8IIfhsuItFqj8slCWG55VAsRVOJN2CBRlBwmsHlE'}]
      },
      {
        'compName': '이환석 파트너',
        'rating': 4.9,
        'completedJobs': 3618,
        'reviewCount': 1400,
        'experience': '24년차',
        'serviceData': [{'serviceNm': '포장 이사'}],
        'regionNm': '경기',
        'imgData': [{'imgUrl': 'https://plus.unsplash.com/premium_photo-1675130119373-61ada6685d63?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'}]
      },
      {
        'compName': '박일순 파트너',
        'rating': 4.8,
        'completedJobs': 2707,
        'reviewCount': 1193,
        'experience': '9년차',
        'serviceData': [{'serviceNm': '가정 이사'}],
        'regionNm': '인천',
        'easyPayment': true,
        'imgData': [{'imgUrl': 'https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcTufmY5Z9bfKrAlVgrhz_jkJF2z1xn8UGCeaaQY2RC8IIfhsuItFqj8slCWG55VAsRVOJN2CBRlBwmsHlE'}]
      },
      {
        'compName': '김지훈 파트너',
        'rating': 4.7,
        'completedJobs': 4200,
        'reviewCount': 1600,
        'experience': '15년차',
        'serviceData': [{'serviceNm': '사무실 이사'}],
        'regionNm': '서울',
        'imgData': [{'imgUrl': 'https://plus.unsplash.com/premium_photo-1674777843203-da3ebb9fbca0?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'}]
      },
      {
        'compName': '이현진 파트너',
        'rating': 4.6,
        'completedJobs': 1850,
        'reviewCount': 920,
        'experience': '7년차',
        'serviceData': [{'serviceNm': '이사 서비스'}],
        'regionNm': '부산',
        'easyPayment': true,
        'imgData': [{'imgUrl': 'https://plus.unsplash.com/premium_photo-1664536392896-cd1743f9c02c?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'}]
      },
      {
        'compName': '최민수 파트너',
        'rating': 4.9,
        'completedJobs': 5200,
        'reviewCount': 2100,
        'experience': '12년차',
        'serviceData': [{'serviceNm': '보관 이사'}],
        'regionNm': '대구',
        'imgData': [{'imgUrl': 'https://plus.unsplash.com/premium_photo-1674777843203-da3ebb9fbca0?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'}]
      },
      {
        'compName': '강다영 파트너',
        'rating': 4.5,
        'completedJobs': 1500,
        'reviewCount': 800,
        'experience': '5년차',
        'serviceData': [{'serviceNm': '원룸 이사'}],
        'regionNm': '서울',
        'imgData': [{'imgUrl': 'https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcTufmY5Z9bfKrAlVgrhz_jkJF2z1xn8UGCeaaQY2RC8IIfhsuItFqj8slCWG55VAsRVOJN2CBRlBwmsHl'}]
      },
      {
        'compName': '홍길동 파트너',
        'rating': 4.7,
        'completedJobs': 3400,
        'reviewCount': 1500,
        'experience': '20년차',
        'serviceData': [{'serviceNm': '이사 서비스'}],
        'regionNm': '경기',
        'easyPayment': true,
        'imgData': [{'imgUrl': 'https://plus.unsplash.com/premium_photo-1675130119373-61ada6685d63?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'}]
      },
      {
        'compName': '유재석 파트너',
        'rating': 4.9,
        'completedJobs': 3800,
        'reviewCount': 1800,
        'experience': '18년차',
        'serviceData': [{'serviceNm': '포장 이사'}],
        'regionNm': '인천',
        'imgData': [{'imgUrl': 'https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcTufmY5Z9bfKrAlVgrhz_jkJF2z1xn8UGCeaaQY2RC8IIfhsuItFqj8slCWG55VAsRVOJN2CBRlBwmsHl'}]
      },
      {
        'compName': '신동엽 파트너',
        'rating': 4.8,
        'completedJobs': 2900,
        'reviewCount': 1300,
        'experience': '10년차',
        'serviceData': [{'serviceNm': '가정 이사'}],
        'regionNm': '서울',
        'easyPayment': true,
        'imgData': [{'imgUrl': 'https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcTufmY5Z9bfKrAlVgrhz_jkJF2z1xn8UGCeaaQY2RC8IIfhsuItFqj8slCWG55VAsRVOJN2CBRlBwmsHl'}]
      },
    ];
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