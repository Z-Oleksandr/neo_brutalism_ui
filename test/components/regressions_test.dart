import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slab_ui/slab_ui.dart';

import '../helpers/pump.dart';

void main() {
  testWidgets('a badged tab shares the width equally', (tester) async {
    await pumpNeo(
      tester,
      SizedBox(
        width: 360,
        child: NeoTabBar(
          onChanged: (_) {},
          tabs: const [
            NeoTab(label: 'Friends'),
            NeoTab(label: 'Requests', badgeCount: 4),
            NeoTab(label: 'Clubs'),
          ],
        ),
      ),
    );
    double widthOf(String label) => tester
        .getSize(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byType(NeoPressableSurface),
              )
              .first,
        )
        .width;
    expect(widthOf('Requests'), closeTo(widthOf('Friends'), 0.5));
  });

  testWidgets('scrollable tabs change selection and reveal the tab', (
    tester,
  ) async {
    var selected = 0;
    await pumpNeo(
      tester,
      StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 300,
          child: NeoTabBar(
            isScrollable: true,
            selectedIndex: selected,
            onChanged: (i) => setState(() => selected = i),
            tabs: [for (var i = 0; i < 12; i++) NeoTab(label: 'Tab $i')],
          ),
        ),
      ),
    );
    await tester.drag(find.text('Tab 0'), const Offset(-350, 0));
    await tester.pumpAndSettle();
    final partial = tester.getRect(find.text('Tab 5'));
    await tester.tapAt(partial.centerLeft + const Offset(4, 0));
    await tester.pumpAndSettle();
    expect(selected, 5);
    final bar = tester.getRect(find.byType(NeoTabBar));
    final tab = tester.getRect(find.text('Tab 5'));
    expect(bar.left <= tab.left && tab.right <= bar.right, isTrue);
  });

  testWidgets('app bar leading keeps its own height', (tester) async {
    await pumpNeo(
      tester,
      NeoAppBar(
        titleText: 'Title',
        leading: NeoIconButton(
          icon: Icons.arrow_back,
          size: 40,
          semanticLabel: 'Back',
          onPressed: () {},
        ),
      ),
    );
    final face = find.descendant(
      of: find.byType(NeoIconButton),
      matching: find.byType(Container),
    );
    expect(tester.getSize(face.first).height, 40);
  });

  testWidgets('menu entries never paint the outset focus ring', (tester) async {
    await pumpNeo(
      tester,
      NeoDropdown<int>(
        items: const [1, 2, 3],
        value: 2,
        labelBuilder: (v) => 'Item $v',
        onChanged: (_) {},
      ),
    );
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await tester.tap(find.text('Item 2'));
    await tester.pumpAndSettle();
    final entries = find.byWidgetPredicate(
      (w) => w is NeoPressable && !w.showFocusRing,
    );
    expect(entries, findsNWidgets(3));
  });

  testWidgets('confirm dialog does not autofocus its confirm button', (
    tester,
  ) async {
    await pumpNeo(
      tester,
      Builder(
        builder: (context) => NeoButton(
          label: 'Open',
          onPressed: () => showNeoConfirmDialog(
            context: context,
            title: 'Delete?',
            message: 'Sure?',
            confirmLabel: 'Delete',
            destructive: true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final confirm = tester.widget<NeoButton>(
      find.widgetWithText(NeoButton, 'Delete'),
    );
    expect(confirm.autofocus, isFalse);
  });

  group('NeoTimeSelector keyboard entry', () {
    Future<List<TimeOfDay>> pumpSelector(
      WidgetTester tester, {
      required bool h24,
      TimeOfDay initial = const TimeOfDay(hour: 9, minute: 30),
      int minuteInterval = 1,
    }) async {
      final changes = <TimeOfDay>[];
      var value = initial;
      await pumpNeo(
        tester,
        StatefulBuilder(
          builder: (context, setState) => NeoTimeSelector(
            value: value,
            use24HourFormat: h24,
            minuteInterval: minuteInterval,
            onChanged: (v) => setState(() {
              value = v;
              changes.add(v);
            }),
          ),
        ),
      );
      return changes;
    }

    testWidgets('typing an hour in 24h sets it', (tester) async {
      final changes = await pumpSelector(tester, h24: true);
      await tester.enterText(find.byType(TextField).first, '14');
      await tester.pump();
      expect(changes.last.hour, 14);
    });

    testWidgets('typing an hour in 12h keeps the period', (tester) async {
      final changes = await pumpSelector(
        tester,
        h24: false,
        initial: const TimeOfDay(hour: 15, minute: 0),
      );
      await tester.enterText(find.byType(TextField).first, '11');
      await tester.pump();
      expect(changes.last, const TimeOfDay(hour: 23, minute: 0));
    });

    testWidgets('invalid input is ignored and reverted on blur', (
      tester,
    ) async {
      final changes = await pumpSelector(tester, h24: true);
      await tester.enterText(find.byType(TextField).first, '77');
      await tester.pump();
      expect(changes, isEmpty);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(find.text('09'), findsOneWidget);
    });

    testWidgets('minutes snap to the interval when editing ends', (
      tester,
    ) async {
      final changes = await pumpSelector(tester, h24: true, minuteInterval: 15);
      await tester.enterText(find.byType(TextField).last, '40');
      await tester.pump();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(changes.last.minute, 30);
    });

    testWidgets('arrow keys step the focused field', (tester) async {
      final changes = await pumpSelector(tester, h24: true);
      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(changes.last.hour, 10);
      expect(find.text('10'), findsOneWidget);
    });
  });

  testWidgets('selected days keep two digits on one line when narrow', (
    tester,
  ) async {
    await pumpNeo(
      tester,
      SizedBox(
        width: 200,
        child: NeoCalendar.range(
          firstDate: DateTime(2026),
          lastDate: DateTime(2026, 12, 31),
          initialMonth: DateTime(2026, 10),
          rangeStart: DateTime(2026, 10, 14),
          rangeEnd: DateTime(2026, 10, 18),
          onRangeChanged: (_, _) {},
        ),
      ),
    );
    final natural = tester.getSize(find.text('15'));
    expect(tester.getSize(find.text('14')), natural);
    expect(tester.getSize(find.text('18')), natural);
  });
}
