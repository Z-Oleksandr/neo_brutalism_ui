import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slab_ui/slab_ui.dart';

import '../helpers/pump.dart';

Widget _list({ScrollPhysics? physics}) => ListView.builder(
  physics: physics ?? const AlwaysScrollableScrollPhysics(),
  itemCount: 30,
  itemBuilder: (_, i) => SizedBox(height: 50, child: Text('Item $i')),
);

Future<void> _pumpRefresh(
  WidgetTester tester, {
  required Future<void> Function() onRefresh,
  NeoRefreshController? controller,
  ScrollPhysics? physics,
  bool disableAnimations = false,
}) {
  return pumpNeo(
    tester,
    SizedBox(
      height: 500,
      child: NeoRefreshIndicator(
        onRefresh: onRefresh,
        controller: controller,
        child: _list(physics: physics),
      ),
    ),
    disableAnimations: disableAnimations,
  );
}

Future<void> _finishRefresh(WidgetTester tester, Completer<void> c) async {
  c.complete();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('NeoShimmer / NeoSkeleton', () {
    testWidgets('animates inside a shimmer', (tester) async {
      await pumpNeo(
        tester,
        const NeoShimmer(child: NeoSkeleton(width: 100, height: 20)),
      );
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('is static under reduced motion', (tester) async {
      await pumpNeo(
        tester,
        const NeoShimmer(child: NeoSkeleton(width: 100, height: 20)),
        disableAnimations: true,
      );
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('renders static without a shimmer ancestor', (tester) async {
      await pumpNeo(tester, const NeoSkeleton(width: 40, height: 40));
      expect(tester.hasRunningAnimations, isFalse);
      expect(tester.getSize(find.byType(NeoSkeleton)), const Size(40, 40));
    });

    testWidgets('text helper draws lines with a shorter last line', (
      tester,
    ) async {
      await pumpNeo(
        tester,
        const SizedBox(
          width: 200,
          child: NeoSkeleton.text(lastLineFraction: 0.5),
        ),
      );
      final bars = find.byType(NeoSkeleton);
      expect(bars, findsNWidgets(3));
      expect(tester.getSize(bars.at(0)).width, 200);
      expect(tester.getSize(bars.at(2)).width, 100);
    });

    testWidgets('circle and avatar are square', (tester) async {
      await pumpNeo(
        tester,
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeoSkeleton.circle(size: 30),
            NeoSkeleton.avatar(size: 30),
          ],
        ),
      );
      for (final e in find.byType(NeoSkeleton).evaluate()) {
        expect(e.size, const Size(30, 30));
      }
    });
  });

  group('NeoRefreshIndicator', () {
    testWidgets('pull past the trigger refreshes and completes', (
      tester,
    ) async {
      final c = Completer<void>();
      var calls = 0;
      await _pumpRefresh(
        tester,
        onRefresh: () {
          calls++;
          return c.future;
        },
      );
      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pump();
      expect(calls, 1);
      expect(find.text('DONE ✓'), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      c.complete();
      await tester.pump();
      expect(find.text('DONE ✓'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('DONE ✓'), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('works with bouncing physics', (tester) async {
      final c = Completer<void>();
      var calls = 0;
      await _pumpRefresh(
        tester,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        onRefresh: () {
          calls++;
          return c.future;
        },
      );
      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(calls, 1);
      await _finishRefresh(tester, c);
    });

    testWidgets('a short pull does not refresh', (tester) async {
      var calls = 0;
      await _pumpRefresh(tester, onRefresh: () async => calls++);
      await tester.drag(find.byType(ListView), const Offset(0, 60));
      await tester.pumpAndSettle();
      expect(calls, 0);
      expect(find.text('↓'), findsNothing);
    });

    testWidgets('controller refreshes and dedupes in-flight calls', (
      tester,
    ) async {
      final c = Completer<void>();
      final controller = NeoRefreshController();
      var calls = 0;
      await _pumpRefresh(
        tester,
        controller: controller,
        onRefresh: () {
          calls++;
          return c.future;
        },
      );
      final a = controller.refresh();
      final b = controller.refresh();
      await tester.pump();
      expect(identical(a, b), isTrue);
      expect(controller.isRefreshing, isTrue);
      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pump();
      expect(calls, 1);
      await _finishRefresh(tester, c);
      expect(controller.isRefreshing, isFalse);
    });

    testWidgets('announces a live region while refreshing', (tester) async {
      final c = Completer<void>();
      final controller = NeoRefreshController();
      await _pumpRefresh(
        tester,
        controller: controller,
        onRefresh: () => c.future,
      );
      unawaited(controller.refresh());
      await tester.pump();
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      await _finishRefresh(tester, c);
    });

    testWidgets('reports errors and recovers', (tester) async {
      final controller = NeoRefreshController();
      await _pumpRefresh(
        tester,
        controller: controller,
        onRefresh: () async => throw StateError('boom'),
      );
      await controller.refresh();
      await tester.pump();
      expect(tester.takeException(), isA<StateError>());
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 300));
      expect(controller.isRefreshing, isFalse);
    });

    testWidgets('reduced motion has no busy animation', (tester) async {
      final c = Completer<void>();
      final controller = NeoRefreshController();
      await _pumpRefresh(
        tester,
        controller: controller,
        disableAnimations: true,
        onRefresh: () => c.future,
      );
      unawaited(controller.refresh());
      await tester.pump();
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      await _finishRefresh(tester, c);
    });
  });

  group('NeoProgressBar', () {
    testWidgets('determinate exposes a percentage value', (tester) async {
      await pumpNeo(
        tester,
        const SizedBox(
          width: 200,
          child: NeoProgressBar(value: 0.5, semanticLabel: 'Upload'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(NeoProgressBar)),
        matchesSemantics(label: 'Upload', value: '50%'),
      );
    });

    testWidgets('indeterminate marches unless motion is reduced', (
      tester,
    ) async {
      await pumpNeo(
        tester,
        const SizedBox(width: 200, child: NeoProgressBar()),
      );
      expect(tester.hasRunningAnimations, isTrue);
      await pumpNeo(
        tester,
        const SizedBox(width: 200, child: NeoProgressBar()),
        disableAnimations: true,
      );
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('clamps out-of-range values', (tester) async {
      await pumpNeo(
        tester,
        const SizedBox(width: 200, child: NeoProgressBar(value: 3)),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(NeoProgressBar)),
        matchesSemantics(value: '100%'),
      );
    });
  });

  group('NeoAlertBanner', () {
    testWidgets('fires action and dismiss', (tester) async {
      var actions = 0;
      var dismissed = 0;
      await pumpNeo(
        tester,
        NeoAlertBanner(
          title: 'Heads up',
          message: 'Something happened',
          type: NeoAlertType.warning,
          actionLabel: 'Retry',
          onAction: () => actions++,
          onDismiss: () => dismissed++,
        ),
      );
      await tester.tap(find.text('Retry'));
      await tester.tap(find.bySemanticsLabel('Dismiss'));
      await tester.pumpAndSettle();
      expect(actions, 1);
      expect(dismissed, 1);
    });

    testWidgets('is a live region', (tester) async {
      await pumpNeo(tester, const NeoAlertBanner(message: 'Saved'));
      final node = tester.getSemantics(find.text('Saved'));
      expect(node.flagsCollection.isLiveRegion, isTrue);
    });

    for (final dark in [false, true]) {
      for (final type in NeoAlertType.values) {
        testWidgets('${type.name} ${dark ? 'dark' : 'light'} is legible', (
          tester,
        ) async {
          await pumpNeo(
            tester,
            NeoAlertBanner(
              message: 'Message text',
              title: 'Title',
              type: type,
              onDismiss: () {},
            ),
            dark: dark,
          );
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        });
      }
    }
  });

  group('NeoSticker', () {
    testWidgets('slaps in and settles', (tester) async {
      await pumpNeo(
        tester,
        const NeoSticker(label: 'Offline', icon: Icons.wifi_off),
      );
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('appears immediately with reduced motion', (tester) async {
      await pumpNeo(
        tester,
        const NeoSticker(label: 'Offline'),
        disableAnimations: true,
      );
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('NeoEmptyState', () {
    testWidgets('shows header, message and action', (tester) async {
      var taps = 0;
      await pumpNeo(
        tester,
        NeoEmptyState(
          icon: Icons.inbox,
          title: 'Nothing here',
          message: 'Create your first item',
          actionLabel: 'Create',
          onAction: () => taps++,
        ),
      );
      expect(
        tester.getSemantics(find.text('Nothing here')).flagsCollection.isHeader,
        isTrue,
      );
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });
  });

  group('NeoErrorHighlight', () {
    Widget host(Object? error) => NeoErrorHighlight(
      error: error,
      child: const SizedBox(width: 80, height: 40),
    );

    testWidgets('flashes on a new error and fades', (tester) async {
      await pumpNeo(tester, host(null));
      expect(tester.hasRunningAnimations, isFalse);
      await pumpNeo(tester, host(1));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('does not re-flash for the same error', (tester) async {
      await pumpNeo(tester, host(1));
      await tester.pumpAndSettle();
      await pumpNeo(tester, host(1));
      expect(tester.hasRunningAnimations, isFalse);
      await pumpNeo(tester, host(2));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
    });
  });
}
