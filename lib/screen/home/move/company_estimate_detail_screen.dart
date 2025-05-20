import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

class CompanyEstimateDetailScreen extends StatelessWidget {
  final String companyId;
  final String companyName;
  final bool isRegularMove;
  final Map<String, dynamic> companyData;

  const CompanyEstimateDetailScreen({
    Key? key,
    required this.companyId,
    required this.companyName,
    required this.isRegularMove,
    required this.companyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color themeColor = isRegularMove ? AppTheme.primaryColor : AppTheme.greenColor;
    final numberFormat = NumberFormat('#,###');

    // 필요한 데이터 파싱
    final mainItems = companyData['mainItems'] as List<Map<String, dynamic>>;
    final additionalServices = companyData['additionalServices'] as List<Map<String, dynamic>>;
    final discounts = companyData['discounts'] as List<Map<String, dynamic>>;

    // 금액 계산
    final basePrice = companyData['basePrice'] as int;
    final additionalPrice = companyData['additionalPrice'] as int;
    final discount = companyData['discount'] as int;
    final totalPrice = basePrice + additionalPrice - discount;

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
          '견적 상세',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border, color: themeColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('관심 업체로 저장되었습니다.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 18 , // 하단 버튼을 위한 여유 공간
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(height: 8, thickness: 8, color: Colors.grey.shade100),
              // 1. 업체 요약 정보 (상단 배너)
              _buildCompanyBanner(context, themeColor),

              // 구분선
              Divider(height: 1, thickness: 8, color: Colors.grey.shade100),

              // 2. 최종 견적 금액 카드
              _buildTotalPriceCard(context, themeColor, numberFormat, basePrice, additionalPrice, discount, totalPrice),

              // 구분선
              Divider(height: 1, thickness: 8, color: Colors.grey.shade100),

              // 3. 주요 서비스 항목
              _buildSectionTitle(context, '기본 서비스 항목', Icons.check_circle_outline),
              _buildItemsList(context, mainItems, themeColor),

              // 구분선
              Divider(height: 1, thickness: 8, color: Colors.grey.shade100),

              // 4. 추가 서비스 항목
              _buildSectionTitle(context, '추가 서비스 (선택 사항)', Icons.add_circle_outline),
              _buildAdditionalServicesList(context, additionalServices, themeColor, numberFormat),

              // 구분선
              Divider(height: 1, thickness: 8, color: Colors.grey.shade100),

              // 5. 할인 항목
              _buildSectionTitle(context, '할인 적용 내역', Icons.discount_outlined),
              _buildDiscountList(context, discounts, themeColor, numberFormat),

              // 구분선
              Divider(height: 1, thickness: 8, color: Colors.grey.shade100),

              // 6. 일정 및 세부 정보
              _buildSectionTitle(context, '이사 일정 및 세부 정보', Icons.event_note),
              _buildScheduleDetails(context),

              // 구분선
              Divider(height: 1, thickness: 8, color: Colors.grey.shade100),

              // 7. 업체 소개 및 리뷰
              _buildSectionTitle(context, '업체 소개 및 리뷰', Icons.business),
              _buildCompanyInfo(context, themeColor),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(context, themeColor),
    );
  }

  // 업체 배너 (상단)
  Widget _buildCompanyBanner(BuildContext context, Color themeColor) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // 업체 로고
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.business,
                color: themeColor,
                size: 36,
              ),
            ),
          ),

          SizedBox(width: 16),

          // 업체 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      companyName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '인증업체',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6),

                // 평점 및 리뷰
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < 4 ? Icons.star : Icons.star_half,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '4.8 (156건)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6),

                // 간단한 태그들
                Wrap(
                  spacing: 6,
                  children: [
                    _buildSmallTag('친절한 서비스'),
                    _buildSmallTag('신속한 이사'),
                    _buildSmallTag('정확한 시간'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 작은 태그 위젯
  Widget _buildSmallTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  // 최종 견적 금액 카드
  Widget _buildTotalPriceCard(
      BuildContext context,
      Color themeColor,
      NumberFormat numberFormat,
      int basePrice,
      int additionalPrice,
      int discount,
      int totalPrice,
      ) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '견적 금액',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),

          SizedBox(height: 16),

          // 기본 서비스
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '기본 서비스',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                ),
              ),
              Text(
                '${numberFormat.format(basePrice)}원',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          // 추가 서비스
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '추가 서비스',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                ),
              ),
              Text(
                '+${numberFormat.format(additionalPrice)}원',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          // 할인 금액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '할인',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryText,
                ),
              ),
              Text(
                '-${numberFormat.format(discount)}원',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Divider(height: 1, color: Colors.grey.shade200),

          SizedBox(height: 12),

          // 총 금액
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 견적 금액',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              Text(
                '${numberFormat.format(totalPrice)}원',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // 안내 메시지
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: themeColor,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '이사 당일 상황에 따라 최종 금액이 변동될 수 있습니다.',
                    style: TextStyle(
                      fontSize: 12,
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

  // 섹션 타이틀
  Widget _buildSectionTitle(BuildContext context, String title, IconData iconData) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(
            iconData,
            color: AppTheme.primaryText,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  // 주요 서비스 항목 리스트
  Widget _buildItemsList(BuildContext context, List<Map<String, dynamic>> items, Color themeColor) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: themeColor,
                  size: 18,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: TextStyle(
                          fontSize: 14,
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
                              fontSize: 12,
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
        }).toList(),
      ),
    );
  }

  // 추가 서비스 항목 리스트
  Widget _buildAdditionalServicesList(
      BuildContext context,
      List<Map<String, dynamic>> services,
      Color themeColor,
      NumberFormat numberFormat,
      ) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: services.map((service) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: service['selected'] ?? false,
                  onChanged: (value) {
                    // 선택 상태 변경 로직
                  },
                  activeColor: themeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      if (service['description'] != null && service['description'].isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            service['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '+${numberFormat.format(service['price'])}원',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: themeColor,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 할인 목록
  Widget _buildDiscountList(
      BuildContext context,
      List<Map<String, dynamic>> discounts,
      Color themeColor,
      NumberFormat numberFormat,
      ) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: discounts.map((discount) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.percent,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discount['name'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryText,
                        ),
                      ),
                      if (discount['description'] != null && discount['description'].isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            discount['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '-${numberFormat.format(discount['amount'])}원',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 일정 및 세부 정보
  Widget _buildScheduleDetails(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          _buildScheduleItem(
            icon: Icons.event,
            title: '이사 날짜',
            value: '2025년 5월 25일 (토)',
          ),
          SizedBox(height: 16),
          _buildScheduleItem(
            icon: Icons.access_time,
            title: '이사 시간',
            value: '오전 9:00 ~ 오후 1:00',
          ),
          SizedBox(height: 16),
          _buildScheduleItem(
            icon: Icons.people,
            title: '이사 인력',
            value: '전문 인력 3명',
          ),
          SizedBox(height: 16),
          _buildScheduleItem(
            icon: Icons.local_shipping,
            title: '차량 정보',
            value: '2.5톤 트럭 1대',
          ),
        ],
      ),
    );
  }

  // 일정 항목 위젯
  Widget _buildScheduleItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
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

  // 업체 소개 및 리뷰
  Widget _buildCompanyInfo(BuildContext context, Color themeColor) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 업체 소개
          Text(
            '회사 소개',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),

          SizedBox(height: 8),

          Text(
            '저희 $companyName은 10년 이상의 경험을 가진 전문 이사 업체로, 고객의 소중한 물품을 안전하게 운송하는 것을 최우선으로 생각합니다. 숙련된 전문가들이 신속하고 정확하게 이사를 도와드립니다.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.secondaryText,
              height: 1.5,
            ),
          ),

          SizedBox(height: 16),

          // 리뷰 타이틀 및 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '리뷰 (156)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              TextButton(
                onPressed: () {
                  // 리뷰 전체 보기
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '더보기',
                  style: TextStyle(
                    fontSize: 13,
                    color: themeColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          // 리뷰 예시
          _buildReviewItem(
            name: '김**',
            rating: 5,
            date: '2025.04.18',
            content: '정말 친절하게 이사를 도와주셨어요. 짐도 하나도 파손 없이 안전하게 옮겨주셨고, 시간도 정확하게 지켜주셔서 좋았습니다.',
          ),
        ],
      ),
    );
  }

  // 리뷰 아이템
  Widget _buildReviewItem({
    required String name,
    required int rating,
    required String date,
    required String content,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              SizedBox(width: 8),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 14,
                  );
                }),
              ),
              Spacer(),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.primaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 하단 버튼
  Widget _buildBottomButtons(BuildContext context, Color themeColor) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // 전화 버튼 - 텍스트 없이 아이콘만 사용
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('업체에 전화 연결 중...')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: themeColor),
                  minimumSize: Size(0, 54), // 버튼 높이 통일
                ),
                child: Icon(
                  Icons.phone,
                  color: themeColor,
                  size: 24,
                ),
              ),
            ),

            SizedBox(width: 12),

            // 예약 버튼
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('예약 진행 중...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(0, 54), // 버튼 높이 통일
                ),
                child: Text(
                  '이 업체로 이사 예약하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}