import 'package:flutter/widgets.dart';

import '../theme/neo_theme.dart';
import 'neo_pressable.dart';

/// A [NeoPressable] drawn as a [NeoSurface]-like box whose face slides onto
/// its hard shadow when pressed.
///
/// The shadow is painted once and stays put; only the face translates, so a
/// press repaints without relayout. Disabled surfaces lose their shadow and
/// use [disabledColor].
class NeoPressableSurface extends StatelessWidget {
  const NeoPressableSurface({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.color,
    this.disabledColor,
    this.radius,
    this.borderWidth,
    this.borderColor,
    this.shadow,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.none,
    this.semanticLabel,
    this.selected,
    this.toggled,
    this.sunken = false,
    this.isButton = true,
    this.focusNode,
    this.autofocus = false,
    this.minTapTarget = const Size.square(48),
    this.excludeSemantics = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? disabledColor;
  final double? radius;
  final double? borderWidth;
  final Color? borderColor;

  /// Shadow and press travel. Defaults to the medium theme shadow.
  final Offset? shadow;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final String? semanticLabel;
  final bool? selected;
  final bool? toggled;
  final bool sunken;
  final bool isButton;
  final FocusNode? focusNode;
  final bool autofocus;
  final Size minTapTarget;
  final bool excludeSemantics;

  bool get _enabled => onPressed != null || onLongPress != null;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final r = radius ?? theme.radii.md;
    final offset = _enabled ? (shadow ?? theme.shadows.md) : Offset.zero;
    final fill = _enabled
        ? (color ?? theme.colors.surface)
        : (disabledColor ?? theme.colors.surfaceMuted);
    final foreground = _enabled
        ? theme.colors.onColor(fill)
        : theme.colors.inkFaint;

    final face = Container(
      width: width,
      height: height,
      constraints: constraints,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: theme.decoration(
        color: fill,
        radius: r,
        borderWidth: borderWidth,
        borderColor: borderColor,
        shadow: Offset.zero,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground),
          child: alignment == null
              ? child
              : Align(
                  alignment: alignment!,
                  widthFactor: width == null ? 1 : null,
                  heightFactor: height == null ? 1 : null,
                  child: child,
                ),
        ),
      ),
    );

    return NeoPressable(
      onPressed: onPressed,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      selected: selected,
      toggled: toggled,
      sunken: sunken,
      isButton: isButton,
      focusNode: focusNode,
      autofocus: autofocus,
      minTapTarget: minTapTarget,
      excludeSemantics: excludeSemantics,
      focusRadius: BorderRadius.circular(r),
      builder: (context, states, press) => CustomPaint(
        painter: offset == Offset.zero
            ? null
            : NeoHardShadowPainter(
                offset: offset,
                radius: r,
                color: theme.colors.shadow,
              ),
        child: AnimatedBuilder(
          animation: press,
          builder: (context, child) =>
              Transform.translate(offset: offset * press.value, child: child),
          child: face,
        ),
      ),
    );
  }
}

/// Paints a hard rounded-rect shadow of the painted area, shifted by [offset].
class NeoHardShadowPainter extends CustomPainter {
  const NeoHardShadowPainter({
    required this.offset,
    required this.radius,
    required this.color,
  });

  final Offset offset;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(offset & size, Radius.circular(radius)),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(NeoHardShadowPainter old) =>
      old.offset != offset || old.radius != radius || old.color != color;
}
