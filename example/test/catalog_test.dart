import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';
import 'package:neo_brutalism_ui_example/pages/buttons_page.dart';
import 'package:neo_brutalism_ui_example/pages/display_page.dart';
import 'package:neo_brutalism_ui_example/pages/feedback_page.dart';
import 'package:neo_brutalism_ui_example/pages/inputs_page.dart';
import 'package:neo_brutalism_ui_example/pages/media_page.dart';
import 'package:neo_brutalism_ui_example/pages/navigation_page.dart';
import 'package:neo_brutalism_ui_example/pages/overlays_page.dart';
import 'package:neo_brutalism_ui_example/pages/pickers_page.dart';
import 'package:neo_brutalism_ui_example/pages/selection_page.dart';

void main() {
  const pages = <String, Widget>{
    'buttons': ButtonsPage(),
    'inputs': InputsPage(),
    'selection': SelectionPage(),
    'navigation': NavigationPage(),
    'overlays': OverlaysPage(),
    'feedback': FeedbackPage(),
    'display': DisplayPage(),
    'media': MediaPage(),
    'pickers': PickersPage(),
  };

  const variants = <String, (bool, TextDirection, double)>{
    'light': (false, TextDirection.ltr, 1),
    'dark': (true, TextDirection.ltr, 1),
    'rtl': (false, TextDirection.rtl, 1),
    'large text': (true, TextDirection.ltr, 1.6),
  };

  for (final page in pages.entries) {
    for (final variant in variants.entries) {
      testWidgets('${page.key} renders in ${variant.key}', (tester) async {
        final (dark, direction, scale) = variant.value;
        tester.view.physicalSize = const Size(780, 16000);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);
        final theme = dark ? NeoThemeData.dark() : NeoThemeData.light();
        await tester.pumpWidget(
          MaterialApp(
            theme: theme.toThemeData(),
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(390, 8000),
                textScaler: TextScaler.linear(scale),
              ),
              child: Directionality(
                textDirection: direction,
                child: Scaffold(body: page.value),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
      });
    }
  }
}
