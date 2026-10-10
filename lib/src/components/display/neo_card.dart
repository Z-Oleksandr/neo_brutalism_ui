import 'package:flutter/widgets.dart';

import '../../primitives/neo_pressable_surface.dart';
import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';

/// A content container. Becomes pressable when [onTap] or [onLongPress] is set.
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.color,
    this.padding,
    this.radius,
    this.shadow,
    this.clipBehavior = Clip.antiAlias,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;

  /// Defaults to the large theme spacing.
  final EdgeInsetsGeometry? padding;

  /// Defaults to the large theme radius.
  final double? radius;
  final Offset? shadow;
  final Clip clipBehavior;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final p = padding ?? EdgeInsets.all(theme.spacing.lg);
    final r = radius ?? theme.radii.lg;
    if (onTap == null && onLongPress == null) {
      return Semantics(
        container: semanticLabel != null,
        label: semanticLabel,
        child: NeoSurface(
          color: color,
          padding: p,
          radius: r,
          shadow: shadow,
          clipBehavior: clipBehavior,
          child: child,
        ),
      );
    }
    return NeoPressableSurface(
      onPressed: onTap,
      onLongPress: onLongPress,
      color: color,
      padding: p,
      radius: r,
      shadow: shadow,
      alignment: null,
      clipBehavior: clipBehavior,
      minTapTarget: Size.zero,
      semanticLabel: semanticLabel,
      child: child,
    );
  }
}
