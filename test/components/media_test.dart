import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

import '../helpers/pump.dart';

final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
  '60e6kgAAAABJRU5ErkJggg==',
);

List<ImageProvider> _images(int count) => [
  for (var i = 0; i < count; i++) MemoryImage(Uint8List.fromList(_png)),
];

Future<void> _settleImages(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _openViewer(
  WidgetTester tester, {
  int count = 3,
  int initialIndex = 1,
  bool dark = false,
}) async {
  await pumpNeo(
    tester,
    Builder(
      builder: (context) => NeoButton(
        label: 'Open',
        onPressed: () => showNeoMediaViewer(
          context,
          images: _images(count),
          initialIndex: initialIndex,
        ),
      ),
    ),
    dark: dark,
  );
  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('NeoImage', () {
    testWidgets('shows placeholder, then the loaded image', (tester) async {
      await pumpNeo(
        tester,
        NeoImage(image: _images(1).single, width: 60, height: 60),
      );
      final placeholderFinder = find.descendant(
        of: find.byType(AnimatedSwitcher),
        matching: find.byType(NeoSkeleton),
      );
      expect(placeholderFinder, findsOneWidget);
      await _settleImages(tester);
      expect(placeholderFinder, findsNothing);
      expect(find.byType(RawImage), findsOneWidget);
    });

    testWidgets('shows the error tile for undecodable bytes', (tester) async {
      await pumpNeo(
        tester,
        NeoImage(
          image: MemoryImage(Uint8List.fromList([0, 1, 2, 3])),
          width: 60,
          height: 60,
        ),
      );
      await _settleImages(tester);
      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    });

    testWidgets('decodes at displayed size times device pixel ratio', (
      tester,
    ) async {
      await pumpNeo(
        tester,
        NeoImage(image: _images(1).single, width: 50, height: 80),
      );
      final image = tester.widget<Image>(find.byType(Image));
      final dpr = tester.view.devicePixelRatio;
      expect(image.image, isA<ResizeImage>());
      expect((image.image as ResizeImage).width, (50 * dpr).round());
    });

    testWidgets('resize can be disabled', (tester) async {
      await pumpNeo(
        tester,
        NeoImage(image: _images(1).single, width: 50, resize: false),
      );
      expect(
        tester.widget<Image>(find.byType(Image)).image,
        isA<MemoryImage>(),
      );
    });

    test('resolveProvider skips unknown sizes', () {
      final raw = _images(1).single;
      expect(NeoImage.resolveProvider(raw, devicePixelRatio: 2), same(raw));
      final sized = NeoImage.resolveProvider(
        raw,
        height: 10,
        devicePixelRatio: 2,
      );
      expect((sized as ResizeImage).height, 20);
    });

    testWidgets('onTap makes it a labeled button', (tester) async {
      var taps = 0;
      await pumpNeo(
        tester,
        NeoImage(
          image: _images(1).single,
          width: 60,
          height: 60,
          semanticLabel: 'Cover',
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.byType(NeoImage));
      await tester.pump(const Duration(milliseconds: 300));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Cover')),
        matchesSemantics(
          label: 'Cover',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });

    testWidgets('without a callback it is a plain labeled image', (
      tester,
    ) async {
      await pumpNeo(
        tester,
        NeoImage(
          image: _images(1).single,
          width: 40,
          height: 40,
          semanticLabel: 'Pic',
        ),
      );
      expect(find.byType(NeoPressable), findsNothing);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.semanticLabel, 'Pic');
      expect(image.excludeFromSemantics, isFalse);
    });
  });

  group('NeoMediaViewer', () {
    for (final dark in [false, true]) {
      testWidgets('opens at the initial index (${dark ? 'dark' : 'light'})', (
        tester,
      ) async {
        await _openViewer(tester, dark: dark);
        expect(find.byType(NeoMediaViewer), findsOneWidget);
        expect(find.text('2 / 3'), findsOneWidget);
      });
    }

    testWidgets('pages with a swipe', (tester) async {
      await _openViewer(tester);
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('3 / 3'), findsOneWidget);
    });

    testWidgets('arrow keys page and Escape closes', (tester) async {
      await _openViewer(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1 / 3'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1 / 3'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(NeoMediaViewer), findsNothing);
    });

    testWidgets('close button has a localized label and closes', (
      tester,
    ) async {
      await _openViewer(tester);
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      await tester.tap(find.byType(NeoIconButton));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(NeoMediaViewer), findsNothing);
    });

    testWidgets('swipe down dismisses, a short drag snaps back', (
      tester,
    ) async {
      await _openViewer(tester);
      await tester.drag(find.byType(PageView), const Offset(0, 40));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(NeoMediaViewer), findsOneWidget);
      await tester.drag(find.byType(PageView), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(NeoMediaViewer), findsNothing);
    });

    testWidgets('double tap zooms in and locks paging', (tester) async {
      await _openViewer(tester);
      final center = tester.getCenter(find.byType(PageView));
      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(center);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      final view = tester.widget<PageView>(find.byType(PageView));
      expect(view.physics, isA<NeverScrollableScrollPhysics>());
      final viewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer).first,
      );
      expect(viewer.panEnabled, isTrue);
    });

    testWidgets('single image hides the page indicator', (tester) async {
      await _openViewer(tester, count: 1, initialIndex: 0);
      expect(find.text('1 / 1'), findsNothing);
    });

    testWidgets('builder constructor renders custom items', (tester) async {
      await pumpNeo(
        tester,
        SizedBox(
          width: 300,
          height: 300,
          child: NeoMediaViewer.builder(
            itemCount: 2,
            itemBuilder: (context, i) => Text('item $i'),
          ),
        ),
      );
      expect(find.text('item 0'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
    });
  });

  group('NeoMediaGallery', () {
    testWidgets('shows an overflow count on the last visible tile', (
      tester,
    ) async {
      await pumpNeo(tester, NeoMediaGallery(images: _images(5), maxVisible: 3));
      expect(find.byType(NeoImage), findsNWidgets(3));
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('reports the tapped index to onOpen', (tester) async {
      int? opened;
      await pumpNeo(
        tester,
        NeoMediaGallery(images: _images(4), onOpen: (i) => opened = i),
      );
      await tester.tap(find.byType(NeoImage).at(1));
      await tester.pump(const Duration(milliseconds: 300));
      expect(opened, 1);
    });

    testWidgets('opens the viewer at the tapped index', (tester) async {
      await pumpNeo(tester, NeoMediaGallery(images: _images(5), maxVisible: 3));
      await tester.tap(find.byType(NeoImage).at(2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('3 / 5'), findsOneWidget);
    });

    testWidgets('renders nothing for an empty list', (tester) async {
      await pumpNeo(tester, const NeoMediaGallery(images: []));
      expect(find.byType(ListView), findsNothing);
    });
  });
}
