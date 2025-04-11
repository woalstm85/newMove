import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 주소 상세 정보를 위한 불변 데이터 클래스
@immutable
class AddressDetails {
  final String address;
  final String detailAddress;
  final String buildingType;
  final String roomStructure;
  final String floor;
  final String roomSize;
  final bool hasStairs;
  final bool hasElevator;
  final bool parkingAvailable;

  const AddressDetails({
    required this.address,
    required this.detailAddress,
    required this.buildingType,
    required this.roomStructure,
    required this.floor,
    required this.roomSize,
    required this.hasStairs,
    required this.hasElevator,
    required this.parkingAvailable,
  });

  // copyWith 메서드를 통해 불변성 유지하며 데이터 수정
  AddressDetails copyWith({
    String? address,
    String? detailAddress,
    String? buildingType,
    String? roomStructure,
    String? floor,
    String? roomSize,
    bool? hasStairs,
    bool? hasElevator,
    bool? parkingAvailable,
  }) {
    return AddressDetails(
      address: address ?? this.address,
      detailAddress: detailAddress ?? this.detailAddress,
      buildingType: buildingType ?? this.buildingType,
      roomStructure: roomStructure ?? this.roomStructure,
      floor: floor ?? this.floor,
      roomSize: roomSize ?? this.roomSize,
      hasStairs: hasStairs ?? this.hasStairs,
      hasElevator: hasElevator ?? this.hasElevator,
      parkingAvailable: parkingAvailable ?? this.parkingAvailable,
    );
  }

  // 접근성 및 디버깅을 위한 toString 메서드
  @override
  String toString() {
    return '''
      AddressDetails:
      - Address: $address
      - Detail: $detailAddress
      - Building Type: $buildingType
      - Room Structure: $roomStructure
      - Floor: $floor
      - Room Size: $roomSize
      - Stairs: $hasStairs
      - Elevator: $hasElevator
      - Parking: $parkingAvailable
    ''';
  }
}

// 이동 유형에 따른 상태 클래스
class MoveState {
  final AddressDetails? startAddressDetails;
  final AddressDetails? destinationAddressDetails;

  const MoveState({
    this.startAddressDetails,
    this.destinationAddressDetails,
  });

  MoveState copyWith({
    AddressDetails? startAddressDetails,
    AddressDetails? destinationAddressDetails,
    bool resetStart = false,
    bool resetDestination = false,
  }) {
    return MoveState(
      startAddressDetails: resetStart
          ? null
          : (startAddressDetails ?? this.startAddressDetails),
      destinationAddressDetails: resetDestination
          ? null
          : (destinationAddressDetails ?? this.destinationAddressDetails),
    );
  }
}

// 정기 이사 Provider
class RegularMoveNotifier extends StateNotifier<MoveState> {
  RegularMoveNotifier() : super(const MoveState());

  // 출발지 주소 설정
  void setStartAddress(Map<String, dynamic> addressData) {
    final newStartAddress = AddressDetails(
      address: addressData['address'],
      detailAddress: addressData['detailAddress'],
      buildingType: addressData['buildingType'],
      roomStructure: addressData['roomStructure'],
      floor: addressData['floor'],
      roomSize: addressData['roomSize'],
      hasStairs: addressData['hasStairs'],
      hasElevator: addressData['hasElevator'],
      parkingAvailable: addressData['parkingAvailable'],
    );

    state = state.copyWith(startAddressDetails: newStartAddress);
  }

  // 도착지 주소 설정
  void setDestinationAddress(Map<String, dynamic> addressData) {
    final newDestinationAddress = AddressDetails(
      address: addressData['address'],
      detailAddress: addressData['detailAddress'],
      buildingType: addressData['buildingType'],
      roomStructure: addressData['roomStructure'],
      floor: addressData['floor'],
      roomSize: addressData['roomSize'],
      hasStairs: addressData['hasStairs'],
      hasElevator: addressData['hasElevator'],
      parkingAvailable: addressData['parkingAvailable'],
    );

    state = state.copyWith(destinationAddressDetails: newDestinationAddress);
  }

  // 출발지 주소 초기화
  void resetStartAddress() {
    state = state.copyWith(resetStart: true);
  }

  // 도착지 주소 초기화
  void resetDestinationAddress() {
    state = state.copyWith(resetDestination: true);
  }

  // 전체 이사 정보 유효성 검사
  bool validateMoveData() {
    return state.startAddressDetails != null &&
        state.destinationAddressDetails != null;
  }
}

// 특수 이사 Provider
class SpecialMoveNotifier extends StateNotifier<MoveState> {
  SpecialMoveNotifier() : super(const MoveState());

  // 출발지 주소 설정
  void setStartAddress(Map<String, dynamic> addressData) {
    final newStartAddress = AddressDetails(
      address: addressData['address'],
      detailAddress: addressData['detailAddress'],
      buildingType: addressData['buildingType'],
      roomStructure: addressData['roomStructure'],
      floor: addressData['floor'],
      roomSize: addressData['roomSize'],
      hasStairs: addressData['hasStairs'],
      hasElevator: addressData['hasElevator'],
      parkingAvailable: addressData['parkingAvailable'],
    );

    state = state.copyWith(startAddressDetails: newStartAddress);
  }

  // 도착지 주소 설정
  void setDestinationAddress(Map<String, dynamic> addressData) {
    final newDestinationAddress = AddressDetails(
      address: addressData['address'],
      detailAddress: addressData['detailAddress'],
      buildingType: addressData['buildingType'],
      roomStructure: addressData['roomStructure'],
      floor: addressData['floor'],
      roomSize: addressData['roomSize'],
      hasStairs: addressData['hasStairs'],
      hasElevator: addressData['hasElevator'],
      parkingAvailable: addressData['parkingAvailable'],
    );

    state = state.copyWith(destinationAddressDetails: newDestinationAddress);
  }

  // 출발지 주소 초기화
  void resetStartAddress() {
    state = state.copyWith(resetStart: true);
  }

  // 도착지 주소 초기화
  void resetDestinationAddress() {
    state = state.copyWith(resetDestination: true);
  }

  // 전체 이사 정보 유효성 검사
  bool validateMoveData() {
    return state.startAddressDetails != null &&
        state.destinationAddressDetails != null;
  }
}

// Provider 생성
final regularMoveProvider =
StateNotifierProvider<RegularMoveNotifier, MoveState>((ref) {
  return RegularMoveNotifier();
});

final specialMoveProvider =
StateNotifierProvider<SpecialMoveNotifier, MoveState>((ref) {
  return SpecialMoveNotifier();
});