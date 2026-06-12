import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:track_dev/providers/task_selector_provider.dart';
import 'package:track_dev/ui/timer/task/refine/refine.dart';
import 'package:track_dev/ui/timer/task/task_item_tile.dart';
import 'package:track_dev/ui/timer/task/task_selector_search_bar.dart';
import 'package:track_dev/ui/timer/task/task_description_sheet.dart';

/// A result returned by the task selector when the user picks an item.
class TaskSelectorResult {
  const TaskSelectorResult({this.project, this.issue});

  final String? project;
  final String? issue;
}

class TaskSelectorSheet extends HookConsumerWidget {
  const TaskSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchFocusNode = useFocusNode();
    final searchController = useTextEditingController();

    // Focus the search bar only once when the widget is first mounted,
    // not on every rebuild (which autofocus: true would cause).
    useEffect(() {
      searchFocusNode.requestFocus();
      return null;
    }, const []);

    final filteredItemsAsync = ref.watch(filteredTaskItemsProvider);
    final selectorState = ref.watch(taskSelectorProvider);

    Future<void> onItemTapped(TaskItem item) async {
      final selected = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => TaskItemDescriptionSheet(item: item),
      );

      if (selected == true) {
        if (!context.mounted) return;
        final result = switch (item) {
          ProjectTaskItem(:final project) => TaskSelectorResult(
              project: project.id.toString(),
            ),
          IssueTaskItem(:final issue) => TaskSelectorResult(
              issue: issue.id.toString(),
            ),
        };
        Navigator.of(context).pop(result);
      }
    }

    return Column(
      children: [
        _SheetHeader(filterMode: selectorState.filterMode),
        const Divider(height: 1),

        Expanded(
          child: filteredItemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Ошибка загрузки: $err',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return _EmptyState(
                  hasSearchQuery: selectorState.searchQuery.isNotEmpty,
                );
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return TaskItemTile(
                    item: item,
                    onTap: () => onItemTapped(item),
                  );
                },
              );
            },
          ),
        ),

        TaskSelectorSearchBar(
          focusNode: searchFocusNode,
          controller: searchController,
          onFilterSortPressed: () => showTaskRefineBottomSheet(context),
        ),
      ],
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.filterMode});

  final TaskFilterMode filterMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = switch (filterMode) {
      TaskFilterMode.all => 'Выбор задачи',
      TaskFilterMode.projectsOnly => 'Проекты',
      TaskFilterMode.issuesOnly => 'Задачи',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: const Size(36, 36),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearchQuery});

  final bool hasSearchQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearchQuery ? Icons.search_off_rounded : Icons.inbox_rounded,
              size: 48,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              hasSearchQuery ? 'Ничего не найдено' : 'Нет доступных задач',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasSearchQuery)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Попробуйте изменить запрос или фильтры',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows the full-screen task selector modal bottom sheet.
///
/// Returns a [TaskSelectorResult] if the user picks an item, or `null` if
/// dismissed.
Future<TaskSelectorResult?> showTaskSelectorSheet(BuildContext context) {
  return showModalBottomSheet<TaskSelectorResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return const FractionallySizedBox(
        heightFactor: 1.0,
        child: TaskSelectorSheet(),
      );
    },
  );
}
