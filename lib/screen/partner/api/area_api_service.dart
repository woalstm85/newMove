import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AreaModel {
  final String areaDivCd;
  final String areaDivNm;
  final List<SubArea> subData;

  AreaModel({
    required this.areaDivCd,
    required this.areaDivNm,
    required this.subData,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    List<SubArea> subAreas = [];
    if (json['subData'] != null) {
      subAreas = List<SubArea>.from(json['subData'].map((x) => SubArea.fromJson(x)));
    }

    return AreaModel(
      areaDivCd: json['areaDivCd'] ?? '',
      areaDivNm: json['areaDivNm'] ?? '',
      subData: subAreas,
    );
  }
}

class SubArea {
  final String areaCd;
  final String areaNm;
  final String areaDivCd;

  SubArea({
    required this.areaCd,
    required this.areaNm,
    required this.areaDivCd,
  });

  factory SubArea.fromJson(Map<String, dynamic> json) {
    return SubArea(
      areaCd: json['areaCd'] ?? '',
      areaNm: json['areaNm'] ?? '',
      areaDivCd: json['areaDivCd'] ?? '',
    );
  }
}

class AreaApiService {
  static const String baseUrl = 'http://moving.stst.co.kr/api';

  // API에서 지역 데이터 가져오기
  static Future<List<AreaModel>> fetchAreas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/Comm/areas'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((area) => AreaModel.fromJson(area)).toList();
      } else {
        debugPrint('지역 데이터 로드 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('지역 데이터 로드 중 예외 발생: $e');
      return [];
    }
  }

  // 캐싱을 위한 데이터 저장
  static List<AreaModel>? _cachedAreas;

  // 지역 데이터 가져오기 (캐싱 적용)
  static Future<List<AreaModel>> getAreas() async {
    if (_cachedAreas != null && _cachedAreas!.isNotEmpty) {
      return _cachedAreas!;
    }

    final areas = await fetchAreas();
    if (areas.isNotEmpty) {
      _cachedAreas = areas;
    }

    return areas;
  }

  // 전체 지역 옵션 추가
  static List<AreaModel> addAllRegionOption(List<AreaModel> areas) {
    // 전체 지역 옵션이 없으면 추가
    if (!areas.any((area) => area.areaDivNm == '전체')) {
      final allRegion = AreaModel(
        areaDivCd: '000',
        areaDivNm: '전체',
        subData: [SubArea(areaCd: '000000', areaNm: '전국(전체)', areaDivCd: '000')],
      );

      return [allRegion, ...areas];
    }

    return areas;
  }
}