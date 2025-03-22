import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart';

class FloorSelectorModal extends StatefulWidget {
  final String initialSelection;
  final Function(String) onConfirm;
  final bool isRegularMove;

  const FloorSelectorModal({
    Key? key,
    required this.initialSelection,
    required this.onConfirm,
    required this.isRegularMove,
  }) : super(key: key);

  @override
  _FloorSelectorModalState createState() => _FloorSelectorModalState();
}

class _FloorSelectorModalState extends State<FloorSelectorModal> {
  late String tempSelectedFloor;
  Color get _primaryColor => widget.isRegularMove ? AppTheme.primaryColor : AppTheme.greenColor;


  @override
  void initState() {
    super.initState();
    tempSelectedFloor = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    // 층 옵션 생성
    List<String> floorOptions = ['반지하'];
    for (int i = 1; i <= 29; i++) {
      floorOptions.add('$i층');
    }
    floorOptions.add('30층 이상');

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
                      color: _primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.layers_outlined,
                      color: _primaryColor,
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
                      setState(() {
                        tempSelectedFloor = option;
                      });
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 60) / 3,
                      padding: EdgeInsets.symmetric(vertical: 12),
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
                widget.onConfirm(tempSelectedFloor);
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

// 층 선택 모달을 표시하는 함수
void showFloorSelector({
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
      return FloorSelectorModal(
        initialSelection: initialSelection,
        onConfirm: onConfirm,
        isRegularMove: isRegularMove,
      );
    },
  );
}