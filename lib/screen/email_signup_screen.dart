import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class EmailSignUpScreen extends StatefulWidget {
  const EmailSignUpScreen({super.key});

  @override
  _EmailSignUpScreenState createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
  bool isAgreedTerms = false;
  bool isAgreedPrivacy = false;
  bool isAbove14 = false;
  bool isAgreedOptionalPrivacy = false;
  bool isAgreedPromotions = false;
  bool isAllSelected = false;

  TextEditingController phoneController = TextEditingController();
  TextEditingController authCodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController birthController = TextEditingController();

  bool isPhoneValid = false;
  bool isAuthCodeValid = false;
  bool isEmailValid = false;
  String? selectedGender;
  bool showAuthCode = false;

  // 전체 동의 상태 체크
  void _updateAllSelectedState() {
    setState(() {
      isAllSelected = isAgreedTerms && isAgreedPrivacy && isAbove14 &&
          isAgreedOptionalPrivacy && isAgreedPromotions;
    });
  }

  // 전체 동의 토글
  void toggleAll(bool? value) {
    setState(() {
      isAllSelected = value ?? false;
      isAgreedTerms = isAllSelected;
      isAgreedPrivacy = isAllSelected;
      isAbove14 = isAllSelected;
      isAgreedOptionalPrivacy = isAllSelected;
      isAgreedPromotions = isAllSelected;
    });
  }

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_validateInputs);
    authCodeController.addListener(_validateInputs);
    emailController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    phoneController.dispose();
    authCodeController.dispose();
    emailController.dispose();
    birthController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      // 휴대폰 번호 검증 (숫자만 포함된 10-11자)
      final phoneRegex = RegExp(r'^[0-9]{10,11}$');
      isPhoneValid = phoneRegex.hasMatch(phoneController.text.replaceAll('-', ''));

      // 인증코드 검증 (숫자 6자리)
      final authCodeRegex = RegExp(r'^[0-9]{6}$');
      isAuthCodeValid = authCodeRegex.hasMatch(authCodeController.text);

      // 이메일 검증
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      isEmailValid = emailRegex.hasMatch(emailController.text);
    });
  }

  // 휴대폰 인증 버튼 클릭
  void _requestAuthCode() {
    setState(() {
      showAuthCode = true;
    });
    // 실제로는 여기서 서버에 인증번호 요청 API 호출
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('인증번호가 발송되었습니다'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // 모든 필수 조건이 만족되는지 확인
  bool get _canSignUp {
    return isPhoneValid && isAuthCodeValid && isEmailValid &&
        isAgreedTerms && isAgreedPrivacy && isAbove14;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '이메일로 회원가입',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내 메시지
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.secondaryText,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '정확한 정보를 입력하시면 더 나은 서비스를 제공해 드립니다.',
                        style: TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // 휴대전화 번호 입력
              _buildSectionTitle('휴대전화 번호', required: true),
              SizedBox(height: 4),
              Text(
                '고객님의 확인 없이는 연락처가 공개되지 않습니다.',
                style: TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: phoneController,
                      hintText: '휴대폰 번호 (-없이 입력)',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildButton(
                      text: '인증',
                      onPressed: isPhoneValid ? _requestAuthCode : null,
                      isPrimary: isPhoneValid,
                    ),
                  ),
                ],
              ),

              // 인증코드 입력 (인증번호 요청 시에만 표시)
              if (showAuthCode) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: authCodeController,
                        hintText: '인증번호 입력',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildButton(
                        text: '확인',
                        onPressed: isAuthCodeValid ? () {
                          // 인증번호 확인 로직
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('인증이 완료되었습니다'),
                              backgroundColor: AppTheme.success,
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)
                              ),
                            ),
                          );
                        } : null,
                        isPrimary: isAuthCodeValid,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 24),

              // 이메일 입력
              _buildSectionTitle('이메일', required: true),
              SizedBox(height: 12),
              _buildTextField(
                controller: emailController,
                hintText: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 24),

              // 성별 선택
              _buildSectionTitle('성별', required: false),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSelectButton(
                      title: '남성',
                      isSelected: selectedGender == '남성',
                      onTap: () {
                        setState(() {
                          selectedGender = '남성';
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildSelectButton(
                      title: '여성',
                      isSelected: selectedGender == '여성',
                      onTap: () {
                        setState(() {
                          selectedGender = '여성';
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // 생년월일 입력
              _buildSectionTitle('생년월일', required: false),
              SizedBox(height: 12),
              _buildTextField(
                controller: birthController,
                hintText: 'YYYY.MM.DD',
                keyboardType: TextInputType.datetime,
              ),

              SizedBox(height: 32),

              // 이용약관 동의
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCheckboxItem(
                      title: '이용약관 전체 동의',
                      value: isAllSelected,
                      onChanged: toggleAll,
                      isTitle: true,
                    ),

                    Divider(height: 24, thickness: 1),

                    _buildCheckboxItem(
                      title: '이용약관 동의',
                      value: isAgreedTerms,
                      onChanged: (value) {
                        setState(() {
                          isAgreedTerms = value ?? false;
                          _updateAllSelectedState();
                        });
                      },
                      isRequired: true,
                      showDetail: true,
                    ),

                    SizedBox(height: 16),

                    _buildCheckboxItem(
                      title: '개인정보 수집/이용 동의',
                      value: isAgreedPrivacy,
                      onChanged: (value) {
                        setState(() {
                          isAgreedPrivacy = value ?? false;
                          _updateAllSelectedState();
                        });
                      },
                      isRequired: true,
                      showDetail: true,
                    ),

                    SizedBox(height: 16),

                    _buildCheckboxItem(
                      title: '만 14세 이상 확인',
                      value: isAbove14,
                      onChanged: (value) {
                        setState(() {
                          isAbove14 = value ?? false;
                          _updateAllSelectedState();
                        });
                      },
                      isRequired: true,
                    ),

                    SizedBox(height: 16),

                    _buildCheckboxItem(
                      title: '개인정보 수집/이용 동의',
                      value: isAgreedOptionalPrivacy,
                      onChanged: (value) {
                        setState(() {
                          isAgreedOptionalPrivacy = value ?? false;
                          _updateAllSelectedState();
                        });
                      },
                      isRequired: false,
                      showDetail: true,
                    ),

                    SizedBox(height: 16),

                    _buildCheckboxItem(
                      title: '이벤트 및 할인쿠폰 등 혜택/정보 수신',
                      value: isAgreedPromotions,
                      onChanged: (value) {
                        setState(() {
                          isAgreedPromotions = value ?? false;
                          _updateAllSelectedState();
                        });
                      },
                      isRequired: false,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // 회원가입 버튼
              _buildButton(
                text: '회원가입 완료',
                onPressed: _canSignUp ? () {
                  // 회원가입 완료 처리
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('회원가입이 완료되었습니다'),
                      backgroundColor: AppTheme.success,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );

                  // 회원가입 완료 후 로그인 화면으로 돌아가기
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.pop(context);
                  });
                } : null,
                isPrimary: _canSignUp,
                isFullWidth: true,
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 섹션 제목 위젯
  Widget _buildSectionTitle(String title, {bool required = false}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  // 텍스트 필드 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.subtleText),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
        ),
      ),
    );
  }

  // 버튼 위젯
  Widget _buildButton({
    required String text,
    VoidCallback? onPressed,
    bool isPrimary = true,
    bool isFullWidth = false,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppTheme.primaryColor : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AppTheme.primaryText,
          disabledBackgroundColor: Colors.grey.shade200,
          disabledForegroundColor: Colors.grey.shade500,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isPrimary ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 선택 버튼 위젯 (성별 선택 등)
  Widget _buildSelectButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppTheme.primaryText,
          ),
        ),
      ),
    );
  }

  // 체크박스 아이템 위젯
  Widget _buildCheckboxItem({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
    bool isRequired = false,
    bool isTitle = false,
    bool showDetail = false,
  }) {
    return Row(
      children: [
        // 체크박스
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),

        SizedBox(width: 12),

        // 텍스트
        Expanded(
          child: Text(
            isRequired ? '[필수] $title' : (isTitle ? title : '[선택] $title'),
            style: TextStyle(
              fontSize: isTitle ? 16 : 14,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
              color: isTitle ? AppTheme.primaryText : AppTheme.secondaryText,
            ),
          ),
        ),

        // 상세보기 아이콘
        if (showDetail)
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppTheme.secondaryText,
          ),
      ],
    );
  }
}