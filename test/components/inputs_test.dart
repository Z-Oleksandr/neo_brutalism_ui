import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slab_ui/slab_ui.dart';

import '../helpers/pump.dart';

Widget _sized(Widget child) => SizedBox(width: 320, child: child);

BoxDecoration _fieldDecoration(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(NeoTextField),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  group('NeoTextField', () {
    testWidgets('reports changes and submitted value', (tester) async {
      final changes = <String>[];
      String? submitted;
      await pumpNeo(
        tester,
        _sized(
          NeoTextField(
            hintText: 'Name',
            onChanged: changes.add,
            onSubmitted: (v) => submitted = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Ada');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(changes.last, 'Ada');
      expect(submitted, 'Ada');
    });

    testWidgets('shows label, helper and replaces helper with error', (
      tester,
    ) async {
      await pumpNeo(
        tester,
        _sized(
          const NeoTextField(label: 'Email', helperText: 'We never share it'),
        ),
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('We never share it'), findsOneWidget);

      await pumpNeo(
        tester,
        _sized(
          const NeoTextField(
            label: 'Email',
            helperText: 'We never share it',
            errorText: 'Invalid email',
          ),
        ),
      );
      expect(find.text('Invalid email'), findsOneWidget);
      expect(find.text('We never share it'), findsNothing);
      final border = _fieldDecoration(tester).border! as Border;
      expect(border.top.color, NeoColors.light().danger);
    });

    testWidgets('exposes the label to screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpNeo(tester, _sized(const NeoTextField(label: 'Email')));
      expect(find.bySemanticsLabel(RegExp('Email')), findsWidgets);
      handle.dispose();
    });

    testWidgets('focus colors the border and raises a shadow', (tester) async {
      await pumpNeo(tester, _sized(const NeoTextField(hintText: 'x')));
      final before = tester.getSize(find.byType(NeoTextField));
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      final decoration = _fieldDecoration(tester);
      final border = decoration.border! as Border;
      final theme = NeoThemeData.light();
      expect(border.top.color, theme.colors.focus);
      expect(border.top.width, theme.borders.regular);
      expect(decoration.boxShadow!.single.offset, theme.shadows.sm);
      expect(tester.getSize(find.byType(NeoTextField)), before);
    });

    for (final density in [VisualDensity.standard, VisualDensity.compact]) {
      testWidgets('icons do not change the field height at $density', (
        tester,
      ) async {
        Future<void> pumpField(Widget field) => tester.pumpWidget(
          MaterialApp(
            theme: NeoThemeData.light().toThemeData(
              base: ThemeData(visualDensity: density),
            ),
            home: Scaffold(body: Center(child: _sized(field))),
          ),
        );
        await pumpField(
          const NeoTextField(hintText: 'x', prefixIcon: Icons.person),
        );
        final plain = tester.getSize(find.byType(NeoTextField)).height;
        await pumpField(
          NeoTextField(
            hintText: 'x',
            prefixIcon: Icons.lock,
            suffix: NeoPressable(
              semanticLabel: 'Show',
              onPressed: () {},
              builder: (_, _, _) => const Icon(Icons.visibility),
            ),
          ),
        );
        expect(tester.getSize(find.byType(NeoTextField)).height, plain);
        await tester.tap(find.bySemanticsLabel('Show'));
      });
    }

    testWidgets('search field keeps its height when text is entered', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeoThemeData.light().toThemeData(
            base: ThemeData(visualDensity: VisualDensity.compact),
          ),
          home: Scaffold(body: Center(child: _sized(const NeoSearchField()))),
        ),
      );
      final empty = tester.getSize(find.byType(NeoSearchField)).height;
      await tester.enterText(find.byType(TextField), 'party');
      await tester.pump();
      expect(tester.getSize(find.byType(NeoSearchField)).height, empty);
    });

    testWidgets('icons do not change the field height', (tester) async {
      await pumpNeo(tester, _sized(const NeoTextField(hintText: 'x')));
      final plain = tester.getSize(find.byType(NeoTextField)).height;
      await pumpNeo(
        tester,
        _sized(
          NeoTextField(
            hintText: 'x',
            prefixIcon: Icons.lock,
            suffix: NeoPressable(
              semanticLabel: 'Show',
              onPressed: () {},
              builder: (_, _, _) => const Icon(Icons.visibility),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(NeoTextField)).height, plain);
    });

    testWidgets('maxLength enforces and counts', (tester) async {
      await pumpNeo(tester, _sized(const NeoTextField(maxLength: 5)));
      expect(find.text('0/5'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'abcdefgh');
      await tester.pump();
      expect(find.text('5/5'), findsOneWidget);
    });

    testWidgets('disabled cannot be edited', (tester) async {
      await pumpNeo(tester, _sized(const NeoTextField(enabled: false)));
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, false);
    });

    testWidgets('uses an external controller', (tester) async {
      final controller = TextEditingController(text: 'preset');
      addTearDown(controller.dispose);
      await pumpNeo(tester, _sized(NeoTextField(controller: controller)));
      expect(find.text('preset'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'new');
      expect(controller.text, 'new');
    });

    for (final dark in [false, true]) {
      testWidgets('meets text contrast (${dark ? 'dark' : 'light'})', (
        tester,
      ) async {
        await pumpNeo(
          tester,
          _sized(
            const NeoTextField(
              label: 'Label',
              hintText: 'Hint',
              helperText: 'Helper',
              errorText: 'Error',
            ),
          ),
          dark: dark,
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      });
    }

    testWidgets('survives 2x text scale', (tester) async {
      await pumpNeo(
        tester,
        _sized(
          const NeoTextField(
            label: 'A long label for the field',
            hintText: 'Hint text',
            helperText: 'Helper text that wraps',
            maxLength: 20,
            prefixIcon: Icons.mail,
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('NeoTextFormField', () {
    testWidgets('shows validator errors and clears them', (tester) async {
      final key = GlobalKey<FormState>();
      String? saved;
      await pumpNeo(
        tester,
        _sized(
          Form(
            key: key,
            child: NeoTextFormField(
              label: 'Name',
              validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
              onSaved: (v) => saved = v,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
          ),
        ),
      );
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Ada');
      await tester.pump();
      expect(find.text('Required'), findsNothing);
      expect(key.currentState!.validate(), isTrue);
      key.currentState!.save();
      expect(saved, 'Ada');
    });

    testWidgets('reset restores the initial value', (tester) async {
      final key = GlobalKey<FormState>();
      await pumpNeo(
        tester,
        _sized(
          Form(
            key: key,
            child: NeoTextFormField(initialValue: 'start'),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'changed');
      key.currentState!.reset();
      await tester.pump();
      expect(find.text('start'), findsOneWidget);
    });

    testWidgets('tracks an external controller', (tester) async {
      final key = GlobalKey<FormState>();
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpNeo(
        tester,
        _sized(
          Form(
            key: key,
            child: NeoTextFormField(
              controller: controller,
              validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
            ),
          ),
        ),
      );
      controller.text = 'set in code';
      expect(key.currentState!.validate(), isTrue);
    });
  });

  group('NeoSearchField', () {
    testWidgets('clear button appears, clears and notifies', (tester) async {
      final handle = tester.ensureSemantics();
      final changes = <String>[];
      var cleared = 0;
      await pumpNeo(
        tester,
        _sized(
          NeoSearchField(onChanged: changes.add, onCleared: () => cleared++),
        ),
      );
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.text('Search'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'party');
      await tester.pump();
      expect(find.bySemanticsLabel(RegExp('Clear')), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('party'), findsNothing);
      expect(changes.last, '');
      expect(cleared, 1);
      handle.dispose();
    });

    testWidgets('debounces onChanged', (tester) async {
      final changes = <String>[];
      await pumpNeo(
        tester,
        _sized(
          NeoSearchField(
            onChanged: changes.add,
            debounce: const Duration(milliseconds: 300),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump(const Duration(milliseconds: 100));
      expect(changes, isEmpty);
      await tester.pump(const Duration(milliseconds: 300));
      expect(changes, ['ab']);
    });

    testWidgets('submits the current value', (tester) async {
      String? submitted;
      await pumpNeo(
        tester,
        _sized(NeoSearchField(onSubmitted: (v) => submitted = v)),
      );
      await tester.enterText(find.byType(TextField), 'beach');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(submitted, 'beach');
    });

    testWidgets('clear button meets tap target guidelines', (tester) async {
      await pumpNeo(tester, _sized(const NeoSearchField()));
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });

  group('NeoDropdown', () {
    Widget dropdown({
      required String? value,
      ValueChanged<String>? onChanged,
    }) => NeoDropdown<String>(
      items: const ['Small', 'Medium', 'Large'],
      value: value,
      hint: 'Pick a size',
      labelBuilder: (s) => s,
      onChanged: onChanged,
    );

    testWidgets('shows the hint when empty', (tester) async {
      await pumpNeo(tester, dropdown(value: null, onChanged: (_) {}));
      expect(find.text('Pick a size'), findsOneWidget);
    });

    testWidgets('selects a different value', (tester) async {
      String? chosen;
      await pumpNeo(
        tester,
        dropdown(value: 'Small', onChanged: (v) => chosen = v),
      );
      await tester.tap(find.byType(NeoDropdown<String>));
      await tester.pumpAndSettle();
      expect(find.text('Large'), findsOneWidget);
      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();
      expect(chosen, 'Large');
      expect(find.text('Medium'), findsNothing);
    });

    testWidgets('reselecting the current value does not fire', (tester) async {
      var calls = 0;
      await pumpNeo(
        tester,
        dropdown(value: 'Small', onChanged: (_) => calls++),
      );
      await tester.tap(find.byType(NeoDropdown<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Small').last);
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('disabled does not open', (tester) async {
      await pumpNeo(tester, dropdown(value: 'Small'));
      await tester.tap(find.byType(NeoDropdown<String>), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Large'), findsNothing);
    });

    testWidgets('keyboard: arrows move, Enter selects, Escape closes', (
      tester,
    ) async {
      String? chosen;
      await pumpNeo(
        tester,
        dropdown(value: 'Small', onChanged: (v) => chosen = v),
      );
      await tester.tap(find.byType(NeoDropdown<String>));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(chosen, 'Medium');

      await tester.tap(find.byType(NeoDropdown<String>));
      await tester.pumpAndSettle();
      expect(find.text('Large'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Large'), findsNothing);
    });

    testWidgets('tapping outside dismisses with null', (tester) async {
      int? result = -1;
      await pumpNeo(
        tester,
        Builder(
          builder: (context) => NeoButton(
            label: 'Open',
            onPressed: () async {
              result = await showNeoMenu<int>(
                context: context,
                items: const [NeoMenuItem(value: 1, label: 'One')],
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('One'), findsNothing);
      expect(result, isNull);
    });

    testWidgets('flips above the anchor near the bottom edge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeoThemeData.light().toThemeData(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: dropdown(value: 'Small', onChanged: (_) {}),
            ),
          ),
        ),
      );
      final anchorTop = tester.getTopLeft(find.byType(NeoDropdown<String>)).dy;
      await tester.tap(find.byType(NeoDropdown<String>));
      await tester.pumpAndSettle();
      expect(tester.getBottomLeft(find.text('Large')).dy, lessThan(anchorTop));
    });

    for (final dark in [false, true]) {
      testWidgets('open menu meets contrast (${dark ? 'dark' : 'light'})', (
        tester,
      ) async {
        await pumpNeo(
          tester,
          dropdown(value: 'Small', onChanged: (_) {}),
          dark: dark,
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await tester.tap(find.byType(NeoDropdown<String>));
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      });
    }
  });
}
