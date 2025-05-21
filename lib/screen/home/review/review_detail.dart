import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api/review_api_service.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

class ReviewDetailScreen extends StatefulWidget {
  final String reviewId;

  const ReviewDetailScreen({super.key, required this.reviewId});

  @override
  _ReviewDetailScreenState createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  Map<String, dynamic>? review;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReviewDetail();
  }

  Future<void> loadReviewDetail() async {
    Map<String, dynamic>? fetchedReview = await ReviewService.fetchReviewDetail(widget.reviewId);
    setState(() {
      review = fetchedReview;
      isLoading = false;
    });
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('yyyy.MM.dd').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  String formatAmount(int? amount) {
    if (amount == null) return '';
    return NumberFormat('#,###').format(amount) + '원';
  }

  @override
  Widget build(BuildContext context) {
    final int starCount = review != null && review!['startCnt'] != null ?
    (review!['startCnt'] is int ? review!['startCnt'] : review!['startCnt'].toInt()) : 0;
    final int emptyStarCount = 5 - starCount;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          '리뷰 상세',
          style: AppTheme.headingStyle.copyWith(
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryText),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                '리뷰를 불러오는 중입니다...',
                style: TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        )
            : review == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.subtleText,
              ),
              const SizedBox(height: 16),
              Text(
                '리뷰 정보를 불러오지 못했습니다.',
                style: TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        )
            : Column(
          children: [
            // 스크롤 가능한 콘텐츠 영역
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  // 상단 카드 - 핵심 정보 포함
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                        // 헤더 - 서비스 유형 및 날짜
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                review?['serviceNm'] ?? '서비스',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              formatDate(review!['serviceDt'] ?? ''),
                              style: TextStyle(
                                color: AppTheme.subtleText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 금액 및 별점을 한 줄에 배치
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 금액 정보
                            Text(
                              formatAmount(review!['amount']),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),

                            // 별점
                            Row(
                              children: [
                                ...List.generate(
                                    starCount,
                                        (i) => const Icon(Icons.star, color: AppTheme.warning, size: 18)
                                ),
                                ...List.generate(
                                    emptyStarCount,
                                        (i) => Icon(Icons.star_border, color: AppTheme.subtleText, size: 18)
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$starCount.0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryText,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 간단한 정보 칩 - 파트너명과 건물 유형
                        Row(
                          children: [
                            _buildInfoChip(Icons.business_outlined, review!['parterNm'] ?? '이름 없음'),
                            const SizedBox(width: 10),
                            _buildInfoChip(Icons.location_on_outlined, review!['buildingNm'] ?? '정보 없음'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 리뷰 내용 카드 - 내용에 맞게 자동으로 크기 조절
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
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
                        // 리뷰 내용 헤더
                        Text(
                          '리뷰 내용',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 파트너 코멘트 (있는 경우에만)
                        if (review!['comments'] != null && review!['comments'].toString().isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.accentColor.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '파트너 코멘트',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  review!['comments'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.primaryText.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 리뷰 본문
                        Text(
                          review!['contents'] ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: AppTheme.secondaryText,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 하단 알림 텍스트
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppTheme.subtleText,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '이 리뷰는 실제 서비스 이용 후 작성된 리뷰입니다.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.subtleText,
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
            ),

            // 하단 확인 버튼 (항상 화면 하단에 고정)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.scaffoldBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '확 인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 정보 칩 위젯
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.subtleText.withOpacity(0.07),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.secondaryText,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}