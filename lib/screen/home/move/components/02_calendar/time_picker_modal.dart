import 'package:flutter/material.dart';
import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class TimePickerModal extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final Color primaryColor;

  const TimePickerModal({
    Key? key,
    required this.initialHour,
    required this.initialMinute,
    required this.primaryColor,
  }) : super(key: key);

  @override
  State<TimePickerModal> createState() => _TimePickerModalState();
}

class _TimePickerModalState extends State<TimePickerModal> {
  late int _selectedHour;
  late int _selectedMinute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialHour;
    _selectedMinute = widget.initialMinute;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute == 0 ? 0 : 1);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _scrollToSelectedHour(int index) {
    _hourController.animateToItem(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToSelectedMinute(int index) {
    _minuteController.animateToItem(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          // 모달 헤더
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: widget.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '예약 시간 선택',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // 현재 선택된 시간 표시
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: widget.primaryColor,
              ),
            ),
          ),

          // 시간 선택 휠
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  height: 54,
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(27),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 시간 선택 휠
                    SizedBox(
                      width: 80,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 54,
                        controller: _hourController,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedHour = index;
                          });
                        },
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final isSelected = index == _selectedHour;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedHour = index;
                                });
                                _scrollToSelectedHour(index);
                              },
                              child: Center(
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: isSelected ? 24 : 20,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? widget.primaryColor
                                        : AppTheme.secondaryText,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: 24,
                        ),
                      ),
                    ),

                    // 콜론
                    Text(
                      ':',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),

                    // 분 선택 휠
                    SizedBox(
                      width: 80,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 54,
                        controller: _minuteController,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedMinute = index == 0 ? 0 : 30;
                          });
                        },
                        physics: const FixedExtentScrollPhysics(),
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final isSelected = (index == 0 && _selectedMinute == 0) ||
                                (index == 1 && _selectedMinute == 30);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedMinute = index == 0 ? 0 : 30;
                                });
                                _scrollToSelectedMinute(index);
                              },
                              child: Center(
                                child: Text(
                                  (index == 0 ? '00' : '30'),
                                  style: TextStyle(
                                    fontSize: isSelected ? 24 : 20,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? widget.primaryColor
                                        : AppTheme.secondaryText,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: 2, // 00분과 30분만 선택 가능
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 확인 버튼
          Padding(
            padding: EdgeInsets.all(context.defaultPadding),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                ),
                child: const Text(
                  '시간 선택 완료',
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
}