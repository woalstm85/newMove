import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/splash_screen.dart'; // 스플래시 화면 임포트
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

// 서비스 미리 로딩 함수
Future<Map<String, dynamic>> _preloadData() async {
  // 여기서 필요한 데이터를 미리 로드
  // 예: API 호출, 로컬 데이터 불러오기 등

  // 간단한 지연으로 스플래시 화면을 보여주기 위한 예시 코드
  await Future.delayed(const Duration(milliseconds: 500));

  return {
    // 미리 로드할 데이터를 여기에 추가
    'reviews': [],
    'partners': [],
    'stories': [],
  };
}

Future<void> main() async {
  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // 앱 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // 카카오 SDK 초기화 - 네이티브 앱 키 사용
  final kakaoAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
  KakaoSdk.init(nativeAppKey: kakaoAppKey);

  // 카카오 SDK origin 확인
  debugPrint('카카오 SDK Origin: ${await KakaoSdk.origin}');

  // 필요한 데이터 사전 로드
  final preloadedData = await _preloadData();

  runApp(
    // ProviderScope로 앱 감싸기
    ProviderScope(
      child: MyApp(preloadedData: preloadedData),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> preloadedData;

  const MyApp({super.key, required this.preloadedData});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '디딤돌 이사',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Pretendard', // 폰트 설정
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(preloadedData: preloadedData), // 스플래시 화면으로 시작
      debugShowCheckedModeBanner: false,
    );
  }
}