import 'package:flutter/material.dart';
import 'package:MoveSmart/screen/navigation/bottom_navigation.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

class SplashScreen extends StatefulWidget {
  final Map<String, dynamic> preloadedData;

  const SplashScreen({Key? key, required this.preloadedData}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // 로고 애니메이션 컨트롤러
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;

  // 텍스트 애니메이션 컨트롤러
  late AnimationController _textController;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;

  // 슬로건 애니메이션 컨트롤러
  late AnimationController _sloganController;
  late Animation<double> _sloganOpacityAnimation;

  // 하이라이트 효과 애니메이션
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;

  @override
  void initState() {
    super.initState();

    // 로고 애니메이션 설정
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_logoController);

    // 텍스트 애니메이션 설정
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    // 슬로건 애니메이션 설정
    _sloganController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _sloganOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sloganController,
      curve: Curves.easeOut,
    ));

    // 하이라이트 효과 애니메이션
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _highlightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeIn,
    ));

    // 애니메이션 시퀀스 실행
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 로고 애니메이션 시작
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // 하이라이트 효과 시작
    await Future.delayed(const Duration(milliseconds: 500));
    _highlightController.forward();

    // 텍스트 애니메이션 시작
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();

    // 슬로건 애니메이션 시작
    await Future.delayed(const Duration(milliseconds: 200));
    _sloganController.forward();

    // 다음 화면으로 이동
    await Future.delayed(const Duration(milliseconds: 1500));
    _navigateToMainScreen();
  }

  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BottomNavigationBarWidget(
          initialIndex: 0,
          preloadedData: widget.preloadedData,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _sloganController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF558BFF), // 단색 배경으로 변경 (#558BFF)
        child: Stack(
          children: [
            // 하이라이트 효과
            AnimatedBuilder(
                animation: _highlightAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: -200 + (_highlightAnimation.value * 300),
                    right: -200 + (_highlightAnimation.value * 300),
                    child: Opacity(
                      opacity: 0.2 * _highlightAnimation.value,
                      child: Container(
                        width: 600,
                        height: 600,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.6),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.9],
                          ),
                        ),
                      ),
                    ),
                  );
                }
            ),

            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로고 애니메이션
                    ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset('assets/icon/app_icon.png'),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 영문 이름 (작은 글씨)
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textOpacityAnimation,
                        child: const Text(
                          'STEPPING STONE',
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 한글 이름 (큰 글씨)
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textOpacityAnimation,
                        child: const Text(
                          '디딤돌 이사',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 슬로건들
                    FadeTransition(
                      opacity: _sloganOpacityAnimation,
                      child: Column(
                        children: const [
                          Text(
                            '당신의 새로운 시작을 응원합니다',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '믿을 수 있는 이사, 디딤돌과 함께',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    // 로딩 인디케이터
                    FadeTransition(
                      opacity: _sloganOpacityAnimation,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
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
    );
  }
}