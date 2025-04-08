import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'bottom_navigation.dart';
import 'email_signup_screen.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/api_service.dart';
import 'package:MoveSmart/services/naver_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignInAccount? _currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  late StreamSubscription<GoogleSignInAccount?> _subscription;
  bool _isLoading = false;
  bool _isNaverLoading = false; // 네이버 로그인 로딩 상태

  @override
  void initState() {
    super.initState();
    _subscription = _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (mounted) {
        setState(() {
          _currentUser = account;
          _isLoading = false;
        });
      }
      if (account != null) {
        // 로그인 성공 시 별도 메서드 호출
        _navigateAfterLogin(account.email);
      }
    });
  }

  // 로그인 성공 후 네비게이션을 처리하는 별도 메서드
  Future<void> _navigateAfterLogin(String email) async {
    // 데이터를 로드한 후 네비게이션
    Map<String, dynamic> preloadedData = await _preloadData();

    // 더보기 탭으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BottomNavigationBarWidget(
          initialIndex: 4,
          preloadedData: preloadedData,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> _preloadData() async {
    try {
      // 병렬로 API 호출
      final results = await Future.wait([
        ApiService.fetchReviews(),
        ApiService.fetchPartnerList(),
        ApiService.fetchStoryList(),
      ]);

      return {
        'reviews': results[0],
        'partners': results[1],
        'stories': results[2],
      };
    } catch (e) {
      print('데이터 미리 로드 중 오류 발생: $e');
      return {
        'reviews': [],
        'partners': [],
        'stories': [],
      };
    }
  }

  // Google 로그인 함수
  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _googleSignIn.signIn();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('로그인 실패: $error');
      // 로그인 실패 시 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '로그인',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),

              // 로고 이미지 (실제로는 앱 로고로 대체)
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.moving,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),

              SizedBox(height: 15),

              // 제목 텍스트
              Text(
                '로그인하여 더 많은 혜택을\n받아보세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16),

              // 부제목 텍스트
              Text(
                '로그인하면 이사 견적과 이력을 관리하고,\n다양한 혜택을 받을 수 있습니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryText,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 50),

              // 구글 로그인 버튼
              ElevatedButton(
                onPressed: _isLoading || _isNaverLoading ? null : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryText,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google_login_icon.png',
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Google로 로그인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // 네이버 로그인 버튼
              ElevatedButton(
                onPressed: _isLoading || _isNaverLoading ? null : () async {
                  setState(() {
                    _isNaverLoading = true;
                  });

                  try {
                    final naverAuthService = NaverAuthService();

                    final email = await naverAuthService.signInWithNaver();

                    if (email != null) {
                      print('네이버 로그인 성공: $email');
                      _navigateAfterLogin(email);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('네이버 로그인에 실패했습니다.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (error) {
                    print('네이버 로그인 오류: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('네이버 로그인 중 오류가 발생했습니다.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    setState(() {
                      _isNaverLoading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF03C75A), // 네이버 그린 색상
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isNaverLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/naver_login_icon.png',
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            '네이버로 로그인',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // 카카오 로그인 버튼
              ElevatedButton(
                onPressed: _isLoading || _isNaverLoading ? null : () {
                  // TODO: 카카오 로그인 구현
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('카카오 로그인 구현 예정입니다.'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFEE500), // 카카오 노란색
                  foregroundColor: Color(0xFF191600), // 카카오 버튼 텍스트 색상
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/kakao_login_icon.png',
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '카카오로 로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // 이메일 로그인 버튼
              ElevatedButton(
                onPressed: _isLoading || _isNaverLoading ? null : () {
                  // 예시로 이메일 회원가입 화면으로 연결
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmailSignUpScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email,  // 이메일 아이콘 사용
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '이메일로 로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // 회원가입 안내 텍스트
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '아직 회원이 아니신가요?',
                    style: TextStyle(
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EmailSignUpScreen()),
                      );
                    },
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}