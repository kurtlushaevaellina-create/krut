import 'package:flutter/material.dart';
import 'package:track_dev/ui/home/refine/display.dart';
import 'package:track_dev/ui/home/refine/filter.dart';
import 'package:track_dev/ui/utils/tabbed_bottom_sheet.dart';

Future<T?> showRefineBottomSheet<T>(BuildContext context) {
  return showTabbedBottomSheet(
    context: context,
    maxHeightFactor: 0.35,
    tabs: [
      (tab: const Tab(text: 'Фильтры'), content: FilterOptions()),
      (tab: const Tab(text: 'Вид'), content: const DisplayOptions()),
    ],
  );
}
