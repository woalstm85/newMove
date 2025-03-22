import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static const String _commUrl = "http://moving.stst.co.kr/api/Comm";
  static const String _baseUrl = "http://moving.stst.co.kr/api/api";

  // ✅ 리뷰 목록 가져오기 (타입 캐스팅 추가)
  static Future<List<dynamic>> fetchReviews() async {
    final response = await _getRequest("$_commUrl/reviews");
    return response is List ? response.take(10).toList() : []; // ✅ List 타입 보장
  }

  // ✅ 특정 리뷰 상세정보 가져오기
  static Future<Map<String, dynamic>?> fetchReviewDetail(
      String reviewId) async {
    final response = await _getRequest("$_commUrl/reviews/$reviewId");
    return response is Map<String, dynamic> ? response : null; // ✅ Map 타입 보장
  }

  // ✅ 이달의 파트너 목록 가져오기 (향상된 오류 처리 및 타입 캐스팅)
  static Future<List<dynamic>> fetchPartnerList() async {
    final url = "$_baseUrl/Company";
    final response = await http.get(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }
    );
    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);

      // 응답 구조에 따라 처리 방식 조정
      if (decoded is List) {
        return decoded;
      } else if (decoded is Map && decoded.containsKey('data') &&
          decoded['data'] is List) {
        return decoded['data'];
      } else {
        print("예상치 못한 응답 형식: $decoded");
        return [];
      }
    } else {
      print("API 요청 실패. 상태 코드: ${response.statusCode}, 응답: ${response.body}");
      return [];
    }
  }

  // ✅ 파트너 검색 화면용 파트너 목록 가져오기 (새로 추가된 함수)
  static Future<List<dynamic>> fetchPartnersForSearchScreen() async {
    try {
      // 실제 API 호출은 동일하게 유지하되 처리 방식을 더 강화
      final url = "$_baseUrl/Company";
      final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }
      );

      print("파트너 검색 API 응답 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        print("파트너 검색 API 응답 타입: ${decoded.runtimeType}");

        List<dynamic> partnerList = [];

        // 응답 구조에 따라 처리
        if (decoded is List) {
          partnerList = decoded;
        } else if (decoded is Map && decoded.containsKey('data') &&
            decoded['data'] is List) {
          partnerList = decoded['data'];
        } else {
          print("예상치 못한 응답 형식: $decoded");
          // API가 실패하는 경우 임시 데이터 제공 (개발용)
          return _getMockPartnerData();
        }

        print("파트너 데이터 개수: ${partnerList.length}");

        // 데이터가 비어있는 경우 임시 데이터 제공 (개발용)
        if (partnerList.isEmpty) {
          print("API가 빈 데이터를 반환했습니다. 임시 데이터를 사용합니다.");
          return _getMockPartnerData();
        }

        return partnerList;
      } else {
        print("API 요청 실패. 상태 코드: ${response.statusCode}, 응답: ${response.body}");
        // API가 실패하는 경우 임시 데이터 제공 (개발용)
        return _getMockPartnerData();
      }
    } catch (e) {
      print("파트너 데이터 로딩 중 오류 발생: $e");
      // 예외 발생 시 임시 데이터 제공 (개발용)
      return _getMockPartnerData();
    }
  }


  static Future<List<Map<String, dynamic>>> searchAddress(String keyword, int page) async {
    // 행정안전부 주소 검색 API URL
    const String apiUrl = 'https://www.juso.go.kr/addrlink/addrLinkApi.do';

    // .env 파일에서 API 키 로드
    final String apiKey = dotenv.env['ADDRESS_API_KEY'] ?? '';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: {
        'confmKey': apiKey,
        'currentPage': page.toString(),
        'countPerPage': '10',
        'keyword': keyword,
        'resultType': 'json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));

      if (data['results']['common']['errorCode'] == '0') {
        final List<dynamic> juso = data['results']['juso'];

        return juso.map((address) => {
          'roadAddress': address['roadAddr'],
          'jibunAddress': address['jibunAddr'],
          'buildingName': address['bdNm'],
          'zonecode': address['zipNo'],
        }).toList();
      } else {
        throw Exception(data['results']['common']['errorMessage']);
      }
    } else {
      throw Exception('주소 검색 API 요청 실패: ${response.statusCode}');
    }
  }

