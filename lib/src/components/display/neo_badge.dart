import 'package:flutter/widgets.dart';

import '../../theme/neo_theme.dart';

/// Overlays a count or dot on the top-end corner of [child].
///
/// Hidden when [count] is null or zero and [dot] is false.
class NeoBadge extends StatelessWidget {
  const NeoBadge({
    super.key,
    required this.child,
    this.count,
    this.dot = false,
    this.max = 99,
    this.color,
    this.semanticLabel,
  });

  final Widget child;
  final int? count;
  final bool dot;

  /// Counts above this show as `max+`.
  final int max;

  /// Badge fill. Defaults to the theme pink.
  final Color? color;
  final String? semanticLabel;

  bool get _visible => dot || (count != null && count! > 0);

  @override
  Widget build(BuildContext context) {
    if (!_visible) return child;
    final theme = NeoTheme.of(context);
    final fill = color ?? theme.colors.pink;
    final text = dot ? null : (count! > max ? '$max+' : '$count');
    final badge = Container(
      constraints: BoxConstraints(
        minWidth: dot ? 12 : 20,
        minHeight: dot ? 12 : 20,
      ),
      padding: dot ? null : const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.regular,
        ),
        borderRadius: BorderRadius.circular(dot ? 6 : 10),
      ),
      child: text == null
          ? null
          : Text(
              text,
              style: theme.typography.overline.copyWith(
                color: theme.colors.onColor(fill),
                fontSize: 11,
                height: 1,
              ),
            ),
    );
    return Semantics(
      label: semanticLabel ?? text,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          PositionedDirectional(
            top: dot ? -4 : -8,
            end: dot ? -4 : -8,
            child: ExcludeSemantics(child: badge),
          ),
        ],
      ),
    );
  }
}
