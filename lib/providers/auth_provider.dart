import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 인증 상태를 관리하는 Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// 인증 상태 클래스
class AuthState {
  final String? userEmail;
  final String? phoneNumber;
  final bool isLoggedIn;
  final bool isLoading;
  final bool marketingConsent;
  final bool thirdPartyConsent;
  final List<String> connectedAccounts;
  final String? loginType;

  AuthState({
    this.userEmail,
    this.phoneNumber,
    this.isLoggedIn = false,
    this.isLoading = false,
    this.marketingConsent = false,
    this.thirdPartyConsent = false,
    List<String>? connectedAccounts,
    this.loginType,
  }) : connectedAccounts = connectedAccounts ?? [];

  AuthState copyWith({
    String? userEmail,
    String? phoneNumber,
    bool? isLoggedIn,
    bool? isLoading,
    bool? marketingConsent,
    bool? thirdPartyConsent,
    List<String>? connectedAccounts,
    String? loginType,
  }) {
    return AuthState(
      userEmail: userEmail ?? this.userEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      thirdPartyConsent: thirdPartyConsent ?? this.thirdPartyConsent,
      connectedAccounts: connectedAccounts ?? this.connectedAccounts,
      loginType: loginType ?? this.loginType,
    );
  }
}

// 인증 상태 관리 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isLoading: true)) {
    _loadAuthState();
  }

  // 초기 인증 상태 로드
  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString('user_email');
    final phone = prefs.getString('user_phone');
    final marketingConsent = prefs.getBool('marketing_consent') ?? false;
    final thirdPartyConsent = prefs.getBool('third_party_consent') ?? false;
    final loginType = prefs.getString('login_type');

    // 소셜 로그인 정보에 따라 연결된 계정 관리
    List<String> connectedAccounts = [];
    if (email != null) {
      connectedAccounts.add(email);

      // 소셜 로그인 정보 확인
      final loginType = prefs.getString('login_type');
      if (loginType != null) {
        switch (loginType) {
          case 'google':
            connectedAccounts.add('Google 계정');
            break;
          case 'naver':
            connectedAccounts.add('네이버 계정');
            break;
          case 'kakao':
            connectedAccounts.add('카카오 계정');
            break;
          default:
            connectedAccounts.add('이메일 계정');
        }
      }
    }

    state = AuthState(
      userEmail: email,
      phoneNumber: phone,
      isLoggedIn: email != null,
      isLoading: false,
      marketingConsent: marketingConsent,
      thirdPartyConsent: thirdPartyConsent,
      connectedAccounts: connectedAccounts,
      loginType: loginType,
    );
  }

  // 로그인 처리
  Future<void> login(String email, {String? loginType, String? phone, String? password}) async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);

      if (loginType != null) {
        await prefs.setString('login_type', loginType);
      }

      if (phone != null) {
        await prefs.setString('user_phone', phone);
      }

      if (password != null) {
        await prefs.setString('user_password', password);
      }

      // 소셜 로그인 정보에 따라 연결된 계정 관리
      List<String> connectedAccounts = [email];
      if (loginType != null) {
        switch (loginType) {
          case 'google':
            connectedAccounts.add('Google 계정');
            break;
          case 'naver':
            connectedAccounts.add('네이버 계정');
            break;
          case 'kakao':
            connectedAccounts.add('카카오 계정');
            break;
          default:
            connectedAccounts.add('이메일 계정');
        }
      }

      state = AuthState(
        userEmail: email,
        phoneNumber: phone ?? state.phoneNumber,
        isLoggedIn: true,
        isLoading: false,
        marketingConsent: state.marketingConsent,
        thirdPartyConsent: state.thirdPartyConsent,
        connectedAccounts: connectedAccounts,
        loginType: loginType, // 상태에 loginType 추가
      );
    } catch (e) {
      debugPrint('로그인 오류: $e');
      state = state.copyWith(isLoading: false);
      throw e;
    }
  }

  // 로그아웃 처리
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('login_type');
      // 마케팅 동의와 제3자 동의는 유지

      state = AuthState(
        isLoggedIn: false,
        isLoading: false,
        marketingConsent: state.marketingConsent,
        thirdPartyConsent: state.thirdPartyConsent,
      );
    } catch (e) {
      debugPrint('로그아웃 오류: $e');
      state = state.copyWith(isLoading: false);
      throw e;
    }
  }

  Future<bool> verifyEmailPassword(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    final savedPassword = prefs.getString('user_password');

    return email == savedEmail && password == savedPassword;
  }

  // 마케팅 정보 수신 동의 설정
  Future<void> setMarketingConsent(bool consent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('marketing_consent', consent);

      state = state.copyWith(marketingConsent: consent);
    } catch (e) {
      debugPrint('마케팅 동의 설정 오류: $e');
      throw e;
    }
  }

  // 제3자 정보 제공 동의 설정
  Future<void> setThirdPartyConsent(bool consent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('third_party_consent', consent);

      state = state.copyWith(thirdPartyConsent: consent);
    } catch (e) {
      debugPrint('제3자 정보 동의 설정 오류: $e');
      throw e;
    }
  }

  // 회원가입 시 동의 설정
  Future<void> setInitialConsents({bool marketing = false, bool thirdParty = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('marketing_consent', marketing);
      await prefs.setBool('third_party_consent', thirdParty);

      state = state.copyWith(
        marketingConsent: marketing,
        thirdPartyConsent: thirdParty,
      );
    } catch (e) {
      debugPrint('초기 동의 설정 오류: $e');
      throw e;
    }
  }

  // 전화번호 업데이트
  Future<void> updatePhoneNumber(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_phone', phone);

      state = state.copyWith(phoneNumber: phone);
    } catch (e) {
      debugPrint('전화번호 업데이트 오류: $e');
      throw e;
    }
  }
}