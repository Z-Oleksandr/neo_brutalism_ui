import 'dart:math' as math;

import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

import '../../primitives/neo_pressable.dart';
import '../../theme/neo_theme.dart';
import '../../theme/neo_theme_data.dart';
import '../feedback/neo_skeleton.dart';

/// A bordered image for any [ImageProvider].
///
/// Decodes at the displayed size (logical size × device pixel ratio) when
/// [width] or [height] is known, shows a themed placeholder while loading,
/// fades the image in and falls back to a broken-image tile on error.
class NeoImage extends StatelessWidget {
  const NeoImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.radius,
    this.bordered = true,
    this.color,
    this.borderWidth,
    this.shadow,
    this.placeholder,
    this.errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.onTap,
    this.heroTag,
    this.resize = true,
  });

  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  /// Defaults to the medium theme radius.
  final double? radius;
  final bool bordered;

  /// Backdrop behind the image. Defaults to the muted theme surface.
  final Color? color;

  /// Defaults to the regular theme border.
  final double? borderWidth;

  /// Hard shadow offset. No shadow when null.
  final Offset? shadow;
  final WidgetBuilder? placeholder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final VoidCallback? onTap;
  final Object? heroTag;

  /// Whether to decode at the displayed size.
  final bool resize;

  /// The provider decoded at [width] or [height] times [devicePixelRatio].
  static ImageProvider resolveProvider(
    ImageProvider image, {
    double? width,
    double? height,
    required double devicePixelRatio,
  }) {
    int? px(double? v) => v != null && v.isFinite && v > 0
        ? math.max(1, (v * devicePixelRatio).round())
        : null;
    final w = px(width);
    return ResizeImage.resizeIfNeeded(w, w == null ? px(height) : null, image);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final r = radius ?? theme.radii.md;
    final b = bordered ? (borderWidth ?? theme.borders.regular) : 0.0;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final provider = resize
        ? resolveProvider(
            image,
            width: width,
            height: height,
            devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
          )
        : image;
    final hasAction = onTap != null;

    Widget picture = Image(
      image: provider,
      width: width == null ? null : double.infinity,
      height: height == null ? null : double.infinity,
      fit: fit,
      alignment: alignment,
      gaplessPlayback: true,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics || hasAction,
      frameBuilder: (context, child, frame, sync) {
        if (sync) return child;
        return AnimatedSwitcher(
          duration: reduced ? Duration.zero : theme.motion.medium,
          child: frame == null
              ? KeyedSubtree(
                  key: const ValueKey(false),
                  child: placeholder?.call(context) ?? _placeholder(theme),
                )
              : KeyedSubtree(key: const ValueKey(true), child: child),
        );
      },
      errorBuilder:
          errorBuilder ??
          (context, error, stack) => _ErrorTile(
            width: width == null ? null : double.infinity,
            height: height == null ? null : double.infinity,
          ),
    );

    if (heroTag != null) picture = Hero(tag: heroTag!, child: picture);

    final content = Container(
      width: width,
      height: height,
      decoration: bordered
          ? theme.decoration(
              color: color ?? theme.colors.surfaceMuted,
              radius: r,
              borderWidth: b,
              shadow: shadow ?? Offset.zero,
            )
          : BoxDecoration(
              color: color ?? theme.colors.surfaceMuted,
              borderRadius: BorderRadius.circular(r),
              boxShadow: shadow == null
                  ? null
                  : [BoxShadow(color: theme.colors.shadow, offset: shadow!)],
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(math.max(0, r - b)),
        child: picture,
      ),
    );

    if (!hasAction) return content;
    return NeoPressable(
      onPressed: onTap,
      semanticLabel: semanticLabel,
      minTapTarget: Size.zero,
      focusRadius: BorderRadius.circular(r),
      builder: (context, states, press) => content,
    );
  }

  Widget _placeholder(NeoThemeData theme) => NeoShimmer(
    child: NeoSkeleton(
      width: width == null ? null : double.infinity,
      height: height == null ? null : double.infinity,
      radius: 0,
    ),
  );
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = NeoTheme.of(context).colors;
    return Container(
      width: width,
      height: height,
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, c) {
          final side = math.min(
            c.hasBoundedWidth ? c.maxWidth : 32.0,
            c.hasBoundedHeight ? c.maxHeight : 32.0,
          );
          return Icon(
            Icons.broken_image_outlined,
            size: (side * 0.4).clamp(16.0, 48.0),
            color: colors.inkFaint,
          );
        },
      ),
    );
  }
}
