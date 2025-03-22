import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import '../utils/ui_extensions.dart';


class PartnerBusinessInfoTab extends StatelessWidget {
  final Map<String, dynamic> partnerData;

  const PartnerBusinessInfoTab({
    Key? key,
    required this.partnerData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 데이터 추출 (기본값 제공)
    final String companyName = partnerData['compName'] ?? '파트너';
    final String bussNo = partnerData['bussNo']?.isNotEmpty == true
        ? partnerData['bussNo']
        : '123-45-67890';
    final String tel = partnerData['tel1']?.isNotEmpty == true
        ? partnerData['tel1']
        : '010-9033-7199';
    final String email = partnerData['eMail']?.isNotEmpty == true
        ? partnerData['eMail']
        : 'partner@example.com';
    final String bossName = partnerData['bossName'] ?? '정보 없음';
    final bool businessVerified = partnerData['businessVerified'] ?? true;


    return SingleChildScrollView(
      padding: EdgeInsets.all(context.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사업자 정보 카드
          _buildBusinessInfoCard(context,
            companyName: companyName,
            bossName: bossName,
            bussNo: bussNo,
            tel: tel,
            email: email,
            businessVerified: businessVerified,
          ),

          SizedBox(height: context.defaultPadding),

          // 사업장 위치 정보
          _buildLocationCard(context),

          SizedBox(height: context.defaultPadding),

          // 사업자 인증 정보
          _buildCertificationCard(context),

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

  Widget _buildBusinessInfoCard(BuildContext context, {
    required String companyName,
    required String bossName,
    required String bussNo,
    required String tel,
    required String email,
    required bool businessVerified,
  }) {
    final infoItems = [
      {'label': '상호명', 'value': companyName},
      {'label': '대표자', 'value': bossName},
      {'label': '사업자등록번호', 'value': bussNo},
      {'label': '연락처', 'value': tel},
      {'label': '이메일', 'value': email},
    ];

    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: context.cardDecoration(borderColor: AppTheme.borderSubColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: context.smallPadding),
              Text(
                '기본 정보',
                style: context.titleStyle(),
              ),
              const Spacer(),
              if (businessVerified)
                Container(
                  padding: EdgeInsets.all(context.smallPadding),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified,
                        size: 12,
                        color: AppTheme.success,
                      ),
                      SizedBox(width: context.smallPadding / 2),
                      Text(
                        '인증완료',
                        style: context.labelSubStyle(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: context.defaultPadding), // 제목과 내용 사이 여백 추가
          Column(
            children: [
              for (int i = 0; i < infoItems.length; i++) ...[
                _buildInfoRow(context, infoItems[i]['label']!, infoItems[i]['value']!),
                if (i < infoItems.length - 1)
                  Divider(height: context.defaultPadding * 1.5),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    Color color = AppTheme.success,
  }) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
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
          SizedBox(width: context.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.subtitleStyle()),
                SizedBox(height: context.smallPadding / 2),
                Text(description, style: context.captionStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(
      BuildContext context, {
        String address = '서울특별시 강남구 테헤란로 123',
        String detailAddress = '디딤돌타워 8층',
      }) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: context.cardDecoration(borderColor: AppTheme.borderSubColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            context,
            icon : Icons.location_on,
            title : '사업장 위치',
          ),
         SizedBox(height: context.defaultPadding),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.subtleText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 40,
                    color: AppTheme.subtleText,
                  ),
                  SizedBox(height: context.defaultPadding),
                  Text(
                    address,
                    style: context.labelStyle(),
                  ),
                  SizedBox(height: context.smallPadding / 2),
                  Text(
                    detailAddress ,
                    style: context.labelStyle(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: context.cardDecoration(borderColor: AppTheme.borderSubColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(
            context,
            icon: Icons.verified_user,
            title: '인증 정보',
          ),
          SizedBox(height: context.defaultPadding),

          // 첫 번째 인증 정보 컨테이너
          _buildInfoContainer(
            context,
            icon: Icons.check_circle,
            title: '사업자 인증 완료',
            description: '해당 파트너는 디딤돌에서 사업자 정보를 인증받은 파트너입니다. 안심하고 이용하세요.',
            color: AppTheme.success,
          ),

          SizedBox(height: context.defaultPadding),

          // 두 번째 인증 정보 컨테이너
          _buildInfoContainer(
            context,
            icon: Icons.shield,
            title: '신뢰 파트너 인증',
            description: '고객 만족도, 작업 품질, 응답률 등의 기준을 충족한 파트너입니다.',
            color: AppTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: context.labelStyle(),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.valueStyle(),
          ),
        ),
      ],
    );
  }
}