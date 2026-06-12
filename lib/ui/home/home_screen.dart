import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:track_dev/core/repository/preferences.dart';
import 'package:track_dev/core/usecase/stats.dart';
import 'package:track_dev/providers/auth_provider.dart';
import 'package:track_dev/providers/stats_provider.dart';
import 'package:track_dev/providers/user_provider.dart';
import 'package:track_dev/ui/home/refine/refine.dart';
import 'package:track_dev/ui/home/section/chart_section.dart';
import 'package:track_dev/ui/home/section/header_section.dart';
import 'package:track_dev/ui/home/section/stats_section.dart';
import 'package:track_dev/ui/home/section/tasks_section.dart';
import 'package:track_dev/ui/home/stats_error.dart';
import 'package:go_router/go_router.dart';
import 'package:track_dev/providers/navigation_provider.dart';
import 'package:track_dev/utils/value_or_null.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStateProvider);
    final user = userAsync.valueOrNull;
    final userDisplayName = user?.firstname ?? user?.login ?? 'Пользователь';

    final layoutAsync = ref.watch(statsLayoutProvider);
    final statsLayout = layoutAsync.valueOrNull ?? StatsLayout.grid;

    final statsAsync = ref.watch(statsStateProvider);
    final statsState = statsAsync.valueOrNull ?? _placeholderStats;

    return _HomeLayout(
      isLoading: statsAsync.isLoading,
      statsHasError: statsAsync.hasError && !statsAsync.isLoading,
      headerSection: HeaderSection(
        username: userDisplayName,
        projectFilter: statsAsync.valueOrNull?.projectFilter,
        onFilter: () {
          showRefineBottomSheet<void>(context);
        },
        onLogout: () {
          ref.read(authStateProvider.notifier).logOut();
        },
      ),
      statsSection: StatsSection(
        stats: statsState.stats,
        layout: statsLayout,
        onTotalHoursClick: () => context.go(AppRoutes.timer),
        onCompletedTasksClick: () => context.go(AppRoutes.projects),
        onPendingTasksClick: () => context.go(AppRoutes.projects),
        onWorkingDaysClick: () => context.go(AppRoutes.timer),
      ),
      chartSection: ChartSection(
        range: DateTimeRange(start: statsState.start, end: statsState.end),
        stats: statsState.stats,
        onSwipe: (newRange) {
          final notifier = ref.read(statsStateProvider.notifier);
          notifier.applyRange(newRange.start, newRange.end);
        },
      ),
      taskListSection: TasksSection(data: statsState.stats.workHoursPerDay),
      onStatsError: StatsError(
        error: statsAsync.error,
        onRetry: () {
          ref.invalidate(statsStateProvider);
        },
        onLogout: () {
          ref.read(authStateProvider.notifier).logOut();
        },
      ),
    );
  }
}

class _HomeLayout extends StatelessWidget {
  final bool isLoading;
  final bool statsHasError;

  final Widget headerSection;
  final Widget statsSection;
  final Widget chartSection;
  final Widget taskListSection;
  final Widget onStatsError;

  const _HomeLayout({
    required this.isLoading,
    required this.statsHasError,
    required this.headerSection,
    required this.statsSection,
    required this.chartSection,
    required this.taskListSection,
    required this.onStatsError,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Skeletonizer(
          enabled: isLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerSection,
                const SizedBox(height: 20),
                if (statsHasError) ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: onStatsError,
                    ),
                  ),
                ] else ...[
                  statsSection,
                  const SizedBox(height: 24),
                  chartSection,
                  const SizedBox(height: 24),
                  taskListSection,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final _placeholderStats = StatsState(
  start: DateTime(0),
  end: DateTime(0),
  projectFilter: null,
  stats: Stats(
    totalWorkHours: 0,
    completedTasks: 0,
    pendingTasks: 0,
    workHoursPerDay: Map.fromEntries(
      List.generate(7, (i) {
        final date = DateTime.now().subtract(Duration(days: 6 - i));
        final normalizedDate = DateTime(date.year, date.month, date.day);
        return MapEntry(
          normalizedDate,
          const DayStats(total: 0, workHoursPerIssue: []),
        );
      }),
    ),
  ),
);
