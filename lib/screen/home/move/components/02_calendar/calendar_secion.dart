import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:MoveSmart/theme/theme_constants.dart';
import 'package:MoveSmart/utils/ui_extensions.dart';

class CalendarSection extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime today;
  final Map<String, String> visibleMonthMovStatus;
  final Map<String, String> allMovStatus;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final Color primaryColor;

  const CalendarSection({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.today,
    required this.visibleMonthMovStatus,
    required this.allMovStatus,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      locale: 'ko_KR',
      focusedDay: focusedDay,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime(today.year + 1, today.month, today.day),
      availableGestures: AvailableGestures.horizontalSwipe,
      selectedDayPredicate: (day) {
        return isSameDay(selectedDay, day);
      },
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      calendarStyle: _buildCalendarStyle(),
      headerStyle: _buildHeaderStyle(context),
      daysOfWeekStyle: _buildDaysOfWeekStyle(context),
      enabledDayPredicate: (day) {
        return !day.isBefore(DateTime(today.year, today.month, today.day));
      },
      calendarBuilders: _buildCalendarBuilders(context),
    );
  }

  CalendarStyle _buildCalendarStyle() {
    return CalendarStyle(
      todayDecoration: BoxDecoration(
        color: selectedDay != null && isSameDay(today, selectedDay)
            ? primaryColor
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      selectedDecoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
      ),
      todayTextStyle: TextStyle(
        color: selectedDay != null && isSameDay(today, selectedDay)
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
    );
  }

  HeaderStyle _buildHeaderStyle(BuildContext context) {
    return HeaderStyle(
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
    );
  }

  DaysOfWeekStyle _buildDaysOfWeekStyle(BuildContext context) {
    return DaysOfWeekStyle(
      weekdayStyle: TextStyle(
        color: AppTheme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: context.scaledFontSize(10),
      ),
      weekendStyle: TextStyle(
        color: Colors.redAccent.shade100,
        fontWeight: FontWeight.w600,
        fontSize: context.scaledFontSize(10),
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
    );
  }

  CalendarBuilders _buildCalendarBuilders(BuildContext context) {
    return CalendarBuilders(
      defaultBuilder: (context, day, focusedDay) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(day);
        String? status = visibleMonthMovStatus[formattedDate] ?? allMovStatus[formattedDate];

        return Container(

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
    );
  }
}