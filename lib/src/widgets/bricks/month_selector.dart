import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/src/models.dart';
import 'package:intl/intl.dart';

/// A widget that displays the current and next month in a row along with navigation arrows.
class MonthSelectorAndDoubleIndicator extends StatelessWidget {
  const MonthSelectorAndDoubleIndicator({
    Key? key,
    required this.currentMonth,
    required this.onNext,
    required this.onPrevious,
    this.nextMonth,
    this.doubleMonth = true,
    required this.onSetYearOrMonth,
    required this.theme,
  })  : assert(doubleMonth ? nextMonth != null : true),
        super(key: key);

  /// The current month displayed.
  final DateTime currentMonth;

  /// The next month displayed.
  final DateTime? nextMonth;

  /// Whether to display two months or not.
  final bool doubleMonth;

  /// A callback for when the next button is pressed.
  final VoidCallback onNext;

  /// A callback for when the previous button is pressed.
  final VoidCallback onPrevious;

  final void Function(DateTime selectedYearOrMonth) onSetYearOrMonth;

  final CalendarTheme theme;

  @override
  Widget build(BuildContext context) {
    if (doubleMonth) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onPrevious,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: theme.previousMonthSelector ?? const Icon(Icons.keyboard_arrow_left),
              ),
            ),
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(currentMonth),
              textAlign: doubleMonth ? TextAlign.center : TextAlign.start,
              style: theme.monthTextStyle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(nextMonth!),
              textAlign: TextAlign.center,
              style: theme.monthTextStyle,
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onNext,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: theme.nextMonthSelector ?? const Icon(Icons.keyboard_arrow_right),
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                DateMenuWidget(
                  mode: DateMenuMode.month,
                  selectedDate: currentMonth,
                  onChanged: onSetYearOrMonth,
                  menuLabelTextStyle: theme.monthTextStyle,
                  dropDownTrailingIcon: theme.dropDownTrailingIcon,
                  menuItemsTextStyle: theme.menuItemsTextStyle,
                  menuColor: theme.monthAndYearMenuColor,
                ),
                DateMenuWidget(
                  mode: DateMenuMode.year,
                  selectedDate: currentMonth,
                  onChanged: onSetYearOrMonth,
                  menuLabelTextStyle: theme.yearTextStyle ?? theme.monthTextStyle,
                  menuItemsTextStyle: theme.menuItemsTextStyle,
                  dropDownTrailingIcon: theme.dropDownTrailingIcon,
                  menuColor: theme.monthAndYearMenuColor,
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onPrevious,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: theme.previousMonthSelector ?? const Icon(Icons.keyboard_arrow_left),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onNext,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: theme.nextMonthSelector ?? const Icon(Icons.keyboard_arrow_right),
              ),
            ),
          ),
        ],
      );
    }
  }
}

enum DateMenuMode {
  month,
  year,
}

class DateMenuWidget extends StatelessWidget {
  final DateTime selectedDate;
  final DateMenuMode mode;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;
  final TextStyle? menuLabelTextStyle;
  final TextStyle? menuItemsTextStyle;
  final Widget? dropDownTrailingIcon;
  final Color? menuColor;

  const DateMenuWidget({
    super.key,
    required this.selectedDate,
    required this.mode,
    required this.onChanged,
    this.enabled = true,
    this.menuLabelTextStyle,
    this.menuItemsTextStyle,
    this.dropDownTrailingIcon,
    this.menuColor,
  });

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  List<int> get _availableValues {
    switch (mode) {
      case DateMenuMode.month:
        return List.generate(12, (index) => index + 1);

      case DateMenuMode.year:
        final startYear = DateTime.now().year;
        final endYear = DateTime.now().year + 10;

        return List.generate(
          endYear - startYear + 1,
          (index) => startYear + index,
        );
    }
  }

  void _onValuePressed(int value) {
    switch (mode) {
      case DateMenuMode.month:
        onChanged(
          DateTime(
            selectedDate.year,
            value,
            selectedDate.day,
            selectedDate.hour,
            selectedDate.minute,
            selectedDate.second,
            selectedDate.millisecond,
            selectedDate.microsecond,
          ),
        );
        break;

      case DateMenuMode.year:
        onChanged(
          DateTime(
            value,
            selectedDate.month,
            selectedDate.day,
            selectedDate.hour,
            selectedDate.minute,
            selectedDate.second,
            selectedDate.millisecond,
            selectedDate.microsecond,
          ),
        );
        break;
    }
  }

  String _labelForValue(int value) {
    switch (mode) {
      case DateMenuMode.month:
        return _months[value - 1];

      case DateMenuMode.year:
        return value.toString();
    }
  }

  int get _selectedValue {
    switch (mode) {
      case DateMenuMode.month:
        return selectedDate.month;

      case DateMenuMode.year:
        return selectedDate.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue = _selectedValue;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(2),
      child: MenuAnchor(
        style: MenuStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          ),
          backgroundColor: WidgetStatePropertyAll(menuColor),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          maximumSize: const WidgetStatePropertyAll(
            Size.fromHeight(220),
          ),
        ),
        menuChildren: _availableValues
            .map(
              (value) => DateMenuItem(
                label: _labelForValue(value),
                onPressed: () => _onValuePressed(value),
                textStyle: menuItemsTextStyle,
              ),
            )
            .toList(),
        builder: (
          BuildContext context,
          MenuController controller,
          Widget? child,
        ) {
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: enabled ? () => controller.isOpen ? controller.close() : controller.open() : null,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                color: Colors.transparent,
                child: Row(
                  spacing: 4,
                  children: [
                    Text(
                      _labelForValue(selectedValue),
                      style: menuLabelTextStyle,
                    ),
                    AnimatedRotation(
                      turns: controller.isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: dropDownTrailingIcon ??
                          Icon(Icons.keyboard_arrow_down_rounded, color: menuLabelTextStyle?.color),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DateMenuItem extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final TextStyle? textStyle;

  const DateMenuItem({
    super.key,
    required this.onPressed,
    required this.label,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: onPressed,
      style: MenuItemButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        textStyle: textStyle,
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
