import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/more/constants/more_screen_constants.dart';

class AppInfoSection extends StatelessWidget {
  const AppInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        // 데이터 로딩 중이면 로딩 표시
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 데이터 가져오기 성공하면 정보 표시
        final PackageInfo packageInfo = snapshot.data!;
        final String appName = packageInfo.appName;
        final String version = packageInfo.version;
        final String buildNumber = packageInfo.buildNumber;

        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              const Divider(
                color: Color(0xFFEEEEEE),
                thickness: 1,
              ),
              const SizedBox(height: 16),

              // 앱 로고 또는 아이콘
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/icon/app_icon.png', // 앱 아이콘 경로
                  width: 48,
                  height: 48,
                ),
              ),
              const SizedBox(height: 12),

              // 앱 이름
              Text(
                appName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 4),

              // 버전 정보
              Text(
                'v$version ($buildNumber)',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 20),

              // 회사 정보
              Text(
                MoreScreenText.copyright,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.subtleText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}