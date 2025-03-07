import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screen/bottom_navigation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './api_service.dart';

// 글로벌 변수로 미리 로드된 데이터를 저장
Map<String, dynamic> preloadedData = {
  'reviews': [],
  'partners': [],
  'stories': [],
};

void main() async {
  // 글로벌 에러 핸들링 설정
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  // 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 시스템 UI 설정
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // 화면 방향 설정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 날짜 형식을 초기화 (한글 로케일)
  await initializeDateFormatting('ko_KR', null);

  // 앱 설정 불러오기
  final prefs = await SharedPreferences.getInstance();
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final String language = prefs.getString('language') ?? 'ko_KR';
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  // 최초 실행 시 필요한 작업
  if (isFirstRun) {
    await prefs.setBool('isFirstRun', false);
  }

  // 앱 실행 전에 데이터 미리 로드
  await _preloadAppData();

  // 앱 실행
  runApp(MyApp(
    isDarkMode: isDarkMode,
    language: language,
  ));
}

// 스플래시 화면 동안 데이터 미리 로드하는 함수
Future<void> _preloadAppData() async {
  try {
    // 병렬로 API 호출
    final results = await Future.wait([
      ApiService.fetchReviews(),
      ApiService.fetchPartnerList(),
      ApiService.fetchStoryList(),
    ]);

    // 글로벌 변수에 저장
    preloadedData = {
      'reviews': results[0],
      'partners': results[1],
      'stories': results[2],
    };
  } catch (e) {
    print('데이터 미리 로드 중 오류 발생: $e');
    // 오류가 발생해도 앱은 계속 실행
  }
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;
  final String language;

  const MyApp({
    super.key,
    this.isDarkMode = false,
    this.language = 'ko_KR',
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomSplashScreen(preloadedData: preloadedData),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C3E50),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
          titleTextStyle: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      darkTheme: isDarkMode ? ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C3E50),
          brightness: Brightness.dark,
        ),
      ) : null,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  }
}

class CustomSplashScreen extends StatefulWidget {
  final Map<String, dynamic> preloadedData;

  const CustomSplashScreen({super.key, required this.preloadedData});

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    // 3초 후에 다음 화면으로 이동
    Future.delayed(const Duration(milliseconds: 3000), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BottomNavigationBarWidget(preloadedData: widget.preloadedData),
        ),
      );
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
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고 또는 아이콘
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.moving, // 앱 아이콘
                  size: 72,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 24),
              // 앱 이름
              const Text(
                "디딤돌",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),
              // 앱 설명
              Text(
                "당신의 이사, 좀 더 편하게",
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF2C3E50).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}