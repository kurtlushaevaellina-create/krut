import 'package:flutter/material.dart';
import 'package:track_dev/ui/timer/task/refine/filter.dart';
import 'package:track_dev/ui/timer/task/refine/sort.dart';
import 'package:track_dev/ui/utils/tabbed_bottom_sheet.dart';

Future<T?> showTaskRefineBottomSheet<T>(BuildContext context) {
  return showTabbedBottomSheet(
    context: context,
    maxHeightFactor: 0.45,
    tabs: [
      (tab: const Tab(text: 'Фильтр'), content: const TaskFilterOptions()),
      (tab: const Tab(text: 'Сортировка'), content: const TaskSortOptions()),
    ],
  );
}
