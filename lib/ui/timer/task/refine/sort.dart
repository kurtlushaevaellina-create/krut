import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/providers/task_selector_provider.dart';
import 'package:track_dev/ui/utils/tabbed_bottom_sheet.dart';

class TaskSortOptions extends ConsumerWidget {
  const TaskSortOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectorState = ref.watch(taskSelectorProvider);
    final notifier = ref.read(taskSelectorProvider.notifier);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        SortOptionEntry(
          title: 'По имени (А → Я)',
          direction: SortDirection.ascending,
          selected: selectorState.sortMode == TaskSortMode.nameAsc,
          onTap: () => notifier.setSortMode(TaskSortMode.nameAsc),
        ),
        SortOptionEntry(
          title: 'По имени (Я → А)',
          direction: SortDirection.descending,
          selected: selectorState.sortMode == TaskSortMode.nameDesc,
          onTap: () => notifier.setSortMode(TaskSortMode.nameDesc),
        ),
        SortOptionEntry(
          title: 'Сначала новые',
          direction: SortDirection.descending,
          selected: selectorState.sortMode == TaskSortMode.updatedDesc,
          onTap: () => notifier.setSortMode(TaskSortMode.updatedDesc),
        ),
        SortOptionEntry(
          title: 'Сначала старые',
          direction: SortDirection.ascending,
          selected: selectorState.sortMode == TaskSortMode.updatedAsc,
          onTap: () => notifier.setSortMode(TaskSortMode.updatedAsc),
        ),
      ],
    );
  }
}
