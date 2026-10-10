import 'package:flutter/material.dart';

import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';

/// The dialog card shown by [showNeoDialog]: bold [title], a [message] or
/// custom [content], and [actions] along the bottom.
class NeoDialog extends StatelessWidget {
  const NeoDialog({
    super.key,
    this.title,
    this.message,
    this.content,
    this.actions = const [],
    this.color,
    this.maxWidth = 420,
  });

  final String? title;
  final String? message;
  final Widget? content;

  /// Up to two actions share the width; more wrap to the end.
  final List<Widget> actions;

  /// Card fill. Defaults to the theme surface.
  final Color? color;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final ink = theme.colors.onColor(color ?? theme.colors.surface);
    final gap = theme.spacing.lg;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: title,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          type: MaterialType.transparency,
          child: DefaultTextStyle(
            style: theme.typography.body.copyWith(color: ink),
            child: NeoSurface(
              color: color,
              radius: theme.radii.lg,
              padding: EdgeInsets.all(theme.spacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: theme.typography.title.copyWith(color: ink),
                    ),
                  if (title != null && (message != null || content != null))
                    SizedBox(height: theme.spacing.md),
                  if (message != null) Text(message!),
                  if (content != null) Flexible(child: content!),
                  if (actions.isNotEmpty) ...[
                    SizedBox(height: gap),
                    _Actions(actions: actions, gap: theme.spacing.md),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.actions, required this.gap});

  final List<Widget> actions;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (actions.length > 2) {
      return Wrap(
        alignment: WrapAlignment.end,
        spacing: gap,
        runSpacing: gap,
        children: actions,
      );
    }
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(child: actions[i]),
        ],
      ],
    );
  }
}
