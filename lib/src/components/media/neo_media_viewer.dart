import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/neo_strings.dart';
import '../../theme/neo_theme.dart';
import '../buttons/neo_icon_button.dart';
import '../feedback/neo_loading_dots.dart';
import 'neo_image.dart';

/// Returns the hero tag for the item at [index], or null for none.
typedef NeoHeroTagBuilder = Object? Function(int index);

/// Full-screen media viewer with paging, pinch and double-tap zoom,
/// swipe-down to dismiss and keyboard navigation (arrows, Escape).
///
/// Usually opened with [showNeoMediaViewer].
class NeoMediaViewer extends StatefulWidget {
  const NeoMediaViewer({
    super.key,
    required List<ImageProvider> this.images,
    this.initialIndex = 0,
    this.heroTagBuilder,
    this.closeLabel,
    this.onPageChanged,
    this.maxScale = 4,
    this.doubleTapScale = 2.5,
  }) : itemBuilder = null,
       _count = null;

  const NeoMediaViewer.builder({
    super.key,
    required int itemCount,
    required IndexedWidgetBuilder this.itemBuilder,
    this.initialIndex = 0,
    this.heroTagBuilder,
    this.closeLabel,
    this.onPageChanged,
    this.maxScale = 4,
    this.doubleTapScale = 2.5,
  }) : images = null,
       _count = itemCount;

  final List<ImageProvider>? images;
  final IndexedWidgetBuilder? itemBuilder;
  final int initialIndex;
  final NeoHeroTagBuilder? heroTagBuilder;

  /// Semantic label of the close button. Defaults to [NeoStrings.close].
  final String? closeLabel;
  final ValueChanged<int>? onPageChanged;
  final double maxScale;
  final double doubleTapScale;
  final int? _count;

  int get itemCount => _count ?? images!.length;

  @override
  State<NeoMediaViewer> createState() => _NeoMediaViewerState();
}

