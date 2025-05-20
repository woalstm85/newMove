import 'dart:io';
import 'dart:math';
import 'package:MoveSmart/screen/home/move/move_progress_bar.dart';
import 'package:MoveSmart/screen/history/history_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/utils/ui_mixins.dart';

class FinalReviewScreen extends ConsumerStatefulWidget {
  final bool isRegularMove;

  const FinalReviewScreen({
    Key? key,
    required this.isRegularMove,
  }) : super(key: key);

  @override
  ConsumerState<FinalReviewScreen> createState() => _FinalReviewScreenState();
}

class _FinalReviewScreenState extends ConsumerState<FinalReviewScreen> with MoveFlowMixin {
  bool isRequestingEstimate = false;

  @override
  void initState() {
    super.initState();
    isRegularMove = widget.isRegularMove;
  }


  // 서비스 유형 이름 변환
  String getCombinedServiceTypeName(MoveData moveData) {
    // 이사 유형
    final moveType = moveData.selectedMoveType;
    // 서비스 옵션
    final serviceType = moveData.selectedServiceType;

    // 특수 이사인 경우 - 서비스 옵션 표시 없이 바로
    if (moveType == 'office_move') return '사무실 이사';
    if (moveType == 'storage_move') return '보관 이사';
    if (moveType == 'simple_transport') return '단순 운송';

    // 소형 이사인 경우
    if (moveType == 'small_move') {
      if (serviceType == 'normal') return '소형 이사(일반)';
      if (serviceType == 'semiPackage') return '소형 이사(반포장)';
      if (serviceType == 'package') return '소형 이사(포장)';
      return '소형 이사';
    }

    // 포장 이사인 경우 (가정 이사)
    if (moveType == 'package_move') {
      if (serviceType == 'normal') return '가정 이사(일반)';
      if (serviceType == 'semiPackage') return '가정 이사(반포장)';
      if (serviceType == 'package') return '가정 이사(포장)';
      return '가정 이사';
    }

    // 기본값
    return '이사 유형 정보 없음';
  }

// 견적 요청 처리
  void _requestEstimate() {
    setState(() {
      isRequestingEstimate = true;
    });

    // 견적 요청 ID 생성 (실제 서비스에서는 서버에서 제공)
    final String requestId = 'EST${DateFormat('yyMMdd').format(DateTime.now())}${Random().nextInt(1000).toString().padLeft(3, '0')}';

    // 현재 날짜
    final String currentDate = DateFormat('yyyy.MM.dd').format(DateTime.now());

    // 견적 요청 객체 생성
    final EstimateRequest newRequest = EstimateRequest(
      id: requestId,
      status: '진행중',  // 초기 상태
      date: currentDate,
      isRegularMove: widget.isRegularMove,
    );

    // 견적 요청 추가 및 상태 업데이트
    ref.read(estimateRequestsProvider.notifier).addRequest(newRequest).then((_) {
      // 이사 상태를 '요청중'으로 업데이트
      if (widget.isRegularMove) {
        ref.read(regularMoveProvider.notifier).setEstimateRequestStatus(true);
      } else {
        ref.read(specialMoveProvider.notifier).setEstimateRequestStatus(true);
      }

      // 상태 업데이트 및 홈 화면으로 이동
      setState(() {
        isRequestingEstimate = false;
      });

      // 홈 화면으로 이동 (다이얼로그 없이)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }).catchError((e) {
      // 실패 처리
      setState(() {
        isRequestingEstimate = false;
      });

      // 실패 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('견적 요청 중 오류가 발생했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  // 성공 다이얼로그 표시
// 성공 다이얼로그 표시
  void _showSuccessDialog(String requestId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: widget.isRegularMove ? primaryColor : AppTheme.greenColor,
              size: 60,
            ),
            SizedBox(height: 16),
            Text(
              '견적 요청이 완료되었습니다',
              style: TextStyle(
                fontSize: context.scaledFontSize(18),
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '전문가가 검토 후 빠른 시간 내에 견적을 보내드립니다. 감사합니다.',
              style: TextStyle(
                fontSize: context.scaledFontSize(14),
                color: AppTheme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '견적번호: $requestId',
              style: TextStyle(
                fontSize: context.scaledFontSize(12),
                color: AppTheme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          // 이용내역 확인 버튼 추가
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton(
              onPressed: () {
                // 성공 다이얼로그 닫기
                Navigator.pop(context);
                // 이용내역 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyUsageHistoryScreen(userEmail: 'user@example.com'),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.isRegularMove ? primaryColor : AppTheme.greenColor,
                side: BorderSide(color: widget.isRegularMove ? primaryColor : AppTheme.greenColor),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '이용내역 확인하기',
                style: TextStyle(
                  fontSize: context.scaledFontSize(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                // 홈화면으로 이동
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isRegularMove ? primaryColor : AppTheme.greenColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '확인',
                style: TextStyle(
                  fontSize: context.scaledFontSize(16),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 이사 데이터 가져오기
    final moveState = widget.isRegularMove
        ? ref.watch(regularMoveProvider)
        : ref.watch(specialMoveProvider);

    final moveData = moveState.moveData;
    final Color themeColor = widget.isRegularMove ? primaryColor : AppTheme.greenColor;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '견적 요청 확인',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 진행 상황 표시 바 (앱바 바로 아래)
          MoveProgressBar(
            currentStep: 6,  // 첫 번째 단계
            isRegularMove: isRegularMove,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '입력하신 정보를 확인해주세요',
                          style: TextStyle(
                            fontSize: context.scaledFontSize(20),
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                        Text(
                          '추가 질문이나 수정이 필요하면 뒤로 가기를 눌러주세요',
                          style: TextStyle(
                            fontSize: context.scaledFontSize(14),
                            color: AppTheme.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15),

                  // 이사 유형 정보
                  _buildSectionCard(
                    title: '이사 유형',
                    icon: Icons.local_shipping,
                    themeColor: themeColor,
                    children: [
                      // 서비스 타입과 옵션을 합친 통합 정보
                      _buildInfoRow(
                        label: '서비스 타입',
                        value: getCombinedServiceTypeName(moveData),
                        iconData: Icons.miscellaneous_services_outlined,
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // 날짜 및 시간
                  _buildSectionCard(
                    title: '날짜 및 시간',
                    icon: Icons.calendar_today,
                    themeColor: themeColor,
                    children: [
                      _buildInfoRow(
                        label: '이사일',
                        value: moveData.selectedDate != null
                            ? DateFormat('yyyy년 MM월 dd일').format(moveData.selectedDate!)
                            : '날짜 미선택',
                        iconData: Icons.event_outlined,
                      ),
                      _buildInfoRow(
                        label: '희망 시간',
                        value: moveData.selectedTime ?? '시간 미선택',
                        iconData: Icons.access_time,
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // 주소 정보
// 주소 정보
                  _buildSectionCard(
                    title: '이사 주소',
                    icon: Icons.location_on_outlined,
                    themeColor: themeColor,
                    children: [
                      // 출발지 주소
                      if (moveData.startAddressDetails != null) ...[
                        _buildAddressSection(
                          title: '출발지',
                          addressDetails: moveData.startAddressDetails!,
                          icon: Icons.home_outlined,
                        ),
                        SizedBox(height: 16),
                      ],

                      // 도착지 주소
                      if (moveData.destinationAddressDetails != null)
                        _buildAddressSection(
                          title: '도착지',
                          addressDetails: moveData.destinationAddressDetails!,
                          icon: Icons.location_city_outlined,
                        ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // 이삿짐 정보 섹션
                  _buildSectionCard(
                    title: '이삿짐 정보',
                    icon: Icons.inventory_2_outlined,
                    themeColor: themeColor,
                    children: [
                      // 이삿짐 입력 방식
                      _buildInfoRow(
                        label: '입력 방식',
                        value: moveData.isPhotoSelected
                            ? '방 사진 촬영'
                            : moveData.isListSelected
                            ? '짐 목록 선택'
                            : '미선택',
                        iconData: moveData.isPhotoSelected
                            ? Icons.camera_alt_outlined
                            : Icons.list_alt_outlined,
                      ),

                      SizedBox(height: 16),
                      Divider(height: 1),
                      SizedBox(height: 16),

                      // 선택한 입력 방식에 따라 다른 위젯 표시
                      if (moveData.isPhotoSelected) ...[
                        // 방 사진 촬영 방식일 경우
                        if (moveData.roomTypes.isNotEmpty)
                          _buildRoomPhotoSection(moveData),
                      ] else if (moveData.isListSelected) ...[
                        // 짐 목록 선택 방식일 경우
                        if (moveData.selectedBaggageItems.isNotEmpty)
                          _buildBaggageItemsList(moveData.selectedBaggageItems),
                        if (moveData.attachedPhotos.isNotEmpty) ...[
                          SizedBox(height: 16),
                          Divider(height: 1),
                          SizedBox(height: 16),
                          _buildAttachedPhotosSection(moveData),
                        ],
                      ],
                    ],
                  ),

                  SizedBox(height: 16),

                  // 추가 정보 (메모 등)
                  if (moveData.memo != null && moveData.memo!.isNotEmpty)
                    _buildSectionCard(
                      title: '추가 메모',
                      icon: Icons.note_outlined,
                      themeColor: themeColor,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            moveData.memo!,
                            style: TextStyle(
                              fontSize: context.scaledFontSize(14),
                              color: AppTheme.primaryText,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 20),

                  // 알림 메시지
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber[800],
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '견적 요청 안내',
                                style: TextStyle(
                                  fontSize: context.scaledFontSize(16),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '입력하신 정보를 기반으로 전문 업체의 견적이 산출됩니다. 견적 확인까지 최대 24시간이 소요될 수 있습니다.',
                                style: TextStyle(
                                  fontSize: context.scaledFontSize(14),
                                  color: Colors.amber[900],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(context.defaultPadding),
                child: ElevatedButton(
                  onPressed: isRequestingEstimate ? null : _requestEstimate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                  ),
                  child: isRequestingEstimate
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '처리 중...',
                        style: TextStyle(
                          fontSize: context.scaledFontSize(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    '견적 요청하기',
                    style: TextStyle(
                      fontSize: context.scaledFontSize(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 섹션 카드 위젯
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color themeColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppTheme.borderSubColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: themeColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: context.scaledFontSize(18),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // 컨텐츠
          ...children,
        ],
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData iconData,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              iconData,
              color: AppTheme.secondaryText,
              size: 16,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: context.scaledFontSize(13),
                  color: AppTheme.secondaryText,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: context.scaledFontSize(15),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// 주소 섹션 위젯
  Widget _buildAddressSection({
    required String title,
    required Map<String, dynamic> addressDetails,
    required IconData icon,
  }) {
    // 출발지는 primaryColor, 도착지는 greenColor 사용
    final Color titleColor = title == '출발지' ? primaryColor : AppTheme.greenColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: titleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: titleColor,
                size: 20,
              ),
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: context.scaledFontSize(16),
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            // 배경색 변경
            color: titleColor.withOpacity(0.03), // 매우 연한 색상으로 배경 설정
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: titleColor.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: titleColor.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 주소
              Text(
                addressDetails['address'],
                style: TextStyle(
                  fontSize: context.scaledFontSize(15),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              ),
              // 상세주소
              if (addressDetails['detailAddress'] != null &&
                  addressDetails['detailAddress'].isNotEmpty)
                Text(
                  addressDetails['detailAddress'],
                  style: TextStyle(
                    fontSize: context.scaledFontSize(14),
                    color: AppTheme.primaryText,
                  ),
                ),
              SizedBox(height: 12),
              // 상세 정보
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildAddressTag('${addressDetails['buildingType']}', titleColor),
                  _buildAddressTag('${addressDetails['roomStructure']}', titleColor),
                  _buildAddressTag('${addressDetails['roomSize']}', titleColor),
                  _buildAddressTag('${addressDetails['floor']}층', titleColor),
                  if (addressDetails['hasElevator'] == true)
                    _buildAddressTag('엘리베이터 있음', titleColor),
                  if (addressDetails['hasStairs'] == true)
                    _buildAddressTag('1층 계단 있음', titleColor),
                  if (addressDetails['parkingAvailable'] == true)
                    _buildAddressTag('주차 가능', titleColor),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 주소 태그 위젯
  Widget _buildAddressTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.scaledFontSize(12),
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  // 이삿짐 목록 위젯
  Widget _buildBaggageItemsList(List<Map<String, dynamic>> items) {
    final Color themeColor = widget.isRegularMove ? primaryColor : AppTheme.greenColor;

    // 디버그 로깅: 아이템 정보 확인
    debugPrint('이삿짐 아이템 목록: ${items.length}개');
    if (items.isNotEmpty) {
      debugPrint('첫 번째 아이템 정보: ${items[0]}');
    }

    // 카테고리별로 아이템 분류
    Map<String, List<Map<String, dynamic>>> itemsByCategory = {};

    for (var item in items) {
      final category = item['category'] ?? '기타';
      if (!itemsByCategory.containsKey(category)) {
        itemsByCategory[category] = [];
      }
      itemsByCategory[category]!.add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.isRegularMove ? primaryColor.withOpacity(0.1) : AppTheme.greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2,
                color: widget.isRegularMove ? primaryColor : AppTheme.greenColor,
                size: 18,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '선택한 이삿짐 목록',
              style: TextStyle(
                fontSize: context.scaledFontSize(15),
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: widget.isRegularMove
                    ? primaryColor.withOpacity(0.1)
                    : AppTheme.greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '총 ${getTotalItemCount(itemsByCategory)}개',
                style: TextStyle(
                  fontSize: context.scaledFontSize(12),
                  color: widget.isRegularMove ? primaryColor : AppTheme.greenColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // 카테고리별로 아이템 표시
// 카테고리별로 아이템 표시
        ...itemsByCategory.entries.map((entry) {
          final category = entry.key;
          final categoryItems = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 헤더 - 단순화된 버전
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.category,
                        size: 16,
                        color: themeColor,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: context.scaledFontSize(16),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${categoryItems.length}개',
                        style: TextStyle(
                          color: themeColor,
                          fontSize: context.scaledFontSize(12),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 구분선 추가
              Divider(height: 1, thickness: 1, color: AppTheme.borderColor.withOpacity(0.3)),
              SizedBox(height: 8),

              // 아이템 목록 - 여기서 카드 형태 없이 바로 아이템 표시
// 아이템 목록 - 각 아이템을 네모 테두리로 감싸기
              ...categoryItems.map((item) {
                final hasOptions = item['options'] != null && (item['options'] as Map).isNotEmpty;
                String? iconPath = item['iconPath'] as String?;

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.subtleText.withOpacity(0.7),
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // 제품 이미지 추가
                      Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: iconPath != null && iconPath.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            iconPath,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, _) => Icon(
                              Icons.inventory_2,
                              color: themeColor,
                              size: 24,
                            ),
                          ),
                        )
                            : Icon(
                          Icons.inventory_2,
                          color: themeColor,
                          size: 24,
                        ),
                      ),

                      // 아이템 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['itemName'] ?? '알 수 없는 항목',
                              style: TextStyle(
                                fontSize: context.scaledFontSize(14),
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            if (hasOptions) ...[
                              SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: (item['options'] as Map).entries.map<Widget>((option) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: themeColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: themeColor.withOpacity(0.2),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      '${option.key}: ${option.value}',
                                      style: TextStyle(
                                        fontSize: context.scaledFontSize(12),
                                        color: themeColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              // 카테고리 구분을 위한 여백과 구분선
              SizedBox(height: 16),
              if (entry != itemsByCategory.entries.last)
                Divider(height: 1, thickness: 1, color: AppTheme.borderColor.withOpacity(0.9)),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAttachedPhotosSection(MoveData moveData) {
    final photos = moveData.attachedPhotos;

    if (photos.isEmpty) return SizedBox.shrink();

    final Color themeColor = widget.isRegularMove ? primaryColor : AppTheme.greenColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.photo_camera,
                color: themeColor,
                size: 18,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '첨부한 사진',
              style: TextStyle(
                fontSize: context.scaledFontSize(15),
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${photos.length}장',
                style: TextStyle(
                  fontSize: context.scaledFontSize(12),
                  color: themeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // 사진 그리드 (최대 6장까지 표시)
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: min(6, photos.length),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
                image: DecorationImage(
                  image: FileImage(File(photos[index])),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),

        // 6장 이상인 경우 더보기 표시
        if (photos.length > 6) ...[
          SizedBox(height: 8),
          Center(
            child: Text(
              '외 ${photos.length - 6}장의 사진',
              style: TextStyle(
                fontSize: context.scaledFontSize(12),
                color: AppTheme.secondaryText,
              ),
            ),
          ),
        ],
      ],
    );
  }

// 모든 카테고리의 총 아이템 수 계산하는 헬퍼 함수
  int getTotalItemCount(Map<String, List<dynamic>> itemsByCategory) {
    int total = 0;
    itemsByCategory.forEach((_, items) {
      total += items.length;
    });
    return total;
  }

// 방 사진 섹션 위젯
  Widget _buildRoomPhotoSection(MoveData moveData) {
    // 사진이 있는 방만 필터링
    final roomsWithPhotos = moveData.roomTypes.where((roomType) {
      final photos = moveData.roomImages[roomType] ?? [];
      return photos.isNotEmpty;
    }).toList();

    if (roomsWithPhotos.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: widget.isRegularMove ? primaryColor.withOpacity(0.1) : AppTheme.greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.photo_library_outlined,
                color: widget.isRegularMove ? primaryColor : AppTheme.greenColor,
                size: 18,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '촬영한 방 정보',
              style: TextStyle(
                fontSize: context.scaledFontSize(15),
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        // 방 목록
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: roomsWithPhotos.length,
          itemBuilder: (context, index) {
            final roomType = roomsWithPhotos[index];
            final photos = moveData.roomImages[roomType] ?? [];

            return Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: widget.isRegularMove
                        ? primaryColor.withOpacity(0.3)
                        : AppTheme.greenColor.withOpacity(0.3)
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 방 이름
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: widget.isRegularMove
                              ? primaryColor.withOpacity(0.1)
                              : AppTheme.greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          _getRoomIcon(roomType),
                          size: 14,
                          color: widget.isRegularMove ? primaryColor : AppTheme.greenColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        roomType,
                        style: TextStyle(
                          fontSize: context.scaledFontSize(14),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.isRegularMove
                              ? primaryColor.withOpacity(0.1)
                              : AppTheme.greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${photos.length}장',
                          style: TextStyle(
                            fontSize: context.scaledFontSize(12),
                            color: widget.isRegularMove ? primaryColor : AppTheme.greenColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (photos.length > 0) ...[
                    SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          min(3, photos.length), // 최대 3장만 표시
                              (photoIndex) => Container(
                            width: 70,
                            height: 70,
                            margin: EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.grey[300]!,
                              ),
                              image: DecorationImage(
                                image: FileImage(File(photos[photoIndex])),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 사진이 3장 이상인 경우 더보기 표시
                    if (photos.length > 3) ...[
                      SizedBox(height: 5),
                      Text(
                        '외 ${photos.length - 3}장의 사진',
                        style: TextStyle(
                          fontSize: context.scaledFontSize(12),
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

// 방 아이콘 가져오기
  IconData _getRoomIcon(String roomType) {
    switch (roomType) {
      case '거실':
        return Icons.weekend;
      case '주방':
        return Icons.kitchen;
      case '안방':
      case '침실':
        return Icons.king_bed;
      case '화장실':
        return Icons.bathtub;
      case '현관':
        return Icons.door_front_door;
      case '베란다':
        return Icons.balcony;
      case '드레스룸':
        return Icons.checkroom;
      case '창고':
        return Icons.inventory;
      default:
        return Icons.home;
    }
  }
}