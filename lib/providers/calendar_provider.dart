import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MoveSmart/screen/home/move/api/moving_service.dart';

// 캘린더 상태를 위한 모델 클래스
class CalendarState {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final String? selectedTime;
  final bool isLoading;
  final Map<String, String> movStatus;
  final Map<String, String> visibleMonthMovStatus;

  CalendarState({
    required this.focusedDay,
    this.selectedDay,
    this.selectedTime,
    this.isLoading = false,
    this.movStatus = const {},
    this.visibleMonthMovStatus = const {},
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    String? selectedTime,
    bool? isLoading,
    Map<String, String>? movStatus,
    Map<String, String>? visibleMonthMovStatus,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedTime: selectedTime ?? this.selectedTime,
      isLoading: isLoading ?? this.isLoading,
      movStatus: movStatus ?? this.movStatus,
      visibleMonthMovStatus: visibleMonthMovStatus ?? this.visibleMonthMovStatus,
    );
  }
}

// 캘린더 Repository
class CalendarRepository {
  // 특정 월의 이사 상태 데이터 로드
  Future<Map<String, String>> fetchMovStatusForMonth(DateTime month) async {
    try {
      return await MovingService.fetchMovStatusForMonth(month);
    } catch (e) {
      debugPrint("Repository: 이사 상태 데이터 로드 오류: $e");
      return {};
    }
  }
}

// 캘린더 Repository Provider
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository();
});

// 캘린더 상태 관리를 위한 StateNotifier
class CalendarNotifier extends StateNotifier<CalendarState> {
  final CalendarRepository repository;

  CalendarNotifier(this.repository)
      : super(CalendarState(focusedDay: DateTime.now()));

  // 초기 상태 데이터 로드
  Future<void> initializeData() async {
    state = state.copyWith(isLoading: true);

    try {
      final movStatus = await repository.fetchMovStatusForMonth(state.focusedDay);

      state = state.copyWith(
        isLoading: false,
        movStatus: movStatus,
        visibleMonthMovStatus: Map.from(movStatus),
      );
    } catch (e) {
      debugPrint("CalendarNotifier: 초기 데이터 로드 오류: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  // 날짜 페이지 변경 시 해당 월의 데이터 로드
  Future<void> onPageChanged(DateTime focusedDay) async {
    state = state.copyWith(
      focusedDay: focusedDay,
      visibleMonthMovStatus: {},
    );

    // 해당 월의 데이터가 이미 있는지 확인
    final needsFetch = !_hasDataForMonth(focusedDay);

    if (needsFetch) {
      try {
        final newData = await repository.fetchMovStatusForMonth(focusedDay);

        // 전체 데이터에 추가
        final updatedMovStatus = Map<String, String>.from(state.movStatus)..addAll(newData);

        // 현재 보이는 월에 대한 데이터만 별도로 저장
        state = state.copyWith(
          movStatus: updatedMovStatus,
          visibleMonthMovStatus: Map.from(newData),
        );
      } catch (e) {
        debugPrint("페이지 변경 시 데이터 로드 오류: $e");
      }
    } else {
      // 이미 데이터가 있는 경우, 현재 월에 해당하는 데이터만 필터링
      _updateVisibleMonthData(focusedDay);
    }
  }

  // 선택한 날짜 설정
  void setSelectedDay(DateTime selectedDay) {
    state = state.copyWith(
      selectedDay: selectedDay,
      focusedDay: selectedDay,
    );
  }

  // 선택한 시간 설정
  void setSelectedTime(String selectedTime) {
    state = state.copyWith(selectedTime: selectedTime);
  }

  // 해당 월의 데이터가 이미 있는지 확인
  bool _hasDataForMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    // 해당 월의 첫날과 마지막 날 기준으로 데이터 확인
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      final date = DateTime(month.year, month.month, i);
      final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      if (state.movStatus.containsKey(dateStr)) {
        return true;
      }
    }

    return false;
  }

  // 현재 보이는 월에 대한 데이터만 필터링하여 업데이트
  void _updateVisibleMonthData(DateTime month) {
    final filteredData = <String, String>{};

    for (int i = 1; i <= 31; i++) {
      try {
        final date = DateTime(month.year, month.month, i);
        final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

        if (state.movStatus.containsKey(dateStr)) {
          filteredData[dateStr] = state.movStatus[dateStr]!;
        }
      } catch (e) {
        // 유효하지 않은 날짜인 경우 (예: 2월 31일) 무시
      }
    }

    state = state.copyWith(visibleMonthMovStatus: filteredData);
  }
}

// 캘린더 Provider
final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final repository = ref.read(calendarRepositoryProvider);
  return CalendarNotifier(repository);
});

// 선택된 날짜 Provider
final selectedDayProvider = Provider<DateTime?>((ref) {
  return ref.watch(calendarProvider).selectedDay;
});

// 선택된 시간 Provider
final selectedTimeProvider = Provider<String?>((ref) {
  return ref.watch(calendarProvider).selectedTime;
});

// 이사 상태 데이터 Provider
final movStatusProvider = Provider<Map<String, String>>((ref) {
  return ref.watch(calendarProvider).movStatus;
});

// 현재 보이는 월의 이사 상태 데이터 Provider
final visibleMonthMovStatusProvider = Provider<Map<String, String>>((ref) {
  return ref.watch(calendarProvider).visibleMonthMovStatus;
});

// 로딩 상태 Provider
final calendarLoadingProvider = Provider<bool>((ref) {
  return ref.watch(calendarProvider).isLoading;
});