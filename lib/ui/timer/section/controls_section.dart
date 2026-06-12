import 'package:flutter/material.dart';
import 'package:track_dev/ui/timer/widget/timer_control_buttons.dart';

class ControlsSection extends StatelessWidget {
  const ControlsSection({
    super.key,
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.onStop,
    required this.onSubmit,
  });

  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return TimerControlButtons(
      isRunning: isRunning,
      onStart: onStart,
      onPause: onPause,
      onStop: onStop,
      onSubmit: onSubmit,
    );
  }
}
