import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/core/models/stopwatch_state.dart';
import 'package:track_dev/providers/stopwatch_provider.dart';
import 'package:track_dev/ui/timer/section/clock_section.dart';
import 'package:track_dev/ui/timer/section/controls_section.dart';
import 'package:track_dev/ui/timer/section/task_picker_section.dart';
import 'package:track_dev/ui/timer/submit/submit_time_entry_sheet.dart';
import 'package:track_dev/ui/timer/task/task_selector_sheet.dart';
import 'package:track_dev/ui/timer/timer_error.dart';
import 'package:track_dev/utils/value_or_null.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  Future<void> _openTaskSelector(BuildContext context, WidgetRef ref) async {
    final result = await showTaskSelectorSheet(context);
    if (result == null) return;

    await ref.read(stopwatchProvider.notifier).makeNew(
          project: result.project,
          issue: result.issue,
        );
  }

  Future<void> _openSubmitSheet(
    BuildContext context,
    WidgetRef ref,
    StopwatchState timerState,
  ) async {
    await ref.read(stopwatchProvider.notifier).stop();

    if (!context.mounted) return;

    final submitted = await showSubmitTimeEntrySheet(
      context: context,
      stopwatchState: timerState,
    );

    if (submitted == true) {
      await ref.read(stopwatchProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerAsync = ref.watch(stopwatchProvider);
    final timerNotifier = ref.read(stopwatchProvider.notifier);
    final timerState = timerAsync.valueOrNull;

    return _TimerLayout(
      isLoading: timerAsync.isLoading,
      hasError: timerAsync.hasError && !timerAsync.isLoading,
      clockSection: timerState != null
          ? ClockSection(stopwatch: timerState.stopwatch)
          : const Expanded(child: SizedBox()),
      taskPickerSection: TaskPickerSection(
        onTap: () => _openTaskSelector(context, ref),
      ),
      controlsSection: timerState != null
          ? ControlsSection(
              isRunning: timerState.stopwatch.isRunning,
              onStart: () => timerNotifier.start(timerState),
              onPause: timerNotifier.stop,
              onStop: timerNotifier.reset,
              onSubmit: () => _openSubmitSheet(context, ref, timerState),
            )
          : const SizedBox(height: 56),
      onError: TimerError(
        error: timerAsync.error,
        onRetry: () => ref.invalidate(stopwatchProvider),
      ),
    );
  }
}

class _TimerLayout extends StatelessWidget {
  const _TimerLayout({
    required this.isLoading,
    required this.hasError,
    required this.clockSection,
    required this.taskPickerSection,
    required this.controlsSection,
    required this.onError,
  });

  final bool isLoading;
  final bool hasError;
  final Widget clockSection;
  final Widget taskPickerSection;
  final Widget controlsSection;
  final Widget onError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError
              ? Center(child: onError)
              : Column(
                  children: [
                    clockSection,
                    const SizedBox(height: 8),
                    taskPickerSection,
                    const SizedBox(height: 32),
                    controlsSection,
                  ],
                ),
        ),
      ),
    );
  }
}
