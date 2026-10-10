import 'package:flutter/widgets.dart';

import '../../theme/neo_theme.dart';

/// A chunky bordered progress bar.
///
/// Determinate when [value] is set (0..1), otherwise shows marching stripes
/// that stay still under reduced motion.
class NeoProgressBar extends StatefulWidget {
  const NeoProgressBar({
    super.key,
    this.value,
    this.color,
    this.trackColor,
    this.height = 16,
    this.radius,
    this.semanticLabel,
  });

  final double? value;

  /// Fill. Defaults to the theme primary.
  final Color? color;

  /// Track. Defaults to the theme surface.
  final Color? trackColor;
  final double height;
  final double? radius;
  final String? semanticLabel;

  @override
  State<NeoProgressBar> createState() => _NeoProgressBarState();
}

class _NeoProgressBarState extends State<NeoProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _march = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(NeoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.value != null || reduced) {
      _march.stop();
    } else if (!_march.isAnimating) {
      _march.repeat();
    }
  }

  @override
  void dispose() {
    _march.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final fill = widget.color ?? theme.colors.primary;
    final r = widget.radius ?? theme.radii.sm;
    final value = widget.value?.clamp(0.0, 1.0);
    final border = theme.borders.regular;
    final inner = Radius.circular((r - border).clamp(0.0, r));

    return Semantics(
      label: widget.semanticLabel,
      value: value == null ? null : '${(value * 100).round()}%',
      child: Container(
        height: widget.height,
        decoration: theme.decoration(
          color: widget.trackColor ?? theme.colors.surface,
          radius: r,
          borderWidth: border,
          shadow: theme.shadows.sm,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(inner),
          child: value == null
              ? RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _StripesPainter(
                      progress: _march,
                      color: fill,
                      edge: theme.colors.border,
                    ),
                  ),
                )
              : TweenAnimationBuilder<double>(
                  tween: Tween(end: value),
                  duration: theme.motion.medium,
                  curve: theme.motion.curve,
                  builder: (context, v, _) => FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: v,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: fill,
                        border: BorderDirectional(
                          end: v > 0 && v < 1
                              ? BorderSide(
                                  color: theme.colors.border,
                                  width: border,
                                )
                              : BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _StripesPainter extends CustomPainter {
  _StripesPainter({
    required this.progress,
    required this.color,
    required this.edge,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color color;
  final Color edge;

  @override
  void paint(Canvas canvas, Size size) {
    final band = size.height * 1.2;
    final shift = progress.value * band * 2;
    final fill = Paint()..color = color;
    final line = Paint()
      ..color = edge
      ..strokeWidth = 2;
    for (var x = -band * 2 + shift; x < size.width + band; x += band * 2) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + band, size.height)
        ..lineTo(x + band * 2, 0)
        ..lineTo(x + band, 0)
        ..close();
      canvas
        ..drawPath(path, fill)
        ..drawLine(Offset(x, size.height), Offset(x + band, 0), line);
    }
  }

  @override
  bool shouldRepaint(_StripesPainter old) =>
      old.progress != progress || old.color != color || old.edge != edge;
}
