import 'package:flutter/material.dart';

class BannerModel {
  final String imagePath;
  final String title;
  final String subtitle;
  final String buttonText;
  final Color titleColor;
  final Color subtitleColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color bgColor;
  final String description;
  final List<BenefitItem> benefitItems;

  BannerModel({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.titleColor,
    required this.subtitleColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.bgColor,
    required this.description,
    required this.benefitItems,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    // 색상 변환 헬퍼 함수
    Color parseColor(String colorStr) {
      if (colorStr == 'white') return Colors.white;
      if (colorStr == 'white_90') return Colors.white.withOpacity(0.9);
      if (colorStr == 'white_80') return Colors.white.withOpacity(0.8);
      if (colorStr.startsWith('0x')) return Color(int.parse(colorStr, radix: 16));
      return Color(int.parse('0xFF$colorStr'));
    }

    return BannerModel(
      imagePath: json['imagePath'],
      title: json['title'],
      subtitle: json['subtitle'],
      buttonText: json['buttonText'],
      titleColor: parseColor(json['titleColor']),
      subtitleColor: parseColor(json['subtitleColor']),
      buttonColor: parseColor(json['buttonColor']),
      buttonTextColor: parseColor(json['buttonTextColor']),
      bgColor: parseColor(json['bgColor']),
      description: json['description'],
      benefitItems: (json['benefitItems'] as List)
          .map((e) => BenefitItem.fromJson(e))
          .toList(),
    );
  }

  static List<BannerModel> fromJsonList(List<Map<String, dynamic>> list) {
    return list.map((json) => BannerModel.fromJson(json)).toList();
  }
}

class BenefitItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool hasArrow;

  BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.hasArrow,
  });

  factory BenefitItem.fromJson(Map<String, dynamic> json) {
    // 아이콘 변환 헬퍼 함수
    IconData getIconData(dynamic iconValue) {
      if (iconValue == 'card_giftcard') return Icons.card_giftcard;
      if (iconValue == 'share') return Icons.share;
      if (iconValue == 'calendar_today') return Icons.calendar_today;
      if (iconValue == 'info_outline') return Icons.info_outline;
      if (iconValue == 'star') return Icons.star;
      if (iconValue == 'rate_review') return Icons.rate_review;
      if (iconValue == 'fastfood') return Icons.fastfood;
      if (iconValue == 'movie') return Icons.movie;
      if (iconValue == 'camera_alt') return Icons.camera_alt;
      if (iconValue == 'tag') return Icons.tag;
      return Icons.info;
    }

    return BenefitItem(
      icon: getIconData(json['icon']),
      title: json['title'],
      subtitle: json['subtitle'],
      hasArrow: json['hasArrow'] ?? false,
    );
  }
}