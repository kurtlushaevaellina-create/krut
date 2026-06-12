import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:track_dev/core/usecase/stats.dart';
import 'package:track_dev/ui/utils/chart/work_hours_chart.dart';

class ChartSection extends StatelessWidget {
  final DateTimeRange range;
  final Stats stats;

  final OnSwipeTimeWindow onSwipe;

  const ChartSection({
    super.key,
    required this.range,
    required this.stats,
    required this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Skeleton.keep(
              child: Text(
                'Рабочие часы',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${_formatDate(range.start)} - ${_formatDate(range.end)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        WorkHoursChart(
          data: stats.workHoursPerDay,
          range: range,
          onSwipe: onSwipe,
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'янв',
    'фев',
    'мар',
    'апр',
    'май',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
