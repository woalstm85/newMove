import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

// 모든 화면에서 공통으로 사용할 수 있는 UI 관련 믹스인
mixin CommonUiMixin<T extends StatefulWidget> on State<T> {
  // 공통 앱바 설정
  AppBar buildCommonAppBar({
    required String title,
    bool showBackButton = true,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryText,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      bottom: bottom,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
        onPressed: () => Navigator.of(context).pop(),
      )
          : null,
      actions: actions,
    );
  }

  // 공통 정보 카드
  Widget buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? iconColor,
    bool showBorder = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: showBorder
            ? Border.all(color: AppTheme.borderSubColor, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}




// 로딩 상태 저장을 위한 Mixin
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  // 공통 로딩 위젯
  Widget buildLoadingWidget({
    String? message,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppTheme.primaryColor
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 이사 흐름에서 공통으로 필요한 Mixin
mixin MoveFlowMixin<T extends StatefulWidget> on State<T> {

  bool isRegularMove = true; // 기본값은 true로 설정

  // 이사 유형에 따른 색상 반환
  Color get primaryColor => isRegularMove
      ? AppTheme.primaryColor
      : AppTheme.greenColor;

  // 이사 유형에 따른 그라데이션 반환
  LinearGradient get backgroundGradient => LinearGradient(
    colors: isRegularMove
        ? [AppTheme.primaryColor, Color(0xFF6A92FF)]
        : [AppTheme.greenColor, Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 저장소 키 접두사
  String get keyPrefix => isRegularMove ? 'regular_' : 'special_';
}