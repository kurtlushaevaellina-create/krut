import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:track_dev/core/models/issue.dart';
import 'package:track_dev/core/usecase/stats.dart';

class TasksSection extends StatelessWidget {
  final Map<DateTime, DayStats> data;

  const TasksSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton.keep(
          child: Text(
            'Задачи',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 12),

        _TaskList(data: data),
      ],
    );
  }
}

class _TaskList extends StatelessWidget {
  final Map<DateTime, DayStats> data;

  const _TaskList({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Aggregate hours per issue across all days in the dataset
    final Map<int, (Issue, int)> issueHours = {};
    for (final dayStats in data.values) {
      for (final (issue, hours) in dayStats.workHoursPerIssue) {
        final existing = issueHours[issue.id];
        if (existing != null) {
          issueHours[issue.id] = (issue, existing.$2 + hours);
        } else {
          issueHours[issue.id] = (issue, hours);
        }
      }
    }

    // Sort issues by logged hours descending
    final sortedIssues = issueHours.values.toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    return _TaskListLayout(
      issueHours: sortedIssues,
      emptyContent: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Нет задач за этот период',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
      issueRow: (issue, hours) {
        return _ItemCard(issue: issue, hours: hours);
      },
    );
  }
}

class _TaskListLayout extends StatelessWidget {
  final List<(Issue, int)> issueHours;

  final Widget emptyContent;
    final Widget Function(Issue issue, int hours) issueRow;

  const _TaskListLayout({
    required this.issueHours,
    required this.emptyContent,
    required this.issueRow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (issueHours.isEmpty) ...[
          emptyContent,
        ] else ...[
          // TODO: Use LazyList
          Column(
            children: issueHours.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: issueRow(item.$1, item.$2),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Issue issue;
  final int hours;

  const _ItemCard({required this.issue, required this.hours});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '#${issue.id}',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            issue.subject,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$hours ч.',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
