import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/screen/home/move/company_estimate_detail_screen.dart';

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

    // 견적 데이터 (예시 데이터 - 실제로는 API나 다른 provider로부터 가져와야 함)
    final estimateData = _getMockEstimateData();

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
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 스크롤 가능한 콘텐츠 영역
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: context.defaultPadding,
                  right: context.defaultPadding,
                  top: context.defaultPadding,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 상단 상태 카드
                    _buildStatusCard(context, estimateData, themeColor, companyCount),

                    SizedBox(height: 20),

                    // 3. 견적 금액 섹션
                    _buildPriceSectionTitle(context, '견적 금액', themeColor),

                    SizedBox(height: 12),

                    // 4. 업체별 견적 리스트
                    ...estimateData['companies'].map<Widget>((company) =>
                        _buildCompanyEstimateCard(context, company, themeColor, numberFormat)
                    ),

                    SizedBox(height: 20),

                    // 7. 견적 노트
                    _buildNoteCard(context, themeColor),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 상단 상태 카드 (수정된 버전 - 파란색 배경)
  Widget _buildStatusCard(BuildContext context, Map<String, dynamic> estimateData, Color themeColor, int companyCount) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor, // 파란색 배경
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // 체크 아이콘 (흰색 원형)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 24,
              ),
            ),

            SizedBox(width: 16),

            // 텍스트 컬럼
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 견적 완료 메시지
                  Text(
                    '견적 준비가 완료되었습니다',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 4),

                  // 견적 개수
                  Text(
                    '$companyCount개 업체에서 견적을 제공했습니다',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        ],
      ),
    );
  }

