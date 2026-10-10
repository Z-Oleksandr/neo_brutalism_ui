import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

void main() {
  group('NeoColors', () {
    for (final palette in [NeoColors.light(), NeoColors.dark()]) {
      final name = palette.brightness.name;

      test('$name: onColor meets WCAG AA on every accent and role', () {
        final fills = [
          ...palette.accents,
          palette.primary,
          palette.secondary,
          palette.success,
          palette.warning,
          palette.danger,
          palette.info,
        ];
        for (final fill in fills) {
          final ratio = NeoColors.contrastRatio(palette.onColor(fill), fill);
          expect(ratio, greaterThanOrEqualTo(4.5), reason: '$fill');
        }
      });

      test('$name: ink on surfaces meets WCAG AAA', () {
        for (final fill in [palette.surface, palette.background]) {
          expect(
            NeoColors.contrastRatio(palette.ink, fill),
            greaterThanOrEqualTo(7),
          );
        }
      });

      test('$name: onColor returns ink on surfaces', () {
        expect(palette.onColor(palette.surface), palette.ink);
        expect(palette.onColor(palette.background), palette.ink);
      });
    }

    test('contrastRatio is 21 for black on white', () {
      expect(
        NeoColors.contrastRatio(
          const Color(0xFF000000),
          const Color(0xFFFFFFFF),
        ),
        closeTo(21, 0.01),
      );
    });

    test('lerp returns endpoints at 0 and 1', () {
      final a = NeoColors.light();
      final b = NeoColors.dark();
      expect(NeoColors.lerp(a, b, 0), a);
      expect(NeoColors.lerp(a, b, 1), b);
    });

    test('copyWith overrides a single token', () {
      final c = NeoColors.light().copyWith(primary: const Color(0xFF123456));
      expect(c.primary, const Color(0xFF123456));
      expect(c.surface, NeoColors.light().surface);
      expect(c == NeoColors.light(), isFalse);
    });

    test('equal palettes share hashCode', () {
      expect(NeoColors.dark().hashCode, NeoColors.dark().hashCode);
    });
  });
}
