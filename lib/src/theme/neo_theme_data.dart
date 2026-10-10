import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../foundation/neo_colors.dart';
import '../foundation/neo_metrics.dart';
import '../foundation/neo_typography.dart';

/// All design tokens of the neobrutalism theme.
///
/// Install it with [NeoTheme], or as a [ThemeExtension] via [toThemeData].
@immutable
class NeoThemeData extends ThemeExtension<NeoThemeData> {
  const NeoThemeData({
    required this.colors,
    required this.typography,
    this.spacing = const NeoSpacing(),
    this.radii = const NeoRadii(),
    this.borders = const NeoBorders(),
    this.shadows = const NeoShadows(),
    this.motion = const NeoMotion(),
  });

  factory NeoThemeData.light({
    NeoColors? colors,
    NeoTypography? typography,
    String? fontFamily,
  }) => NeoThemeData(
    colors: colors ?? NeoColors.light(),
    typography: typography ?? NeoTypography.standard(fontFamily: fontFamily),
  );

  factory NeoThemeData.dark({
    NeoColors? colors,
    NeoTypography? typography,
    String? fontFamily,
  }) => NeoThemeData(
    colors: colors ?? NeoColors.dark(),
    typography: typography ?? NeoTypography.standard(fontFamily: fontFamily),
  );

  static final NeoThemeData fallbackLight = NeoThemeData.light();
  static final NeoThemeData fallbackDark = NeoThemeData.dark();

  final NeoColors colors;
  final NeoTypography typography;
  final NeoSpacing spacing;
  final NeoRadii radii;
  final NeoBorders borders;
  final NeoShadows shadows;
  final NeoMotion motion;

  Brightness get brightness => colors.brightness;

  /// A bordered box with a hard shadow. Pass [shadow] as [Offset.zero] to
  /// drop the shadow.
  BoxDecoration decoration({
    Color? color,
    double? radius,
    double? borderWidth,
    Color? borderColor,
    Offset? shadow,
  }) {
    final offset = shadow ?? shadows.md;
    return BoxDecoration(
      color: color ?? colors.surface,
      border: Border.all(
        color: borderColor ?? colors.border,
        width: borderWidth ?? borders.thick,
      ),
      borderRadius: BorderRadius.circular(radius ?? radii.md),
      boxShadow: offset == Offset.zero
          ? null
          : [BoxShadow(color: colors.shadow, offset: offset)],
    );
  }

  /// A Material [ThemeData] derived from this theme that also carries it as
  /// an extension.
  ThemeData toThemeData({ThemeData? base}) {
    final c = colors;
    final scheme = ColorScheme(
      brightness: c.brightness,
      primary: c.primary,
      onPrimary: c.onColor(c.primary),
      secondary: c.secondary,
      onSecondary: c.onColor(c.secondary),
      error: c.danger,
      onError: c.onColor(c.danger),
      surface: c.surface,
      onSurface: c.ink,
      outline: c.border,
      shadow: c.shadow,
      scrim: c.scrim,
    );
    final start =
        base ??
        ThemeData(
          brightness: c.brightness,
          colorScheme: scheme,
          fontFamily: typography.body.fontFamily,
        );
    return start.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      splashFactory: NoSplash.splashFactory,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.ink,
        selectionColor: c.primary.withValues(alpha: 0.5),
        selectionHandleColor: c.ink,
      ),
      cupertinoOverrideTheme: toCupertinoThemeData(),
      extensions: [...start.extensions.values, this],
    );
  }

  CupertinoThemeData toCupertinoThemeData() => CupertinoThemeData(
    brightness: colors.brightness,
    primaryColor: colors.ink,
    scaffoldBackgroundColor: colors.background,
    barBackgroundColor: colors.surface,
  );

  @override
  NeoThemeData copyWith({
    NeoColors? colors,
    NeoTypography? typography,
    NeoSpacing? spacing,
    NeoRadii? radii,
    NeoBorders? borders,
    NeoShadows? shadows,
    NeoMotion? motion,
  }) {
    return NeoThemeData(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      radii: radii ?? this.radii,
      borders: borders ?? this.borders,
      shadows: shadows ?? this.shadows,
      motion: motion ?? this.motion,
    );
  }

  @override
  NeoThemeData lerp(covariant NeoThemeData? other, double t) {
    if (other == null) return this;
    return NeoThemeData(
      colors: NeoColors.lerp(colors, other.colors, t),
      typography: NeoTypography.lerp(typography, other.typography, t),
      spacing: NeoSpacing.lerp(spacing, other.spacing, t),
      radii: NeoRadii.lerp(radii, other.radii, t),
      borders: NeoBorders.lerp(borders, other.borders, t),
      shadows: NeoShadows.lerp(shadows, other.shadows, t),
      motion: t < 0.5 ? motion : other.motion,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NeoThemeData &&
      other.colors == colors &&
      other.typography == typography &&
      other.spacing == spacing &&
      other.radii == radii &&
      other.borders == borders &&
      other.shadows == shadows &&
      other.motion == motion;

  @override
  int get hashCode =>
      Object.hash(colors, typography, spacing, radii, borders, shadows, motion);
}
