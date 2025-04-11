import 'package:flutter/material.dart';
import 'screen/navigation/bottom_navigation.dart';

class SplashScreen extends StatefulWidget {
  final Map<String, dynamic> preloadedData;

  const SplashScreen({Key? key, required this.preloadedData}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // 애니메이션 시작 및 완료 후 메인 화면으로 이동
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => BottomNavigationBarWidget(
              preloadedData: widget.preloadedData,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 스플래시 배경색
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 스플래시 이미지
              Image.asset('assets/splash/splash_icon.png', width: 180),
              const SizedBox(height: 24),

              // 영문 이름 (작은 글씨)
              const Text(
                'STEPPING STONE',
                style: TextStyle(
                  fontSize: 15,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),

              const SizedBox(height: 5),

              // 한글 이름 (큰 글씨)
              const Text(
                '디딤돌 이사',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),

              const SizedBox(height: 10),

              // 첫 번째 슬로건
              const Text(
                '당신의 새로운 시작을 응원합니다.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF95A5A6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}