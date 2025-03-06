import 'package:flutter/material.dart';
import './screen/bottom_navigation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 날짜 형식을 초기화 (한글 로케일)
  await initializeDateFormatting('ko_KR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      home: BottomNavigationBarWidget(), // 스플래시 화면 먼저 보여줌
    );
  }
}

