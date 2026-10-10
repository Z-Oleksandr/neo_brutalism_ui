import 'package:flutter/widgets.dart';

import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';
import '../buttons/neo_button.dart';

/// Placeholder for empty lists and screens with an optional call to action.
class NeoEmptyState extends StatelessWidget {
  const NeoEmptyState({
    super.key,
    required this.title,
    this.icon,
    this.message,
    this.actionLabel,
    this.onAction,
    this.color,
  });

  final String title;
  final IconData? icon;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Icon tile fill. Defaults to the theme primary.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final s = theme.spacing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          ExcludeSemantics(
            child: NeoSurface(
              width: 72,
              height: 72,
              radius: theme.radii.lg,
              color: color ?? theme.colors.primary,
              alignment: Alignment.center,
              child: Icon(icon, size: 36),
            ),
          ),
          SizedBox(height: s.xl),
        ],
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.typography.title.copyWith(color: theme.colors.ink),
          ),
        ),
        if (message != null) ...[
          SizedBox(height: s.sm),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: theme.typography.body.copyWith(color: theme.colors.inkMuted),
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          SizedBox(height: s.xl),
          NeoButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    );
  }
}
