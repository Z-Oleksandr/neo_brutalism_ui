import 'package:flutter/widgets.dart';

import '../../theme/neo_theme.dart';

/// A solid rule. Horizontal by default; [NeoDivider.vertical] for columns.
class NeoDivider extends StatelessWidget {
  const NeoDivider({
    super.key,
    this.thickness,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  }) : vertical = false;

  const NeoDivider.vertical({
    super.key,
    this.thickness,
    this.color,
    this.indent = 0,
    this.endIndent = 0,
  }) : vertical = true;

  /// Defaults to the regular theme border width.
  final double? thickness;
  final Color? color;
  final double indent;
  final double endIndent;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final t = thickness ?? theme.borders.regular;
    final line = ColoredBox(color: color ?? theme.colors.border);
    return Padding(
      padding: vertical
          ? EdgeInsets.only(top: indent, bottom: endIndent)
          : EdgeInsetsDirectional.only(start: indent, end: endIndent),
      child: vertical
          ? SizedBox(width: t, height: double.infinity, child: line)
          : SizedBox(width: double.infinity, height: t, child: line),
    );
  }
}
