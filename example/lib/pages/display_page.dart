import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:slab_ui/slab_ui.dart';

import '../catalog/catalog_page.dart';

const String _lorem =
    'Neobrutalism borrows from raw web design: thick outlines, flat saturated '
    'colors and hard offset shadows. It is loud on purpose, yet a solid grid, '
    'generous spacing and strong contrast keep it readable. This quote block '
    'scrolls once the text grows past its max height, and the pink thumb on '
    'the rail can be dragged to scroll through it.';

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    final gap = SizedBox(height: theme.spacing.md);
    return CatalogPage(
      children: [
        const CatalogSection(
          title: 'Banner',
          child: NeoBanner(text: 'PARTIES AROUND'),
        ),
        CatalogSection(
          title: 'Cards',
          child: Column(
            children: [
              NeoCard(
                child: Text('A static card.', style: theme.typography.body),
              ),
              gap,
              NeoCard(
                color: theme.colors.blue,
                onTap: () {},
                child: Text(
                  'A pressable card.',
                  style: theme.typography.bodyStrong,
                ),
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Tags and badges',
          child: DemoWrap(
            children: [
              NeoTag(
                label: 'open',
                icon: Icons.public,
                color: theme.colors.green,
              ),
              NeoTag(
                label: 'private',
                icon: Icons.lock,
                color: theme.colors.yellow,
              ),
              NeoTag(
                label: 'secret',
                icon: Icons.visibility_off,
                color: theme.colors.pink,
                size: NeoTagSize.medium,
              ),
              NeoBadge(
                count: 7,
                child: NeoIconButton(
                  icon: Icons.message,
                  semanticLabel: 'Messages',
                  onPressed: () {},
                ),
              ),
              NeoBadge(
                dot: true,
                child: NeoIconButton(
                  icon: Icons.notifications,
                  semanticLabel: 'Notifications',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Avatars',
          child: DemoWrap(
            children: [
              const NeoAvatar(name: 'Ada Lovelace'),
              const NeoAvatar(name: 'Grace', shape: NeoAvatarShape.circle),
              const NeoAvatar(shape: NeoAvatarShape.square),
              NeoAvatar(
                name: 'Broken Image',
                image: MemoryImage(Uint8List(4)),
                shadow: true,
                size: 64,
              ),
              NeoAvatarGroup(
                max: 3,
                avatars: [
                  for (final n in ['Ann', 'Bo', 'Cy', 'Dee', 'Eve', 'Flo'])
                    NeoAvatar(name: n, size: 40),
                ],
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'List tiles',
          child: Column(
            children: [
              for (final (i, name) in ['Ada', 'Grace', 'Linus'].indexed) ...[
                NeoListTile(
                  leading: NeoAvatar(name: name, size: 40),
                  title: Text(name),
                  subtitle: Text(i == 1 ? 'Unread message' : 'Tap to select'),
                  highlighted: i == 1,
                  selected: _selected == i,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => setState(() => _selected = i),
                ),
                gap,
              ],
              const NeoListTile(
                dense: true,
                title: Text('Dense static tile'),
                subtitle: Text('No interaction'),
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Dividers',
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                const Expanded(child: NeoDivider()),
                SizedBox(width: theme.spacing.lg),
                const NeoDivider.vertical(),
                SizedBox(width: theme.spacing.lg),
                Expanded(
                  child: NeoDivider(thickness: 4, color: theme.colors.pink),
                ),
              ],
            ),
          ),
        ),
        const CatalogSection(
          title: 'Quote block',
          child: NeoQuoteBlock(
            title: 'About',
            text: _lorem,
            thumbSemanticLabel: 'Scroll description',
          ),
        ),
        CatalogSection(
          title: 'Expansion panels',
          child: Column(
            children: [
              const NeoExpansionPanel(
                leading: Icon(Icons.celebration),
                title: Text('Music'),
                subtitle: Text('3 selected'),
                initiallyExpanded: true,
                child: Text('Techno, House, Jazz'),
              ),
              gap,
              NeoExpansionPanel(
                color: theme.colors.lime,
                title: const Text('Sports'),
                child: const Text('Football, Climbing'),
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Chat bubbles',
          child: Column(
            children: [
              const NeoChatBubble(
                text: 'Are you coming tonight?',
                sender: 'Grace',
                timestamp: '18:02',
              ),
              gap,
              const NeoChatBubble(
                text: 'Obviously. Bringing snacks.',
                isMine: true,
                timestamp: '18:03',
                status: Icon(Icons.done_all),
              ),
              gap,
              NeoChatBubble(
                text: 'Long press me',
                color: theme.colors.yellow,
                onLongPress: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
