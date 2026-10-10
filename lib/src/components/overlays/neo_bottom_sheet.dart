import 'package:flutter/material.dart';

import '../../theme/neo_theme.dart';

/// The sheet body shown by [showNeoBottomSheet]: a top-bordered panel with a
/// drag handle, optional [title] and the [child] content.
class NeoBottomSheet extends StatelessWidget {
  const NeoBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.color,
    this.padding,
  });

  final Widget child;
  final String? title;
  final bool showDragHandle;

  /// Sheet fill. Defaults to the theme surface.
  final Color? color;

  /// Content padding. Defaults to the large theme spacing.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final fill = color ?? theme.colors.surface;
    final ink = theme.colors.onColor(fill);
    final side = BorderSide(
      color: theme.colors.border,
      width: theme.borders.thick,
    );
    final radius = Radius.circular(theme.radii.lg);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        border: Border(top: side, left: side, right: side),
        borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
      ),
      child: SafeArea(
        top: false,
        child: DefaultTextStyle(
          style: NeoTheme.baseTextStyleOf(context)
              .merge(theme.typography.body.copyWith(color: ink)),
          child: IconTheme.merge(
            data: IconThemeData(color: ink),
            child: Padding(
              padding: padding ?? EdgeInsets.all(theme.spacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showDragHandle)
                    Center(
                      child: Container(
                        width: 44,
                        height: 6,
                        margin: EdgeInsets.only(bottom: theme.spacing.md),
                        decoration: BoxDecoration(
                          color: theme.colors.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  if (title != null) ...[
                    Semantics(
                      header: true,
                      child: Text(
                        title!,
                        style: theme.typography.title.copyWith(color: ink),
                      ),
                    ),
                    SizedBox(height: theme.spacing.md),
                  ],
                  Flexible(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
