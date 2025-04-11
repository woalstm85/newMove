import 'package:flutter/cupertino.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KakaoAuthService {
  static final KakaoAuthService _instance = KakaoAuthService._internal();

  factory KakaoAuthService() {
    return _instance;
  }

  KakaoAuthService._internal();

  static const String _tokenKey = 'kakao_access_token';
  static const String _refreshTokenKey = 'kakao_refresh_token';
  static const String _emailKey = 'kakao_email';

  // 카카오 로그인 구현
  Future<String?> signInWithKakao() async {
    try {
      // 앱 키 확인
      debugPrint('카카오 앱 키: ${KakaoSdk.appKey}');

      // 카카오톡 설치 여부 확인
      bool isInstalled = await isKakaoTalkInstalled();
      debugPrint('카카오톡 설치됨: $isInstalled');

      // 로그인 실행
      debugPrint('로그인 시도: ${isInstalled ? "카카오톡" : "카카오 계정"}');

      OAuthToken token;
      try {
        token = isInstalled
            ? await UserApi.instance.loginWithKakaoTalk() // 카카오톡 앱으로 로그인
            : await UserApi.instance.loginWithKakaoAccount(); // 카카오 계정으로 로그인
        debugPrint('토큰 획득 성공: ${token.accessToken.substring(0, 10)}...');
      } catch (e) {
        debugPrint('토큰 획득 실패: $e');
        return null;
      }

      // 토큰 저장
      await _saveTokenInfo(token);

      // 사용자 정보 요청
      try {
        User user = await UserApi.instance.me();
        debugPrint('사용자 정보 획득 성공: ${user.id}');
        String? email = user.kakaoAccount?.email;
        debugPrint('이메일: $email');

        // 이메일 저장
        if (email != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_emailKey, email);
        }

        return email;
      } catch (e) {
        debugPrint('사용자 정보 획득 실패: $e');
        return null;
      }
    } catch (e) {
      debugPrint('카카오 로그인 에러 (최상위): $e');
      return null;
    }
  }

  // 현재 로그인된 사용자 정보 가져오기
  Future<String?> getCurrentUser() async {
    try {
      bool hasToken = await AuthApi.instance.hasToken();
      debugPrint('토큰 존재 여부: $hasToken');

      if (hasToken) {
        // 유효한 토큰이 있는지 확인
        try {
          bool isValid = await isValidAccessToken();
          debugPrint('토큰 유효성: $isValid');

          if (isValid) {
            // 사용자 정보 요청
            User user = await UserApi.instance.me();
            return user.kakaoAccount?.email;
          }
        } catch (e) {
          debugPrint('토큰 유효성 확인 중 오류: $e');
        }
      }
      return null;
    } catch (e) {
      debugPrint('카카오 사용자 정보 조회 에러: $e');
      return null;
    }
  }

  // 토큰 유효성 확인
  Future<bool> isValidAccessToken() async {
    try {
      AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await UserApi.instance.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_emailKey);
    } catch (e) {
      debugPrint('카카오 로그아웃 에러: $e');
    }
  }

  // 토큰 정보 저장
  Future<void> _saveTokenInfo(OAuthToken token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token.accessToken);
    if (token.refreshToken != null) {
      await prefs.setString(_refreshTokenKey, token.refreshToken!);
    }
  }
}