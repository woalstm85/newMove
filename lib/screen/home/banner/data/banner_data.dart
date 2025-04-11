import 'package:flutter/material.dart';

const List<Map<String, dynamic>> bannersData = [
  {
    // 친구 초대 이벤트
    'imagePath': 'assets/banners/banner1.png',
    'title': '친구 초대하고,\n커피 한잔의 여유를!',
    'subtitle': '스타벅스 아메리카노 증정!',
    'buttonText': '친구 초대하기',
    'titleColor': 'white',
    'subtitleColor': 'white_90',
    'buttonColor': 'white',
    'buttonTextColor': '00704A',
    'bgColor': '00704A', // 스타벅스 녹색
    'description': '친구에게 이사를 추천하고\n스타벅스 아메리카노를\n받아보세요',
    'benefitItems': [
      {
        'icon': 'card_giftcard',
        'title': '이벤트 혜택',
        'subtitle': '친구가 디딤돌로 이사 완료 시 나와 친구 모두에게 스타벅스 아메리카노 기프티콘 증정',
        'hasArrow': true,
      },
      {
        'icon': 'share',
        'title': '참여 방법',
        'subtitle': '앱 내 [친구 초대하기] 버튼 클릭 → 카카오톡, 문자 등으로 초대 메시지 발송',
        'hasArrow': true,
      },
      {
        'icon': 'calendar_today',
        'title': '이벤트 기간',
        'subtitle': '2025년 3월 1일 ~ 5월 31일',
        'hasArrow': false,
      },
      {
        'icon': 'info_outline',
        'title': '유의사항',
        'subtitle': '한 계정당 최대 10명까지 초대 가능합니다',
        'hasArrow': true,
      },
    ],
  },
  {
    // 리뷰 작성 이벤트
    'imagePath': 'assets/banners/banner2.png',
    'title': '이사 후기 쓰면\n선물이 팡팡!',
    'subtitle': '편의점 상품권\n배달의민족 상품권 증정!',
    'buttonText': '리뷰 작성하기',
    'titleColor': 'white',
    'subtitleColor': 'white_80',
    'buttonColor': 'white',
    'buttonTextColor': 'FF9500', // 오렌지색
    'bgColor': 'FF9500', // 오렌지색 배경
    'description': '소중한 경험을 나누고\n상품권도 받아가세요',
    'benefitItems': [
      {
        'icon': 'card_giftcard',
        'title': '즉시 지급 혜택',
        'subtitle': '리뷰 작성 즉시 편의점 상품권 3천원 지급',
        'hasArrow': true,
      },
      {
        'icon': 'star',
        'title': '베스트 리뷰 선정',
        'subtitle': '매주 베스트 리뷰 선정 시 배달의민족 1만원권 추가 증정',
        'hasArrow': true,
      },
      {
        'icon': 'rate_review',
        'title': '참여 방법',
        'subtitle': '이사 서비스 완료 후 앱에서 별점과 함께 솔직한 이용 후기 작성',
        'hasArrow': true,
      },
      {
        'icon': 'calendar_today',
        'title': '이벤트 기간',
        'subtitle': '2025년 3월 1일 ~ 4월 30일',
        'hasArrow': false,
      },
      {
        'icon': 'info_outline',
        'title': '유의사항',
        'subtitle': '한 번의 이사 서비스당 1회 리뷰 작성 가능합니다',
        'hasArrow': true,
      },
    ],
  },
  {
    // SNS 인증샷 이벤트
    'imagePath': 'assets/banners/banner3.png',
    'title': '이사 인증샷 올리고\n치킨 먹자!',
    'subtitle': '이사 후 인증샷을 SNS에 공유\n영화관람권 등 증정!',
    'buttonText': '리뷰 작성하고 선물 받기',
    'titleColor': 'white',
    'subtitleColor': 'white_80',
    'buttonColor': 'white',
    'buttonTextColor': '9747FF',
    'bgColor': '9747FF', // 보라색 배경
    'description': '새로운 공간을 자랑하고\n맛있는 선물도 받아가세요',
    'benefitItems': [
      {
        'icon': 'fastfood',
        'title': '주간 경품',
        'subtitle': '매주 추첨을 통해 10명에게 치킨 기프티콘 증정',
        'hasArrow': true,
      },
      {
        'icon': 'movie',
        'title': '월간 경품',
        'subtitle': '월간 베스트 인증샷 3명 선정하여 CGV 영화관람권 2매 증정',
        'hasArrow': true,
      },
      {
        'icon': 'camera_alt',
        'title': '참여 방법',
        'subtitle': '새 공간 인증샷 촬영 → SNS 게시물 업로드 → 앱에 URL 등록',
        'hasArrow': true,
      },
      {
        'icon': 'tag',
        'title': '필수 해시태그',
        'subtitle': '#디딤돌이사 #디딤돌최고 #이사는디딤돌에서',
        'hasArrow': false,
      },
      {
        'icon': 'calendar_today',
        'title': '이벤트 기간',
        'subtitle': '2025년 3월 1일 ~ 5월 31일',
        'hasArrow': false,
      },
    ],
  },
];

// 아이콘 변환 헬퍼 함수
IconData getIconData(String iconName) {
  switch (iconName) {
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'share':
      return Icons.share;
    case 'calendar_today':
      return Icons.calendar_today;
    case 'info_outline':
      return Icons.info_outline;
    case 'star':
      return Icons.star;
    case 'rate_review':
      return Icons.rate_review;
    case 'fastfood':
      return Icons.fastfood;
    case 'movie':
      return Icons.movie;
    case 'camera_alt':
      return Icons.camera_alt;
    case 'tag':
      return Icons.tag;
    default:
      return Icons.info;
  }
}

// 색상 변환 헬퍼 함수
Color getColor(String colorStr) {
  if (colorStr == 'white') return Colors.white;
  if (colorStr == 'white_90') return Colors.white.withOpacity(0.9);
  if (colorStr == 'white_80') return Colors.white.withOpacity(0.8);
  // 16진수 색상 처리
  if (colorStr.length == 6) {
    try {
      return Color(int.parse('0xFF$colorStr'));
    } catch (e) {
      debugPrint('색상 변환 오류: $e');
      return Colors.grey;
    }
  }
  return Colors.grey;
}