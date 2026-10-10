import 'package:flutter/material.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

/// A titled demo block inside a [CatalogPage].
class CatalogSection extends StatelessWidget {
  const CatalogSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.typography.overline.copyWith(
              color: theme.colors.inkMuted,
            ),
          ),
          SizedBox(height: theme.spacing.sm),
          child,
        ],
      ),
    );
  }
}

/// Scrollable page of [CatalogSection]s.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.neo.spacing;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        spacing.lg,
        spacing.lg,
        spacing.lg,
        spacing.xxl * 3,
      ),
      children: children,
    );
  }
}

/// Lays out demo widgets with consistent gaps.
class DemoWrap extends StatelessWidget {
  const DemoWrap({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.neo.spacing;
    return Wrap(
      spacing: spacing.lg,
      runSpacing: spacing.lg,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
