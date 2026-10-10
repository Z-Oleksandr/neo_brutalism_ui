import 'package:flutter/material.dart';

import '../../theme/neo_theme.dart';
import 'neo_tab_bar.dart';

/// A pinned sliver header hosting a [NeoTabBar], for use in a
/// [CustomScrollView] or [NestedScrollView].
class NeoSliverTabBar extends StatelessWidget {
  const NeoSliverTabBar({
    super.key,
    required this.tabBar,
    this.backgroundColor,
    this.padding,
    this.pinned = true,
  });

  final NeoTabBar tabBar;

  /// Fill behind the bar. Defaults to the theme background.
  final Color? backgroundColor;

  /// Defaults to symmetric large horizontal and small vertical spacing.
  final EdgeInsetsGeometry? padding;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final insets =
        padding ??
        EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.sm,
        );
    final resolved = insets.resolve(Directionality.of(context));
    final tabHeight = MediaQuery.textScalerOf(context).scale(tabBar.tabHeight);
    final extent =
        NeoTabBar.heightFor(theme, tabHeight: tabHeight) + resolved.vertical;
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _Delegate(
        extent: extent,
        color: backgroundColor ?? theme.colors.background,
        padding: insets,
        child: tabBar,
      ),
    );
  }
}

class _Delegate extends SliverPersistentHeaderDelegate {
  _Delegate({
    required this.extent,
    required this.color,
    required this.padding,
    required this.child,
  });

  final double extent;
  final Color color;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: color,
      child: ClipRect(
        child: Padding(
          padding: padding,
          child: Align(alignment: AlignmentDirectional.topStart, child: child),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_Delegate old) =>
      old.extent != extent ||
      old.color != color ||
      old.padding != padding ||
      old.child != child;
}
