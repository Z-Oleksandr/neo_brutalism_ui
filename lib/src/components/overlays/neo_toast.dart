import 'package:flutter/material.dart';

import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';
import '../../theme/neo_theme_data.dart';
import '../buttons/neo_button.dart';

enum NeoToastType { info, success, warning, error }

/// The toast card shown by [showNeoToast]. Usable on its own as an inline
/// status message.
class NeoToast extends StatelessWidget {
  const NeoToast({
    super.key,
    required this.message,
    this.type = NeoToastType.info,
    this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final NeoToastType type;
  final String? title;

  /// Defaults to an icon matching [type].
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  static Color colorFor(NeoToastType type, NeoThemeData theme) =>
      switch (type) {
        NeoToastType.info => theme.colors.info,
        NeoToastType.success => theme.colors.success,
        NeoToastType.warning => theme.colors.warning,
        NeoToastType.error => theme.colors.danger,
      };

  static IconData iconFor(NeoToastType type) => switch (type) {
    NeoToastType.info => Icons.info_outline,
    NeoToastType.success => Icons.check_circle_outline,
    NeoToastType.warning => Icons.warning_amber_rounded,
    NeoToastType.error => Icons.error_outline,
  };

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final fill = colorFor(type, theme);
    final ink = theme.colors.onColor(fill);
    return Semantics(
      container: true,
      liveRegion: true,
      child: DefaultTextStyle(
        style: theme.typography.bodyStrong.copyWith(color: ink),
        child: NeoSurface(
          color: fill,
          padding: EdgeInsetsDirectional.fromSTEB(
            theme.spacing.lg,
            theme.spacing.md,
            theme.spacing.md,
            theme.spacing.md,
          ),
          child: Row(
            children: [
              Icon(icon ?? iconFor(type), color: ink),
              SizedBox(width: theme.spacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: theme.typography.titleSmall.copyWith(color: ink),
                      ),
                    Text(message),
                  ],
                ),
              ),
              if (actionLabel != null) ...[
                SizedBox(width: theme.spacing.sm),
                NeoButton(
                  label: actionLabel!,
                  size: NeoButtonSize.small,
                  variant: NeoButtonVariant.outlined,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
