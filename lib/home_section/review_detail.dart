import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api_service.dart';
import '../theme/theme_constants.dart';

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
    Map<String, dynamic>? fetchedReview = await ApiService.fetchReviewDetail(widget.reviewId);
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
            : Stack(
          children: [
            // 스크롤 가능한 콘텐츠
            Padding(
              padding: const EdgeInsets.only(bottom: 84), // 하단 버튼 높이만큼 패딩 추가
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 서비스 유형 및 날짜
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

                      const SizedBox(height: 20),

                      // 금액 정보
                      Row(
                        children: [
                          Text(
                            formatAmount(review!['amount']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 별점
                      Row(
                        children: [
                          ...List.generate(
                              starCount,
                                  (i) => const Icon(Icons.star, color: AppTheme.warning, size: 20)
                          ),
                          ...List.generate(
                              emptyStarCount,
                                  (i) => Icon(Icons.star_border, color: AppTheme.subtleText, size: 20)
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$starCount.0',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 구분선
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppTheme.borderColor,
                      ),

                      const SizedBox(height: 24),

                      // 세부 정보
                      buildInfoSection('파트너 정보', [
                        buildInfoItem(
                            Icons.business_outlined,
                            '파트너명',
                            review!['parterNm'] ?? '이름 없음'
                        ),
                        buildInfoItem(
                            Icons.location_on_outlined,
                            '건물 유형',
                            review!['buildingNm'] ?? '정보 없음'
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // 리뷰 내용
                      Text(
                        '리뷰 내용',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (review!['comments'] != null && review!['comments'].toString().isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.accentColor.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            review!['comments'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.primaryText.withOpacity(0.8),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      Text(
                        review!['contents'] ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: AppTheme.secondaryText,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 저작권 및 안내문
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.subtleText.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppTheme.subtleText,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '이 리뷰는 실제 서비스 이용 후 작성된 리뷰입니다. 리뷰 내용에 대한 책임은 작성자에게 있습니다.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.subtleText,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20), // 하단 버튼을 위한 여백
                    ],
                  ),
                ),
              ),
            ),

            // 하단에 고정된 버튼
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
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
                    '리뷰 목록으로 돌아가기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.subtleText,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
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
}