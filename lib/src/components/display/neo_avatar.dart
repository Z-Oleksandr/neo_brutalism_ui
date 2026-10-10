import 'package:flutter/material.dart';

import '../../theme/neo_theme.dart';

enum NeoAvatarShape { square, rounded, circle }

/// A bordered avatar showing [image], falling back to initials of [name] or
/// [icon] while missing or when the image fails to load.
///
/// Images are decoded at the displayed pixel size when the provider allows it.
class NeoAvatar extends StatelessWidget {
  const NeoAvatar({
    super.key,
    this.image,
    this.name,
    this.icon = Icons.person,
    this.size = 48,
    this.shape = NeoAvatarShape.rounded,
    this.color,
    this.border = true,
    this.shadow = false,
    this.semanticLabel,
  });

  final ImageProvider? image;

  /// Source of the initials fallback and default semantic label.
  final String? name;
  final IconData icon;
  final double size;
  final NeoAvatarShape shape;

  /// Fallback fill. Defaults to an accent derived from [name].
  final Color? color;
  final bool border;
  final bool shadow;
  final String? semanticLabel;

  static String initialsOf(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(2).map((w) => w.characters.first.toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final borderWidth = border ? theme.borders.regular : 0.0;
    final outer = switch (shape) {
      NeoAvatarShape.square => BorderRadius.zero,
      NeoAvatarShape.rounded => BorderRadius.circular(theme.radii.md),
      NeoAvatarShape.circle => BorderRadius.circular(size / 2),
    };
    final inner = outer.subtract(BorderRadius.circular(borderWidth));
    final accents = theme.colors.accents;
    final fill =
        color ??
        (name == null || name!.isEmpty
            ? theme.colors.surfaceMuted
            : accents[name!.codeUnits.fold(0, (a, b) => a + b) %
                  accents.length]);
    final fallback = _Fallback(
      initials: name == null ? '' : initialsOf(name!),
      icon: icon,
      size: size,
      color: fill,
    );

    Widget content = fallback;
    if (image != null) {
      final px = (size * MediaQuery.devicePixelRatioOf(context)).round();
      content = Image(
        image: ResizeImage.resizeIfNeeded(px, null, image!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        excludeFromSemantics: true,
        frameBuilder: (context, child, frame, sync) =>
            frame == null && !sync ? fallback : child,
        errorBuilder: (context, error, stack) => fallback,
      );
    }

    return Semantics(
      image: true,
      label: semanticLabel ?? name,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: outer,
          border: border
              ? Border.all(color: theme.colors.border, width: borderWidth)
              : null,
          boxShadow: shadow
              ? [
                  BoxShadow(
                    color: theme.colors.shadow,
                    offset: theme.shadows.md,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(borderRadius: inner, child: content),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.initials,
    required this.icon,
    required this.size,
    required this.color,
  });

  final String initials;
  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final fg = theme.colors.onColor(color);
    return ExcludeSemantics(
      child: ColoredBox(
        color: color,
        child: Center(
          child: initials.isEmpty
              ? Icon(icon, size: size * 0.5, color: fg)
              : Text(
                  initials,
                  maxLines: 1,
                  textScaler: TextScaler.noScaling,
                  style: theme.typography.label.copyWith(
                    fontSize: size * (initials.length > 1 ? 0.36 : 0.42),
                    fontWeight: FontWeight.w900,
                    color: fg,
                  ),
                ),
        ),
      ),
    );
  }
}
