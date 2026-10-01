import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

/// The default [CalendarTheme] used by the date range picker.
const CalendarTheme kTheme = CalendarTheme(
  selectedColor: Color(0xff009490),
  dayNameTextStyle: TextStyle(color: Color(0xff616366), fontSize: 10, fontWeight: FontWeight.w400, height: 1.5),
  inRangeColor: Color(0xFFE2F0F1),
  inRangeTextStyle: TextStyle(color: Color(0xff1E1E1F), fontSize: 10, fontWeight: FontWeight.w400, height: 1.5),
  selectedTextStyle: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w400, height: 1.5),
  todayTextStyle: TextStyle(color: Color(0xff1E1E1F), fontSize: 10, fontWeight: FontWeight.w400, height: 1.5),
  defaultTextStyle: TextStyle(color: Color(0xff1E1E1F), fontSize: 10, fontWeight: FontWeight.w400, height: 1.5),
  radius: 25,
  tileSize: 20,
  disabledTextStyle: TextStyle(color: Color(0xffD2D4D9), fontSize: 10, fontWeight: FontWeight.w400, height: 1.5),
  monthTextStyle: TextStyle(color: Color(0xff1E1E1F), fontSize: 9, fontWeight: FontWeight.w600, height: 1.5),
  quickDateRangeTextStyle: TextStyle(color: Color(0xff3F3F40), fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
  quickDateRangeBackgroundColor: Colors.transparent,
  selectedQuickDateRangeColor: Color(0xffE7E8EC),
  separatorColor: Color(0xffF2F3F5),
);

/// A function that builds a day tile for the date range picker.
///
/// * [dayModel] - The model for the day tile to be built.
/// * [theme] - The theme to apply to the day tile.
/// * [onTap] - A callback function to be called when the day tile is tapped.
Widget kDayTileBuilder(
  DayModel dayModel,
  CalendarTheme theme,
  ValueChanged<DateTime> onTap,
) {
  TextStyle combinedTextStyle = theme.defaultTextStyle;

  if (dayModel.isToday) {
    combinedTextStyle = combinedTextStyle.merge(theme.todayTextStyle);
  }

  if (dayModel.isInRange) {
    combinedTextStyle = combinedTextStyle.merge(theme.inRangeTextStyle);
  }

  if (dayModel.isSelected) {
    combinedTextStyle = combinedTextStyle.merge(
        theme.selectedTextStyle.copyWith(color: dayModel.isEnd && !dayModel.isStart ? theme.selectedColor : null));
  }

  if (!dayModel.isSelectable) {
    combinedTextStyle = combinedTextStyle.merge(theme.disabledTextStyle);
  }

  return DayTileWidget(
    size: theme.tileSize,
    textStyle: combinedTextStyle,
    backgroundColor: dayModel.isInRange ? theme.inRangeColor : null,
    color: dayModel.isSelected && dayModel.isStart ? theme.selectedColor : null,
    text: dayModel.date.day.toString(),
    value: dayModel.date,
    onTap: dayModel.isSelectable ? onTap : null,
    radius: BorderRadius.circular(theme.radius),
    borderColor: dayModel.isEnd ? theme.selectedColor : null,
    backgroundRadius: BorderRadius.horizontal(
      left: Radius.circular(dayModel.isStart ? theme.radius : 0),
      right: Radius.circular(dayModel.isEnd ? theme.radius : 0),
    ),
  );
}

/// A widget that displays the names of the days of the week for the date range picker.
class DayNamesRow extends StatelessWidget {
  /// Creates a [DayNamesRow].
  ///
  /// * [key] - The [Key] for this widget.
  /// * [textStyle] - The style to apply to the day names text.
  /// * [lengthOfDateName] - The length of the date name to display. Defaults to 3 (e.g., "Mon").
  /// * [firstDayOfWeek] - The first day of the week, where 0 is Sunday and 6 is Saturday. Defaults to 0.
  /// * [weekDays] - The names of the days of the week to display. If null, defaults to the default week days.
  const DayNamesRow({
    Key? key,
    required this.textStyle,
    this.weekDays,
    this.lengthOfDateName = 2,
    this.firstDayOfWeek = 0,
  }) : super(key: key);

  final TextStyle textStyle;
  final List<String>? weekDays;
  final int lengthOfDateName;
  final int firstDayOfWeek;

