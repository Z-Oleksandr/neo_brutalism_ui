import 'package:flutter/material.dart';

import '../../foundation/neo_strings.dart';
import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';
import '../buttons/neo_button.dart';

MaterialLocalizations neoMaterialLocalizations(BuildContext context) =>
    Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) ??
    const DefaultMaterialLocalizations();

/// Presents [builder] as a centered modal over a scrim. Dismissing via the
/// barrier completes with null.
Future<T?> showNeoPickerDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final theme = NeoTheme.of(context);
  final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  final duration = reduced ? Duration.zero : theme.motion.fast;
  return navigator.push<T>(
    RawDialogRoute<T>(
      barrierDismissible: barrierDismissible,
      barrierLabel: NeoStrings.of(context).dismiss,
      barrierColor: theme.colors.scrim,
      transitionDuration: duration,
      pageBuilder: (context, animation, secondary) =>
          themes.wrap(SafeArea(child: Builder(builder: builder))),
      transitionBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: theme.motion.curve,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

/// The neobrutalist dialog body shared by all pickers: title, scrollable
/// content and a cancel/confirm footer.
class NeoPickerFrame extends StatelessWidget {
  const NeoPickerFrame({
    super.key,
    required this.title,
    required this.child,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    required this.onCancel,
    this.header,
    this.message,
    this.maxWidth = 400,
  });

  final String title;
  final Widget child;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback onCancel;
  final Widget? header;
  final String? message;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final spacing = theme.spacing;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DefaultTextStyle(
            style: theme.typography.body.copyWith(
              color: theme.colors.ink,
              decoration: TextDecoration.none,
            ),
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: title,
              child: NeoSurface(
                radius: theme.radii.lg,
                padding: EdgeInsetsDirectional.fromSTEB(
                  spacing.lg,
                  spacing.lg,
                  spacing.lg + theme.shadows.md.dx,
                  spacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(title, style: theme.typography.title),
                          ),
                        ),
                        ?header,
                      ],
                    ),
                    SizedBox(height: spacing.md),
                    Flexible(
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        child: child,
                      ),
                    ),
                    if (message != null) ...[
                      SizedBox(height: spacing.sm),
                      Semantics(
                        liveRegion: true,
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 18,
                              color: theme.colors.danger,
                            ),
                            SizedBox(width: spacing.xs),
                            Expanded(
                              child: Text(
                                message!,
                                style: theme.typography.caption.copyWith(
                                  color: theme.colors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: spacing.lg),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: spacing.sm,
                      runSpacing: spacing.sm,
                      children: [
                        NeoButton(
                          label: cancelLabel,
                          variant: NeoButtonVariant.outlined,
                          size: NeoButtonSize.small,
                          onPressed: onCancel,
                        ),
                        NeoButton(
                          label: confirmLabel,
                          size: NeoButtonSize.small,
                          onPressed: onConfirm,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
