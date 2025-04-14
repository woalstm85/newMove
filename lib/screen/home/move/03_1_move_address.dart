import 'package:MoveSmart/screen/home/move/move_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/utils/ui_mixins.dart';
import 'package:MoveSmart/screen/home/move/components/03_address/address_card.dart';

import 'package:MoveSmart/screen/home/move/03_2_move_address_search.dart';
import 'package:MoveSmart/screen/home/move/03_3_move_address_detail.dart';

import 'package:MoveSmart/screen/home/move/modal/baggage_type.dart';

class AddressInputScreen extends ConsumerStatefulWidget {
  final bool isRegularMove;

  const AddressInputScreen({super.key, required this.isRegularMove});

  @override
  ConsumerState<AddressInputScreen> createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends ConsumerState<AddressInputScreen> with MoveFlowMixin {
  // 로컬 UI 상태
  Map<String, dynamic>? _startAddressDetails;
  Map<String, dynamic>? _destinationAddressDetails;

  @override
  void initState() {
    super.initState();
    // MoveFlowMixin의 isRegularMove 설정
    isRegularMove = widget.isRegularMove;

    // Provider에서 초기 주소 데이터 로드
    _loadAddressData();
  }

  // Provider에서 주소 데이터 로드
  void _loadAddressData() {
    final moveData = _getMoveData();
    setState(() {
      _startAddressDetails = moveData.startAddressDetails;
      _destinationAddressDetails = moveData.destinationAddressDetails;
    });
  }

  // 현재 이사 유형에 따른 MoveData 가져오기
  MoveData _getMoveData() {
    return widget.isRegularMove
        ? ref.read(regularMoveProvider).moveData
        : ref.read(specialMoveProvider).moveData;
  }

  // 현재 이사 유형에 따른 MoveNotifier 가져오기
  MoveNotifier _getMoveNotifier() {
    return widget.isRegularMove
        ? ref.read(regularMoveProvider.notifier)
        : ref.read(specialMoveProvider.notifier);
  }

  // 주소 데이터 저장
  Future<void> _saveAddressData({
    Map<String, dynamic>? startAddress,
    Map<String, dynamic>? destinationAddress
  }) async {
    final moveNotifier = _getMoveNotifier();

    if (startAddress != null) {
      await moveNotifier.setStartAddress(startAddress);
      setState(() => _startAddressDetails = startAddress);
    }

    if (destinationAddress != null) {
      await moveNotifier.setDestinationAddress(destinationAddress);
      setState(() => _destinationAddressDetails = destinationAddress);
    }
  }

  // 출발지 주소 검색 및 설정
  Future<void> _searchStartAddress() async {
    final moveData = _getMoveData();

    if (moveData.startAddressDetails != null) {
      // 기존 주소 수정
      _editExistingAddress(
          isStart: true,
          initialDetails: moveData.startAddressDetails!
      );
    } else {
      // 새 주소 검색
      _searchNewAddress(isStart: true);
    }
  }

  // 도착지 주소 검색 및 설정
  Future<void> _searchDestinationAddress() async {
    final moveData = _getMoveData();

    if (moveData.destinationAddressDetails != null) {
      // 기존 주소 수정
      _editExistingAddress(
          isStart: false,
          initialDetails: moveData.destinationAddressDetails!
      );
    } else {
      // 새 주소 검색
      _searchNewAddress(isStart: false);
    }
  }

  // 기존 주소 수정
  Future<void> _editExistingAddress({
    required bool isStart,
    required Map<String, dynamic> initialDetails
  }) async {
    Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressDetailsScreen(
            selectedAddress: initialDetails['address'],
            isStart: isStart,
            initialDetails: initialDetails,
            isRegularMove: widget.isRegularMove
        ),
      ),
    );

    if (result != null) {
      if (isStart) {
        await _saveAddressData(startAddress: result);
      } else {
        await _saveAddressData(destinationAddress: result);
      }
    }
  }

  // 새 주소 검색
  Future<void> _searchNewAddress({required bool isStart}) async {
    // 주소 검색 화면으로 이동
    Map<String, dynamic>? postcodeResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostcodeSearchScreen(
          isRegularMove: widget.isRegularMove,
        ),
      ),
    );

    if (postcodeResult != null) {
      // 도로명 주소 또는 지번 주소 선택
      String fullAddress = postcodeResult['roadAddress'] ?? postcodeResult['jibunAddress'] ?? '';

      // 건물명이 있으면 추가
      if (postcodeResult['buildingName'] != null &&
          postcodeResult['buildingName'].toString().isNotEmpty) {
        fullAddress += ' (${postcodeResult['buildingName']})';
      }

      // 주소 상세 정보 입력 화면으로 이동
      Map<String, dynamic>? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddressDetailsScreen(
            selectedAddress: fullAddress,
            isStart: isStart,
            isRegularMove: widget.isRegularMove,
          ),
        ),
      );

      if (result != null) {
        if (isStart) {
          await _saveAddressData(startAddress: result);
        } else {
          await _saveAddressData(destinationAddress: result);
        }
      }
    }
  }

  // 모달 띄우기
  void _showBaggageTypeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BaggageTypeModal(isRegularMove: widget.isRegularMove);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provider를 통한 상태 감시
    final moveData = widget.isRegularMove
        ? ref.watch(regularMoveProvider).moveData
        : ref.watch(specialMoveProvider).moveData;

    final bool canProceed = moveData.startAddressDetails != null &&
        moveData.destinationAddressDetails != null;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 진행 상황 표시 바 (앱바 바로 아래)
          MoveProgressBar(
            currentStep: 1,  // 첫 번째 단계
            isRegularMove: isRegularMove,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 15),

                  // 출발지 섹션
                  AddressCard(
                    title: '출발지',
                    icon: Icons.location_on_outlined,
                    details: _startAddressDetails,
                    primaryColor: primaryColor,
                    onTap: _searchStartAddress,
                  ),

                  const SizedBox(height: 20),

                  // 도착지 섹션
                  AddressCard(
                    title: '도착지',
                    icon: Icons.flag_outlined,
                    details: _destinationAddressDetails,
                    primaryColor: primaryColor,
                    onTap: _searchDestinationAddress,
                  ),

                  const SizedBox(height: 30),

                  // 안내 섹션
                  _buildInfoSection(),
                ],
              ),
            ),
          ),

          // 하단 버튼
          _buildBottomButton(canProceed),
        ],
      ),
    );
  }

  // 앱바 위젯
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '주소 입력',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryText,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // 헤더 텍스트 위젯
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '출발지와 도착지를 알려주세요',
          style: TextStyle(
            fontSize: context.scaledFontSize(22),
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '정확한 주소 정보를 입력하면 더 정확한 견적을 받을 수 있어요',
          style: TextStyle(
            fontSize: context.scaledFontSize(14),
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  // 안내 섹션 위젯
  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '개인정보 보호',
                  style: TextStyle(
                    fontSize: context.scaledFontSize(16),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '파트너 선택 전에는 고객님의 주소와 연락처가 노출되지 않으니 안심하세요.',
                  style: TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: context.scaledFontSize(13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 하단 버튼 위젯
  Widget _buildBottomButton(bool canProceed) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(context.defaultPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: canProceed ? () => _showBaggageTypeModal() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(context.defaultPadding),
            minimumSize: const Size(double.infinity, 54),
            elevation: 0,
          ),
          child: Text(
            '다음 단계로',
            style: TextStyle(
              fontSize: context.scaledFontSize(16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}