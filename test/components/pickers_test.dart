import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slab_ui/slab_ui.dart';

import '../helpers/pump.dart';

final DateTime _today = DateTime(2026, 10, 10);
final DateTime _first = DateTime(2026);
final DateTime _last = DateTime(2027, 12, 31);

class _MondayFirst extends DefaultMaterialLocalizations {
  const _MondayFirst();

  @override
  int get firstDayOfWeekIndex => 1;
}

class _MondayFirstDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _MondayFirstDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture(const _MondayFirst());

  @override
  bool shouldReload(_MondayFirstDelegate old) => false;
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<Future<T?>> _open<T>(
  WidgetTester tester,
  Future<T?> Function(BuildContext context) open, {
  bool dark = false,
}) async {
  late Future<T?> result;
  await pumpNeo(
    tester,
    Builder(
      builder: (context) =>
          NeoButton(label: 'Open', onPressed: () => result = open(context)),
    ),
    dark: dark,
  );
  await tester.tap(find.text('Open'));
  await _settle(tester);
  return result;
}

Widget _calendar({
  DateTime? selected,
  ValueChanged<DateTime>? onSelected,
  DateTime? first,
  SelectableDayPredicate? predicate,
}) => SizedBox(
  width: 360,
  child: NeoCalendar(
    firstDate: first ?? _first,
    lastDate: _last,
    currentDate: _today,
    initialMonth: _today,
    selectedDate: selected,
    selectableDayPredicate: predicate,
    onDateSelected: onSelected ?? (_) {},
  ),
);

