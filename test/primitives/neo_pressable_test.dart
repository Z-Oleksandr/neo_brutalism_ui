import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

import '../helpers/pump.dart';

void main() {
  Widget surface({VoidCallback? onPressed, VoidCallback? onLongPress}) =>
      NeoPressableSurface(
        onPressed: onPressed,
        onLongPress: onLongPress,
        semanticLabel: 'Box',
        width: 24,
        height: 24,
        child: const SizedBox(),
      );

  testWidgets('calls onPressed on tap', (tester) async {
    var taps = 0;
    await pumpNeo(tester, surface(onPressed: () => taps++));
    await tester.tap(find.byType(NeoPressableSurface));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('calls onLongPress on long press', (tester) async {
    var longPresses = 0;
    await pumpNeo(tester, surface(onLongPress: () => longPresses++));
    await tester.longPress(find.byType(NeoPressableSurface));
    await tester.pumpAndSettle();
    expect(longPresses, 1);
  });

  testWidgets('grows a small visual to a 48dp tap target', (tester) async {
    await pumpNeo(tester, surface(onPressed: () {}));
    expect(tester.getSize(find.byType(NeoPressable)), const Size(48, 48));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  testWidgets('taps on the padded area still activate', (tester) async {
    var taps = 0;
    await pumpNeo(tester, surface(onPressed: () => taps++));
    final topLeft = tester.getTopLeft(find.byType(NeoPressable));
    await tester.tapAt(topLeft + const Offset(2, 2));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('disabled exposes disabled semantics and ignores taps', (
    tester,
  ) async {
    await pumpNeo(tester, surface());
    await tester.tap(find.byType(NeoPressableSurface), warnIfMissed: false);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Box')),
      matchesSemantics(label: 'Box', isButton: true, hasEnabledState: true),
    );
  });

  testWidgets('activates with keyboard Enter and Space when focused', (
    tester,
  ) async {
    var taps = 0;
    final node = FocusNode();
    addTearDown(node.dispose);
    await pumpNeo(
      tester,
      NeoPressableSurface(
        onPressed: () => taps++,
        focusNode: node,
        child: const Text('Go'),
      ),
    );
    node.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(taps, 2);
  });

  testWidgets('face travels onto the shadow while pressed', (tester) async {
    await pumpNeo(tester, surface(onPressed: () {}));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(NeoPressableSurface)),
    );
    await tester.pumpAndSettle();
    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(NeoPressableSurface),
        matching: find.byType(Transform),
      ),
    );
    expect(transform.transform.getTranslation().x, 4);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion skips the press animation', (tester) async {
    await pumpNeo(tester, surface(onPressed: () {}), disableAnimations: true);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(NeoPressableSurface)),
    );
    await tester.pump();
    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(NeoPressableSurface),
        matching: find.byType(Transform),
      ),
    );
    expect(transform.transform.getTranslation().x, 4);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('sunken keeps the pressed position', (tester) async {
    await pumpNeo(
      tester,
      NeoPressableSurface(
        onPressed: () {},
        sunken: true,
        child: const Text('Tab'),
      ),
    );
    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(NeoPressableSurface),
        matching: find.byType(Transform),
      ),
    );
    expect(transform.transform.getTranslation().x, 4);
  });

  testWidgets('NeoSurface sets legible foreground for its fill', (
    tester,
  ) async {
    final theme = NeoThemeData.dark();
    await pumpNeo(
      tester,
      NeoSurface(color: theme.colors.pink, child: const Text('Hi')),
      theme: theme,
    );
    final style = DefaultTextStyle.of(tester.element(find.text('Hi'))).style;
    expect(style.color, theme.colors.onColor(theme.colors.pink));
  });
}
