import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class PartnerReviewTab extends StatefulWidget {
  final String partnerName;
  final List<Map<String, dynamic>> reviews;
  final List<String> serviceTypes;

  const PartnerReviewTab({
    Key? key,
    required this.partnerName,
    required this.reviews,
    required this.serviceTypes,
  }) : super(key: key);

  @override
  _PartnerReviewTabState createState() => _PartnerReviewTabState();
}

class _PartnerReviewTabState extends State<PartnerReviewTab> {
  String _selectedFilter = '최신순';
  int _displayedReviewCount = 5; // 초기에 보여줄 리뷰 개수
  bool _isServiceRatingExpanded = false; // 서비스 유형별 평가 확장 상태

  @override
  Widget build(BuildContext context) {
    // 리뷰 데이터를 사용
    final List<Map<String, dynamic>> reviews = widget.reviews;

    // 현재 표시할 리뷰 목록 (처음 5개 또는 설정된 개수만큼)
    final List<Map<String, dynamic>> displayedReviews =
    widget.reviews.take(_displayedReviewCount).toList();



    // 별점 통계 계산
    double averageRating = reviews.isEmpty
        ? 0.0
        : reviews.fold(0.0, (sum, review) => sum + (review['rating'] as double)) / reviews.length;

    Map<double, int> ratingCounts = {
      5.0: 0,
      4.5: 0,
      4.0: 0,
      3.5: 0,
      3.0: 0,
    };

    for (var review in reviews) {
      double rating = review['rating'] as double;
      ratingCounts[rating] = (ratingCounts[rating] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 리뷰 통계 카드
          _buildReviewStatsCard(reviews, averageRating, ratingCounts),

          // 리뷰 목록
          reviews.isEmpty
              ? _buildEmptyReviewState()
              : ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: displayedReviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final review = displayedReviews[index];
              return _buildReviewCard(review);
            },
          ),

          const SizedBox(height: 16),

          // 더보기 버튼
          _buildSeeMoreButton(),


        ],
      ),
    );
  }

  Widget _buildReviewStatsCard(List<Map<String, dynamic>> reviews, double averageRating, Map<double, int> ratingCounts) {
    final int total = reviews.length;

    // 서비스 유형별 평점 계산
    Map<String, List<double>> serviceTypeRatings = {};
    for (var review in reviews) {
      String serviceType = review['serviceType'] as String;
      double rating = review['rating'] as double;
      if (!serviceTypeRatings.containsKey(serviceType)) {
        serviceTypeRatings[serviceType] = [];
      }
      serviceTypeRatings[serviceType]!.add(rating);
    }

    // 서비스 유형별 평균 평점
    Map<String, double> averageServiceRatings = {};
    serviceTypeRatings.forEach((key, value) {
      averageServiceRatings[key] = value.reduce((a, b) => a + b) / value.length;
    });

    // 가장 평점이 높은 서비스 유형
    String? bestService;
    double highestRating = 0;
    averageServiceRatings.forEach((key, value) {
      if (value > highestRating) {
        highestRating = value;
        bestService = key;
      }
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '전체 리뷰 요약',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${reviews.length}개 리뷰',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 메인 통계 섹션
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 평균 평점 - 더 시각적으로 구현
              Container(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 원형 프로그레스 바로 평점 표시
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: averageRating / 5,
                            strokeWidth: 8,
                            backgroundColor: AppTheme.subtleText.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getRatingColor(averageRating),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            Text(
                              '/ 5.0',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 별점 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < averageRating.floor() ? Icons.star :
                          (index == averageRating.floor() && averageRating % 1 > 0) ? Icons.star_half : Icons.star_border,
                          color: AppTheme.warning,
                          size: 18,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // 별점 분포
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5.0, ratingCounts[5.0] ?? 0, total),
                    const SizedBox(height: 8),
                    _buildRatingBar(4.5, ratingCounts[4.5] ?? 0, total),
                    const SizedBox(height: 8),
                    _buildRatingBar(4.0, ratingCounts[4.0] ?? 0, total),
                    const SizedBox(height: 8),
                    _buildRatingBar(3.5, ratingCounts[3.5] ?? 0, total),
                    const SizedBox(height: 8),
                    _buildRatingBar(3.0, ratingCounts[3.0] ?? 0, total),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 서비스 유형별 섹션 - 접을 수 있는 위젯으로 구현
          if (averageServiceRatings.isNotEmpty) ...[
            Divider(),
            const SizedBox(height: 16),

            // 확장 가능한 섹션 헤더
            GestureDetector(
              onTap: () {
                setState(() {
                  _isServiceRatingExpanded = !_isServiceRatingExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '서비스 유형별 평가',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    Row(
                      children: [
                        // 가장 높은 평가 서비스를 헤더에 표시 (닫혀있을 때만)
                        if (!_isServiceRatingExpanded && bestService != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '최고 평점: $bestService',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.success,
                              ),
                            ),
                          ),
                        // 확장 아이콘
                        Icon(
                          _isServiceRatingExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppTheme.secondaryText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 확장된 콘텐츠
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isServiceRatingExpanded
                  ? (averageServiceRatings.length * 40 + 80).toDouble()
                  : 0, // 닫혔을 때는 높이가 0
              curve: Curves.easeInOut,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // 서비스별 평점 리스트
                    ...averageServiceRatings.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryText,
                                fontWeight: entry.key == bestService ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < entry.value.floor() ? Icons.star :
                                  (index == entry.value.floor() && entry.value % 1 > 0) ? Icons.star_half : Icons.star_border,
                                  color: AppTheme.warning,
                                  size: 14,
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                entry.value.toStringAsFixed(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getRatingColor(entry.value),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )).toList(),

                    // 가장 높은 평가 서비스에 대한 특별 표시
                    if (bestService != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: AppTheme.success,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '가장 높은 평가: $bestService (${highestRating.toStringAsFixed(1)}점)',
                                style: TextStyle(
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

// 평점에 따른 색상 반환
  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.amber;
    if (rating >= 3.0) return Colors.orange;
    return Colors.redAccent;
  }

// 향상된 레이팅 바
  Widget _buildRatingBar(double rating, int count, int total) {
    final double percentage = total > 0 ? count / total : 0;

    return Row(
      children: [
        // 별점 아이콘으로 표시
        Row(
          children: [
            Icon(Icons.star, size: 14, color: AppTheme.warning),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Stack(
            children: [
              // 배경 바
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.subtleText.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // 채워진 바 - 그라디언트 사용
              Container(
                height: 10,
                width: percentage * MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.warning.withOpacity(0.7),
                      AppTheme.warning,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        // 개수와 백분율 표시
        Text(
          '$count (${(percentage * 100).toStringAsFixed(0)}%)',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        // Border 설정 제거
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 리뷰 헤더
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  review['userName'].substring(0, 1),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: context.defaultPadding / 1.5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['userName'],
                    style: context.subtitleStyle(),
                  ),
                  SizedBox(height: context.smallPadding / 2),
                  Row(
                    children: [
                      Text(
                        review['serviceType'],
                        style: context.captionStyle(),
                      ),
                      SizedBox(width: context.smallPadding),
                      Text(
                        '•',
                        style: TextStyle(
                          color: AppTheme.subtleText,
                        ),
                      ),
                      SizedBox(width: context.smallPadding),
                      Text(
                        review['date'],
                        style: context.captionStyle(),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              if (review['verified'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 12,
                        color: AppTheme.success,
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Text(
                        '인증됨',
                        style: context.labelSubStyle(),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: context.smallPadding),

          // 별점
          Row(
            children: List.generate(5, (index) {
              double rating = review['rating'] as double;
              return Icon(
                index < rating.floor() ? Icons.star :
                (index == rating.floor() && rating % 1 > 0) ? Icons.star_half : Icons.star_border,
                color: AppTheme.warning,
                size: 16,
              );
            }),
          ),

          SizedBox(height: context.smallPadding),

          // 리뷰 내용
          Text(
            review['content'],
            style: context.bodyStyle(),
          ),

          SizedBox(height: context.smallPadding),

          // 하단 액션
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // 도움됨 로직
                  context.showSnackBar('도움이 되었다고 평가했습니다.');
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: AppTheme.secondaryText,
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      '도움됨',
                      style: context.captionStyle(),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.defaultPadding),
              GestureDetector(
                onTap: () {
                  // 신고 로직
                  context.showSnackBar('신고 기능은 준비 중입니다.');
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.report_outlined,
                      size: 16,
                      color: AppTheme.secondaryText,
                    ),
                    SizedBox(width: context.smallPadding / 2),
                    Text(
                      '신고',
                      style: context.captionStyle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviewState() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 48,
            color: AppTheme.subtleText,
          ),
          SizedBox(height: context.defaultPadding),
          Text(
            '아직 리뷰가 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 리뷰를 작성해 보세요!',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.showSnackBar('리뷰 작성 기능은 준비 중입니다.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('리뷰 작성하기'),
          ),
        ],
      ),
    );
  }

  //더보기 버튼
  Widget _buildSeeMoreButton() {
    // 전체 리뷰 개수보다 현재 표시된 리뷰 개수가 작은 경우에만 버튼 표시
    if (_displayedReviewCount < widget.reviews.length) {
      return Center(
        child: TextButton(
          onPressed: () {
            setState(() {
              // 5개씩 추가
              _displayedReviewCount += 5;

              // 전체 리뷰 개수를 초과하지 않도록 조정
              if (_displayedReviewCount > widget.reviews.length) {
                _displayedReviewCount = widget.reviews.length;
              }
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              side: BorderSide(color: AppTheme.primaryColor),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '리뷰 더보기 (${widget.reviews.length - _displayedReviewCount}개 남음)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: context.smallPadding),
              Icon(
                Icons.arrow_forward,
                size: 18,
              ),
            ],
          ),
        ),
      );
    } else {
      // 더 이상 볼 리뷰가 없으면 아무것도 표시하지 않음
      return const SizedBox.shrink();
    }
  }
}