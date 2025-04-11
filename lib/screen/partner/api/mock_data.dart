import 'package:flutter/cupertino.dart';

/// 모의 데이터 클래스
/// API 실패 시 사용할 모의 데이터를 모두 이 파일에 보관
class MockData {
  // 파트너 목록 모의 데이터
  static final List<Map<String, dynamic>> partners = [
    {
      'compCd': 'C0001',
      'compName': '대형 이사 전문 파트너',
      'rating': 4.9,
      'completedJobs': 3085,
      'reviewCount': 1501,
      'experience': '9년차',
      'serviceData': [
        {'serviceNm': '사무실 이사'},
        {'serviceNm': '대형 이사'}
      ],
      'regionNm': '서울',
      'easyPayment': true,
      'imgData': [{'imgUrl': 'https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcTufmY5Z9bfKrAlVgrhz_jkJF2z1xn8UGCeaaQY2RC8IIfhsuItFqj8slCWG55VAsRVOJN2CBRlBwmsHlE'}]
    },
    {
      'compCd': 'C0002',
      'compName': '소형 이사 전문 파트너',
      'rating': 4.9,
      'completedJobs': 3618,
      'reviewCount': 1400,
      'experience': '24년차',
      'serviceData': [
        {'serviceNm': '원룸 이사'},
        {'serviceNm': '소형 이사'}
      ],
      'regionNm': '경기',
      'imgData': [{'imgUrl': 'https://plus.unsplash.com/premium_photo-1675130119373-61ada6685d63?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'}]
    },
    {
      'compCd': 'C0003',
      'compName': '장거리 이사 전문 파트너',
      'rating': 4.8,
      'completedJobs': 2707,
      'reviewCount': 1193,
      'experience': '15년차',
      'serviceData': [
        {'serviceNm': '장거리 이사'},
        {'serviceNm': '도서산간 이사'}
      ],
      'regionNm': '인천',
      'easyPayment': true,
      'imgData': [{'imgUrl': 'https://encrypted-tbn1.gstatic.com/licensed-image?q=tbn:ANd9GcTufmY5Z9bfKrAlVgrhz_jkJF2z1xn8UGCeaaQY2RC8IIfhsuItFqj8slCWG55VAsRVOJN2CBRlBwmsHlE'}]
    },
    {
      'compCd': 'C0004',
      'compName': '특수 화물 이사 전문 파트너',
      'rating': 4.7,
      'completedJobs': 4200,
      'reviewCount': 1600,
      'experience': '20년차',
      'serviceData': [
        {'serviceNm': '특수 화물 이사'},
        {'serviceNm': '예술품 운송'}
      ],
      'regionNm': '서울',
      'imgData': [{'imgUrl': 'https://plus.unsplash.com/premium_photo-1674777843203-da3ebb9fbca0?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'}]
    },
    {
      'compCd': 'C0005',
      'compName': '이현진 파트너',
      'rating': 4.6,
      'completedJobs': 1850,
      'reviewCount': 920,
      'experience': '7년차',
      'serviceData': [{'serviceNm': '이사 서비스'}],
      'regionNm': '부산',
      'easyPayment': true,
      'imgData': [{'imgUrl': 'https://plus.unsplash.com/premium_photo-1664536392896-cd1743f9c02c?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'}]
    }
  ];

  // 리뷰 목록 모의 데이터
  static final List<Map<String, dynamic>> reviews = [
    {
      'id': 'R0001',
      'userName': '김** 고객님',
      'rating': 5.0,
      'date': '2024.01.15',
      'content': '이사 서비스가 정말 훌륭했습니다. 직원들이 매우 친절하고 전문적이었으며, 모든 물건을 안전하게 옮겨주었습니다.',
      'serviceType': '가정 이사',
      'verified': true,
    },
    {
      'id': 'R0002',
      'userName': '박** 고객님',
      'rating': 4.5,
      'date': '2023.12.22',
      'content': '전반적으로 만족스러운 서비스였습니다. 다만 약속 시간보다 30분 정도 늦게 도착한 점이 아쉬웠어요.',
      'serviceType': '사무실 이사',
      'verified': true,
    },
    {
      'id': 'R0003',
      'userName': '이** 고객님',
      'rating': 4.0,
      'date': '2023.11.05',
      'content': '가격 대비 괜찮은 서비스였습니다. 작업 속도가 빨랐고 직원들도 친절했어요.',
      'serviceType': '원룸 이사',
      'verified': true,
    }
  ];

