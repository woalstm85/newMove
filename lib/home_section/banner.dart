import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import 'banner_free.dart';
import 'banner_new_user.dart';
import 'banner_safe.dart';

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
    // 배너에 대한 샘플 데이터
    final List<Map<String, dynamic>> banners = [
      {
        'title': '신규 가입자 프로모션',
        'description': '신규 가입자에게 첫 이사 서비스 10% 할인 혜택을 드립니다',
        'color': const [Color(0xFF8864EF), Color(0xFF9B87EF)], // accentColor(보라색) 사용
        'icon': Icons.local_offer_outlined,
      },
      {
        'title': '무료 견적 서비스',
        'description': '이사 전 무료 방문 견적을 통해 정확한 견적을 확인하세요',
        'color': const [Color(0xFFFF9045), Color(0xFFFFAB45)], // secondaryColor(주황색) 유지
        'icon': Icons.calculate_outlined,
      },
      {
        'title': '안전한 이사 보장',
        'description': '손상 물품에 대한 보상 서비스로 안전한 이사를 약속합니다',
        'color': const [Color(0xFF5C6BC0), Color(0xFF7986CB)], // 인디고 계열로 변경
        'icon': Icons.shield_outlined,
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

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: banner['color'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      // 배너 컨텐츠
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              banner['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner['description'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),

                            ElevatedButton(
                              onPressed: () {
                                // 배너 인덱스에 따라 다른 페이지로 이동
                                if (bannerIndex == 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const NewUserPromotionScreen()),
                                  );
                                } else if (bannerIndex == 1) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const FreeQuoteScreen()),
                                  );
                                } else if (bannerIndex == 2) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SafeMovingScreen()),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: banner['color'][0],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                '자세히 보기',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 배너 아이콘
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              banner['icon'] as IconData,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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