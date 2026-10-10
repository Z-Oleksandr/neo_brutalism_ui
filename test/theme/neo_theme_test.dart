import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

void main() {
  NeoThemeData? resolved;
  final probe = Builder(
    builder: (context) {
      resolved = NeoTheme.of(context);
      return const SizedBox();
    },
  );

  setUp(() => resolved = null);

  testWidgets('falls back to light without any theme', (tester) async {
    await tester.pumpWidget(MaterialApp(home: probe));
    expect(resolved, NeoThemeData.fallbackLight);
  });

  testWidgets('falls back to dark for a dark Material theme', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: ThemeData.dark(), home: probe));
    expect(resolved, NeoThemeData.fallbackDark);
  });

  testWidgets('reads the ThemeExtension from toThemeData', (tester) async {
    final custom = NeoThemeData.light(
      colors: NeoColors.light().copyWith(primary: Colors.teal),
    );
    await tester.pumpWidget(
      MaterialApp(theme: custom.toThemeData(), home: probe),
    );
    expect(resolved!.colors.primary, Colors.teal);
  });

  testWidgets('a scoped NeoTheme wins over the extension', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NeoThemeData.light().toThemeData(),
        home: NeoTheme(data: NeoThemeData.dark(), child: probe),
      ),
    );
    expect(resolved!.brightness, Brightness.dark);
  });

  test('toThemeData maps tokens onto Material', () {
    final neo = NeoThemeData.dark();
    final theme = neo.toThemeData();
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, neo.colors.background);
    expect(theme.colorScheme.primary, neo.colors.primary);
    expect(theme.extension<NeoThemeData>(), neo);
  });

  test('lerp interpolates and keeps endpoints', () {
    final a = NeoThemeData.light();
    final b = NeoThemeData.dark();
    expect(a.lerp(b, 0), a);
    expect(a.lerp(b, 1).colors, b.colors);
    expect(a.lerp(null, 0.5), a);
  });

  test('decoration drops the shadow for Offset.zero', () {
    final theme = NeoThemeData.light();
    expect(theme.decoration().boxShadow, hasLength(1));
    expect(theme.decoration(shadow: Offset.zero).boxShadow, isNull);
  });

  test('copyWith replaces only the given group', () {
    final theme = NeoThemeData.light().copyWith(radii: const NeoRadii(md: 0));
    expect(theme.radii.md, 0);
    expect(theme.colors, NeoColors.light());
  });

  test('custom font family propagates to every style', () {
    final t = NeoTypography.standard(fontFamily: 'Space Grotesk');
    expect(t.display.fontFamily, 'Space Grotesk');
    expect(t.overline.fontFamily, 'Space Grotesk');
    expect(t.apply(fontFamily: 'Mono').body.fontFamily, 'Mono');
  });
}
