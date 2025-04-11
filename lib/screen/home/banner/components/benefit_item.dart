import 'package:flutter/material.dart';
import 'package:MoveSmart/screen/home/banner/models/banner_model.dart';

class BenefitItemWidget extends StatelessWidget {
  final BenefitItem item;
  final Color bannerColor;

  const BenefitItemWidget({
    Key? key,
    required this.item,
    required this.bannerColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            item.icon,
            color: bannerColor,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item.subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}