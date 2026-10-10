import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/neo_theme.dart';

/// A tilted, slapped-on label. Shows [child], or [label] with an optional
/// [icon].
class NeoSticker extends StatefulWidget {
  const NeoSticker({
    super.key,
    this.label,
    this.icon,
    this.child,
    this.angle = 8,
    this.color,
    this.animate = true,
    this.semanticLabel,
  }) : assert(label != null || child != null);

  final String? label;
  final IconData? icon;
  final Widget? child;

  /// Tilt in degrees; positive is clockwise.
  final double angle;

  /// Defaults to the theme pink.
  final Color? color;

  /// Slaps in with a scale bounce on first build.
  final bool animate;
  final String? semanticLabel;

  @override
  State<NeoSticker> createState() => _NeoStickerState();
}

class _NeoStickerState extends State<NeoSticker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.animate && !reduced) {
      _slap.forward();
    } else {
      _slap.value = 1;
    }
  }

  @override
  void dispose() {
    _slap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final fill = widget.color ?? theme.colors.pink;
    final fg = theme.colors.onColor(fill);
    final content =
        widget.child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 18, color: fg),
              SizedBox(width: theme.spacing.sm),
            ],
            Text(
              widget.label!,
              style: theme.typography.label.copyWith(
                color: fg,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );

    final sticker = Transform.rotate(
      angle: widget.angle * math.pi / 180,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md + 2,
          vertical: theme.spacing.sm,
        ),
        decoration: theme.decoration(color: fill),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: fg),
          child: content,
        ),
      ),
    );

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _slap,
          builder: (context, child) {
            final t = Curves.elasticOut.transform(_slap.value);
            return Opacity(
              opacity: _slap.value.clamp(0.0, 1.0),
              child: Transform.scale(scale: 1.6 - 0.6 * t, child: child),
            );
          },
          child: sticker,
        ),
      ),
    );
  }
}
