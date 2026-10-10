import 'package:flutter/material.dart';

import 'neo_theme_data.dart';

/// Provides a [NeoThemeData] to a subtree.
///
/// [NeoTheme.of] resolves, in order: the nearest [NeoTheme], the
/// [NeoThemeData] extension of the ambient [Theme], and finally the default
/// light or dark theme matching [Theme] brightness.
class NeoTheme extends InheritedTheme {
  const NeoTheme({super.key, required this.data, required super.child});

  final NeoThemeData data;

  static NeoThemeData of(BuildContext context) {
    final scoped = context.dependOnInheritedWidgetOfExactType<NeoTheme>();
    if (scoped != null) return scoped.data;
    final theme = Theme.of(context);
    return theme.extension<NeoThemeData>() ??
        (theme.brightness == Brightness.dark
            ? NeoThemeData.fallbackDark
            : NeoThemeData.fallbackLight);
  }

  /// The app's base text style (font family, locale features) without
  /// decoration, for text roots outside a Material such as overlays.
  static TextStyle baseTextStyleOf(BuildContext context) =>
      (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(
        decoration: TextDecoration.none,
      );

  @override
  Widget wrap(BuildContext context, Widget child) =>
      NeoTheme(data: data, child: child);

  @override
  bool updateShouldNotify(NeoTheme oldWidget) => data != oldWidget.data;
}

extension NeoThemeContext on BuildContext {
  NeoThemeData get neo => NeoTheme.of(this);
}
