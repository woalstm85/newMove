import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/screen/more/constants/more_screen_constants.dart';
import 'package:MoveSmart/screen/more/models/menu_item_model.dart';
import 'package:MoveSmart/screen/more/widgets/menu_tile.dart';
import 'package:MoveSmart/screen/login/login_screen.dart';

class CouponSection extends StatelessWidget {
  final bool isLoggedIn;

  const CouponSection({
    Key? key,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 쿠폰 & 초대 메뉴 아이템 생성
    final MenuItem inviteFriendsItem = MenuItem(
      icon: Icons.share,
      iconColor: Colors.green,
      title: MoreScreenText.inviteFriendsTitle,
      subtitle: MoreScreenText.inviteFriendsSubtitle,
      onTap: () {
        // 비로그인 상태면 로그인 화면으로 이동
        if (!isLoggedIn) {
          _navigateToLogin(context);
          return;
        }
        // 초대 기능 실행 (로그인 상태인 경우)
        _showInviteFriendsDialog(context);
      },
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: context.cardDecoration(borderColor: AppTheme.borderColor),
      child: MenuTile(item: inviteFriendsItem),
    );
  }

  // 로그인 화면으로 이동하는 함수
  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  // 친구 초대 기능 다이얼로그
  void _showInviteFriendsDialog(BuildContext context) {
    // 여기에 친구 초대 관련 다이얼로그나 기능 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('친구 초대'),
        content: Text('친구에게 초대 링크를 공유하고 쿠폰을 받아보세요!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 초대 링크 공유 기능 구현
              Navigator.pop(context);
            },
            child: Text('공유하기'),
          ),
        ],
      ),
    );
  }
}