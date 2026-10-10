import 'package:flutter/material.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

import '../catalog/catalog_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller = TabController(length: 3, vsync: this);
  int _tab = 0;
  int _category = 0;
  int _nav = 0;
  Set<String> _range = {'week'};
  Set<String> _days = {'mon', 'wed'};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    return CatalogPage(
      children: [
        CatalogSection(
          title: 'Tab bar',
          child: NeoTabBar(
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
            tabs: const [
              NeoTab(label: 'Friends', icon: Icons.people),
              NeoTab(label: 'Requests', badgeCount: 4),
              NeoTab(icon: Icons.groups, semanticLabel: 'Clubs'),
            ],
          ),
        ),
        CatalogSection(
          title: 'Tab bar with TabController',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeoTabBar(
                controller: _controller,
                activeColor: theme.colors.pink,
                tabs: const [
                  NeoTab(label: 'Posts'),
                  NeoTab(label: 'Members'),
                  NeoTab(label: 'Parties'),
                ],
              ),
              SizedBox(height: theme.spacing.md),
              SizedBox(
                height: 80,
                child: TabBarView(
                  controller: _controller,
                  children: [
                    for (final label in ['Posts', 'Members', 'Parties'])
                      NeoCard(child: Center(child: Text('$label content'))),
                  ],
                ),
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Scrollable tab bar',
          child: NeoTabBar(
            isScrollable: true,
            selectedIndex: _category,
            onChanged: (i) => setState(() => _category = i),
            activeColor: theme.colors.green,
            tabs: [for (final c in _categories) NeoTab(label: c)],
          ),
        ),
        CatalogSection(
          title: 'Segmented control',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeoSegmentedControl<String>(
                selected: _range,
                onChanged: (v) => setState(() => _range = v),
                segments: const [
                  NeoSegment(value: 'day', label: 'Day'),
                  NeoSegment(value: 'week', label: 'Week'),
                  NeoSegment(value: 'month', label: 'Month'),
                ],
              ),
              SizedBox(height: theme.spacing.md),
              NeoSegmentedControl<String>(
                multiSelect: true,
                emptySelectionAllowed: true,
                activeColor: theme.colors.teal,
                selected: _days,
                onChanged: (v) => setState(() => _days = v),
                segments: const [
                  NeoSegment(value: 'mon', label: 'Mon'),
                  NeoSegment(value: 'tue', label: 'Tue'),
                  NeoSegment(value: 'wed', label: 'Wed'),
                  NeoSegment(value: 'thu', label: 'Thu'),
                ],
              ),
              SizedBox(height: theme.spacing.md),
              Text(
                'Showing parties this ${_range.single}'
                '${_days.isEmpty ? '' : ' on ${_days.join(', ')}'}',
                style: theme.typography.bodyStrong.copyWith(
                  color: theme.colors.ink,
                ),
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'App bar',
          child: NeoSurface(
            padding: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: NeoAppBar(
                titleText: 'Club details',
                color: theme.colors.yellow,
                leading: NeoIconButton(
                  icon: Icons.arrow_back,
                  size: 40,
                  semanticLabel: NeoStrings.of(context).back,
                  onPressed: () {},
                ),
                actions: [
                  NeoIconButton(
                    icon: Icons.edit,
                    size: 40,
                    semanticLabel: 'Edit',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
        CatalogSection(
          title: 'Nav bar',
          child: Column(
            children: [
              NeoNavBar(
                currentIndex: _nav,
                onTap: (i) => setState(() => _nav = i),
                margin: EdgeInsets.zero,
                items: const [
                  NeoNavBarItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                  ),
                  NeoNavBarItem(
                    icon: Icons.message_outlined,
                    activeIcon: Icons.message,
                    label: 'Messages',
                    badgeCount: 3,
                  ),
                  NeoNavBarItem(icon: Icons.people, label: 'Social'),
                  NeoNavBarItem(icon: Icons.person, label: 'Profile'),
                ],
              ),
              SizedBox(height: theme.spacing.lg),
              NeoNavBar(
                currentIndex: _nav,
                showLabels: true,
                activeColor: theme.colors.blue,
                onTap: (i) => setState(() => _nav = i),
                margin: EdgeInsets.zero,
                items: const [
                  NeoNavBarItem(icon: Icons.home, label: 'Home'),
                  NeoNavBarItem(
                    icon: Icons.message,
                    label: 'Chat',
                    badgeCount: 3,
                  ),
                  NeoNavBarItem(icon: Icons.people, label: 'Social'),
                  NeoNavBarItem(icon: Icons.person, label: 'Me'),
                ],
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Sliver tab bar',
          child: SizedBox(
            height: 260,
            child: NeoSurface(
              clipBehavior: Clip.antiAlias,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(theme.spacing.lg),
                      child: const NeoBanner(text: 'Scroll me'),
                    ),
                  ),
                  NeoSliverTabBar(
                    backgroundColor: theme.colors.surface,
                    tabBar: const NeoTabBar(
                      tabs: [
                        NeoTab(label: 'Posts'),
                        NeoTab(label: 'About'),
                      ],
                    ),
                  ),
                  SliverList.builder(
                    itemCount: 20,
                    itemBuilder: (_, i) => Padding(
                      padding: EdgeInsets.all(theme.spacing.md),
                      child: Text('Row $i'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const _categories = [
  'Music',
  'Sports',
  'Food',
  'Art',
  'Games',
  'Tech',
  'Outdoors',
  'Film',
  'Dance',
  'Books',
  'Fitness',
  'Travel',
];
