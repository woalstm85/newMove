import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// 일반 이사 Provider
final regularMoveProvider = StateNotifierProvider<MoveNotifier, MoveState>((ref) {
  return MoveNotifier(isRegularMove: true);
});

// 특수 이사 Provider
final specialMoveProvider = StateNotifierProvider<MoveNotifier, MoveState>((ref) {
  return MoveNotifier(isRegularMove: false);
});


// 이사 데이터 관리를 위한 모델 클래스
class MoveData {
  // 이사 유형 관련 데이터
  String? selectedMoveType;

  // 날짜 및 시간 관련 데이터
  DateTime? selectedDate;
  String? selectedTime;

  // 주소 관련 데이터
  Map<String, dynamic>? startAddressDetails;
  Map<String, dynamic>? destinationAddressDetails;

  // 이삿짐 관련 데이터
  List<Map<String, dynamic>> selectedBaggageItems = [];

  // 추가 설명
  String? additionalNotes;

  MoveData({
    this.selectedMoveType,
    this.selectedDate,
    this.selectedTime,
    this.startAddressDetails,
    this.destinationAddressDetails,
    this.additionalNotes,
  });

  bool get hasSelectedDate => selectedDate != null;
  bool get hasSelectedTime => selectedTime != null;
  bool get hasStartAddress => startAddressDetails != null;
  bool get hasDestinationAddress => destinationAddressDetails != null;

  // 다음 단계로 진행 가능한지 확인
  bool canProceedToCalendar() => selectedMoveType != null;
  bool canProceedToAddress() => hasSelectedDate && hasSelectedTime;
  bool canProceedToBaggage() => hasStartAddress && hasDestinationAddress;
  bool canSubmitEstimate() => selectedBaggageItems.isNotEmpty;

  // 이삿짐 입력 방식 관련 데이터
  bool isPhotoSelected = false;
  bool isListSelected = false;

  // 방 사진 관련 데이터
  List<String> roomTypes = []; // 방 종류 목록
  Map<String, List<String>> roomImages = {}; // 방 별 이미지 경로

  // 특별 관리 항목 체크리스트
  Map<String, bool> specialItems = {};

  // 메모 데이터
  String? memo;
  int selectedMemoCategory = 0;
  List<String> selectedTemplates = [];

  //서비스 유형
  String? selectedServiceType;

  // 복사 메서드 (상태 업데이트를 위한)
  MoveData copyWith({
    String? selectedMoveType,
    DateTime? selectedDate,
    String? selectedTime,
    Map<String, dynamic>? startAddressDetails,
    Map<String, dynamic>? destinationAddressDetails,
    List<Map<String, dynamic>>? selectedBaggageItems,
    String? additionalNotes,
    bool? isPhotoSelected,
    bool? isListSelected,
    List<String>? roomTypes,
    Map<String, List<String>>? roomImages,
    Map<String, bool>? specialItems,
    String? memo,
    int? selectedMemoCategory,
    List<String>? selectedTemplates,
    String? selectedServiceType,
  }) {
    return MoveData(
      selectedMoveType: selectedMoveType ?? this.selectedMoveType,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      startAddressDetails: startAddressDetails ?? this.startAddressDetails,
      destinationAddressDetails: destinationAddressDetails ?? this.destinationAddressDetails,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    )
      ..selectedBaggageItems = selectedBaggageItems ?? this.selectedBaggageItems
      ..isPhotoSelected = isPhotoSelected ?? this.isPhotoSelected
      ..isListSelected = isListSelected ?? this.isListSelected
      ..roomTypes = roomTypes ?? this.roomTypes
      ..roomImages = roomImages ?? this.roomImages
      ..specialItems = specialItems ?? this.specialItems
      ..memo = memo ?? this.memo
      ..selectedMemoCategory = selectedMemoCategory ?? this.selectedMemoCategory
      ..selectedTemplates = selectedTemplates ?? this.selectedTemplates
      ..selectedServiceType = selectedServiceType ?? this.selectedServiceType;
  }
}

// 이사 상태 클래스
class MoveState {
  final MoveData moveData;
  final bool isLoading;
  final bool isInitialized;

  MoveState({
    required this.moveData,
    this.isLoading = false,
    this.isInitialized = false,
  });

  bool get isDataLoaded => !isLoading && isInitialized;

