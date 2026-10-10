import 'package:flutter/material.dart';

import '../../foundation/neo_strings.dart';
import '../../theme/neo_theme.dart';
import '../buttons/neo_icon_button.dart';

/// A top bar with a bold title, optional leading widget and actions.
///
/// Shows a back button automatically when the current route can pop and no
/// [leading] is given.
class NeoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NeoAppBar({
    super.key,
    this.title,
    this.titleText,
    this.leading,
    this.actions = const [],
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.color,
    this.showBorder = true,
    this.height = 64,
    this.onBack,
    this.backLabel,
  });

  final Widget? title;

  /// Convenience for a plain text title. Ignored when [title] is set.
  final String? titleText;
  final Widget? leading;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;
  final bool centerTitle;

  /// Bar fill. Defaults to the theme background.
  final Color? color;

  /// Draws a thick bottom border.
  final bool showBorder;
  final double height;

  /// Overrides the implied back button action. Defaults to [Navigator.maybePop].
  final VoidCallback? onBack;
  final String? backLabel;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final fill = color ?? theme.colors.background;
    final canPop = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;
    final lead =
        leading ??
        (automaticallyImplyLeading && canPop
            ? NeoIconButton(
                icon: Icons.arrow_back,
                size: 40,
                semanticLabel: backLabel ?? NeoStrings.of(context).back,
                onPressed: onBack ?? () => Navigator.maybePop(context),
              )
            : null);
    final heading =
        title ??
        (titleText == null
            ? null
            : Text(
                titleText!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.title.copyWith(
                  color: theme.colors.onColor(fill),
                ),
              ));
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          border: showBorder
              ? Border(
                  bottom: BorderSide(
                    color: theme.colors.border,
                    width: theme.borders.thick,
                  ),
                )
              : null,
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: height,
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: theme.spacing.lg,
              ),
              child: NavigationToolbar(
                leading: lead == null
                    ? null
                    : Center(widthFactor: 1, child: lead),
                middle: heading == null
                    ? null
                    : Semantics(header: true, child: heading),
                trailing: actions.isEmpty
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < actions.length; i++) ...[
                            if (i > 0) SizedBox(width: theme.spacing.sm),
                            actions[i],
                          ],
                        ],
                      ),
                centerMiddle: centerTitle,
                middleSpacing: theme.spacing.md,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
