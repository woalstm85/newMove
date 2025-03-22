import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

class BannerDetailScreen extends StatelessWidget {
  final int bannerIndex;

  const BannerDetailScreen({
    Key? key,
    required this.bannerIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 배너 상세 데이터
    final List<Map<String, dynamic>> bannerDetails = [
      {
        // 친구 초대 이벤트
        'imagePath': 'assets/banners/banner1.png',
        'bgColor': const Color(0xFF00704A), // 스타벅스 녹색
        'title': '친구 초대하고\n커피 한잔의 여유를!',
        'description': '친구에게 이사를 추천하고\n스타벅스 아메리카노를\n받아보세요',
        'benefitItems': [
          {
            'icon': Icons.card_giftcard,
            'title': '이벤트 혜택',
            'subtitle': '친구가 디딤돌로 이사 완료 시 나와 친구 모두에게 스타벅스 아메리카노 기프티콘 증정',
            'hasArrow': true,
          },

          {
            'icon': Icons.share,
            'title': '참여 방법',
            'subtitle': '앱 내 [친구 초대하기] 버튼 클릭 → 카카오톡, 문자 등으로 초대 메시지 발송',
            'hasArrow': true,
          },
          {
            'icon': Icons.calendar_today,
            'title': '이벤트 기간',
            'subtitle': '2025년 3월 1일 ~ 5월 31일',
            'hasArrow': false,
          },
          {
            'icon': Icons.info_outline,
            'title': '유의사항',
            'subtitle': '한 계정당 최대 10명까지 초대 가능합니다',
            'hasArrow': true,
          },
        ],
      },
      {
        // 리뷰 작성 이벤트
        'imagePath': 'assets/banners/banner2.png',
        'bgColor': Colors.orange, // 보라색 배경
        'title': '이사 후기 쓰면\n선물이 팡팡!',
        'description': '소중한 경험을 나누고\n상품권도 받아가세요',
        'benefitItems': [
          {
            'icon': Icons.card_giftcard,
            'title': '즉시 지급 혜택',
            'subtitle': '리뷰 작성 즉시 편의점 상품권 3천원 지급',
            'hasArrow': true,
          },
          {
            'icon': Icons.star,
            'title': '베스트 리뷰 선정',
            'subtitle': '매주 베스트 리뷰 선정 시 배달의민족 1만원권 추가 증정',
            'hasArrow': true,
          },
          {
            'icon': Icons.rate_review,
            'title': '참여 방법',
            'subtitle': '이사 서비스 완료 후 앱에서 별점과 함께 솔직한 이용 후기 작성',
            'hasArrow': true,
          },
          {
            'icon': Icons.calendar_today,
            'title': '이벤트 기간',
            'subtitle': '2025년 3월 1일 ~ 4월 30일',
            'hasArrow': false,
          },
          {
            'icon': Icons.info_outline,
            'title': '유의사항',
            'subtitle': '한 번의 이사 서비스당 1회 리뷰 작성 가능합니다',
            'hasArrow': true,
          },
        ],
      },
      {
        // SNS 인증샷 이벤트
        'imagePath': 'assets/banners/banner3.png',
        'bgColor': const Color(0xFF9747FF), // 보라색 배경
        'title': '이사 인증샷 올리고\n치킨 먹자!',
        'description': '새로운 공간을 자랑하고\n맛있는 선물도 받아가세요',
        'benefitItems': [
          {
            'icon': Icons.fastfood,
            'title': '주간 경품',
            'subtitle': '매주 추첨을 통해 10명에게 치킨 기프티콘 증정',
            'hasArrow': true,
          },
          {
            'icon': Icons.movie,
            'title': '월간 경품',
            'subtitle': '월간 베스트 인증샷 3명 선정하여 CGV 영화관람권 2매 증정',
            'hasArrow': true,
          },
          {
            'icon': Icons.camera_alt,
            'title': '참여 방법',
            'subtitle': '새 공간 인증샷 촬영 → SNS 게시물 업로드 → 앱에 URL 등록',
            'hasArrow': true,
          },
          {
            'icon': Icons.tag,
            'title': '필수 해시태그',
            'subtitle': '#디딤돌이사 #디딤돌최고 #이사는디딤돌에서',
            'hasArrow': false,
          },
          {
            'icon': Icons.calendar_today,
            'title': '이벤트 기간',
            'subtitle': '2025년 3월 1일 ~ 5월 31일',
            'hasArrow': false,
          },
        ],
      },
    ];

    // 현재 배너 데이터
    final currentBanner = bannerDetails[bannerIndex];
    final Color bannerColor = currentBanner['bgColor'] as Color;

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
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: Colors.white, // 이 부분 추가
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
                                benefitItem['icon'] as IconData,
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
                            // trailing: benefitItem['hasArrow'] == true
                            //     ? Icon(
                            //   Icons.chevron_right,
                            //   color: Colors.grey.shade400,
                            // )
                            //     : null,
                            // onTap: benefitItem['hasArrow'] == true
                            //     ? () {
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(
                            //       content: Text('${benefitItem['title']} 상세 정보는 준비 중입니다.'),
                            //       duration: Duration(seconds: 2),
                            //     ),
                            //   );
                            // }
                            //     : null,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('이벤트 참여가 완료되었습니다.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
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