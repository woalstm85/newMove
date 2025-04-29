import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/providers/auth_provider.dart';
import 'package:MoveSmart/screen/login/login_screen.dart';
import 'package:MoveSmart/screen/more/account_settings_screen.dart';
import 'package:MoveSmart/screen/more/constants/more_screen_constants.dart';

class ProfileSection extends ConsumerWidget {
  final bool isLoggedIn;
  final String? userEmail;

  const ProfileSection({
    Key? key,
    required this.isLoggedIn,
    this.userEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (isLoggedIn) {
                // 로그인 상태면 계정 관리 화면으로 이동
                _navigateToAccountSettings(context, ref);
              } else {
                // 비로그인 상태면 로그인 화면으로 이동
                _navigateToLogin(context);
              }
            },
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLoggedIn ? Icons.person : Icons.person_outline,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                SizedBox(width: context.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn ? userEmail! : MoreScreenText.loginRequired,
                        style: context.titleStyle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.smallPadding),
                      Text(
                        isLoggedIn
                            ? MoreScreenText.accountManagement
                            : MoreScreenText.loginBenefitMessage,
                        style: TextStyle(
                          fontSize: context.scaledFontSize(14),
                          color: isLoggedIn
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.secondaryText,
                  size: 16,
                ),
              ],
            ),
          ),
          if (!isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () => _navigateToLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  MoreScreenText.loginSignup,
                  style: context.titleStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 계정 관리 화면으로 이동하는 함수
  void _navigateToAccountSettings(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountSettingsScreen(
          userEmail: authState.userEmail!,
          phoneNumber: authState.phoneNumber ?? "010-****-7199",
          loginType: authState.loginType ?? "email", // loginType 전달
          connectedAccounts: authState.connectedAccounts,
          marketingConsent: authState.marketingConsent,
          thirdPartyConsent: authState.thirdPartyConsent,
          onLogout: () {
            // 로그아웃 처리
            ref.read(authProvider.notifier).logout().then((_) {
              Navigator.pop(context); // 계정 설정 화면 닫기

              // 로그아웃 성공 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(MoreScreenText.logoutSuccessMessage),
                  backgroundColor: AppTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            });
          },
          onMarketingConsentChanged: (value) {
            ref.read(authProvider.notifier).setMarketingConsent(value);
          },
          onThirdPartyConsentChanged: (value) {
            ref.read(authProvider.notifier).setThirdPartyConsent(value);
          },
        ),
      ),
    );
  }

  // 로그인 화면으로 이동하는 함수
  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}