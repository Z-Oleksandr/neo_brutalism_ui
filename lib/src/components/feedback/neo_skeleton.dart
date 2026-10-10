import 'package:flutter/widgets.dart';

import '../../theme/neo_theme.dart';

/// Drives one shared shimmer for every [NeoSkeleton] below it.
///
/// Skeletons repaint through their painter, so the subtree never rebuilds per
/// frame. With reduced motion the blocks stay static.
class NeoShimmer extends StatefulWidget {
  const NeoShimmer({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1200),
  });

  final Widget child;
  final Duration period;

  @override
  State<NeoShimmer> createState() => _NeoShimmerState();
}

class _NeoShimmerState extends State<NeoShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_reduced) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(NeoShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _controller.duration = widget.period;
      if (!_reduced) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ShimmerScope(
    animation: _reduced ? null : _controller,
    child: widget.child,
  );
}

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required this.animation, required super.child});

  final Animation<double>? animation;

  static Animation<double>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerScope>()?.animation;

  @override
  bool updateShouldNotify(_ShimmerScope oldWidget) =>
      animation != oldWidget.animation;
}

/// A placeholder block. Shimmers inside a [NeoShimmer], static otherwise.
class NeoSkeleton extends StatelessWidget {
  const NeoSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius,
    this.circle = false,
  });

  const NeoSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = null,
      circle = true;

  const NeoSkeleton.avatar({super.key, required double size, this.radius})
    : width = size,
      height = size,
      circle = false;

  /// Paragraph placeholder of [lines] bars; the last one is shortened to
  /// [lastLineFraction] of the width.
  const factory NeoSkeleton.text({
    Key? key,
    int lines,
    double lineHeight,
    double spacing,
    double lastLineFraction,
    double? width,
  }) = _NeoSkeletonText;

  final double? width;
  final double? height;

  /// Corner radius. Defaults to the small theme radius.
  final double? radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final animation = _ShimmerScope.maybeOf(context);
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _SkeletonPainter(
            progress: animation,
            base: theme.colors.skeletonBase,
            highlight: theme.colors.skeletonHighlight,
            radius: circle ? null : (radius ?? theme.radii.sm),
          ),
        ),
      ),
    );
  }
}

class _NeoSkeletonText extends NeoSkeleton {
  const _NeoSkeletonText({
    super.key,
    this.lines = 3,
    this.lineHeight = 12,
    this.spacing = 8,
    this.lastLineFraction = 0.6,
    super.width,
  });

  final int lines;
  final double lineHeight;
  final double spacing;
  final double lastLineFraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final full = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : 200.0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < lines; i++) ...[
                if (i > 0) SizedBox(height: spacing),
                NeoSkeleton(
                  height: lineHeight,
                  width: i == lines - 1 && lines > 1
                      ? full * lastLineFraction
                      : full,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter({
    required this.progress,
    required this.base,
    required this.highlight,
    required this.radius,
  }) : super(repaint: progress);

  final Animation<double>? progress;
  final Color base;
  final Color highlight;
  final double? radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint();
    final t = progress?.value;
    if (t == null) {
      paint.color = base;
    } else {
      paint.shader = LinearGradient(
        begin: Alignment(-3 + 4 * t, 0),
        end: Alignment(-1 + 4 * t, 0),
        colors: [base, highlight, base],
      ).createShader(rect);
    }
    if (radius == null) {
      canvas.drawOval(rect, paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius!)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SkeletonPainter old) =>
      old.progress != progress ||
      old.base != base ||
      old.highlight != highlight ||
      old.radius != radius;
}
