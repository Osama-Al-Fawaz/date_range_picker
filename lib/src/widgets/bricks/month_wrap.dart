import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/src/models.dart';

/// A widget that displays a wrap of a month's worth of day tiles.
class MonthWrapWidget extends StatelessWidget {
  /// Constructs a [MonthWrapWidget] widget.
  const MonthWrapWidget({
    Key? key,
    required this.days,
    required this.delta,
    required this.dayTileBuilder,
    required this.placeholderBuilder,
    this.fillBefore = false,
  }) : super(key: key);

  /// The list of [DayModel]s to display.
  final List<DayModel> days;

  /// The offset of the first day to display.
  final int delta;

  /// A builder that builds a day tile given a [DayModel].
  final Widget Function(DayModel dayModel) dayTileBuilder;

  /// A builder that builds a placeholder widget given a delta index.
  final Widget Function(int deltaIndex) placeholderBuilder;
  final bool fillBefore;

  @override
  Widget build(BuildContext context) {
    const int column = 7;

    final int leadingCells = fillBefore ? 0 : delta;
    final int totalCells = leadingCells + days.length;

    final int row = (totalCells / column).ceil();

    return Column(
      children: List.generate(row, (rowIndex) {
        return Row(
          children: List.generate(column, (columnIndex) {
            final int gridIndex = rowIndex * column + columnIndex;
            final int dayIndex = gridIndex - leadingCells;

            if (dayIndex < 0 || dayIndex >= days.length) {
              return placeholderBuilder(columnIndex);
            }

            return dayTileBuilder(days[dayIndex]);
          }),
        );
      }),
    );
  }
}
