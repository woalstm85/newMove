import 'dart:async';
import 'package:flutter/material.dart';
import '../home_section/move_register.dart';
import '../home_section/banner.dart';
import '../home_section/bottom_banner.dart';
import '../home_section/review.dart';
import '../home_section/partner.dart';
import '../home_section/partner_info.dart';
import '../home_section/story.dart';
import '../theme/theme_constants.dart';
import '../api_service.dart';
import 'notification_screen.dart';
import '../utils/ui_extensions.dart';
import './object_detection_screen.dart';


class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> preloadedData;

  const HomeScreen({super.key, required this.preloadedData});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  late PageController _pageController;
  late Timer _timer;
  bool _isLoading = false; // 이미 로드되었으므로 기본값은 false
  List<dynamic> _reviews = [];
  List<dynamic> _partners = [];
  List<dynamic> _stories = [];

  @override
  void initState() {
    super.initState();

    // 무한 스크롤을 위해 큰 숫자의 중간에서 시작
    int initialPage = 5000;
    _pageController = PageController(initialPage: initialPage);
    _currentPage = initialPage % 3; // 3은 배너의 총 개수

// 5초마다 배너 페이지를 자동으로 전환
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      _pageController.nextPage(
        duration: AppTheme.animationDuration, // 애니메이션 지속시간
        curve: AppTheme.animationCurve,
      );
    });

    // 미리 로드된 데이터 사용
    _initializePreloadedData();
  }

  // 미리 로드된 데이터 초기화
  void _initializePreloadedData() {
    setState(() {
      _reviews = widget.preloadedData['reviews'] ?? [];
      _partners = widget.preloadedData['partners'] ?? [];
      _stories = widget.preloadedData['stories'] ?? [];
    });
  }

  // 데이터 새로 고침 함수 (필요할 때만 사용)
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        ApiService.fetchReviews(),
        ApiService.fetchPartnerList(),
        ApiService.fetchStoryList(),
      ]);

      setState(() {
        _reviews = results[0];
        _partners = results[1];
        _stories = results[2];
        _isLoading = false;
      });
    } catch (e) {
      print('데이터 새로 고침 중 오류 발생: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 왼쪽 박스의 전체 높이를 지정합니다.
    double leftBoxHeight = 230;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 환영 메시지
            SliverToBoxAdapter(
              child: _buildWelcomeSection(),
            ),

            // 이사 등록 및 배너 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMoveRegisterCard(leftBoxHeight, context),
                    const SizedBox(height: 25),
                    _buildBannerSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // 파트너 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildSectionHeader(
                        AppCopy.monthlyPartnerTitle,
                        null,
                        null
                    ),
                    const SizedBox(height: 16),
                    _buildPartnerInfoCard(context),
                    const SizedBox(height: 16),
                    CircleSlider(
                      partners: _partners,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),

            // 리뷰 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildSectionHeader(
                        AppCopy.reviewSectionTitle,
                        AppCopy.viewMoreReviews,
                            () {
                          // 모든 리뷰 보기 페이지로 이동
                        }
                    ),

                    ReviewSlider(
                      reviews: _reviews,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // 스토리 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    _buildSectionHeader(
                        AppCopy.monthlyStoryTitle,
                        null,
                        null
                    ),
                    const SizedBox(height: 15),
                    StorySlider(
                      stories: _stories,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),


            SliverToBoxAdapter(
              child: Column(
                  children: [
                    const BottomBanner(),
                    const SizedBox(height: 20),
                  ],
                ),

            ),

            // 회사 정보 섹션
            SliverToBoxAdapter(
              child: _buildCompanyInfoSection(),
            ),
          ],
        ),
      ),
    );
  }

  // AppBar 위젯
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.home_outlined, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Text(
            '디딤돌',
            style: AppTheme.headingStyle.copyWith(
              fontSize: 20,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.scaffoldBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.notifications_none_outlined, color: AppTheme.primaryText),
              // 읽지 않은 알림 표시
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppTheme.warning,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 10,
                    minHeight: 10,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                const NotificationScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); // 오른쪽에서 시작
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
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                const ObjectDetectionScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); // 오른쪽에서 시작
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
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(Icons.person_outline, color: AppTheme.primaryColor, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  // 환영 메시지 섹션
  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요!',
            style: AppTheme.headingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            AppCopy.trustStatement,
            style: AppTheme.bodyTextStyle.copyWith(
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

// 이사 등록 카드
  Widget _buildMoveRegisterCard(double height, BuildContext context) {
    return LeftBox(height: height);
  }

  // 배너 섹션
  Widget _buildBannerSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: BannerSection(
          currentPage: _currentPage,
          pageController: _pageController,
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
        ),
      ),
    );
  }

  // 섹션 헤더 (제목 및 더보기 버튼)
  Widget _buildSectionHeader(String title, String? viewMoreText, Function()? onViewMoreTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.subheadingStyle,
        ),
        if (viewMoreText != null && onViewMoreTap != null)
          TextButton(
            onPressed: onViewMoreTap,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
            ),
            child: Row(
              children: [
                Text(
                  viewMoreText,
                  style: AppTheme.captionStyle.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // 파트너 정보 카드
  Widget _buildPartnerInfoCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const PartnerInfoScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0); // 화면 위에서 시작
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.accentColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: AppTheme.accentColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppCopy.partnerSelectionInfo,
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppCopy.partnerQualityPromise,
                    style: TextStyle(
                      color: AppTheme.secondaryText,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.accentColor,
            ),
          ],
        ),
      ),
    );
  }

  // 회사 정보 섹션
  Widget _buildCompanyInfoSection() {
    return Container(
      width: double.infinity,
      color: AppTheme.primaryColor.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.business_outlined,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              AppCopy.companyMotto,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
          const SizedBox(height: 24),
          _buildCompanyDetails(),
          const SizedBox(height: 24),
          _buildFooterSection(),
        ],
      ),
    );
  }

  // 회사 상세 정보
  Widget _buildCompanyDetails() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppCopy.companyName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: AppTheme.primaryText,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: AppTheme.secondaryText),
              SizedBox(width: 8),
              Text(
                "대표이사: 홍길동",
                style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
              ),
            ],
          ),
          // 기타 회사 정보 항목들
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.business_outlined, size: 14, color: AppTheme.secondaryText),
              SizedBox(width: 8),
              Text(
                "사업자번호: 123-45-56789",
                style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
              ),
            ],
          ),
          // ... (이하 회사 정보 항목들)
          SizedBox(height: 24),
          Text(
            "디딤돌은 파트너와 이용자 간의 거래를 중개하는 플랫폼 서비스를 제공하며, 거래의 직접적인 당사자가 아닙니다. 따라서 개별 서비스에 대한 계약 체결 및 이로 인한 사고에 대한 책임은 파트너와 소비자에게 있습니다. 다만, 디딤돌은 이용자 간 분쟁 발생 시, 분쟁 해결을 위해 중재하거나 조정할 수 있습니다.",
            style: TextStyle(
              color: AppTheme.subtleText,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 푸터 섹션
  Widget _buildFooterSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.facebook_outlined),
                color: AppTheme.secondaryText,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline),
                color: AppTheme.secondaryText,
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.language_outlined),
                color: AppTheme.secondaryText,
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "© 2024 디딤돌 Co., Ltd. All rights reserved.",
          style: TextStyle(
            color: AppTheme.subtleText,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}