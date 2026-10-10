import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

import '../helpers/pump.dart';

Future<BuildContext> _host(WidgetTester tester, {bool dark = false}) async {
  late BuildContext captured;
  await pumpNeo(
    tester,
    Builder(
      builder: (context) {
        captured = context;
        return const SizedBox();
      },
    ),
    dark: dark,
  );
  return captured;
}

void main() {
  group('showNeoDialog', () {
    testWidgets('returns the popped value', (tester) async {
      final context = await _host(tester);
      final result = showNeoDialog<int>(
        context: context,
        builder: (context) => NeoDialog(
          title: 'Pick',
          message: 'Choose one',
          actions: [
            NeoButton(
              label: 'Seven',
              onPressed: () => Navigator.of(context).pop(7),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Choose one'), findsOneWidget);
      await tester.tap(find.text('Seven'));
      await tester.pumpAndSettle();
      expect(await result, 7);
    });

    testWidgets('barrier tap dismisses with null', (tester) async {
      final context = await _host(tester);
      final result = showNeoDialog<int>(
        context: context,
        builder: (_) => const NeoDialog(title: 'Hi'),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('Hi'), findsNothing);
      expect(await result, isNull);
    });

    testWidgets('non-dismissible barrier keeps the dialog', (tester) async {
      final context = await _host(tester);
      showNeoDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const NeoDialog(title: 'Stay'),
      ).ignore();
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('Stay'), findsOneWidget);
    });

    testWidgets('keeps a scoped NeoTheme inside the route', (tester) async {
      late BuildContext context;
      final custom = NeoThemeData.light().copyWith(
        colors: NeoColors.light().copyWith(surface: const Color(0xFF00FF00)),
      );
      await pumpNeo(
        tester,
        NeoTheme(
          data: custom,
          child: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      NeoThemeData? inside;
      showNeoDialog<void>(
        context: context,
        builder: (c) {
          inside = NeoTheme.of(c);
          return const NeoDialog(title: 'Themed');
        },
      ).ignore();
      await tester.pumpAndSettle();
      expect(inside, custom);
    });

    testWidgets('appears instantly with reduced motion', (tester) async {
      final context = await _host(tester);
      await pumpNeo(
        tester,
        Builder(
          builder: (c) {
            return NeoButton(
              label: 'Open',
              onPressed: () => showNeoDialog<void>(
                context: c,
                builder: (_) => const NeoDialog(title: 'Fast'),
              ),
            );
          },
        ),
        disableAnimations: true,
      );
      expect(context, isNotNull);
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Fast'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('showNeoConfirmDialog', () {
    for (final dark in [false, true]) {
      testWidgets('confirm resolves true (${dark ? 'dark' : 'light'})', (
        tester,
      ) async {
        final context = await _host(tester, dark: dark);
        final result = showNeoConfirmDialog(
          context: context,
          title: 'Delete post?',
          message: 'This cannot be undone.',
          confirmLabel: 'Delete',
          destructive: true,
        );
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        expect(await result, isTrue);
      });
    }

    testWidgets('cancel and barrier resolve false', (tester) async {
      final context = await _host(tester);
      var result = showNeoConfirmDialog(context: context, title: 'Leave?');
      await tester.pumpAndSettle();
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await result, isFalse);

      result = showNeoConfirmDialog(context: context, title: 'Leave?');
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(await result, isFalse);
    });

    testWidgets('destructive confirm uses the danger color', (tester) async {
      final context = await _host(tester);
      showNeoConfirmDialog(
        context: context,
        title: 'Remove?',
        confirmLabel: 'Remove',
        destructive: true,
      ).ignore();
      await tester.pumpAndSettle();
      final button = tester.widget<NeoButton>(
        find.ancestor(
          of: find.text('Remove'),
          matching: find.byType(NeoButton),
        ),
      );
      expect(button.color, NeoColors.light().danger);
      expect(button.autofocus, isTrue);
    });
  });

  group('bottom sheets', () {
    testWidgets('showNeoBottomSheet shows content and returns', (tester) async {
      final context = await _host(tester);
      final result = showNeoBottomSheet<String>(
        context: context,
        builder: (context) => NeoBottomSheet(
          title: 'Sheet',
          child: NeoButton(
            label: 'Done',
            onPressed: () => Navigator.of(context).pop('done'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sheet'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(await result, 'done');
    });

    testWidgets('action sheet returns the chosen value', (tester) async {
      final context = await _host(tester);
      final result = showNeoActionSheet<String>(
        context: context,
        title: 'Message',
        actions: const [
          NeoSheetAction(label: 'Edit', value: 'edit', icon: Icons.edit),
          NeoSheetAction(label: 'Delete', value: 'delete', destructive: true),
        ],
      );
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(await result, 'delete');
    });

    testWidgets('action sheet cancel returns null', (tester) async {
      final context = await _host(tester, dark: true);
      final result = showNeoActionSheet<String>(
        context: context,
        actions: const [NeoSheetAction(label: 'Edit', value: 'edit')],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await result, isNull);
    });
  });

  group('showNeoToast', () {
    testWidgets('auto dismisses after its duration', (tester) async {
      final context = await _host(tester);
      final handle = showNeoToast(
        context,
        message: 'Saved',
        type: NeoToastType.success,
        duration: const Duration(seconds: 2),
      );
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsNothing);
      expect(handle.isClosed, isTrue);
    });

    testWidgets('queues toasts one at a time', (tester) async {
      final context = await _host(tester);
      showNeoToast(context, message: 'First');
      showNeoToast(context, message: 'Second');
      await tester.pumpAndSettle();
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsNothing);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('handle dismisses early and drops queued toasts', (
      tester,
    ) async {
      final context = await _host(tester);
      final first = showNeoToast(context, message: 'One');
      final second = showNeoToast(context, message: 'Two');
      await tester.pumpAndSettle();
      second.dismiss();
      expect(second.isClosed, isTrue);
      first.dismiss();
      await tester.pumpAndSettle();
      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsNothing);
      expect(first.isClosed, isTrue);
    });

    testWidgets('tap dismisses and action fires once', (tester) async {
      final context = await _host(tester);
      var undone = 0;
      showNeoToast(
        context,
        message: 'Deleted',
        actionLabel: 'Undo',
        onAction: () => undone++,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(undone, 1);
      expect(find.text('Deleted'), findsNothing);

      showNeoToast(context, message: 'Tap me');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(find.text('Tap me'), findsNothing);
    });

    testWidgets('swipe dismisses', (tester) async {
      final context = await _host(tester);
      final handle = showNeoToast(context, message: 'Swipe');
      await tester.pumpAndSettle();
      await tester.drag(find.text('Swipe'), const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Swipe'), findsNothing);
      expect(handle.isClosed, isTrue);
    });

    for (final dark in [false, true]) {
      testWidgets(
        'every type is legible and live (${dark ? 'dark' : 'light'})',
        (tester) async {
          for (final type in NeoToastType.values) {
            await pumpNeo(
              tester,
              NeoToast(message: type.name, type: type, title: 'Title'),
              dark: dark,
            );
            await expectLater(tester, meetsGuideline(textContrastGuideline));
            expect(
              tester
                  .getSemantics(find.text(type.name))
                  .flagsCollection
                  .isLiveRegion,
              isTrue,
            );
          }
        },
      );
    }
  });
}
