import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 글로벌 변수로 미리 로드된 데이터를 저장
Map<String, dynamic> preloadedData = {
  'reviews': [],
  'partners': [],
  'stories': [],
};

void main() async {
  // 기본 초기화
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

  await dotenv.load(fileName: ".env");

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

  // 앱 실행 - 스플래시 화면으로 시작
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(preloadedData: preloadedData),
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
      ),
    ),
  );
}

// 데이터 미리 로드 함수 - 네이티브 스플래시 관련 코드 제거됨
Future<void> _preloadAppData() async {
  try {
    final results = await Future.wait([
      ApiService.fetchReviews(),
      ApiService.fetchPartnerList(),
      ApiService.fetchStoryList(),
    ]);

    preloadedData = {
      'reviews': results[0],
      'partners': results[1],
      'stories': results[2],
    };
  } catch (e) {
    print('데이터 미리 로드 중 오류 발생: $e');
  }
}