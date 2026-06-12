import 'package:flutter/material.dart';

/// A callback fired when the user swipes the chart to change the time window.
/// [direction] is -1 for swipe-left (go forward) and 1 for swipe-right (go back).
typedef OnSwipeWeekTimeWindow = void Function(int direction);

/// A bar chart that shows work hours per day and supports horizontal swipe
/// gestures to move the time window.
class WeekWorkHoursChart extends StatelessWidget {
  final List<(DateTime, int)> data;
  final DateTimeRange range;

  final OnSwipeWeekTimeWindow? onSwipe;

  const WeekWorkHoursChart({
    super.key,
    required this.data,
    required this.range,
    this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (onSwipe == null) return;
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 0) {
          onSwipe!(1);
        } else if (velocity < 0) {
          onSwipe!(-1);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: _buildChart(context),
    );
  }

  Widget _buildChart(BuildContext context) {
    // Generate all dates within the specified range
    final startDate = DateTime(range.start.year, range.start.month, range.start.day);
    final endDate = DateTime(range.end.year, range.end.month, range.end.day);
    final daysList = <DateTime>[];
    var current = startDate;
    while (!current.isAfter(endDate)) {
      daysList.add(current);
      current = current.add(const Duration(days: 1));
    }

    // Map existing data to each day in the range, defaulting to 0 hours if no data is found
    final chartItems = daysList.map((day) {
      final match = data.firstWhere(
        (e) => e.$1.year == day.year && e.$1.month == day.month && e.$1.day == day.day,
        orElse: () => (day, 0),
      );
      return match;
    }).toList();

    final maxHours = chartItems.map((e) => e.$2).fold<int>(0, (a, b) => a > b ? a : b);
    final safeMax = maxHours == 0 ? 1 : maxHours;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: chartItems.map((item) {
        final date = item.$1;
        final hours = item.$2;
        final heightFactor = hours / safeMax;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Opacity(
                  opacity: hours > 0 ? 1.0 : 0.0,
                  child: Text(
                    '$hours',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 140 * heightFactor,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _dayLabel(date),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDayMonth(date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _dayLabel(DateTime date) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[date.weekday - 1];
  }

  String _formatDayMonth(DateTime date) {
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
