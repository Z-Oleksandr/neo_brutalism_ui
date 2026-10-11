/// Renders the README and pub.dev screenshots into `doc/screenshots`.
///
/// Run from `example/`: `flutter test tool/screenshots_test.dart`
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slab_ui/slab_ui.dart';

const _output = '../doc/screenshots';
const _sceneSize = Size(560, 400);
const _heroSize = Size(420, 640);

void main() {
  setUpAll(_loadFonts);

  _shot('hero_light', _heroSize, (_) => const _Hero());
  _shot('hero_dark', _heroSize, (_) => const _Hero(), dark: true);
  _shot('buttons', _sceneSize, (_) => const _Buttons());
  _shot('inputs', _sceneSize, (_) => const _Inputs());
  _shot('selection', _sceneSize, (_) => const _Selection());
  _shot('navigation', _sceneSize, (_) => const _Navigation());
  _shot('overlays', _sceneSize, (_) => const _Overlays(), padded: false);
  _shot('feedback', _sceneSize, (_) => const _Feedback());
  _shot('display', _sceneSize, (_) => const _Display());
  _shot('pickers', _sceneSize, (_) => const _Pickers());
}

void _shot(
  String name,
  Size size,
  WidgetBuilder scene, {
  bool dark = false,
  bool padded = true,
}) {
  testWidgets(name, (tester) async {
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final theme = dark
        ? NeoThemeData.dark(fontFamily: 'Roboto')
        : NeoThemeData.light(fontFamily: 'Roboto');
    final key = UniqueKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme.toThemeData(),
        home: RepaintBoundary(
          key: key,
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(padded ? 24 : 0),
              child: Builder(builder: scene),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    expect(tester.takeException(), isNull);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final file = File('$_output/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(png!.buffer.asUint8List());
    });
  });
}

Future<void> _loadFonts() async {
  final exe = Platform.resolvedExecutable;
  final cache = '${Platform.pathSeparator}bin${Platform.pathSeparator}cache';
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      exe.substring(0, exe.indexOf(cache));
  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  Future<ByteData> read(File f) async =>
      ByteData.sublistView(await f.readAsBytes());
  final files = dir.listSync().whereType<File>();
  final roboto = FontLoader('Roboto');
  for (final f in files.where((f) => f.path.contains('Roboto-'))) {
    roboto.addFont(read(f));
  }
  final icons = FontLoader('MaterialIcons')
    ..addFont(read(files.firstWhere((f) => f.path.endsWith('.otf'))));
  await Future.wait([roboto.load(), icons.load()]);
}

class _Gap extends StatelessWidget {
  const _Gap([this.factor = 1]);

  final double factor;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: context.neo.spacing.lg * factor);
}

