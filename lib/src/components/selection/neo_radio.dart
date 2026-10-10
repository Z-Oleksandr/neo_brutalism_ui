import 'package:flutter/material.dart';

import '../../primitives/neo_pressable.dart';
import '../../theme/neo_theme.dart';
import 'neo_control_row.dart';

/// A round radio button selecting [value] within a group sharing
/// [groupValue]. Disabled when [onChanged] is null.
class NeoRadio<T> extends StatelessWidget {
  const NeoRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.color,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final T value;
  final T? groupValue;
  final ValueChanged<T>? onChanged;
  final String? label;

  /// Dot fill. Defaults to the theme primary.
  final Color? color;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final colors = theme.colors;
    final enabled = onChanged != null;
    final selected = value == groupValue;
    final duration = neoAnimationDuration(context, theme.motion.fast);
    final ring = Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: enabled ? colors.surface : colors.surfaceMuted,
        border: Border.all(color: colors.border, width: theme.borders.thick),
        boxShadow: enabled
            ? [BoxShadow(color: colors.shadow, offset: theme.shadows.sm)]
            : null,
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: duration,
        curve: theme.motion.curve,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled ? (color ?? colors.primary) : colors.inkFaint,
            border: Border.all(color: colors.border, width: theme.borders.thin),
          ),
        ),
      ),
    );
    return NeoPressable(
      onPressed: enabled
          ? () {
              if (!selected) onChanged!(value);
            }
          : null,
      isButton: false,
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      autofocus: autofocus,
      focusRadius: BorderRadius.circular(16),
      builder: (context, states, press) => Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: true,
        child: NeoControlRow(control: ring, label: label, enabled: enabled),
      ),
    );
  }
}
