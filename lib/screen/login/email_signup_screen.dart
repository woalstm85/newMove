import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/more/sections/terms_service.dart';
import 'package:MoveSmart/screen/login/marketing_consent_screen.dart';
import 'package:MoveSmart/screen/login/third_party_consent_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/providers/auth_provider.dart';
import 'package:MoveSmart/screen/navigation/bottom_navigation.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class EmailSignUpScreen extends ConsumerStatefulWidget {
  const EmailSignUpScreen({super.key});

  @override
  ConsumerState<EmailSignUpScreen> createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends ConsumerState<EmailSignUpScreen> {
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
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isPhoneValid = false;
  bool isAuthCodeValid = false;
  bool isEmailValid = false;
  String? selectedGender;
  bool showAuthCode = false;
  bool isPasswordValid = false;
  bool isPasswordMatched = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? passwordError;

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
    passwordController.addListener(_validateInputs);
    confirmPasswordController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    phoneController.dispose();
    authCodeController.dispose();
    emailController.dispose();
    birthController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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

      // 비밀번호 검증 (8자 이상, 문자/숫자 조합)
      final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
      isPasswordValid = passwordRegex.hasMatch(passwordController.text);

      // 비밀번호 일치 여부 확인
      isPasswordMatched = passwordController.text == confirmPasswordController.text
          && passwordController.text.isNotEmpty;
    });
  }

  // 휴대폰 인증 버튼 클릭
  void _requestAuthCode() {
    setState(() {
      showAuthCode = true;
      // 개발 테스트를 위해 인증번호 필드를 검증 완료 상태로 설정
      authCodeController.text = "123456";
    });
    // 실제로는 여기서 서버에 인증번호 요청 API 호출
    context.showSnackBar('인증번호가 발소되었습니다.', isError: false);
  }

  // 모든 필수 조건이 만족되는지 확인
  bool get _canSignUp {
    // 개발 테스트를 위해 조건을 완화 (인증코드 및 휴대폰 조건 제외)
    return isEmailValid && isPasswordValid && isPasswordMatched &&
        isAgreedTerms && isAgreedPrivacy && isAbove14;
  }

  // 마케팅 동의 확인 다이얼로그 표시
  Future<void> _showMarketingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.scaffoldBackground,
          title: Text(
            '마케팅 정보 수신 안내',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '현재 진행 중인 이벤트를 참여해도 아무런 혜택을 받을 수 없어요. 선택 항목에 동의하시겠어요?',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '아니오',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // 다음으로 제3자 동의 다이얼로그 표시
                _showThirdPartyDialog();
              },
            ),
            ElevatedButton(
              child: Text('네'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isAgreedOptionalPrivacy = true;
                  _updateAllSelectedState();
                });
                // 다음으로 제3자 동의 다이얼로그 표시
                _showThirdPartyDialog();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  // 제3자 정보 제공 동의 다이얼로그 표시
  Future<void> _showThirdPartyDialog() async {
    if (!mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.scaffoldBackground,
          title: Text(
            '제3자 정보 제공 안내',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '이벤트 참여 후 쿠폰 발송 업체에서 쿠폰 제공이 불가능해요. 선택 항목에 동의 하시겠어요?',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '아니오',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _completeSignUp();
              },
            ),
            ElevatedButton(
              child: Text('네'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isAgreedPromotions = true;
                  _updateAllSelectedState();
                });
                _completeSignUp();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  // 회원가입 완료 처리
  void _completeSignUp() {
    if (!mounted) return;

    // 회원가입 정보 저장 및 상태 업데이트
    final email = emailController.text;
    final phone = phoneController.text;
    final password = passwordController.text;

    // 각종 동의 상태 저장
    ref.read(authProvider.notifier).setInitialConsents(
      marketing: isAgreedOptionalPrivacy,
      thirdParty: isAgreedPromotions,
    );

    // 로그인 상태 업데이트
    ref.read(authProvider.notifier).login(
      email,
      loginType: 'email',
      phone: phone,
      password: password,
    );

    // 성공 메시지 표시
    context.showSnackBar('회원가입이 완료되었습니다.', isError: false);

    // 회원가입 완료 후 메인 화면으로 이동
    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;

      // 미리 로드할 데이터 (빈 데이터로 시작)
      Map<String, dynamic> preloadedData = {
        'reviews': [],
        'partners': [],
        'stories': [],
      };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BottomNavigationBarWidget(
            initialIndex: 4, // 더보기 탭으로 이동
            preloadedData: preloadedData,
          ),
        ),
      );
    });
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
                      onPressed: _requestAuthCode, // 테스트를 위해 항상 활성화
                      isPrimary: true,
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
                        onPressed: () {
                          // 인증번호 확인 로직
                          context.showSnackBar('인증이 완료되었습니다.', isError: false);
                        },
                        isPrimary: true,
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

              // 비밀번호 입력
              _buildSectionTitle('비밀번호', required: true),
              SizedBox(height: 4),
              Text(
                '8자 이상의 영문, 숫자 조합으로 입력해주세요',
                style: TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 12),
              _buildPasswordField(
                controller: passwordController,
                hintText: '비밀번호',
                obscureText: _obscurePassword,
                toggleObscure: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                errorText: passwordError,
              ),

              SizedBox(height: 16),

              // 비밀번호 확인
              _buildPasswordField(
                controller: confirmPasswordController,
                hintText: '비밀번호 확인',
                obscureText: _obscureConfirmPassword,
                toggleObscure: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                errorText: isPasswordMatched || confirmPasswordController.text.isEmpty
                    ? null
                    : '비밀번호가 일치하지 않습니다',
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
                    // 이용약관 동의
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
                      onTapDetail: () {
                        // 이용약관 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsOfServiceScreen(initialIndex: 0),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 16),

                    // 개인정보 수집/이용 동의
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
                      onTapDetail: () {
                        // 개인정보 처리방침 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsOfServiceScreen(initialIndex: 1),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 16),

                    // 만 14세 이상 확인
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

                    // 마케팅 활용 동의 부분 수정 (설명 문구 추가)
                    _buildCheckboxItem(
                      title: '마케팅 활용 동의',
                      value: isAgreedOptionalPrivacy,
                      onChanged: (value) {
                        setState(() {
                          isAgreedOptionalPrivacy = value ?? false;
                          _updateAllSelectedState();
                        });
                      },
                      isRequired: false,
                      showDetail: true,
                      onTapDetail: () {
                        // 마케팅 활용 동의 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MarketingConsentScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 16),

                    // 제3자 정보 제공 동의 부분
                    _buildCheckboxItem(
                      title: '제3자 정보 제공 동의',
                      value: isAgreedPromotions,
                      onChanged: (value) {
                        setState(() {
                          isAgreedPromotions = value ?? false;
                          _updateAllSelectedState();
                        });
                      },
                      isRequired: false,
                      showDetail: true,
                      onTapDetail: () {
                        // 제3자 정보 제공 동의 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThirdPartyConsentScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32),

              // 회원가입 버튼
              _buildButton(
                text: '회원가입 완료',
                onPressed: _canSignUp ? () {
                  // 마케팅 동의를 하지 않은 경우
                  if (!isAgreedOptionalPrivacy) {
                    _showMarketingDialog();
                  }
                  // 마케팅 동의를 했지만 제3자 동의를 하지 않은 경우
                  else if (!isAgreedPromotions) {
                    _showThirdPartyDialog();
                  }
                  // 둘 다 동의한 경우
                  else {
                    _completeSignUp();
                  }
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

  // 비밀번호 필드 위젯
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback toggleObscure,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        errorText: errorText,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.secondaryText,
          ),
          onPressed: toggleObscure,
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
    VoidCallback? onTapDetail,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              GestureDetector(
                onTap: onTapDetail,
                child: Container(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Text(
                        '보기',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppTheme.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}