class _Row extends StatelessWidget {
  const _Row(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: context.neo.spacing.md,
    runSpacing: context.neo.spacing.md,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    final colors = theme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NeoBanner(text: 'SLAB UI'),
        const _Gap(),
        NeoCard(
          color: colors.yellow,
          child: Row(
            children: [
              const NeoAvatar(name: 'Rooftop Session'),
              SizedBox(width: theme.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rooftop session', style: theme.typography.title),
                    Text('Tonight, 21:00', style: theme.typography.caption),
                  ],
                ),
              ),
              NeoTag(label: 'open', icon: Icons.public, color: colors.green),
            ],
          ),
        ),
        const _Gap(),
        const NeoTextField(
          label: 'Email',
          hintText: 'you@example.com',
          prefixIcon: Icons.mail,
        ),
        const _Gap(),
        NeoSwitch(value: true, label: 'Notifications', onChanged: (_) {}),
        const _Gap(0.5),
        _Row([
          for (final (i, tag) in const ['Music', 'Art', 'Food'].indexed)
            NeoChip(
              label: tag,
              color: colors.accents[i + 2],
              selected: i.isEven,
              onSelected: (_) {},
            ),
        ]),
        const _Gap(),
        Row(
          children: [
            Expanded(
              child: NeoButton(
                label: 'Join party',
                icon: Icons.add,
                expanded: true,
                onPressed: () {},
              ),
            ),
            SizedBox(width: theme.spacing.md),
            NeoIconButton(
              icon: Icons.favorite,
              semanticLabel: 'Like',
              color: colors.pink,
              onPressed: () {},
            ),
          ],
        ),
        const _Gap(),
        const NeoToast(message: 'Saved to drafts', type: NeoToastType.success),
        const Spacer(),
        NeoNavBar(
          currentIndex: 0,
          margin: EdgeInsets.zero,
          onTap: (_) {},
          items: const [
            NeoNavBarItem(icon: Icons.home, label: 'Home'),
            NeoNavBarItem(icon: Icons.message, label: 'Chat', badgeCount: 3),
            NeoNavBarItem(icon: Icons.people, label: 'Social'),
            NeoNavBarItem(icon: Icons.person, label: 'Me'),
          ],
        ),
      ],
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons();

  @override
  Widget build(BuildContext context) {
    final colors = context.neo.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Row([
          for (final v in NeoButtonVariant.values)
            NeoButton(label: v.name, variant: v, onPressed: () {}),
        ]),
        const _Gap(),
        _Row([
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
        ]),
        const _Gap(),
        _Row([
          for (final c in [colors.pink, colors.blue, colors.green, colors.lime])
            NeoButton(label: 'Go', color: c, onPressed: () {}),
        ]),
        const _Gap(),
        _Row([
          const NeoButton(label: 'Disabled'),
          NeoButton(label: 'Loading', isLoading: true, onPressed: () {}),
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
        ]),
        const _Gap(),
        NeoButton(
          label: 'Continue',
          expanded: true,
          size: NeoButtonSize.large,
          color: colors.blue,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _Inputs extends StatelessWidget {
  const _Inputs();

  @override
  Widget build(BuildContext context) {
    final colors = context.neo.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: NeoTextField(
                label: 'Name',
                hintText: 'Ada Lovelace',
                prefixIcon: Icons.person,
                autofocus: true,
              ),
            ),
            SizedBox(width: context.neo.spacing.lg),
            const Expanded(
              child: NeoTextField(
                label: 'Email',
                hintText: 'you@example.com',
                errorText: 'Enter a valid email',
              ),
            ),
          ],
        ),
        const _Gap(),
        NeoTextField(
          label: 'Password',
          hintText: 'At least 8 characters',
          obscureText: true,
          prefixIcon: Icons.lock,
          suffix: NeoPressable(
            semanticLabel: 'Show password',
            onPressed: () {},
            builder: (_, _, _) => const Icon(Icons.visibility, size: 20),
          ),
        ),
        const _Gap(),
        NeoSearchField(hintText: 'Search parties', onChanged: (_) {}),
        const _Gap(),
        _Row([
          NeoDropdown<String>(
            items: const ['Berlin', 'Kyiv', 'Lisbon'],
            value: 'Berlin',
            color: colors.blue,
            iconBuilder: (_) => Icons.location_city,
            labelBuilder: _identity,
            onChanged: (_) {},
          ),
          NeoDropdown<String>(
            items: const ['Small', 'Medium', 'Large'],
            value: null,
            hint: 'Pick a size',
            labelBuilder: _identity,
            onChanged: (_) {},
          ),
        ]),
      ],
    );
  }
}

class _Selection extends StatelessWidget {
  const _Selection();

