import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/neo_theme.dart';

/// Overlapping row of avatars with a `+N` tile for the overflow.
class NeoAvatarGroup extends StatelessWidget {
  const NeoAvatarGroup({
    super.key,
    required this.avatars,
    this.size = 40,
    this.max = 4,
    this.overlap = 0.3,
    this.semanticLabel,
  });

  /// Usually [NeoAvatar]s built with the same [size].
  final List<Widget> avatars;
  final double size;

  /// Avatars shown before collapsing into the `+N` tile.
  final int max;

  /// Fraction of [size] each avatar overlaps the previous one.
  final double overlap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final visible = avatars.take(max).toList();
    final extra = avatars.length - visible.length;
    final step = size * (1 - overlap.clamp(0.0, 0.9));
    final count = visible.length + (extra > 0 ? 1 : 0);
    final width = count == 0 ? 0.0 : size + step * (count - 1);

    return Semantics(
      container: true,
      label: semanticLabel,
      child: SizedBox(
        width: width,
        height: size + theme.shadows.sm.dy,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < visible.length; i++)
              PositionedDirectional(
                start: step * i,
                top: 0,
                width: size,
                height: size,
                child: visible[i],
              ),
            if (extra > 0)
              PositionedDirectional(
                start: step * visible.length,
                top: 0,
                width: size,
                height: size,
                child: Container(
                  alignment: Alignment.center,
                  decoration: theme.decoration(
                    color: theme.colors.ink,
                    radius: theme.radii.md,
                    borderWidth: theme.borders.regular,
                    shadow: Offset.zero,
                  ),
                  child: Text(
                    '+$extra',
                    textScaler: TextScaler.noScaling,
                    style: theme.typography.label.copyWith(
                      fontSize: math.max(10, size * 0.32),
                      color: theme.colors.onColor(theme.colors.ink),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
