import 'package:flutter/widgets.dart';

import '../../primitives/neo_pressable_surface.dart';
import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';
import '../display/neo_badge.dart';

/// One destination of a [NeoNavBar].
@immutable
class NeoNavBarItem {
  const NeoNavBarItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badgeCount,
  });

  final IconData icon;
  final IconData? activeIcon;

  /// Announced by screen readers, and shown when labels are enabled.
  final String label;
  final int? badgeCount;
}

/// A floating bottom navigation bar. Sits above the system gesture area
/// using the raw bottom view padding, so it works inside or outside a
/// [SafeArea].
class NeoNavBar extends StatelessWidget {
  const NeoNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.activeColor,
    this.color,
    this.showLabels = false,
    this.margin,
  }) : assert(items.length >= 2);

  final List<NeoNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Fill of the active item. Defaults to the theme primary.
  final Color? activeColor;

  /// Bar fill. Defaults to the theme surface.
  final Color? color;
  final bool showLabels;

  /// Space around the bar. Defaults to extra-large horizontal insets and a
  /// bottom gap derived from the system inset.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final active = activeColor ?? theme.colors.primary;
    return Padding(
      padding:
          margin ??
          EdgeInsets.fromLTRB(
            theme.spacing.xl,
            0,
            theme.spacing.xl,
            bottomInset / 2 + theme.spacing.lg,
          ),
      child: NeoSurface(
        color: color,
        padding: EdgeInsets.symmetric(vertical: theme.spacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < items.length; i++)
              Flexible(
                child: _Item(
                  item: items[i],
                  active: i == currentIndex,
                  activeColor: active,
                  showLabel: showLabels,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.item,
    required this.active,
    required this.activeColor,
    required this.showLabel,
    required this.onTap,
  });

  final NeoNavBarItem item;
  final bool active;
  final Color activeColor;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final icon = Icon(active ? item.activeIcon ?? item.icon : item.icon);
    final face = NeoPressableSurface(
      onPressed: onTap,
      sunken: active,
      selected: active,
      semanticLabel: item.label,
      excludeSemantics: true,
      color: active ? activeColor : theme.colors.surface,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      padding: showLabel
          ? EdgeInsets.symmetric(
              horizontal: theme.spacing.sm,
              vertical: theme.spacing.xs,
            )
          : null,
      child: showLabel
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.overline,
                ),
              ],
            )
          : icon,
    );
    return Padding(
      padding: EdgeInsets.all(theme.spacing.xs),
      child: NeoBadge(count: item.badgeCount, child: face),
    );
  }
}
