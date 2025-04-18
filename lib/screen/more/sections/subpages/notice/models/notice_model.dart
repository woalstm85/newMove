class NoticeModel {
  final String title;
  final String date;
  final String content;
  final bool important;
  final String category;

  NoticeModel({
    required this.title,
    required this.date,
    required this.content,
    required this.important,
    required this.category,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      title: json['title'],
      date: json['date'],
      content: json['content'],
      important: json['important'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'content': content,
      'important': important,
      'category': category,
    };
  }
}

// 샘플 데이터 제공 함수
List<NoticeModel> getSampleNotices() {
  return [
    NoticeModel(
      title: "[공통] 이용약관 개정 안내",
      date: "2024-06-25",
      content: "안녕하세요. 디딤돌입니다.\n\n회사의 서비스 정책 변경에 따라 이용약관이 개정됨을 안내드립니다.\n\n개정된 이용약관은 7월 1일부터 적용되며, 주요 개정 내용은 다음과 같습니다.\n\n1. 서비스 이용 정책 변경\n2. 취소 및 환불 정책 업데이트\n3. 개인정보 수집 항목 명확화\n\n자세한 내용은 마이페이지 > 약관 및 정책에서 확인하실 수 있습니다.\n\n감사합니다.",
      important: true,
      category: "공통",
    ),
    NoticeModel(
      title: "[공통] 리뷰 정책 변경 안내",
      date: "2024-06-20",
      content: "안녕하세요. 디딤돌입니다.\n\n더 나은 서비스 제공을 위해 리뷰 정책이 변경되었습니다.\n\n변경된 내용은 다음과 같습니다.\n\n1. 리뷰 작성 기간이 서비스 완료 후 14일로 연장됩니다.\n2. 사진과 함께 리뷰를 작성하시면 추가 포인트를 드립니다.\n3. 리뷰 수정은 작성 후 48시간 이내에만 가능합니다.\n\n더 좋은 서비스로 보답하겠습니다.\n\n감사합니다.",
      important: false,
      category: "공통",
    ),
    NoticeModel(
      title: "[공통] 2024-06-19 (수) 시스템 점검 안내",
      date: "2024-06-17",
      content: "안녕하세요. 디딤돌입니다.\n\n서비스 안정화를 위한 시스템 점검이 진행될 예정입니다.\n\n■ 점검 일시: 2024년 6월 19일 (수) 02:00 ~ 05:00 (3시간)\n■ 점검 내용: 서버 안정화 및 성능 개선\n\n점검 시간 동안에는 서비스 이용이 일시적으로 중단됩니다.\n사용자 여러분의 양해 부탁드립니다.\n\n감사합니다.",
      important: true,
      category: "공통",
    ),
    NoticeModel(
      title: "[청소] 가전청소(세탁기/에어컨) 서비스 종료 안내",
      date: "2024-06-15",
      content: "안녕하세요. 디딤돌입니다.\n\n부득이한 사정으로 가전청소(세탁기/에어컨) 서비스가 종료됨을 알려드립니다.\n\n■ 종료 일시: 2024년 6월 30일\n■ 종료 서비스: 세탁기 청소, 에어컨 청소\n\n해당 기간까지 예약된 서비스는 정상적으로 진행됩니다.\n대체 서비스로 '종합 가전 클리닝' 서비스를 7월부터 시작할 예정이니 많은 관심 부탁드립니다.\n\n감사합니다.",
      important: false,
      category: "청소",
    ),
    NoticeModel(
      title: "[공통] 개인정보 처리방침 개정 안내",
      date: "2024-06-10",
      content: "안녕하세요. 디딤돌입니다.\n\n개인정보 보호법 개정에 따라 개인정보 처리방침이 변경되었습니다.\n\n■ 시행일: 2024년 7월 1일\n■ 주요 변경사항\n1. 개인정보 수집 항목 변경\n2. 개인정보 보유 기간 명확화\n3. 제3자 제공 항목 조정\n\n자세한 내용은 마이페이지 > 약관 및 정책에서 확인하실 수 있습니다.\n\n감사합니다.",
      important: true,
      category: "공통",
    ),
  ];
}