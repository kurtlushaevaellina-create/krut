import 'package:flutter/material.dart';
import 'package:track_dev/core/usecase/stopwatch.dart' as app;
import 'package:track_dev/ui/timer/widget/stopwatch_clock.dart';

class ClockSection extends StatelessWidget {
  const ClockSection({
    super.key,
    required this.stopwatch,
  });

  final app.Stopwatch stopwatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Center(
        child: StopwatchClock(
          stopwatch: stopwatch,
          size: 260,
          smallLineColor: theme.colorScheme.outlineVariant,
          largeLineColor: theme.colorScheme.onSurface,
          textColor: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
