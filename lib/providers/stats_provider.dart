import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/core/models/project.dart';
import 'package:track_dev/core/usecase/stats.dart';
import 'package:track_dev/core/repository/time_entries.dart';
import 'package:track_dev/providers/sources_provider.dart';
import 'package:track_dev/providers/projects_provider.dart';
import 'package:track_dev/utils/value_or_null.dart';
import 'package:track_dev/core/repository/preferences.dart';

class StatsState {
  final DateTime start;
  final DateTime end;
  final Project? projectFilter;
  final Stats stats;

  const StatsState({
    required this.start,
    required this.end,
    this.projectFilter,
    required this.stats,
  });
}

class StatsStateNotifier extends AsyncNotifier<StatsState> {
  @override
  Future<StatsState> build() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    final end = now;
    final projectFilter = ref.watch(statsProjectFilterProvider).valueOrNull;
    return _calculate(start, end, projectFilter);
  }

  Future<void> applyRange(DateTime start, DateTime end) {
    final current = state.value;
    return periodStats(start, end, current?.projectFilter);
  }

  Future<void> currentWeekStats(Project? projectFilter) async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    final end = now;

    periodStats(start, end, projectFilter);
  }

  Future<void> moveStatsByWeek(StatsState stats, int direction) async {
    final days = const Duration(days: 7);
    final newStart = stats.start.add(Duration(days: days.inDays * -direction));
    final newEnd = stats.end.add(Duration(days: days.inDays * -direction));

    periodStats(newStart, newEnd, stats.projectFilter);
  }

  Future<void> periodStats(
    DateTime start,
    DateTime end,
    Project? projectFilter,
  ) async {
    // state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _calculate(start, end, projectFilter));
  }

  Future<StatsState> _calculate(
    DateTime start,
    DateTime end,
    Project? projectFilter,
  ) async {
    final userRepo = ref.read(userRepositoryProvider);
    final issuesRepo = ref.read(issuesRepositoryProvider);
    final entriesRepo = ref.read(timeEntriesRepositoryProvider);

    final user = await userRepo.fetchCurrentUser();

    final query = TimeEntriesQuery(
      projectId: projectFilter?.id.toString(),
      spentOnFrom: start,
      spentOnTo: end,
      userId: int.parse(user.id),
    );

    final entries = await entriesRepo.listAll(query);

    final calculatedStats = await calculateStats(user, entries, issuesRepo);

    return StatsState(
      start: start,
      end: end,
      projectFilter: projectFilter,
      stats: calculatedStats,
    );
  }
}

class StatsProjectFilterNotifier extends AsyncNotifier<Project?> {
  @override
  Future<Project?> build() async {
    final prefs = ref.watch(preferencesRepositoryProvider);
    final savedId = await prefs.getStatsSelectedProjectId();
    if (savedId == null) return null;

    final projects = await ref.watch(projectsProvider.future);
    try {
      return projects.firstWhere((p) => p.id == savedId);
    } catch (_) {
      return null;
    }
  }

  Future<void> setProject(Project? project) async {
    state = AsyncValue.data(project);
    final prefs = ref.read(preferencesRepositoryProvider);
    await prefs.setStatsSelectedProjectId(project?.id);
  }
}

class StatsLayoutNotifier extends AsyncNotifier<StatsLayout> {
  @override
  Future<StatsLayout> build() async {
    final prefs = ref.watch(preferencesRepositoryProvider);
    return prefs.getStatsLayout();
  }

  Future<void> setLayout(StatsLayout layout) async {
    state = AsyncValue.data(layout);
    final prefs = ref.read(preferencesRepositoryProvider);
    await prefs.setStatsLayout(layout);
  }
}

final statsStateProvider =
    AsyncNotifierProvider<StatsStateNotifier, StatsState>(
      StatsStateNotifier.new,
    );

final statsProjectFilterProvider =
    AsyncNotifierProvider<StatsProjectFilterNotifier, Project?>(
      StatsProjectFilterNotifier.new,
    );

final statsLayoutProvider =
    AsyncNotifierProvider<StatsLayoutNotifier, StatsLayout>(
      StatsLayoutNotifier.new,
    );
