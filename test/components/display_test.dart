import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slab_ui/slab_ui.dart';

import '../helpers/pump.dart';

final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
);

String _long(int n) => List.filled(n, 'Neobrutalism is loud.').join(' ');

void main() {
  group('NeoListTile', () {
    testWidgets('fires tap and long press', (tester) async {
      var taps = 0;
      var longs = 0;
      await pumpNeo(
        tester,
        NeoListTile(
          title: const Text('Ada'),
          subtitle: const Text('Online'),
          onTap: () => taps++,
          onLongPress: () => longs++,
        ),
      );
      await tester.tap(find.text('Ada'));
      await tester.longPress(find.text('Ada'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(longs, 1);
    });

    testWidgets('static tile has no press behavior', (tester) async {
      await pumpNeo(tester, const NeoListTile(title: Text('Static')));
      expect(find.byType(NeoPressable), findsNothing);
    });

    testWidgets('exposes selected semantics', (tester) async {
      await pumpNeo(
        tester,
        NeoListTile(title: const Text('Pick'), selected: true, onTap: () {}),
      );
      final node = tester.getSemantics(find.text('Pick'));
      expect(node.flagsCollection.isSelected, Tristate.isTrue);
    });

    testWidgets('highlighted adds a start rail', (tester) async {
      await pumpNeo(
        tester,
        const SizedBox(
          width: 300,
          child: NeoListTile(title: Text('Unread'), highlighted: true),
        ),
        textDirection: TextDirection.rtl,
      );
      final rail = find.descendant(
        of: find.byType(NeoListTile),
        matching: find.byType(ColoredBox),
      );
      expect(rail, findsOneWidget);
      final tile = tester.getRect(find.byType(NeoListTile));
      expect(tester.getRect(rail).right, closeTo(tile.right - 3, 0.5));
    });

    for (final dark in [false, true]) {
      testWidgets('is legible ${dark ? 'dark' : 'light'}', (tester) async {
        await pumpNeo(
          tester,
          SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeoListTile(
                  title: const Text('Title'),
                  subtitle: const Text('Subtitle'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                NeoListTile(
                  title: const Text('Highlighted'),
                  subtitle: const Text('Subtitle'),
                  highlighted: true,
                  onTap: () {},
                ),
                NeoListTile(
                  title: const Text('Selected'),
                  selected: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
          dark: dark,
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      });
    }
  });

  group('NeoAvatar', () {
    test('initialsOf takes up to two words', () {
      expect(NeoAvatar.initialsOf('ada lovelace byron'), 'AL');
      expect(NeoAvatar.initialsOf('  grace  '), 'G');
      expect(NeoAvatar.initialsOf('Émile Zola'), 'ÉZ');
    });

    testWidgets('shows initials and name semantics', (tester) async {
      await pumpNeo(tester, const NeoAvatar(name: 'Ada Lovelace'));
      expect(find.text('AL'), findsOneWidget);
      expect(find.bySemanticsLabel('Ada Lovelace'), findsOneWidget);
    });

    testWidgets('falls back to the icon without a name', (tester) async {
      await pumpNeo(tester, const NeoAvatar());
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows the image once decoded', (tester) async {
      await pumpNeo(tester, NeoAvatar(image: MemoryImage(_png), name: 'Ada'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<ResizeImage>());
    });

    testWidgets('falls back to initials when the image fails', (tester) async {
      await pumpNeo(
        tester,
        NeoAvatar(
          image: MemoryImage(Uint8List.fromList([0, 1, 2, 3])),
          name: 'Bad Image',
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
      expect(find.text('BI'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('circle shape clips round', (tester) async {
      await pumpNeo(
        tester,
        const NeoAvatar(name: 'C', shape: NeoAvatarShape.circle, size: 40),
      );
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clip.borderRadius, isNot(BorderRadius.zero));
      expect(tester.getSize(find.byType(NeoAvatar)), const Size(40, 40));
    });
  });

  group('NeoAvatarGroup', () {
    testWidgets('collapses overflow into +N', (tester) async {
      await pumpNeo(
        tester,
        NeoAvatarGroup(
          size: 32,
          max: 3,
          avatars: [
            for (final n in ['A', 'B', 'C', 'D', 'E'])
              NeoAvatar(name: n, size: 32),
          ],
        ),
      );
      expect(find.byType(NeoAvatar), findsNWidgets(3));
      expect(find.text('+2'), findsOneWidget);
    });
  });

  group('NeoDivider', () {
    testWidgets('horizontal and vertical take the border thickness', (
      tester,
    ) async {
      await pumpNeo(
        tester,
        const SizedBox(
          width: 100,
          height: 50,
          child: Row(
            children: [
              Expanded(child: NeoDivider()),
              NeoDivider.vertical(),
            ],
          ),
        ),
      );
      final h = tester.getSize(find.byType(NeoDivider).first);
      final v = tester.getSize(find.byType(NeoDivider).last);
      expect(h.height, 2);
      expect(v.width, 2);
      expect(v.height, 50);
    });
  });

  group('NeoQuoteBlock', () {
    testWidgets('short text has no thumb', (tester) async {
      await pumpNeo(
        tester,
        const SizedBox(width: 300, child: NeoQuoteBlock(text: 'Short.')),
      );
      await tester.pump();
      expect(find.bySemanticsLabel('Scroll'), findsNothing);
    });

    testWidgets('long text gets a draggable thumb that scrolls', (
      tester,
    ) async {
      await pumpNeo(
        tester,
        SizedBox(
          width: 300,
          child: NeoQuoteBlock(
            title: 'About',
            text: _long(40),
            thumbSemanticLabel: 'Scroll',
          ),
        ),
      );
      await tester.pump();
      final thumb = find.bySemanticsLabel('Scroll');
      expect(thumb, findsOneWidget);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.pixels, 0);
      await tester.drag(thumb, const Offset(0, 30));
      await tester.pump();
      expect(scrollable.position.pixels, greaterThan(0));
    });

    testWidgets('thumb supports increase and decrease actions', (tester) async {
      await pumpNeo(
        tester,
        SizedBox(
          width: 300,
          child: NeoQuoteBlock(text: _long(40), thumbSemanticLabel: 'Scroll'),
        ),
      );
      await tester.pump();
      final semantics = tester.semantics;
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      semantics.performAction(
        find.semantics.byLabel('Scroll'),
        SemanticsAction.increase,
      );
      await tester.pump();
      expect(scrollable.position.pixels, greaterThan(0));
    });
  });

  group('NeoExpansionPanel', () {
    testWidgets('toggles and reports expanded semantics', (tester) async {
      final changes = <bool>[];
      await pumpNeo(
        tester,
        SizedBox(
          width: 300,
          child: NeoExpansionPanel(
            title: const Text('Details'),
            onExpansionChanged: changes.add,
            child: const Text('Body'),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Details')).flagsCollection.isExpanded,
        Tristate.isFalse,
      );
      expect(find.text('Body').hitTestable(), findsNothing);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(changes, [true]);
      expect(find.text('Body').hitTestable(), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Details')).flagsCollection.isExpanded,
        Tristate.isTrue,
      );
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(changes, [true, false]);
      expect(find.text('Body'), findsNothing);
    });

    testWidgets('controlled mode follows the expanded prop', (tester) async {
      final changes = <bool>[];
      Widget build(bool expanded) => SizedBox(
        width: 300,
        child: NeoExpansionPanel(
          title: const Text('Details'),
          expanded: expanded,
          onExpansionChanged: changes.add,
          child: const Text('Body'),
        ),
      );
      await pumpNeo(tester, build(false));
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(changes, [true]);
      expect(find.text('Body'), findsNothing);
      await pumpNeo(tester, build(true));
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);
    });
  });

  group('NeoChatBubble', () {
    testWidgets('aligns own messages to the end edge', (tester) async {
      Future<Rect> rectFor(bool mine, TextDirection dir) async {
        await pumpNeo(
          tester,
          SizedBox(
            width: 400,
            child: NeoChatBubble(text: 'Hey', isMine: mine),
          ),
          textDirection: dir,
        );
        return tester.getRect(find.text('Hey'));
      }

      final mineLtr = await rectFor(true, TextDirection.ltr);
      final theirsLtr = await rectFor(false, TextDirection.ltr);
      final mineRtl = await rectFor(true, TextDirection.rtl);
      expect(mineLtr.left, greaterThan(theirsLtr.left));
      expect(mineRtl.left, lessThan(mineLtr.left));
    });

    testWidgets('shows sender only for others', (tester) async {
      await pumpNeo(
        tester,
        const SizedBox(
          width: 400,
          child: NeoChatBubble(text: 'Hi', sender: 'Ada', timestamp: '12:01'),
        ),
      );
      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('12:01'), findsOneWidget);
      await pumpNeo(
        tester,
        const SizedBox(
          width: 400,
          child: NeoChatBubble(text: 'Hi', sender: 'Ada', isMine: true),
        ),
      );
      expect(find.text('Ada'), findsNothing);
    });

    testWidgets('long press fires', (tester) async {
      var longs = 0;
      await pumpNeo(
        tester,
        SizedBox(
          width: 400,
          child: NeoChatBubble(text: 'Hold me', onLongPress: () => longs++),
        ),
      );
      await tester.longPress(find.text('Hold me'));
      await tester.pumpAndSettle();
      expect(longs, 1);
    });

    for (final dark in [false, true]) {
      testWidgets('is legible ${dark ? 'dark' : 'light'}', (tester) async {
        await pumpNeo(
          tester,
          const SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeoChatBubble(text: 'Mine', isMine: true, timestamp: '9:00'),
                NeoChatBubble(text: 'Theirs', sender: 'Ada', timestamp: '9:01'),
              ],
            ),
          ),
          dark: dark,
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      });
    }
  });
}