  @override
  Widget build(BuildContext context) {
    var finalWeekDays = (weekDays ??
            defaultWeekDays(lengthOfDateNames: lengthOfDateName, locale: Localizations.localeOf(context).languageCode))
        .shiftBy(firstDayOfWeek);

    return Row(
      children: [
        for (var day in finalWeekDays)
          Expanded(
            child: Center(
              child: Text(
                day,
                style: textStyle,
              ),
            ),
          ),
      ],
    );
  }
}

/// A widget that displays a date range picker.
///
/// The onDateRangeChanged callback is called whenever the selected date range
/// is changed.
///
/// The initialDisplayedDate is the date that is initially displayed when the
/// picker is opened. If no initial date is provided, the current date is used.
///
/// The minimumDateRangeLength and maximumDateRangeLength properties can be used
/// to limit the length of the selected date range.
///
/// The doubleMonth property can be set to true to display two months at a time.
///
/// The disabledDates property can be used to disable specific dates.
///
/// The quickDateRanges property can be used to display a list of quick selection
/// dateRanges at the top of the picker.
///
/// The height property can be used to set the height of the picker.
///
/// The theme property can be used to customize the appearance of the picker.
class DateRangePickerWidget extends StatefulWidget {
  const DateRangePickerWidget({
    Key? key,
    required this.onDateRangeChanged,
    this.initialDisplayedDate,
    this.minimumDateRangeLength,
    this.initialDateRange,
    this.minDate,
    this.maxDate,
    this.theme = kTheme,
    this.maximumDateRangeLength,
    this.disabledDates = const [],
    this.quickDateRanges = const [],
    this.doubleMonth = true,
    this.height = 330,
    this.displayMonthsSeparator = true,
    this.separatorThickness = 1,
    this.allowSingleTapDaySelection = false,
    this.firstDayOfWeek = 0,
    this.lengthOfDateName = 2,
  })  : assert(
          firstDayOfWeek >= 0 && firstDayOfWeek <= 6,
          'firstDayOfWeek must be in the range [0..6].',
        ),
        super(key: key);

  /// Called whenever the selected date range is changed.
  final ValueChanged<DateRange?> onDateRangeChanged;

  /// A list of quick selection dateRanges displayed at the top of the picker.
  final List<QuickDateRange> quickDateRanges;

  /// The initial selected date range.
  final DateRange? initialDateRange;

  /// The maximum length of the selected date range.
  final int? maximumDateRangeLength;

  /// The minimum length of the selected date range.
  final int? minimumDateRangeLength;

  /// Set to true to display two months at a time.
  final bool doubleMonth;

  /// The earliest selectable date.
  final DateTime? minDate;

  /// The latest selectable date.
  final DateTime? maxDate;

  /// The date that is initially displayed when the picker is opened.
  final DateTime? initialDisplayedDate;

  /// The height of the picker.
  final double height;

  /// A list of dates that are disabled and cannot be selected.
  final List<DateTime> disabledDates;

  /// Set [allowSingleTapDaySelection] to true to allow single day selection
  /// with just one click (to avoid the user being required to tap on the same
  /// day twice).
  final bool allowSingleTapDaySelection;

  /// The theme used to customize the appearance of the picker.
  final CalendarTheme theme;

  /// Used to either display or hide the vertical separator between months if [doubleMonth] mode is active
  final bool displayMonthsSeparator;

  /// Thickness of the vertical separator between months if [doubleMonth] mode is active
  final double separatorThickness;

  /// The length of the date name in the day names row.
  final int lengthOfDateName;

  /// The first day of the week, where 0 is Sunday and 6 is Saturday.
  final int firstDayOfWeek;

  @override
  State<DateRangePickerWidget> createState() => DateRangePickerWidgetState();
}

class DateRangePickerWidgetState extends State<DateRangePickerWidget> {
  late final controller = RangePickerController(
    dateRange: widget.initialDateRange,
    minDate: widget.minDate,
    maxDate: widget.maxDate,
    onDateRangeChanged: widget.onDateRangeChanged,
    disabledDates: widget.disabledDates,
    minimumDateRangeLength: widget.minimumDateRangeLength,
    maximumDateRangeLength: widget.maximumDateRangeLength,
    allowSingleTapDaySelection: widget.allowSingleTapDaySelection,
  );

  late final calendarController = CalendarWidgetController(
    controller: controller,
    currentMonth: widget.initialDisplayedDate ?? widget.initialDateRange?.start ?? DateTime.now(),
  );

