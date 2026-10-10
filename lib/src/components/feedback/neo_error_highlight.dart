import 'package:flutter/widgets.dart';

import '../../theme/neo_theme.dart';

/// Flashes a danger-colored outline around [child] whenever [error] changes
/// to a new non-null value, then fades it out.
///
/// A subtle alternative to snackbars for failed actions. Under reduced motion
/// the outline shows steadily for [duration] instead of fading.
class NeoErrorHighlight extends StatefulWidget {
  const NeoErrorHighlight({
    super.key,
    required this.child,
    this.error,
    this.radius,
    this.duration = const Duration(milliseconds: 1400),
    this.semanticLabel,
  });

  final Widget child;

  /// Any value identifying the current failure; a new non-null value flashes.
  final Object? error;
  final double? radius;
  final Duration duration;

  /// Announced to screen readers when the highlight fires.
  final String? semanticLabel;

  @override
  State<NeoErrorHighlight> createState() => _NeoErrorHighlightState();
}

class _NeoErrorHighlightState extends State<NeoErrorHighlight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  @override
  void initState() {
    super.initState();
    if (widget.error != null) _flash.forward(from: 0);
  }

  @override
  void didUpdateWidget(NeoErrorHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    _flash.duration = widget.duration;
    if (widget.error != null && widget.error != oldWidget.error) {
      _flash.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    return Semantics(
      liveRegion: widget.error != null && widget.semanticLabel != null,
      label: widget.error == null ? null : widget.semanticLabel,
      child: CustomPaint(
        foregroundPainter: _OutlinePainter(
          progress: _flash,
          color: theme.colors.danger,
          radius: widget.radius ?? theme.radii.md,
          width: theme.borders.thick,
          steady: _reduced,
        ),
        child: widget.child,
      ),
    );
  }
}

class _OutlinePainter extends CustomPainter {
  _OutlinePainter({
    required this.progress,
    required this.color,
    required this.radius,
    required this.width,
    required this.steady,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color color;
  final double radius;
  final double width;
  final bool steady;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t >= 1) return;
    final opacity = steady ? 1.0 : Curves.easeIn.transform(1 - t);
    final rect = (Offset.zero & size).inflate(width);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius + width)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color.withValues(alpha: color.a * opacity),
    );
  }

  @override
  bool shouldRepaint(_OutlinePainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.radius != radius ||
      old.width != width ||
      old.steady != steady;
}
