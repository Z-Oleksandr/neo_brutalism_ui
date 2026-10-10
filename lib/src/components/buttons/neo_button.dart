import 'package:flutter/widgets.dart';

import '../../primitives/neo_pressable.dart';
import '../../primitives/neo_pressable_surface.dart';
import '../../theme/neo_theme.dart';
import '../../theme/neo_theme_data.dart';
import '../feedback/neo_loading_dots.dart';

enum NeoButtonVariant {
  /// Accent fill, border and shadow.
  filled,

  /// Surface fill, border and shadow.
  outlined,

  /// Ink fill with inverted text.
  inverted,

  /// No border or shadow until pressed or hovered.
  ghost,
}

enum NeoButtonSize { small, medium, large }

/// A labeled button that presses down onto its hard shadow.
///
/// Disabled when [onPressed] and [onLongPress] are null. While [isLoading]
/// the label is replaced by [NeoLoadingDots] and taps are ignored, keeping the
/// button's width stable.
class NeoButton extends StatelessWidget {
  const NeoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.onLongPress,
    this.icon,
    this.trailingIcon,
    this.variant = NeoButtonVariant.filled,
    this.size = NeoButtonSize.medium,
    this.color,
    this.expanded = false,
    this.isLoading = false,
    this.radius,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final IconData? icon;
  final IconData? trailingIcon;
  final NeoButtonVariant variant;
  final NeoButtonSize size;

  /// Fill for [NeoButtonVariant.filled]. Defaults to the theme primary.
  final Color? color;

  /// Stretches to the available width.
  final bool expanded;
  final bool isLoading;
  final double? radius;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final metrics = _Metrics.of(size, theme);
    final busy = isLoading;
    final pressed = busy ? null : onPressed;
    final longPressed = busy ? null : onLongPress;
    final enabled = onPressed != null || onLongPress != null;
    final fill = _fill(theme);
    final fg = enabled ? theme.colors.onColor(fill) : theme.colors.inkFaint;

    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: metrics.icon),
          SizedBox(width: metrics.gap),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: metrics.text,
          ),
        ),
        if (trailingIcon != null) ...[
          SizedBox(width: metrics.gap),
          Icon(trailingIcon, size: metrics.icon),
        ],
      ],
    );

    final body = busy
        ? Stack(
            alignment: Alignment.center,
            children: [
              Visibility.maintain(visible: false, child: content),
              NeoLoadingDots(size: metrics.icon / 3, color: fg),
            ],
          )
        : content;

    if (variant == NeoButtonVariant.ghost) {
      return _GhostButton(
        onPressed: pressed,
        onLongPress: longPressed,
        metrics: metrics,
        radius: radius ?? theme.radii.md,
        semanticLabel: semanticLabel,
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: enabled,
        child: body,
      );
    }

    return NeoPressableSurface(
      onPressed: pressed,
      onLongPress: longPressed,
      color: fill,
      disabledColor: busy ? fill : null,
      shadow: busy ? Offset.zero : null,
      radius: radius,
      padding: metrics.padding,
      constraints: BoxConstraints(minHeight: metrics.height),
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      autofocus: autofocus,
      width: expanded ? double.infinity : null,
      child: body,
    );
  }

  Color _fill(NeoThemeData theme) => switch (variant) {
    NeoButtonVariant.filled => color ?? theme.colors.primary,
    NeoButtonVariant.outlined => theme.colors.surface,
    NeoButtonVariant.inverted => theme.colors.ink,
    NeoButtonVariant.ghost => const Color(0x00000000),
  };
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.child,
    required this.onPressed,
    required this.onLongPress,
    required this.metrics,
    required this.radius,
    required this.semanticLabel,
    required this.focusNode,
    required this.autofocus,
    required this.enabled,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final _Metrics metrics;
  final double radius;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = NeoTheme.of(context).colors;
    return NeoPressable(
      onPressed: onPressed,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      autofocus: autofocus,
      focusRadius: BorderRadius.circular(radius),
      builder: (context, states, press) {
        final active =
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered);
        final fg = enabled ? colors.ink : colors.inkFaint;
        return Container(
          constraints: BoxConstraints(minHeight: metrics.height),
          padding: metrics.padding,
          decoration: BoxDecoration(
            color: active ? colors.surfaceMuted : null,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: fg),
            child: IconTheme.merge(
              data: IconThemeData(color: fg),
              child: Center(widthFactor: 1, heightFactor: 1, child: child),
            ),
          ),
        );
      },
    );
  }
}

class _Metrics {
  const _Metrics({
    required this.height,
    required this.padding,
    required this.icon,
    required this.gap,
    required this.text,
  });

  factory _Metrics.of(NeoButtonSize size, NeoThemeData theme) {
    final label = theme.typography.label;
    return switch (size) {
      NeoButtonSize.small => _Metrics(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        icon: 16,
        gap: 6,
        text: label.copyWith(fontSize: 13),
      ),
      NeoButtonSize.medium => _Metrics(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        icon: 18,
        gap: 8,
        text: label,
      ),
      NeoButtonSize.large => _Metrics(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        icon: 20,
        gap: 8,
        text: label.copyWith(fontSize: 16),
      ),
    };
  }

  final double height;
  final EdgeInsets padding;
  final double icon;
  final double gap;
  final TextStyle text;
}
