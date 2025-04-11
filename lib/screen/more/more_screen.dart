import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/screen/more/sections/notice.dart';
import 'package:MoveSmart/screen/more/sections/faq.dart';
import 'package:MoveSmart/screen/more/sections/terms_service.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import '../login/login_screen.dart';
import 'account_settings_screen.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({Key? key}) : super(key: key);

  // URL을 여는 함수
  void _launchURL(BuildContext context) async {
    final String kakaoChatUrl = dotenv.env['KAKAO_CHAT_URL'] ?? 'http://pf.kakao.com/_ZxkbmG/chat';
    final Uri url = Uri.parse(kakaoChatUrl);

    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카카오톡 채팅을 열 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isLoggedIn;
    final userEmail = authState.userEmail;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 섹션
              _buildProfileSection(context, ref, isLoggedIn, userEmail),

              // 안심 서비스 안내 섹션
              _buildAssuranceSection(context),

              // 쿠폰 & 초대 섹션
              _buildCouponInviteSection(context, isLoggedIn),

              SizedBox(height: context.defaultPadding),

              // 고객 지원 섹션
              _buildSupportSection(context),

              SizedBox(height: context.defaultPadding),

              // 약관 섹션
              _buildTermsSection(context),

              SizedBox(height: context.defaultPadding),

              // 앱 버전 정보
              Center(
                child: Text(
                  'App version 1.0.0',
                  style: TextStyle(
                    color: AppTheme.subtleText,
                    fontSize: 12,
                  ),
                ),
              ),

              SizedBox(height: context.defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  // 프로필 섹션
  Widget _buildProfileSection(BuildContext context, WidgetRef ref, bool isLoggedIn, String? userEmail) {
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
                        isLoggedIn ? userEmail! : '로그인이 필요합니다',
                        style: context.titleStyle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.smallPadding),
                      Text(
                        isLoggedIn ? '계정 관리' : '로그인하고 더 많은 혜택을 누려보세요',
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
                  '로그인 / 회원가입',
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
                  content: Text('로그아웃 되었습니다.'),
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

  // 안심 서비스 섹션
  Widget _buildAssuranceSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.accentColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 안심 서비스 상세 정보로 이동
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(context.defaultPadding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: context.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이사 안심+ 서비스',
                        style: context.titleStyle(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '파트너와 문제가 생겼을 때 도움을 드립니다',
                        style: context.labelSSubStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 쿠폰 & 초대 섹션
  Widget _buildCouponInviteSection(BuildContext context, bool isLoggedIn) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: context.cardDecoration(borderColor: AppTheme.borderColor),
      child: _buildMenuTile(
        context,
        icon: Icons.share,
        iconColor: Colors.green,
        title: '친구 초대',
        subtitle: '친구에게 공유하고 쿠폰 받기',
        onTap: () {
          // 비로그인 상태면 로그인 화면으로 이동
          if (!isLoggedIn) {
            _navigateToLogin(context);
            return;
          }
          // 초대 기능 실행 (로그인 상태인 경우)
        },
      ),
    );
  }

  // 고객 지원 섹션
  Widget _buildSupportSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              '고객 지원',
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildMenuTile(
            context,
            icon: Icons.campaign_outlined,
            iconColor: AppTheme.primaryColor,
            title: '공지사항',
            subtitle: '주요 소식 및 업데이트',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoticeScreen()),
              );
            },
          ),
          Divider(height: 1, indent: 20, endIndent: 20),
          _buildMenuTile(
            context,
            icon: Icons.question_answer_outlined,
            iconColor: AppTheme.accentColor,
            title: '자주 묻는 질문',
            subtitle: '궁금한 점을 찾아보세요',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FAQScreen()),
              );
            },
          ),
          Divider(height: 1, indent: 20, endIndent: 20),
          _buildMenuTile(
            context,
            icon: Icons.support_agent,
            iconColor: Colors.yellow[700]!,
            title: '1:1 문의',
            subtitle: '카카오톡 채팅으로 상담하기',
            onTap: () {
              _launchURL(context);
            },
          ),
        ],
      ),
    );
  }

  // 약관 섹션
  Widget _buildTermsSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              '약관 및 정책',
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildMenuTile(
            context,
            icon: Icons.description_outlined,
            iconColor: Colors.grey,
            title: '서비스 이용약관',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsOfServiceScreen()),
              );
            },
            showSubtitle: false,
          ),
          Divider(height: 1, indent: 20, endIndent: 20),
          _buildMenuTile(
            context,
            icon: Icons.security,
            iconColor: Colors.grey,
            title: '개인정보 처리방침',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TermsOfServiceScreen(initialIndex: 1),
                ),
              );
            },
            showSubtitle: false,
          ),
        ],
      ),
    );
  }

  // 메뉴 타일 위젯
  Widget _buildMenuTile(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        String? subtitle,
        String? trailing,
        required VoidCallback onTap,
        bool showSubtitle = true,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              SizedBox(width: context.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: context.scaledFontSize(16),
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    if (showSubtitle && subtitle != null)
                      SizedBox(height: context.smallPadding),
                    if (showSubtitle && subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: context.scaledFontSize(13),
                          color: AppTheme.secondaryText,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (trailing == null)
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.secondaryText,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}