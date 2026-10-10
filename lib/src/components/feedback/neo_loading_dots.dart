import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/neo_strings.dart';
import '../../theme/neo_theme.dart';

/// Three bouncing squares. The neobrutalist replacement for a spinner.
class NeoLoadingDots extends StatefulWidget {
  const NeoLoadingDots({
    super.key,
    this.size = 8,
    this.color,
    this.semanticLabel,
  });

  /// Side of one square.
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  State<NeoLoadingDots> createState() => _NeoLoadingDotsState();
}

class _NeoLoadingDotsState extends State<NeoLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? NeoTheme.of(context).colors.ink;
    final s = widget.size;
    return Semantics(
      label: widget.semanticLabel ?? NeoStrings.of(context).loading,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(s * 5, s * 2.5),
          painter: _DotsPainter(progress: _controller, color: color, dot: s),
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter({required this.progress, required this.color, required this.dot})
    : super(repaint: progress);

  final Animation<double> progress;
  final Color color;
  final double dot;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final travel = size.height - dot;
    for (var i = 0; i < 3; i++) {
      final phase = (progress.value - i * 0.15) % 1.0;
      final lift = phase < 0.5 ? math.sin(phase * 2 * math.pi) : 0.0;
      final top = travel - travel * lift.clamp(0.0, 1.0);
      canvas.drawRect(Rect.fromLTWH(i * dot * 2, top, dot, dot), paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.progress != progress || old.color != color || old.dot != dot;
}
