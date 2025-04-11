import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'data/banner_data.dart';

class BannerDetailScreen extends StatelessWidget {
  final int bannerIndex;

  const BannerDetailScreen({
    Key? key,
    required this.bannerIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 현재 배너 데이터
    final currentBanner = bannersData[bannerIndex];
    final Color bannerColor = getColor(currentBanner['bgColor'].toString());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // 상단 배너 이미지 및 텍스트
          ClipRRect(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 배경 이미지
                  Image.asset(
                    currentBanner['imagePath'] as String,
                    fit: BoxFit.cover,
                  ),

                  // 오버레이 (약간의 그라데이션으로 텍스트가 더 잘 보이게)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),

                  // 배너 내용
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        // 제목
                        Text(
                          currentBanner['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 부제목
                        Text(
                          currentBanner['description'] as String,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          // 하단 콘텐츠: 흰색 배경에 혜택 아이템들
          Expanded(
            child: Container(
              color: AppTheme.scaffoldBackground,
              child: Column(
                children: [
                  // 혜택 리스트
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: (currentBanner['benefitItems'] as List).length,
                      itemBuilder: (context, index) {
                        final benefitItem = (currentBanner['benefitItems'] as List)[index];
                        final IconData iconData = getIconData(benefitItem['icon'].toString());

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: bannerColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                iconData,
                                color: bannerColor,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              benefitItem['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                benefitItem['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 하단 참여 버튼
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // ui_extensions.dart의 showSnackBar 사용
                          context.showSnackBar('이벤트 참여가 완료되었습니다.');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bannerColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '이벤트 참여하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}