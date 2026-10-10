import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

import '../helpers/pump.dart';

Finder _face(String text) => find.ancestor(
  of: find.text(text),
  matching: find.byType(NeoPressableSurface),
);

bool _sunken(WidgetTester tester, String text) =>
    tester.widget<NeoPressableSurface>(_face(text)).sunken;

void main() {
  group('NeoTabBar', () {
    const tabs = [
      NeoTab(label: 'Friends'),
      NeoTab(label: 'Requests', badgeCount: 3),
      NeoTab(icon: Icons.groups, semanticLabel: 'Clubs'),
    ];

    testWidgets('marks the selected tab and reports taps', (tester) async {
      int? tapped;
      await pumpNeo(
        tester,
        SizedBox(
          width: 360,
          child: NeoTabBar(
            tabs: tabs,
            selectedIndex: 1,
            onChanged: (i) => tapped = i,
          ),
        ),
      );
      expect(_sunken(tester, 'Requests'), isTrue);
      expect(_sunken(tester, 'Friends'), isFalse);
      await tester.tap(find.text('Friends'));
      await tester.pumpAndSettle();
      expect(tapped, 0);
    });

    testWidgets('renders badge counts without casting', (tester) async {
      await pumpNeo(
        tester,
        const SizedBox(width: 360, child: NeoTabBar(tabs: tabs)),
      );
      expect(find.text('3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('exposes selected semantics and icon labels', (tester) async {
      await pumpNeo(
        tester,
        const SizedBox(width: 360, child: NeoTabBar(tabs: tabs)),
      );
      expect(
        tester.getSemantics(find.text('Friends')),
        matchesSemantics(
          label: 'Friends',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      expect(find.bySemanticsLabel('Clubs'), findsOneWidget);
    });

    testWidgets('stays in sync with a TabController', (tester) async {
      final controller = TabController(length: 3, vsync: const TestVSync());
      addTearDown(controller.dispose);
      await pumpNeo(
        tester,
        SizedBox(
          width: 360,
          child: NeoTabBar(tabs: tabs, controller: controller),
        ),
      );
      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();
      expect(controller.index, 1);
      controller.index = 0;
      await tester.pumpAndSettle();
      expect(_sunken(tester, 'Friends'), isTrue);
    });

    testWidgets('scrollable tabs size to content', (tester) async {
      await pumpNeo(
        tester,
        SizedBox(
          width: 200,
          child: NeoTabBar(
            isScrollable: true,
            tabs: [for (var i = 0; i < 8; i++) NeoTab(label: 'Tab $i')],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    for (final dark in [false, true]) {
      testWidgets('meets guidelines (${dark ? 'dark' : 'light'})', (
        tester,
      ) async {
        await pumpNeo(
          tester,
          SizedBox(
            width: 360,
            child: NeoTabBar(tabs: tabs, onChanged: (_) {}),
          ),
          dark: dark,
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      });
    }
  });

  group('NeoSliverTabBar', () {
    testWidgets('stays pinned while scrolling', (tester) async {
      await pumpNeo(
        tester,
        CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 300)),
            const NeoSliverTabBar(
              tabBar: NeoTabBar(
                tabs: [
                  NeoTab(label: 'Posts'),
                  NeoTab(label: 'Members'),
                ],
              ),
            ),
            SliverList.builder(
              itemCount: 50,
              itemBuilder: (_, i) => SizedBox(height: 60, child: Text('$i')),
            ),
          ],
        ),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await tester.pumpAndSettle();
      expect(find.text('Posts'), findsOneWidget);
      expect(tester.getTopLeft(find.byType(NeoTabBar)).dy, lessThan(40));
      expect(tester.takeException(), isNull);
    });
  });

  group('NeoNavBar', () {
    const items = [
      NeoNavBarItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      NeoNavBarItem(icon: Icons.message, label: 'Messages', badgeCount: 120),
      NeoNavBarItem(icon: Icons.person, label: 'Profile'),
    ];

    testWidgets('labels items for screen readers without visible labels', (
      tester,
    ) async {
      int? tapped;
      await pumpNeo(
        tester,
        NeoNavBar(items: items, currentIndex: 0, onTap: (i) => tapped = i),
      );
      expect(find.text('Home'), findsNothing);
      expect(find.bySemanticsLabel('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();
      expect(tapped, 2);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });

    testWidgets('shows labels once without duplicate semantics', (
      tester,
    ) async {
      await pumpNeo(
        tester,
        NeoNavBar(
          items: items,
          currentIndex: 1,
          showLabels: true,
          onTap: (_) {},
        ),
        dark: true,
      );
      expect(find.text('Home'), findsOneWidget);
      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('lifts above the bottom system inset', (tester) async {
      tester.view.viewPadding = const FakeViewPadding(bottom: 100);
      addTearDown(tester.view.reset);
      await pumpNeo(
        tester,
        NeoNavBar(items: items, currentIndex: 0, onTap: (_) {}),
      );
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(NeoNavBar),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding.vertical, greaterThan(16));
    });
  });

  group('NeoAppBar', () {
    testWidgets('implies a back button on pushed routes', (tester) async {
      await pumpNeo(
        tester,
        Builder(
          builder: (context) => NeoButton(
            label: 'Open',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const Scaffold(appBar: NeoAppBar(titleText: 'Details')),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsOneWidget);
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsNothing);
    });

    testWidgets('has no back button on the first route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeoThemeData.light().toThemeData(),
          home: Scaffold(
            appBar: NeoAppBar(
              titleText: 'Home',
              actions: [
                NeoIconButton(
                  icon: Icons.settings,
                  semanticLabel: 'Settings',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Back'), findsNothing);
      expect(find.bySemanticsLabel('Settings'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('Home')).flagsCollection.isHeader,
        isTrue,
      );
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('centers the title when asked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: NeoAppBar(
              titleText: 'Mid',
              centerTitle: true,
              leading: NeoIconButton(
                icon: Icons.menu,
                semanticLabel: 'Menu',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      final center = tester.getCenter(find.text('Mid')).dx;
      expect(center, closeTo(400, 1));
    });
  });

  group('NeoSegmentedControl', () {
    const segments = [
      NeoSegment(value: 'day', label: 'Day'),
      NeoSegment(value: 'week', label: 'Week'),
      NeoSegment(value: 'month', label: 'Month'),
    ];

    testWidgets('single select replaces the selection', (tester) async {
      Set<String>? next;
      await pumpNeo(
        tester,
        SizedBox(
          width: 360,
          child: NeoSegmentedControl<String>(
            segments: segments,
            selected: const {'day'},
            onChanged: (v) => next = v,
          ),
        ),
      );
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      expect(next, {'week'});
      next = null;
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();
      expect(next, isNull);
    });

    testWidgets('multi select toggles and reports toggled state', (
      tester,
    ) async {
      Set<String>? next;
      await pumpNeo(
        tester,
        SizedBox(
          width: 360,
          child: NeoSegmentedControl<String>(
            segments: segments,
            selected: const {'day', 'week'},
            multiSelect: true,
            onChanged: (v) => next = v,
          ),
        ),
      );
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();
      expect(next, {'week'});
      expect(
        tester.getSemantics(find.text('Week')).flagsCollection.isToggled,
        isNot(Tristate.none),
      );
    });

    testWidgets('allows clearing when emptySelectionAllowed', (tester) async {
      Set<String>? next;
      await pumpNeo(
        tester,
        SizedBox(
          width: 360,
          child: NeoSegmentedControl<String>(
            segments: segments,
            selected: const {'day'},
            emptySelectionAllowed: true,
            onChanged: (v) => next = v,
          ),
        ),
      );
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();
      expect(next, isEmpty);
    });

    testWidgets('null onChanged disables segments', (tester) async {
      await pumpNeo(
        tester,
        const SizedBox(
          width: 360,
          child: NeoSegmentedControl<String>(
            segments: segments,
            selected: {'day'},
            onChanged: null,
          ),
        ),
        dark: true,
      );
      expect(
        tester.getSemantics(find.text('Week')).flagsCollection.isEnabled,
        Tristate.isFalse,
      );
    });
  });
}
