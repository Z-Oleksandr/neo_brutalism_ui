import 'package:flutter/widgets.dart';

import '../theme/neo_theme.dart';

/// A bordered box with a hard shadow: the basic neobrutalist building block.
class NeoSurface extends StatelessWidget {
  const NeoSurface({
    super.key,
    this.child,
    this.color,
    this.radius,
    this.borderWidth,
    this.borderColor,
    this.shadow,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
    this.clipBehavior = Clip.none,
  });

  final Widget? child;

  /// Fill color. Defaults to the theme surface.
  final Color? color;
  final double? radius;
  final double? borderWidth;
  final Color? borderColor;

  /// Shadow offset. Defaults to the medium theme shadow; [Offset.zero] hides it.
  final Offset? shadow;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final fill = color ?? theme.colors.surface;
    final content = child == null
        ? null
        : DefaultTextStyle.merge(
            style: TextStyle(color: theme.colors.onColor(fill)),
            child: IconTheme.merge(
              data: IconThemeData(color: theme.colors.onColor(fill)),
              child: child!,
            ),
          );
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      alignment: alignment,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: theme.decoration(
        color: fill,
        radius: radius,
        borderWidth: borderWidth,
        borderColor: borderColor,
        shadow: shadow,
      ),
      child: content,
    );
  }
}
