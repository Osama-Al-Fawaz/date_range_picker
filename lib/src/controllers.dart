import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_date_range_picker/src/models.dart';

/// A controller that handles the logic of the date range picker.
class RangePickerController {
  RangePickerController(
      {DateRange? dateRange,
      required this.onDateRangeChanged,
      this.minDate,
      this.maxDate,
      this.startDate,
      this.endDate,
      this.minimumDateRangeLength,
      this.maximumDateRangeLength,
      this.disabledDates = const [],
      this.allowSingleTapDaySelection = false}) {
    if (dateRange != null) {
      startDate = dateRange.start;
      endDate = dateRange.end;
    }
  }

  int? maximumDateRangeLength;
  int? minimumDateRangeLength;

  List<DateTime> disabledDates;

  final bool allowSingleTapDaySelection;

  final ValueChanged<DateRange?> onDateRangeChanged;

  /// The minimum date that can be selected. (inclusive)
  DateTime? minDate;

  /// The maximum date that can be selected. (inclusive)
  DateTime? maxDate;

  /// The start date of the selected range.
  DateTime? startDate;

  /// The end date of the selected range.
  DateTime? endDate;

  DateRange? get dateRange {
    if (startDate == null || endDate == null) {
      return null;
    }

    return DateRange(startDate!, endDate!);
  }

  /// Called when the user selects a date in the calendar.
  /// If the [startDate] is null, it will be set to the [date] parameter.
  /// If the [startDate] is not null and the [endDate] is null, it will be set to the [date]
  /// parameter except if the [date] is before the [startDate]. In this case, the [startDate]
  /// will be set to the [date] parameter and the [endDate] will be set to null.
  /// If the [startDate] is not null and the [endDate] is not null, the [startDate] will be set
  /// to the [date] parameter and the [endDate] will be set to null.
  /// If the [allowSingleTapDaySelection] is true, the [endDate] will be set to the [startDate]
  /// when the [date] is equal to the [startDate].
  void onDateChanged(DateTime date) {
    if (maximumDateRangeLength != null && maximumDateRangeLength! < 2) {
      startDate = date;
      endDate = date;
      onDateRangeChanged(DateRange(startDate!, endDate!));
      return;
    }
    if (startDate == null) {
      startDate = date;
      onDateRangeChanged(DateRange(startDate!, startDate!));
    } else if (endDate == null) {
      if (date == startDate) {
        endDate = date;
        onDateRangeChanged(DateRange(startDate!, endDate!));
      } else {
        if (date.isBefore(startDate!)) {
          endDate = startDate;
          startDate = date;
        } else {
          endDate = date;
        }
        onDateRangeChanged(DateRange(startDate!, endDate!));
      }
    } else {
      startDate = date;
      endDate = null;
      if (allowSingleTapDaySelection) {
        onDateRangeChanged(DateRange(startDate!, startDate!));
      }
    }
  }

  /// Returns whether the [date] is in the selected range or not.
  bool dateInSelectedRange(DateTime date) {
    if (startDate == null || endDate == null) {
      return false;
    }
    return dateIsStartOrEnd(date) || (date.isAfter(startDate!) && date.isBefore(endDate!));
  }

  bool areSameDay(DateTime one, DateTime two) {
    return one.year == two.year && one.month == two.month && one.day == two.day;
  }

  /// Returns whether the [date] is selectable or not. (i.e. if it is between the [minDate] and the [maxDate])
  bool dateIsSelectable(DateTime date) {
    for (final DateTime disabledDay in disabledDates) {
      if (areSameDay(disabledDay, date)) {
        return false;
      }
    }

    DateTime localizedDate = date.toUtc();
    localizedDate = localizedDate.add(date.timeZoneOffset);

    DateTime? tmpStartDate;
    DateTime? tmpEndDate;

    if (startDate != null) {
      tmpStartDate = startDate!.toUtc();
      tmpStartDate = tmpStartDate.add(startDate!.timeZoneOffset);
    }
    if (endDate != null) {
      tmpEndDate = endDate!.toUtc();
      tmpEndDate = tmpEndDate.add(endDate!.timeZoneOffset);
    }

    if (tmpStartDate != null && tmpEndDate == null) {
      var dateDifference = localizedDate.difference(tmpStartDate).inDays;
      if (maximumDateRangeLength != null && dateDifference + 1 > maximumDateRangeLength!) {
        return false;
      }

      if (minimumDateRangeLength != null && dateDifference > 0 && dateDifference + 1 < minimumDateRangeLength!) {
        return false;
      }
    }

    if (minDate != null && localizedDate.isBefore(minDate!)) {
      return false;
    }

    if (maxDate != null && localizedDate.isAfter(maxDate!)) {
      return false;
    }

    return true;
  }

