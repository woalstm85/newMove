import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'partner_screen.dart';
import 'login_screen.dart';
import 'my_usage_history_screen.dart';
import 'more_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/services/naver_auth_service.dart';

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
  late int _selectedIndex;
  GoogleSignInAccount? _currentUser; // 구글 로그인 사용자 정보
  // NaverAccountResult 대신 단순 bool 사용
  bool _isNaverLoggedIn = false; // 네이버 로그인 상태
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  bool _isSigningIn = false;
  bool _hasInitialized = false;
  String? _userEmail; // 사용자 이메일

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // 구글 로그인 상태 변화 감지
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        _userEmail = account?.email;
      });
    });

    _signInSilently();
  }

  // 자동 로그인 함수

  Future<void> _signInSilently() async {
    if (_isSigningIn) return;
    setState(() {
      _isSigningIn = true;
    });

    try {
      // 구글 자동 로그인 시도
      final googleAccount = await _googleSignIn.signInSilently();
      if (googleAccount != null) {
        setState(() {
          _currentUser = googleAccount;
          _userEmail = googleAccount.email;
        });
      } else {
        // 네이버 로그인 상태 확인
        try {
          final naverAuthService = NaverAuthService();

          final email = await naverAuthService.getCurrentUser();
          if (email != null) {
            setState(() {
              _isNaverLoggedIn = true;
              _userEmail = email;
            });
          }
        } catch (e) {
          print('네이버 자동 로그인 확인 실패: $e');
        }
      }
    } catch (error) {
      print('자동 로그인 실패: $error');
    } finally {
      setState(() {
        _isSigningIn = false;
        _hasInitialized = true;
      });
    }
  }

// 로그아웃 처리 함수도 수정
  void _handleLogout() async {
    if (_currentUser != null) {
      await _googleSignIn.signOut(); // 구글 로그아웃
    }

    if (_isNaverLoggedIn) {
      try {
        // 네이버 로그아웃 처리
        final naverAuthService = NaverAuthService();
        await naverAuthService.signOut();
      } catch (e) {
        print('네이버 로그아웃 실패: $e');
      }
    }

    setState(() {
      _currentUser = null;
      _isNaverLoggedIn = false;
      _userEmail = null;
      _selectedIndex = 0;
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
          _userEmail == null
              ? const LoginScreen()
              : MyUsageHistoryScreen(userEmail: _userEmail!),
          const PlaceholderWidget('채팅'),
          MoreScreen(
            userEmail: _userEmail,
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