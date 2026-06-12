import 'package:flutter/material.dart';
import 'package:track_dev/ui/timer/submit/field/picker_field.dart';

class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.date,
    required this.onTap,
    this.enabled = true,
  });

  final DateTime date;
  final VoidCallback onTap;
  final bool enabled;

  static String format(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';

  @override
  Widget build(BuildContext context) {
    return PickerField(
      enabled: enabled,
      onTap: onTap,
      leading: const Icon(Icons.calendar_today_rounded),
      title: 'Дата начала',
      subtitle: format(date),
    );
  }
}
