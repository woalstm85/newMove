import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:MoveSmart/screen/bottom_navigation.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

Future<void> main() async {
  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // 앱 초기화
  WidgetsFlutterBinding.ensureInitialized();


  runApp(const MyApp());
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