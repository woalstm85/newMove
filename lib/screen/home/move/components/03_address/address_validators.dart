class AddressValidators {
  // 상세 주소 유효성 검사
  static String? validateDetailAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '상세 주소를 입력해주세요';
    }

    // 너무 긴 주소 방지 (예: 최대 100자)
    if (value.trim().length > 100) {
      return '상세 주소는 100자 이내로 입력해주세요';
    }

    // 특수 문자 필터링 (선택적)
    final specialCharRegex = RegExp(r'[<>%$#@!&*()]');
    if (specialCharRegex.hasMatch(value)) {
      return '부적절한 특수 문자가 포함되어 있습니다';
    }

    return null;
  }

  // 건물 종류 유효성 검사
  static bool isValidBuildingType(String? buildingType) {
    final validTypes = [
      '빌라/연립', '오피스텔', '주택', '아파트', '상가/사무실'
    ];
    return buildingType != null && validTypes.contains(buildingType);
  }

  // 방 구조 유효성 검사
  static bool isValidRoomStructure(String? roomStructure) {
    final validStructures = [
      '원룸', '1.5룸', '2룸', '3룸', '4룸', '5룸 이상'
    ];
    return roomStructure != null && validStructures.contains(roomStructure);
  }

  // 평수 선택 유효성 검사
  static bool isValidRoomSize(String? roomSize) {
    return roomSize != null && roomSize != '선택';
  }

  // 층 선택 유효성 검사
  static bool isValidFloor(String? floor) {
    return floor != null && floor != '선택';
  }

  // 전체 주소 정보 유효성 검사
  static bool validateAddressData({
    required String address,
    required String detailAddress,
    required String buildingType,
    required String roomStructure,
    required String roomSize,
    required String floor,
  }) {
    return
      validateDetailAddress(detailAddress) == null &&
          isValidBuildingType(buildingType) &&
          isValidRoomStructure(roomStructure) &&
          isValidRoomSize(roomSize) &&
          isValidFloor(floor);
  }
}