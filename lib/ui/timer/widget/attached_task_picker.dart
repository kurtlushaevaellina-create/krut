import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/providers/stopwatch_provider.dart';
import 'package:track_dev/providers/task_display_provider.dart';
import 'package:track_dev/utils/value_or_null.dart';

class AttachedTaskPicker extends ConsumerWidget {
  const AttachedTaskPicker({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final outline = theme.colorScheme.outline;

    final timerAsync = ref.watch(stopwatchProvider);
    final stopwatchState = timerAsync.valueOrNull;

    final taskDisplay = ref.watch(
      taskDisplayProvider((
        projectId: stopwatchState?.attachedProject,
        issueId: stopwatchState?.attachedIssue,
      )),
    );

    final leadingIconColor = switch (taskDisplay.kind) {
      TaskDisplayKind.project => theme.colorScheme.primary,
      TaskDisplayKind.issue => theme.colorScheme.tertiary,
      TaskDisplayKind.none => outline.withValues(alpha: 0.7),
    };

    final textStyle = taskDisplay.hasSelection
        ? TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          )
        : TextStyle(color: outline.withValues(alpha: 0.7));

    final displayText =
        taskDisplay.hasSelection ? taskDisplay.label : 'Поиск задач...';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: outline.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(taskDisplay.icon, color: leadingIconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayText,
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
