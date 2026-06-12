import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:track_dev/core/usecase/stopwatch.dart' as app;

class StopwatchClock extends StatefulWidget {
  final app.Stopwatch stopwatch;
  final double size;
  final Color smallLineColor;
  final Color largeLineColor;
  final Color textColor;

  const StopwatchClock({
    super.key,
    required this.stopwatch,
    this.size = 220,
    // TODO: Use colors from material theme
    this.smallLineColor = const Color(0xFF9AA0A6),
    this.largeLineColor = const Color(0xFF202124),
    this.textColor = const Color(0xFF202124),
  });

  @override
  State<StopwatchClock> createState() => _StopwatchClockState();
}

class _StopwatchClockState extends State<StopwatchClock>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (mounted) setState(() {});
    });

    if (widget.stopwatch.isRunning) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant StopwatchClock oldWidget) {
    super.didUpdateWidget(oldWidget);

    final wasRunning = oldWidget.stopwatch.isRunning;
    final isRunning = widget.stopwatch.isRunning;

    if (wasRunning != isRunning) {
      if (isRunning) {
        _ticker.start();
      } else {
        _ticker.stop();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = widget.stopwatch.elapsed;

    final days = elapsed.inDays;
    final hours = elapsed.inHours.remainder(24);
    final minutes = elapsed.inMinutes.remainder(60);
    final seconds = elapsed.inSeconds.remainder(60);

    final totalSeconds = elapsed.inMilliseconds / 1000.0;
    final secondIndex = totalSeconds.floor().remainder(60);
    final fraction = totalSeconds - totalSeconds.floor();

    final previousIndex = (secondIndex + 59) % 60;

    final timeText =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _StopwatchClockPainter(
                fraction: fraction,
                activeIndex: secondIndex,
                previousIndex: previousIndex,
                smallLineColor: widget.smallLineColor,
                largeLineColor: widget.largeLineColor,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (days > 0) ...[
                Text(
                  '${days}d',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                timeText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: days > 0 ? 22 : 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StopwatchClockPainter extends CustomPainter {
  static const int _ticks = 60;

  final double fraction; // 0..1 within the current second
  final int activeIndex;
  final int previousIndex;
  final Color smallLineColor;
  final Color largeLineColor;

  _StopwatchClockPainter({
    required this.fraction,
    required this.activeIndex,
    required this.previousIndex,
    required this.smallLineColor,
    required this.largeLineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Two-tick morph:
    // previous tick shrinks to default size,
    // current tick grows to active size.
    final growT = Curves.easeOutCubic.transform(fraction);
    final shrinkT = Curves.easeInCubic.transform(fraction);

    for (int i = 0; i < _ticks; i++) {
      final isLarge = i % 5 == 0;
      final angle = -math.pi / 2 + (2 * math.pi * i / _ticks);

      final baseOuter = radius * 0.96;

      final baseLength = isLarge ? radius * 0.16 : radius * 0.09;
      final activeLength = isLarge ? radius * 0.24 : radius * 0.14;

      final baseWidth = isLarge ? 2.2 : 1.4;
      final activeWidth = isLarge ? 7.7 : 4.2;

      double length = baseLength;
      double strokeWidth = baseWidth;

      if (i == activeIndex) {
        length = _lerp(baseLength, activeLength, growT);
        strokeWidth = _lerp(baseWidth, activeWidth, growT);
      } else if (i == previousIndex) {
        length = _lerp(activeLength, baseLength, shrinkT);
        strokeWidth = _lerp(activeWidth, baseWidth, shrinkT);
      }

      final outer = Offset(
        center.dx + math.cos(angle) * baseOuter,
        center.dy + math.sin(angle) * baseOuter,
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (baseOuter - length),
        center.dy + math.sin(angle) * (baseOuter - length),
      );

      paint
        ..color = isLarge ? largeLineColor : smallLineColor
        ..strokeWidth = strokeWidth;

      canvas.drawLine(inner, outer, paint);
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _StopwatchClockPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.previousIndex != previousIndex ||
        oldDelegate.smallLineColor != smallLineColor ||
        oldDelegate.largeLineColor != largeLineColor;
  }
}
