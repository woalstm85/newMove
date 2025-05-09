import 'package:MoveSmart/modal_banner_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:MoveSmart/screen/home/home_screen.dart';
import 'package:MoveSmart/screen/partner/partner_screen.dart';
import 'package:MoveSmart/screen/login/login_screen.dart';
import 'package:MoveSmart/screen/history/history_screen.dart';
import 'package:MoveSmart/screen/more/more_screen.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/services/naver_auth_service.dart';
import 'package:MoveSmart/services/kakao_auth_service.dart';
import 'package:MoveSmart/services/google_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/providers/auth_provider.dart';

class BottomNavigationBarWidget extends ConsumerStatefulWidget {
  final int initialIndex; // 초기 탭을 설정하는 매개변수
  final Map<String, dynamic> preloadedData;

  const BottomNavigationBarWidget({
    super.key,
    this.initialIndex = 0,
    required this.preloadedData,
  }); // 기본값을 0으로 설정

  @override
  ConsumerState<BottomNavigationBarWidget> createState() => _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends ConsumerState<BottomNavigationBarWidget> {
  late int _selectedIndex;
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  bool _isNaverLoggedIn = false;
  bool _isSigningIn = false;
  bool _hasInitialized = false;
  String? _userEmail;
  final KakaoAuthService _kakaoAuthService = KakaoAuthService();
  bool _isKakaoLoggedIn = false;

  int _previousIndex = 0; // 이전 인덱스 추적

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _previousIndex = _selectedIndex;
    _signInSilently();
  }

  // 자동 로그인 함수
  Future<void> _signInSilently() async {
    if (_isSigningIn) return;
    setState(() {
      _isSigningIn = true;
    });

    try {
      // 먼저 저장된 로그인 타입 확인
      final prefs = await SharedPreferences.getInstance();
      final savedLoginType = prefs.getString('login_type');

      if (savedLoginType == 'google') {
        // 구글 자동 로그인 시도
        final email = await _googleAuthService.getCurrentUser();
        if (email != null) {
          setState(() {
            _userEmail = email;
          });
          ref.read(authProvider.notifier).login(email, loginType: 'google');
        }
      } else if (savedLoginType == 'naver') {
        // 저장된 로그인이 네이버인 경우 네이버 로그인 먼저 시도
        try {
          final naverAuthService = NaverAuthService();
          final email = await naverAuthService.getCurrentUser();
          if (email != null) {
            setState(() {
              _isNaverLoggedIn = true;
              _userEmail = email;
            });
            ref.read(authProvider.notifier).login(email, loginType: 'naver');
            return; // 성공하면 다른 로그인 시도하지 않고 종료
          }
        } catch (e) {
          debugPrint('네이버 자동 로그인 확인 실패: $e');
        }
      } else if (savedLoginType == 'kakao') {
        // 저장된 로그인이 카카오인 경우 카카오 로그인 먼저 시도
        try {
          final email = await _kakaoAuthService.getCurrentUser();
          if (email != null) {
            setState(() {
              _isKakaoLoggedIn = true;
              _userEmail = email;
            });
            ref.read(authProvider.notifier).login(email, loginType: 'kakao');
            return; // 성공하면 다른 로그인 시도하지 않고 종료
          }
        } catch (e) {
          debugPrint('카카오 자동 로그인 확인 실패: $e');
        }
      }
    } catch (error) {
      debugPrint('자동 로그인 실패: $error');
    } finally {
      setState(() {
        _isSigningIn = false;
        _hasInitialized = true;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _previousIndex = _selectedIndex; // 이전 인덱스 저장
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
          // HomeScreen 인스턴스 생성 (GlobalKey 없이)
          HomeScreen(preloadedData: widget.preloadedData),
          const PartnerSearchScreen(),

          // 로그인 상태를 Consumer로 감지하여 화면 전환
          Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authProvider);
                return authState.isLoggedIn
                    ? MyUsageHistoryScreen(userEmail: authState.userEmail)
                    : const LoginScreen();
              }
          ),

          const PlaceholderWidget('채팅'),
          const MoreScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white, // 흰색 배경
        selectedItemColor: AppTheme.primaryColor, // 선택된 아이템 색상
        unselectedItemColor: AppTheme.secondaryText, // 선택되지 않은 아이템 색상
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold, // 선택된 라벨 볼드처리
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
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