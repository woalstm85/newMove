import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';
import 'package:MoveSmart/utils/ui_mixins.dart';
import 'package:MoveSmart/providers/move_provider.dart';
import 'package:MoveSmart/providers/calendar_provider.dart';
import 'package:MoveSmart/screen/home/move/move_progress_bar.dart';

import 'package:MoveSmart/screen/home/move/components/02_calendar/calendar_secion.dart';
import 'package:MoveSmart/screen/home/move/components/02_calendar/selected_date_header.dart';
import 'package:MoveSmart/screen/home/move/components/02_calendar/time_picker_section.dart';
import 'package:MoveSmart/screen/home/move/components/02_calendar/calendar_info_container.dart';
import 'package:MoveSmart/screen/home/move/components/02_calendar/time_picker_modal.dart';

import 'package:MoveSmart/screen/home/move/03_1_move_address.dart'; // 다음 페이지

// 보관이사 기간 선택을 위한 Provider
final storageDurationProvider = StateProvider<int>((ref) => 1); // 기본값 1개월

class StorageCalendarScreen extends ConsumerStatefulWidget {
  const StorageCalendarScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StorageCalendarScreen> createState() => _StorageCalendarScreenState();
}

class _StorageCalendarScreenState extends ConsumerState<StorageCalendarScreen>
    with LoadingStateMixin, MoveFlowMixin, CommonUiMixin {

  // 현재 선택된 탭 (0: 보관시작, 1: 보관종료)
  int _selectedTab = 0;

  // 보관 기간 옵션
  final List<int> _storageDurationOptions = [1, 2, 3, 6, 12];

  @override
  void initState() {
    super.initState();
    isRegularMove = false; // 특수이사로 설정 (MoveFlowMixin에서 상속)

    // 로케일 데이터 초기화
    initializeDateFormatting('ko_KR', null);

    // 초기 데이터 로드
    Future.microtask(() {
      ref.read(calendarProvider.notifier).initializeData();
      _loadStorageDates();
      _loadStorageDuration();
    });
  }

  // 저장된 보관 날짜 및 시간 불러오기
  Future<void> _loadStorageDates() async {
    final moveState = ref.read(specialMoveProvider);

    // 보관 시작일 불러오기
    if (moveState.moveData.hasStorageStartDate) {
      final notifier = ref.read(calendarProvider.notifier);
      notifier.setSelectedDay(moveState.moveData.storageStartDate!);
    }

    // 첫 탭(보관 시작일) 선택 시 보관 종료일 확인하지 않음
    if (_selectedTab == 0) return;

    // 보관 종료일 불러오기
    if (moveState.moveData.hasStorageEndDate) {
      final notifier = ref.read(calendarProvider.notifier);
      notifier.setSelectedDay(moveState.moveData.storageEndDate!);
    }
  }

  // 보관 기간 불러오기
  Future<void> _loadStorageDuration() async {
    final moveState = ref.read(specialMoveProvider);

    if (moveState.moveData.storageDuration != null) {
      ref
          .read(storageDurationProvider.notifier)
          .state = moveState.moveData.storageDuration!;
    }
  }

  // 보관 시작일 저장
  Future<void> _saveStorageStartDate(DateTime date) async {
    final provider = ref.read(specialMoveProvider.notifier);
    await provider.setStorageStartDate(date);

    // 보관 종료일 계산 및 자동 설정 (기본적으로 보관 기간만큼 더한 날짜)
    int months = ref.read(storageDurationProvider);
    DateTime endDate = DateTime(date.year, date.month + months, date.day);
    await provider.setStorageEndDate(endDate);
  }

  // 보관 종료일 저장
  Future<void> _saveStorageEndDate(DateTime date) async {
    final provider = ref.read(specialMoveProvider.notifier);
    await provider.setStorageEndDate(date);
  }

  // 보관 시작 시간 저장
  Future<void> _saveStorageStartTime(String time) async {
    final provider = ref.read(specialMoveProvider.notifier);
    await provider.setStorageStartTime(time);
  }

  // 보관 종료 시간 저장
  Future<void> _saveStorageEndTime(String time) async {
    final provider = ref.read(specialMoveProvider.notifier);
    await provider.setStorageEndTime(time);
  }

  // 보관 기간 저장
  Future<void> _saveStorageDuration(int months) async {
    final provider = ref.read(specialMoveProvider.notifier);
    await provider.setStorageDuration(months);

    // 시작일이 이미 선택된 경우, 종료일도 자동으로 업데이트
    final moveState = ref.read(specialMoveProvider);
    if (moveState.moveData.hasStorageStartDate) {
      DateTime startDate = moveState.moveData.storageStartDate!;
      DateTime endDate = DateTime(
          startDate.year, startDate.month + months, startDate.day);
      await provider.setStorageEndDate(endDate);

      // 현재 종료일 탭을 선택한 경우 화면 업데이트
      if (_selectedTab == 1) {
        ref.read(calendarProvider.notifier).setSelectedDay(endDate);
      }
    }
  }

  // 시간 선택 모달 표시
  Future<void> _showTimePickerModal() async {
    final calendarState = ref.read(calendarProvider);

    // 현재 선택된 시간을 기본값으로 설정
    String? currentTime;
    if (_selectedTab == 0) {
      final moveState = ref.read(specialMoveProvider);
      currentTime = moveState.moveData.storageStartTime;
    } else {
      final moveState = ref.read(specialMoveProvider);
      currentTime = moveState.moveData.storageEndTime;
    }

    // 기본값 설정
    int initialHour = 8;
    int initialMinute = 0;

    // 이미 선택된 시간이 있으면 파싱
    if (currentTime != null) {
      final timeParts = currentTime.split(':');
      initialHour = int.parse(timeParts[0]);
      initialMinute = int.parse(timeParts[1]);
    } else if (calendarState.selectedTime != null) {
      final timeParts = calendarState.selectedTime!.split(':');
      initialHour = int.parse(timeParts[0]);
      initialMinute = int.parse(timeParts[1]);
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          TimePickerModal(
            initialHour: initialHour,
            initialMinute: initialMinute,
            primaryColor: AppTheme.greenColor, // 특수이사 색상
          ),
    );

    if (result != null) {
      ref.read(calendarProvider.notifier).setSelectedTime(result);
      if (_selectedTab == 0) {
        await _saveStorageStartTime(result);
      } else {
        await _saveStorageEndTime(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 상태 구독
    final calendarState = ref.watch(calendarProvider);
    final isLoading = calendarState.isLoading;
    final storageDuration = ref.watch(storageDurationProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: buildCommonAppBar(
        title: '보관이사 일정',
      ),
      body: Column(
        children: [
          // 진행 상황 표시 바 (앱바 바로 아래)
          MoveProgressBar(
            currentStep: 0, // 첫 번째 단계
            isRegularMove: false, // 특수이사
          ),

          // 탭 바
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTab(0, '보관 시작일'),
                _buildTab(1, '보관 종료일'),
              ],
            ),
          ),

          // 본문 컨텐츠
          Expanded(
            child: isLoading
                ? buildLoadingWidget(message: '일정 정보를 불러오는 중입니다...')
                : _buildCalendarBody(storageDuration),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // 탭 위젯 생성
  Widget _buildTab(int index, String title) {
    bool isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
          _loadStorageDates(); // 탭 변경 시 관련 날짜 로드
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.greenColor.withOpacity(0.1) : Colors
                .white,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.greenColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.greenColor : AppTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // 캘린더 본문
  Widget _buildCalendarBody(int storageDuration) {
    final calendarState = ref.watch(calendarProvider);

    // 현재 선택된 날짜 및 시간 가져오기
    final moveState = ref.read(specialMoveProvider);
    DateTime? selectedDay;
    String? selectedTime;

    if (_selectedTab == 0) {
      // 보관 시작일 탭
      selectedDay = moveState.moveData.storageStartDate;
      selectedTime = moveState.moveData.storageStartTime;
    } else {
      // 보관 종료일 탭
      selectedDay = moveState.moveData.storageEndDate;
      selectedTime = moveState.moveData.storageEndTime;
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.all(context.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택한 날짜 표시
          if (selectedDay != null)
            SelectedDateHeader(
              selectedDay: selectedDay,
              selectedTime: selectedTime,
              backgroundGradient: LinearGradient(
                colors: [
                  AppTheme.greenColor.withOpacity(0.7),
                  AppTheme.greenColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),

          // 보관 기간 선택 섹션 (보관 시작일 탭에서만 표시)
          if (_selectedTab == 0)
            buildInfoCard(
              title: '보관 기간 선택',
              icon: Icons.calendar_month,
              iconColor: AppTheme.greenColor,
              children: [
                _buildStorageDurationSelector(storageDuration),
              ],
            ),

          const SizedBox(height: 16),

          // 캘린더 섹션
          buildInfoCard(
            title: _selectedTab == 0 ? '보관 시작일 선택' : '보관 종료일 선택',
            icon: Icons.calendar_today_outlined,
            iconColor: AppTheme.greenColor,
            children: [
              _buildCalendarWidget(),
            ],
          ),

          const SizedBox(height: 24),

          // 일정 상태 안내
          CalendarInfoContainer(primaryColor: AppTheme.greenColor),

          const SizedBox(height: 24),

          // 시간 선택 섹션
          buildInfoCard(
            title: '예약 시간',
            icon: Icons.access_time,
            iconColor: AppTheme.greenColor,
            children: [
              TimePickerSection(
                selectedTime: selectedTime ?? calendarState.selectedTime,
                onTap: _showTimePickerModal,
                iconColor: AppTheme.greenColor,
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 보관 기간 선택 위젯
  Widget _buildStorageDurationSelector(int currentDuration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '보관 기간을 선택하세요',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.secondaryText,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _storageDurationOptions.map((months) {
            bool isSelected = months == currentDuration;
            return GestureDetector(
              onTap: () {
                ref
                    .read(storageDurationProvider.notifier)
                    .state = months;
                _saveStorageDuration(months);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.greenColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.greenColor : AppTheme
                        .borderColor,
                  ),
                ),
                child: Text(
                  '$months개월',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight
                        .normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          '* 보관 기간은 1개월 단위로 연장 가능합니다.',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.greenColor.withOpacity(0.8),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // 캘린더 위젯
  Widget _buildCalendarWidget() {
    final calendarState = ref.watch(calendarProvider);
    final today = DateTime.now();

    // 현재 선택된 날짜 (탭에 따라 다름)
    final moveState = ref.read(specialMoveProvider);
    DateTime? selectedDay;

    if (_selectedTab == 0) {
      selectedDay = moveState.moveData.storageStartDate;
    } else {
      selectedDay = moveState.moveData.storageEndDate;
    }

    return CalendarSection(
      focusedDay: calendarState.focusedDay,
      selectedDay: selectedDay ?? calendarState.selectedDay,
      today: today,
      visibleMonthMovStatus: calendarState.visibleMonthMovStatus,
      allMovStatus: calendarState.movStatus,
      primaryColor: AppTheme.greenColor,
      onDaySelected: (selectedDay, focusedDay) {
        ref.read(calendarProvider.notifier).setSelectedDay(selectedDay);

        if (_selectedTab == 0) {
          _saveStorageStartDate(selectedDay);
        } else {
          _saveStorageEndDate(selectedDay);
        }
      },
      onPageChanged: (focusedDay) {
        ref.read(calendarProvider.notifier).onPageChanged(focusedDay);
      },
    );
  }

  // 하단 버튼
  Widget _buildBottomButton() {
    final moveState = ref.read(specialMoveProvider);

    // 진행 가능 여부 확인
    final hasStartDate = moveState.moveData.hasStorageStartDate;
    final hasStartTime = moveState.moveData.hasStorageStartTime;
    final hasEndDate = moveState.moveData.hasStorageEndDate;
    final hasEndTime = moveState.moveData.hasStorageEndTime;

    // 모든 필수 정보가 있는지 확인
    final canProceed = hasStartDate && hasStartTime && hasEndDate && hasEndTime;

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
                builder: (context) => AddressInputScreen(isRegularMove: false),
              ),
            );
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.greenColor,
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