import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/providers/issues_provider.dart';
import 'package:track_dev/providers/projects_provider.dart';

typedef TaskIds = ({String? projectId, String? issueId});

enum TaskDisplayKind {
  none,
  project,
  issue,
}

class TaskDisplay {
  const TaskDisplay({
    required this.label,
    required this.icon,
    required this.kind,
  });

  final String label;
  final IconData icon;
  final TaskDisplayKind kind;

  bool get hasSelection => kind != TaskDisplayKind.none;

  static const placeholder = TaskDisplay(
    label: 'Не выбрано',
    icon: Icons.help_outline_rounded,
    kind: TaskDisplayKind.none,
  );
}

final taskDisplayProvider = Provider.autoDispose.family<TaskDisplay, TaskIds>((
  ref,
  ids,
) {
  if (ids.projectId != null) {
    final projectsAsync = ref.watch(projectsProvider);
    final projects = projectsAsync.asData?.value;
    if (projects != null) {
      for (final project in projects) {
        if (project.id.toString() == ids.projectId) {
          return TaskDisplay(
            label: project.name,
            icon: Icons.folder_rounded,
            kind: TaskDisplayKind.project,
          );
        }
      }
    }
  } else if (ids.issueId != null) {
    final issuesAsync = ref.watch(issuesProvider);
    final issues = issuesAsync.asData?.value;
    if (issues != null) {
      for (final issue in issues) {
        if (issue.id.toString() == ids.issueId) {
          return TaskDisplay(
            label: '#${issue.id} ${issue.subject}',
            icon: Icons.task_alt_rounded,
            kind: TaskDisplayKind.issue,
          );
        }
      }
    }
  }

  return TaskDisplay.placeholder;
});
