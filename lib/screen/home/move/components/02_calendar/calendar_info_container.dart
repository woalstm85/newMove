import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/utils/ui_mixins.dart';

class CalendarInfoContainer extends StatefulWidget {
  final Color primaryColor;

  const CalendarInfoContainer({
    Key? key,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<CalendarInfoContainer> createState() => _CalendarInfoContainerState();
}

// State 클래스에 CommonUiMixin 적용
class _CalendarInfoContainerState extends State<CalendarInfoContainer> with CommonUiMixin {
  @override
  Widget build(BuildContext context) {
    return buildInfoCard(
      title: '예약 안내',
      icon: Icons.info_outline,
      iconColor: widget.primaryColor,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        // 상태 범례
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusItem(context, '여유', Colors.blue),
              _buildStatusDivider(),
              _buildStatusItem(context, '보통', Colors.black54),
              _buildStatusDivider(),
              _buildStatusItem(context, '많음', Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 안내 사항들
        _buildInfoRow(context, '표시는 손없는날입니다.', Icons.event_busy_outlined),
        _buildInfoRow(context, '예약일은 90일 이내로만 선택 가능합니다.', Icons.date_range_outlined),
        _buildInfoRow(context, '손없는날, 금요일, 토요일은 가격이 비쌀 수 있어요!', Icons.payment_outlined),
      ],
    );
  }

  Widget _buildStatusItem(BuildContext context, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: context.scaledFontSize(12),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDivider() {
    return Container(
      width: 1,
      height: 16,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildInfoRow(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.secondaryText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: context.scaledFontSize(13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}