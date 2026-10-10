import 'package:flutter/widgets.dart';

import '../../primitives/neo_pressable_surface.dart';
import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';

/// A bordered row with leading, title, subtitle and trailing slots.
///
/// Pressable when [onTap] or [onLongPress] is set. [highlighted] tints the
/// tile and adds an accent rail on the start edge, e.g. for unread items.
class NeoListTile extends StatelessWidget {
  const NeoListTile({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.dense = false,
    this.selected = false,
    this.highlighted = false,
    this.color,
    this.accentColor,
    this.semanticLabel,
  });

  final Widget title;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool dense;

  /// Fills the tile with [accentColor].
  final bool selected;
  final bool highlighted;

  /// Tile fill. Defaults to the theme surface.
  final Color? color;

  /// Rail and selection color. Defaults to the theme primary.
  final Color? accentColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final accent = accentColor ?? theme.colors.primary;
    final base = color ?? theme.colors.surface;
    final fill = selected
        ? accent
        : highlighted
        ? Color.alphaBlend(accent.withValues(alpha: 0.18), base)
        : base;
    final fg = theme.colors.onColor(fill);
    final mutedFg = fg == theme.colors.ink ? theme.colors.inkMuted : fg;
    final pad = dense ? theme.spacing.sm : theme.spacing.md;
    final rail = theme.spacing.xs + 2;

    final content = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        pad + (highlighted ? rail : 0),
        pad,
        pad,
        pad,
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, SizedBox(width: theme.spacing.md)],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style:
                      (dense
                              ? theme.typography.bodyStrong
                              : theme.typography.titleSmall)
                          .copyWith(color: fg),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: title,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: theme.spacing.xs / 2),
                  DefaultTextStyle(
                    style: theme.typography.caption.copyWith(color: mutedFg),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: theme.spacing.sm),
            IconTheme.merge(
              data: IconThemeData(color: fg),
              child: trailing!,
            ),
          ],
        ],
      ),
    );

    final body = highlighted
        ? Stack(
            children: [
              content,
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: rail,
                child: ColoredBox(color: accent),
              ),
            ],
          )
        : content;

    final r = theme.radii.md;
    if (onTap == null && onLongPress == null) {
      return Semantics(
        container: true,
        selected: selected,
        label: semanticLabel,
        child: NeoSurface(
          color: fill,
          radius: r,
          clipBehavior: Clip.antiAlias,
          child: body,
        ),
      );
    }
    return NeoPressableSurface(
      onPressed: onTap,
      onLongPress: onLongPress,
      color: fill,
      radius: r,
      alignment: null,
      clipBehavior: Clip.antiAlias,
      minTapTarget: Size.zero,
      selected: selected,
      semanticLabel: semanticLabel,
      child: body,
    );
  }
}
