import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Text style scale. Styles carry no color; components apply ink colors.
@immutable
class NeoTypography {
  const NeoTypography({
    required this.display,
    required this.headline,
    required this.title,
    required this.titleSmall,
    required this.body,
    required this.bodyStrong,
    required this.label,
    required this.caption,
    required this.overline,
  });

  factory NeoTypography.standard({
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    TextStyle s(double size, FontWeight weight, {double? height, double? ls}) =>
        TextStyle(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: ls,
        );
    return NeoTypography(
      display: s(32, FontWeight.w900, height: 1.1),
      headline: s(24, FontWeight.w900, height: 1.2, ls: 0.5),
      title: s(20, FontWeight.w900, height: 1.25),
      titleSmall: s(16, FontWeight.w800, height: 1.3),
      body: s(14, FontWeight.w500, height: 1.4),
      bodyStrong: s(14, FontWeight.w700, height: 1.4),
      label: s(14, FontWeight.w800, height: 1.2),
      caption: s(12, FontWeight.w600, height: 1.3),
      overline: s(10, FontWeight.w800, height: 1.2, ls: 0.6),
    );
  }

  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle titleSmall;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle overline;

  NeoTypography apply({String? fontFamily, List<String>? fontFamilyFallback}) {
    TextStyle a(TextStyle s) =>
        s.apply(fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback);
    return NeoTypography(
      display: a(display),
      headline: a(headline),
      title: a(title),
      titleSmall: a(titleSmall),
      body: a(body),
      bodyStrong: a(bodyStrong),
      label: a(label),
      caption: a(caption),
      overline: a(overline),
    );
  }

  static NeoTypography lerp(NeoTypography a, NeoTypography b, double t) {
    TextStyle l(TextStyle x, TextStyle y) => TextStyle.lerp(x, y, t)!;
    return NeoTypography(
      display: l(a.display, b.display),
      headline: l(a.headline, b.headline),
      title: l(a.title, b.title),
      titleSmall: l(a.titleSmall, b.titleSmall),
      body: l(a.body, b.body),
      bodyStrong: l(a.bodyStrong, b.bodyStrong),
      label: l(a.label, b.label),
      caption: l(a.caption, b.caption),
      overline: l(a.overline, b.overline),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NeoTypography &&
      other.display == display &&
      other.headline == headline &&
      other.title == title &&
      other.titleSmall == titleSmall &&
      other.body == body &&
      other.bodyStrong == bodyStrong &&
      other.label == label &&
      other.caption == caption &&
      other.overline == overline;

  @override
  int get hashCode => Object.hash(
    display,
    headline,
    title,
    titleSmall,
    body,
    bodyStrong,
    label,
    caption,
    overline,
  );
}
