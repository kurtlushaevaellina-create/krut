import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/core/models/project.dart';
import 'package:track_dev/utils/value_or_null.dart';
import 'package:track_dev/providers/projects_provider.dart';
import 'package:track_dev/providers/stats_provider.dart';

class FilterOptions extends ConsumerWidget {
  const FilterOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProject = ref.watch(statsProjectFilterProvider).valueOrNull;

    final projectsAsync = ref.watch(projectsProvider);
    final projects = projectsAsync.valueOrNull ?? const [];

    return RadioGroup<Project?>(
      groupValue: selectedProject,
      onChanged: (val) {
        ref.read(statsProjectFilterProvider.notifier).setProject(val);
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          RadioListTile<Project?>(title: const Text('Все проекты'), value: null),
          ...projects.map((project) {
            return RadioListTile<Project?>(title: Text(project.name), value: project);
          }),
        ],
      ),
    );
  }
}
