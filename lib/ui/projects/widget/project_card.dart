import 'package:flutter/material.dart';
import 'package:track_dev/core/usecase/project_stats.dart';
import 'package:track_dev/ui/projects/widget/project_info_row.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.stats,
  });

  final ProjectStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          stats.project.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Выполнено: ${stats.completed} | В ожидании: ${stats.pending}',
        ),
        children: [
          const Divider(),
          ProjectInfoRow(
            icon: Icons.check_circle_outline,
            title: 'Выполненные задачи',
            value: '${stats.completed}',
          ),
          ProjectInfoRow(
            icon: Icons.pending_actions,
            title: 'Задачи в ожидании',
            value: '${stats.pending}',
          ),
          ProjectInfoRow(
            icon: Icons.access_time,
            title: 'Отработано часов',
            value: '${stats.totalWorkHours}',
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              stats.project.description ?? 'Нет описания',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
