import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slab_ui/slab_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget home) => tester.pumpWidget(
    MaterialApp(
      theme: NeoThemeData.light().toThemeData(
        base: ThemeData(fontFamily: 'Brand'),
      ),
      home: Scaffold(body: home),
    ),
  );

  String? familyOf(WidgetTester tester, String text) {
    final element = tester.element(find.text(text));
    final widget = element.widget as Text;
    return DefaultTextStyle.of(element).style.merge(widget.style).fontFamily;
  }

  testWidgets('in-tree components keep the app font', (tester) async {
    await pump(
      tester,
      Column(
        children: [
          NeoListTile(
            title: const Text('Tile'),
            subtitle: const Text('Sub'),
            onTap: () {},
          ),
          const NeoExpansionPanel(title: Text('Panel'), child: Text('Body')),
          NeoButton(label: 'Button', onPressed: () {}),
        ],
      ),
    );
    for (final text in ['Tile', 'Sub', 'Panel', 'Button']) {
      expect(familyOf(tester, text), 'Brand', reason: text);
    }
  });

  testWidgets('overlays keep the app font', (tester) async {
    await pump(
      tester,
      Builder(
        builder: (context) => NeoButton(
          label: 'Open',
          onPressed: () => showNeoDialog<void>(
            context: context,
            builder: (_) => const NeoDialog(title: 'Title'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(familyOf(tester, 'Title'), 'Brand');
  });
}
