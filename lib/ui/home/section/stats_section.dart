import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:track_dev/core/repository/preferences.dart';
import 'package:track_dev/core/usecase/stats.dart';

class StatsSection extends StatelessWidget {
  final Stats stats;
  final StatsLayout layout;

  final VoidCallback? onTotalHoursClick;
  final VoidCallback? onCompletedTasksClick;
  final VoidCallback? onPendingTasksClick;
  final VoidCallback? onWorkingDaysClick;

  const StatsSection({
    super.key,
    required this.stats,
    required this.layout,
    this.onTotalHoursClick,
    this.onCompletedTasksClick,
    this.onPendingTasksClick,
    this.onWorkingDaysClick,
  });

  @override
  Widget build(BuildContext context) {
    return _StatsLayout(
      layout: layout,
      totalCard: _StatCard(
        title: 'Общие часы',
        value: '${stats.totalWorkHours}',
        icon: Icons.access_time,
        onTap: onTotalHoursClick,
      ),
      completedCard: _StatCard(
        title: 'Выполнено',
        value: '${stats.completedTasks}',
        icon: Icons.check_circle_outline,
        onTap: onCompletedTasksClick,
      ),
      pendingCard: _StatCard(
        title: 'В ожидании',
        value: '${stats.pendingTasks}',
        icon: Icons.pending_actions,
        onTap: onPendingTasksClick,
      ),
      workingDaysCard: _StatCard(
        title: 'Рабочие дни',
        value: '${stats.workHoursPerDay.length} дн.',
        icon: Icons.bar_chart,
        onTap: onWorkingDaysClick,
      ),
    );
  }
}

class _StatsLayout extends StatelessWidget {
  final StatsLayout layout;

  final Widget totalCard;
  final Widget completedCard;
  final Widget pendingCard;
  final Widget workingDaysCard;

  const _StatsLayout({
    required this.layout,
    required this.totalCard,
    required this.completedCard,
    required this.pendingCard,
    required this.workingDaysCard,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [totalCard, completedCard, pendingCard, workingDaysCard];

    return switch (layout) {
      StatsLayout.list => Column(
        children: cards
            .map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: card,
              ),
            )
            .toList(),
      ),
      StatsLayout.grid => Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      ),
    };
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cardContent = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton.keep(
            child: Icon(icon, size: 28, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Skeleton.keep(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return cardContent;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: cardContent,
    );
  }
}
