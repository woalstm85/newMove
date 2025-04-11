import 'package:flutter/material.dart';
import 'package:MoveSmart/screen/home/story/story_webview.dart';
import 'package:MoveSmart/theme/theme_constants.dart';

class StorySlider extends StatelessWidget {
  final List<dynamic> stories;
  final bool isLoading;

  const StorySlider({
    super.key,
    required this.stories,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (stories.isEmpty) {
      return _buildEmptyState();
    }

    return _buildStoryList(context);
  }

  // 로딩 상태 UI
  Widget _buildLoadingState() {
    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              '스토리를 불러오는 중입니다...',
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 스토리 없음 상태 UI
  Widget _buildEmptyState() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 48,
            color: AppTheme.subtleText,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 등록된 스토리가 없습니다',
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '곧 새로운 스토리로 찾아뵙겠습니다!',
            style: TextStyle(
              color: AppTheme.subtleText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _openWebView(BuildContext context, String blogUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(blogUrl: blogUrl),
      ),
    );
  }

  // 스토리 리스트 UI
  Widget _buildStoryList(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          final String imageUrl = story['imgUrl'] ?? '';
          final String title = story['title'] ?? '제목 없음';
          final int viewCount = story['clickCnt'] ?? 0;
          final String blogUrl = story['blogUrl'] ?? '';

          return GestureDetector(
            onTap: () => _openWebView(context, blogUrl),
            child: Container(
              width: 280,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 12,
                right: 12,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [AppTheme.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.cardRadius),
                      topRight: Radius.circular(AppTheme.cardRadius),
                    ),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          width: double.infinity,
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppTheme.primaryColor.withOpacity(0.5),
                              size: 48,
                            ),
                          ),
                        );
                      },
                    )
                        : Container(
                      height: 160,
                      width: double.infinity,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppTheme.primaryColor.withOpacity(0.5),
                          size: 48,
                        ),
                      ),
                    ),
                  ),

                  // 콘텐츠 영역
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // 조회수
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 14,
                              color: AppTheme.subtleText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$viewCount회 조회',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.subtleText,
                              ),
                            ),

                            const Spacer(),

                            // '자세히 보기' 버튼
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '자세히 보기',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.open_in_new,
                                    size: 10,
                                    color: AppTheme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}