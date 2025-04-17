import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import 'dart:math' as math;

// Context 확장 - 반응형 디자인 및 테마 관련 메서드
extension ContextExtension on BuildContext {
  // 미디어 쿼리 접근자
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  // 화면 크기 관련
  double get screenHeight => mediaQuery.size.height;
  double get screenWidth => mediaQuery.size.width;

  // 화면 방향 확인
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  // 현재 디바이스가 태블릿인지 확인 (가로 너비 600 이상을 태블릿으로 간주)
  bool get isTablet => screenWidth >= 600;

  // 테마 접근자
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  // 이사 유형에 따른 색상 설정을 위한 메서드
  Color primaryColorForMoveType(bool isRegularMove) =>
      isRegularMove ? AppTheme.primaryColor : AppTheme.greenColor;

  // 화면 크기 기반 여백 계산
  double get defaultPadding => screenWidth * 0.04;
  double get smallPadding => defaultPadding * 0.5; // 기존 screenWidth * 0.02 대신
  double get largePadding => defaultPadding * 1.5; // 기존 screenWidth * 0.06 대신


  // 화면 크기에 따른 스케일링 - 캐싱 없이 직접 계산
  double get scaleFactor => math.min(screenWidth / 375, 1.2);

  double scaleValue(double baseValue) => baseValue * scaleFactor;


  // 화면 크기에 따른 폰트 사이즈 조정
  double scaledFontSize(double baseFontSize) {
    return scaleValue(baseFontSize);
  }

  // 화면의 세이프 영역 고려
  EdgeInsets get safePadding => mediaQuery.padding;
  double get safeTopPadding => safePadding.top;
  double get safeBottomPadding => safePadding.bottom;

  // 바텀 시트 높이 계산
  double get bottomSheetDefaultHeight => screenHeight * 0.75;
  double get bottomSheetMediumHeight => screenHeight * 0.5;
  double get bottomSheetSmallHeight => screenHeight * 0.3;

  // SnackBar 표시
  void showSnackBar(
      String message, {
        bool isError = false,
        Duration duration = const Duration(milliseconds: 1000), // 기본값 1초
      }) {
    // 현재 표시된 모든 SnackBar 제거
    ScaffoldMessenger.of(this).removeCurrentSnackBar();

    // 새 SnackBar 표시
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.primaryText,
        behavior: SnackBarBehavior.floating,
        duration: duration, // 명시적으로 지속 시간 설정
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),

      ),
    );
  }

  // 로딩 다이얼로그 표시
  void showLoadingDialog({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            SizedBox(width: 20),
            Text(message ?? '처리 중입니다...'),
          ],
        ),
      ),
    );
  }

  // 디바이스 화면에 따른 그리드 열 수 계산
  int get optimalGridColumns {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    return 4;
  }
}

// 이사 주소 관련 유용한 확장 기능
extension MoveAddressExtension on Map<String, dynamic> {
  // 주소와 상세 주소를 조합하여 전체 주소 반환
  String get fullAddress => '${this['address']} ${this['detailAddress']}';

  // 주소에 대한 요약 정보 반환
  String get addressSummary => '${this['buildingType']} | '
      '${this['roomStructure']} | '
      '${this['roomSize']} | '
      '${this['floor']}';

  // 엘리베이터 정보 문자열 반환
  String get elevatorInfo => this['hasElevator'] ? '엘리베이터 있음' : '엘리베이터 없음';

  // 계단 정보 문자열 반환
  String get stairsInfo => this['hasStairs'] ? '1층 계단 있음' : '1층 계단 없음';

  // 주차 정보 문자열 반환
  String get parkingInfo => this['parkingAvailable'] ? '주차 가능' : '주차 불가';
}

// 텍스트 스타일 확장

extension TextStyleExtension on BuildContext {
  TextStyle titleStyle({Color? color}) => TextStyle(
    fontSize: scaledFontSize(16),
    fontWeight: FontWeight.bold,
    color: color ?? AppTheme.primaryText,
  );

  TextStyle bodyStyle({Color? color}) => TextStyle(
    fontSize: scaledFontSize(14),
    color: color ?? AppTheme.primaryText,
  );

  TextStyle subtitleStyle({Color? color}) => TextStyle(
    fontSize: scaledFontSize(14),
    fontWeight: FontWeight.bold,
    color: color ?? AppTheme.primaryText,
  );

  TextStyle captionStyle({Color? color}) => TextStyle(
    fontSize: scaledFontSize(12),
    color: color ?? AppTheme.secondaryText,
  );

  TextStyle labelStyle({Color? color}) => TextStyle(
    fontSize: scaledFontSize(14),
    color: color ?? AppTheme.secondaryText,
  );

  TextStyle labelSSubStyle({Color? color}) => TextStyle(
    fontSize: scaledFontSize(13),
    color: color ?? AppTheme.secondaryText,
  );

  TextStyle valueStyle({Color? color}) => TextStyle(
    fontSize: scaledFontSize(14),
    fontWeight: FontWeight.w500,
    color: color ?? AppTheme.primaryText,
  );

  TextStyle labelSubStyle({Color? color}) => TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: color ?? AppTheme.success,
  );
}

// 카드 장식 확장
extension CardDecorationExtension on BuildContext {
  BoxDecoration cardDecoration({Color? borderColor}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      border: borderColor != null ? Border.all(
        width: 1,
        color: borderColor,
      ) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  BoxDecoration tagDecoration(Color color) => BoxDecoration(
    color: color.withOpacity(0.08),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: color.withOpacity(0.2),
    ),
  );
}

extension PhoneNumberExtension on String {
  // 전화번호 포맷팅 메서드
  String formatPhoneNumber() {
    // 숫자만 추출
    String digits = replaceAll(RegExp(r'\D'), '');

    // 번호가 11자리(010으로 시작)인지 확인
    if (digits.length == 11 && digits.startsWith('010')) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }

    // 10자리 번호의 경우 (예: 지역번호 포함)
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    // 포맷팅이 불가능한 경우 원래 문자열 반환
    return this;
  }
}