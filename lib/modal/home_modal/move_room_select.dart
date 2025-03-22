import 'package:flutter/material.dart';
import '../../theme/theme_constants.dart';
import '../../utils/ui_mixins.dart';
import '../../utils/ui_extensions.dart';

class RoomSelectionModal extends StatefulWidget {
  final List<String> options;
  final String title;
  final String initialSelection;
  final Function(String) onConfirm;
  final bool isRegularMove;

  const RoomSelectionModal({
    super.key,
    required this.options,
    required this.title,
    required this.initialSelection,
    required this.onConfirm,
    required this.isRegularMove,
  });

  @override
  _RoomSelectionModalState createState() => _RoomSelectionModalState();
}

class _RoomSelectionModalState extends State<RoomSelectionModal> with MoveFlowMixin {
  late String selectedRoom;

  @override
  void initState() {
    super.initState();

    isRegularMove = widget.isRegularMove;

    selectedRoom = widget.initialSelection;
  }

  // 각 방 유형에 맞는 아이콘 반환
  IconData _getRoomTypeIcon(String roomType) {
    switch (roomType) {
      case '거실':
        return Icons.weekend;
      case '주방':
        return Icons.kitchen;
      case '안방':
      case '침실':
        return Icons.king_bed;
      case '화장실':
        return Icons.bathtub;
      case '현관':
        return Icons.door_front_door;
      case '베란다':
        return Icons.balcony;
      case '드레스룸':
        return Icons.checkroom;
      case '창고':
        return Icons.inventory;
      default:
        return Icons.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 드래그 핸들
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // 헤더
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.home_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: context.scaledFontSize(18),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),

          SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.only(left: 45),
            child: Text(
              '추가할 방의 종류를 선택해주세요',
              style: TextStyle(
                fontSize: context.scaledFontSize(13),
                color: AppTheme.secondaryText,
              ),
            ),
          ),

          SizedBox(height: 24),

          // 방 종류 선택 옵션들
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.options.map((roomType) {
                  final bool isSelected = selectedRoom == roomType;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRoom = roomType;
                      });
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 60) / 3,
                      padding: EdgeInsets.all(context.defaultPadding),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? primaryColor : AppTheme.borderColor,
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getRoomTypeIcon(roomType),
                            color: isSelected ? Colors.white : primaryColor,
                            size: 24,
                          ),
                          SizedBox(height: 8),
                          Text(
                            roomType,
                            style: TextStyle(
                              fontSize: context.scaledFontSize(14),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : AppTheme.primaryText,
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          SizedBox(height: 24),

          // 확인 버튼
          SafeArea(child:
            ElevatedButton(
              onPressed: () {
                widget.onConfirm(selectedRoom);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(context.defaultPadding),
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
        ],
      ),
    );
  }
}

// 방 선택 모달을 쉽게 호출하기 위한 함수
Future<void> showRoomSelectionModal({
  required BuildContext context,
  required String title,
  required String initialSelection,
  required Function(String) onConfirm,
  required bool isRegularMove,
  List<String>? options,
}) async {
  // 기본 방 옵션
  final defaultOptions = ['거실', '주방', '안방', '침실', '화장실', '현관', '베란다', '드레스룸', '창고'];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return RoomSelectionModal(
        options: options ?? defaultOptions,
        title: title,
        initialSelection: initialSelection,
        onConfirm: onConfirm,
        isRegularMove: isRegularMove,
      );
    },
  );
}