import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/core/models/time_entry_activity.dart';
import 'package:track_dev/core/models/stopwatch_state.dart';
import 'package:track_dev/core/repository/time_entries.dart';
import 'package:track_dev/providers/activities_provider.dart';
import 'package:track_dev/providers/sources_provider.dart';

class SubmitTimeEntryState {
  final String? projectId;
  final String? issueId;
  final DateTime spentOn;
  final int durationHours;
  final int durationMinutes;
  final TimeEntryActivity? selectedActivity;
  final String comment;
  final bool isSubmitting;

  const SubmitTimeEntryState({
    required this.projectId,
    required this.issueId,
    required this.spentOn,
    required this.durationHours,
    required this.durationMinutes,
    this.selectedActivity,
    required this.comment,
    this.isSubmitting = false,
  });

  SubmitTimeEntryState copyWith({
    String? projectId,
    String? issueId,
    DateTime? spentOn,
    int? durationHours,
    int? durationMinutes,
    TimeEntryActivity? selectedActivity,
    String? comment,
    bool? isSubmitting,
  }) {
    return SubmitTimeEntryState(
      projectId: projectId ?? this.projectId,
      issueId: issueId ?? this.issueId,
      spentOn: spentOn ?? this.spentOn,
      durationHours: durationHours ?? this.durationHours,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      selectedActivity: selectedActivity ?? this.selectedActivity,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class SubmitTimeEntryNotifier extends Notifier<SubmitTimeEntryState> {
  @override
  SubmitTimeEntryState build() {
    return SubmitTimeEntryState(
      projectId: null,
      issueId: null,
      spentOn: DateTime.now(),
      durationHours: 0,
      durationMinutes: 0,
      comment: '',
      isSubmitting: false,
    );
  }

  void init(StopwatchState stopwatchState) {
    final elapsed = stopwatchState.stopwatch.elapsed;

    state = SubmitTimeEntryState(
      projectId: stopwatchState.attachedProject,
      issueId: stopwatchState.attachedIssue,
      spentOn: DateTime.now(),
      durationHours: elapsed.inHours,
      durationMinutes: elapsed.inMinutes.remainder(60),
      selectedActivity: _defaultActivity(),
      comment: '',
      isSubmitting: false,
    );
  }

  void ensureDefaultActivity() {
    if (state.selectedActivity != null) return;

    final defaultActivity = _defaultActivity();
    if (defaultActivity != null) {
      state = state.copyWith(selectedActivity: defaultActivity);
    }
  }

  TimeEntryActivity? _defaultActivity() {
    final activitiesAsync = ref.read(activitiesProvider);
    if (activitiesAsync is! AsyncData<List<TimeEntryActivity>>) {
      return null;
    }

    final activities = activitiesAsync.value;
    if (activities.isEmpty) {
      return null;
    }

    return activities.firstWhere(
      (a) => a.isDefault,
      orElse: () => activities.first,
    );
  }

  void setProjectAndIssue(String? projectId, String? issueId) {
    state = state.copyWith(projectId: projectId, issueId: issueId);
  }

  void setSpentOn(DateTime date) {
    state = state.copyWith(spentOn: date);
  }

  void setDuration(int hours, int minutes) {
    state = state.copyWith(durationHours: hours, durationMinutes: minutes);
  }

  void setActivity(TimeEntryActivity? activity) {
    state = state.copyWith(selectedActivity: activity);
  }

  void setComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  Future<void> submit() async {
    if (state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true);
    try {
      final repo = ref.read(timeEntriesRepositoryProvider);

      final double hours = state.durationHours + (state.durationMinutes / 60.0);

      final request = CreateTimeEntryRequest(
        projectId: state.projectId != null ? int.tryParse(state.projectId!) : null,
        issueId: state.issueId != null ? int.tryParse(state.issueId!) : null,
        hours: hours,
        spentOn: state.spentOn,
        activityId: state.selectedActivity?.id,
        comments: state.comment.isEmpty ? null : state.comment,
      );

      await repo.create(request);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final submitTimeEntryProvider =
    NotifierProvider.autoDispose<SubmitTimeEntryNotifier, SubmitTimeEntryState>(
  SubmitTimeEntryNotifier.new,
);
