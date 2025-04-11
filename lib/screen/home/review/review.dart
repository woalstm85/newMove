import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MoveSmart/screen/home/review/review_detail.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

class ReviewSlider extends StatelessWidget {
  final List<dynamic> reviews;
  final bool isLoading;

  const ReviewSlider({
    super.key,
    required this.reviews,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (reviews.isEmpty) {
      return _buildEmptyState();
    }

    return _buildReviewList(context);
  }

  // 로딩 상태 UI
  Widget _buildLoadingState() {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              strokeWidth: 3,
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
      ),
    );
  }

  // 리뷰 없음 상태 UI
  Widget _buildEmptyState() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 48,
            color: AppTheme.subtleText,
          ),
          const SizedBox(height: 16),
          Text(
            AppCopy.reviewPlaceholder,
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 리뷰를 작성해 보세요!',
            style: TextStyle(
              color: AppTheme.subtleText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 리뷰 리스트 UI
  Widget _buildReviewList(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 0, right: 0),
        scrollDirection: Axis.horizontal,
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          final int id = review['id'];
          int starCount = review['startCnt'] ?? 0;

          // 금액 포맷팅
          String formattedAmount = review['amount'] != null
              ? NumberFormat('#,###').format(review['amount'])
              : '';

          // 날짜 포맷팅
          String formattedDate = review['serviceDt'] != null
              ? DateFormat('yyyy.MM').format(DateTime.parse(review['serviceDt']))
              : '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ReviewDetailScreen(reviewId: id.toString()),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0); // 화면 아래에서 시작
                    const end = Offset.zero;
                    const curve = Curves.easeOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Container(
              width: 300,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [AppTheme.cardShadow],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단 정보 (서비스 유형, 평점)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 서비스 유형 뱃지
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
                            review['serviceNm'] ?? '서비스',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        // 별점
                        Row(
                          children: [
                            ...List.generate(starCount, (i) => const Icon(
                              Icons.star,
                              color: AppTheme.warning,
                              size: 16,
                            )),
                            ...List.generate(5 - starCount, (i) => Icon(
                              Icons.star_border,
                              color: AppTheme.subtleText,
                              size: 16,
                            )),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 금액 정보
                    Text(
                      '$formattedAmount원',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 리뷰 내용
                    Expanded(
                      child: Text(
                        review['contents'] ?? '',
                        style: TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 리뷰어 정보 및 날짜
                    Row(
                      children: [
                        // 아바타 (옵션)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 14,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // 파트너명
                        Text(
                          review['parterNm'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryText,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // 구분선
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppTheme.subtleText,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // 날짜
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: AppTheme.subtleText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}