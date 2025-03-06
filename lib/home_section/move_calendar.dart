import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_constants.dart'; // 테마 상수 임포트
import 'move_address.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final DateTime _today = DateTime.now();
  String? _selectedTime;

  // 예약 상태 저장
  Map<String, String> movStatus = {};
  bool isLoading = true;

  // 시간 선택 설정
  int selectedHour = 8;
  int selectedMinute = 0;

  // 시간 및 분 컨트롤러
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;

  @override
  void initState() {
    super.initState();
    fetchMovStatus();
    _loadSelectedDateTime();

    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController =
        FixedExtentScrollController(initialItem: selectedMinute == 0 ? 0 : 1);
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  // API 호출해서 상태 데이터 가져오기
  Future<void> fetchMovStatus() async {
    try {
      final url = 'http://moving.stst.co.kr/api/api/Est/dates';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          movStatus = Map.fromEntries(
            data.map((item) {
              String status;
              int movCnt = item['movCnt'];

              if (movCnt >= 0 && movCnt <= 3) {
                status = '여유';
              } else if (movCnt >= 4 && movCnt <= 6) {
                status = '보통';
              } else {
                status = '많음';
              }

              String movDat = DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(item['movDat']));

              return MapEntry(movDat, status);
            }),
          );
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load moving status');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print("Error fetching moving status: $e");
      });
    }
  }

  // 저장된 날짜와 시간을 불러오는 함수
  Future<void> _loadSelectedDateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 저장된 날짜 불러오기
    String? savedDate = prefs.getString('selectedDate');
    if (savedDate != null) {
      setState(() {
        _selectedDay = DateTime.parse(savedDate);
        _focusedDay = _selectedDay!;
      });
    } else {
      _selectedDay = DateTime.now();
    }

    // 저장된 시간 불러오기
    String? savedTime = prefs.getString('selectedTime');
    if (savedTime != null) {
      setState(() {
        _selectedTime = savedTime;
        List<String> timeParts = savedTime.split(':');
        selectedHour = int.parse(timeParts[0]);
        selectedMinute = int.parse(timeParts[1]);
      });
    }
  }

  // 선택한 날짜를 저장하는 함수
  Future<void> _saveSelectedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_selectedDay != null) {
      await prefs.setString(
          'selectedDate', _selectedDay!.toIso8601String());
    }
  }

  // 선택한 시간을 저장하는 함수
  Future<void> _saveSelectedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_selectedTime != null) {
      await prefs.setString('selectedTime', _selectedTime!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '예정일 입력',
          style: TextStyle(fontWeight: FontWeight.bold),
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
      body: isLoading
          ? _buildLoadingState()
          : _buildCalendarBody(),
      bottomNavigationBar: Container(
        color: Colors.white, // 배경색 명확하게 지정
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: _buildBottomButton(),
      ),
    );
  }

  // 로딩 상태 위젯
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            '일정 정보를 불러오는 중입니다...',
            style: TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 캘린더 메인 본문
  Widget _buildCalendarBody() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(), // 스크롤 물리 효과 변경
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택한 날짜 표시
          if (_selectedDay != null)
            _buildSelectedDateHeader(),

          const SizedBox(height: 8),

          // 캘린더 섹션 컨테이너
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '이사 예정일 선택',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildCalendar(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 일정 상태 안내
          _buildInfoContainer(),

          const SizedBox(height: 24),

          // 시간 선택 섹션
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: _buildTimeSelector(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 선택된 날짜 헤더
  Widget _buildSelectedDateHeader() {
    String formattedDate = DateFormat('yyyy년 MM월 dd일 (E)', 'ko_KR').format(_selectedDay!);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF6A92FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
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

  // 캘린더 위젯
  Widget _buildCalendar() {
    return GestureDetector(
      // 제스처 이벤트를 가로채서 달력 영역에서 상하 스크롤 이벤트를 부모로 전달
      onVerticalDragUpdate: (details) {
        // 수직 방향으로 스크롤하면 부모 스크롤 뷰에 전달
        final offset = details.primaryDelta ?? 0;
        if (offset != 0) {
          // 음수면 위로, 양수면 아래로 스크롤
          final ScrollPosition position = Scrollable.of(context).position;
          position.jumpTo(position.pixels - offset);
        }
      },
      child: TableCalendar(
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
          _saveSelectedDate();
        },
        calendarStyle: CalendarStyle(
          // 오늘 날짜 스타일
          todayDecoration: BoxDecoration(
            color: _selectedDay != null && isSameDay(_today, _selectedDay)
                ? AppTheme.primaryColor
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          // 선택된 날짜 스타일
          selectedDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          // 오늘 날짜 텍스트 스타일
          todayTextStyle: TextStyle(
            color: _selectedDay != null && isSameDay(_today, _selectedDay)
                ? Colors.white
                : AppTheme.primaryColor,
          ),
          // 선택된 날짜 텍스트 스타일
          selectedTextStyle: const TextStyle(
            color: Colors.white,
          ),
          // 기본 날짜 텍스트 스타일
          defaultTextStyle: TextStyle(
            color: AppTheme.primaryText,
          ),
          // 비활성화된 날짜 스타일
          disabledTextStyle: TextStyle(
            color: AppTheme.subtleText,
          ),
          // 월에 포함되지 않은 날짜 표시 여부
          outsideDaysVisible: false,
          // 주말 스타일
          weekendTextStyle: TextStyle(
            color: Colors.redAccent,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.arrow_back_ios, size: 16, color: AppTheme.primaryColor),
          rightChevronIcon: Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryColor),
          titleTextFormatter: (date, locale) =>
              DateFormat.yMMMM(locale).format(date),
          titleTextStyle: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppTheme.secondaryText,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: Colors.redAccent.shade100,
            fontWeight: FontWeight.w600,
            fontSize: 12,
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
        // 날짜별 상태 표시
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            String formattedDate = DateFormat('yyyy-MM-dd').format(day);
            String? status = movStatus[formattedDate];

            return Container(
              margin: const EdgeInsets.all(4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 14,
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
                          fontSize: 10,
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
      ),
    );
  }

  // 일정 상태 안내 컨테이너
  Widget _buildInfoContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '예약 안내',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),
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
      ),
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
            fontSize: 12,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                fontSize: 13,
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
        Row(
          children: [
            Icon(
              Icons.access_time,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '예약 시간',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final time = await _showTimePicker(context);
            if (time != null) {
              setState(() {
                _selectedTime = time;
              });
              _saveSelectedTime();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      color: AppTheme.secondaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime ?? "시간을 선택해주세요",
                      style: TextStyle(
                        color: _selectedTime != null
                            ? AppTheme.primaryText
                            : AppTheme.secondaryText,
                        fontSize: 14,
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
        if (_selectedTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 4),
            child: Text(
              '선택한 시간: $_selectedTime',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // 하단 버튼
// 하단 버튼
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        onPressed: () {
          // 다음 페이지로 이동
          if (_selectedDay == null) {
            const snackBar = SnackBar(
              content: Text('예정일을 선택해 주세요.'),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else if (_selectedTime == null) {
            const snackBar = SnackBar(
              content: Text('예약 시간을 선택해 주세요.'),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddressInputScreen(), // 여기에 다음 화면 위젯 지정
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
        ),
        child: Text(
          '다음 단계로',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 시간 선택 모달
  Future<String?> _showTimePicker(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final hourController =
            FixedExtentScrollController(initialItem: selectedHour);
            final minuteController = FixedExtentScrollController(
                initialItem: selectedMinute == 0 ? 0 : 1);

            // 스크롤 함수
            void _scrollToSelectedHour(int index) {
              hourController.animateToItem(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }

            void _scrollToSelectedMinute(int index) {
              minuteController.animateToItem(
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
              height: 500,
              child: Column(
                children: [
                  // 모달 헤더
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                              color: AppTheme.primaryColor,
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
                      '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
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
                            color: AppTheme.primaryColor.withOpacity(0.1),
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
                                controller: hourController,
                                onSelectedItemChanged: (index) {
                                  setModalState(() {
                                    selectedHour = index;
                                  });
                                },
                                physics: const FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    final isSelected = index == selectedHour;
                                    return GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          selectedHour = index;
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
                                                ? AppTheme.primaryColor
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
                                controller: minuteController,
                                onSelectedItemChanged: (index) {
                                  setModalState(() {
                                    selectedMinute = index == 0 ? 0 : 30;
                                  });
                                },
                                physics: const FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    final isSelected = (index == 0 && selectedMinute == 0) ||
                                        (index == 1 && selectedMinute == 30);
                                    return GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          selectedMinute = index == 0 ? 0 : 30;
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
                                                ? AppTheme.primaryColor
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SafeArea( // 하단 네비게이션 바를 고려하여 버튼을 띄움
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
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