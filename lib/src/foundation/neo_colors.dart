import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Color tokens for one brightness: accents, semantic roles, surfaces,
/// outline and ink.
///
/// Foreground colors for filled areas come from [onColor], which picks the
/// higher-contrast of [onLight] and [onDark] so any accent stays legible.
@immutable
class NeoColors {
  const NeoColors({
    required this.brightness,
    required this.yellow,
    required this.pink,
    required this.blue,
    required this.green,
    required this.teal,
    required this.purple,
    required this.orange,
    required this.lime,
    required this.red,
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.shadow,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.inkSubtle,
    required this.focus,
    required this.scrim,
    required this.skeletonBase,
    required this.skeletonHighlight,
    this.onLight = const Color(0xFF000000),
    this.onDark = const Color(0xFFFFFFFF),
  });

  factory NeoColors.light() => const NeoColors(
    brightness: Brightness.light,
    yellow: Color(0xFFFFC900),
    pink: Color(0xFFFF6B9D),
    blue: Color(0xFF59B3FF),
    green: Color(0xFF7BED9F),
    teal: Color(0xFF4ECDC4),
    purple: Color(0xFFA855F7),
    orange: Color(0xFFFF8C42),
    lime: Color(0xFFB8E62E),
    red: Color(0xFFE63946),
    primary: Color(0xFFFFC900),
    secondary: Color(0xFF59B3FF),
    success: Color(0xFF7BED9F),
    warning: Color(0xFFFF8C42),
    danger: Color(0xFFE63946),
    info: Color(0xFF59B3FF),
    background: Color(0xFFFFFDF0),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEEEEEE),
    border: Color(0xFF000000),
    shadow: Color(0xFF000000),
    ink: Color(0xFF000000),
    inkMuted: Color(0xB3000000),
    inkFaint: Color(0x8A000000),
    inkSubtle: Color(0x42000000),
    focus: Color(0xFF2962FF),
    scrim: Color(0x8A000000),
    skeletonBase: Color(0xFFE8E5D8),
    skeletonHighlight: Color(0xFFF5F2E5),
  );

  factory NeoColors.dark() => const NeoColors(
    brightness: Brightness.dark,
    yellow: Color(0xFFDDAE00),
    pink: Color(0xFF8E2633),
    blue: Color(0xFF234E80),
    green: Color(0xFF3E8C57),
    teal: Color(0xFF2E7A74),
    purple: Color(0xFF6B2EA6),
    orange: Color(0xFFB35E2A),
    lime: Color(0xFF6E8C1A),
    red: Color(0xFF992832),
    primary: Color(0xFFDDAE00),
    secondary: Color(0xFF234E80),
    success: Color(0xFF3E8C57),
    warning: Color(0xFFB35E2A),
    danger: Color(0xFF992832),
    info: Color(0xFF234E80),
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF1A1A1A),
    surfaceMuted: Color(0xFF2A2A2A),
    border: Color(0xFFFFFFFF),
    shadow: Color(0xFFFFFFFF),
    ink: Color(0xFFFFFFFF),
    inkMuted: Color(0xCCFFFFFF),
    inkFaint: Color(0x99FFFFFF),
    inkSubtle: Color(0x4DFFFFFF),
    focus: Color(0xFF82B1FF),
    scrim: Color(0xB3000000),
    skeletonBase: Color(0xFF242424),
    skeletonHighlight: Color(0xFF333333),
  );

  final Brightness brightness;

  final Color yellow;
  final Color pink;
  final Color blue;
  final Color green;
  final Color teal;
  final Color purple;
  final Color orange;
  final Color lime;
  final Color red;

  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  /// Page/scaffold background.
  final Color background;

  /// Fill of cards, buttons, inputs and other raised elements.
  final Color surface;

  /// Fill of disabled, inactive or empty elements.
  final Color surfaceMuted;

  final Color border;
  final Color shadow;

  /// Primary text and icons on [background] and [surface].
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color inkSubtle;

  /// Keyboard focus ring.
  final Color focus;

  /// Modal barrier behind dialogs and sheets.
  final Color scrim;

  final Color skeletonBase;
  final Color skeletonHighlight;

  /// Foreground used on light fills.
  final Color onLight;

  /// Foreground used on dark fills.
  final Color onDark;

  /// All accents in display order.
  List<Color> get accents => [
    yellow,
    pink,
    blue,
    green,
    teal,
    purple,
    orange,
    lime,
    red,
  ];

  /// The legible foreground for content drawn on [fill].
  Color onColor(Color fill) {
    if (fill == surface || fill == background || fill.a < 0.5) return ink;
    return contrastRatio(onLight, fill) >= contrastRatio(onDark, fill)
        ? onLight
        : onDark;
  }

  /// WCAG contrast ratio between two opaque colors, from 1 to 21.
  static double contrastRatio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  NeoColors copyWith({
    Brightness? brightness,
    Color? yellow,
    Color? pink,
    Color? blue,
    Color? green,
    Color? teal,
    Color? purple,
    Color? orange,
    Color? lime,
    Color? red,
    Color? primary,
    Color? secondary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? shadow,
    Color? ink,
    Color? inkMuted,
    Color? inkFaint,
    Color? inkSubtle,
    Color? focus,
    Color? scrim,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? onLight,
    Color? onDark,
  }) {
    return NeoColors(
      brightness: brightness ?? this.brightness,
      yellow: yellow ?? this.yellow,
      pink: pink ?? this.pink,
      blue: blue ?? this.blue,
      green: green ?? this.green,
      teal: teal ?? this.teal,
      purple: purple ?? this.purple,
      orange: orange ?? this.orange,
      lime: lime ?? this.lime,
      red: red ?? this.red,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      inkSubtle: inkSubtle ?? this.inkSubtle,
      focus: focus ?? this.focus,
      scrim: scrim ?? this.scrim,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      onLight: onLight ?? this.onLight,
      onDark: onDark ?? this.onDark,
    );
  }

  static NeoColors lerp(NeoColors a, NeoColors b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return NeoColors(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      yellow: c(a.yellow, b.yellow),
      pink: c(a.pink, b.pink),
      blue: c(a.blue, b.blue),
      green: c(a.green, b.green),
      teal: c(a.teal, b.teal),
      purple: c(a.purple, b.purple),
      orange: c(a.orange, b.orange),
      lime: c(a.lime, b.lime),
      red: c(a.red, b.red),
      primary: c(a.primary, b.primary),
      secondary: c(a.secondary, b.secondary),
      success: c(a.success, b.success),
      warning: c(a.warning, b.warning),
      danger: c(a.danger, b.danger),
      info: c(a.info, b.info),
      background: c(a.background, b.background),
      surface: c(a.surface, b.surface),
      surfaceMuted: c(a.surfaceMuted, b.surfaceMuted),
      border: c(a.border, b.border),
      shadow: c(a.shadow, b.shadow),
      ink: c(a.ink, b.ink),
      inkMuted: c(a.inkMuted, b.inkMuted),
      inkFaint: c(a.inkFaint, b.inkFaint),
      inkSubtle: c(a.inkSubtle, b.inkSubtle),
      focus: c(a.focus, b.focus),
      scrim: c(a.scrim, b.scrim),
      skeletonBase: c(a.skeletonBase, b.skeletonBase),
      skeletonHighlight: c(a.skeletonHighlight, b.skeletonHighlight),
      onLight: c(a.onLight, b.onLight),
      onDark: c(a.onDark, b.onDark),
    );
  }

  List<Object> get _props => [
    brightness,
    yellow,
    pink,
    blue,
    green,
    teal,
    purple,
    orange,
    lime,
    red,
    primary,
    secondary,
    success,
    warning,
    danger,
    info,
    background,
    surface,
    surfaceMuted,
    border,
    shadow,
    ink,
    inkMuted,
    inkFaint,
    inkSubtle,
    focus,
    scrim,
    skeletonBase,
    skeletonHighlight,
    onLight,
    onDark,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NeoColors) return false;
    final a = _props;
    final b = other._props;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_props);
}
