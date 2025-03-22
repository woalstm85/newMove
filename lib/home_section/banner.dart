import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import 'banner_free.dart';
import 'banner_new_user.dart';
import 'banner_safe.dart';
import 'banner_detail.dart';

class BannerSection extends StatelessWidget {
  final int currentPage;
  final PageController pageController;
  final Function(int) onPageChanged;

  const BannerSection({
    Key? key,
    required this.currentPage,
    required this.pageController,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 배너에 대한 데이터 - 이미지 경로와 텍스트 정보
    final List<Map<String, dynamic>> banners = [
      {
        'imagePath': 'assets/banners/banner1.png', // 스타벅스 배너 이미지 경로
        'title': '친구 초대하고,\n커피 한잔의 여유를!',
        'subtitle': '스타벅스 아메리카노 증정!',
        'buttonText': '친구 초대하기',
        'titleColor': Colors.white,
        'subtitleColor': Colors.white.withOpacity(0.9),
        'buttonColor': Colors.white,
        'buttonTextColor': Color(0xFF00704A), // 스타벅스 녹색
      },
      {
        'imagePath': 'assets/banners/banner2.png', // 리뷰 작성 보라색 배너 이미지 경로
        'title': '이사 후기 쓰면\n선물이 팡팡!',
        'subtitle': '편의점 상품권\n배달의민족 상품권 증정!',
        'buttonText': '리뷰 작성하기',
        'titleColor': Colors.white,
        'subtitleColor': Colors.white.withOpacity(0.8),
        'buttonColor': Colors.white,
        'buttonTextColor': Colors.orange, // 보라색
      },
      {
        'imagePath': 'assets/banners/banner3.png', // 리뷰 작성 노란색 배너 이미지 경로
        'title': '이사 인증샷 올리고\n치킨 먹자!',
        'subtitle': '이사 후 인증샷을 SNS에 공유\n영화관람권 등 증정!',
        'buttonText': '리뷰 작성하고 선물 받기',
        'titleColor': Colors.white,
        'subtitleColor': Colors.white.withOpacity(0.8),
        'buttonColor': Colors.white,
        'buttonTextColor': Color(0xFF9747FF),
      },
    ];

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // 배너 슬라이더
          PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              onPageChanged(index % banners.length);
            },
            itemBuilder: (context, index) {
              final bannerIndex = index % banners.length;
              final banner = banners[bannerIndex];

              return Stack(
                fit: StackFit.expand,
                children: [
                  // 배경 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    child: Image.asset(
                      banner['imagePath'] as String,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 배너 내용
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 제목
                        Text(
                          banner['title'] as String,
                          style: TextStyle(
                            color: banner['titleColor'] as Color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 부제목
                        Text(
                          banner['subtitle'] as String,
                          style: TextStyle(
                            color: banner['subtitleColor'] as Color,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),

                        // 버튼
                        ElevatedButton(
                          onPressed: () {
                            // 모든 배너에 대해 BannerDetailScreen으로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BannerDetailScreen(bannerIndex: bannerIndex),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: banner['buttonColor'] as Color,
                            foregroundColor: banner['buttonTextColor'] as Color,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            banner['buttonText'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // 하단 인디케이터
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: currentPage % banners.length == index ? 20.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    decoration: BoxDecoration(
                      color: currentPage % banners.length == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
