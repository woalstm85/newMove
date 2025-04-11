import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:intl/intl.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  _NoticeScreenState createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final List<Map<String, dynamic>> notices = [
    {
      "title": "[공통] 이용약관 개정 안내",
      "date": "2024-06-25",
      "content": "안녕하세요. 디딤돌입니다.\n\n회사의 서비스 정책 변경에 따라 이용약관이 개정됨을 안내드립니다.\n\n개정된 이용약관은 7월 1일부터 적용되며, 주요 개정 내용은 다음과 같습니다.\n\n1. 서비스 이용 정책 변경\n2. 취소 및 환불 정책 업데이트\n3. 개인정보 수집 항목 명확화\n\n자세한 내용은 마이페이지 > 약관 및 정책에서 확인하실 수 있습니다.\n\n감사합니다.",
      "important": true,
      "category": "공통"
    },
    {
      "title": "[공통] 리뷰 정책 변경 안내",
      "date": "2024-06-20",
      "content": "안녕하세요. 디딤돌입니다.\n\n더 나은 서비스 제공을 위해 리뷰 정책이 변경되었습니다.\n\n변경된 내용은 다음과 같습니다.\n\n1. 리뷰 작성 기간이 서비스 완료 후 14일로 연장됩니다.\n2. 사진과 함께 리뷰를 작성하시면 추가 포인트를 드립니다.\n3. 리뷰 수정은 작성 후 48시간 이내에만 가능합니다.\n\n더 좋은 서비스로 보답하겠습니다.\n\n감사합니다.",
      "important": false,
      "category": "공통"
    },
    {
      "title": "[공통] 2024-06-19 (수) 시스템 점검 안내",
      "date": "2024-06-17",
      "content": "안녕하세요. 디딤돌입니다.\n\n서비스 안정화를 위한 시스템 점검이 진행될 예정입니다.\n\n■ 점검 일시: 2024년 6월 19일 (수) 02:00 ~ 05:00 (3시간)\n■ 점검 내용: 서버 안정화 및 성능 개선\n\n점검 시간 동안에는 서비스 이용이 일시적으로 중단됩니다.\n사용자 여러분의 양해 부탁드립니다.\n\n감사합니다.",
      "important": true,
      "category": "공통"
    },
    {
      "title": "[청소] 가전청소(세탁기/에어컨) 서비스 종료 안내",
      "date": "2024-06-15",
      "content": "안녕하세요. 디딤돌입니다.\n\n부득이한 사정으로 가전청소(세탁기/에어컨) 서비스가 종료됨을 알려드립니다.\n\n■ 종료 일시: 2024년 6월 30일\n■ 종료 서비스: 세탁기 청소, 에어컨 청소\n\n해당 기간까지 예약된 서비스는 정상적으로 진행됩니다.\n대체 서비스로 '종합 가전 클리닝' 서비스를 7월부터 시작할 예정이니 많은 관심 부탁드립니다.\n\n감사합니다.",
      "important": false,
      "category": "청소"
    },
    {
      "title": "[공통] 개인정보 처리방침 개정 안내",
      "date": "2024-06-10",
      "content": "안녕하세요. 디딤돌입니다.\n\n개인정보 보호법 개정에 따라 개인정보 처리방침이 변경되었습니다.\n\n■ 시행일: 2024년 7월 1일\n■ 주요 변경사항\n1. 개인정보 수집 항목 변경\n2. 개인정보 보유 기간 명확화\n3. 제3자 제공 항목 조정\n\n자세한 내용은 마이페이지 > 약관 및 정책에서 확인하실 수 있습니다.\n\n감사합니다.",
      "important": true,
      "category": "공통"
    },
    {
      "title": "[공통] 2024-01-17 (수) 시스템 점검 안내",
      "date": "2024-01-15",
      "content": "안녕하세요. 디딤돌입니다.\n\n서비스 안정화를 위한 시스템 점검이 진행될 예정입니다.\n\n■ 점검 일시: 2024년 1월 17일 (수) 01:00 ~ 04:00 (3시간)\n■ 점검 내용: 데이터베이스 최적화 및 보안 패치 적용\n\n점검 시간 동안에는 서비스 이용이 일시적으로 중단됩니다.\n사용자 여러분의 양해 부탁드립니다.\n\n감사합니다.",
      "important": false,
      "category": "공통"
    },
    {
      "title": "[공통] 견적 선택 가능한 시간 변경 안내",
      "date": "2024-01-10",
      "content": "안녕하세요. 디딤돌입니다.\n\n서비스 품질 향상을 위해 견적 선택 가능 시간이 변경됩니다.\n\n■ 변경 전: 견적 제공 후 24시간 이내\n■ 변경 후: 견적 제공 후 48시간 이내\n■ 적용일: 2024년 1월 15일 이후 견적부터\n\n더 많은 선택지와 비교 시간을 드리기 위한 변경이니 참고 부탁드립니다.\n\n감사합니다.",
      "important": false,
      "category": "공통"
    },
    {
      "title": "[공통] 앱 내 채팅 서비스 오픈",
      "date": "2023-12-20",
      "content": "안녕하세요. 디딤돌입니다.\n\n고객과 파트너 간의 원활한 소통을 위해 앱 내 채팅 서비스가 오픈되었습니다.\n\n■ 시작일: 2023년 12월 20일\n■ 주요 기능\n1. 실시간 채팅으로 빠른 소통\n2. 사진 및 파일 공유 기능\n3. 서비스 관련 주요 알림 수신\n\n새로운 기능에 많은 관심과 이용 부탁드립니다.\n\n감사합니다.",
      "important": true,
      "category": "공통"
    },
  ];

  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          '공지사항',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    body: SafeArea(  // 이 부분을 추가합니다
      child: Column(
          children: [
            // 필터 섹션
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    '전체 ${notices.length}건',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  // 여기에 필터 드롭다운 또는 버튼 추가 가능
                  // Row(
                  //   children: [
                  //     Text(
                  //       '최신순',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         color: AppTheme.primaryColor,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //     Icon(
                  //       Icons.arrow_drop_down,
                  //       color: AppTheme.primaryColor,
                  //       size: 20,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),

            Divider(height: 1),

            // 공지사항 목록
            Expanded(
              child: ListView.separated(
                itemCount: notices.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final notice = notices[index];
                  final bool isExpanded = expandedIndex == index;

                  // 날짜 파싱
                  final DateTime noticeDate = DateTime.parse(notice["date"]);
                  final bool isRecent = DateTime.now().difference(noticeDate).inDays <= 7;

                  return Column(
                    children: [
                      // 공지사항 아이템
                      InkWell(
                        onTap: () {
                          setState(() {
                            expandedIndex = isExpanded ? null : index;
                          });
                        },
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 카테고리 태그
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(notice["category"]).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      notice["category"],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getCategoryColor(notice["category"]),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),

                                  // 중요 표시
                                  if (notice["important"] == true)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '중요',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                  // 최신 표시
                                  if (isRecent && notice["important"] != true)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.success.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'NEW',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.success,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              SizedBox(height: 8),

                              // 제목
                              Text(
                                notice["title"],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isExpanded ? FontWeight.bold : FontWeight.w500,
                                  color: AppTheme.primaryText,
                                ),
                              ),

                              SizedBox(height: 8),

                              // 날짜 및 확장 아이콘
                              Row(
                                children: [
                                  Text(
                                    _formatDate(notice["date"]),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.secondaryText,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: AppTheme.secondaryText,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 확장된 콘텐츠
                      if (isExpanded)
                        Container(
                          width: double.infinity,
                          color: AppTheme.scaffoldBackground,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notice["content"],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppTheme.primaryText,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 날짜 포맷팅 함수
  String _formatDate(String dateStr) {
    final DateTime date = DateTime.parse(dateStr);
    return DateFormat('yyyy.MM.dd').format(date);
  }

  // 카테고리 색상 반환 함수
  Color _getCategoryColor(String category) {
    switch (category) {
      case '공통':
        return AppTheme.primaryColor;
      case '청소':
        return Colors.green;
      case '이사':
        return Colors.orange;
      default:
        return AppTheme.secondaryText;
    }
  }
}