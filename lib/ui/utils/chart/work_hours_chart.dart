import 'package:flutter/material.dart';
import 'package:track_dev/core/usecase/stats.dart';
import 'package:track_dev/ui/utils/chart/week_work_hours_chart.dart';

typedef OnSwipeTimeWindow = void Function(DateTimeRange range);

class WorkHoursChart extends StatelessWidget {
  final Map<DateTime, DayStats> data;
  final DateTimeRange range;
  final OnSwipeTimeWindow? onSwipe;

  const WorkHoursChart({
    super.key,
    required this.data,
    required this.range,
    this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    // Map work hours per day to the (DateTime, int) format the chart expects.
    final chartData = data.entries
        .map((e) => (e.key, e.value.total))
        .toList(growable: false);

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 220,
        child: WeekWorkHoursChart(
          data: chartData,
          range: range,
          onSwipe: onSwipe == null
              ? null
              : (direction) {
                  // Move range by 7 days in the swipe direction
                  final days = const Duration(days: 7);
                  final newStart = range.start.add(Duration(days: days.inDays * -direction));
                  final newEnd = range.end.add(Duration(days: days.inDays * -direction));
                  onSwipe!(DateTimeRange(start: newStart, end: newEnd));
                },
        ),
      ),
    );
  }
}
