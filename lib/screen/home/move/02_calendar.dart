import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/utils/ui_mixins.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/providers/calendar_provider.dart';

import 'package:MoveSmart/screen/home/move/components/02_calendar/calendar_secion.dart';
import 'package:MoveSmart/screen/home/move/components/02_calendar/selected_date_header.dart';
import 'package:MoveSmart/screen/home/move/components/02_calendar/time_picker_section.dart';
import 'package:MoveSmart/screen/home/move/components/02_calendar/calendar_info_container.dart';
import 'package:MoveSmart/screen/home/move/components/02_calendar/time_picker_modal.dart';

import '03_1_move_address.dart'; // 다음페이지

class CalendarScreen extends ConsumerStatefulWidget {
  final bool isRegularMove;

  const CalendarScreen({Key? key, required this.isRegularMove}) : super(key: key);

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with LoadingStateMixin, MoveFlowMixin, CommonUiMixin {

  @override
  void initState() {
    super.initState();
    isRegularMove = widget.isRegularMove;  // MoveFlowMixin의 isRegularMove 설정

    // 로케일 데이터 초기화
    initializeDateFormatting('ko_KR', null);

    // 초기 데이터 로드
    Future.microtask(() {
      ref.read(calendarProvider.notifier).initializeData();
      _loadSelectedDateTime();
    });
  }

  // Riverpod을 이용한 Provider 가져오기
  MoveNotifier _getMoveProvider() {
    return widget.isRegularMove
        ? ref.read(regularMoveProvider.notifier)
        : ref.read(specialMoveProvider.notifier);
  }

  // 선택된 날짜와 시간 불러오기
  Future<void> _loadSelectedDateTime() async {
    final moveState = widget.isRegularMove
        ? ref.read(regularMoveProvider)
        : ref.read(specialMoveProvider);

    debugPrint('CalendarScreen에서 날짜/시간 불러오기 시작');

    if (moveState.moveData.hasSelectedDate) {
      debugPrint('날짜 데이터: ${moveState.moveData.selectedDate}');

      final notifier = ref.read(calendarProvider.notifier);
      notifier.setSelectedDay(moveState.moveData.selectedDate!);
    }

    if (moveState.moveData.hasSelectedTime) {
      debugPrint('시간 데이터: ${moveState.moveData.selectedTime}');

      final notifier = ref.read(calendarProvider.notifier);
      notifier.setSelectedTime(moveState.moveData.selectedTime!);
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

  // 시간 선택 모달 표시
  Future<void> _showTimePickerModal() async {
    final calendarState = ref.read(calendarProvider);

    // 기본값 설정
    int initialHour = 8;
    int initialMinute = 0;

    // 이미 선택된 시간이 있으면 파싱
    if (calendarState.selectedTime != null) {
      final timeParts = calendarState.selectedTime!.split(':');
      initialHour = int.parse(timeParts[0]);
      initialMinute = int.parse(timeParts[1]);
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TimePickerModal(
        initialHour: initialHour,
        initialMinute: initialMinute,
        primaryColor: primaryColor,
      ),
    );

    if (result != null) {
      ref.read(calendarProvider.notifier).setSelectedTime(result);
      await _saveSelectedTime(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 상태 구독
    final calendarState = ref.watch(calendarProvider);
    final isLoading = calendarState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: buildCommonAppBar(
        title: '예정일 입력',
      ),
      body: isLoading
          ? buildLoadingWidget(message: '일정 정보를 불러오는 중입니다...')
          : _buildCalendarBody(),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // 캘린더 본문
  Widget _buildCalendarBody() {
    final calendarState = ref.watch(calendarProvider);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.all(context.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택한 날짜 표시
          if (calendarState.selectedDay != null)
            SelectedDateHeader(
              selectedDay: calendarState.selectedDay!,
              selectedTime: calendarState.selectedTime,
              backgroundGradient: backgroundGradient,
            ),

          // 캘린더 섹션
          buildInfoCard(
            title: '이사 예정일 선택',
            icon: Icons.calendar_today_outlined,
            iconColor: primaryColor,
            children: [
              _buildCalendarWidget(),
            ],
          ),

          const SizedBox(height: 24),

          // 일정 상태 안내
          CalendarInfoContainer(primaryColor: primaryColor),

          const SizedBox(height: 24),

          // 시간 선택 섹션
          buildInfoCard(
            title: '예약 시간',
            icon: Icons.access_time,
            iconColor: primaryColor,
            children: [
              TimePickerSection(
                selectedTime: calendarState.selectedTime,
                onTap: _showTimePickerModal,
                iconColor: isRegularMove
                    ? AppTheme.secondaryColor
                    : const Color(0xFF26A69A),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 캘린더 위젯
  Widget _buildCalendarWidget() {
    final calendarState = ref.watch(calendarProvider);
    final today = DateTime.now();

    return CalendarSection(
      focusedDay: calendarState.focusedDay,
      selectedDay: calendarState.selectedDay,
      today: today,
      visibleMonthMovStatus: calendarState.visibleMonthMovStatus,
      allMovStatus: calendarState.movStatus,
      primaryColor: primaryColor,
      onDaySelected: (selectedDay, focusedDay) {
        ref.read(calendarProvider.notifier).setSelectedDay(selectedDay);
        _saveSelectedDate(selectedDay);
      },
      onPageChanged: (focusedDay) {
        ref.read(calendarProvider.notifier).onPageChanged(focusedDay);
      },
    );
  }

  // 하단 버튼
  Widget _buildBottomButton() {
    final calendarState = ref.watch(calendarProvider);
    final canProceed = calendarState.selectedDay != null && calendarState.selectedTime != null;

    return Container(
      padding: EdgeInsets.all(context.defaultPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: canProceed
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
}