  // 상태 복사 메서드
  MoveState copyWith({
    MoveData? moveData,
    bool? isLoading,
    bool? isInitialized,
  }) {
    return MoveState(
      moveData: moveData ?? this.moveData,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// 이사 데이터를 관리하는 StateNotifier
class MoveNotifier extends StateNotifier<MoveState> {
  final bool isRegularMove;
  String get _keyPrefix => isRegularMove ? 'regular_' : 'special_';
  bool _initialized = false;

  MoveNotifier({required this.isRegularMove})
      : super(MoveState(moveData: MoveData(), isLoading: true)) {
    print('MoveNotifier initialized for isRegularMove: $isRegularMove');
    _loadAllData();
  }

  // 데이터 강제 리로드 메서드 추가
  Future<void> forceReload() async {
    if (!_initialized) {
      await _loadAllData();
      _initialized = true;
    }
  }

  // 직접 타입 로드 메서드 추가
  Future<String?> getSelectedMoveType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_keyPrefix}selectedMoveType');
  }

  // 데이터 로드 메소드 업데이트
  Future<void> _loadBaggageInputType() async {
    final prefs = await SharedPreferences.getInstance();

    final isPhotoSelected = prefs.getBool('${_keyPrefix}isPhotoSelected') ?? false;
    final isListSelected = prefs.getBool('${_keyPrefix}isListSelected') ?? false;

    state = state.copyWith(
        moveData: state.moveData.copyWith(
          isPhotoSelected: isPhotoSelected,
          isListSelected: isListSelected,
        )
    );
  }

  // 모든 데이터 로드
  Future<void> _loadAllData() async {
    // 기존 코드...
    try {
      await Future.wait([
        _loadMoveType(),
        _loadDateAndTime(),
        _loadAddressData(),
        _loadBaggageData(),
        _loadBaggageInputType(),
        _loadRoomData(),
        _loadMemoData(),
        _loadServiceType(),
      ]);
      _initialized = true;
    } catch (e) {
      print('데이터 로드 오류: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // 이사 유형 로드
  Future<void> _loadMoveType() async {
    final prefs = await SharedPreferences.getInstance();
    final moveType = prefs.getString('${_keyPrefix}selectedMoveType');

    if (moveType != null) {
      // 기존 moveData를 유지하면서 selectedMoveType만 업데이트
      state = state.copyWith(
          moveData: state.moveData.copyWith(selectedMoveType: moveType)
      );
    }
  }

  // 이사 유형 저장
  Future<void> setMoveType(String moveType) async {
    print('Provider setMoveType called with: $moveType');
    final prefs = await SharedPreferences.getInstance();

    print('Saving to key: ${_keyPrefix}selectedMoveType');
    await prefs.setString('${_keyPrefix}selectedMoveType', moveType);

    print('Updating state with moveType: $moveType');
    state = state.copyWith(
        moveData: state.moveData.copyWith(selectedMoveType: moveType)
    );

    print('Current state after update: $state');
  }

  // 날짜 및 시간 로드
  Future<void> _loadDateAndTime() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDateStr = prefs.getString('${_keyPrefix}selectedDate');
    final savedTime = prefs.getString('${_keyPrefix}selectedTime');

    print('날짜 로드 시도: 키=${_keyPrefix}selectedDate, 저장된 값=$savedDateStr, isRegularMove=$isRegularMove');
    print('시간 로드 시도: 키=${_keyPrefix}selectedTime, 저장된 값=$savedTime, isRegularMove=$isRegularMove');

    DateTime? date;
    if (savedDateStr != null) {
      date = DateTime.parse(savedDateStr);
      print('날짜 파싱 결과: $date');
    }

    state = state.copyWith(
        moveData: state.moveData.copyWith(
          selectedDate: date,
          selectedTime: savedTime,
        )
    );
  }

  // 날짜 설정
  Future<void> setSelectedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_keyPrefix}selectedDate';
    final value = date.toIso8601String();

    print('날짜 저장 시도: 키=$key, 값=$value, isRegularMove=$isRegularMove');

    await prefs.setString(key, value);

    state = state.copyWith(
        moveData: state.moveData.copyWith(selectedDate: date)
    );

    // 저장 확인
    final savedValue = prefs.getString(key);
    print('저장 확인: 키=$key, 저장된 값=$savedValue');
  }

  // 시간 설정
  Future<void> setSelectedTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_keyPrefix}selectedTime', time);

