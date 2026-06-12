import 'package:flutter/material.dart';
import 'package:track_dev/ui/timer/submit/field/picker_field.dart';

class DurationField extends StatelessWidget {
  const DurationField({
    super.key,
    required this.hours,
    required this.minutes,
    required this.onTap,
    this.enabled = true,
  });

  final int hours;
  final int minutes;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PickerField(
      enabled: enabled,
      onTap: onTap,
      leading: const Icon(Icons.timer_outlined),
      title: 'Затраченное время',
      subtitle: '$hours ч. $minutes мин.',
    );
  }
}
