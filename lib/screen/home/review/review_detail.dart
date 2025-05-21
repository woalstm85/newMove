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

  // 임의로 이미지 개수 결정하는 함수 (실제 구현에서는 필요 없음)
  int _getImageCount(int id) {
    // ID를 이용해 1~3 사이의 값 생성
    return 1 + (id % 3);
  }

  // 이미지 갤러리 위젯 - 이미지 개수에 따라 레이아웃 조정
  Widget _buildImageGallery(int count, int reviewId) {
    // 갤러리 높이
    final double galleryHeight = 150;

    // 이미지가 없으면 빈 컨테이너 반환 (실제로는 발생하지 않음)
    if (count == 0) return const SizedBox.shrink();

    return SizedBox(
      height: galleryHeight,
      child: count == 1
      // 이미지가 1개인 경우
          ? _buildTappablePlaceholderImage(galleryHeight, 1, reviewId, 1)
      // 이미지가 2~3개인 경우
          : _buildMultipleTappablePlaceholderImages(count, galleryHeight, reviewId),
    );
  }

  // 클릭 가능한 단일 플레이스홀더 이미지
  Widget _buildTappablePlaceholderImage(double height, int index, int reviewId, int totalCount) {
    // 이미지 인덱스에 따라 색상 약간 다르게 (시각적 구분을 위해)
    final color = index % 2 == 0 ? Colors.grey.shade200 : Colors.grey.shade300;

    return GestureDetector(
      onTap: () {
        _showImageViewer(context, index, reviewId, totalCount);
      },
      child: Container(
        width: double.infinity,
        height: height,
        color: color,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 메인 아이콘
            Icon(
              Icons.image,
              size: 64,
              color: Colors.grey.shade400,
            ),

            // 왼쪽 상단에 이미지 번호 표시
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '이미지 $index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 클릭 가능함을 나타내는 아이콘 (우측 하단)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 여러 클릭 가능한 플레이스홀더 이미지 (2~3개)
  Widget _buildMultipleTappablePlaceholderImages(int count, double height, int reviewId) {
    if (count == 2) {
      // 2개 이미지 레이아웃 (좌우 분할)
      return Row(
        children: [
          Expanded(
            child: _buildTappablePlaceholderImage(height, 1, reviewId, count),
          ),
          const SizedBox(width: 2), // 이미지 사이 간격
          Expanded(
            child: _buildTappablePlaceholderImage(height, 2, reviewId, count),
          ),
        ],
      );
    } else {
      // 3개 이미지 레이아웃 (1개 좌측 크게, 2개 우측 위아래 분할)
      return Row(
        children: [
          // 좌측 큰 이미지
          Expanded(
            flex: 3,
            child: _buildTappablePlaceholderImage(height, 1, reviewId, count),
          ),
          const SizedBox(width: 2), // 이미지 사이 간격
          // 우측 두 개 이미지
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // 상단 이미지
                GestureDetector(
                  onTap: () {
                    _showImageViewer(context, 2, reviewId, count);
                  },
                  child: Container(
                    height: height / 2 - 1, // 간격 고려
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 30,
                          color: Colors.grey.shade400,
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '이미지 2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // 클릭 가능함을 나타내는 아이콘 (우측 하단)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2), // 이미지 사이 간격
                // 하단 이미지
                GestureDetector(
                  onTap: () {
                    _showImageViewer(context, 3, reviewId, count);
                  },
                  child: Container(
                    height: height / 2 - 1, // 간격 고려
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 30,
                          color: Colors.grey.shade400,
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '이미지 3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // 클릭 가능함을 나타내는 아이콘 (우측 하단)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  // 이미지 뷰어 다이얼로그 표시
  void _showImageViewer(BuildContext context, int imageIndex, int reviewId, int totalCount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(
          imageIndex: imageIndex,
          reviewId: reviewId,
          totalCount: totalCount,
        ),
      ),
    );
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

                        // 이미지 갤러리 (리뷰 ID가 있는 경우에만 표시)
                        if (review!['id'] != null)
                          Builder(
                            builder: (context) {
                              final int reviewId = review!['id'] is int
                                  ? review!['id']
                                  : int.parse(review!['id'].toString());
                              final int imageCount = _getImageCount(reviewId);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildImageGallery(imageCount, reviewId),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          ),

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

// 이미지 뷰어 화면
class ImageViewerScreen extends StatefulWidget {
  final int imageIndex;
  final int reviewId;
  final int totalCount;

  const ImageViewerScreen({
    Key? key,
    required this.imageIndex,
    required this.reviewId,
    required this.totalCount,
  }) : super(key: key);

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.imageIndex;
    _pageController = PageController(initialPage: widget.imageIndex - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            '이미지 ${_currentIndex}/${widget.totalCount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Stack(
            children: [
              // 이미지 페이지 뷰
              PageView.builder(
                controller: _pageController,
                itemCount: widget.totalCount,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index + 1;
                  });
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        color: (index % 2 == 0) ? Colors.grey.shade300 : Colors.grey.shade400,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 100,
                              color: Colors.grey.shade200,
                            ),
                            Text(
                              '이미지 ${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 하단 이미지 인디케이터
              if (widget.totalCount > 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.totalCount,
                          (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index + 1
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}