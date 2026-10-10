import 'package:flutter/widgets.dart';

import '../../theme/neo_theme.dart';

/// A selection control followed by an optional label. Internal to the
/// selection widgets.
class NeoControlRow extends StatelessWidget {
  const NeoControlRow({
    super.key,
    required this.control,
    required this.label,
    required this.enabled,
  });

  final Widget control;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (label == null) return control;
    final theme = NeoTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        control,
        SizedBox(width: theme.spacing.sm + 2),
        Flexible(
          child: Text(
            label!,
            style: theme.typography.bodyStrong.copyWith(
              color: enabled ? theme.colors.ink : theme.colors.inkFaint,
            ),
          ),
        ),
      ],
    );
  }
}

Duration neoAnimationDuration(BuildContext context, Duration duration) =>
    MediaQuery.maybeDisableAnimationsOf(context) == true
    ? Duration.zero
    : duration;
