import 'package:flutter/material.dart';
import 'package:track_dev/ui/timer/widget/attached_task_picker.dart';

class TaskPickerSection extends StatelessWidget {
  const TaskPickerSection({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AttachedTaskPicker(onTap: onTap);
  }
}
