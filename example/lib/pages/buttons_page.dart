import 'package:flutter/material.dart';
import 'package:slab_ui/slab_ui.dart';

import '../catalog/catalog_page.dart';

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({super.key});

  @override
  State<ButtonsPage> createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  bool _loading = false;

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.neo.colors;
    return CatalogPage(
      children: [
        CatalogSection(
          title: 'Variants',
          child: DemoWrap(
            children: [
              for (final v in NeoButtonVariant.values)
                NeoButton(label: v.name, onPressed: () {}, variant: v),
            ],
          ),
        ),
        CatalogSection(
          title: 'Sizes and icons',
          child: DemoWrap(
            children: [
              NeoButton(
                label: 'Small',
                size: NeoButtonSize.small,
                icon: Icons.add,
                onPressed: () {},
              ),
              NeoButton(label: 'Medium', icon: Icons.add, onPressed: () {}),
              NeoButton(
                label: 'Large',
                size: NeoButtonSize.large,
                trailingIcon: Icons.arrow_forward,
                onPressed: () {},
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Colors',
          child: DemoWrap(
            children: [
              for (final c in colors.accents)
                NeoButton(label: 'Go', color: c, onPressed: () {}),
            ],
          ),
        ),
        CatalogSection(
          title: 'States',
          child: DemoWrap(
            children: [
              const NeoButton(label: 'Disabled'),
              NeoButton(
                label: 'Load data',
                isLoading: _loading,
                onPressed: _load,
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Expanded',
          child: NeoButton(
            label: 'Continue',
            expanded: true,
            size: NeoButtonSize.large,
            onPressed: () {},
          ),
        ),
        CatalogSection(
          title: 'Icon buttons',
          child: DemoWrap(
            children: [
              NeoIconButton(
                icon: Icons.favorite,
                semanticLabel: 'Like',
                color: colors.pink,
                onPressed: () {},
              ),
              NeoIconButton(
                icon: Icons.share,
                semanticLabel: 'Share',
                onPressed: () {},
              ),
              const NeoIconButton(icon: Icons.block, semanticLabel: 'Blocked'),
            ],
          ),
        ),
        CatalogSection(
          title: 'Icon button sizes (36, 44, 56)',
          child: DemoWrap(
            children: [
              for (final size in const [36.0, 44.0, 56.0])
                NeoIconButton(
                  icon: Icons.close,
                  semanticLabel: 'Close',
                  size: size,
                  onPressed: () {},
                ),
            ],
          ),
        ),
      ],
    );
  }
}