  @override
  Widget build(BuildContext context) {
    final colors = context.neo.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeoCheckbox(
                    value: true,
                    label: 'Cheese',
                    color: colors.green,
                    onChanged: (_) {},
                  ),
                  NeoCheckbox(value: false, label: 'Olives', onChanged: (_) {}),
                  NeoRadio<String>(
                    value: 'open',
                    groupValue: 'open',
                    label: 'Open',
                    onChanged: (_) {},
                  ),
                  NeoRadio<String>(
                    value: 'secret',
                    groupValue: 'open',
                    label: 'Secret',
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeoSwitch(
                    value: true,
                    label: 'Notifications',
                    onChanged: (_) {},
                  ),
                  NeoSwitch(
                    value: false,
                    label: 'Share location',
                    onChanged: (_) {},
                  ),
                  NeoSwitch(
                    value: true,
                    label: 'Dark mode',
                    activeColor: colors.blue,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ],
        ),
        const _Gap(),
        _Row([
          for (final (i, tag) in const [
            'Music',
            'Sports',
            'Art',
            'Food',
          ].indexed)
            NeoChip(
              label: tag,
              icon: Icons.tag,
              color: colors.accents[i],
              selected: i.isEven,
              onSelected: (_) {},
            ),
        ]),
        const _Gap(),
        NeoSlider(
          value: 0.6,
          label: 'Volume',
          activeColor: colors.pink,
          onChanged: (_) {},
        ),
      ],
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation();

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeoSurface(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: NeoAppBar(
            titleText: 'Club details',
            color: theme.colors.yellow,
            leading: NeoIconButton(
              icon: Icons.arrow_back,
              size: 40,
              semanticLabel: 'Back',
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
        const _Gap(),
        NeoTabBar(
          onChanged: (_) {},
          tabs: const [
            NeoTab(label: 'Friends', icon: Icons.people),
            NeoTab(label: 'Requests', badgeCount: 4),
            NeoTab(icon: Icons.groups, semanticLabel: 'Clubs'),
          ],
        ),
        const _Gap(),
        NeoSegmentedControl<String>(
          selected: const {'week'},
          activeColor: theme.colors.teal,
          onChanged: (_) {},
          segments: const [
            NeoSegment(value: 'day', label: 'Day'),
            NeoSegment(value: 'week', label: 'Week'),
            NeoSegment(value: 'month', label: 'Month'),
          ],
        ),
        const Spacer(),
        NeoNavBar(
          currentIndex: 1,
          showLabels: true,
          activeColor: theme.colors.blue,
          margin: EdgeInsets.zero,
          onTap: (_) {},
          items: const [
            NeoNavBarItem(icon: Icons.home, label: 'Home'),
            NeoNavBarItem(icon: Icons.message, label: 'Chat', badgeCount: 3),
            NeoNavBarItem(icon: Icons.people, label: 'Social'),
            NeoNavBarItem(icon: Icons.person, label: 'Me'),
          ],
        ),
      ],
    );
  }
}

class _Overlays extends StatelessWidget {
  const _Overlays();

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    final colors = theme.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: EdgeInsets.all(theme.spacing.xl),
          child: Column(
            children: [
              for (final (i, name) in const ['Ada', 'Grace', 'Linus'].indexed)
                Padding(
                  padding: EdgeInsets.only(bottom: theme.spacing.md),
                  child: NeoListTile(
                    leading: NeoAvatar(name: name, size: 40),
                    title: Text(name),
                    subtitle: const Text('Member since 2024'),
                    highlighted: i == 1,
                  ),
                ),
            ],
          ),
        ),
        ColoredBox(color: colors.scrim),
        Center(
          child: SizedBox(
            width: 380,
            child: NeoDialog(
              title: 'Delete club?',
              message: 'All posts and members will be removed.',
              actions: [
                NeoButton(
                  label: 'Cancel',
                  variant: NeoButtonVariant.outlined,
                  onPressed: () {},
                ),
                NeoButton(
                  label: 'Delete',
                  color: colors.danger,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: theme.spacing.xl,
          right: theme.spacing.xl,
          bottom: theme.spacing.xl,
          child: const NeoToast(
            title: 'ERROR',
            message: 'Could not reach the server.',
            type: NeoToastType.error,
            actionLabel: 'Retry',
            onAction: _noop,
          ),
        ),
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback();

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    final colors = theme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NeoAlertBanner(
          type: NeoAlertType.success,
          title: 'SUCCESS',
          message: 'Your party is live.',
        ),
        const _Gap(0.75),
        const NeoAlertBanner(
          type: NeoAlertType.error,
          title: 'ERROR',
          message: 'Upload failed. Check your connection.',
        ),
        const _Gap(0.75),
        const NeoProgressBar(value: 0.65, semanticLabel: 'Upload'),
        const _Gap(0.75),
        NeoShimmer(
          child: NeoCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NeoSkeleton.avatar(size: 48),
                SizedBox(width: theme.spacing.md),
                const Expanded(child: NeoSkeleton.text()),
              ],
            ),
          ),
        ),
        const _Gap(0.75),
        _Row([
          const NeoLoadingDots(),
          NeoLoadingDots(size: 12, color: colors.pink),
          const NeoSticker(label: 'OFFLINE', icon: Icons.wifi_off),
          NeoSticker(
            label: 'NEW!',
            angle: -6,
            color: colors.lime,
            animate: false,
          ),
          NeoSticker(
            label: 'SALE',
            angle: 4,
            color: colors.yellow,
            animate: false,
          ),
        ]),
      ],
    );
  }
}