  /// Returns whether the [date] is the start of the selected range or not.
  bool dateIsStart(DateTime date) {
    if (startDate == null) {
      return false;
    }

    return areSameDay(date, startDate!);
  }

  /// Returns whether the [date] is the end of the selected range or not.
  bool dateIsEnd(DateTime date) {
    if (endDate == null) {
      return false;
    }

    return areSameDay(date, endDate!);
  }

  /// Returns whether the [date] is the start or the end of the selected range or not.
  /// This is useful to display the correct border radius on the day tile.
  bool dateIsStartOrEnd(DateTime date) {
    return dateIsStart(date) || dateIsEnd(date);
  }

  List<DayModel> retrieveDatesForMonth(
    DateTime month, {
    bool fillBefore = false,
    bool fillAfter = false,
  }) {
    final List<DayModel> dayModels = [];

    final int delta = retrieveDeltaForMonth(month);

    // Fill previous month days.
    if (fillBefore) {
      for (int i = delta; i > 0; i--) {
        final date = DateTime(month.year, month.month, 1 - i);
        dayModels.add(_buildDayModel(date));
      }
    }

    // Current month days.
    final int daysInMonth = DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;

    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(month.year, month.month, i);
      dayModels.add(_buildDayModel(date));
    }

    if (fillAfter) {
      final occupiedCells = dayModels.length + (fillBefore ? 0 : delta);

      final totalCells = ((occupiedCells / 7).ceil()) * 7;
      final trailingCells = totalCells - occupiedCells;

      for (int i = 1; i <= trailingCells; i++) {
        dayModels.add(
          _buildDayModel(
            DateTime(month.year, month.month + 1, i),
          ),
        );
      }
    }

    return dayModels;
  }

  DayModel _buildDayModel(DateTime date) {
    return DayModel(
      date: date,
      isSelected: dateIsStartOrEnd(date),
      isStart: dateIsStart(date),
      isEnd: dateIsEnd(date),
      isSelectable: dateIsSelectable(date),
      isToday: areSameDay(date, DateTime.now()),
      isInRange: dateInSelectedRange(date),
    );
  }

  /// Returns the number of days to skip at the beginning of the month.
  int retrieveDeltaForMonth(final DateTime month) {
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    return firstDayOfMonth.weekday % 7;
  }

  void onDateRangeChangedExternally(DateRange? newRange) {
    startDate = newRange?.start;
    endDate = newRange?.end;
    onDateRangeChanged(newRange);
  }
}

/// A controller that handles the logic of the calendar widget.
class CalendarWidgetController {
  final _streamController = StreamController<void>();

  Stream<void> get updateStream => _streamController.stream;

  /// The controller that handles the logic of the date range picker.
  final RangePickerController controller;

  CalendarWidgetController({
    required this.controller,
    required DateTime currentMonth,
  }) : _currentMonth = currentMonth;

  /// The current month that is displayed.
  DateTime _currentMonth;

  /// The current month that is displayed.
  DateTime get currentMonth => _currentMonth;

  /// The current month that is displayed.
  set currentMonth(DateTime value) {
    _currentMonth = value;
    _streamController.add(null);
  }

  /// The next month that can be displayed (two months can be displayed at the same time).
  DateTime get nextMonth => DateTime(currentMonth.year, currentMonth.month + 1, 1);

  /// Goes to the next month.
  void next() {
    currentMonth = nextMonth;
  }

  void onDateChanged(DateTime date) {
    controller.onDateChanged(date);
    _streamController.add(null);
  }

  /// Goes to the previous month.
  void previous() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
  }

  /// Returns the dates for the current month.
  List<DayModel> retrieveDatesForMonth({bool fillBefore = false, bool fillAfter = false}) {
    return controller.retrieveDatesForMonth(currentMonth, fillBefore: fillBefore, fillAfter: fillAfter);
  }

  /// Returns the dates for the next month.
  List<DayModel> retrieveDatesForNextMonth({bool fillBefore = false, bool fillAfter = false}) {
    return controller.retrieveDatesForMonth(nextMonth, fillBefore: fillBefore, fillAfter: fillAfter);
  }

  /// Returns the number of days to skip at the beginning of the current month.
  int retrieveDeltaForMonth(int firstDayOfWeek) {
    return controller.retrieveDeltaForMonth(currentMonth) - firstDayOfWeek;
  }

  /// Returns the number of days to skip at the beginning of the next month.
  int retrieveDeltaForNextMonth(int firstDayOfWeek) {
    return controller.retrieveDeltaForMonth(nextMonth) - firstDayOfWeek;
  }

  void setDateRange(DateRange? dateRange) {
    _streamController.add(null);

    if (dateRange == null) {
      controller.onDateRangeChangedExternally(null);
      return;
    }

    controller.onDateRangeChangedExternally(dateRange);
    currentMonth = dateRange.start;
  }
}
