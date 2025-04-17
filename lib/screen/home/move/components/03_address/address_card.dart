import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

/// 주소 카드 컴포넌트

/// 출발지 또는 도착지 주소 정보를 표시하는 카드 위젯
class AddressCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, dynamic>? details;
  final Color primaryColor;
  final VoidCallback onTap;

  const AddressCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.details,
    required this.primaryColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderSubColor,
            width: 1,
          ),
          boxShadow: details != null
              ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ]

              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.smallPadding),
                  decoration: BoxDecoration(
                    color: details != null
                        ? primaryColor.withOpacity(0.1)
                        : Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: details != null ? primaryColor : AppTheme.secondaryText,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.scaledFontSize(18),
                    fontWeight: FontWeight.bold,
                    color: details != null ? primaryColor : AppTheme.secondaryText,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.edit_outlined,
                  color: details != null ? primaryColor : AppTheme.secondaryText,
                  size: context.scaledFontSize(16),
                ),
              ],
            ),
            if (details != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildAddressDetails(context, details!),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                '주소를 입력해주세요',
                style: TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: context.scaledFontSize(14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 주소 상세 정보 위젯
  Widget _buildAddressDetails(BuildContext context, Map<String, dynamic> addressDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${addressDetails['address']} ${addressDetails['detailAddress']}',
          style: TextStyle(
            fontSize: context.scaledFontSize(14),
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          _buildAddressSummary(addressDetails),
          style: TextStyle(
            fontSize: context.scaledFontSize(12),
            color: AppTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildInfoChip(context, (addressDetails['hasStairs'] ?? false) ? '1층 계단 있음' : '1층 계단 없음'),
            _buildInfoChip(context, (addressDetails['hasElevator'] ?? false) ? '엘리베이터 있음' : '엘리베이터 없음'),
            _buildInfoChip(context, (addressDetails['parkingAvailable'] ?? false) ? '주차 가능' : '주차 불가'),
          ],
        ),
      ],
    );
  }

  // 주소 요약 문자열 생성
  String _buildAddressSummary(Map<String, dynamic> addressDetails) {
    return '${addressDetails['buildingType']} | '
        '${addressDetails['roomStructure']} | '
        '${addressDetails['roomSize']} | '
        '${addressDetails['floor']}';
  }

  // 정보 태그 위젯
  Widget _buildInfoChip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.all(context.smallPadding),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: primaryColor,
          fontSize: context.scaledFontSize(11),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}