import 'package:flutter/material.dart';

import '../../foundation/neo_strings.dart';
import '../../theme/neo_theme.dart';
import '../buttons/neo_button.dart';
import 'neo_dialog.dart';

/// Shows [builder]'s widget (typically a [NeoDialog]) centered over the
/// theme scrim with a short scale-and-fade entrance.
Future<T?> showNeoDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  final theme = NeoTheme.of(context);
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  return navigator.push<T>(
    RawDialogRoute<T>(
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? NeoStrings.of(context).dismiss,
      barrierColor: theme.colors.scrim,
      settings: routeSettings,
      transitionDuration: reduced ? Duration.zero : theme.motion.medium,
      pageBuilder: (context, _, _) => themes.wrap(
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(theme.spacing.xl),
            child: Center(child: Builder(builder: builder)),
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: theme.motion.curve,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

/// Asks the user to confirm an action. Completes with `true` only when the
/// confirm button is pressed.
Future<bool> showNeoConfirmDialog({
  required BuildContext context,
  required String title,
  String? message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
  Color? confirmColor,
  bool barrierDismissible = true,
}) async {
  final result = await showNeoDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      final theme = NeoTheme.of(context);
      final strings = NeoStrings.of(context);
      return NeoDialog(
        title: title,
        message: message,
        actions: [
          NeoButton(
            label: cancelLabel ?? strings.cancel,
            variant: NeoButtonVariant.outlined,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          NeoButton(
            label: confirmLabel ?? strings.ok,
            color:
                confirmColor ??
                (destructive ? theme.colors.danger : theme.colors.primary),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