class _NeoMediaViewerState extends State<NeoMediaViewer>
    with TickerProviderStateMixin {
  static const double _dismissDistance = 120;
  static const double _dismissVelocity = 700;

  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  final Map<int, TransformationController> _zoom = {};
  bool _zoomed = false;
  final ValueNotifier<double> _drag = ValueNotifier(0);
  late final AnimationController _zoomAnimation = AnimationController(
    vsync: this,
  )..addListener(_onZoomTick);
  late final AnimationController _snap = AnimationController(vsync: this)
    ..addListener(_onSnapTick);
  Matrix4Tween? _zoomTween;
  double _snapFrom = 0;
  Offset _tapPosition = Offset.zero;
  final FocusNode _focus = FocusNode(debugLabel: 'NeoMediaViewer');

  bool get _reduced => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  Duration get _duration =>
      _reduced ? Duration.zero : NeoTheme.of(context).motion.medium;

  @override
  void dispose() {
    _pages.dispose();
    _drag.dispose();
    _zoomAnimation.dispose();
    _snap.dispose();
    _focus.dispose();
    for (final c in _zoom.values) {
      c.dispose();
    }
    super.dispose();
  }

  TransformationController _controllerFor(int index) => _zoom.putIfAbsent(
    index,
    () => TransformationController()..addListener(_syncZoomed),
  );

  void _syncZoomed() {
    final c = _zoom[_index];
    final zoomed = c != null && c.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
  }

  void _onZoomTick() {
    final tween = _zoomTween;
    if (tween == null) return;
    final curve = NeoTheme.of(context).motion.curve;
    _controllerFor(_index).value = tween.transform(
      curve.transform(_zoomAnimation.value),
    );
  }

  void _onDoubleTap() {
    final controller = _controllerFor(_index);
    final s = widget.doubleTapScale;
    final target = controller.value.getMaxScaleOnAxis() > 1.01
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -_tapPosition.dx * (s - 1),
              -_tapPosition.dy * (s - 1),
              0,
              1,
            )
            ..scaleByDouble(s, s, 1, 1));
    if (_reduced) {
      controller.value = target;
      return;
    }
    _zoomTween = Matrix4Tween(begin: controller.value, end: target);
    _zoomAnimation
      ..duration = _duration
      ..forward(from: 0);
  }

  void _onSnapTick() {
    _drag.value = _snapFrom * (1 - _snap.value);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _snap.stop();
    _drag.value += details.delta.dy;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_drag.value.abs() > _dismissDistance ||
        velocity.abs() > _dismissVelocity) {
      _close();
      return;
    }
    _snapFrom = _drag.value;
    if (_reduced) {
      _drag.value = 0;
      return;
    }
    _snap
      ..duration = NeoTheme.of(context).motion.fast
      ..forward(from: 0);
  }

  void _close() => Navigator.of(context).maybePop();

  void _go(int delta) {
    final target = (_index + delta).clamp(0, widget.itemCount - 1);
    if (target == _index) return;
    if (_reduced) {
      _pages.jumpToPage(target);
    } else {
      _pages.animateToPage(
        target,
        duration: _duration,
        curve: NeoTheme.of(context).motion.curve,
      );
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _close();
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _go(1);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _go(-1);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  Widget _item(BuildContext context, int index) {
    final builder = widget.itemBuilder;
    if (builder != null) return builder(context, index);
    final onBackdrop = NeoTheme.of(context).colors.onDark;
    return NeoImage(
      image: widget.images![index],
      fit: BoxFit.contain,
      bordered: false,
      radius: 0,
      resize: false,
      color: const Color(0x00000000),
      heroTag: widget.heroTagBuilder?.call(index),
      placeholder: (_) => Center(child: NeoLoadingDots(color: onBackdrop)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final colors = theme.colors;
    final backdrop = colors.brightness == Brightness.light
        ? colors.ink
        : colors.background;
    final strings = NeoStrings.of(context);

    final pages = PageView.builder(
      controller: _pages,
      physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
      itemCount: widget.itemCount,
      onPageChanged: (i) {
        setState(() => _index = i);
        _syncZoomed();
        widget.onPageChanged?.call(i);
      },
      itemBuilder: (context, i) => GestureDetector(
        onDoubleTapDown: (d) => _tapPosition = d.localPosition,
        onDoubleTap: _onDoubleTap,
        child: InteractiveViewer(
          transformationController: _controllerFor(i),
          panEnabled: _zoomed,
          maxScale: widget.maxScale,
          child: Center(child: _item(context, i)),
        ),
      ),
    );

    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      child: DefaultTextStyle(
        style: NeoTheme.baseTextStyleOf(context).merge(
          theme.typography.label.copyWith(
            color: colors.ink,
            decoration: TextDecoration.none,
          ),
        ),
        child: ValueListenableBuilder<double>(
          valueListenable: _drag,
          builder: (context, drag, child) {
            final progress = (drag.abs() / 300).clamp(0.0, 1.0);
            return ColoredBox(
              color: backdrop.withValues(alpha: 1 - progress * 0.6),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.translate(
                    offset: Offset(0, drag),
                    child: Transform.scale(
                      scale: 1 - progress * 0.15,
                      child: child,
                    ),
                  ),
                  SafeArea(
                    child: Opacity(
                      opacity: 1 - progress,
                      child: _controls(context, strings),
                    ),
                  ),
                ],
              ),
            );
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragUpdate: _zoomed ? null : _onDragUpdate,
            onVerticalDragEnd: _zoomed ? null : _onDragEnd,
            child: pages,
          ),
        ),
      ),
    );
  }

  Widget _controls(BuildContext context, NeoStrings strings) {
    final theme = NeoTheme.of(context);
    final gap = theme.spacing.md;
    return Stack(
      children: [
        PositionedDirectional(
          top: gap,
          start: gap,
          child: NeoIconButton(
            icon: Icons.close,
            semanticLabel: widget.closeLabel ?? strings.close,
            onPressed: _close,
          ),
        ),
        if (widget.itemCount > 1)
          PositionedDirectional(
            bottom: theme.spacing.xl,
            start: 0,
            end: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.lg,
                  vertical: theme.spacing.sm,
                ),
                decoration: theme.decoration(
                  radius: theme.radii.md,
                  shadow: theme.shadows.sm,
                ),
                child: Text(
                  '${_index + 1} / ${widget.itemCount}',
                  style: theme.typography.label.copyWith(
                    color: theme.colors.ink,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Opens a [NeoMediaViewer] over the current route with a fade.
Future<void> showNeoMediaViewer(
  BuildContext context, {
  required List<ImageProvider> images,
  int initialIndex = 0,
  NeoHeroTagBuilder? heroTagBuilder,
  String? closeLabel,
  ValueChanged<int>? onPageChanged,
}) {
  final navigator = Navigator.of(context);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  final duration = reduced ? Duration.zero : NeoTheme.of(context).motion.medium;
  return navigator.push(
    PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondary) => themes.wrap(
        NeoMediaViewer(
          images: images,
          initialIndex: initialIndex,
          heroTagBuilder: heroTagBuilder,
          closeLabel: closeLabel,
          onPageChanged: onPageChanged,
        ),
      ),
      transitionsBuilder: (context, animation, secondary, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}
