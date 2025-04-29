import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/providers/auth_provider.dart';

// 각 섹션 위젯 불러오기
import 'package:MoveSmart/screen/more/sections/profile_section.dart';
import 'package:MoveSmart/screen/more/sections/assurance_section.dart';
import 'package:MoveSmart/screen/more/sections/coupon_section.dart';
import 'package:MoveSmart/screen/more/sections/support_section.dart';
import 'package:MoveSmart/screen/more/sections/terms_section.dart';
import 'package:MoveSmart/screen/more/sections/app_info_section.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 인증 상태 가져오기
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
              ProfileSection(
                isLoggedIn: isLoggedIn,
                userEmail: userEmail,
              ),

              // 안심 서비스 안내 섹션
              const AssuranceSection(),

              // 쿠폰 & 초대 섹션
              CouponSection(isLoggedIn: isLoggedIn),

              SizedBox(height: context.defaultPadding),

              // 고객 지원 섹션
              const SupportSection(),

              SizedBox(height: context.defaultPadding),

              // 약관 섹션
              const TermsSection(),

              SizedBox(height: context.defaultPadding),

              // 앱 버전 정보
              const AppInfoSection(),

              SizedBox(height: context.defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}