  // 스토리 목록 모의 데이터
  static final List<Map<String, dynamic>> stories = [
    {
      'id': 'S0001',
      'title': '이사 준비부터 정리까지, 한 번에 해결하는 방법',
      'summary': '이사 전 준비부터 이사 후 정리까지 모든 단계를 쉽게 해결하는 팁을 소개합니다.',
      'imageUrl': 'https://example.com/images/story1.jpg',
      'date': '2023.12.15',
      'author': '이사 전문가',
    },
    {
      'id': 'S0002',
      'title': '안전한 이사를 위한 포장 노하우',
      'summary': '깨지기 쉬운 물건부터 큰 가구까지 안전하게 포장하는 방법을 알려드립니다.',
      'imageUrl': 'https://example.com/images/story2.jpg',
      'date': '2023.11.20',
      'author': '포장 전문가',
    }
  ];

  // 이사 날짜 상태 모의 데이터
  static final List<Map<String, dynamic>> moveDates = [
    {
      'movDat': '2024-01-01',
      'movCnt': 2,
    },
    {
      'movDat': '2024-01-02',
      'movCnt': 5,
    },
    {
      'movDat': '2024-01-03',
      'movCnt': 8,
    },
  ];

  // 이삿짐 목록 모의 데이터
  static final List<Map<String, dynamic>> baggageItems = [
    {
      'id': 'B0001',
      'name': '침대',
      'category': '가구',
      'description': '싱글/더블/퀸/킹 사이즈',
    },
    {
      'id': 'B0002',
      'name': '냉장고',
      'category': '가전제품',
      'description': '소형/중형/대형',
    },
    {
      'id': 'B0003',
      'name': '책상',
      'category': '가구',
      'description': '학생용/사무용',
    }
  ];

  // 특정 리뷰 상세정보 가져오기
  static Map<String, dynamic>? getReviewDetail(String reviewId) {
    try {
      return reviews.firstWhere((review) => review['id'] == reviewId);
    } catch (e) {
      debugPrint('리뷰 ID $reviewId에 해당하는 모의 데이터가 없습니다: $e');
      return null;
    }
  }

  // 특정 파트너 상세정보 가져오기
  static Map<String, dynamic> getPartnerDetail(String partnerId) {
    try {
      return partners.firstWhere(
            (partner) => partner['compCd'] == partnerId,
        orElse: () => _createGenericPartnerDetail(partnerId),
      );
    } catch (e) {
      debugPrint('파트너 ID $partnerId에 해당하는 모의 데이터가 없습니다: $e');
      return _createGenericPartnerDetail(partnerId);
    }
  }

  // 기본 파트너 상세정보 생성
  static Map<String, dynamic> _createGenericPartnerDetail(String partnerId) {
    return {
      "compCd": partnerId,
      "compName": "일반 파트너",
      "bossName": "홍길동",
      "bussNo": "123-45-67890",
      "tel1": "010-1234-5678",
      "eMail": "partner@example.com",
      "imgData": [
        {
          "compCd": partnerId,
          "imgUrl": "https://plus.unsplash.com/premium_photo-1675130119373-61ada6685d63?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
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
      "experience": "5년",
      "completedJobs": 150,
      "reviewCount": 75,
      "rating": 4.5,
      "introduction": "안녕하세요, 고객님의 소중한 물품을 안전하게 옮겨드리는 파트너입니다. 친절하고 신속한 서비스로 최선을 다하겠습니다.",
      "regions": ["서울", "경기"],
      "businessVerified": true
    };
  }
}