  late final StreamSubscription subscription;

  @override
  void initState() {
    super.initState();

    subscription = calendarController.updateStream.listen((event) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.quickDateRanges.isNotEmpty)
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.theme.quickDateRangeBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.theme.radius),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: QuickSelectorWidget(
                  selectedDateRange: controller.dateRange,
                  quickDateRanges: widget.quickDateRanges,
                  onDateRangeChanged: (dateRange) {
                    calendarController.setDateRange(dateRange);
                  },
                  theme: widget.theme,
                ),
              ),
            ),
          if (widget.quickDateRanges.isNotEmpty) VerticalDivider(color: widget.theme.separatorColor),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: widget.theme.tileSize * 7 * (widget.doubleMonth ? 2 : 1) + (widget.doubleMonth ? 16 : 0),
                    child: MonthSelectorAndDoubleIndicator(
                      theme: widget.theme,
                      doubleMonth: widget.doubleMonth,
                      onPrevious: calendarController.previous,
                      onNext: calendarController.next,
                      onSetYearOrMonth: (DateTime selectedYearOrMonth) => calendarController.currentMonth =
                          DateTime(selectedYearOrMonth.year, selectedYearOrMonth.month),
                      currentMonth: calendarController.currentMonth,
                      nextMonth: calendarController.nextMonth,
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        EnrichedMonthWrapWidget(
                          fillBefore: true,
                          theme: widget.theme,
                          onDateChanged: calendarController.onDateChanged,
                          days: calendarController.retrieveDatesForMonth(
                              fillBefore: true, fillAfter: !widget.doubleMonth),
                          delta: calendarController.retrieveDeltaForMonth(widget.firstDayOfWeek),
                          firstDayOfWeek: widget.firstDayOfWeek,
                          lengthOfDateName: widget.lengthOfDateName,
                        ),
                        if (widget.doubleMonth) const SizedBox(width: 8),
                        if (widget.doubleMonth && widget.displayMonthsSeparator)
                          VerticalDivider(
                            thickness: widget.separatorThickness,
                            color: widget.theme.separatorColor,
                          ),
                        if (widget.doubleMonth) const SizedBox(width: 8),
                        if (widget.doubleMonth)
                          EnrichedMonthWrapWidget(
                            theme: widget.theme,
                            onDateChanged: calendarController.onDateChanged,
                            days: calendarController.retrieveDatesForNextMonth(fillAfter: true),
                            delta: calendarController.retrieveDeltaForNextMonth(widget.firstDayOfWeek),
                            firstDayOfWeek: widget.firstDayOfWeek,
                            lengthOfDateName: widget.lengthOfDateName,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that displays a vertical column of days in a month grid, along with the day names row.
class EnrichedMonthWrapWidget extends StatelessWidget {
  const EnrichedMonthWrapWidget({
    Key? key,
    required this.theme,
    required this.onDateChanged,
    required this.days,
    required this.delta,
    this.firstDayOfWeek = 0,
    this.lengthOfDateName = 2,
    this.fillBefore = false,
  }) : super(key: key);

  /// The theme to use for the calendar.
  final CalendarTheme theme;

  /// A callback that is called when the selected date changes.
  final ValueChanged<DateTime> onDateChanged;

  /// The days to display in the month grid.
  final List<DayModel> days;

  /// The number of days to pad at the beginning of the grid.
  final int delta;

  /// The first day of the week, where 0 is Sunday and 6 is Saturday.
  final int firstDayOfWeek;

  /// The length of the date name in the day names row.
  final int lengthOfDateName;

  final bool fillBefore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: theme.tileSize * 7,
      child: Column(
        children: [
          DayNamesRow(
            textStyle: theme.dayNameTextStyle,
            firstDayOfWeek: firstDayOfWeek,
            lengthOfDateName: lengthOfDateName,
          ),
          MonthWrapWidget(
            fillBefore: fillBefore,
            days: days,
            delta: delta,
            dayTileBuilder: (dayModel) => kDayTileBuilder(
              dayModel,
              theme,
              onDateChanged,
            ),
            placeholderBuilder: (index) => buildPlaceholder(),
          ),
        ],
      ),
    );
  }

  /// A placeholder widget to use for days that do not exist in the current month.
  SizedBox buildPlaceholder() => SizedBox(
        width: theme.tileSize,
        height: theme.tileSize,
      );
}
