import 'package:flutter/material.dart';

import '../../foundation/neo_strings.dart';
import '../../theme/neo_theme.dart';
import '../../theme/neo_theme_data.dart';
import '../buttons/neo_button.dart';
import '../buttons/neo_icon_button.dart';

enum NeoAlertType { info, success, warning, error }

/// An inline status message colored by [type], announced to screen readers.
class NeoAlertBanner extends StatelessWidget {
  const NeoAlertBanner({
    super.key,
    required this.message,
    this.type = NeoAlertType.info,
    this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.dismissLabel,
  });

  final String message;
  final NeoAlertType type;
  final String? title;

  /// Overrides the icon implied by [type].
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Shows a close button when set.
  final VoidCallback? onDismiss;
  final String? dismissLabel;

  static Color colorFor(NeoAlertType type, NeoThemeData theme) =>
      switch (type) {
        NeoAlertType.info => theme.colors.info,
        NeoAlertType.success => theme.colors.success,
        NeoAlertType.warning => theme.colors.warning,
        NeoAlertType.error => theme.colors.danger,
      };

  IconData get _icon =>
      icon ??
      switch (type) {
        NeoAlertType.info => Icons.info_outline,
        NeoAlertType.success => Icons.check_circle_outline,
        NeoAlertType.warning => Icons.warning_amber_rounded,
        NeoAlertType.error => Icons.error_outline,
      };

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final fill = colorFor(type, theme);
    final fg = theme.colors.onColor(fill);
    final gap = theme.spacing.md;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          theme.spacing.lg,
          gap,
          onDismiss == null ? theme.spacing.lg : theme.spacing.xs,
          gap,
        ),
        decoration: theme.decoration(color: fill),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 2),
              child: Icon(_icon, color: fg, size: 22),
            ),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: theme.typography.titleSmall.copyWith(color: fg),
                    ),
                  Text(
                    message,
                    style: theme.typography.body.copyWith(color: fg),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    SizedBox(height: theme.spacing.sm),
                    NeoButton(
                      label: actionLabel!,
                      onPressed: onAction,
                      variant: NeoButtonVariant.outlined,
                      size: NeoButtonSize.small,
                    ),
                  ],
                ],
              ),
            ),
            if (onDismiss != null)
              NeoIconButton(
                icon: Icons.close,
                size: 32,
                color: fill,
                semanticLabel: dismissLabel ?? NeoStrings.of(context).dismiss,
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}