    state = state.copyWith(
        moveData: state.moveData.copyWith(selectedTime: time)
    );
  }

  // 주소 데이터 로드
  Future<void> _loadAddressData() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic>? startAddress;
    Map<String, dynamic>? destinationAddress;

    // 출발지 주소 로드
    if (prefs.containsKey('${_keyPrefix}startAddress')) {
      startAddress = {
        'address': prefs.getString('${_keyPrefix}startAddress')!,
        'detailAddress': prefs.getString('${_keyPrefix}startDetailAddress')!,
        'buildingType': prefs.getString('${_keyPrefix}startBuildingType')!,
        'roomStructure': prefs.getString('${_keyPrefix}startRoomStructure')!,
        'roomSize': prefs.getString('${_keyPrefix}startRoomSize')!,
        'floor': prefs.getString('${_keyPrefix}startFloor')!,
        'hasStairs': prefs.getBool('${_keyPrefix}startHasStairs')!,
        'hasElevator': prefs.getBool('${_keyPrefix}startHasElevator')!,
        'parkingAvailable': prefs.getBool('${_keyPrefix}startParkingAvailable')!,
      };
    }

    // 도착지 주소 로드
    if (prefs.containsKey('${_keyPrefix}destinationAddress')) {
      destinationAddress = {
        'address': prefs.getString('${_keyPrefix}destinationAddress')!,
        'detailAddress': prefs.getString('${_keyPrefix}destinationDetailAddress')!,
        'buildingType': prefs.getString('${_keyPrefix}destinationBuildingType')!,
        'roomStructure': prefs.getString('${_keyPrefix}destinationRoomStructure')!,
        'roomSize': prefs.getString('${_keyPrefix}destinationRoomSize')!,
        'floor': prefs.getString('${_keyPrefix}destinationFloor')!,
        'hasStairs': prefs.getBool('${_keyPrefix}destinationHasStairs')!,
        'hasElevator': prefs.getBool('${_keyPrefix}destinationHasElevator')!,
        'parkingAvailable': prefs.getBool('${_keyPrefix}destinationParkingAvailable')!,
      };
    }

    state = state.copyWith(
        moveData: state.moveData.copyWith(
          startAddressDetails: startAddress,
          destinationAddressDetails: destinationAddress,
        )
    );
  }

  // 출발지 주소 설정
  Future<void> setStartAddress(Map<String, dynamic> addressDetails) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('${_keyPrefix}startAddress', addressDetails['address']);
    await prefs.setString('${_keyPrefix}startDetailAddress', addressDetails['detailAddress']);
    await prefs.setString('${_keyPrefix}startBuildingType', addressDetails['buildingType']);
    await prefs.setString('${_keyPrefix}startRoomStructure', addressDetails['roomStructure']);
    await prefs.setString('${_keyPrefix}startRoomSize', addressDetails['roomSize']);
    await prefs.setString('${_keyPrefix}startFloor', addressDetails['floor']);
    await prefs.setBool('${_keyPrefix}startHasStairs', addressDetails['hasStairs']);
    await prefs.setBool('${_keyPrefix}startHasElevator', addressDetails['hasElevator']);
    await prefs.setBool('${_keyPrefix}startParkingAvailable', addressDetails['parkingAvailable']);

    state = state.copyWith(
        moveData: state.moveData.copyWith(startAddressDetails: addressDetails)
    );
  }

  // 도착지 주소 설정
  Future<void> setDestinationAddress(Map<String, dynamic> addressDetails) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('${_keyPrefix}destinationAddress', addressDetails['address']);
    await prefs.setString('${_keyPrefix}destinationDetailAddress', addressDetails['detailAddress']);
    await prefs.setString('${_keyPrefix}destinationBuildingType', addressDetails['buildingType']);
    await prefs.setString('${_keyPrefix}destinationRoomStructure', addressDetails['roomStructure']);
    await prefs.setString('${_keyPrefix}destinationRoomSize', addressDetails['roomSize']);
    await prefs.setString('${_keyPrefix}destinationFloor', addressDetails['floor']);
    await prefs.setBool('${_keyPrefix}destinationHasStairs', addressDetails['hasStairs']);
    await prefs.setBool('${_keyPrefix}destinationHasElevator', addressDetails['hasElevator']);
    await prefs.setBool('${_keyPrefix}destinationParkingAvailable', addressDetails['parkingAvailable']);

    state = state.copyWith(
        moveData: state.moveData.copyWith(destinationAddressDetails: addressDetails)
    );
  }

  // 이삿짐 데이터 로드
  Future<void> _loadBaggageData() async {
    final prefs = await SharedPreferences.getInstance();
    final baggageDataString = prefs.getString('${_keyPrefix}baggageItems');

    List<Map<String, dynamic>> baggageItems = [];

    if (baggageDataString != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(baggageDataString);
        baggageItems = List<Map<String, dynamic>>.from(
            decodedList.map((item) => Map<String, dynamic>.from(item))
        );
      } catch (e) {
        print('이삿짐 데이터 파싱 오류: $e');
      }
    }

    final newMoveData = state.moveData.copyWith();
    newMoveData.selectedBaggageItems = baggageItems;

    state = state.copyWith(moveData: newMoveData);
  }

  // 이삿짐 항목 추가
  Future<void> addBaggageItem(Map<String, dynamic> item) async {
    final newBaggageItems = [...state.moveData.selectedBaggageItems, item];

    final newMoveData = state.moveData.copyWith();
    newMoveData.selectedBaggageItems = newBaggageItems;

    state = state.copyWith(moveData: newMoveData);

    await _saveBaggageItems();
  }

  // 이삿짐 항목 업데이트
  Future<void> updateBaggageItem(int index, Map<String, dynamic> item) async {
    if (index >= 0 && index < state.moveData.selectedBaggageItems.length) {
      final newBaggageItems = [...state.moveData.selectedBaggageItems];
      newBaggageItems[index] = item;

      final newMoveData = state.moveData.copyWith();
      newMoveData.selectedBaggageItems = newBaggageItems;

      state = state.copyWith(moveData: newMoveData);

      await _saveBaggageItems();
    }
  }

  // 이삿짐 항목 삭제
  Future<void> removeBaggageItem(int index) async {
    if (index >= 0 && index < state.moveData.selectedBaggageItems.length) {
      final newBaggageItems = [...state.moveData.selectedBaggageItems];
      newBaggageItems.removeAt(index);

      final newMoveData = state.moveData.copyWith();
      newMoveData.selectedBaggageItems = newBaggageItems;

      state = state.copyWith(moveData: newMoveData);

      await _saveBaggageItems();
    }
  }

  // 이삿짐 데이터 저장
  Future<void> _saveBaggageItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '${_keyPrefix}baggageItems',
        jsonEncode(state.moveData.selectedBaggageItems)
    );
  }

  // 모든 데이터 리셋
  Future<void> resetAllData() async {
    state = state.copyWith(isLoading: true);

    final prefs = await SharedPreferences.getInstance();

    // 현재 이사 유형에 대한 모든 키 삭제
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }

    // 메모리 내 데이터도 리셋
    state = MoveState(moveData: MoveData(), isLoading: false);
  }

  // 이삿짐 입력 방식 설정
  Future<void> setBaggageInputType({
    required bool isPhotoSelected,
    required bool isListSelected,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // SharedPreferences에 저장
    await prefs.setBool('${_keyPrefix}isPhotoSelected', isPhotoSelected);
    await prefs.setBool('${_keyPrefix}isListSelected', isListSelected);

    // 상태 업데이트
    final newMoveData = state.moveData.copyWith(
      isPhotoSelected: isPhotoSelected,
      isListSelected: isListSelected,
    );

    state = state.copyWith(moveData: newMoveData);
  }

// 방 목록 설정
  Future<void> setRoomTypes(List<String> roomTypes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${_keyPrefix}roomTypes', roomTypes);

    state = state.copyWith(
        moveData: state.moveData.copyWith(roomTypes: roomTypes)
    );
  }

// 방 이미지 저장
  Future<void> setRoomImages(String roomType, List<String> imagePaths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${_keyPrefix}images_$roomType', imagePaths);

    // 현재 이미지 맵 복사 후 업데이트
    final updatedImages = Map<String, List<String>>.from(state.moveData.roomImages);
    updatedImages[roomType] = imagePaths;

    state = state.copyWith(
        moveData: state.moveData.copyWith(roomImages: updatedImages)
    );
  }

// 모든 방 이미지 정보 한 번에 저장
  Future<void> saveAllRoomData(List<String> roomTypes, Map<String, List<String>> allRoomImages) async {
    final prefs = await SharedPreferences.getInstance();

    // 방 종류 저장
    await prefs.setStringList('${_keyPrefix}roomTypes', roomTypes);

    // 모든 방의 이미지 저장
    for (final roomType in roomTypes) {
      final images = allRoomImages[roomType] ?? [];
      await prefs.setStringList('${_keyPrefix}images_$roomType', images);
    }

    // 상태 업데이트
    state = state.copyWith(
        moveData: state.moveData.copyWith(
            roomTypes: roomTypes,
            roomImages: allRoomImages
        )
    );
  }

// 방 데이터 로드 (기존 _loadAllData에 추가)
  Future<void> _loadRoomData() async {
    final prefs = await SharedPreferences.getInstance();

    // 방 종류 로드
    final roomTypes = prefs.getStringList('${_keyPrefix}roomTypes') ?? [];

    // 각 방의 이미지 경로 로드
    final Map<String, List<String>> roomImages = {};
    for (final roomType in roomTypes) {
      final imagePaths = prefs.getStringList('${_keyPrefix}images_$roomType') ?? [];
      roomImages[roomType] = imagePaths;
    }

    state = state.copyWith(
        moveData: state.moveData.copyWith(
            roomTypes: roomTypes,
            roomImages: roomImages
        )
    );
  }

  // 메모 데이터 저장
  Future<void> setMemoData({
    required String memo,
    required int selectedCategory,
    required List<String> selectedTemplates,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('${_keyPrefix}memo', memo);
    await prefs.setInt('${_keyPrefix}memoCategory', selectedCategory);
    await prefs.setStringList('${_keyPrefix}memoTemplates', selectedTemplates);

    state = state.copyWith(
        moveData: state.moveData.copyWith(
          memo: memo,
          selectedMemoCategory: selectedCategory,
          selectedTemplates: selectedTemplates,
        )
    );
  }

  // 특별 관리 항목 저장
  Future<void> setSpecialItems(Map<String, bool> items) async {
    final prefs = await SharedPreferences.getInstance();

    // 각 아이템 개별 저장
    for (var entry in items.entries) {
      await prefs.setBool('${_keyPrefix}specialItem_${entry.key}', entry.value);
    }

    // 목록 자체를 저장 (true인 항목들만)
    final selectedItems = items.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    await prefs.setStringList('${_keyPrefix}selectedSpecialItems', selectedItems);

    state = state.copyWith(
        moveData: state.moveData.copyWith(
          specialItems: items,
        )
    );
  }

  // 메모 데이터 로드
  Future<void> _loadMemoData() async {
    final prefs = await SharedPreferences.getInstance();

    final memo = prefs.getString('${_keyPrefix}memo');
    final category = prefs.getInt('${_keyPrefix}memoCategory') ?? 0;
    final templates = prefs.getStringList('${_keyPrefix}memoTemplates') ?? [];

    // 특별 관리 항목 로드
    Map<String, bool> specialItems = {};
    final defaultItems = ['대형 가전제품', '피아노/전자피아노', '미술품/액자', '유리/도자기류', '운동기구'];

    for (var item in defaultItems) {
      specialItems[item] = prefs.getBool('${_keyPrefix}specialItem_$item') ?? false;
    }

    state = state.copyWith(
        moveData: state.moveData.copyWith(
          memo: memo,
          selectedMemoCategory: category,
          selectedTemplates: templates,
          specialItems: specialItems,
        )
    );
  }

// MoveNotifier 클래스에 추가
  Future<void> setServiceType(String serviceType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_keyPrefix}selectedServiceType', serviceType);

    state = state.copyWith(
        moveData: state.moveData.copyWith(selectedServiceType: serviceType)
    );
  }

// _loadAllData 메서드에 추가 필요
  Future<void> _loadServiceType() async {
    final prefs = await SharedPreferences.getInstance();
    final serviceType = prefs.getString('${_keyPrefix}selectedServiceType');

    if (serviceType != null) {
      state = state.copyWith(
          moveData: state.moveData.copyWith(selectedServiceType: serviceType)
      );
    }
  }
}
