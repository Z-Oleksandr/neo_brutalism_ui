import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slab_ui/slab_ui.dart';

import '../helpers/pump.dart';

void main() {
  group('NeoButton', () {
    testWidgets('renders label and fires onPressed', (tester) async {
      var taps = 0;
      await pumpNeo(tester, NeoButton(label: 'Save', onPressed: () => taps++));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('loading shows dots, keeps width and ignores taps', (
      tester,
    ) async {
      var taps = 0;
      await pumpNeo(tester, NeoButton(label: 'Save', onPressed: () => taps++));
      final width = tester.getSize(find.byType(NeoButton)).width;
      await pumpNeo(
        tester,
        NeoButton(label: 'Save', isLoading: true, onPressed: () => taps++),
      );
      expect(find.byType(NeoLoadingDots), findsOneWidget);
      expect(tester.getSize(find.byType(NeoButton)).width, width);
      await tester.tap(find.byType(NeoButton));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('disabled when no callbacks', (tester) async {
      await pumpNeo(tester, const NeoButton(label: 'Off'));
      final semantics = tester.getSemantics(find.text('Off'));
      expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
    });

    testWidgets('expanded fills the available width', (tester) async {
      await pumpNeo(
        tester,
        SizedBox(
          width: 300,
          child: NeoButton(label: 'Wide', expanded: true, onPressed: () {}),
        ),
      );
      expect(tester.getSize(find.byType(NeoButton)).width, 300);
    });

    for (final variant in NeoButtonVariant.values) {
      for (final dark in [false, true]) {
        testWidgets('${variant.name} ${dark ? 'dark' : 'light'} '
            'meets contrast and tap target guidelines', (tester) async {
          await pumpNeo(
            tester,
            NeoButton(
              label: 'Action',
              icon: Icons.add,
              variant: variant,
              onPressed: () {},
            ),
            dark: dark,
          );
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        });
      }
    }

    testWidgets('sizes grow in height', (tester) async {
      final heights = <double>[];
      for (final size in NeoButtonSize.values) {
        await pumpNeo(
          tester,
          NeoButton(label: 'A', size: size, onPressed: () {}),
        );
        final face = find.descendant(
          of: find.byType(NeoPressableSurface),
          matching: find.byType(Container),
        );
        heights.add(tester.getSize(face.first).height);
      }
      expect(
        heights[0] < heights[1] && heights[1] < heights[2],
        isTrue,
        reason: '$heights',
      );
    });

    testWidgets('survives 2x text scale without overflow', (tester) async {
      await pumpNeo(
        tester,
        SizedBox(
          width: 160,
          child: NeoButton(
            label: 'A rather long label',
            icon: Icons.check,
            onPressed: () {},
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('NeoIconButton', () {
    testWidgets('exposes its semantic label and fires', (tester) async {
      var taps = 0;
      await pumpNeo(
        tester,
        NeoIconButton(
          icon: Icons.close,
          semanticLabel: 'Close',
          onPressed: () => taps++,
        ),
      );
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      await tester.tap(find.byType(NeoIconButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });
  });

  group('display basics', () {
    testWidgets('NeoBadge caps the count and hides at zero', (tester) async {
      await pumpNeo(
        tester,
        const NeoBadge(count: 120, child: SizedBox(width: 24, height: 24)),
      );
      expect(find.text('99+'), findsOneWidget);
      await pumpNeo(
        tester,
        const NeoBadge(count: 0, child: SizedBox(width: 24, height: 24)),
      );
      expect(
        find.descendant(
          of: find.byType(NeoBadge),
          matching: find.byType(Stack),
        ),
        findsNothing,
      );
    });

    testWidgets('NeoTag uppercases by default', (tester) async {
      await pumpNeo(tester, const NeoTag(label: 'open'));
      expect(find.text('OPEN'), findsOneWidget);
    });

    testWidgets('NeoCard is pressable only with a callback', (tester) async {
      var taps = 0;
      await pumpNeo(tester, const NeoCard(child: Text('Static')));
      expect(find.byType(NeoPressable), findsNothing);
      await pumpNeo(
        tester,
        NeoCard(onTap: () => taps++, child: const Text('Tap')),
      );
      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('NeoBanner is a header', (tester) async {
      await pumpNeo(tester, const NeoBanner(text: 'Parties'));
      expect(
        tester.getSemantics(find.text('Parties')).flagsCollection.isHeader,
        isTrue,
      );
    });
  });
}
