import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/home/banner/models/banner_model.dart';
import 'package:MoveSmart/screen/home/banner/banner_detail.dart';

class BannerItem extends StatelessWidget {
  final BannerModel banner;
  final int index;

  const BannerItem({
    Key? key,
    required this.banner,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 배경 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: Image.asset(
            banner.imagePath,
            fit: BoxFit.cover,
          ),
        ),

        // 배너 내용
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 제목
              Text(
                banner.title,
                style: TextStyle(
                  color: banner.titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // 부제목
              Text(
                banner.subtitle,
                style: TextStyle(
                  color: banner.subtitleColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // 버튼
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BannerDetailScreen(bannerIndex: index),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: banner.buttonColor,
                  foregroundColor: banner.buttonTextColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  banner.buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}