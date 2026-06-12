import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/providers/task_display_provider.dart';
import 'package:track_dev/ui/timer/submit/field/picker_field.dart';

class TaskField extends ConsumerWidget {
  const TaskField({
    super.key,
    required this.projectId,
    required this.issueId,
    required this.onTap,
    this.enabled = true,
  });

  final String? projectId;
  final String? issueId;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final taskDisplay = ref.watch(
      taskDisplayProvider((projectId: projectId, issueId: issueId)),
    );

    final iconColor = switch (taskDisplay.kind) {
      TaskDisplayKind.project => theme.colorScheme.primary,
      TaskDisplayKind.issue => theme.colorScheme.tertiary,
      TaskDisplayKind.none => theme.colorScheme.outline,
    };

    return PickerField(
      enabled: enabled,
      onTap: onTap,
      leading: Icon(taskDisplay.icon, color: iconColor),
      title: 'Задача / Проект',
      subtitle: taskDisplay.label,
    );
  }
}