// 특정 월에 대한 이사 상태 데이터 가져오기
  static Future<Map<String, String>> fetchMovStatusForMonth(DateTime month) async {
    try {
      // 월의 시작일과 종료일 계산
      final DateTime startOfMonth = DateTime(month.year, month.month, 1);
      final DateTime endOfMonth = DateTime(month.year, month.month + 1, 0);

      // API 호출 URL 구성
      final url = '$_baseUrl/Est/dates?startDate=${DateFormat('yyyy-MM-dd').format(startOfMonth)}&endDate=${DateFormat('yyyy-MM-dd').format(endOfMonth)}';

      // API 응답 처리 및 상태 매핑 로직
      Map<String, String> monthStatus = {};

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);

          for (final item in data) {
            String status;
            int movCnt = item['movCnt'];

            if (movCnt >= 0 && movCnt <= 3) {
              status = '여유';
            } else if (movCnt >= 4 && movCnt <= 6) {
              status = '보통';
            } else {
              status = '많음';
            }

            String movDat = DateFormat('yyyy-MM-dd').format(DateTime.parse(item['movDat']));
            monthStatus[movDat] = status;
          }
        } else {
          print("이사 상태 API 요청 실패. 상태 코드: ${response.statusCode}, 응답: ${response.body}");

        }
      } catch (e) {
        print("월별 상태 데이터 로드 오류: $e");

      }

      return monthStatus;
    } catch (e) {
      print("이사 상태 데이터 로드 오류: $e");
      return {};
    }
  }


  // ✅ 파트너 상세 정보 가져오기
  static Future<Map<String, dynamic>?> fetchPartnerDetail(String partnerId) async {
    try {
      final url = "$_baseUrl/Company/$partnerId";
      final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }
      );

      print("파트너 상세 API 응답 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        print("파트너 상세 API 응답 타입: ${decoded.runtimeType}");

        // 응답이 Map 형태인지 확인
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          print("예상치 못한 응답 형식: $decoded");
          // API 응답이 예상과 다른 경우 모의 데이터 제공
          return _getMockPartnerDetail(partnerId);
        }
      } else {
        print("API 요청 실패. 상태 코드: ${response.statusCode}, 응답: ${response.body}");
        // API 실패 시 모의 데이터 제공
        return _getMockPartnerDetail(partnerId);
      }
    } catch (e) {
      print("파트너 상세 데이터 로딩 중 오류 발생: $e");
      // 예외 발생 시 모의 데이터 제공
      return _getMockPartnerDetail(partnerId);
    }
  }

  // 임시 파트너 데이터 (API 실패 시 사용)
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

  // 파트너 상세 모의 데이터
  static Map<String, dynamic> _getMockPartnerDetail(String partnerId) {
    // partnerId에 따라 다른 모의 데이터를 반환하도록 할 수 있음
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

  // ✅ 이달의 스토리 목록 가져오기 (타입 캐스팅 추가)
  static Future<List<dynamic>> fetchStoryList() async {
    final response = await _getRequest("$_baseUrl/Story");
    return response is List ? response : []; // ✅ List 타입 보장
  }

  static Future<List<dynamic>> fetchBaggageItems() async {
    try {
      const url = "$_baseUrl/LoadInfo";
      final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }
      );

      print("이삿짐 목록 API 응답 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        print("이삿짐 목록 API 응답 타입: ${decoded.runtimeType}");

        if (decoded is List) {
          return decoded;
        } else if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
          return decoded['data'];
        } else {
          print("예상치 못한 응답 형식: $decoded");
          return [];
        }
      } else {
        print("API 요청 실패. 상태 코드: ${response.statusCode}, 응답: ${response.body}");
        return [];
      }
    } catch (e) {
      print("이삿짐 목록 데이터 로딩 중 오류 발생: $e");
      return [];
    }
  }

  // ✅ 공통 GET 요청 함수 (유형 불명 데이터 처리 및 오류 로깅 강화)
  static Future<dynamic> _getRequest(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("API 요청 실패. 상태 코드: ${response.statusCode}, 응답: ${response.body}");
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print("Error fetching data from $url: $error");
      return null;
    }
  }
}