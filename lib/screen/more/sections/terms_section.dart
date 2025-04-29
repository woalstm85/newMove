import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/more/models/menu_item_model.dart';
import 'package:MoveSmart/screen/more/widgets/menu_tile.dart';
import 'package:MoveSmart/screen/more/constants/more_screen_constants.dart';

// 수정된 import 경로
import 'package:MoveSmart/screen/more/sections/subpages/terms/terms_service_screen.dart';

class TermsSection extends StatelessWidget {
  const TermsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 약관 메뉴 섹션 생성
    final termsMenuSection = MenuSection(
      title: MoreScreenText.termsTitle,
      items: [
        MenuItem(
          icon: Icons.description_outlined,
          iconColor: Colors.grey,
          title: MoreScreenText.termsOfServiceTitle,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TermsOfServiceScreen()),
            );
          },
          showSubtitle: false,
        ),
        MenuItem(
          icon: Icons.security,
          iconColor: Colors.grey,
          title: MoreScreenText.privacyPolicyTitle,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TermsOfServiceScreen(initialIndex: 1),
              ),
            );
          },
          showSubtitle: false,
        ),
      ],
    );

    return MenuSectionWidget(section: termsMenuSection);
  }
}