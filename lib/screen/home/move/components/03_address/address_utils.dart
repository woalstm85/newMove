import 'package:flutter/material.dart';

/// 주소 관련 유틸리티 함수를 제공하는 클래스
class AddressUtils {
  /// 주소 요약 문자열 생성
  /// 건물 종류, 방 구조, 평수, 층 정보를 파이프(|)로 구분하여 표시
  static String buildAddressSummary(Map<String, dynamic> addressDetails) {
    return '${addressDetails['buildingType']} | '
        '${addressDetails['roomStructure']} | '
        '${addressDetails['roomSize']} | '
        '${addressDetails['floor']}';
  }

  /// 주소에 건물명 추가
  /// 도로명 주소나 지번 주소에 건물명을 포함시켜 반환
  static String addBuildingNameToAddress(String address, String? buildingName) {
    if (buildingName != null && buildingName.isNotEmpty) {
      return '$address ($buildingName)';
    }
    return address;
  }

  /// 주소 유효성 검사
  /// 필수 필드가 모두 입력되었는지 확인
  static bool isAddressValid(Map<String, dynamic>? addressDetails) {
    if (addressDetails == null) return false;

    return addressDetails.containsKey('address') &&
        addressDetails['address'] != null &&
        addressDetails.containsKey('detailAddress') &&
        addressDetails['detailAddress'] != null &&
        addressDetails.containsKey('buildingType') &&
        addressDetails['buildingType'] != null &&
        addressDetails.containsKey('roomStructure') &&
        addressDetails['roomStructure'] != null &&
        addressDetails.containsKey('roomSize') &&
        addressDetails['roomSize'] != null &&
        addressDetails.containsKey('floor') &&
        addressDetails['floor'] != null;
  }

  /// 주소 출력 형식 생성
  /// 주소와 상세주소를 결합하여 반환
  static String formatFullAddress(Map<String, dynamic> addressDetails) {
    final address = addressDetails['address'] ?? '';
    final detailAddress = addressDetails['detailAddress'] ?? '';

    return '$address $detailAddress'.trim();
  }

  /// 건물 유형에 따른 아이콘 반환
  static IconData getBuildingTypeIcon(String buildingType) {
    switch (buildingType) {
      case '빌라/연립':
        return Icons.apartment;
      case '오피스텔':
        return Icons.business;
      case '주택':
        return Icons.home;
      case '아파트':
        return Icons.location_city;
      case '상가/사무실':
        return Icons.store;
      default:
        return Icons.home_work;
    }
  }
}