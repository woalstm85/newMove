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

  // 현재 세션에서 모달이 표시되었는지 추적하는 정적 변수 추가
  static bool _hasShownInCurrentSession = false;

  // 모달 표시 여부 확인
  static Future<bool> shouldShowBanner() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String? lastSkippedDate = prefs.getString('last_skipped_banner_date');

    // 오늘 하루 보지 않기를 선택했으면 표시하지 않음
    if (lastSkippedDate == today) {
      return false;
    }

    // 단순 닫기를 누른 후에는 화면 이동 후 다시 표시되도록 하기 위해
    // 현재 세션에서 이미 표시된 경우를 체크하지 않음 (항상 true 반환)
    return true;
  }

  // 모달이 표시되었는지 확인하는 메서드 추가
  static bool hasShownInCurrentSession() {
    return _hasShownInCurrentSession;
  }

  // 현재 세션에서 모달 표시 상태 초기화 (화면 이동 시 호출)
  static void resetSessionFlag() {
    _hasShownInCurrentSession = false;
  }

  // "오늘 하루 보지 않기" 설정 저장
  static Future<void> skipForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('last_skipped_banner_date', today);
  }

  // 모달 배너 표시 함수
  static Future<void> show(BuildContext context) async {
    // 표시 여부 확인
    if (!await shouldShowBanner()) return;

    // 이미 현재 세션에서 표시되었다면 또 표시하지 않음
    if (_hasShownInCurrentSession) return;

    // 화면이 마운트된 상태인지 확인
    if (!context.mounted) return;

    // 현재 세션에서 표시 플래그 설정
    _hasShownInCurrentSession = true;

    // 페이지 컨트롤러 초기화
    final PageController pageController = PageController(initialPage: 0);
    int currentPage = 0;

    // 디바이스의 하단 여백 계산 (안전 영역)
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // 바텀 시트가 스크린 위쪽까지 확장되는 것을 막음 (높이 축소)
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5, // 70%에서 50%로 축소
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Container(
                  // 높이를 화면의 45%로 설정하여 더 작게 조정
                  height: MediaQuery.of(context).size.height * 0.45,
                  decoration: BoxDecoration(
                    color: Colors.transparent, // 배경색을 투명하게 변경
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
                  child: Stack(
                    children: [
                      // 이미지 영역 (하단 버튼 영역 제외)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 70, // 하단 버튼 영역 높이만큼 공간 확보
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
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

                      // 드래그 핸들 (모달 상단에 위치)
                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      // 인디케이터 (하단 이미지 영역 아래쪽에 위치)
                      Positioned(
                        bottom: 80, // 버튼 영역 바로 위
                        left: 0,
                        right: 0,
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
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 하단 버튼 영역 (흰색 배경)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 70, // 버튼 영역 높이
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            // 하단 모서리의 borderRadius 제거
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.secondaryText,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(40, 36),
                                ),
                                child: const Text(
                                  '오늘 하루 보지 않기',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              // 닫기 버튼 (일반 텍스트로 변경)
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(40, 36),
                                ),
                                child: const Text(
                                  '닫기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
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