import 'package:flutter/material.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

import 'pages/buttons_page.dart';
import 'pages/display_page.dart';
import 'pages/feedback_page.dart';
import 'pages/inputs_page.dart';
import 'pages/media_page.dart';
import 'pages/navigation_page.dart';
import 'pages/overlays_page.dart';
import 'pages/pickers_page.dart';
import 'pages/selection_page.dart';

void main() => runApp(const CatalogApp());

typedef _Entry = ({String title, IconData icon, WidgetBuilder builder});

final List<_Entry> _entries = [
  (
    title: 'Buttons',
    icon: Icons.smart_button,
    builder: (_) => const ButtonsPage(),
  ),
  (title: 'Inputs', icon: Icons.edit, builder: (_) => const InputsPage()),
  (
    title: 'Selection',
    icon: Icons.check_box,
    builder: (_) => const SelectionPage(),
  ),
  (
    title: 'Navigation',
    icon: Icons.tab,
    builder: (_) => const NavigationPage(),
  ),
  (title: 'Overlays', icon: Icons.layers, builder: (_) => const OverlaysPage()),
  (
    title: 'Feedback',
    icon: Icons.hourglass_bottom,
    builder: (_) => const FeedbackPage(),
  ),
  (
    title: 'Display',
    icon: Icons.view_agenda,
    builder: (_) => const DisplayPage(),
  ),
  (title: 'Media', icon: Icons.image, builder: (_) => const MediaPage()),
  (
    title: 'Pickers',
    icon: Icons.calendar_month,
    builder: (_) => const PickersPage(),
  ),
];

class CatalogApp extends StatefulWidget {
  const CatalogApp({super.key});

  @override
  State<CatalogApp> createState() => _CatalogAppState();
}

class _CatalogAppState extends State<CatalogApp> {
  ThemeMode _mode = ThemeMode.light;
  bool _rtl = false;
  bool _largeText = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'neo_brutalism_ui',
      debugShowCheckedModeBanner: false,
      theme: NeoThemeData.light().toThemeData(),
      darkTheme: NeoThemeData.dark().toThemeData(),
      themeMode: _mode,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(_largeText ? 1.6 : 1)),
        child: Directionality(
          textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        ),
      ),
      home: _Home(
        dark: _mode == ThemeMode.dark,
        rtl: _rtl,
        largeText: _largeText,
        onDark: (v) =>
            setState(() => _mode = v ? ThemeMode.dark : ThemeMode.light),
        onRtl: (v) => setState(() => _rtl = v),
        onLargeText: (v) => setState(() => _largeText = v),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({
    required this.dark,
    required this.rtl,
    required this.largeText,
    required this.onDark,
    required this.onRtl,
    required this.onLargeText,
  });

  final bool dark;
  final bool rtl;
  final bool largeText;
  final ValueChanged<bool> onDark;
  final ValueChanged<bool> onRtl;
  final ValueChanged<bool> onLargeText;

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(theme.spacing.lg),
          children: [
            const NeoBanner(text: 'NEO BRUTALISM UI'),
            SizedBox(height: theme.spacing.lg),
            Wrap(
              spacing: theme.spacing.sm,
              runSpacing: theme.spacing.sm,
              children: [
                NeoButton(
                  label: dark ? 'Dark' : 'Light',
                  icon: dark ? Icons.dark_mode : Icons.light_mode,
                  variant: NeoButtonVariant.outlined,
                  size: NeoButtonSize.small,
                  onPressed: () => onDark(!dark),
                ),
                NeoButton(
                  label: rtl ? 'RTL' : 'LTR',
                  icon: Icons.format_textdirection_l_to_r,
                  variant: NeoButtonVariant.outlined,
                  size: NeoButtonSize.small,
                  onPressed: () => onRtl(!rtl),
                ),
                NeoButton(
                  label: largeText ? 'Text 1.6x' : 'Text 1x',
                  icon: Icons.format_size,
                  variant: NeoButtonVariant.outlined,
                  size: NeoButtonSize.small,
                  onPressed: () => onLargeText(!largeText),
                ),
              ],
            ),
            SizedBox(height: theme.spacing.xl),
            for (final (i, entry) in _entries.indexed) ...[
              NeoCard(
                color: theme.colors.accents[i % theme.colors.accents.length],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _DemoScreen(entry: entry),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(entry.icon),
                    SizedBox(width: theme.spacing.md),
                    Expanded(
                      child: Text(entry.title, style: theme.typography.title),
                    ),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
              SizedBox(height: theme.spacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _DemoScreen extends StatelessWidget {
  const _DemoScreen({required this.entry});

  final _Entry entry;

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(theme.spacing.lg),
              child: Row(
                children: [
                  NeoIconButton(
                    icon: Icons.arrow_back,
                    semanticLabel: NeoStrings.of(context).back,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: theme.spacing.md),
                  Text(entry.title, style: theme.typography.headline),
                ],
              ),
            ),
            Expanded(child: Builder(builder: entry.builder)),
          ],
        ),
      ),
    );
  }
}
