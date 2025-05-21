import 'package:flutter/material.dart';

// 앱 전체에서 사용할 색상 테마 정의
class AppTheme {
  // 주요 색상
  static const Color primaryColor = Color(0xFF4E7CFF); // 주요 색상 (파란색 계열)
  static const Color secondaryColor = Color(0xFFFF9045); // 보조 색상 (주황색 계열)
  static const Color accentColor = Color(0xFF8864EF); // 강조 색상 (보라색 계열)
  static const Color greenColor = Color(0xFF009688); // 강조 색상 (녹색 계열)

  // 주요 색상
  static const Color primarySubColor = Color(0xFFF2F7FA); // 주요 색상 (파란색 계열)
  static const Color secondarySubColor = Color(0xFFF3F2FA); // 보조 색상 (주황색 계열)
  static const Color accentSubColor = Color(0xFFCCC1F1); // 강조 색상 (보라색 계열)
  static const Color greenSubColor = Color(0xFFF4FBF4); // 강조 색상 (녹색 계열)

  // 배경 색상
  static const Color scaffoldBackground = Color(0xFFFAFAFC); // 연한 그레이 배경
  static const Color cardBackground = Colors.white; // 카드 배경색

  // 텍스트 색상
  static const Color primaryText = Color(0xFF2E384D); // 주요 텍스트 색상
  static const Color secondaryText = Color(0xFF8798AD); // 부가 텍스트 색상
  static const Color subtleText = Color(0xFFB7C2D0); // 부드러운 텍스트 색상

  // 상태 색상
  static const Color success = Color(0xFF3ECF8E); // 성공 상태 색상
  static const Color warning = Color(0xFFFFB445); // 경고 상태 색상
  static const Color error = Color(0xFFFF5C5C); // 에러 상태 색상

  // 그라데이션 정의
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 테두리 및 구분선 색상
  static const Color borderColor = Color(0xFFEEF0F5);
  static const Color borderSubColor = Color(0xFFE8E8E8);
  static const Color borderSSubColor = Color(0xFFDFDFDF);
  // 그림자 효과
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.05),
    spreadRadius: 0,
    blurRadius: 10,
    offset: const Offset(0, 5),
  );

  // 라운드 값 정의
  static const double borderRadius = 12.0;
  static const double cardRadius = 16.0;

  // 텍스트 스타일 정의
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: primaryText,
    height: 1.3,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryText,
    height: 1.3,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: primaryText,
    height: 1.5,
  );

  static const TextStyle captionStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: secondaryText,
    height: 1.4,
  );

  // 애니메이션 정의
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;

  // 버튼 스타일
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    textStyle: const TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    elevation: 0,
  );

  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    textStyle: const TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    side: const BorderSide(color: primaryColor, width: 1.5),
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
}

// 앱 내에서 사용할 문구 모음
class AppCopy {
  // 섹션 제목
  static const String monthlyPartnerTitle = '이달의 파트너';
  static const String monthlyStoryTitle = '이달의 스토리';
  static const String reviewSectionTitle = '고객님들의 생생한 후기';

  // 서비스 관련 문구
  static const String moveServiceTitle = '이사 서비스';
  static const String moveServiceSubtitle = '편안한 이사를 위한 첫 걸음';
  static const String draftText = '작성 중';

  // 파트너 선정 관련 문구
  static const String partnerSelectionInfo = '디딤돌은 파트너를 어떻게 선정할까?';
  static const String partnerQualityPromise = '검증된 파트너만 소개해 드립니다';

  // 사용자 행동 유도 문구
  static const String startServiceCTA = '지금 바로 시작하세요';
  static const String viewMoreReviews = '모든 후기 보기';
  static const String registerMoveCTA = '이사 등록하기';

  // 리뷰 관련 문구
  static const String reviewPlaceholder = '아직 리뷰가 없습니다';
  static const String reviewRating = '평점';

  // 회사 정보 관련 문구
  static const String companyName = '주식회사 디딤돌';
  static const String companyMotto = '편안한 이사를 위한 모든 서비스';
  static const String trustStatement = '신뢰할 수 있는 이사 파트너를 만나보세요';
}