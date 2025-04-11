import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/utils/ui_mixins.dart';

import 'move_address_search.dart';

import 'package:MoveSmart/screen/home/move/modal/move_floor.dart';
import 'package:MoveSmart/screen/home/move/modal/move_home_size.dart';
import 'package:MoveSmart/screen/home/move/modal/move_address_edit.dart';

import 'package:MoveSmart/screen/home/move/components/03_address/detail_option_card.dart';
import 'package:MoveSmart/screen/home/move/components/03_address/detail_list_title_option.dart';
import 'package:MoveSmart/screen/home/move/components/03_address/detail_toggle_option.dart';

class AddressDetailsScreen extends ConsumerStatefulWidget {
  final String selectedAddress;
  final bool isStart;
  final Map<String, dynamic>? initialDetails;
  final bool isRegularMove;

  const AddressDetailsScreen({
    super.key,
    required this.selectedAddress,
    required this.isStart,
    this.initialDetails,
    required this.isRegularMove
  });

  @override
  ConsumerState<AddressDetailsScreen> createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends ConsumerState<AddressDetailsScreen> with MoveFlowMixin {
  // 기존 상태 변수 유지
  String buildingType = '';
  String roomStructure = '';
  String floor = '선택';
  String roomSize = '선택';
  bool hasStairs = false;
  bool hasElevator = false;
  bool parkingAvailable = false;
  String currentAddress = '';
  TextEditingController detailAddressController = TextEditingController();


  // 건물 종류 옵션 정의
  final List<Map<String, dynamic>> buildingOptions = [
    {'icon': Icons.apartment, 'title': '빌라/연립', 'value': '빌라/연립'},
    {'icon': Icons.business, 'title': '오피스텔', 'value': '오피스텔'},
    {'icon': Icons.home, 'title': '주택', 'value': '주택'},
    {'icon': Icons.location_city, 'title': '아파트', 'value': '아파트'},
    {'icon': Icons.store, 'title': '상가/사무실', 'value': '상가/사무실'},
  ];

  // 방 구조 옵션 정의
  final List<Map<String, dynamic>> roomStructureOptions = [
    {'icon': Icons.single_bed, 'title': '원룸', 'value': '원룸'},
    {'icon': Icons.bedroom_child, 'title': '1.5룸', 'value': '1.5룸'},
    {'icon': Icons.king_bed, 'title': '2룸', 'value': '2룸'},
    {'icon': Icons.meeting_room, 'title': '3룸', 'value': '3룸'},
    {'icon': Icons.other_houses, 'title': '4룸', 'value': '4룸'},
    {'icon': Icons.holiday_village, 'title': '5룸 이상', 'value': '5룸 이상'},
  ];

  @override
  void initState() {
    super.initState();

    // MoveFlowMixin의 isRegularMove 설정
    isRegularMove = widget.isRegularMove;

    currentAddress = widget.selectedAddress;

    // Provider에서 데이터를 가져오는 방식으로 변경
    if (widget.initialDetails != null) {
      // 기존 코드 유지
      buildingType = widget.initialDetails!['buildingType'] ?? '';
      roomStructure = widget.initialDetails!['roomStructure'] ?? '';
      floor = widget.initialDetails!['floor'] ?? '선택';
      roomSize = widget.initialDetails!['roomSize'] ?? '선택';
      hasStairs = widget.initialDetails!['hasStairs'] ?? false;
      hasElevator = widget.initialDetails!['hasElevator'] ?? false;
      parkingAvailable = widget.initialDetails!['parkingAvailable'] ?? false;
      detailAddressController.text = widget.initialDetails!['detailAddress'] ?? '';
    } else {
      // Provider에서 데이터 확인
      final moveProvider = widget.isRegularMove
          ? ref.read(regularMoveProvider)
          : ref.read(specialMoveProvider);

      final addressDetails = widget.isStart
          ? moveProvider.moveData.startAddressDetails
          : moveProvider.moveData.destinationAddressDetails;

      if (addressDetails != null) {
        buildingType = addressDetails['buildingType'] ?? '';
        roomStructure = addressDetails['roomStructure'] ?? '';
        floor = addressDetails['floor'] ?? '선택';
        roomSize = addressDetails['roomSize'] ?? '선택';
        hasStairs = addressDetails['hasStairs'] ?? false;
        hasElevator = addressDetails['hasElevator'] ?? false;
        parkingAvailable = addressDetails['parkingAvailable'] ?? false;
        detailAddressController.text = addressDetails['detailAddress'] ?? '';
      }
    }
  }

  // 모든 필드가 선택되었는지 확인
  bool _areAllFieldsSelected() {
    return buildingType.isNotEmpty &&
        roomStructure.isNotEmpty &&
        roomSize != '선택' &&
        floor != '선택' &&
        detailAddressController.text.isNotEmpty;
  }

  // 주소 검색 페이지로 이동하여 새 주소 선택
  Future<void> _navigateToAddressSearch() async {
    // PostcodeSearchScreen으로 이동하고 결과를 기다림
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostcodeSearchScreen(
          isRegularMove: widget.isRegularMove,
        ),
      ),
    );

