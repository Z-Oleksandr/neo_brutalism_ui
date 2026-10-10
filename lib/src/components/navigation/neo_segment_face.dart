import 'package:flutter/widgets.dart';

import '../../primitives/neo_pressable_surface.dart';
import '../../theme/neo_theme.dart';
import '../display/neo_badge.dart';

/// Shared visual of a tab or segment. Internal to the navigation group.
class NeoSegmentFace extends StatelessWidget {
  const NeoSegmentFace({
    super.key,
    required this.active,
    required this.activeColor,
    required this.onPressed,
    required this.height,
    this.label,
    this.icon,
    this.badgeCount,
    this.semanticLabel,
    this.toggle = false,
  });

  final bool active;
  final Color activeColor;
  final VoidCallback? onPressed;
  final double height;
  final String? label;
  final IconData? icon;
  final int? badgeCount;
  final String? semanticLabel;
  final bool toggle;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final style = theme.typography.label;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: label == null ? 22 : 18),
        if (icon != null && label != null) SizedBox(width: theme.spacing.xs),
        if (label != null)
          Flexible(
            child: Text(
              label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
      ],
    );
    final face = NeoPressableSurface(
      onPressed: onPressed,
      sunken: active,
      selected: toggle ? null : active,
      toggled: toggle ? active : null,
      color: active ? activeColor : theme.colors.surface,
      radius: theme.radii.sm,
      shadow: theme.shadows.sm,
      constraints: BoxConstraints(minHeight: height),
      padding: EdgeInsetsDirectional.symmetric(horizontal: theme.spacing.md),
      semanticLabel: semanticLabel,
      child: content,
    );
    return NeoBadge(count: badgeCount, child: face);
  }
}
