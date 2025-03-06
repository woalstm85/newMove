import 'dart:async';
import 'package:flutter/material.dart';
import '../home_section/move_register.dart';
import '../home_section/banner.dart';
import '../home_section/review.dart';
import '../home_section/partner.dart';
import '../home_section/partner_info.dart';
import '../home_section/story.dart';
import '../modal/home_modal/move_type.dart';
import '../theme/theme_constants.dart'; // 새로 만든 테마 상수 임포트

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // 무한 스크롤을 위해 큰 숫자의 중간에서 시작
    int initialPage = 5000;
    _pageController = PageController(initialPage: initialPage);
    _currentPage = initialPage % 3; // 3은 배너의 총 개수

    // 5초마다 배너 페이지를 자동으로 전환
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      // 항상 다음 페이지로 이동 (무한 루프)
      _pageController.nextPage(
        duration: AppTheme.animationDuration,
        curve: AppTheme.animationCurve,
      );
    });
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
    double leftBoxHeight = 270;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground, // 새로운 배경색 적용
      appBar: AppBar(
        title: Row(
          children: [
            // 로고 또는 아이콘 추가
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
          // 알림 아이콘 추가
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: AppTheme.primaryText),
            onPressed: () {
              // 알림 기능 추가
            },
          ),
          // 사용자 프로필 아이콘 추가
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Icon(Icons.person_outline, color: AppTheme.primaryColor, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 환영 메시지 및 설명 문구 추가
            Padding(
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
            ),

            // 첫 번째 섹션: 상단 박스 및 슬라이더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이사 등록 카드
                  GestureDetector(
                    onTap: () {
                      // LeftBox를 클릭했을 때 모달 호출
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  MediaQuery.of(context).padding.bottom,
                            ),
                            child: const MovingTypeModal(),
                          );
                        },
                      );
                    },
                    child: LeftBox(height: leftBoxHeight),
                  ),
                  const SizedBox(height: 25),
                  // 배너 섹션 (개선된 디자인)
                  Container(
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
                  ),

                  const SizedBox(height: 32),

                  // 리뷰 섹션 제목 개선
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppCopy.reviewSectionTitle,
                        style: AppTheme.subheadingStyle,
                      ),
                      TextButton(
                        onPressed: () {
                          // 모든 리뷰 보기 페이지로 이동
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                        child: Row(
                          children: [
                            Text(
                              AppCopy.viewMoreReviews,
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
                  ),

                  const SizedBox(height: 16),

                  // 개선된 리뷰 슬라이더
                  const ReviewSlider(),

                  const SizedBox(height: 32),

                  // 파트너 섹션 헤더 개선
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppCopy.monthlyPartnerTitle,
                        style: AppTheme.subheadingStyle,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 파트너 선정 정보 컨테이너 개선
                  GestureDetector(
                    onTap: () {
                      // 파트너 선정 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PartnerInfoScreen()),
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
                  ),

                  const SizedBox(height: 16),
                  // 파트너 슬라이더
                  const CircleSlider(),
                  // 스토리 섹션 헤더 개선
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppCopy.monthlyStoryTitle,
                        style: AppTheme.subheadingStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 스토리 슬라이더
                  const StorySlider(),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 회사 정보 섹션 개선
            Container(
              width: double.infinity,
              color: AppTheme.primaryColor.withOpacity(0.05),
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Column(
                children: [
                  // 회사 로고 또는 아이콘 추가
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

                  // 회사 모토
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

                  // 회사 정보
                  const Padding(
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
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.assignment_outlined, size: 14, color: AppTheme.secondaryText),
                            SizedBox(width: 8),
                            Text(
                              "통신판매업신고: 2024-대한민국-10001호",
                              style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 14, color: AppTheme.secondaryText),
                            SizedBox(width: 8),
                            Text(
                              "화물자동차운송주선사업자: 제241234호",
                              style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: AppTheme.secondaryText),
                            SizedBox(width: 8),
                            Text(
                              "주소: 경기 부천시 원미구 조마루로385번길 80",
                              style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: AppTheme.secondaryText),
                            SizedBox(width: 8),
                            Text(
                              "대표번호: 1234-5678",
                              style: TextStyle(fontSize: 14, color: AppTheme.secondaryText),
                            ),
                          ],
                        ),
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
                  ),

                  const SizedBox(height: 24),

                  // 푸터 - 소셜 아이콘 및 앱 스토어 링크
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}