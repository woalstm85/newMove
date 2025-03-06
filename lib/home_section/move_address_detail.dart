import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import 'move_address_search.dart';
import '../modal/home_modal/move_floor.dart';
import '../modal/home_modal/move_home_size.dart';
import '../modal/home_modal/move_address_edit.dart';

class AddressDetailsScreen extends StatefulWidget {
  final String selectedAddress;
  final bool isStart;
  final Map<String, dynamic>? initialDetails;

  const AddressDetailsScreen({
    super.key,
    required this.selectedAddress,
    required this.isStart,
    this.initialDetails,
  });

  @override
  _AddressDetailsScreenState createState() => _AddressDetailsScreenState();
}

class _AddressDetailsScreenState extends State<AddressDetailsScreen> {
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
    currentAddress = widget.selectedAddress;

    // 초기 데이터가 있으면 필드 초기화
    if (widget.initialDetails != null) {
      buildingType = widget.initialDetails!['buildingType'] ?? '';
      roomStructure = widget.initialDetails!['roomStructure'] ?? '';
      floor = widget.initialDetails!['floor'] ?? '선택';
      roomSize = widget.initialDetails!['roomSize'] ?? '선택';
      hasStairs = widget.initialDetails!['hasStairs'] ?? false;
      hasElevator = widget.initialDetails!['hasElevator'] ?? false;
      parkingAvailable = widget.initialDetails!['parkingAvailable'] ?? false;
      detailAddressController.text = widget.initialDetails!['detailAddress'] ?? '';
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
        builder: (context) => PostcodeSearchScreen(),
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
    );

    if (shouldEdit == true) {
      _navigateToAddressSearch();
    }
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 선택한 주소 표시 (수정 버튼 추가)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
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
                                fontSize: 13,
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
                                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 14,
                                      color: AppTheme.primaryColor,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '수정',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.primaryColor,
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
                            fontSize: 16,
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
                        fontSize: 14,
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
                          color: AppTheme.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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

                  const SizedBox(height: 32),

                  // 방 구조 (새로운 UI)
                  _buildSectionTitle('방 구조'),
                  const SizedBox(height: 16),
                  _buildOptionCards(roomStructureOptions, roomStructure, (value) {
                    setState(() {
                      roomStructure = value;
                    });
                  }),

