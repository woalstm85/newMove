import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

class MoveButton extends StatelessWidget {
  final double height;
  final String title;
  final List<String> subtitles;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String buttonText;
  final bool isWritingInProgress;
  final VoidCallback onTap;

  const MoveButton({
    super.key,
    required this.height,
    required this.title,
    required this.subtitles,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.buttonText,
    required this.isWritingInProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 스크린 너비에 따라 조정
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = screenWidth < 400 ? 16.0 : 16.0;
    final iconSize = screenWidth < 400 ? 22.0 : 22.0;
    final titleSize = screenWidth < 400 ? 20.0 : 20.0;
    final subtitleSize = screenWidth < 400 ? 14.0 : 14.0;
    final buttonTextSize = screenWidth < 400 ? 13.0 : 13.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          boxShadow: [AppTheme.cardShadow],
        ),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 영역: 이사 아이콘 + 작성 중 배지
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      icon,
                      color: primaryColor,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(width: 25),
                  // 작성 중인 경우에만 배지 표시
                  if (isWritingInProgress)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 4.0
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppCopy.draftText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              // 제목
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // 부제목들
              for (var subtitle in subtitles)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const Spacer(),
              // 하단 버튼 (가운데 정렬)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        buttonText,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: buttonTextSize,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}