import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import 'move_address_detail.dart';
import 'move_address_search.dart';
import '../modal/home_modal/baggage_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/move_provider.dart';
import '../utils/ui_extensions.dart';
import '../utils/ui_mixins.dart';

class AddressInputScreen extends ConsumerStatefulWidget {
  final bool isRegularMove;

  const AddressInputScreen({super.key, required this.isRegularMove});

  @override
  ConsumerState<AddressInputScreen> createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends ConsumerState<AddressInputScreen> with MoveFlowMixin {
  // Riverpod을 사용한 상태 관리로 변경
  Map<String, dynamic>? _startAddressDetails;
  Map<String, dynamic>? _destinationAddressDetails;

  @override
  void initState() {
    super.initState();
    // Provider에서 초기 주소 데이터 로드
    final moveProvider = widget.isRegularMove
        ? ref.read(regularMoveProvider)
        : ref.read(specialMoveProvider);

    // MoveFlowMixin의 isRegularMove 설정
    isRegularMove = widget.isRegularMove;

    _startAddressDetails = moveProvider.moveData.startAddressDetails;
    _destinationAddressDetails = moveProvider.moveData.destinationAddressDetails;
  }

  Future<void> _saveAddressData(Map<String, dynamic>? startAddress, Map<String, dynamic>? destinationAddress) async {
    final moveProvider = widget.isRegularMove
        ? ref.read(regularMoveProvider.notifier)
        : ref.read(specialMoveProvider.notifier);

    if (startAddress != null) {
      await moveProvider.setStartAddress(startAddress);
    }
    if (destinationAddress != null) {
      await moveProvider.setDestinationAddress(destinationAddress);
    }
  }

  // 출발지 주소 검색 후 디테일 화면으로 이동
  Future<void> _searchStartAddress() async {
    final moveData = widget.isRegularMove
        ? ref.read(regularMoveProvider).moveData
        : ref.read(specialMoveProvider).moveData;

    if (moveData.startAddressDetails != null) {
      Map<String, dynamic>? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddressDetailsScreen(
              selectedAddress: moveData.startAddressDetails!['address'],
              isStart: true,
              initialDetails: moveData.startAddressDetails,
              isRegularMove: widget.isRegularMove
          ),
        ),
      );
      if (result != null) {
        // Riverpod을 통해 상태 업데이트
        final moveProvider = widget.isRegularMove
            ? ref.read(regularMoveProvider.notifier)
            : ref.read(specialMoveProvider.notifier);

        moveProvider.setStartAddress(result);
      }
    } else {
      // 새로운 주소 검색 화면 사용
      Map<String, dynamic>? postcodeResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostcodeSearchScreen(
            isRegularMove: widget.isRegularMove, // 이 부분을 추가
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

        Map<String, dynamic>? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddressDetailsScreen(
              selectedAddress: fullAddress,
              isStart: true,
              isRegularMove: widget.isRegularMove,
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
            isRegularMove: widget.isRegularMove,
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
          builder: (context) => PostcodeSearchScreen(
            isRegularMove: widget.isRegularMove, // 이 부분을 추가
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

        Map<String, dynamic>? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddressDetailsScreen(
              selectedAddress: fullAddress,
              isStart: false,
              isRegularMove: widget.isRegularMove,
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
        return BaggageTypeModal(isRegularMove: widget.isRegularMove);
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
            fontSize: context.scaledFontSize(14),
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
            fontSize: context.scaledFontSize(12),
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
      padding: EdgeInsets.all(context.smallPadding),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: primaryColor,
          fontSize: context.scaledFontSize(11),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod을 사용한 상태 읽기
    final moveData = widget.isRegularMove
        ? ref.watch(regularMoveProvider).moveData
        : ref.watch(specialMoveProvider).moveData;

    final bool canProceed =
        moveData.startAddressDetails != null &&
            moveData.destinationAddressDetails != null;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
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
              padding: EdgeInsets.all(context.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더 텍스트
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
                  const SizedBox(height: 15),

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
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼
          SafeArea(
          child:
            Container(
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
                onPressed: canProceed
                    ? () => _showBaggageTypeModal()
                    : null,
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
        padding: EdgeInsets.all(context.defaultPadding),
        decoration: BoxDecoration(
          color: details != null
              ? primaryColor.withOpacity(0.03)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: details != null
                ? primaryColor.withOpacity(0.2)
                : AppTheme.borderColor,
            width: 1.5,
          ),
          boxShadow: details != null
              ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
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
                  padding: EdgeInsets.all(context.smallPadding),
                  decoration: BoxDecoration(
                    color: details != null
                        ? primaryColor.withOpacity(0.1)
                        : Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: details != null
                        ? primaryColor
                        : AppTheme.secondaryText,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.scaledFontSize(18),
                    fontWeight: FontWeight.bold,
                    color: details != null
                        ? primaryColor
                        : AppTheme.secondaryText,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.edit_outlined,
                  color: details != null
                      ? primaryColor
                      : AppTheme.secondaryText,
                  size: context.scaledFontSize(16),
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
                  fontSize: context.scaledFontSize(14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}