import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/screen/navigation/bottom_navigation.dart';
import 'package:MoveSmart/screen/login/email_signup_screen.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/home/story/api/story_api_service.dart';
import 'package:MoveSmart/screen/partner/API/partner_api_service.dart';
import 'package:MoveSmart/screen/home/review/api/review_api_service.dart';
import 'package:MoveSmart/services/naver_auth_service.dart';
import 'package:MoveSmart/services/kakao_auth_service.dart';
import 'package:MoveSmart/services/google_auth_service.dart';
import 'package:MoveSmart/providers/auth_provider.dart';
import 'package:MoveSmart/screen/login/email_login_screen.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  bool _isNaverLoading = false; // 네이버 로그인 로딩 상태
  bool _isKakaoLoading = false;
  final KakaoAuthService _kakaoAuthService = KakaoAuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Map<String, dynamic>> _preloadData() async {
    try {
      // 병렬로 API 호출
      final results = await Future.wait([
        ReviewService.fetchReviews(),
        PartnerService.fetchPartners(),
        StoryService.fetchStoryList(),
      ]);

      return {
        'reviews': results[0],
        'partners': results[1],
        'stories': results[2],
      };
    } catch (e) {
      debugPrint('데이터 미리 로드 중 오류 발생: $e');
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
      final email = await _googleAuthService.signInWithGoogle();

      if (email != null && mounted) {
        debugPrint('구글 로그인 성공: $email');

        // 1. authProvider 업데이트
        ref.read(authProvider.notifier).login(email, loginType: 'google');

        // 2. 데이터 미리 로드
        Map<String, dynamic> preloadedData = await _preloadData();

        // 3. 위젯이 여전히 마운트 상태인지 확인
        if (mounted) {
          // 4. 네비게이션
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
      } else {
        if (mounted) {
          context.showSnackBar('구글 로그인에 실패했습니다.', isError: true);
        }
      }
    } catch (error) {
      debugPrint('구글 로그인 오류: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.showSnackBar('구글 로그인중 오류가 발생하였습니다.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 카카오 로그인 처리 함수
  Future<void> _handleKakaoLogin() async {
    setState(() {
      _isKakaoLoading = true;
    });

    try {
      final email = await _kakaoAuthService.signInWithKakao();

      if (email != null && mounted) {
        debugPrint('카카오 로그인 성공: $email');

        // 1. 먼저 authProvider 업데이트
        ref.read(authProvider.notifier).login(email, loginType: 'kakao');

        // 2. 데이터 미리 로드
        Map<String, dynamic> preloadedData = await _preloadData();

        // 3. 위젯이 여전히 마운트 상태인지 확인
        if (mounted) {
          // 4. 네비게이션
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
      } else {
        if (mounted) {
          context.showSnackBar('카카오 로그인에 실패했습니다.', isError: true);
        }
      }
    } catch (error) {
      debugPrint('카카오 로그인 오류: $error');
      if (mounted) {
        context.showSnackBar('카카오 로그인중 오류가 발생하였습니다.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isKakaoLoading = false;
        });
      }
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

                    if (email != null && mounted) {
                      debugPrint('네이버 로그인 성공: $email');

                      // 1. authProvider 업데이트
                      ref.read(authProvider.notifier).login(email, loginType: 'naver');

                      // 2. 데이터 미리 로드
                      Map<String, dynamic> preloadedData = await _preloadData();

                      // 3. 위젯이 여전히 마운트 상태인지 확인
                      if (mounted) {
                        // 4. 네비게이션
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
                    } else {
                      if (mounted) {
                        context.showSnackBar('네이버 로그인에 실패했습니다.', isError: true);
                      }
                    }
                  } catch (error) {
                    debugPrint('네이버 로그인 오류: $error');
                    if (mounted) {
                      context.showSnackBar('네이버 로그인중 오류가 발생하였습니다.', isError: true);
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isNaverLoading = false;
                      });
                    }
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
                onPressed: _isLoading || _isNaverLoading || _isKakaoLoading
                    ? null
                    : _handleKakaoLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFEE500), // 카카오 노란색
                  foregroundColor: Color(0xFF191600), // 카카오 버튼 텍스트 색상
                  padding: EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isKakaoLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF191600)),
                        ),
                      )
                    else
                      Row(
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
                  ],
                ),
              ),

              SizedBox(height: 16),

              // 이메일 로그인 버튼
// 이메일 로그인 버튼
              ElevatedButton(
                onPressed: _isLoading || _isNaverLoading ? null : () {
                  // 새 이메일 로그인 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EmailLoginScreen()),
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
                      Icons.email,
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