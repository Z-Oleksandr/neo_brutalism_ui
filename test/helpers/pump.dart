import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slab_ui/slab_ui.dart';

Future<void> pumpNeo(
  WidgetTester tester,
  Widget child, {
  NeoThemeData? theme,
  bool dark = false,
  TextDirection textDirection = TextDirection.ltr,
  bool disableAnimations = false,
  double textScale = 1,
}) {
  final data = theme ?? (dark ? NeoThemeData.dark() : NeoThemeData.light());
  return tester.pumpWidget(
    MaterialApp(
      theme: data.toThemeData(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Directionality(
            textDirection: textDirection,
            child: Scaffold(body: Center(child: child)),
          ),
        ),
      ),
    ),
  );
}