                  const SizedBox(height: 32),

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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: ElevatedButton(
                  onPressed: _areAllFieldsSelected()
                      ? () {
                    Navigator.pop(context, {
                      'address': currentAddress,
                      'detailAddress': detailAddressController.text,
                      'buildingType': buildingType,
                      'roomStructure': roomStructure,
                      'floor': floor,
                      'roomSize': roomSize,
                      'hasStairs': hasStairs,
                      'hasElevator': hasElevator,
                      'parkingAvailable': parkingAvailable,
                    });
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 54),
                    elevation: 0,
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
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
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryText,
      ),
    );
  }

  // 새로운 옵션 카드 UI
  Widget _buildOptionCards(List<Map<String, dynamic>> options, String selectedValue, Function(String) onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        bool isSelected = selectedValue == option['value'];
        return GestureDetector(
          onTap: () => onSelect(option['value']),
          child: Container(
            width: (MediaQuery.of(context).size.width - 50) / 2,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.3) : AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    option['icon'],
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    size: 18,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option['title'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppTheme.primaryText,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // 리스트 타일 옵션 위젯 (개선됨)
  Widget _buildListTileOption(
      String title,
      String selectedOption,
      IconData icon,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedOption != '선택' ? AppTheme.primaryColor.withOpacity(0.5) : AppTheme.borderColor,
            width: 1,
          ),
          boxShadow: selectedOption != '선택'
              ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.primaryText,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selectedOption != '선택' ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                selectedOption,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selectedOption != '선택' ? FontWeight.bold : FontWeight.normal,
                  color: selectedOption != '선택' ? AppTheme.primaryColor : AppTheme.secondaryText,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  // 토글 옵션 카드 UI (3개의 토글 옵션을 카드로 표시)
  Widget _buildToggleCardOptions() {
    return Container(
      padding: EdgeInsets.all(16),
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
          _buildToggleSwitch('1층 별도 계단', hasStairs, (value) {
            setState(() {
              hasStairs = value;
            });
          }, Icons.stairs),
          Divider(height: 24),
          _buildToggleSwitch('엘리베이터', hasElevator, (value) {
            setState(() {
              hasElevator = value;
            });
          }, Icons.elevator),
          Divider(height: 24),
          _buildToggleSwitch('주차', parkingAvailable, (value) {
            setState(() {
              parkingAvailable = value;
            });
          }, Icons.local_parking),
        ],
      ),
    );
  }

  // 토글 스위치 위젯
  Widget _buildToggleSwitch(String title, bool value, Function(bool) onChanged, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 18,
          ),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.primaryText,
          ),
        ),
        Spacer(),
        Row(
          children: [
            Text(
              value ? '있음' : '없음',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText,
              ),
            ),
            SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
              activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ],
        ),
      ],
    );
  }

  // 층 선택 모달 (개선된 UI)
  void _showFloorSelectionModal() {
    List<String> floorOptions = ['반지하'];
    for (int i = 1; i <= 29; i++) {
      floorOptions.add('$i층');
    }
    floorOptions.add('30층 이상');

    String tempSelectedFloor = floor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.layers_outlined,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '층 선택',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),
                  Text(
                    '* 건물의 층수를 선택해주세요',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.secondaryText,
                    ),
                  ),

                  SizedBox(height: 20),

                  // 층 선택 목록
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: floorOptions.map((option) {
                          bool isSelected = tempSelectedFloor == option;
                          return GestureDetector(
                            onTap: () {
                              modalSetState(() {
                                tempSelectedFloor = option;
                              });
                            },
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 60) / 3,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : AppTheme.primaryText,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // 확인 버튼
                  SafeArea(
                    child: ElevatedButton(
                      onPressed: tempSelectedFloor != '선택'
                          ? () {
                        setState(() {
                          floor = tempSelectedFloor;
                        });
                        Navigator.pop(context);
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 54),
                        elevation: 0,
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 집 평수 선택 모달 (개선된 UI)
  void _showRoomSizeSelectionModal() {
    final List<Map<String, dynamic>> roomSizeOptions = [
      {'value': '10평 이하', 'description': '약 33㎡ 이하'},
      {'value': '10~15평', 'description': '약 33~50㎡'},
      {'value': '15~20평', 'description': '약 50~66㎡'},
      {'value': '20~25평', 'description': '약 66~83㎡'},
      {'value': '25~30평', 'description': '약 83~99㎡'},
      {'value': '30~40평', 'description': '약 99~132㎡'},
      {'value': '40~50평', 'description': '약 132~165㎡'},
      {'value': '50평 이상', 'description': '약 165㎡ 이상'},
    ];

    String tempSelectedRoomSize = roomSize;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.straighten_outlined,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            '집 평수 선택',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),
                  Text(
                    '* 정확한 평수가 필요 없으며, 대략적인 평수를 선택해주세요',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.secondaryText,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 평수 선택 리스트
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: roomSizeOptions.length,
                      separatorBuilder: (context, index) => SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final option = roomSizeOptions[index];
                        bool isSelected = tempSelectedRoomSize == option['value'];

                        return GestureDetector(
                          onTap: () {
                            modalSetState(() {
                              tempSelectedRoomSize = option['value'];
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: Offset(0, 2),
                                ),
                              ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['value'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : AppTheme.primaryText,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      option['description'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isSelected ? Colors.white.withOpacity(0.8) : AppTheme.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isSelected)
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: AppTheme.primaryColor,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 확인 버튼
                  SafeArea(
                    child: ElevatedButton(
                      onPressed: tempSelectedRoomSize != '선택'
                          ? () {
                        setState(() {
                          roomSize = tempSelectedRoomSize;
                        });
                        Navigator.pop(context);
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 54),
                        elevation: 0,
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}