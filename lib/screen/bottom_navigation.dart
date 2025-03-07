import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'partner_screen.dart';
import 'login_screen.dart';
import 'my_usage_history_screen.dart';
import 'more_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/theme_constants.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  final int initialIndex; // 초기 탭을 설정하는 매개변수
  final Map<String, dynamic> preloadedData;

  const BottomNavigationBarWidget({
    super.key,
    this.initialIndex = 0,
    required this.preloadedData,
  }); // 기본값을 0으로 설정

  @override
  _BottomNavigationBarWidgetState createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  late int _selectedIndex; // 초기값 설정
  GoogleSignInAccount? _currentUser; // 구글 로그인 사용자 정보
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  bool _isSigningIn = false; // 자동 로그인 중인지 상태를 추적
  bool _hasInitialized = false; // 앱이 처음 로드되었는지 여부

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // 초기 탭 설정

    // 구글 로그인 상태 변화 감지
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account; // 구글 로그인 상태에 따라 사용자 정보 저장
      });
    });

    _signInSilently(); // 앱 시작 시 자동 로그인 시도
  }

  // 구글 자동 로그인 함수
  Future<void> _signInSilently() async {
    if (_isSigningIn) return; // 이미 로그인 중이면 중복 호출 방지
    setState(() {
      _isSigningIn = true;
    });

    try {
      await _googleSignIn.signInSilently();
    } catch (error) {
      print('자동 로그인 실패: $error');
    } finally {
      setState(() {
        _isSigningIn = false;
        _hasInitialized = true; // 앱 초기화 완료
      });
    }
  }

  // 로그아웃 처리 함수
  void _handleLogout() {
    _googleSignIn.signOut(); // 구글 로그아웃
    setState(() {
      _currentUser = null; // 로그아웃 후 사용자 정보 제거
      _selectedIndex = 0; // 로그아웃 후 홈 화면으로 이동
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 탭의 인덱스 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    // 앱이 처음 로드되었는지 확인 (자동 로그인 상태에 상관없이 첫 화면으로 이동)
    if (!_hasInitialized) {
      return const Center(
        child: CircularProgressIndicator(), // 앱이 초기화되지 않았으면 로딩 표시
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(preloadedData: widget.preloadedData), // preloadedData 전달
          const PartnerSearchScreen(),
          _currentUser == null
              ? const LoginScreen()
              : MyUsageHistoryScreen(userEmail: _currentUser!.email),
          const PlaceholderWidget('채팅'),
          MoreScreen(
            userEmail: _currentUser?.email,
            onLogout: _handleLogout,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white, // 흰색 배경
        selectedItemColor: AppTheme.primaryColor, // 선택된 아이템 색상
        unselectedItemColor: AppTheme.secondaryText, // 선택되지 않은 아이템 색상
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold, // 선택된 라벨 볼드처리
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
        ),

        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '파트너 찾기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '이용내역',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: '더보기',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String text;

  const PlaceholderWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 30),
      ),
    );
  }
}
