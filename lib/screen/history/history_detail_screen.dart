import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:intl/intl.dart';

class EstimateDetailScreen extends ConsumerWidget {
  final String requestId;
  final bool isRegularMove;

  const EstimateDetailScreen({
    Key? key,
    required this.requestId,
    required this.isRegularMove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 견적 요청 정보 가져오기
    final estimateRequestsState = ref.watch(estimateRequestsProvider);
    final request = estimateRequestsState.requests.firstWhere(
          (request) => request.id == requestId,
      orElse: () => EstimateRequest(
        id: requestId,
        status: '정보 없음',
        date: '날짜 정보 없음',
        isRegularMove: isRegularMove,
      ),
    );

    // 이사 데이터 가져오기
    final moveState = isRegularMove
        ? ref.watch(regularMoveProvider)
        : ref.watch(specialMoveProvider);

    final moveData = moveState.moveData;
    final Color themeColor = isRegularMove ? AppTheme.primaryColor : AppTheme.greenColor;

    // 이사 유형 이름 가져오기
    String serviceTypeName = '';
    if (moveData.selectedMoveType != null) {
      if (moveData.selectedMoveType == 'office_move') {
        serviceTypeName = '사무실 이사';
      } else if (moveData.selectedMoveType == 'storage_move') {
        serviceTypeName = '보관 이사';
      } else if (moveData.selectedMoveType == 'simple_transport') {
        serviceTypeName = '단순 운송';
      } else if (moveData.selectedMoveType == 'small_move') {
        if (moveData.selectedServiceType == 'normal') serviceTypeName = '소형 이사(일반)';
        else if (moveData.selectedServiceType == 'semiPackage') serviceTypeName = '소형 이사(반포장)';
        else if (moveData.selectedServiceType == 'package') serviceTypeName = '소형 이사(포장)';
        else serviceTypeName = '소형 이사';
      } else if (moveData.selectedMoveType == 'package_move') {
        if (moveData.selectedServiceType == 'normal') serviceTypeName = '가정 이사(일반)';
        else if (moveData.selectedServiceType == 'semiPackage') serviceTypeName = '가정 이사(반포장)';
        else if (moveData.selectedServiceType == 'package') serviceTypeName = '가정 이사(포장)';
        else serviceTypeName = '가정 이사';
      } else {
        serviceTypeName = '이사 서비스';
      }
    } else {
      serviceTypeName = '이사 서비스';
    }

    // 이사일 형식화
    String moveDateStr = '';
    if (moveData.selectedDate != null) {
      moveDateStr = DateFormat('yyyy년 MM월 dd일').format(moveData.selectedDate!);
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '견적 상세 정보',
          style: TextStyle(
            color: AppTheme.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상태 정보 및 견적번호 카드
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 상태 배지
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: request.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: request.statusColor, width: 1),
                      ),
                      child: Text(
                        request.status,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: request.statusColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // 서비스 유형
                    Text(
                      serviceTypeName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    SizedBox(height: 8),

                    // 견적번호
                    Text(
                      '견적번호: ${request.id}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    SizedBox(height: 4),

                    // 신청일
                    Text(
                      '신청일: ${request.date}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                    ),

                    // 견적 금액 (있는 경우)
                    if (request.price != null) ...[
                      SizedBox(height: 24),
                      Divider(),
                      SizedBox(height: 16),
                      Text(
                        '견적 금액',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        request.price!,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 24),

              // 이사 정보 섹션
              _buildInfoSection(
                context: context,
                title: '이사 정보',
                icon: Icons.local_shipping,
                themeColor: themeColor,
                children: [
                  if (moveDateStr.isNotEmpty) ...[
                    _buildInfoRow(
                      context: context,
                      icon: Icons.event_outlined,
                      label: '이사일',
                      value: moveDateStr,
                    ),
                    if (moveData.selectedTime != null)
                      _buildInfoRow(
                        context: context,
                        icon: Icons.access_time,
                        label: '이사 시간',
                        value: moveData.selectedTime!,
                      ),
                    SizedBox(height: 8),
                  ],

                  _buildInfoRow(
                    context: context,
                    icon: Icons.miscellaneous_services_outlined,
                    label: '서비스 유형',
                    value: serviceTypeName,
                  ),

                  // 보관 이사 정보 (해당하는 경우)
                  if (moveData.selectedMoveType == 'storage_move' && moveData.storageDuration != null) ...[
                    SizedBox(height: 12),
                    Divider(),
                    SizedBox(height: 12),
                    Text(
                      '보관 이사 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.date_range,
                      label: '보관 기간',
                      value: '${moveData.storageDuration}개월',
                    ),
                  ],
                ],
              ),

              SizedBox(height: 16),

              // 주소 정보 섹션
              if (moveData.startAddressDetails != null)
                _buildInfoSection(
                  context: context,
                  title: '주소 정보',
                  icon: Icons.location_on_outlined,
                  themeColor: themeColor,
                  children: [
                    // 출발지 주소
                    _buildAddressRow(
                      context: context,
                      icon: Icons.home_outlined,
                      iconColor: AppTheme.primaryColor,
                      label: '출발지',
                      address: moveData.startAddressDetails!['address'],
                      detailAddress: moveData.startAddressDetails!['detailAddress'],
                      extraInfo: [
                        '${moveData.startAddressDetails!['buildingType']}',
                        '${moveData.startAddressDetails!['roomStructure']}',
                        '${moveData.startAddressDetails!['floor']}층',
                      ],
                    ),

                    // 도착지 주소
                    if (moveData.destinationAddressDetails != null) ...[
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 16),
                      _buildAddressRow(
                        context: context,
                        icon: Icons.location_on_outlined,
                        iconColor: AppTheme.greenColor,
                        label: '도착지',
                        address: moveData.destinationAddressDetails!['address'],
                        detailAddress: moveData.destinationAddressDetails!['detailAddress'],
                        extraInfo: [
                          '${moveData.destinationAddressDetails!['buildingType']}',
                          '${moveData.destinationAddressDetails!['roomStructure']}',
                          '${moveData.destinationAddressDetails!['floor']}층',
                        ],
                      ),
                    ],
                  ],
                ),

              SizedBox(height: 16),

              // 이삿짐 정보 섹션 (간단한 요약만 표시)
              _buildInfoSection(
                context: context,
                title: '이삿짐 정보',
                icon: Icons.inventory_2_outlined,
                themeColor: themeColor,
                children: [
                  _buildInfoRow(
                    context: context,
                    icon: Icons.list_alt_outlined,
                    label: '등록 항목',
                    value: '${moveData.selectedBaggageItems.length}건',
                  ),
                  SizedBox(height: 8),
                  if (moveData.isPhotoSelected)
                    _buildInfoRow(
                      context: context,
                      icon: Icons.photo_camera_outlined,
                      label: '방 사진',
                      value: '${moveData.roomTypes.length}개 방 촬영',
                    ),
                ],
              ),

              SizedBox(height: 24),

              // 취소 버튼 (취소 상태가 아닐 때만 표시)
              if (request.status != '취소')
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      // 취소 확인 다이얼로그 표시
                      _showCancelConfirmDialog(context, ref, request.id);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: Text('견적 요청 취소'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 정보 섹션 위젯
  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color themeColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: themeColor,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.secondaryText,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 주소 정보 행 위젯
  Widget _buildAddressRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
    String? detailAddress,
    List<String>? extraInfo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryText,
                ),
              ),
              if (detailAddress != null && detailAddress.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  detailAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
              if (extraInfo != null && extraInfo.isNotEmpty) ...[
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: extraInfo.map((info) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      info,
                      style: TextStyle(
                        fontSize: 12,
                        color: iconColor,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // 취소 확인 다이얼로그
  void _showCancelConfirmDialog(BuildContext context, WidgetRef ref, String requestId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('견적 요청 취소'),
        content: Text('정말로 견적 요청을 취소하시겠습니까? 취소 후에는 다시 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () {
              // 견적 상태 업데이트
              ref.read(estimateRequestsProvider.notifier).updateRequestStatus(requestId, '취소');

              // 다이얼로그 닫기
              Navigator.pop(context);

              // 목록 화면으로 이동
              Navigator.pop(context);

              // 취소 완료 메시지
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('견적 요청이 취소되었습니다.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('예, 취소합니다'),
          ),
        ],
      ),
    );
  }
}