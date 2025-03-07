import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  // 알림 데이터 로드 (실제로는 API에서 가져올 것)
  void _initNotifications() {

    // 알림 샘플 데이터
    final List<Map<String, dynamic>> notificationData = [
      {
        'id': '1',
        'title': '견적 요청 승인',
        'message': '홍길동님이 요청하신 이사 견적이 파트너에 의해 승인되었습니다. 상세 내용을 확인해보세요.',
        'type': 'quote',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': '2',
        'title': '이벤트 알림',
        'message': '봄맞이 이사 할인 이벤트가 시작되었습니다. 최대 20% 할인 혜택을 놓치지 마세요!',
        'type': 'event',
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '3',
        'title': '파트너 매칭 완료',
        'message': '요청하신 이사 서비스에 최적의 파트너가 매칭되었습니다. 확인해보세요.',
        'type': 'match',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '4',
        'title': '리뷰 작성 요청',
        'message': '최근 이용하신 서비스에 대한 리뷰를 작성해주세요. 리뷰 작성 시 포인트가 적립됩니다.',
        'type': 'review',
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 4)),
      },
    ];

    _notifications = notificationData;
  }

  // 알림 읽음 처리
  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((notification) => notification['id'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  // 모든 알림 읽음 처리
  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '모든 알림을 읽음 처리했습니다.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 알림 삭제
  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((notification) => notification['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '알림이 삭제되었습니다.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 타임스탬프 포맷팅
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      // 7일 이상 지난 경우 날짜 표시
      return '${timestamp.year}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.day.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      // 1일 이상 7일 미만인 경우
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      // 1시간 이상 24시간 미만인 경우
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      // 1분 이상 60분 미만인 경우
      return '${difference.inMinutes}분 전';
    } else {
      // 1분 미만인 경우
      return '방금 전';
    }
  }

  // 알림 타입에 따른 아이콘 가져오기
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'quote':
        return Icons.description_outlined;
      case 'event':
        return Icons.celebration_outlined;
      case 'match':
        return Icons.handshake_outlined;
      case 'review':
        return Icons.rate_review_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  // 알림 타입에 따른 색상 가져오기
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'quote':
        return AppTheme.primaryColor;
      case 'event':
        return AppTheme.warning;
      case 'match':
        return AppTheme.success;
      case 'review':
        return AppTheme.secondaryColor;
      default:
        return AppTheme.subtleText;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 읽지 않은 알림 개수
    final int unreadCount = _notifications.where((notification) => notification['isRead'] == false).length;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          '알림',
          style: AppTheme.headingStyle.copyWith(
            fontSize: 18,
            color: AppTheme.primaryText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              '모두 읽음',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyView()
          : _buildNotificationList(unreadCount),
    );
  }

  // 로딩 뷰
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            '알림을 불러오는 중입니다...',
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 빈 알림 뷰
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppTheme.subtleText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '알림이 없습니다',
            style: TextStyle(
              color: AppTheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 알림이 도착하면 여기에 표시됩니다',
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 알림 목록 뷰
  Widget _buildNotificationList(int unreadCount) {
    return CustomScrollView(
      slivers: [
        // 읽지 않은 알림 개수 표시
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppTheme.scaffoldBackground,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: unreadCount > 0
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : AppTheme.subtleText.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '읽지 않은 알림 $unreadCount건',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: unreadCount > 0
                          ? AppTheme.primaryColor
                          : AppTheme.subtleText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 알림 목록
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final notification = _notifications[index];
              final bool isRead = notification['isRead'];
              final String id = notification['id'];
              final String title = notification['title'];
              final String message = notification['message'];
              final String type = notification['type'];
              final DateTime createdAt = notification['createdAt'];
              final Color notificationColor = _getNotificationColor(type);
              final IconData notificationIcon = _getNotificationIcon(type);

              return Column(
                children: [
                  // 날짜 구분선 (첫 번째 알림이거나 이전 알림과 날짜가 다른 경우)
                  if (index == 0 ||
                      !_isSameDay(_notifications[index - 1]['createdAt'], createdAt))
                    _buildDateDivider(createdAt),

                  // 알림 항목
                  Dismissible(
                    key: Key(id),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteNotification(id);
                    },
                    child: GestureDetector(
                      onTap: () {
                        if (!isRead) {
                          _markAsRead(id);
                        }
                        // 알림 상세 화면으로 이동 로직 (여기서는 생략)
                      },
                      child: Container(
                        color: isRead ? Colors.white : AppTheme.primaryColor.withOpacity(0.03),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 알림 아이콘
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: notificationColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                notificationIcon,
                                color: notificationColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // 알림 내용
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                            fontSize: 15,
                                            color: AppTheme.primaryText,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        _formatTimestamp(createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.subtleText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.secondaryText,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  // 읽지 않은 알림인 경우 표시
                                  if (!isRead)
                                    Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '읽지 않음',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 구분선
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.subtleText.withOpacity(0.1),
                  ),
                ],
              );
            },
            childCount: _notifications.length,
          ),
        ),
      ],
    );
  }

  // 날짜 구분선
  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    String dateText;

    if (_isSameDay(now, date)) {
      dateText = '오늘';
    } else if (_isSameDay(now.subtract(const Duration(days: 1)), date)) {
      dateText = '어제';
    } else {
      dateText = '${date.year}.${date.month}.${date.day}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: AppTheme.scaffoldBackground,
      alignment: Alignment.centerLeft,
      child: Text(
        dateText,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppTheme.secondaryText,
        ),
      ),
    );
  }

  // 같은 날짜인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}