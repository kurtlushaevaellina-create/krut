import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/utils/value_or_null.dart';
import 'package:track_dev/core/repository/preferences.dart';
import 'package:track_dev/providers/stats_provider.dart';

class DisplayOptions extends ConsumerWidget {
  const DisplayOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLayout =
        ref.watch(statsLayoutProvider).valueOrNull ?? StatsLayout.grid;

    return RadioGroup(
      groupValue: selectedLayout,
      onChanged: (val) {
        if (val != null) {
          ref.read(statsLayoutProvider.notifier).setLayout(val);
        }
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          RadioListTile<StatsLayout>(
            title: const Text('Сетка'),
            subtitle: const Text('Отображать карточки в две колонки'),
            value: StatsLayout.grid,
          ),
          RadioListTile<StatsLayout>(
            title: const Text('Список'),
            subtitle: const Text('Отображать карточки в одну колонку'),
            value: StatsLayout.list,
          ),
        ],
      ),
    );
  }
}