    // 결과가 있으면 주소 업데이트
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        currentAddress = result['roadAddress'];
      });
    }
  }

  // 주소 수정 다이얼로그 호출
  void _showEditAddressDialog() async {
    final shouldEdit = await showAddressEditDialog(
      context: context,
      currentAddress: currentAddress,
      isRegularMove: widget.isRegularMove,
    );

    if (shouldEdit == true) {
      _navigateToAddressSearch();
    }
  }

  void _saveAddressData() {
    final addressData = {
      'address': currentAddress,
      'detailAddress': detailAddressController.text,
      'buildingType': buildingType,
      'roomStructure': roomStructure,
      'floor': floor,
      'roomSize': roomSize,
      'hasStairs': hasStairs,
      'hasElevator': hasElevator,
      'parkingAvailable': parkingAvailable,
    };

    // Provider를 통해 데이터 저장 후 화면 닫기
    final moveProvider = widget.isRegularMove
        ? ref.read(regularMoveProvider.notifier)
        : ref.read(specialMoveProvider.notifier);

    if (widget.isStart) {
      moveProvider.setStartAddress(addressData);
    } else {
      moveProvider.setDestinationAddress(addressData);
    }

    Navigator.pop(context, addressData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isStart ? '출발지 상세 정보' : '도착지 상세 정보',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 선택한 주소 표시 (수정 버튼 추가)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.defaultPadding),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '선택한 주소',
                              style: TextStyle(
                                fontSize: context.scaledFontSize(13),
                                fontWeight: FontWeight.w500,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                            InkWell(
                              onTap: _showEditAddressDialog,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: primaryColor.withOpacity(0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 14,
                                      color: primaryColor,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '수정',
                                      style: TextStyle(
                                        fontSize: context.scaledFontSize(12),
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentAddress,
                          style: TextStyle(
                            fontSize: context.scaledFontSize(16),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 상세 주소
                  _buildSectionTitle('상세 주소'),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: detailAddressController,
                    decoration: InputDecoration(
                      hintText: '상세 주소 입력 (동/호수 등)',
                      hintStyle: TextStyle(
                        color: AppTheme.subtleText,
                        fontSize: context.scaledFontSize(14),
                      ),
                      prefixIcon: Icon(
                        Icons.home_outlined,
                        color: AppTheme.secondaryText,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.borderColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(context.smallPadding),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 건물 종류 (새로운 UI)
                  _buildSectionTitle('건물 종류'),
                  const SizedBox(height: 16),
                  _buildOptionCards(buildingOptions, buildingType, (value) {
                    setState(() {
                      buildingType = value;
                    });
                  }),

                  const SizedBox(height: 22),

                  // 방 구조 (새로운 UI)
                  _buildSectionTitle('방 구조'),
                  const SizedBox(height: 22),
                  _buildOptionCards(roomStructureOptions, roomStructure, (value) {
                    setState(() {
                      roomStructure = value;
                    });
                  }),

                  const SizedBox(height: 22),

                  // 집 평수
                  _buildListTileOption(
                    '집 평수',
                    roomSize,
                    Icons.straighten_outlined,
                        () {
                      // 외부 모달 호출
                      showRoomSizeSelector(
                        context: context,
                        initialSelection: roomSize,
                        onConfirm: (selectedSize) {
                          setState(() {
                            roomSize = selectedSize;
                          });
                        },
                        isRegularMove: widget.isRegularMove,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 층 선택
                  _buildListTileOption(
                    '층 선택',
                    floor,
                    Icons.layers_outlined,
                        () {
                      // 외부 모달 호출
                      showFloorSelector(
                        context: context,
                        initialSelection: floor,
                        onConfirm: (selectedFloor) {
                          setState(() {
                            floor = selectedFloor;
                          });
                        },
                        isRegularMove: widget.isRegularMove,
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // 기타 옵션들 (카드 스타일로 변경)
                  _buildSectionTitle('추가 정보'),
                  const SizedBox(height: 16),
                  _buildToggleCardOptions(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 하단 버튼 (네비게이션 바와 겹치지 않도록 개선)
          Container(
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
            // SafeArea에 bottom: true를 설정하여 네비게이션 바와 겹치지 않도록 함
            child: SafeArea(
              bottom: true, // 이 부분이 중요! 네비게이션 바 공간 확보
              child: Padding(
                padding: EdgeInsets.all(context.defaultPadding),
                child: ElevatedButton(
                  onPressed: _areAllFieldsSelected()
                      ? () {
                    _saveAddressData();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: context.scaledFontSize(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 섹션 타이틀 위젯
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: context.scaledFontSize(16),
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryText,
      ),
    );
  }

  // 옵션 카드 UI
  Widget _buildOptionCards(List<Map<String, dynamic>> options, String selectedValue, Function(String) onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        return OptionCard(
          option: option,
          isSelected: selectedValue == option['value'],
          onSelect: onSelect,
        );
      }).toList(),
    );
  }

  // 리스트 타일 옵션 위젯
  Widget _buildListTileOption(
      String title,
      String selectedOption,
      IconData icon,
      VoidCallback onTap,
      ) {
    return ListTileOption(
      title: title,
      selectedOption: selectedOption,
      icon: icon,
      onTap: onTap,
    );
  }

  // 토글 옵션 카드 UI (3개의 토글 옵션을 카드로 표시)
  Widget _buildToggleCardOptions() {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ToggleOptionSwitch(
            title: '1층 별도 계단',
            value: hasStairs,
            onChanged: (value) {
              setState(() {
                hasStairs = value;
              });
            },
            icon: Icons.stairs,
          ),
          Divider(height: 24),
          ToggleOptionSwitch(
            title: '엘리베이터',
            value: hasElevator,
            onChanged: (value) {
              setState(() {
                hasElevator = value;
              });
            },
            icon: Icons.elevator,
          ),
          Divider(height: 24),
          ToggleOptionSwitch(
            title: '주차',
            value: parkingAvailable,
            onChanged: (value) {
              setState(() {
                parkingAvailable = value;
              });
            },
            icon: Icons.local_parking,
          ),
        ],
      ),
    );
  }
}