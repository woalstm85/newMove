import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/more/sections/subpages/notice/models/notice_model.dart';
import 'package:MoveSmart/screen/more/sections/subpages/notice/constants/notice_constants.dart';

class NoticeItem extends StatelessWidget {
  final NoticeModel notice;
  final bool isExpanded;
  final VoidCallback onTap;

  const NoticeItem({
    Key? key,
    required this.notice,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 날짜 파싱
    final DateTime noticeDate = DateTime.parse(notice.date);
    final bool isRecent = DateTime.now().difference(noticeDate).inDays <= NoticeConstants.recentNoticeDays;

    return Column(
      children: [
        // 공지사항 아이템
        InkWell(
          onTap: onTap,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 태그
                    _buildTag(
                      notice.category,
                      _getCategoryColor(notice.category),
                    ),
                    SizedBox(width: 8),

                    // 중요 표시
                    if (notice.important)
                      _buildTag(
                        NoticeConstants.importantLabel,
                        AppTheme.error,
                      ),

                    // 최신 표시
                    if (isRecent && !notice.important)
                      _buildTag(
                        NoticeConstants.newLabel,
                        AppTheme.success,
                      ),
                  ],
                ),

                SizedBox(height: 8),

                // 제목
                Text(
                  notice.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isExpanded ? FontWeight.bold : FontWeight.w500,
                    color: AppTheme.primaryText,
                  ),
                ),

                SizedBox(height: 8),

                // 날짜 및 확장 아이콘
                Row(
                  children: [
                    Text(
                      _formatDate(notice.date),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppTheme.secondaryText,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 확장된 콘텐츠
        if (isExpanded)
          Container(
            width: double.infinity,
            color: AppTheme.scaffoldBackground,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.content,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.primaryText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // 날짜 포맷팅 함수
  String _formatDate(String dateStr) {
    final DateTime date = DateTime.parse(dateStr);
    return DateFormat('yyyy.MM.dd').format(date);
  }

  // 카테고리 색상 반환 함수
  Color _getCategoryColor(String category) {
    return NoticeConstants.categoryColors[category] ??
        NoticeConstants.defaultCategoryColor;
  }

  // 태그 위젯 생성 함수
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}