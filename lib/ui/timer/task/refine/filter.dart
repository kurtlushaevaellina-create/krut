import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/providers/task_selector_provider.dart';

class TaskFilterOptions extends ConsumerWidget {
  const TaskFilterOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectorState = ref.watch(taskSelectorProvider);
    final notifier = ref.read(taskSelectorProvider.notifier);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      children: [
        Wrap(
          spacing: 8,
          children: [
            _FilterChip(
              label: 'Все',
              selected: selectorState.filterMode == TaskFilterMode.all,
              onSelected: () => notifier.setFilterMode(TaskFilterMode.all),
            ),
            _FilterChip(
              label: 'Проекты',
              selected: selectorState.filterMode == TaskFilterMode.projectsOnly,
              onSelected: () =>
                  notifier.setFilterMode(TaskFilterMode.projectsOnly),
            ),
            _FilterChip(
              label: 'Задачи',
              selected: selectorState.filterMode == TaskFilterMode.issuesOnly,
              onSelected: () => notifier.setFilterMode(TaskFilterMode.issuesOnly),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    );
  }
}
