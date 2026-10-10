import 'package:flutter/material.dart';

import '../../primitives/neo_pressable.dart';
import '../../theme/neo_theme.dart';
import 'neo_control_row.dart';

/// An on/off switch with a square thumb that slides across a bordered track.
/// Disabled when [onChanged] is null.
class NeoSwitch extends StatelessWidget {
  const NeoSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.activeColor,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  /// Track fill when on. Defaults to the theme success color.
  final Color? activeColor;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final colors = theme.colors;
    final enabled = onChanged != null;
    final duration = neoAnimationDuration(context, theme.motion.fast);
    final trackFill = !enabled
        ? colors.surfaceMuted
        : (value ? (activeColor ?? colors.success) : colors.surfaceMuted);
    final track = AnimatedContainer(
      duration: duration,
      width: 52,
      height: 30,
      padding: const EdgeInsets.all(2),
      decoration: theme.decoration(
        color: trackFill,
        radius: theme.radii.sm,
        shadow: enabled ? theme.shadows.sm : Offset.zero,
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: theme.motion.curve,
        alignment: value
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: enabled ? colors.surface : colors.inkSubtle,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: colors.border,
              width: theme.borders.regular,
            ),
          ),
        ),
      ),
    );
    return NeoPressable(
      onPressed: enabled ? () => onChanged!(!value) : null,
      isButton: false,
      toggled: value,
      semanticLabel: semanticLabel,
      focusNode: focusNode,
      autofocus: autofocus,
      focusRadius: BorderRadius.circular(theme.radii.sm),
      builder: (context, states, press) =>
          NeoControlRow(control: track, label: label, enabled: enabled),
    );
  }
}
