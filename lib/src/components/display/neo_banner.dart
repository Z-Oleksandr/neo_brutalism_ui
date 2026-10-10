import 'package:flutter/widgets.dart';

import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';

/// A bold, colored title block for section and page headers.
class NeoBanner extends StatelessWidget {
  const NeoBanner({
    super.key,
    required this.text,
    this.color,
    this.style,
    this.textAlign = TextAlign.center,
    this.padding,
  });

  final String text;

  /// Defaults to the theme primary.
  final Color? color;

  /// Defaults to the headline style.
  final TextStyle? style;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    return Semantics(
      header: true,
      child: NeoSurface(
        color: color ?? theme.colors.primary,
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: theme.spacing.lg,
              vertical: theme.spacing.sm,
            ),
        child: Text(
          text,
          textAlign: textAlign,
          style: style ?? theme.typography.headline,
        ),
      ),
    );
  }
}