void main() {
  group('NeoCalendar helpers', () {
    test('leadingBlankDays follows the first day of the week', () {
      final october = DateTime(2026, 10);
      expect(NeoCalendar.leadingBlankDays(october, 0), 4);
      expect(NeoCalendar.leadingBlankDays(october, 1), 3);
      expect(NeoCalendar.leadingBlankDays(october, 6), 5);
      expect(NeoCalendar.leadingBlankDays(DateTime(2026, 11), 0), 0);
    });

    test('nextRange starts, completes with swap, then restarts', () {
      final a = DateTime(2026, 10, 20);
      final b = DateTime(2026, 10, 12);
      expect(NeoCalendar.nextRange(null, null, a), (a, null));
      expect(NeoCalendar.nextRange(a, null, b), (b, a));
      expect(NeoCalendar.nextRange(b, a, a), (a, null));
      expect(NeoCalendar.nextRange(a, null, a), (a, a));
    });

    test('NeoTimeSelector.snap rounds minutes down', () {
      expect(
        NeoTimeSelector.snap(const TimeOfDay(hour: 9, minute: 44), 15),
        const TimeOfDay(hour: 9, minute: 30),
      );
    });
  });

  group('NeoCalendar', () {
    testWidgets('shows the localized month title', (tester) async {
      await pumpNeo(tester, _calendar());
      expect(find.text('October 2026'), findsOneWidget);
    });

    testWidgets('respects firstDayOfWeekIndex from localizations', (
      tester,
    ) async {
      await pumpNeo(tester, _calendar());
      final sundayFirst = tester.getCenter(find.text('1')).dx;
      await tester.pumpWidget(
        MaterialApp(
          theme: NeoThemeData.light().toThemeData(),
          localizationsDelegates: const [
            _MondayFirstDelegate(),
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Scaffold(body: Center(child: _calendar())),
        ),
      );
      final mondayFirst = tester.getCenter(find.text('1')).dx;
      expect(sundayFirst - mondayFirst, closeTo(48, 0.5));
    });

    testWidgets('selects a day and exposes date semantics', (tester) async {
      DateTime? picked;
      await pumpNeo(
        tester,
        _calendar(
          selected: DateTime(2026, 10, 14),
          onSelected: (d) => picked = d,
        ),
      );
      final node = tester.getSemantics(
        find.bySemanticsLabel('Wednesday, October 14, 2026'),
      );
      expect(node.flagsCollection.isSelected, isNotNull);
      await tester.tap(find.text('21'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(picked, DateTime(2026, 10, 21));
    });

    testWidgets('days outside bounds or the predicate are disabled', (
      tester,
    ) async {
      final picked = <DateTime>[];
      await pumpNeo(
        tester,
        _calendar(
          first: DateTime(2026, 10, 10),
          predicate: (d) => d.weekday != DateTime.saturday,
          onSelected: picked.add,
        ),
      );
      await tester.tap(find.text('5'), warnIfMissed: false);
      await tester.tap(find.text('17'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));
      expect(picked, isEmpty);
      await tester.tap(find.text('16'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(picked, [DateTime(2026, 10, 16)]);
    });

    testWidgets('month navigation stops at the bounds', (tester) async {
      await pumpNeo(
        tester,
        SizedBox(
          width: 360,
          child: NeoCalendar(
            firstDate: DateTime(2026, 9, 15),
            lastDate: DateTime(2026, 11, 2),
            initialMonth: _today,
            onDateSelected: (_) {},
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('September 2026'), findsOneWidget);
      await tester.tap(
        find.bySemanticsLabel('Previous month'),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('September 2026'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('November 2026'), findsOneWidget);
    });

    testWidgets('range mode swaps an earlier second tap', (tester) async {
      DateTime? start;
      DateTime? end;
      await pumpNeo(
        tester,
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 360,
            child: NeoCalendar.range(
              firstDate: _first,
              lastDate: _last,
              initialMonth: _today,
              rangeStart: start,
              rangeEnd: end,
              onRangeChanged: (s, e) => setState(() {
                start = s;
                end = e;
              }),
            ),
          ),
        ),
      );
      await tester.tap(find.text('20'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('12'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(start, DateTime(2026, 10, 12));
      expect(end, DateTime(2026, 10, 20));
    });

    for (final dark in [false, true]) {
      testWidgets('meets contrast and tap target guidelines '
          '(${dark ? 'dark' : 'light'})', (tester) async {
        await pumpNeo(
          tester,
          _calendar(selected: DateTime(2026, 10, 14)),
          dark: dark,
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      });
    }
  });

  group('showNeoDatePicker', () {
    for (final dark in [false, true]) {
      testWidgets('returns the chosen date (${dark ? 'dark' : 'light'})', (
        tester,
      ) async {
        final result = await _open(
          tester,
          (context) => showNeoDatePicker(
            context: context,
            firstDate: _first,
            lastDate: _last,
            initialDate: _today,
            currentDate: _today,
          ),
          dark: dark,
        );
        await tester.pump();
        await tester.tap(find.text('14'));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.tap(find.text('OK'));
        await _settle(tester);
        expect(await result, DateTime(2026, 10, 14));
      });
    }

    testWidgets('cancel returns null', (tester) async {
      final result = await _open(
        tester,
        (context) => showNeoDatePicker(
          context: context,
          firstDate: _first,
          lastDate: _last,
          initialDate: _today,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await _settle(tester);
      expect(await result, isNull);
      expect(find.byType(NeoCalendar), findsNothing);
    });

    testWidgets('barrier tap returns null', (tester) async {
      final result = await _open(
        tester,
        (context) => showNeoDatePicker(
          context: context,
          firstDate: _first,
          lastDate: _last,
        ),
      );
      await tester.pump();
      expect(find.byType(NeoCalendar), findsOneWidget);
      await tester.tapAt(const Offset(4, 4));
      await _settle(tester);
      expect(await result, isNull);
    });

    testWidgets('OK is disabled until a date is chosen', (tester) async {
      await _open(
        tester,
        (context) => showNeoDatePicker(
          context: context,
          firstDate: _first,
          lastDate: _last,
          currentDate: _today,
        ),
      );
      await tester.pump();
      final ok = tester.widget<NeoButton>(find.widgetWithText(NeoButton, 'OK'));
      expect(ok.onPressed, isNull);
    });
  });

  group('showNeoTimePicker', () {
    testWidgets('24-hour steppers change the hour', (tester) async {
      final result = await _open(
        tester,
        (context) => showNeoTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 13, minute: 5),
          use24HourFormat: true,
        ),
      );
      await tester.pump();
      expect(find.text('13'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.keyboard_arrow_up).first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down).last);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('OK'));
      await _settle(tester);
      expect(await result, const TimeOfDay(hour: 14, minute: 4));
    });

    testWidgets('12-hour shows the period and toggles it', (tester) async {
      final result = await _open(
        tester,
        (context) => showNeoTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 13, minute: 5),
          use24HourFormat: false,
        ),
      );
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('PM'), findsOneWidget);
      await tester.tap(find.text('AM'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('OK'));
      await _settle(tester);
      expect(await result, const TimeOfDay(hour: 1, minute: 5));
    });

    testWidgets('minute interval snaps and steps', (tester) async {
      final result = await _open(
        tester,
        (context) => showNeoTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 9, minute: 7),
          minuteInterval: 15,
          use24HourFormat: true,
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.keyboard_arrow_up).last);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('OK'));
      await _settle(tester);
      expect(await result, const TimeOfDay(hour: 9, minute: 15));
    });

    testWidgets('long press repeats steps', (tester) async {
      final result = await _open(
        tester,
        (context) => showNeoTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 0, minute: 0),
          use24HourFormat: true,
        ),
      );
      await tester.pump();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.keyboard_arrow_up).last),
      );
      await tester.pump(const Duration(milliseconds: 600));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('OK'));
      await _settle(tester);
      expect((await result)!.minute, greaterThan(2));
    });

    testWidgets('steppers are adjustable for screen readers', (tester) async {
      await _open(
        tester,
        (context) => showNeoTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 8, minute: 30),
          use24HourFormat: true,
        ),
      );
      await tester.pump();
      final node = tester.getSemantics(find.bySemanticsLabel('Hour'));
      expect(node.value, '08');
      expect(node.increasedValue, '09');
    });
  });

  group('showNeoDateTimePicker', () {
    testWidgets('date step then time step returns the combination', (
      tester,
    ) async {
      final result = await _open(
        tester,
        (context) => showNeoDateTimePicker(
          context: context,
          firstDate: _first,
          lastDate: _last,
          initialDateTime: DateTime(2026, 10, 10, 18, 30),
          currentDate: _today,
          use24HourFormat: true,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('14'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Continue'));
      await _settle(tester);
      expect(find.byType(NeoTimeSelector), findsOneWidget);
      await tester.tap(find.byIcon(Icons.keyboard_arrow_up).first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('OK'));
      await _settle(tester);
      expect(await result, DateTime(2026, 10, 14, 19, 30));
    });

    testWidgets('back returns to the calendar', (tester) async {
      await _open(
        tester,
        (context) => showNeoDateTimePicker(
          context: context,
          firstDate: _first,
          lastDate: _last,
          initialDateTime: _today,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await _settle(tester);
      await tester.tap(find.text('Back'));
      await _settle(tester);
      expect(find.byType(NeoCalendar), findsOneWidget);
    });

    testWidgets('out-of-range time disables OK and explains why', (
      tester,
    ) async {
      await _open(
        tester,
        (context) => showNeoDateTimePicker(
          context: context,
          firstDate: _first,
          lastDate: DateTime(2026, 10, 10, 12),
          initialDateTime: DateTime(2026, 10, 10, 13),
          use24HourFormat: true,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await _settle(tester);
      final ok = tester.widget<NeoButton>(find.widgetWithText(NeoButton, 'OK'));
      expect(ok.onPressed, isNull);
      expect(find.text('Enter a valid time'), findsOneWidget);
    });
  });

  group('showNeoDateRangePicker', () {
    for (final dark in [false, true]) {
      testWidgets('returns an ordered range (${dark ? 'dark' : 'light'})', (
        tester,
      ) async {
        final result = await _open(
          tester,
          (context) => showNeoDateRangePicker(
            context: context,
            firstDate: _first,
            lastDate: _last,
            currentDate: _today,
          ),
          dark: dark,
        );
        await tester.pump();
        await tester.tap(find.text('20'));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.tap(find.text('12'));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.tap(find.text('OK'));
        await _settle(tester);
        expect(
          await result,
          DateTimeRange(
            start: DateTime(2026, 10, 12),
            end: DateTime(2026, 10, 20),
          ),
        );
      });
    }

    testWidgets('fits at 2x text scale on a small phone', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpNeo(
        tester,
        Builder(
          builder: (context) => NeoButton(
            label: 'Open',
            onPressed: () => showNeoDateRangePicker(
              context: context,
              firstDate: _first,
              lastDate: _last,
              currentDate: _today,
            ),
          ),
        ),
        textScale: 2,
      );
      await tester.tap(find.text('Open'));
      await _settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(NeoCalendar), findsOneWidget);
    });
  });
}
