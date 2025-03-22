import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import './review_analysis_widget.dart';
import '../utils/ui_extensions.dart';

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

  @override
  Widget build(BuildContext context) {
    // 리뷰 데이터를 사용
    final List<Map<String, dynamic>> reviews = widget.reviews;

    // 현재 표시할 리뷰 목록 (처음 5개 또는 설정된 개수만큼)
    final List<Map<String, dynamic>> displayedReviews =
    widget.reviews.take(_displayedReviewCount).toList();


// AI 리뷰 분석 위젯 추가
    final aiReviewAnalysis = ReviewAnalysisWidget(
      reviews: widget.reviews,
      partnerId: widget.partnerName,
    );

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

          aiReviewAnalysis,
          // 리뷰 통계 카드
          _buildReviewStatsCard(reviews, averageRating, ratingCounts),

          SizedBox(height: context.defaultPadding),

          // 리뷰 필터 섹션
          _buildFilterSection(),

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

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '전체 리뷰',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 평균 평점
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.floor() ? Icons.star :
                        (index == averageRating.floor() && averageRating % 1 > 0) ? Icons.star_half : Icons.star_border,
                        color: AppTheme.warning,
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reviews.length}개의 리뷰',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ],
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
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 18,
            color: AppTheme.secondaryText,
          ),
          SizedBox(width: context.smallPadding),
          DropdownButton<String>(
            value: _selectedFilter,
            underline: Container(),
            icon: Icon(Icons.arrow_drop_down, color: AppTheme.secondaryText),
            items: <String>['최신순', '평점 높은순', '평점 낮은순']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: context.bodyStyle(),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedFilter = newValue;
                  // 여기에서 실제 필터링 로직을 구현할 수 있음
                });
              }
            },
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              // 리뷰 작성 로직 구현
              context.showSnackBar('리뷰 작성 기능은 준비 중입니다.');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '리뷰 작성하기',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(double rating, int count, int total) {
    final double percentage = total > 0 ? count / total : 0;

    return Row(
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryText,
          ),
        ),
        SizedBox(width: context.smallPadding),
        Expanded(
          child: Stack(
            children: [
              // 배경 바
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.subtleText.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // 채워진 바
              Container(
                height: 8,
                width: percentage * MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: AppTheme.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: context.smallPadding),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: context.cardDecoration(borderColor: AppTheme.borderColor),
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