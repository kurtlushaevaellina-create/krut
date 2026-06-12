import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/core/models/stopwatch_state.dart';
import 'package:track_dev/providers/activities_provider.dart';
import 'package:track_dev/providers/submit_time_entry_provider.dart';
import 'package:track_dev/ui/timer/submit/duration_picker_dialog.dart';
import 'package:track_dev/ui/timer/submit/field/activity_field.dart';
import 'package:track_dev/ui/timer/submit/field/comment_field.dart';
import 'package:track_dev/ui/timer/submit/field/date_field.dart';
import 'package:track_dev/ui/timer/submit/field/duration_field.dart';
import 'package:track_dev/ui/timer/submit/field/task_field.dart';
import 'package:track_dev/ui/timer/task/task_selector_sheet.dart';

class SubmitTimeEntrySheet extends HookConsumerWidget {
  const SubmitTimeEntrySheet({
    super.key,
    required this.stopwatchState,
  });

  final StopwatchState stopwatchState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentController = useTextEditingController();
    final commentFocusNode = useFocusNode();

    useEffect(() {
      Future.microtask(() {
        ref.read(submitTimeEntryProvider.notifier).init(stopwatchState);
        commentController.text = ref.read(submitTimeEntryProvider).comment;
      });
      return null;
    }, const []);

    ref.listen(activitiesProvider, (_, _) {
      ref.read(submitTimeEntryProvider.notifier).ensureDefaultActivity();
    });

    final state = ref.watch(submitTimeEntryProvider);
    final notifier = ref.read(submitTimeEntryProvider.notifier);

    Future<void> pickTask() async {
      commentFocusNode.unfocus();
      final result = await showTaskSelectorSheet(context);
      if (result != null && context.mounted) {
        notifier.setProjectAndIssue(result.project, result.issue);
      }
    }

    Future<void> pickDate(DateTime initialDate) async {
      commentFocusNode.unfocus();
      final result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (result != null && context.mounted) {
        notifier.setSpentOn(result);
      }
    }

    Future<void> pickDuration(int hours, int minutes) async {
      commentFocusNode.unfocus();
      final result = await showDurationPickerDialog(
        context: context,
        initialHours: hours,
        initialMinutes: minutes,
      );
      if (result != null && context.mounted) {
        notifier.setDuration(result.hours, result.minutes);
      }
    }

    Future<void> submit() async {
      if (state.projectId == null && state.issueId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите проект или задачу')),
        );
        return;
      }

      try {
        await notifier.submit();
        if (context.mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка отправки: $e')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отправить запись времени'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: state.isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  TaskField(
                    projectId: state.projectId,
                    issueId: state.issueId,
                    enabled: !state.isSubmitting,
                    onTap: pickTask,
                  ),
                  const SizedBox(height: 20),
                  DateField(
                    date: state.spentOn,
                    enabled: !state.isSubmitting,
                    onTap: () => pickDate(state.spentOn),
                  ),
                  const SizedBox(height: 20),
                  DurationField(
                    hours: state.durationHours,
                    minutes: state.durationMinutes,
                    enabled: !state.isSubmitting,
                    onTap: () =>
                        pickDuration(state.durationHours, state.durationMinutes),
                  ),
                  const SizedBox(height: 20),
                  ActivityField(
                    selectedActivity: state.selectedActivity,
                    enabled: !state.isSubmitting,
                    onChanged: notifier.setActivity,
                  ),
                  const SizedBox(height: 24),
                  CommentField(
                    controller: commentController,
                    focusNode: commentFocusNode,
                    commentLength: state.comment.length,
                    enabled: !state.isSubmitting,
                    onChanged: notifier.setComment,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isSubmitting ? null : submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Отправить', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> showSubmitTimeEntrySheet({
  required BuildContext context,
  required StopwatchState stopwatchState,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 1.0,
        child: SubmitTimeEntrySheet(stopwatchState: stopwatchState),
      );
    },
  );
}
