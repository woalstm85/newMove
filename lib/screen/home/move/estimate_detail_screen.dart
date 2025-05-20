import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class EstimateDetailScreen extends ConsumerWidget {
  final bool isRegularMove;
  final String estimateId;

  const EstimateDetailScreen({
    Key? key,
    required this.isRegularMove,
    required this.estimateId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 이사 데이터 가져오기
    final moveState = isRegularMove
        ? ref.watch(regularMoveProvider)
        : ref.watch(specialMoveProvider);

    // 견적 데이터 (예시 데이터 - 실제로는 API나 다른 provider로부터 가져와야 함)
    final estimateData = _getMockEstimateData();

    final moveData = moveState.moveData;
    final Color themeColor = isRegularMove ? AppTheme.primaryColor : AppTheme.greenColor;

    // 숫자 포맷터 (가격 표시용)
    final numberFormat = NumberFormat('#,###');

    // 견적 제공 업체 수
    final companyCount = estimateData['companies'].length;

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
          '견적 상세 정보',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: themeColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('견적 공유 기능은 준비 중입니다.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: context.defaultPadding,
            right: context.defaultPadding,
            top: context.defaultPadding,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 상단 상태 카드
              _buildStatusCard(context, estimateData, themeColor, companyCount),

              SizedBox(height: 20),

              // 2. 이사 요약 정보
              _buildMoveSummaryCard(context, moveData, themeColor),

              SizedBox(height: 20),

              // 3. 견적 금액 섹션
              _buildPriceSectionTitle(context, '견적 금액', themeColor),

              SizedBox(height: 12),

              // 4. 업체별 견적 리스트
              ...estimateData['companies'].map<Widget>((company) =>
                  _buildCompanyEstimateCard(context, company, themeColor, numberFormat)
              ),

              SizedBox(height: 20),

              // 5. 견적 항목 섹션
              _buildPriceSectionTitle(context, '견적 항목', themeColor),

              SizedBox(height: 12),

              // 6. 견적 항목 상세
              _buildEstimateDetailsCard(context, estimateData, themeColor),

              SizedBox(height: 20),

              // 7. 견적 노트
              _buildNoteCard(context, themeColor),

              SizedBox(height: 24),

              // 8. 하단 버튼
              _buildBottomButtons(context, themeColor),
            ],
          ),
        ),
      ),
    );
  }

  // 상단 상태 카드
  Widget _buildStatusCard(BuildContext context, Map<String, dynamic> estimateData, Color themeColor, int companyCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 상태 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.checklist_rounded,
              color: themeColor,
              size: 30,
            ),
          ),

          SizedBox(height: 16),

          // 견적 완료 메시지
          Text(
            '견적 준비가 완료되었습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),

          SizedBox(height: 8),

          // 견적 개수
          Text(
            '$companyCount개 업체에서 견적을 제공했습니다',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText,
            ),
          ),

          SizedBox(height: 16),

          // 견적 요청 일시
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '요청 일시: ',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                ),
              ),
              Text(
                estimateData['requestDate'],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),

          SizedBox(height: 4),

          // 견적 번호
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '견적 번호: ',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                ),
              ),
              Text(
                estimateData['estimateId'],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 이사 요약 정보 카드
  Widget _buildMoveSummaryCard(BuildContext context, MoveData moveData, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize_outlined,
                color: themeColor,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                '이사 요약 정보',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // 이사 유형
          _buildInfoRow(
            title: '이사 유형',
            value: _getMoveTypeName(moveData),
            iconData: Icons.local_shipping_outlined,
          ),

          Divider(height: 24, color: Colors.grey.shade200),

          // 이사 날짜
          if (moveData.selectedDate != null)
            _buildInfoRow(
              title: '이사 날짜',
              value: DateFormat('yyyy년 MM월 dd일').format(moveData.selectedDate!),
              iconData: Icons.event_outlined,
            ),

          if (moveData.selectedDate != null)
            SizedBox(height: 12),

          // 이사 시간
          if (moveData.selectedTime != null)
            _buildInfoRow(
              title: '이사 시간',
              value: moveData.selectedTime ?? '',
              iconData: Icons.access_time,
            ),

          if (moveData.selectedTime != null)
            SizedBox(height: 12),

          // 출발지
          if (moveData.startAddressDetails != null)
            _buildInfoRow(
              title: '출발지',
              value: moveData.startAddressDetails!['address'],
              iconData: Icons.home_outlined,
              iconColor: Colors.blue,
            ),

          if (moveData.startAddressDetails != null)
            SizedBox(height: 12),

          // 도착지
          if (moveData.destinationAddressDetails != null)
            _buildInfoRow(
              title: '도착지',
              value: moveData.destinationAddressDetails!['address'],
              iconData: Icons.location_on_outlined,
              iconColor: Colors.green,
            ),
        ],
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow({
    required String title,
    required String value,
    required IconData iconData,
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          iconData,
          size: 18,
          color: iconColor ?? Colors.grey.shade600,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 섹션 타이틀
  Widget _buildPriceSectionTitle(BuildContext context, String title, Color themeColor) {
    return Padding(
      padding: EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          SizedBox(width: 8),
          if (title == '견적 금액')
            Tooltip(
              message: '업체별 견적 금액은 변동될 수 있습니다.',
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: themeColor,
              ),
            ),
        ],
      ),
    );
  }

  // 업체별 견적 카드
  Widget _buildCompanyEstimateCard(
      BuildContext context,
      Map<String, dynamic> company,
      Color themeColor,
      NumberFormat numberFormat,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // 업체 선택 시 동작
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // 업체 로고/아이콘
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: company['isRecommended'] ? themeColor.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.business,
                    color: company['isRecommended'] ? themeColor : Colors.grey.shade600,
                    size: 28,
                  ),
                ),
              ),

              SizedBox(width: 14),

              // 업체 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 추천 배지
                    if (company['isRecommended'])
                      Container(
                        margin: EdgeInsets.only(bottom: 4),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '추천',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                      ),

                    // 업체명
                    Text(
                      company['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),

                    SizedBox(height: 4),

                    // 평점
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${company['rating']} (${company['reviewCount']})',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 견적 금액
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${numberFormat.format(company['price'])}원',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),

                  SizedBox(height: 4),

                  // 견적 상세 보기 버튼
                  TextButton(
                    onPressed: () {
                      // 상세 견적 보기 동작
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '상세보기',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeColor,
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

  // 견적 항목 상세 카드
  Widget _buildEstimateDetailsCard(BuildContext context, Map<String, dynamic> estimateData, Color themeColor) {
    final items = estimateData['items'] as List<Map<String, dynamic>>;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.map((item) => _buildEstimateItemRow(context, item, themeColor)),

          Divider(height: 24, thickness: 1, color: Colors.grey.shade200),

          // 특이사항
          if (estimateData['specialNotes'] != null && estimateData['specialNotes'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '특이사항',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  estimateData['specialNotes'],
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // 견적 항목 행
  Widget _buildEstimateItemRow(BuildContext context, Map<String, dynamic> item, Color themeColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 체크 아이콘
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: themeColor,
              size: 12,
            ),
          ),

          SizedBox(width: 12),

          // 항목 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryText,
                  ),
                ),

                if (item['description'] != null && item['description'].isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      item['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 견적 노트 카드
  Widget _buildNoteCard(BuildContext context, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: themeColor,
                size: 20,
              ),
              SizedBox(width: 10),
              Text(
                '알아두세요',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Text(
            '• 업체별 견적은 변동될 수 있으며, 계약 시 최종 금액이 확정됩니다.\n'
                '• 각 업체의 서비스 범위와 약관을 확인하세요.\n'
                '• 예약 확정 후 취소는 위약금이 발생할 수 있습니다.\n'
                '• 특수 물품(피아노, 금고 등)은 추가 비용이 발생할 수 있습니다.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.primaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 하단 버튼
  Widget _buildBottomButtons(BuildContext context, Color themeColor) {
    return Column(
      children: [
        // 업체 선택 버튼
        ElevatedButton(
          onPressed: () {
            // 업체 선택 동작
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('업체를 선택해주세요.')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 54),
          ),
          child: Text(
            '업체 선택하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        SizedBox(height: 12),

        // 문의하기 버튼
        OutlinedButton(
          onPressed: () {
            // 문의하기 동작
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('문의하기 기능은 준비 중입니다.')),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: themeColor,
            side: BorderSide(color: themeColor),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 54),
          ),
          child: Text(
            '문의하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
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

  // 견적 데이터 목업
  Map<String, dynamic> _getMockEstimateData() {
    return {
      'estimateId': 'EST-2025-05-12345',
      'requestDate': '2025.05.12 14:30',
      'status': '견적 완료',
      'companies': [
        {
          'id': 'company1',
          'name': '프리미엄 무빙 서비스',
          'rating': 4.8,
          'reviewCount': 142,
          'price': 580000,
          'isRecommended': true,
        },
        {
          'id': 'company2',
          'name': '안심 이사 센터',
          'rating': 4.7,
          'reviewCount': 98,
          'price': 620000,
          'isRecommended': false,
        },
        {
          'id': 'company3',
          'name': '스마트 이사 서비스',
          'rating': 4.9,
          'reviewCount': 156,
          'price': 650000,
          'isRecommended': false,
        },
      ],
      'items': [
        {
          'name': '포장 서비스',
          'description': '모든 짐을 안전하게 포장해 드립니다.',
        },
        {
          'name': '가구 분해/조립',
          'description': '침대, 장롱 등 대형 가구의 분해와 조립을 포함합니다.',
        },
        {
          'name': '청소 서비스',
          'description': '이전 집 기본 청소 서비스가 포함됩니다.',
        },
        {
          'name': '운송 보험',
          'description': '이사 과정에서 발생할 수 있는 물품 파손에 대한 기본 보험이 포함됩니다.',
        },
      ],
      'specialNotes': '냉장고, 세탁기 등 대형 가전은 기본 서비스에 포함되어 있으며, 피아노나 금고 등 특수 물품은 별도 협의가 필요합니다.',
    };
  }
}