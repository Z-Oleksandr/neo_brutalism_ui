import 'package:flutter/material.dart';

import '../../foundation/neo_strings.dart';
import '../../primitives/neo_pressable.dart';
import '../../primitives/neo_pressable_surface.dart';
import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';

/// A compact selectable and/or deletable label.
///
/// Selectable when [onSelected] is set: a selected chip is filled with
/// [color] and stays pressed in. Shows a delete button when [onDeleted] is set.
class NeoChip extends StatelessWidget {
  const NeoChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.deleteLabel,
    this.color,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;

  /// Semantic label of the delete button. Defaults to the localized "Clear".
  final String? deleteLabel;

  /// Fill when selected. Defaults to the theme primary.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final colors = theme.colors;
    final fill = selected ? (color ?? colors.primary) : colors.surface;
    final fg = colors.onColor(fill);
    final padding = EdgeInsetsDirectional.only(
      start: theme.spacing.md,
      end: onDeleted == null ? theme.spacing.md : theme.spacing.xs,
      top: 6,
      bottom: 6,
    );
    final body = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: fg),
          SizedBox(width: theme.spacing.xs + 2),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.label.copyWith(fontSize: 13, color: fg),
          ),
        ),
        if (onDeleted != null) ...[
          SizedBox(width: theme.spacing.xs),
          NeoPressable(
            onPressed: onDeleted,
            semanticLabel:
                '${deleteLabel ?? NeoStrings.of(context).clear} '
                '$label',
            minTapTarget: const Size.square(32),
            focusRadius: BorderRadius.circular(12),
            builder: (context, states, press) => Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 16, color: fg),
            ),
          ),
        ],
      ],
    );
    if (onSelected == null) {
      return NeoSurface(
        color: fill,
        radius: theme.radii.md,
        borderWidth: theme.borders.regular,
        shadow: theme.shadows.sm,
        padding: padding,
        child: body,
      );
    }
    return NeoPressableSurface(
      onPressed: () => onSelected!(!selected),
      selected: selected,
      sunken: selected,
      color: fill,
      radius: theme.radii.md,
      borderWidth: theme.borders.regular,
      shadow: theme.shadows.sm,
      padding: padding,
      child: body,
    );
  }
}
