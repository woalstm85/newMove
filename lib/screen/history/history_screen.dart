import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/screen/history/history_detail_screen.dart';
import 'package:intl/intl.dart';

class MyUsageHistoryScreen extends ConsumerStatefulWidget {
  final String? userEmail; // null이면 비로그인 상태

  const MyUsageHistoryScreen({super.key, this.userEmail});

  @override
  ConsumerState<MyUsageHistoryScreen> createState() => _MyUsageHistoryScreenState();
}

class _MyUsageHistoryScreenState extends ConsumerState<MyUsageHistoryScreen> {
  int _selectedButtonIndex = 0;
  final List<String> _categories = ['전체', '진행중', '완료', '만료/취소'];

  @override
  Widget build(BuildContext context) {
    // 견적 요청 데이터 가져오기
    final estimateRequestsState = ref.watch(estimateRequestsProvider);

    // 일반 이사 데이터와 특수 이사 데이터 가져오기
    final regularMoveState = ref.watch(regularMoveProvider);
    final specialMoveState = ref.watch(specialMoveProvider);

    // 로딩 중인 경우
    if (estimateRequestsState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '이용내역',
            style: TextStyle(
              color: AppTheme.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

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
      body: SafeArea(child:
        Column(
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
              child: _buildHistoryList(
                estimateRequestsState.requests,
                regularMoveState,
                specialMoveState,
              ),
            ),
          ],
        ),
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

  // 이용내역 목록
  Widget _buildHistoryList(
      List<EstimateRequest> requests,
      MoveState regularMoveState,
      MoveState specialMoveState
      ) {
    // 필터에 따라 데이터 필터링
    var filteredRequests = requests;
    if (_selectedButtonIndex != 0) { // '전체'가 아닌 경우
      String filterStatus = _categories[_selectedButtonIndex].toLowerCase();

      // '진행중', '완료', '만료/취소'에 따라 필터링
      filteredRequests = requests.where((request) {
        String itemStatus = request.status.toLowerCase();
        if (filterStatus == '진행중') {
          return itemStatus == '진행중';
        } else if (filterStatus == '완료') {
          return itemStatus == '완료';
        } else if (filterStatus == '만료/취소') {
          return itemStatus == '취소' || itemStatus == '만료';
        }
        return false;
      }).toList();
    }

    // 데이터가 없는 경우
    if (filteredRequests.isEmpty) {
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
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        final request = filteredRequests[index];

        // 이사 데이터 가져오기
        final moveData = request.isRegularMove
            ? regularMoveState.moveData
            : specialMoveState.moveData;

        return _buildHistoryItem(request, moveData);
      },
    );
  }

  // 이용내역 아이템 카드 - 수정된 버전
// 이용내역 아이템 카드 - 수정된 버전
  Widget _buildHistoryItem(EstimateRequest request, MoveData moveData) {
    // 이사 유형 이름 가져오기
    String serviceTypeName = '';
    if (moveData.selectedMoveType != null) {
      if (moveData.selectedMoveType == 'office_move') {
        serviceTypeName = '사무실 이사';
      } else if (moveData.selectedMoveType == 'storage_move') {
        serviceTypeName = '보관 이사';
      } else if (moveData.selectedMoveType == 'simple_transport') {
        serviceTypeName = '단순 운송';
      } else if (moveData.selectedMoveType == 'small_move') {
        if (moveData.selectedServiceType == 'normal') serviceTypeName = '소형 이사(일반)';
        else if (moveData.selectedServiceType == 'semiPackage') serviceTypeName = '소형 이사(반포장)';
        else if (moveData.selectedServiceType == 'package') serviceTypeName = '소형 이사(포장)';
        else serviceTypeName = '소형 이사';
      } else if (moveData.selectedMoveType == 'package_move') {
        if (moveData.selectedServiceType == 'normal') serviceTypeName = '가정 이사(일반)';
        else if (moveData.selectedServiceType == 'semiPackage') serviceTypeName = '가정 이사(반포장)';
        else if (moveData.selectedServiceType == 'package') serviceTypeName = '가정 이사(포장)';
        else serviceTypeName = '가정 이사';
      } else {
        serviceTypeName = '이사 서비스';
      }
    } else {
      serviceTypeName = '이사 서비스';
    }

    // 이사일 형식화
    String moveDateStr = '';
    if (moveData.selectedDate != null) {
      moveDateStr = DateFormat('yyyy.MM.dd').format(moveData.selectedDate!);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: context.cardDecoration(borderColor: AppTheme.borderColor),
      child: Padding(
        padding: EdgeInsets.all(context.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상태 표시 및 상세보기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 상태 배지
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: request.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      fontSize: context.scaledFontSize(12),
                      fontWeight: FontWeight.bold,
                      color: request.statusColor,
                    ),
                  ),
                ),
                // 상세보기 버튼
                TextButton.icon(
                  onPressed: () {
                    // 상세보기 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EstimateDetailScreen(
                          requestId: request.id,
                          isRegularMove: request.isRegularMove,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  label: Text(
                    '상세보기',
                    style: TextStyle(
                      fontSize: context.scaledFontSize(12),
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: context.defaultPadding / 2),

            // 서비스 제목 및 견적번호
            Row(
              children: [
                Expanded(
                  child: Text(
                    serviceTypeName,
                    style: context.titleStyle(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),

            SizedBox(height: context.smallPadding / 2),

            // 이사일 정보
            if (moveDateStr.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 16,
                    color: AppTheme.secondaryText,
                  ),
                  SizedBox(width: context.smallPadding / 2),
                  Text(
                    '이사일: $moveDateStr ${moveData.selectedTime ?? ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.defaultPadding / 1.5),
            ],

            // 주소 정보 - 출발지와 도착지 모두 아이콘 표시
            if (moveData.startAddressDetails != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 출발지 주소
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.home_outlined, // 출발지 아이콘
                        size: 16,
                        color: AppTheme.primaryColor, // 출발지는 primaryColor 사용
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Expanded(
                        child: Text(
                          '출발: ${moveData.startAddressDetails!['address']}',
                          style: context.labelSSubStyle(),
                        ),
                      ),
                    ],
                  ),

                  // 도착지가 있는 경우
                  if (moveData.destinationAddressDetails != null) ...[
                    SizedBox(height: 8), // 출발지와 도착지 사이 간격
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined, // 도착지 아이콘
                          size: 16,
                          color: AppTheme.greenColor, // 도착지는 greenColor 사용
                        ),
                        SizedBox(width: context.smallPadding / 2),
                        Expanded(
                          child: Text(
                            '도착: ${moveData.destinationAddressDetails!['address']}',
                            style: context.labelSSubStyle(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              SizedBox(height: context.smallPadding),
            ],

            // 가격 정보 (견적 완료된 경우만)
            if (request.price != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.payment_outlined,
                    size: 16,
                    color: AppTheme.secondaryText,
                  ),
                  SizedBox(width: context.smallPadding / 2),
                  Text(
                    '견적금액: ',
                    style: context.labelSSubStyle(),
                  ),
                  Text(
                    request.price!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.defaultPadding),
            ] else
              SizedBox(height: context.defaultPadding / 2),

            // 하단 버튼 - 견적서 보기 버튼 하나만 유지
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: request.status == '취소' ? null : () {
                  // 견적서 보기 동작
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.greenColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text('견적서 보기'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}