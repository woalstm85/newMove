import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class AccountSettingsScreen extends StatefulWidget {
  final String userEmail;
  final String phoneNumber;
  final List<String> connectedAccounts;
  final bool marketingConsent;
  final bool thirdPartyConsent;
  final VoidCallback onLogout;
  final ValueChanged<bool> onMarketingConsentChanged;
  final ValueChanged<bool> onThirdPartyConsentChanged;
  final String loginType;

  const AccountSettingsScreen({
    Key? key,
    required this.userEmail,
    required this.phoneNumber,
    required this.connectedAccounts,
    required this.marketingConsent,
    required this.thirdPartyConsent,
    required this.onLogout,
    required this.onMarketingConsentChanged,
    required this.onThirdPartyConsentChanged,
    required this.loginType,
  }) : super(key: key);

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late bool _marketingConsent;
  late bool _thirdPartyConsent;

  @override
  void initState() {
    super.initState();
    _marketingConsent = widget.marketingConsent;
    _thirdPartyConsent = widget.thirdPartyConsent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          '계정관리',
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 휴대전화 번호 섹션
              _buildSectionWithArrow(
                context: context,
                title: '휴대전화 번호',
                value: widget.phoneNumber.formatPhoneNumber(),
                onTap: () {
                  // 휴대전화 번호 수정 화면으로 이동
                },
              ),

              Divider(height: 1),

              // 개인 정보 수정 섹션
              _buildSectionWithArrow(
                context: context,
                title: '개인 정보 수정',
                onTap: () {
                  // 개인 정보 수정 화면으로 이동
                },
              ),

              Divider(height: 1),

              // 연결된 계정 섹션
              _buildConnectedAccountsSection(context),

              SizedBox(height: 16),

              // 마케팅 정보 수신 동의 섹션
              _buildConsentSection(
                context: context,
                title: '마케팅 정보 수신 동의',
                description: '현재 마케팅 정보 수신에 ${_marketingConsent
                    ? '동의하였습니다'
                    : '동의하지 않았습니다'}.\n'
                    '* 마케팅 정보 수신 동의를 철회하면 이메일, 문자(SMS), 푸시 알림을 통한 이벤트, 할인 쿠폰, 프로모션 등의 정보를 더 이상 받지 않게 됩니다.\n'
                    '* 기본 서비스 이용에는 영향을 미치지 않습니다.',
                value: _marketingConsent,
                onChanged: (value) {
                  setState(() {
                    _marketingConsent = value;
                  });
                  widget.onMarketingConsentChanged(value);
                },
              ),

              SizedBox(height: 16),

              // 제3자 정보 제공 동의 섹션
              _buildConsentSection(
                context: context,
                title: '제3자 정보 제공 동의',
                description: '현재 제3자(이삿짐센터, 쿠폰 발송 업체 등)에게 개인정보 제공에 ${_thirdPartyConsent
                    ? '동의하였습니다'
                    : '동의하지 않았습니다'}.\n'
                    '* 제3자 정보 제공 동의를 철회하면 해당 업체에서 고객님의 개인정보를 더 이상 사용할 수 없도록 요청됩니다.\n'
                    '* 기본 서비스 이용에는 영향을 미치지 않습니다.\n'
                    '* 처리 완료까지 최대 7일이 소요될 수 있습니다.',
                value: _thirdPartyConsent,
                onChanged: (value) {
                  setState(() {
                    _thirdPartyConsent = value;
                  });
                  widget.onThirdPartyConsentChanged(value);
                },
              ),

              SizedBox(height: 40),

              // 로그아웃 버튼
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutConfirmDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    ),
                  ),
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // 회원탈퇴 버튼
              Center(
                child: TextButton(
                  onPressed: () {
                    // 회원탈퇴 화면으로 이동
                  },
                  child: Text(
                    '회원탈퇴',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 화살표가 있는 섹션 위젯
  Widget _buildSectionWithArrow({
    required BuildContext context,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    if (value != null)
                      SizedBox(height: 4),
                    if (value != null)
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 연결된 계정 섹션 위젯
// 연결된 계정 섹션 위젯
  Widget _buildConnectedAccountsSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '연결된 계정',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryText,
            ),
          ),
          SizedBox(height: 16),

          // 로그인한 이메일 계정 표시 - 이 부분을 제거하고 하나의 계정만 표시
          _buildLoginAccountItem(context),
        ],
      ),
    );
  }

// 로그인 계정 아이템 위젯
// 로그인 계정 아이템 위젯
  Widget _buildLoginAccountItem(BuildContext context) {
    // 로그인 유형에 따라 적절한 이미지와 텍스트 설정
    Widget icon;
    String email = widget.userEmail ?? ""; // 이메일을 직접 사용

    // 로그인 타입에 따라 아이콘 설정
    switch(widget.loginType) {
      case 'google':
        icon = Image.asset(
          'assets/images/google_login_icon.png',
          width: 30,
          height: 30,
        );
        break;
      case 'naver':
        icon = Image.asset(
          'assets/images/naver_login_icon.png',
          width: 30,
          height: 30,
        );
        break;
      case 'kakao':
        icon = Image.asset(
          'assets/images/kakao_login_icon.png',
          width: 30,
          height: 30,
        );
        break;
      default:
        icon = Icon(
          Icons.email,
          color: AppTheme.primaryColor,
          size: 24,
        );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // 아이콘 컨테이너
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: icon),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              email,  // displayName 대신 email 변수 사용
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 동의 설정 섹션 위젯
  Widget _buildConsentSection({
    required BuildContext context,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryText,
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 로그아웃 확인 다이얼로그
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
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 34,
                    color: Colors.red,
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
                          widget.onLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
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
}