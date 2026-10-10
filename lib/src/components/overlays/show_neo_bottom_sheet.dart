import 'package:flutter/material.dart';

import '../../foundation/neo_strings.dart';
import '../../theme/neo_theme.dart';
import '../buttons/neo_button.dart';
import 'neo_bottom_sheet.dart';

/// Shows [builder]'s widget (typically a [NeoBottomSheet]) as a modal sheet
/// over the theme scrim. Set [isScrollControlled] for tall or keyboard-aware
/// content.
Future<T?> showNeoBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
}) {
  final theme = NeoTheme.of(context);
  final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  return showModalBottomSheet<T>(
    context: context,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: isScrollControlled
            ? MediaQuery.viewInsetsOf(context).bottom
            : 0,
      ),
      child: builder(context),
    ),
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    useSafeArea: true,
    backgroundColor: theme.colors.surface.withValues(alpha: 0),
    elevation: 0,
    barrierColor: theme.colors.scrim,
    shape: const RoundedRectangleBorder(),
    sheetAnimationStyle: reduced ? AnimationStyle.noAnimation : null,
  );
}

/// One choice of [showNeoActionSheet].
@immutable
class NeoSheetAction<T> {
  const NeoSheetAction({
    required this.label,
    required this.value,
    this.icon,
    this.destructive = false,
  });

  final String label;
  final T value;
  final IconData? icon;

  /// Rendered with the theme danger color.
  final bool destructive;
}

/// Shows a list of [actions] plus a cancel button. Completes with the chosen
/// action's value, or null when cancelled or dismissed.
Future<T?> showNeoActionSheet<T>({
  required BuildContext context,
  required List<NeoSheetAction<T>> actions,
  String? title,
  String? message,
  String? cancelLabel,
}) {
  return showNeoBottomSheet<T>(
    context: context,
    builder: (context) {
      final theme = NeoTheme.of(context);
      final gap = SizedBox(height: theme.spacing.md);
      return NeoBottomSheet(
        title: title,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (message != null) ...[Text(message), gap],
              for (final action in actions) ...[
                NeoButton(
                  label: action.label,
                  icon: action.icon,
                  expanded: true,
                  variant: action.destructive
                      ? NeoButtonVariant.filled
                      : NeoButtonVariant.outlined,
                  color: action.destructive ? theme.colors.danger : null,
                  onPressed: () => Navigator.of(context).pop(action.value),
                ),
                gap,
              ],
              NeoButton(
                label: cancelLabel ?? NeoStrings.of(context).cancel,
                expanded: true,
                variant: NeoButtonVariant.ghost,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
