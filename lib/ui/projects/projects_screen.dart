import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:track_dev/core/models/project.dart';
import 'package:track_dev/core/usecase/project_stats.dart';
import 'package:track_dev/providers/projects_provider.dart';
import 'package:track_dev/ui/projects/projects_error.dart';
import 'package:track_dev/ui/projects/section/projects_list_section.dart';
import 'package:track_dev/utils/value_or_null.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsStatsAsync = ref.watch(projectsStatsProvider);
    final projectsStats =
        projectsStatsAsync.valueOrNull ?? _placeholderProjects;

    return _ProjectsLayout(
      isLoading: projectsStatsAsync.isLoading,
      hasError: projectsStatsAsync.hasError && !projectsStatsAsync.isLoading,
      listSection: ProjectsListSection(projectsStats: projectsStats),
      onError: ProjectsError(
        error: projectsStatsAsync.error,
        onRetry: () => ref.invalidate(projectsStatsProvider),
      ),
    );
  }
}

class _ProjectsLayout extends StatelessWidget {
  const _ProjectsLayout({
    required this.isLoading,
    required this.hasError,
    required this.listSection,
    required this.onError,
  });

  final bool isLoading;
  final bool hasError;
  final Widget listSection;
  final Widget onError;

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
            child: hasError
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: onError,
                    ),
                  )
                : listSection,
          ),
        ),
      ),
    );
  }
}

final _placeholderProjects = [
  ProjectStats(
    project: Project(id: 0, name: ""),
    completed: 0,
    pending: 0,
    totalWorkHours: 0,
  ),

  ProjectStats(
    project: Project(id: 1, name: ""),
    completed: 0,
    pending: 0,
    totalWorkHours: 0,
  ),

  ProjectStats(
    project: Project(id: 2, name: ""),
    completed: 0,
    pending: 0,
    totalWorkHours: 0,
  ),
];
