import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';
import '../../theme/neo_theme_data.dart';
import 'neo_segment_face.dart';

/// One entry of a [NeoTabBar]. Provide a [label], an [icon], or both.
@immutable
class NeoTab {
  const NeoTab({this.label, this.icon, this.badgeCount, this.semanticLabel})
    : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;

  /// Shown as a [NeoBadge] count when greater than zero.
  final int? badgeCount;

  /// Required for icon-only tabs to be announced by screen readers.
  final String? semanticLabel;
}

/// A bordered row of tabs; the selected tab is pressed in and filled with
/// [activeColor].
///
/// Drive it with [selectedIndex] and [onChanged], or pass a [TabController]
/// to keep it in sync with a [TabBarView].
class NeoTabBar extends StatefulWidget {
  const NeoTabBar({
    super.key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onChanged,
    this.controller,
    this.activeColor,
    this.isScrollable = false,
    this.tabHeight = 44,
    this.color,
  });

  final List<NeoTab> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final TabController? controller;

  /// Defaults to the theme secondary color.
  final Color? activeColor;

  /// Tabs size to their content and scroll horizontally instead of sharing
  /// the width equally.
  final bool isScrollable;
  final double tabHeight;

  /// Container fill. Defaults to the theme surface.
  final Color? color;

  /// Total height of a bar with the given [tabHeight] under [theme].
  static double heightFor(NeoThemeData theme, {double tabHeight = 44}) =>
      (tabHeight < 48 ? 48 : tabHeight) +
      theme.spacing.sm * 2 +
      theme.borders.thick * 2 +
      theme.shadows.md.dy;

  @override
  State<NeoTabBar> createState() => _NeoTabBarState();
}

class _NeoTabBarState extends State<NeoTabBar> {
  final List<GlobalKey> _keys = [];
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(NeoTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
    _reveal(_selected);
  }

  void _reveal(int index) {
    if (!widget.isScrollable) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = index < _keys.length ? _keys[index].currentContext : null;
      if (!mounted || target == null) return;
      final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      Scrollable.ensureVisible(
        target,
        alignment: 0.5,
        duration: reduced ? Duration.zero : NeoTheme.of(context).motion.medium,
        curve: NeoTheme.of(context).motion.curve,
      );
    });
  }

  int get _selected => widget.controller?.index ?? widget.selectedIndex;

  void _select(int index) {
    widget.controller?.animateTo(index);
    widget.onChanged?.call(index);
    _reveal(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final active = widget.activeColor ?? theme.colors.secondary;
    final gap = theme.spacing.sm;
    while (_keys.length < widget.tabs.length) {
      _keys.add(GlobalKey());
    }
    final faces = [
      for (var i = 0; i < widget.tabs.length; i++)
        NeoSegmentFace(
          key: _keys[i],
          active: i == _selected,
          activeColor: active,
          height: widget.tabHeight,
          label: widget.tabs[i].label,
          icon: widget.tabs[i].icon,
          badgeCount: widget.tabs[i].badgeCount,
          semanticLabel: widget.tabs[i].semanticLabel,
          onPressed: () => _select(i),
        ),
    ];
    final row = widget.isScrollable
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: EdgeInsetsDirectional.only(end: theme.shadows.sm.dx),
            child: Row(
              children: [
                for (var i = 0; i < faces.length; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  faces[i],
                ],
              ],
            ),
          )
        : Row(
            children: [
              for (var i = 0; i < faces.length; i++) ...[
                if (i > 0) SizedBox(width: gap),
                Expanded(child: faces[i]),
              ],
            ],
          );
    final content = widget.isScrollable
        ? ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
            child: row,
          )
        : row;
    return NeoSurface(
      color: widget.color,
      padding: EdgeInsets.all(gap),
      clipBehavior: widget.isScrollable ? Clip.hardEdge : Clip.none,
      child: content,
    );
  }
}
