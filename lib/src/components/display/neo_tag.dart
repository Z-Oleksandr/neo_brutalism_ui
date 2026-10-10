import 'package:flutter/widgets.dart';

import '../../theme/neo_theme.dart';

enum NeoTagSize { small, medium }

/// A compact status or category label with a thin border.
class NeoTag extends StatelessWidget {
  const NeoTag({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.size = NeoTagSize.small,
    this.uppercase = true,
    this.maxWidth,
  });

  final String label;
  final IconData? icon;

  /// Fill. Defaults to the theme surface.
  final Color? color;
  final NeoTagSize size;
  final bool uppercase;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final fill = color ?? theme.colors.surface;
    final fg = theme.colors.onColor(fill);
    final small = size == NeoTagSize.small;
    final style = small
        ? theme.typography.overline
        : theme.typography.caption.copyWith(fontWeight: FontWeight.w800);
    return Container(
      constraints: maxWidth == null
          ? null
          : BoxConstraints(maxWidth: maxWidth!),
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(theme.radii.sm),
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.thin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 11 : 14, color: fg),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              uppercase ? label.toUpperCase() : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
