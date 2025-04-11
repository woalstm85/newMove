
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  GoogleSignIn get googleSignIn => _googleSignIn;

  // 현재 로그인된 사용자 이메일 가져오기
  Future<String?> getCurrentUser() async {
    final GoogleSignInAccount? account = _googleSignIn.currentUser;
    return account?.email;
  }

  // 구글 로그인 실행 (리스너는 사용하지 않고 직접 결과 반환)
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account?.email;
    } catch (e) {
      debugPrint('구글 로그인 오류: $e');
      return null;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}