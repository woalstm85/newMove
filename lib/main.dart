import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/screen/navigation/bottom_navigation.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

Future<void> main() async {
  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // 앱 초기화
  WidgetsFlutterBinding.ensureInitialized();


  // 카카오 SDK 초기화 - 네이티브 앱 키 사용
  final kakaoAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
  KakaoSdk.init(nativeAppKey: kakaoAppKey);

  // 카카오 SDK origin 확인
  debugPrint('카카오 SDK Origin: ${await KakaoSdk.origin}');


  runApp(
    // ProviderScope로 앱 감싸기
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: BottomNavigationBarWidget(
        initialIndex: 0,
        preloadedData: {}, // 초기에는 빈 데이터로 시작
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}