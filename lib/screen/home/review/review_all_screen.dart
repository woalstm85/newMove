import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MoveSmart/screen/home/review/review_detail.dart';
import 'package:MoveSmart/screen/home/review/api/review_api_service.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

class AllReviewsScreen extends StatefulWidget {
  const AllReviewsScreen({super.key});

  @override
  _AllReviewsScreenState createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  final List<String> _filters = ['최신순', '평점 높은순', '평점 낮은순'];
  String _selectedFilter = '최신순';
  List<dynamic> _reviews = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  // 임의로 이미지 개수 결정하는 함수 (실제 구현에서는 필요 없음)
  int _getImageCount(int id) {
    // ID를 이용해 1~3 사이의 값 생성
    return 1 + (id % 3);
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // 기존 API를 사용하여 모든 리뷰 불러오기
      final reviews = await ReviewService.fetchReviews();

      // 필터 적용 (클라이언트 측에서 처리)
      List<dynamic> filteredReviews = _sortReviews(reviews);

      setState(() {
        _reviews = filteredReviews;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      debugPrint('리뷰 로드 중 오류: $e');
    }
  }

  List<dynamic> _sortReviews(List<dynamic> reviews) {
    List<dynamic> sortedReviews = List.from(reviews);

    switch (_selectedFilter) {
      case '평점 높은순':
        sortedReviews.sort((a, b) {
          int aRating = a['startCnt'] as int? ?? 0;
          int bRating = b['startCnt'] as int? ?? 0;
          return bRating.compareTo(aRating);
        });
        break;
      case '평점 낮은순':
        sortedReviews.sort((a, b) {
          int aRating = a['startCnt'] as int? ?? 0;
          int bRating = b['startCnt'] as int? ?? 0;
          return aRating.compareTo(bRating);
        });
        break;
      case '최신순':
      default:
        sortedReviews.sort((a, b) {
          String aDate = a['serviceDt'] as String? ?? '';
          String bDate = b['serviceDt'] as String? ?? '';
          if (aDate.isEmpty || bDate.isEmpty) return 0;
          return DateTime.parse(bDate).compareTo(DateTime.parse(aDate));
        });
        break;
    }

    return sortedReviews;
  }

  void _onFilterChanged(String? value) {
    if (value != null && value != _selectedFilter) {
      setState(() {
        _selectedFilter = value;
        _reviews = _sortReviews(_reviews);
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          '모든 리뷰',
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
        child: Column(
          children: [
            // 필터 선택 섹션
            _buildFilterSection(),

            // 리뷰 목록
            Expanded(
              child: _hasError
                  ? _buildErrorState()
                  : RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.primaryColor,
                child: _isLoading
                    ? _buildLoadingState()
                    : _reviews.isEmpty
                    ? _buildEmptyState()
                    : _buildReviewsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '전체 ${_reviews.length}개',
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                style: TextStyle(color: AppTheme.primaryText, fontSize: 14),
                items: _filters.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: _onFilterChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final review = _reviews[index];
        final int id = review['id'] ?? 0;

        int starCount = review['startCnt'] ?? 0;

        // 금액 포맷팅
        String formattedAmount = review['amount'] != null
            ? NumberFormat('#,###').format(review['amount'])
            : '';

        // 날짜 포맷팅
        String formattedDate = review['serviceDt'] != null
            ? DateFormat('yyyy.MM').format(DateTime.parse(review['serviceDt']))
            : '';

        // ID를 사용해 임의로 이미지 개수 결정 (1~3개)
        int imageCount = _getImageCount(id);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ReviewDetailScreen(reviewId: id.toString()),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              boxShadow: [AppTheme.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단부 - 서비스 유형 및 날짜
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                              review['serviceNm'] ?? '서비스',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: AppTheme.subtleText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ...List.generate(
                              starCount,
                                  (i) => const Icon(Icons.star, color: AppTheme.warning, size: 14)
                          ),
                          ...List.generate(
                              5 - starCount,
                                  (i) => Icon(Icons.star_border, color: AppTheme.subtleText, size: 14)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 이미지 갤러리 섹션 (1~3개의 이미지)
                _buildImageGallery(imageCount, id),

                // 리뷰 내용 섹션
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 금액 정보
                      Text(
                        '$formattedAmount원',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 리뷰 내용
                      Text(
                        review['contents'] ?? '',
                        style: TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 16),

                      // 리뷰어 정보
                      Row(
                        children: [
                          // 사용자 아바타
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // 사용자 정보
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['parterNm'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryText,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${review['buildingNm'] ?? '건물 정보 없음'}',
                                style: TextStyle(
                                  color: AppTheme.subtleText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // 인증 배지
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
                                  const SizedBox(width: 4),
                                  Text(
                                    '인증됨',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.success,
                                    ),
                                  ),
                                ],
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
        );
      },
    );
  }

  // 이미지 갤러리 위젯 - 이미지 개수에 따라 레이아웃 조정
  Widget _buildImageGallery(int count, int reviewId) {
    // 갤러리 높이
    final double galleryHeight = 180;

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

  Widget _buildLoadingState() {
    return Center(
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: AppTheme.subtleText,
          ),
          const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            '리뷰를 불러오는 중 오류가 발생했습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('다시 시도'),
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