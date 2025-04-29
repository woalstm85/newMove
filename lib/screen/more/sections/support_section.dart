import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/more/models/menu_item_model.dart';
import 'package:MoveSmart/screen/more/widgets/menu_tile.dart';
import 'package:MoveSmart/screen/more/constants/more_screen_constants.dart';

// 수정된 import 경로
import 'package:MoveSmart/screen/more/sections/subpages/notice/notice_screen.dart';
import 'package:MoveSmart/screen/more/sections/subpages/faq/faq_screen.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({Key? key}) : super(key: key);

  // URL을 여는 함수
  void _launchURL(BuildContext context) async {
    final String kakaoChatUrl = dotenv.env['KAKAO_CHAT_URL'] ?? 'http://pf.kakao.com/_ZxkbmG/chat';
    final Uri url = Uri.parse(kakaoChatUrl);

    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(MoreScreenText.kakaoErrorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 고객 지원 메뉴 아이템 생성
    final supportMenuSection = MenuSection(
      title: MoreScreenText.customerSupportTitle,
      items: [
        MenuItem(
          icon: Icons.campaign_outlined,
          iconColor: AppTheme.primaryColor,
          title: MoreScreenText.noticeTitle,
          subtitle: MoreScreenText.noticeSubtitle,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NoticeScreen()),
            );
          },
        ),
        MenuItem(
          icon: Icons.question_answer_outlined,
          iconColor: AppTheme.accentColor,
          title: MoreScreenText.faqTitle,
          subtitle: MoreScreenText.faqSubtitle,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FAQScreen()),
            );
          },
        ),
        MenuItem(
          icon: Icons.support_agent,
          iconColor: Colors.yellow[700]!,
          title: MoreScreenText.inquiryTitle,
          subtitle: MoreScreenText.inquirySubtitle,
          onTap: () {
            _launchURL(context);
          },
        ),
      ],
    );

    return MenuSectionWidget(section: supportMenuSection);
  }
}