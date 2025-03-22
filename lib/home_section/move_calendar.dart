import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_constants.dart';
import '../api_service.dart';
import '../providers/move_provider.dart';
import '../utils/ui_extensions.dart';
import '../utils/ui_mixins.dart';
import 'move_address.dart';

final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeProvider = StateProvider<String?>((ref) => null);

class CalendarScreen extends ConsumerStatefulWidget {  // StatefulWidget을 ConsumerStatefulWidget으로 변경
  final bool isRegularMove;

  const CalendarScreen({Key? key, required this.isRegularMove}) : super(key: key);

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();  // 반환 타입 변경
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> with LoadingStateMixin, MoveFlowMixin, CommonUiMixin {  // State를 ConsumerState로 변경
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;
  bool _isFetchingMovStatus = true;
  Map<String, String> _movStatus = {};
  final DateTime _today = DateTime.now();

  // 현재 보이는 월의 상태 데이터
  Map<String, String> _visibleMonthMovStatus = {};

  // 시간 선택 컨트롤러
  int _selectedHour = 8;
  int _selectedMinute = 0;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    isRegularMove = widget.isRegularMove;  // MoveFlowMixin의 isRegularMove 설정

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute == 0 ? 0 : 1);

    // 데이터 로드를 지연 실행
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) {
        _loadSelectedDateTime();
      }
    });

    // API 호출
    _fetchInitialMovStatus();
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  // Riverpod을 이용한 Provider 가져오기
  MoveNotifier _getMoveProvider() {
    return widget.isRegularMove
        ? ref.read(regularMoveProvider.notifier)
        : ref.read(specialMoveProvider.notifier);
  }

  // 선택된 날짜와 시간 불러오기
  Future<void> _loadSelectedDateTime() async {
    // 현재 선택된 이사 유형에 맞는 Provider 상태 가져오기
    final moveState = widget.isRegularMove
        ? ref.read(regularMoveProvider)
        : ref.read(specialMoveProvider);

    print('CalendarScreen에서 날짜/시간 불러오기 시작');
    print('Provider 상태: hasDate=${moveState.moveData.hasSelectedDate}, hasTime=${moveState.moveData.hasSelectedTime}');

    if (moveState.moveData.hasSelectedDate) {
      print('날짜 데이터: ${moveState.moveData.selectedDate}');

      setState(() {
        _selectedDay = moveState.moveData.selectedDate;
        _focusedDay = _selectedDay!;
      });

      print('setState 후 _selectedDay: $_selectedDay, _focusedDay: $_focusedDay');
    } else {
      print('Provider에 날짜 데이터가 없음');
    }

    if (moveState.moveData.hasSelectedTime) {
      print('시간 데이터: ${moveState.moveData.selectedTime}');

      setState(() {
        _selectedTime = moveState.moveData.selectedTime;

        // 시간 파싱하여 컨트롤러 설정
        if (_selectedTime != null) {
          List<String> timeParts = _selectedTime!.split(':');
          _selectedHour = int.parse(timeParts[0]);
          _selectedMinute = int.parse(timeParts[1]);

          // 컨트롤러 위치 조정
          _hourController.dispose();
          _minuteController.dispose();
          _hourController = FixedExtentScrollController(initialItem: _selectedHour);
          _minuteController = FixedExtentScrollController(
              initialItem: _selectedMinute == 0 ? 0 : 1);
        }
      });

      print('setState 후 _selectedTime: $_selectedTime');
    } else {
      print('Provider에 시간 데이터가 없음');
    }
  }

  // 초기 상태 데이터 로드
  Future<void> _fetchInitialMovStatus() async {
    setState(() {
      _isFetchingMovStatus = true;
    });

    try {
      await _fetchMovStatusForMonth(_focusedDay);
    } finally {
      setState(() {
        _isFetchingMovStatus = false;
      });
    }
  }

  // 특정 월에 대한 상태 데이터 로드 (필요한 월만 로드)
  Future<void> _fetchMovStatusForMonth(DateTime month) async {
    try {
      // API 서비스를 통해 데이터 가져오기
      final data = await ApiService.fetchMovStatusForMonth(month);

      // 상태 업데이트 (현재 보이는 월에 대한 데이터만 UI에 반영)
      if (mounted) {
        setState(() {
          // 전체 상태 데이터 업데이트
          _movStatus.addAll(data);

          // 현재 보이는 월에 대한 데이터 업데이트
          if (month.year == _focusedDay.year && month.month == _focusedDay.month) {
            _visibleMonthMovStatus = {...data};
          }
        });
      }
    } catch (e) {
      print("이사 상태 데이터 로드 오류: $e");
    }
  }


  // 선택한 날짜 저장
  Future<void> _saveSelectedDate(DateTime date) async {
    final provider = _getMoveProvider();
    await provider.setSelectedDate(date);
  }

  // 선택한 시간 저장
  Future<void> _saveSelectedTime(String time) async {
    final provider = _getMoveProvider();
    await provider.setSelectedTime(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: buildCommonAppBar(
        title: '예정일 입력',
      ),
      body: _isFetchingMovStatus
          ? buildLoadingWidget(message: '일정 정보를 불러오는 중입니다...')
          : _buildCalendarBody(),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // 캘린더 본문
  Widget _buildCalendarBody() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.all(context.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택한 날짜 표시
          if (_selectedDay != null)
            _buildSelectedDateHeader(),

          // 캘린더 섹션
          buildInfoCard(
            title: '이사 예정일 선택',
            icon: Icons.calendar_today_outlined,
            iconColor: primaryColor,
            children: [
              _buildOptimizedCalendar(),
            ],
          ),

          const SizedBox(height: 24),

          // 일정 상태 안내
          _buildInfoContainer(),

          const SizedBox(height: 24),

          // 시간 선택 섹션
          buildInfoCard(
            title: '예약 시간',
            icon: Icons.access_time,
            iconColor: primaryColor,
            children: [
              _buildTimeSelector(),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 선택된 날짜 헤더
  Widget _buildSelectedDateHeader() {
    print('_buildSelectedDateHeader 호출됨, _selectedDay: $_selectedDay, _selectedTime: $_selectedTime');
    String formattedDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDay!);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '선택한 이사 예정일',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: context.scaledFontSize(13),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.scaledFontSize(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (_selectedTime != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _selectedTime!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 최적화된 캘린더 위젯
  Widget _buildOptimizedCalendar() {
    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime(_today.year + 1, _today.month, _today.day),
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        _saveSelectedDate(selectedDay);
      },
      onPageChanged: (focusedDay) {
        // 월이 변경되면 해당 월의 데이터를 로드
        setState(() {
          _focusedDay = focusedDay;
          _visibleMonthMovStatus = {}; // 현재 보이는 월 데이터 초기화
        });
        _fetchMovStatusForMonth(focusedDay);
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: _selectedDay != null && isSameDay(_today, _selectedDay)
              ? primaryColor
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: _selectedDay != null && isSameDay(_today, _selectedDay)
              ? Colors.white
              : primaryColor,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
        ),
        defaultTextStyle: TextStyle(
          color: AppTheme.primaryText,
        ),
        disabledTextStyle: TextStyle(
          color: AppTheme.subtleText,
        ),
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(
          color: Colors.redAccent,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(Icons.arrow_back_ios, size: 16, color: primaryColor),
        rightChevronIcon: Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor),
        titleTextFormatter: (date, locale) =>
            DateFormat.yMMMM(locale).format(date),
        titleTextStyle: TextStyle(
          fontSize: context.scaledFontSize(18.0),
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryText,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: AppTheme.secondaryText,
          fontWeight: FontWeight.w600,
          fontSize: context.scaledFontSize(12),
        ),
        weekendStyle: TextStyle(
          color: Colors.redAccent.shade100,
          fontWeight: FontWeight.w600,
          fontSize: context.scaledFontSize(12),
        ),
        dowTextFormatter: (date, locale) {
          switch (date.weekday) {
            case 7: return '일';
            case 1: return '월';
            case 2: return '화';
            case 3: return '수';
            case 4: return '목';
            case 5: return '금';
            case 6: return '토';
            default: return '';
          }
        },
      ),
      enabledDayPredicate: (day) {
        return !day.isBefore(DateTime(_today.year, _today.month, _today.day));
      },
      // 날짜별 상태 표시 - 최적화
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(day);
          String? status = _visibleMonthMovStatus[formattedDate] ?? _movStatus[formattedDate];

          return Container(
            margin: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: context.scaledFontSize(14),
                    color: AppTheme.primaryText,
                  ),
                ),
                if (status != null)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: status == '여유'
                          ? Colors.blue.withOpacity(0.1)
                          : status == '보통'
                          ? Colors.black.withOpacity(0.05)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: context.scaledFontSize(10),
                        fontWeight: FontWeight.w500,
                        color: status == '여유'
                            ? Colors.blue
                            : status == '보통'
                            ? Colors.black54
                            : Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 정보 컨테이너
  Widget _buildInfoContainer() {
    return buildInfoCard(
      title: '예약 안내',
      icon: Icons.info_outline,
      iconColor: primaryColor,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        // 상태 범례
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusItem('여유', Colors.blue),
              _buildStatusDivider(),
              _buildStatusItem('보통', Colors.black54),
              _buildStatusDivider(),
              _buildStatusItem('많음', Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 안내 사항들
        _buildInfoRow('표시는 손없는날입니다.', Icons.event_busy_outlined),
        _buildInfoRow('예약일은 90일 이내로만 선택 가능합니다.', Icons.date_range_outlined),
        _buildInfoRow('손없는날, 금요일, 토요일은 가격이 비쌀 수 있어요!', Icons.payment_outlined),
      ],
    );
  }

  // 상태 아이템 위젯
  Widget _buildStatusItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: context.scaledFontSize(12),
          ),
        ),
      ],
    );
  }

  // 상태 구분선
  Widget _buildStatusDivider() {
    return Container(
      width: 1,
      height: 16,
      color: Colors.grey.shade300,
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.secondaryText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: context.scaledFontSize(13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 시간 선택 위젯
  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        GestureDetector(
          onTap: () async {
            final time = await _showTimePicker(context);
            if (time != null) {
              setState(() {
                _selectedTime = time;
              });
              _saveSelectedTime(time);
            }
          },
          child: Container(
            padding: EdgeInsets.all(context.defaultPadding),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: isRegularMove
                          ? AppTheme.secondaryColor
                          : const Color(0xFF26A69A),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime ?? "시간을 선택해주세요",
                      style: TextStyle(
                        color: _selectedTime != null
                            ? AppTheme.primaryText
                            : AppTheme.secondaryText,
                        fontSize: context.scaledFontSize(16),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppTheme.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 하단 버튼
  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,

      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _selectedDay != null && _selectedTime != null
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddressInputScreen(isRegularMove: isRegularMove),
              ),
            );
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
    );
  }

  // 시간 선택 모달
  Future<String?> _showTimePicker(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // 시간 스크롤 함수
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
                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: const BorderRadius.only(
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
                              color: primaryColor,
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
                        color: primaryColor,
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
                            color: primaryColor.withOpacity(0.1),
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
                                  setModalState(() {
                                    _selectedHour = index;
                                  });
                                },
                                physics: const FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    final isSelected = index == _selectedHour;
                                    return GestureDetector(
                                      onTap: () {
                                        setModalState(() {
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
                                                ? primaryColor
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
                                  setModalState(() {
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
                                        setModalState(() {
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
                                                ? primaryColor
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
                          backgroundColor: primaryColor,
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
          },
        );
      },
    );
  }
}