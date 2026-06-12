import 'package:flutter/material.dart';
import 'package:track_dev/core/usecase/project_stats.dart';
import 'package:track_dev/ui/projects/widget/project_card.dart';

class ProjectsListSection extends StatelessWidget {
  const ProjectsListSection({
    super.key,
    required this.projectsStats,
  });

  final List<ProjectStats> projectsStats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (projectsStats.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Нет проектов',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projectsStats.length,
      itemBuilder: (context, index) {
        return ProjectCard(stats: projectsStats[index]);
      },
    );
  }
}