// 업체별 견적 카드 (추천 업체는 primaryColor 배경과 흰색 글씨로 강조, 최고가/최저가 표시 강조)
  Widget _buildCompanyEstimateCard(
      BuildContext context,
      Map<String, dynamic> company,
      Color themeColor,
      NumberFormat numberFormat,
      ) {
    final bool isRecommended = company['isRecommended'] ?? false;

    // 최고가/최저가 확인을 위한 변수
    final int price = company['price'] as int;
    final bool isHighestPrice = company['isHighestPrice'] ?? false;
    final bool isLowestPrice = company['isLowestPrice'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRecommended ? AppTheme.greenColor : Colors.white, // 추천 업체는 greenColor 배경
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
        child: Stack(
          children: [
            // 기본 카드 내용
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // 업체 로고/아이콘
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isRecommended ? Colors.white.withOpacity(0.2) : Colors.grey.shade100, // 추천 업체는 반투명 흰색 배경
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.business,
                        color: isRecommended ? Colors.white : Colors.grey.shade600, // 추천 업체는 흰색 아이콘
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
                        if (isRecommended)
                          Container(
                            margin: EdgeInsets.only(bottom: 4),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.thumb_up,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '추천',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 업체명 (추천 업체는 흰색 텍스트)
                        Text(
                          company['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isRecommended ? Colors.white : AppTheme.primaryText,
                          ),
                        ),

                        SizedBox(height: 4),

                        // 평점 (추천 업체는 흰색/반투명 텍스트)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: isRecommended ? Colors.amber : Colors.amber, // 별은 항상 노란색
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${company['rating']} (${company['reviewCount']})',
                              style: TextStyle(
                                fontSize: 12,
                                color: isRecommended ? Colors.white.withOpacity(0.9) : AppTheme.secondaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 견적 금액 (추천 업체는 흰색 텍스트)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 가격 표시 (최고가/최저가 표시가 있을 경우 위치 조정)
                      Padding(
                        padding: EdgeInsets.only(top: (isHighestPrice || isLowestPrice) ? 24 : 0),
                        child: Text(
                          '${numberFormat.format(price)}원',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isRecommended ? Colors.white : themeColor,
                          ),
                        ),
                      ),

                      SizedBox(height: 4),

                      // 견적 상세 보기 버튼 (추천 업체는 흰색 버튼)
                      TextButton(
                        onPressed: () {
                          // 상세 견적 보기 화면으로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompanyEstimateDetailScreen(
                                companyId: company['id'],
                                companyName: company['name'],
                                isRegularMove: isRegularMove,
                                companyData: _getMockCompanyDetailData(company['id']),
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: isRecommended ? Colors.white.withOpacity(0.2) : Colors.transparent,
                        ),
                        child: Text(
                          '상세보기',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isRecommended ? Colors.white : themeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 최고가 표시 (오른쪽 상단에 강조 표시)
            if (isHighestPrice)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '최고가',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 최저가 표시 (오른쪽 상단에 강조 표시)
            if (isLowestPrice)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '최저가',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 3. 업체 상세 데이터 생성 함수
  Map<String, dynamic> _getMockCompanyDetailData(String companyId) {
    return {
      'basePrice': 500000,
      'additionalPrice': 80000,
      'discount': 50000,
      'mainItems': [
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
      'additionalServices': [
        {
          'name': '프리미엄 포장 서비스',
          'description': '고급 포장재를 사용한 안전한 포장 서비스',
          'price': 100000,
          'selected': false,
        },
        {
          'name': '특수 물품 운송',
          'description': '피아노, 금고 등 특수 물품 운송',
          'price': 150000,
          'selected': false,
        },
        {
          'name': '가전제품 설치',
          'description': 'TV, 세탁기 등 가전제품 설치 서비스',
          'price': 50000,
          'selected': false,
        },
      ],
      'discounts': [
        {
          'name': '조기 예약 할인',
          'description': '30일 이전 예약 고객 특별 할인',
          'amount': 30000,
        },
        {
          'name': '첫 이용 고객 할인',
          'description': '무브스마트 첫 이용 고객 할인',
          'amount': 20000,
        },
      ],
    };
  }

// 견적 노트 카드
  Widget _buildNoteCard(BuildContext context, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션 (타이틀 변경 및 느낌표 아이콘 적용)
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.priority_high, // 느낌표 아이콘
                  color: Colors.white,
                  size: 14,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '원하는 업체를 찾지 못하셨나요?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // 내용 - 단일 섹션으로 간결하게
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추가 견적을 요청하시면 더 많은 이사 업체로부터 맞춤형 견적을 받아보실 수 있습니다. 특별한 요구사항이 있으시면 요청 시 함께 기재해 주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryText,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 16),

                // 견적 더 요청하기 버튼
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // 견적 더 요청하기 기능
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('추가 견적 요청이 접수되었습니다.')),
                          );
                        },
                        icon: Icon(Icons.refresh),
                        label: Text('견적 더 요청하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// 견적 데이터 목업 (최고가/최저가 플래그 추가)
  Map<String, dynamic> _getMockEstimateData() {
    // 업체 리스트 생성
    final companies = [
      {
        'id': 'company1',
        'name': '내가 최고야 익스프레스',
        'rating': 4.9,
        'reviewCount': 156,
        'price': 650000,
        'isRecommended': true,
      },
      {
        'id': 'company2',
        'name': '프리미엄 무빙 서비스',
        'rating': 4.8,
        'reviewCount': 142,
        'price': 580000,
        'isRecommended': true,
      },
      {
        'id': 'company3',
        'name': '홍길동 파트너',
        'rating': 4.7,
        'reviewCount': 98,
        'price': 620000,
        'isRecommended': false,
      },
      {
        'id': 'company4',
        'name': '스마트 이사 센터',
        'rating': 4.9,
        'reviewCount': 156,
        'price': 550000,
        'isRecommended': false,
      },
      {
        'id': 'company5',
        'name': '겁나빨라 이사 센터',
        'rating': 4.9,
        'reviewCount': 156,
        'price': 350000,
        'isRecommended': false,
      },
    ];

    // 최고가와 최저가 찾기
    int maxPrice = 0;
    int minPrice = 9999999999;

    for (var company in companies) {
      final price = company['price'] as int;
      if (price > maxPrice) maxPrice = price;
      if (price < minPrice) minPrice = price;
    }

    // 최고가와 최저가 플래그 설정
    for (var company in companies) {
      final price = company['price'] as int;
      company['isHighestPrice'] = price == maxPrice;
      company['isLowestPrice'] = price == minPrice;
    }

    return {
      'estimateId': 'EST-2025-05-12345',
      'requestDate': '2025.05.12 14:30',
      'status': '견적 완료',
      'companies': companies,
    };
  }
}