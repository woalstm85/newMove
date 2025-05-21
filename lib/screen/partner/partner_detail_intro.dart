import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class PartnerIntroductionTab extends StatelessWidget {
  final String partnerName;
  final String bossName;
  final String introduction;
  final String experience;
  final List<dynamic> regions;
  final List<dynamic> services;

  const PartnerIntroductionTab({
    Key? key,
    required this.partnerName,
    this.bossName = '정보 없음',
    this.introduction = '',
    this.experience = '5년',
    required this.regions,
    required this.services,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // 소개 내용이 없는 경우 기본 소개글 생성
    final String introText = introduction.isNotEmpty
        ? introduction
        : '안녕하세요, $partnerName 입니다.\n'
        '오랜 경험과 노하우로 고객님의 소중한 물품을 안전하게 이사해 드립니다.\n'
        '빠르고 정확한 서비스로 고객님의 만족을 최우선으로 생각합니다.\n'
        '언제든지 문의주시면 친절하게 상담해 드리겠습니다.';

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 통계 및 정보 카드
          _buildPartnerInfoCard(context),

          SizedBox(height: context.defaultPadding),

          // 소개글 섹션
          _buildIntroductionCard(context, introText),

          SizedBox(height: context.defaultPadding),

          // 제공 서비스 섹션
          _buildServicesCard(context),

          SizedBox(height: context.defaultPadding),

          // 서비스 지역 섹션
          _buildRegionsCard(context),

          SizedBox(height: context.defaultPadding),

          // 견적 상담 조건 섹션
          _buildConditionsCard(context),

          SizedBox(height: context.defaultPadding),

          // 자격증 및 수상 이력 섹션
          _buildAwardsCard(context),

          SizedBox(height: context.defaultPadding),
        ],
      ),
    );
  }
  // 제목 공통
  Widget _buildCardTitle(BuildContext context, {
    required IconData icon,
    required String title,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor ?? AppTheme.primaryColor,
        ),
        SizedBox(width: context.smallPadding / 2),
        Text(
          title,
          style: context.titleStyle(),
        ),
      ],
    );
  }

  Widget _buildPartnerInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        // Border 설정 제거
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '파트너 정보',
            style: context.titleStyle(),
          ),
          SizedBox(height: context.defaultPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(context,
                icon: Icons.access_time,
                title: '경력',
                value: experience,
                color: AppTheme.primaryColor,
              ),
              _buildInfoItem(context,
                icon: Icons.check_circle,
                title: '인증상태',
                value: '인증완료',
                color: AppTheme.success,
              ),
              _buildInfoItem(context,
                icon: Icons.local_shipping,
                title: '보유차량',
                value: '1.5톤 탑차',
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntroductionCard(BuildContext context, String introText) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        // Border 설정 제거
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            context,
            icon: Icons.description,
            title: '파트너 소개',
          ),
          SizedBox(height: context.defaultPadding),
          Text(
            introText,
            style: context.bodyStyle().copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        // Border 설정 제거
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            context,
            icon: Icons.handyman,
            title: '제공 서비스',
          ),
          SizedBox(height: context.defaultPadding),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var service in services.isNotEmpty ? services : [{'serviceNm': '소형이사'}, {'serviceNm': '가정이사'}])
                Container(
                  padding: EdgeInsets.all(context.smallPadding),
                  decoration: context.tagDecoration(AppTheme.primaryColor),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Text(
                        service['serviceNm'] ?? '서비스',
                        style: TextStyle(
                          fontSize: context.scaledFontSize(13),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: context.defaultPadding),
          Container(
            padding: EdgeInsets.all(context.defaultPadding),
            decoration: BoxDecoration(
              color: AppTheme.scaffoldBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderSubColor,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppTheme.secondaryText,
                ),
                SizedBox(width: context.smallPadding / 2),
                Expanded(
                  child: Text(
                    '기본 제공 서비스 외 현장의 서비스는 현장에 따라 금액, 수행여부 등이 변경될 수 있습니다. 반드시 업체와 상담해 주세요.',
                    style: TextStyle(
                      fontSize: context.scaledFontSize(12),
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        // Border 설정 제거
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            context,
            icon: Icons.place,
            title: '서비스 지역',
          ),
          SizedBox(height: context.defaultPadding),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var region in regions)
                Container(
                  padding: EdgeInsets.all(context.smallPadding),
                  decoration: context.tagDecoration(AppTheme.secondaryColor),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.secondaryColor,
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Text(
                        region.toString(),
                        style: TextStyle(
                          fontSize: context.scaledFontSize(13),
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        // Border 설정 제거
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            context,
            icon: Icons.gavel,
            title: '견적 상담 조건',
          ),
          SizedBox(height: context.defaultPadding),
          _buildConditionItem(context,
            icon: Icons.restaurant_menu,
            text: '식대 요구 없음',
            description: '별도의 식대를 요구하지 않습니다.',
          ),
          SizedBox(height: context.defaultPadding),
          _buildConditionItem(context,
            icon: Icons.smoke_free,
            text: '작업 중 흡연 금지',
            description: '고객님의 건강과 쾌적한 환경을 위해 작업 중 흡연을 하지 않습니다.',
          ),
          SizedBox(height: context.defaultPadding),
          _buildConditionItem(context,
            icon: Icons.local_police,
            text: '고객 물품 안전 보장',
            description: '파손 발생 시 즉시 보상해 드립니다.',
          ),
        ],
      ),
    );
  }

  Widget _buildAwardsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        // Border 설정 제거
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_membership,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: context.smallPadding / 2),
              Text(
                '자격증 및 수상 이력',
                style: context.titleStyle(),
              ),
            ],
          ),
          SizedBox(height: context.defaultPadding),
          Container(
            padding: EdgeInsets.all(context.defaultPadding),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: AppTheme.warning,
                    size: 20,
                  ),
                ),
                SizedBox(width: context.defaultPadding / 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이달의 파트너',
                        style: context.subtitleStyle(),
                      ),
                      SizedBox(height: context.smallPadding / 4),
                      Text(
                        '2023년 1월',
                        style: context.captionStyle(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.defaultPadding),
          Container(
            padding: EdgeInsets.all(context.defaultPadding),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: context.defaultPadding / 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '우수 파트너 인증',
                        style: context.subtitleStyle(),
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Text(
                        '2023년 상반기',
                        style: TextStyle(
                          fontSize: context.scaledFontSize(12),
                          color: AppTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: context.smallPadding),
        Text(
          value,
          style: context.titleStyle(),
        ),
        SizedBox(height: context.smallPadding / 4),
        Text(
          title,
          style: TextStyle(
            fontSize: context.scaledFontSize(12),
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionItem(BuildContext context,{
    required IconData icon,
    required String text,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSubColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderSubColor),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.secondaryText,
            ),
          ),
          SizedBox(width: context.defaultPadding / 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: context.subtitleStyle(),
                ),
                SizedBox(height: context.smallPadding / 4),
                Text(
                  description,
                  style: context.labelStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}