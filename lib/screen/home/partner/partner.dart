import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/screen/partner/partner_detail_screen.dart';

class CircleSlider extends StatelessWidget {
  final List<dynamic> partners;
  final bool isLoading;

  const CircleSlider({
    super.key,
    required this.partners,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (partners.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPartnerList(context);
  }

  // 로딩 상태 UI
  Widget _buildLoadingState() {
    return Container(
      height: 150,
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
              '파트너를 불러오는 중입니다...',
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

  // 파트너 없음 상태 UI
  Widget _buildEmptyState() {
    return Container(
      height: 150,
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
            Icons.business_outlined,
            size: 40,
            color: AppTheme.subtleText,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 등록된 파트너가 없습니다.',
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 파트너 리스트 UI
  Widget _buildPartnerList(BuildContext context) {
    return Container(
      height: 160,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: partners.length,
        itemBuilder: (context, index) {
          final company = partners[index];

          // 이미지 URL 확인
          String? imageUrl;
          if (company['imgData'] != null &&
              company['imgData'] is List &&
              company['imgData'].isNotEmpty &&
              company['imgData'][0]['imgUrl'] != null) {
            imageUrl = company['imgData'][0]['imgUrl'];
          }

          // 서비스 이름 확인
          String serviceName = '서비스 없음';
          if (company['serviceData'] != null &&
              company['serviceData'] is List &&
              company['serviceData'].isNotEmpty &&
              company['serviceData'][0]['serviceNm'] != null) {
            serviceName = company['serviceData'][0]['serviceNm'];
          }

          return GestureDetector(
            onTap: () {
              // 파트너 상세 정보 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartnerDetailScreen(
                    partnerId: company['compCd'] ?? '', // 파트너의 고유 ID 전달
                  ),
                ),
              );
            },
            child: Container(
              width: 80,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 10,
                right: 10,
              ),
              child: Column(
                children: [
                  // 파트너 아바타
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), // 약간의 둥근 모서리 적용
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12), // ClipRRect에도 동일한 둥근 모서리 적용
                      child: imageUrl != null
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.business_outlined,
                              color: AppTheme.subtleText,
                              size: 36,
                            ),
                          );
                        },
                      )
                          : Center(
                        child: Icon(
                          Icons.business_outlined,
                          color: AppTheme.subtleText,
                          size: 36,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 업체명
                  Text(
                    company['compName'] ?? '업체명 없음',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // 서비스 유형
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      serviceName,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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