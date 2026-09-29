import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A widget that displays the current and next month in a row along with navigation arrows.
class MonthSelectorAndDoubleIndicator extends StatelessWidget {
  const MonthSelectorAndDoubleIndicator({
    Key? key,
    required this.currentMonth,
    required this.onNext,
    required this.onPrevious,
    this.nextMonth,
    this.style,
    this.doubleMonth = true,
    this.previousMonthSelector,
    this.nextMonthSelector,
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

  /// The text style of the displayed month.
  final TextStyle? style;

  ///the widget to navigate to previous month. typically an arrow icon
  ///
  ///navigation is already handled by the package
  final Widget? previousMonthSelector;

  ///the widget to navigate to next month. typically an arrow icon
  ///
  ///navigation is already handled by the package
  final Widget? nextMonthSelector;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (doubleMonth)
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onPrevious,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: previousMonthSelector ?? const Icon(Icons.keyboard_arrow_left),
              ),
            ),
          ),
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy').format(currentMonth),
            textAlign: doubleMonth ? TextAlign.center : TextAlign.start,
            style: style,
          ),
        ),
        if (!doubleMonth)
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onPrevious,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: previousMonthSelector ?? const Icon(Icons.keyboard_arrow_left),
              ),
            ),
          ),
        if (doubleMonth) const SizedBox(width: 16),
        if (doubleMonth)
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(nextMonth!),
              textAlign: TextAlign.center,
              style: style,
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
              child: nextMonthSelector ?? const Icon(Icons.keyboard_arrow_right),
            ),
          ),
        ),
      ],
    );
  }
}
