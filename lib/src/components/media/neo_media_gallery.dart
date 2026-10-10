import 'package:flutter/widgets.dart';

import '../../theme/neo_theme.dart';
import 'neo_image.dart';
import 'neo_media_viewer.dart';

/// A horizontal strip of image thumbnails that opens a [NeoMediaViewer].
///
/// With [maxVisible], the last visible thumbnail shows a "+N" overflow count.
class NeoMediaGallery extends StatelessWidget {
  const NeoMediaGallery({
    super.key,
    required this.images,
    this.thumbnailSize = 96,
    this.maxVisible,
    this.onOpen,
    this.heroTagBuilder,
    this.semanticLabelBuilder,
    this.padding = EdgeInsetsDirectional.zero,
  });

  final List<ImageProvider> images;
  final double thumbnailSize;
  final int? maxVisible;

  /// Called with the tapped index instead of opening the built-in viewer.
  final ValueChanged<int>? onOpen;
  final NeoHeroTagBuilder? heroTagBuilder;

  /// Semantic label of a thumbnail. Defaults to "index / count".
  final String Function(int index, int count)? semanticLabelBuilder;
  final EdgeInsetsGeometry padding;

  int get _visible {
    final max = maxVisible;
    return max != null && max > 0 && images.length > max ? max : images.length;
  }

  void _open(BuildContext context, int index) {
    if (onOpen != null) {
      onOpen!(index);
      return;
    }
    showNeoMediaViewer(
      context,
      images: images,
      initialIndex: index,
      heroTagBuilder: heroTagBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    final theme = NeoTheme.of(context);
    final visible = _visible;
    final hidden = images.length - visible;
    final shadow = theme.shadows.sm;
    return SizedBox(
      height: thumbnailSize + shadow.dy,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        clipBehavior: Clip.none,
        itemCount: visible,
        separatorBuilder: (_, _) => SizedBox(width: theme.spacing.sm),
        itemBuilder: (context, i) {
          final label =
              semanticLabelBuilder?.call(i, images.length) ??
              '${i + 1} / ${images.length}';
          final thumb = NeoImage(
            image: images[i],
            width: thumbnailSize,
            height: thumbnailSize,
            shadow: shadow,
            heroTag: heroTagBuilder?.call(i),
            semanticLabel: label,
            onTap: () => _open(context, i),
          );
          if (hidden <= 0 || i != visible - 1) return thumb;
          final border = theme.borders.regular;
          return Stack(
            children: [
              thumb,
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: EdgeInsets.all(border),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        theme.radii.md - border,
                      ),
                      child: ColoredBox(
                        color: theme.colors.scrim,
                        child: Center(
                          child: Text(
                            '+$hidden',
                            style: theme.typography.title.copyWith(
                              color: theme.colors.onDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
