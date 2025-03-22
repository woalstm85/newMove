import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart';

class RoomSizeSelectorModal extends StatefulWidget {
  final String initialSelection;
  final Function(String) onConfirm;
  final bool isRegularMove;

  const RoomSizeSelectorModal({
    Key? key,
    required this.initialSelection,
    required this.onConfirm,
    required this.isRegularMove,
  }) : super(key: key);

  @override
  _RoomSizeSelectorModalState createState() => _RoomSizeSelectorModalState();
}

class _RoomSizeSelectorModalState extends State<RoomSizeSelectorModal> {
  late String tempSelectedRoomSize;
  Color get _primaryColor => widget.isRegularMove ? AppTheme.primaryColor : AppTheme.greenColor;


  // 평수 옵션 정의
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

  @override
  void initState() {
    super.initState();
    tempSelectedRoomSize = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
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
                      color: _primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.straighten_outlined,
                      color: _primaryColor,
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
              maxHeight: MediaQuery.of(context).size.height * 0.4,
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
                    setState(() {
                      tempSelectedRoomSize = option['value'];
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? _primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _primaryColor : AppTheme.borderColor,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.2),
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
                              color: _primaryColor,
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
          SizedBox(height: 20),

          // 확인 버튼
          SafeArea(
            child: ElevatedButton(
              onPressed: tempSelectedRoomSize != '선택'
                  ? () {
                widget.onConfirm(tempSelectedRoomSize);
                Navigator.pop(context);
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
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
  }
}

// 집 평수 선택 모달을 표시하는 함수
void showRoomSizeSelector({
  required BuildContext context,
  required String initialSelection,
  required Function(String) onConfirm,
  required bool isRegularMove,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return RoomSizeSelectorModal(
        initialSelection: initialSelection,
        onConfirm: onConfirm,
        isRegularMove: isRegularMove,
      );
    },
  );
}