import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slab_ui/slab_ui.dart';

import '../helpers/pump.dart';

Future<void> _guidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

void main() {
  group('NeoCheckbox', () {
    testWidgets('toggles via the box and the label', (tester) async {
      final values = <bool?>[];
      await pumpNeo(
        tester,
        NeoCheckbox(value: false, label: 'Agree', onChanged: values.add),
      );
      await tester.tap(find.text('Agree'));
      await tester.pumpAndSettle();
      expect(values, [true]);
    });

    testWidgets('tristate cycles true to null to false', (tester) async {
      final values = <bool?>[];
      await pumpNeo(
        tester,
        NeoCheckbox(value: true, tristate: true, onChanged: values.add),
      );
      await tester.tap(find.byType(NeoCheckbox));
      await pumpNeo(
        tester,
        NeoCheckbox(value: null, tristate: true, onChanged: values.add),
      );
      await tester.tap(find.byType(NeoCheckbox));
      expect(values, [null, false]);
    });

    testWidgets('exposes checked and mixed semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpNeo(
        tester,
        NeoCheckbox(value: true, label: 'Agree', onChanged: (_) {}),
      );
      expect(
        tester.getSemantics(find.byType(NeoCheckbox)),
        matchesSemantics(
          label: 'Agree',
          hasCheckedState: true,
          isChecked: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      await pumpNeo(
        tester,
        NeoCheckbox(
          value: null,
          tristate: true,
          label: 'Some',
          onChanged: (_) {},
        ),
      );
      final data = tester
          .getSemantics(find.byType(NeoCheckbox))
          .getSemanticsData();
      expect(data.flagsCollection.isChecked, CheckedState.mixed);
      handle.dispose();
    });

    testWidgets('disabled ignores taps', (tester) async {
      await pumpNeo(
        tester,
        const NeoCheckbox(value: false, label: 'Off', onChanged: null),
      );
      await tester.tap(find.text('Off'), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Space toggles when focused', (tester) async {
      final values = <bool?>[];
      final node = FocusNode();
      addTearDown(node.dispose);
      await pumpNeo(
        tester,
        NeoCheckbox(value: false, focusNode: node, onChanged: values.add),
      );
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(values, [true]);
    });

    for (final dark in [false, true]) {
      testWidgets('guidelines (${dark ? 'dark' : 'light'})', (tester) async {
        await pumpNeo(
          tester,
          NeoCheckbox(value: true, label: 'Agree', onChanged: (_) {}),
          dark: dark,
        );
        await _guidelines(tester);
      });
    }
  });

  group('NeoRadio', () {
    testWidgets('selects its value only when not selected', (tester) async {
      final values = <String>[];
      await pumpNeo(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeoRadio<String>(
              value: 'a',
              groupValue: 'a',
              label: 'A',
              onChanged: values.add,
            ),
            NeoRadio<String>(
              value: 'b',
              groupValue: 'a',
              label: 'B',
              onChanged: values.add,
            ),
          ],
        ),
      );
      await tester.tap(find.text('A'));
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(values, ['b']);
    });

    testWidgets('semantics: checked in a mutually exclusive group', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpNeo(
        tester,
        NeoRadio<int>(value: 1, groupValue: 1, label: 'One', onChanged: (_) {}),
      );
      final flags = tester
          .getSemantics(find.byType(NeoRadio<int>))
          .getSemanticsData()
          .flagsCollection;
      expect(flags.isChecked, CheckedState.isTrue);
      expect(flags.isInMutuallyExclusiveGroup, isTrue);
      handle.dispose();
    });

    for (final dark in [false, true]) {
      testWidgets('guidelines (${dark ? 'dark' : 'light'})', (tester) async {
        await pumpNeo(
          tester,
          NeoRadio<int>(
            value: 1,
            groupValue: 1,
            label: 'One',
            onChanged: (_) {},
          ),
          dark: dark,
        );
        await _guidelines(tester);
      });
    }
  });

  group('NeoSwitch', () {
    testWidgets('toggles and slides the thumb', (tester) async {
      var value = false;
      await pumpNeo(
        tester,
        StatefulBuilder(
          builder: (context, setState) => NeoSwitch(
            value: value,
            label: 'Wifi',
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      );
      await tester.tap(find.byType(NeoSwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      final align = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(align.alignment, AlignmentDirectional.centerEnd);
    });

    testWidgets('exposes toggled semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpNeo(
        tester,
        NeoSwitch(value: true, label: 'Wifi', onChanged: (_) {}),
      );
      final flags = tester
          .getSemantics(find.byType(NeoSwitch))
          .getSemanticsData()
          .flagsCollection;
      expect(flags.isToggled, Tristate.isTrue);
      handle.dispose();
    });

    testWidgets('disabled does not toggle', (tester) async {
      await pumpNeo(tester, const NeoSwitch(value: false, onChanged: null));
      await tester.tap(find.byType(NeoSwitch), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    for (final dark in [false, true]) {
      testWidgets('guidelines (${dark ? 'dark' : 'light'})', (tester) async {
        await pumpNeo(
          tester,
          NeoSwitch(value: true, label: 'Wifi', onChanged: (_) {}),
          dark: dark,
        );
        await _guidelines(tester);
      });
    }
  });

  group('NeoChip', () {
    testWidgets('selecting reports the toggled value', (tester) async {
      final values = <bool>[];
      await pumpNeo(tester, NeoChip(label: 'Music', onSelected: values.add));
      await tester.tap(find.text('Music'));
      await tester.pumpAndSettle();
      expect(values, [true]);
    });

    testWidgets('delete fires onDeleted only', (tester) async {
      final handle = tester.ensureSemantics();
      var deleted = 0;
      final selections = <bool>[];
      await pumpNeo(
        tester,
        NeoChip(
          label: 'Tag',
          onSelected: selections.add,
          onDeleted: () => deleted++,
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Tag')), findsWidgets);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(deleted, 1);
      expect(selections, isEmpty);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('selected chip exposes selected semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpNeo(
        tester,
        NeoChip(label: 'On', selected: true, onSelected: (_) {}),
      );
      final flags = tester
          .getSemantics(find.byType(NeoChip))
          .getSemanticsData()
          .flagsCollection;
      expect(flags.isSelected, Tristate.isTrue);
      handle.dispose();
    });

    for (final dark in [false, true]) {
      testWidgets('contrast (${dark ? 'dark' : 'light'})', (tester) async {
        await pumpNeo(
          tester,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoChip(label: 'On', selected: true, onSelected: (_) {}),
              NeoChip(label: 'Off', onSelected: (_) {}),
              NeoChip(label: 'Static', onDeleted: () {}),
            ],
          ),
          dark: dark,
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      });
    }
  });

  group('NeoSlider', () {
    Future<List<double>> pumpSlider(
      WidgetTester tester, {
      double value = 0.5,
      double min = 0,
      double max = 1,
      int? divisions,
      bool enabled = true,
      List<String>? events,
      TextDirection textDirection = TextDirection.ltr,
    }) async {
      final values = <double>[];
      await pumpNeo(
        tester,
        SizedBox(
          width: 224,
          child: NeoSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: 'Volume',
            onChanged: enabled ? values.add : null,
            onChangeStart: (_) => events?.add('start'),
            onChangeEnd: (_) => events?.add('end'),
          ),
        ),
        textDirection: textDirection,
      );
      return values;
    }

    testWidgets('tap at the ends maps to min and max', (tester) async {
      final values = await pumpSlider(tester);
      final rect = tester.getRect(find.byType(NeoSlider));
      await tester.tapAt(rect.centerLeft + const Offset(1, 0));
      await tester.tapAt(rect.centerRight - const Offset(1, 0));
      expect(values, [0, 1]);
    });

    testWidgets('thumb center tracks the finger', (tester) async {
      final values = await pumpSlider(tester);
      final rect = tester.getRect(find.byType(NeoSlider));
      await tester.tapAt(Offset(rect.left + 12 + 50, rect.center.dy));
      expect(values.single, closeTo(0.25, 0.001));
    });

    testWidgets('divisions snap relative to min', (tester) async {
      final values = await pumpSlider(
        tester,
        value: 5,
        min: 5,
        max: 25,
        divisions: 2,
      );
      final rect = tester.getRect(find.byType(NeoSlider));
      await tester.tapAt(Offset(rect.left + 12 + 110, rect.center.dy));
      await tester.tapAt(Offset(rect.left + 12 + 150, rect.center.dy));
      expect(values, [15, 25]);
    });

    testWidgets('drag reports start, changes and end', (tester) async {
      final events = <String>[];
      final values = await pumpSlider(tester, events: events);
      await tester.drag(find.byType(NeoSlider), const Offset(300, 0));
      expect(events.first, 'start');
      expect(events.last, 'end');
      expect(values.last, 1);
    });

    testWidgets('RTL maps the left edge to max', (tester) async {
      final values = await pumpSlider(tester, textDirection: TextDirection.rtl);
      final rect = tester.getRect(find.byType(NeoSlider));
      await tester.tapAt(rect.centerLeft + const Offset(1, 0));
      expect(values, [1]);
    });

    testWidgets('arrow keys step by a division', (tester) async {
      final values = await pumpSlider(tester, divisions: 4);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      expect(values, [0.75, 0.25]);
    });

    testWidgets('semantics increase and decrease actions', (tester) async {
      final handle = tester.ensureSemantics();
      final values = await pumpSlider(tester, divisions: 10);
      final node = tester.getSemantics(find.byType(NeoSlider));
      expect(node.getSemanticsData().value, '50%');
      final owner = node.owner!;
      owner.performAction(node.id, SemanticsAction.increase);
      owner.performAction(node.id, SemanticsAction.decrease);
      expect(values, [0.6, 0.4]);
      handle.dispose();
    });

    testWidgets('disabled ignores input', (tester) async {
      final values = await pumpSlider(tester, enabled: false);
      await tester.drag(find.byType(NeoSlider), const Offset(100, 0));
      expect(values, isEmpty);
    });
  });
}