class _Display extends StatelessWidget {
  const _Display();

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    final colors = theme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeoListTile(
          leading: const NeoAvatar(name: 'Grace', size: 40),
          title: const Text('Grace'),
          subtitle: const Text('Unread message'),
          highlighted: true,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        const _Gap(0.75),
        _Row([
          NeoAvatarGroup(
            max: 3,
            avatars: [
              for (final n in const ['Mia', 'Leo', 'Zoe', 'Kai', 'Eve'])
                NeoAvatar(name: n, size: 40),
            ],
          ),
          NeoTag(label: 'open', icon: Icons.public, color: colors.green),
          NeoTag(label: 'private', icon: Icons.lock, color: colors.yellow),
          NeoBadge(
            count: 7,
            child: NeoIconButton(
              icon: Icons.message,
              semanticLabel: 'Messages',
              onPressed: () {},
            ),
          ),
        ]),
        const _Gap(0.75),
        const NeoChatBubble(
          text: 'Are you coming tonight?',
          sender: 'Grace',
          timestamp: '18:02',
        ),
        const _Gap(0.25),
        const NeoChatBubble(
          text: 'Obviously. Bringing snacks.',
          isMine: true,
          timestamp: '18:03',
          status: Icon(Icons.done_all),
        ),
        const _Gap(0.75),
        NeoCard(
          color: colors.blue,
          child: Text(
            'Cards, banners, quotes and expansion panels too.',
            style: theme.typography.bodyStrong,
          ),
        ),
      ],
    );
  }
}

class _Pickers extends StatelessWidget {
  const _Pickers();

  @override
  Widget build(BuildContext context) {
    final colors = context.neo.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: NeoCard(
            child: NeoCalendar.range(
              firstDate: DateTime(2026),
              lastDate: DateTime(2027, 12, 31),
              initialMonth: DateTime(2026, 10),
              currentDate: DateTime(2026, 10, 11),
              rangeStart: DateTime(2026, 10, 14),
              rangeEnd: DateTime(2026, 10, 18),
              color: colors.teal,
              onRangeChanged: (_, _) {},
            ),
          ),
        ),
        SizedBox(width: context.neo.spacing.lg),
        SizedBox(
          width: 248,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeoCard(
                color: colors.yellow,
                child: NeoTimeSelector(
                  value: const TimeOfDay(hour: 20, minute: 30),
                  minuteInterval: 5,
                  use24HourFormat: true,
                  onChanged: (_) {},
                ),
              ),
              const _Gap(),
              NeoButton(
                label: 'Pick a date',
                icon: Icons.event,
                color: colors.pink,
                onPressed: () {},
              ),
              const _Gap(0.75),
              NeoButton(
                label: 'Pick a range',
                icon: Icons.date_range,
                variant: NeoButtonVariant.outlined,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _identity(String s) => s;

void _noop() {}
