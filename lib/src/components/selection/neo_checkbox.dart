import 'package:flutter/material.dart';

import '../../primitives/neo_pressable.dart';
import '../../theme/neo_theme.dart';
import 'neo_control_row.dart';

/// A square checkbox with an optional tappable [label].
///
/// With [tristate], a null [value] shows the mixed state and taps cycle
/// unchecked → checked → mixed. Disabled when [onChanged] is null.
class NeoCheckbox extends StatelessWidget {
  const NeoCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.label,
    this.color,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  }) : assert(tristate || value != null);

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final String? label;

  /// Fill when checked. Defaults to the theme primary.
  final Color? color;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  bool? get _next => switch (value) {
    false => true,
    true => tristate ? null : false,
    null => false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final colors = theme.colors;
    final enabled = onChanged != null;
    final on = value != false;
    final fill = !enabled
        ? colors.surfaceMuted
        : (on ? (color ?? colors.primary) : colors.surface);
    final box = AnimatedContainer(
      duration: neoAnimationDuration(context, theme.motion.fast),
      width: 24,
      height: 24,
      decoration: theme.decoration(
        color: fill,
        radius: theme.radii.sm,
        shadow: enabled ? theme.shadows.sm : Offset.zero,
      ),
      child: on
          ? Icon(
              value == null ? Icons.remove : Icons.check,
              size: 18,
              color: enabled ? colors.onColor(fill) : colors.inkFaint,
            )
          : null,
    );
    return NeoPressable(
      onPressed: enabled ? () => onChanged!(_next) : null,
      isButton: false,
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      autofocus: autofocus,
      focusRadius: BorderRadius.circular(theme.radii.sm),
      builder: (context, states, press) => Semantics(
        checked: value ?? false,
        mixed: tristate ? value == null : null,
        child: NeoControlRow(control: box, label: label, enabled: enabled),
      ),
    );
  }
}
