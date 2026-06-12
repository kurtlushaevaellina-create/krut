import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:track_dev/core/models/time_entry_activity.dart';
import 'package:track_dev/providers/activities_provider.dart';

class ActivityField extends ConsumerWidget {
  const ActivityField({
    super.key,
    required this.selectedActivity,
    required this.onChanged,
    this.enabled = true,
  });

  final TimeEntryActivity? selectedActivity;
  final ValueChanged<TimeEntryActivity?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activitiesAsync = ref.watch(activitiesProvider);

    if (activitiesAsync.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (activitiesAsync.hasError) {
      return Card(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Не удалось загрузить активности',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Повторить'),
                onPressed: () => ref.invalidate(activitiesProvider),
              ),
            ],
          ),
        ),
      );
    }

    final activities = activitiesAsync.value ?? [];

    return DropdownButtonFormField<TimeEntryActivity>(
      key: ValueKey(selectedActivity),
      initialValue: selectedActivity,
      decoration: InputDecoration(
        labelText: 'Активность',
        prefixIcon: const Icon(Icons.label_outline_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: activities
          .map(
            (activity) => DropdownMenuItem<TimeEntryActivity>(
              value: activity,
              child: Text(activity.name),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
