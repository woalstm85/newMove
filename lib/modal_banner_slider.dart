import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

class ModalBannerSlider {
  // 배너 아이템 데이터
  static final List<Map<String, String>> bannerItems = [
    {
      'image': 'assets/images/banners/large_banner1.png',
      'title': '디딤돌 이사',
      'description': '최고의 이사앱을 이용하세요.',
    },
    {
      'image': 'assets/images/banners/large_banner2.png',
      'title': '친구 초대하삼',
      'description': '친구초대하면 선물줄껀데?',
    },
    {
      'image': 'assets/images/banners/large_banner3.png',
      'title': '최고의 서비스',
      'description': '일단써봐! 엄청 편할걸?',
    },
  ];

  // 모달 표시 여부 확인
  static Future<bool> shouldShowBanner() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String? lastSkippedDate = prefs.getString('last_skipped_banner_date');

    // 오늘 날짜와 마지막으로 건너뛴 날짜가 다르면 모달 표시
    return lastSkippedDate != today;
  }

  // "오늘 하루 보지 않기" 설정 저장
  static Future<void> skipForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('last_skipped_banner_date', today);
  }

  // 모달 배너 표시 함수
  static Future<void> show(BuildContext context) async {
    if (!await shouldShowBanner()) return;

    // 화면이 마운트된 상태인지 확인
    if (!context.mounted) return;

    // 페이지 컨트롤러 초기화
    final PageController pageController = PageController(initialPage: 0);
    int currentPage = 0;

    // 디바이스의 하단 여백 계산 (안전 영역)
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // 바텀 시트가 스크린 위쪽까지 확장되는 것을 막음
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  // 높이를 화면의 60%로 설정하지만, 하단 패딩을 고려하여 조정
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 드래그 핸들
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // 배너 슬라이더
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: PageView.builder(
                              controller: pageController,
                              itemCount: bannerItems.length,
                              onPageChanged: (index) {
                                setModalState(() {
                                  currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // 배너 이미지
                                    Image.asset(
                                      bannerItems[index]['image']!,
                                      fit: BoxFit.cover,
                                    ),

                                    // 이미지 위에 그라데이션 오버레이
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.center,
                                          colors: [
                                            Colors.black.withOpacity(0.4),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),

                                    // 텍스트 콘텐츠
                                    Positioned(
                                      top: 20,
                                      left: 20,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bannerItems[index]['title']!,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(1, 1),
                                                  blurRadius: 3,
                                                  color: Color.fromARGB(128, 0, 0, 0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            bannerItems[index]['description']!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(1, 1),
                                                  blurRadius: 2,
                                                  color: Color.fromARGB(128, 0, 0, 0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // 인디케이터
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            bannerItems.length,
                                (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: currentPage == index ? 18.0 : 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(horizontal: 3.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                                color: currentPage == index
                                    ? AppTheme.primaryColor
                                    : AppTheme.secondaryText.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 하단 버튼 영역 - 하단 패딩 추가
                      Padding(
                        // 디바이스 하단 안전 영역만큼 패딩 추가
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 오늘 하루 보지 않기 버튼
                            TextButton(
                              onPressed: () async {
                                await skipForToday();

                                // 모달 닫기
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                '오늘 하루 보지 않기',
                                style: TextStyle(
                                  color: AppTheme.secondaryText,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            // 닫기 버튼
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('닫기'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
          ),
        );
      },
    );
  }
}