import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../more_section/notice.dart';
import '../more_section/faq.dart';
import '../more_section/terms_service.dart';
import '../theme/theme_constants.dart';
import 'login_screen.dart';
import '../utils/ui_extensions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MoreScreen extends StatelessWidget {
  final String? userEmail;
  final Function onLogout;

  const MoreScreen({super.key, this.userEmail, required this.onLogout});

// URL을 여는 함수
  void _launchURL(BuildContext context) async {
    // .env 파일에서 URL 가져오기 (기본값 제공)
    final String kakaoChatUrl = dotenv.env['KAKAO_CHAT_URL'] ?? 'http://pf.kakao.com/_ZxkbmG/chat';

    final Uri url = Uri.parse(kakaoChatUrl);
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카카오톡 채팅을 열 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 섹션
              _buildProfileSection(context),

              // 안심 서비스 안내 섹션
              _buildAssuranceSection(context),


              // 쿠폰 & 초대 섹션
              _buildCouponInviteSection(context),

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
  Widget _buildProfileSection(BuildContext context) {
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
              if (userEmail != null) {
                // 로그인 상태면 로그아웃 확인 다이얼로그 표시
                _showLogoutConfirmDialog(context);
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
                    userEmail != null ? Icons.person : Icons.person_outline,
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
                        userEmail != null ? userEmail! : '로그인이 필요합니다',
                        style: context.titleStyle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.smallPadding),
                      Text(
                        userEmail != null ? '로그아웃' : '로그인하고 더 많은 혜택을 누려보세요',
                        style: TextStyle(
                          fontSize: context.scaledFontSize(14),
                          color: userEmail != null
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
          if (userEmail == null)
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

  // 로그인 화면으로 이동하는 함수
  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 로그아웃 아이콘
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 34,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 24),

                // 타이틀과 설명
                Text(
                  '로그아웃 하시겠습니까?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  '로그아웃 하시면 이전 화면으로 돌아갑니다.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // 버튼 영역
                Row(
                  children: [
                    // 취소 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: AppTheme.secondaryText,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),

                    // 로그아웃 버튼
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onLogout();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('로그아웃 되었습니다.'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppTheme.primaryColor,
                              margin: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.height * 0.1,
                                left: 16,
                                right: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '로그아웃',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
                        style: context.labelSSubStyle(color: Colors.white.withOpacity(0.9),)
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
  Widget _buildCouponInviteSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: context.cardDecoration(borderColor: AppTheme.borderColor),
      child:
              _buildMenuTile(
                context,
            icon: Icons.share,
            iconColor: Colors.green,
            title: '친구 초대',
            subtitle: '친구에게 공유하고 쿠폰 받기',
            onTap: () {
              // 비로그인 상태면 로그인 화면으로 이동
              if (userEmail == null) {
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
          Divider(height: 1, indent: 20, endIndent: 20,),
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
          Divider(height: 1, indent: 20, endIndent: 20,),
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
          Divider(height: 1, indent: 20, endIndent: 20,),
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
  Widget _buildMenuTile(BuildContext context,{
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
                      SizedBox(width: context.smallPadding),
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