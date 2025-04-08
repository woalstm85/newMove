import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NaverAuthService {

  // 네이버 로그인 수행
  Future<String?> signInWithNaver() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        // 로그인 성공
        final NaverAccountResult account = await FlutterNaverLogin.currentAccount();
        return account.email;
      } else {
        // 로그인 취소 또는 실패
        print('네이버 로그인 실패/취소: ${result.status}');
        print("네이버 로그인 실패/취소: ${result.errorMessage}");
        return null;
      }
    } catch (e) {
      print('네이버 로그인 오류: $e');
      return null;
    }
  }

  // 현재 로그인된 사용자 확인
  Future<String?> getCurrentUser() async {
    try {
      final NaverAccessToken token = await FlutterNaverLogin.currentAccessToken;
      if (token.accessToken.isNotEmpty) {
        final NaverAccountResult account = await FlutterNaverLogin.currentAccount();
        return account.email;
      }
      return null;
    } catch (e) {
      print('현재 사용자 가져오기 오류: $e');
      return null;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await FlutterNaverLogin.logOut();
  }
}