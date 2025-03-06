import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_constants.dart';
import 'move_address_detail.dart';
import 'move_address_search.dart';
import '../modal/home_modal/baggage_type.dart';

class AddressInputScreen extends StatefulWidget {
  const AddressInputScreen({super.key});

  @override
  _AddressInputScreenState createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends State<AddressInputScreen> {
  Map<String, dynamic>? _startAddressDetails;
  Map<String, dynamic>? _destinationAddressDetails;

  @override
  void initState() {
    super.initState();
    _loadAddressData();
  }

  Future<void> _loadAddressData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _startAddressDetails = prefs.containsKey('startAddress')
          ? {
        'address': prefs.getString('startAddress')!,
        'detailAddress': prefs.getString('startDetailAddress')!,
        'buildingType': prefs.getString('startBuildingType')!,
        'roomStructure': prefs.getString('startRoomStructure')!,
        'roomSize': prefs.getString('startRoomSize')!,
        'floor': prefs.getString('startFloor')!,
        'hasStairs': prefs.getBool('startHasStairs')!,
        'hasElevator': prefs.getBool('startHasElevator')!,
        'parkingAvailable': prefs.getBool('startParkingAvailable')!,
      }
          : null;

      _destinationAddressDetails = prefs.containsKey('destinationAddress')
          ? {
        'address': prefs.getString('destinationAddress')!,
        'detailAddress': prefs.getString('destinationDetailAddress')!,
        'buildingType': prefs.getString('destinationBuildingType')!,
        'roomStructure': prefs.getString('destinationRoomStructure')!,
        'roomSize': prefs.getString('destinationRoomSize')!,
        'floor': prefs.getString('destinationFloor')!,
        'hasStairs': prefs.getBool('destinationHasStairs')!,
        'hasElevator': prefs.getBool('destinationHasElevator')!,
        'parkingAvailable': prefs.getBool('destinationParkingAvailable')!,
      }
          : null;
    });
  }

  Future<void> _saveAddressData(
      Map<String, dynamic>? startAddress, Map<String, dynamic>? destinationAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (startAddress != null) {
      await prefs.setString('startAddress', startAddress['address']);
      await prefs.setString('startDetailAddress', startAddress['detailAddress']);
      await prefs.setString('startBuildingType', startAddress['buildingType']);
      await prefs.setString('startRoomStructure', startAddress['roomStructure']);
      await prefs.setString('startRoomSize', startAddress['roomSize']);
      await prefs.setString('startFloor', startAddress['floor']);
      await prefs.setBool('startHasStairs', startAddress['hasStairs']);
      await prefs.setBool('startHasElevator', startAddress['hasElevator']);
      await prefs.setBool('startParkingAvailable', startAddress['parkingAvailable']);
    }

    if (destinationAddress != null) {
      await prefs.setString('destinationAddress', destinationAddress['address']);
      await prefs.setString('destinationDetailAddress', destinationAddress['detailAddress']);
      await prefs.setString('destinationBuildingType', destinationAddress['buildingType']);
      await prefs.setString('destinationRoomStructure', destinationAddress['roomStructure']);
      await prefs.setString('destinationRoomSize', destinationAddress['roomSize']);
      await prefs.setString('destinationFloor', destinationAddress['floor']);
      await prefs.setBool('destinationHasStairs', destinationAddress['hasStairs']);
      await prefs.setBool('destinationHasElevator', destinationAddress['hasElevator']);
      await prefs.setBool('destinationParkingAvailable', destinationAddress['parkingAvailable']);
    }
  }

  // 출발지 주소 검색 후 디테일 화면으로 이동
  Future<void> _searchStartAddress() async {
    if (_startAddressDetails != null) {
      Map<String, dynamic>? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddressDetailsScreen(
            selectedAddress: _startAddressDetails!['address'],
            isStart: true,
            initialDetails: _startAddressDetails,
          ),
        ),
      );
      if (result != null) {
        setState(() {
          _startAddressDetails = result;
        });
        _saveAddressData(result, _destinationAddressDetails);
      }
    } else {
      // 새로운 주소 검색 화면 사용
      Map<String, dynamic>? postcodeResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PostcodeSearchScreen(),
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

        Map<String, dynamic>? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddressDetailsScreen(
              selectedAddress: fullAddress,
              isStart: true,
            ),
          ),
        );
        if (result != null) {
          setState(() {
            _startAddressDetails = result;
          });
          _saveAddressData(result, _destinationAddressDetails);
        }
      }
    }
  }

  // 도착지 주소 검색 후 디테일 화면으로 이동
  Future<void> _searchDestinationAddress() async {
    if (_destinationAddressDetails != null) {
      Map<String, dynamic>? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddressDetailsScreen(
            selectedAddress: _destinationAddressDetails!['address'],
            isStart: false,
            initialDetails: _destinationAddressDetails,
          ),
        ),
      );
      if (result != null) {
        setState(() {
          _destinationAddressDetails = result;
        });
        _saveAddressData(_startAddressDetails, result);
      }
    } else {
      // 새로운 주소 검색 화면 사용
      Map<String, dynamic>? postcodeResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PostcodeSearchScreen(),
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

        Map<String, dynamic>? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddressDetailsScreen(
              selectedAddress: fullAddress,
              isStart: false,
            ),
          ),
        );
        if (result != null) {
          setState(() {
            _destinationAddressDetails = result;
          });
          _saveAddressData(_startAddressDetails, result);
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
        return const BaggageTypeModal();
      },
    );
  }

  // 주소와 상세 주소를 표시하는 함수
  String _buildAddressSummary(Map<String, dynamic> addressDetails) {
    return '${addressDetails['buildingType']} | '
        '${addressDetails['roomStructure']} | '
        '${addressDetails['roomSize']} | '
        '${addressDetails['floor']}';
  }

  // 주소에 대한 상세 정보를 보여주는 위젯
  Widget _buildAddressDetails(Map<String, dynamic> addressDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${addressDetails['address']} ${addressDetails['detailAddress']}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.secondaryText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          _buildAddressSummary(addressDetails),
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildInfoChip((addressDetails['hasStairs'] ?? false) ? '1층 계단 있음' : '1층 계단 없음'),
            _buildInfoChip((addressDetails['hasElevator'] ?? false) ? '엘리베이터 있음' : '엘리베이터 없음'),
            _buildInfoChip((addressDetails['parkingAvailable'] ?? false) ? '주차 가능' : '주차 불가'),
          ],
        ),
      ],
    );
  }

  // 태그 스타일 위젯
  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed = _startAddressDetails != null && _destinationAddressDetails != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 텍스트
                  Text(
                    '출발지와 도착지를 알려주세요',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '정확한 주소 정보를 입력하면 더 정확한 견적을 받을 수 있어요',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 출발지 섹션
                  _buildAddressSection(
                    title: '출발지',
                    icon: Icons.location_on_outlined,
                    details: _startAddressDetails,
                    onTap: _searchStartAddress,
                  ),

                  const SizedBox(height: 20),

                  // 도착지 섹션
                  _buildAddressSection(
                    title: '도착지',
                    icon: Icons.flag_outlined,
                    details: _destinationAddressDetails,
                    onTap: _searchDestinationAddress,
                  ),

                  const SizedBox(height: 30),

                  // 안내 섹션
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: AppTheme.primaryColor,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '파트너 선택 전에는 고객님의 주소와 연락처가 노출되지 않으니 안심하세요.',
                                style: TextStyle(
                                  color: AppTheme.secondaryText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼
          SafeArea(
          child:
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                onPressed: canProceed
                    ? () => _showBaggageTypeModal()
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
                  '다음 단계로',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 주소 섹션 위젯
  Widget _buildAddressSection({
    required String title,
    required IconData icon,
    required Map<String, dynamic>? details,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: details != null
              ? AppTheme.primaryColor.withOpacity(0.03)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: details != null
                ? AppTheme.primaryColor.withOpacity(0.2)
                : AppTheme.borderColor,
            width: 1.5,
          ),
          boxShadow: details != null
              ? [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: details != null
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: details != null
                        ? AppTheme.primaryColor
                        : AppTheme.secondaryText,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: details != null
                        ? AppTheme.primaryText
                        : AppTheme.secondaryText,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.edit_outlined,
                  color: details != null
                      ? AppTheme.primaryColor
                      : AppTheme.secondaryText,
                  size: 16,
                ),
              ],
            ),
            if (details != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildAddressDetails(details),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                '주소를 입력해주세요',
                style: TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}