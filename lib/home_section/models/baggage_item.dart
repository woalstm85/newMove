class BaggageItem {
  final String cateId;      // 카테고리 ID (예: CT0010)
  final String loadCd;      // 아이템 코드 (예: L10010)
  final String category;    // 카테고리 이름 (예: 침실/거실가구)
  final String itemName;    // 아이템 이름 (예: 침대)
  final dynamic subData;    // 아이템 데이터 (아이콘, subData 등) - Map이나 List 둘 다 허용
  Map<String, String> options;  // 선택된 옵션들 (종류, 크기 등)

  BaggageItem({
    required this.cateId,
    required this.loadCd,
    required this.category,
    required this.itemName,
    required this.subData,
    this.options = const {},
  });

  // JSON 직렬화/역직렬화 메서드
  Map<String, dynamic> toJson() {
    return {
      'cateId': cateId,
      'loadCd': loadCd,
      'category': category,
      'itemName': itemName,
      'subData': subData,
      'options': options,
    };
  }

  factory BaggageItem.fromJson(Map<String, dynamic> json) {
    return BaggageItem(
      cateId: json['cateId'],
      loadCd: json['loadCd'],
      category: json['category'],
      itemName: json['itemName'],
      subData: json['subData'],
      options: Map<String, String>.from(json['options'] ?? {}),
    );
  }

  // 아이템 표시 이름 (같은 종류가 여러 개일 때 번호 표시)
  String getDisplayName(List<BaggageItem> items) {
    // 카테고리와 아이템 이름이 같은 항목들 찾기
    final sameItems = items.where((item) =>
    item.category == this.category && item.itemName == this.itemName).toList();

    // 1개만 있으면 그냥 이름만 표시
    if (sameItems.length <= 1) {
      return itemName;
    }

    // 여러 개면 인덱스 찾아서 번호 표시
    final index = sameItems.indexOf(this);
    if (index < 0) {
      return itemName; // 못 찾으면 기본 이름 반환
    }
    return "$itemName(${index + 1})";
  }
}

String createItemKey(String cateId, String loadCd) {
  return '$cateId-$loadCd';
}