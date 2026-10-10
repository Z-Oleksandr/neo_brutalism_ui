import 'package:flutter/widgets.dart';

import '../../primitives/neo_pressable_surface.dart';
import '../../theme/neo_theme.dart';

/// A square icon-only button. [semanticLabel] is required for screen readers.
class NeoIconButton extends StatelessWidget {
  const NeoIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.onLongPress,
    this.color,
    this.size = 44,
    this.selected,
    this.radius,
    this.focusNode,
    this.autofocus = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  /// Fill. Defaults to the theme surface.
  final Color? color;

  /// Visual side length; the tap target is at least 48.
  final double size;
  final bool? selected;
  final double? radius;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    return NeoPressableSurface(
      onPressed: onPressed,
      onLongPress: onLongPress,
      color: color,
      width: size,
      height: size,
      radius: radius,
      shadow: size < 40 ? theme.shadows.sm : null,
      semanticLabel: semanticLabel,
      selected: selected,
      focusNode: focusNode,
      autofocus: autofocus,
      child: Icon(icon, size: size * 0.5),
    );
  }
}
