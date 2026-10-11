import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:slab_ui/slab_ui.dart';

import '../catalog/catalog_page.dart';

Future<ImageProvider> _paint(Color fill, Color ink, int seed) async {
  const size = 480.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Offset(0, 0) & const Size(size, size),
    Paint()..color = fill,
  );
  final random = math.Random(seed);
  final paint = Paint()..color = ink;
  for (var i = 0; i < 5; i++) {
    final s = 40 + random.nextDouble() * 120;
    canvas.drawRect(
      Rect.fromLTWH(
        random.nextDouble() * (size - s),
        random.nextDouble() * (size - s),
        s,
        s,
      ),
      paint,
    );
  }
  final image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return MemoryImage(bytes!.buffer.asUint8List());
}

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  Future<List<ImageProvider>>? _images;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colors = context.neo.colors;
    _images ??= Future.wait([
      for (final (i, c) in colors.accents.indexed)
        _paint(c, colors.onColor(c), i),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ImageProvider>>(
      future: _images,
      builder: (context, snapshot) {
        final images = snapshot.data;
        if (images == null) return const Center(child: NeoLoadingDots());
        return CatalogPage(
          children: [
            CatalogSection(
              title: 'Image',
              child: DemoWrap(
                children: [
                  NeoImage(
                    image: images[0],
                    width: 96,
                    height: 96,
                    semanticLabel: 'Yellow',
                  ),
                  NeoImage(
                    image: images[1],
                    width: 96,
                    height: 96,
                    shadow: context.neo.shadows.md,
                    semanticLabel: 'Pink, tap to open',
                    onTap: () => showNeoMediaViewer(
                      context,
                      images: images,
                      initialIndex: 1,
                    ),
                  ),
                  NeoImage(image: images[2], width: 160, height: 96, radius: 0),
                  NeoImage(
                    image: MemoryImage(Uint8List.fromList(const [0, 1, 2])),
                    width: 96,
                    height: 96,
                  ),
                ],
              ),
            ),
            CatalogSection(
              title: 'Gallery',
              child: NeoMediaGallery(
                images: images,
                maxVisible: 4,
                heroTagBuilder: (i) => 'gallery-$i',
              ),
            ),
            CatalogSection(
              title: 'Viewer',
              child: NeoButton(
                label: 'Open viewer',
                icon: Icons.fullscreen,
                onPressed: () => showNeoMediaViewer(context, images: images),
              ),
            ),
          ],
        );
      },
    );
  }
}
