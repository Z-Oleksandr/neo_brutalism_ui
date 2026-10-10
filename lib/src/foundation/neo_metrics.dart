import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

double _lerp(double a, double b, double t) => lerpDouble(a, b, t)!;

@immutable
class NeoSpacing {
  const NeoSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  static NeoSpacing lerp(NeoSpacing a, NeoSpacing b, double t) => NeoSpacing(
    xs: _lerp(a.xs, b.xs, t),
    sm: _lerp(a.sm, b.sm, t),
    md: _lerp(a.md, b.md, t),
    lg: _lerp(a.lg, b.lg, t),
    xl: _lerp(a.xl, b.xl, t),
    xxl: _lerp(a.xxl, b.xxl, t),
  );

  @override
  bool operator ==(Object other) =>
      other is NeoSpacing &&
      other.xs == xs &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.xl == xl &&
      other.xxl == xxl;

  @override
  int get hashCode => Object.hash(xs, sm, md, lg, xl, xxl);
}

@immutable
class NeoRadii {
  const NeoRadii({this.sm = 4, this.md = 8, this.lg = 12});

  final double sm;
  final double md;
  final double lg;

  static NeoRadii lerp(NeoRadii a, NeoRadii b, double t) => NeoRadii(
    sm: _lerp(a.sm, b.sm, t),
    md: _lerp(a.md, b.md, t),
    lg: _lerp(a.lg, b.lg, t),
  );

  @override
  bool operator ==(Object other) =>
      other is NeoRadii && other.sm == sm && other.md == md && other.lg == lg;

  @override
  int get hashCode => Object.hash(sm, md, lg);
}

@immutable
class NeoBorders {
  const NeoBorders({this.thin = 1.5, this.regular = 2, this.thick = 3});

  final double thin;
  final double regular;
  final double thick;

  static NeoBorders lerp(NeoBorders a, NeoBorders b, double t) => NeoBorders(
    thin: _lerp(a.thin, b.thin, t),
    regular: _lerp(a.regular, b.regular, t),
    thick: _lerp(a.thick, b.thick, t),
  );

  @override
  bool operator ==(Object other) =>
      other is NeoBorders &&
      other.thin == thin &&
      other.regular == regular &&
      other.thick == thick;

  @override
  int get hashCode => Object.hash(thin, regular, thick);
}

/// Hard (zero blur) shadow offsets.
@immutable
class NeoShadows {
  const NeoShadows({
    this.sm = const Offset(2, 2),
    this.md = const Offset(4, 4),
    this.lg = const Offset(6, 6),
  });

  final Offset sm;
  final Offset md;
  final Offset lg;

  static NeoShadows lerp(NeoShadows a, NeoShadows b, double t) => NeoShadows(
    sm: Offset.lerp(a.sm, b.sm, t)!,
    md: Offset.lerp(a.md, b.md, t)!,
    lg: Offset.lerp(a.lg, b.lg, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is NeoShadows && other.sm == sm && other.md == md && other.lg == lg;

  @override
  int get hashCode => Object.hash(sm, md, lg);
}

@immutable
class NeoMotion {
  const NeoMotion({
    this.press = const Duration(milliseconds: 80),
    this.fast = const Duration(milliseconds: 150),
    this.medium = const Duration(milliseconds: 250),
    this.slow = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
  });

  final Duration press;
  final Duration fast;
  final Duration medium;
  final Duration slow;
  final Curve curve;

  @override
  bool operator ==(Object other) =>
      other is NeoMotion &&
      other.press == press &&
      other.fast == fast &&
      other.medium == medium &&
      other.slow == slow &&
      other.curve == curve;

  @override
  int get hashCode => Object.hash(press, fast, medium, slow, curve);
}
