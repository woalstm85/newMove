import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/screen/home/move/estimate_detail_screen.dart';


class EstimateStatusScreen extends ConsumerStatefulWidget {
  final bool isRegularMove;

  const EstimateStatusScreen({
    Key? key,
    required this.isRegularMove,
  }) : super(key: key);

  @override
  ConsumerState<EstimateStatusScreen> createState() => _EstimateStatusScreenState();
}

class _EstimateStatusScreenState extends ConsumerState<EstimateStatusScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 이사 데이터 가져오기
    final moveState = widget.isRegularMove
        ? ref.watch(regularMoveProvider)
        : ref.watch(specialMoveProvider);

    // 견적 요청 정보 가져오기
    final estimateRequests = ref.watch(estimateRequestsProvider).requests;

    // 현재 이사 유형에 맞는 최신 견적 요청 찾기
    final currentEstimate = estimateRequests
        .where((req) => req.isRegularMove == widget.isRegularMove)
        .toList();

    // 날짜 비교 로직
    final latestEstimate = currentEstimate.isNotEmpty
        ? currentEstimate.reduce((a, b) =>
    _compareEstimateDates(a.date, b.date) > 0 ? a : b)
        : null;

    final moveData = moveState.moveData;
    final Color themeColor = widget.isRegularMove ? AppTheme.primaryColor : AppTheme.greenColor;

    // 이사 유형 이름 가져오기
    String moveTypeName = _getMoveTypeName(moveData);

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
          '견적 요청 상태',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: context.defaultPadding,
            right: context.defaultPadding,
            top: context.defaultPadding,
            bottom: context.defaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 견적 요약 정보 카드 (수정됨)
              _buildCompactSummaryCard(context, moveData, themeColor, moveTypeName, latestEstimate),

              SizedBox(height: 24),

              // 3. 이사업체 리스트
              _buildMovingCompaniesSection(context, themeColor),

              SizedBox(height: 14),

              // 4. 안내 메시지
              _buildInfoMessage(context, themeColor),

              SizedBox(height: 24),

              // 5. 하단 버튼
              _buildBottomButtons(context, themeColor),
            ],
          ),
        ),
      ),
    );
  }

  // 날짜 비교 헬퍼 메서드
  int _compareEstimateDates(String dateA, String dateB) {
    try {
      final parsedDateA = _parseEstimateDate(dateA);
      final parsedDateB = _parseEstimateDate(dateB);
      return parsedDateA.compareTo(parsedDateB);
    } catch (e) {
      return dateA.compareTo(dateB);
    }
  }

  // 날짜 파싱 헬퍼 메서드
  DateTime _parseEstimateDate(String dateStr) {
    if (dateStr.contains('.')) {
      final parts = dateStr.split('.');
      if (parts.length >= 3) {
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }
    }

    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  // 이사 유형 이름 가져오기
  String _getMoveTypeName(MoveData moveData) {
    if (moveData.selectedMoveType == 'office_move') return '사무실 이사';
    if (moveData.selectedMoveType == 'storage_move') return '보관 이사';
    if (moveData.selectedMoveType == 'simple_transport') return '단순 운송';

    if (moveData.selectedMoveType == 'small_move') {
      if (moveData.selectedServiceType == 'normal') return '소형 이사(일반)';
      if (moveData.selectedServiceType == 'semiPackage') return '소형 이사(반포장)';
      if (moveData.selectedServiceType == 'package') return '소형 이사(포장)';
      return '소형 이사';
    }

    if (moveData.selectedMoveType == 'package_move') {
      if (moveData.selectedServiceType == 'normal') return '가정 이사(일반)';
      if (moveData.selectedServiceType == 'semiPackage') return '가정 이사(반포장)';
      if (moveData.selectedServiceType == 'package') return '가정 이사(포장)';
      return '가정 이사';
    }

    return '이사 유형 정보 없음';
  }

  // 간단한 견적 요약 카드 (수정됨 - 흰색 배경으로 변경)
  Widget _buildCompactSummaryCard(BuildContext context, MoveData moveData, Color themeColor, String moveTypeName, EstimateRequest? latestEstimate) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (타이틀 + 애니메이션) - 배경색 흰색으로 변경
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, // 흰색 배경으로 변경
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade100,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.summarize_outlined,
                      color: themeColor,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '이사 요약 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    Spacer(),
                    // 애니메이션 위젯 - 파란색 배경에 흰색 텍스트로 변경
                    _buildAnimatedStatus(themeColor),
                  ],
                ),
                // 요청 일시 값만 타이틀 바로 아래에 표시
                if (latestEstimate != null)
                  Padding(
                    padding: EdgeInsets.only(left: 36), // 왼쪽 패딩 조정 (아이콘 너비 + 간격)
                    child: Text(
                      latestEstimate.date,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 컨텐츠 - 간결하게 표시
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // 이사 유형
                _buildCompactInfoRow(
                  icon: Icons.local_shipping_outlined,
                  value: moveTypeName,
                  color: themeColor,
                ),
                SizedBox(height: 16),
                // 날짜와 시간을 한 줄에
                if (moveData.selectedDate != null)
                  _buildCompactInfoRow(
                    icon: Icons.event_outlined,
                    value: "${DateFormat('yyyy년 MM월 dd일').format(moveData.selectedDate!)} ${moveData.selectedTime ?? ''}",
                    color: themeColor,
                  ),

                if (moveData.selectedDate != null)
                  SizedBox(height: 16),

                // 출발지
                if (moveData.startAddressDetails != null)
                  _buildCompactInfoRow(
                    icon: Icons.home_outlined,
                    value: moveData.startAddressDetails!['address'],
                    color: Colors.blue,
                  ),

                if (moveData.startAddressDetails != null)
                  SizedBox(height: 16),

                // 도착지
                if (moveData.destinationAddressDetails != null)
                  _buildCompactInfoRow(
                    icon: Icons.location_on_outlined,
                    value: moveData.destinationAddressDetails!['address'],
                    color: Colors.green,
                  ),
              ],
            ),
          ),

          // 견적 보기 버튼
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                // 견적 상세 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EstimateDetailScreen(
                      isRegularMove: widget.isRegularMove,
                      estimateId: latestEstimate?.id ?? 'default-estimate-id',
                    ),
                  ),
                );
              },
              icon: Icon(Icons.description_outlined),
              label: Text('견적 보기',
                style: TextStyle(
                fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          SizedBox(height: 8),
        ],
      ),
    );
  }

  // 애니메이션 상태 위젯 (파란색 배경에 흰색 텍스트로 변경)
  Widget _buildAnimatedStatus(Color themeColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor, // 파란색 배경으로 변경
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 움직이는 작은 막대 애니메이션 - 흰색으로 변경
          SizedBox(
            width: 16,
            height: 16,
            child: _buildMiniLoadingBars(Colors.white), // 흰색으로 변경
          ),
          SizedBox(width: 8),
          Text(
            '검토 중',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white, // 흰색 텍스트로 변경
            ),
          ),
        ],
      ),
    );
  }

  // 작은 로딩 바 애니메이션
  Widget _buildMiniLoadingBars(Color color) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            // 각 막대의 위상을 약간씩 다르게 하여 물결 효과 생성
            final delay = index * 0.2;
            final value = sin((_animationController.value * 3.14 + delay) % 3.14) * 0.5 + 0.5;

            return Container(
              width: 3,
              height: 10 * value,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        );
      },
    );
  }

  // 간결한 정보 행 위젯
  Widget _buildCompactInfoRow({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // 이사업체 리스트 섹션
  Widget _buildMovingCompaniesSection(BuildContext context, Color themeColor) {
    // 임의의 이사업체 3개 생성
    final companies = [
      {
        'name': '스마트 이사 서비스',
        'rating': 4.8,
        'reviews': 128,
        'description': '빠르고 안전한 이사 서비스, 특별 할인 중',
        'image': 'https://example.com/company1.jpg',
      },
      {
        'name': '프리미엄 무빙',
        'rating': 4.7,
        'reviews': 96,
        'description': '친절한 서비스와 합리적인 가격',
        'image': 'https://example.com/company2.jpg',
      },
      {
        'name': '안심 이사 센터',
        'rating': 4.9,
        'reviews': 156,
        'description': '보험 가입 완비, 파손 걱정 없는 이사',
        'image': 'https://example.com/company3.jpg',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            '추천 이사업체',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
        ),

        // 업체 리스트
        ...companies.map((company) => _buildCompanyCard(context, company, themeColor)),
      ],
    );
  }

  // 업체 카드 위젯
  Widget _buildCompanyCard(BuildContext context, Map<String, dynamic> company, Color themeColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // 업체 선택 시 동작
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${company['name']}을(를) 선택하셨습니다.'),
              backgroundColor: themeColor,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // 업체 아이콘 또는 이미지
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business,
                  color: themeColor,
                  size: 32,
                ),
              ),
              SizedBox(width: 16),

              // 업체 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${company['rating']} (${company['reviews']})',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      company['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 선택 아이콘
              Icon(
                Icons.arrow_forward_ios,
                color: themeColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 안내 메시지 위젯
  Widget _buildInfoMessage(BuildContext context, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: themeColor,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '이런 경우 견적이 지연될 수 있어요',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '• 특이 항목이 있는 경우 (피아노, 대형 가전제품 등)\n• 견적 요청이 많은 성수기 기간\n• 기상 악화 또는 공휴일\n• 출발지/도착지가 특수한 지역인 경우',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 하단 버튼 위젯
  Widget _buildBottomButtons(BuildContext context, Color themeColor) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 54),
          ),
          child: Text(
            '홈으로 돌아가기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}