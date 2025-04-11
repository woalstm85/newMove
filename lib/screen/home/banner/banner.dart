import 'package:flutter/material.dart';
import 'models/banner_model.dart';
import 'data/banner_data.dart';
import 'components/banner_item.dart';

class BannerSection extends StatelessWidget {
  final int currentPage;
  final PageController pageController;
  final Function(int) onPageChanged;

  const BannerSection({
    Key? key,
    required this.currentPage,
    required this.pageController,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<BannerModel> banners = BannerModel.fromJsonList(bannersData);

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // 배너 슬라이더
          PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              onPageChanged(index % banners.length);
            },
            itemBuilder: (context, index) {
              final bannerIndex = index % banners.length;
              return BannerItem(
                banner: banners[bannerIndex],
                index: bannerIndex,
              );
            },
          ),

          // 하단 인디케이터
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  banners.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: currentPage % banners.length == index ? 20.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    decoration: BoxDecoration(
                      color: currentPage % banners.length == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}