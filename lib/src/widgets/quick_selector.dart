import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

/// A widget that displays a list of quick dateRanges that can be selected.
class QuickSelectorWidget extends StatelessWidget {
  const QuickSelectorWidget({
    Key? key,
    required this.selectedDateRange,
    required this.quickDateRanges,
    required this.onDateRangeChanged,
    required this.theme,
  }) : super(key: key);

  /// The dateRange that is currently selected. A line will be displayed on the left
  /// using the [CalendarTheme.selectedQuickDateRangeColor] color.
  final DateRange? selectedDateRange;

  /// The list of quick dateRanges to display.
  final List<QuickDateRange> quickDateRanges;

  /// Called when a quick dateRange is selected.
  final ValueChanged<DateRange?> onDateRangeChanged;

  /// The theme of the calendar.
  final CalendarTheme theme;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final quickDateRange in quickDateRanges)
            Row(
              children: [
                Expanded(
                  child: Material(
                    borderRadius: BorderRadius.circular(2),
                    color: quickDateRange.dateRange == selectedDateRange
                        ? theme.selectedQuickDateRangeColor ?? Theme.of(context).primaryColor
                        : Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(2),
                      onTap: () => onDateRangeChanged(quickDateRange.dateRange),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Text(
                          quickDateRange.label,
                          textAlign: TextAlign.left,
                          style: theme.quickDateRangeTextStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
