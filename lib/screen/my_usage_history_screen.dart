import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import '../utils/ui_extensions.dart';

class MyUsageHistoryScreen extends StatefulWidget {
  final String? userEmail; // null이면 비로그인 상태

  const MyUsageHistoryScreen({super.key, this.userEmail});

  @override
  _MyUsageHistoryScreenState createState() => _MyUsageHistoryScreenState();
}

class _MyUsageHistoryScreenState extends State<MyUsageHistoryScreen> {
  int _selectedButtonIndex = 0;
  final List<String> _categories = ['전체', '진행중', '완료', '만료/취소'];

  // 샘플 이용내역 데이터
  final List<Map<String, dynamic>> _sampleHistoryData = [
    {
      'id': '23051501',
      'type': '이사 서비스',
      'status': '진행중',
      'date': '2024.05.15',
      'fromAddress': '서울시 강남구 테헤란로 123',
      'toAddress': '서울시 송파구 올림픽로 456',
      'price': '350,000원',
      'description': '2인 가구 포장이사',
      'statusColor': Colors.blue,
    },
    {
      'id': '23042201',
      'type': '청소 서비스',
      'status': '완료',
      'date': '2024.04.22',
      'fromAddress': '서울시 서초구 서초대로 789',
      'toAddress': null, // 청소는 도착지 주소 없음
      'price': '180,000원',
      'description': '신축 오피스텔 입주 청소',
      'statusColor': Colors.green,
    },
    {
      'id': '23031501',
      'type': '이사 서비스',
      'status': '취소',
      'date': '2024.03.15',
      'fromAddress': '서울시 마포구 와우산로 111',
      'toAddress': '경기도 고양시 일산동구 중앙로 222',
      'price': '400,000원',
      'description': '3인 가구 포장이사',
      'statusColor': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          '이용내역',
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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 필터 탭 (로그인 상태일 때만 표시)
          if (widget.userEmail != null)
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_categories.length, (index) {
                    return _buildFilterTab(index, _categories[index]);
                  }),
                ),
              ),
            ),

          if (widget.userEmail != null)
            Divider(height: 1),

          // 메인 콘텐츠
          Expanded(
            child: _buildHistoryList()
          ),
        ],
      ),
    );
  }

// 필터 탭 버튼
  Widget _buildFilterTab(int index, String label) {
    bool isSelected = _selectedButtonIndex == index;

    return Container(
      width: 82, // 고정된 너비 지정
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedButtonIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.shade100,
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center, // 텍스트 중앙 정렬
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppTheme.secondaryText,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 로그인 상태 - 이용내역 목록
  Widget _buildHistoryList() {
    // 필터에 따라 데이터 필터링
    List<Map<String, dynamic>> filteredData = _sampleHistoryData;
    if (_selectedButtonIndex != 0) { // '전체'가 아닌 경우
      String filterStatus = _categories[_selectedButtonIndex].toLowerCase();

      // '진행중', '완료', '만료/취소'에 따라 필터링
      filteredData = _sampleHistoryData.where((item) {
        String itemStatus = item['status'].toLowerCase();
        if (filterStatus == '만료/취소') {
          return itemStatus == '취소' || itemStatus == '만료';
        }
        return itemStatus == filterStatus;
      }).toList();
    }

    // 데이터가 없는 경우
    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 60,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16),
            Text(
              '해당 조건의 이용내역이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // 데이터가 있는 경우 목록 표시
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final item = filteredData[index];
        return _buildHistoryItem(item);
      },
    );
  }

  // 이용내역 아이템 카드
  Widget _buildHistoryItem(Map<String, dynamic> item) {
    Color statusColor;
    switch (item['status'].toLowerCase()) {
      case '진행중':
        statusColor = Colors.blue;
        break;
      case '완료':
        statusColor = Colors.green;
        break;
      case '취소':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: context.cardDecoration(borderColor: AppTheme.borderColor),
      child: InkWell(
        onTap: () {
          // 상세보기 화면으로 이동
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(context.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상태 표시 및 날짜
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['status'],
                      style: TextStyle(
                        fontSize: context.scaledFontSize(12),
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppTheme.secondaryText,
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Text(
                        item['date'],
                        style: context.captionStyle(),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: context.defaultPadding / 1.5),

              // 서비스 제목 및 ID
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item['type'],
                      style: context.titleStyle(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '주문번호: ${item['id']}',
                      style: TextStyle(
                        fontSize: context.scaledFontSize(11),
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.smallPadding / 2),


              // 서비스 설명
              Text(
                item['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                ),
              ),

              SizedBox(height: context.defaultPadding / 1.5),

              // 주소 정보
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppTheme.secondaryText,
                  ),
                  SizedBox(width: context.smallPadding / 2),
                  Expanded(
                    child: item['toAddress'] != null
                        ? RichText(
                      text: TextSpan(
                        style: context.labelSSubStyle(),
                        children: [
                          TextSpan(text: '출발: ${item['fromAddress']}'),
                          TextSpan(text: '\n도착: ${item['toAddress']}'),
                        ],
                      ),
                    )
                        : Text(
                      '주소: ${item['fromAddress']}',
                      style: context.labelSSubStyle(),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.smallPadding),

              // 가격 정보
              Row(
                children: [
                  Icon(
                    Icons.payment_outlined,
                    size: 16,
                    color: AppTheme.secondaryText,
                  ),
                  SizedBox(width: context.smallPadding / 2),
                  Text(
                    '결제금액: ',
                    style: context.labelSSubStyle(),
                  ),
                  Text(
                    item['price'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.defaultPadding),

              // 하단 버튼
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // 상세보기
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryText,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('상세보기'),
                    ),
                  ),
                  SizedBox(width: context.defaultPadding),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: item['status'] == '취소' ? null : () {
                        // 채팅하기
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white,),
                          SizedBox(width: 8),
                          Text('채팅하기'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}