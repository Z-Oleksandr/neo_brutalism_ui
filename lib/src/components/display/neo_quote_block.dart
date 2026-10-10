import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/neo_theme.dart';

/// Text with a thick start rail. Shrinks to fit short text; past [maxHeight]
/// it scrolls and the rail gets a draggable thumb.
class NeoQuoteBlock extends StatefulWidget {
  const NeoQuoteBlock({
    super.key,
    required this.text,
    this.title,
    this.maxHeight = 112,
    this.railWidth = 4,
    this.thumbSize = 18,
    this.thumbColor,
    this.textStyle,
    this.titleStyle,
    this.thumbSemanticLabel,
  });

  final String text;
  final String? title;
  final double maxHeight;
  final double railWidth;
  final double thumbSize;

  /// Defaults to the theme pink.
  final Color? thumbColor;
  final TextStyle? textStyle;
  final TextStyle? titleStyle;

  /// Label announced for the scroll thumb.
  final String? thumbSemanticLabel;

  @override
  State<NeoQuoteBlock> createState() => _NeoQuoteBlockState();
}

class _NeoQuoteBlockState extends State<NeoQuoteBlock> {
  static const double _minTouch = 48;

  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _fraction = ValueNotifier(0);
  final ValueNotifier<bool> _scrollable = ValueNotifier(false);
  final ValueNotifier<bool> _dragging = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_syncFraction);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMetrics());
  }

  @override
  void didUpdateWidget(NeoQuoteBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMetrics());
  }

  @override
  void dispose() {
    _scroll.dispose();
    _fraction.dispose();
    _scrollable.dispose();
    _dragging.dispose();
    super.dispose();
  }

  void _syncMetrics() {
    if (!mounted || !_scroll.hasClients) return;
    _scrollable.value = _scroll.position.maxScrollExtent > 0;
    _syncFraction();
  }

  void _syncFraction() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    _fraction.value = max <= 0 ? 0 : (_scroll.offset / max).clamp(0.0, 1.0);
  }

  double _travel(double inset) => _scroll.hasClients
      ? math.max(
          0,
          _scroll.position.viewportDimension - inset * 2 - widget.thumbSize,
        )
      : 0;

  void _jumpToFraction(double fraction) {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    _scroll.jumpTo(fraction.clamp(0.0, 1.0) * max);
  }

  double _pageFraction() {
    if (!_scroll.hasClients) return 0;
    final p = _scroll.position;
    return p.maxScrollExtent <= 0
        ? 1
        : p.viewportDimension * 0.8 / p.maxScrollExtent;
  }

  String _percent(double f) => '${(f.clamp(0.0, 1.0) * 100).round()}%';

  void _page(double direction) {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    final target = (p.pixels + direction * p.viewportDimension * 0.8).clamp(
      0.0,
      p.maxScrollExtent,
    );
    _scroll.jumpTo(target);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final inset = theme.spacing.sm;
    final hitPad = math.max(0.0, (_minTouch - widget.thumbSize) / 2);
    final thumbStart =
        inset + widget.railWidth / 2 - widget.thumbSize / 2 - hitPad;

    final content = NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        _syncMetrics();
        return false;
      },
      child: SingleChildScrollView(
        controller: _scroll,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(
          inset * 2 + widget.railWidth + theme.spacing.sm,
          inset + 2,
          theme.spacing.md,
          inset + 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style:
                    widget.titleStyle ??
                    theme.typography.titleSmall.copyWith(
                      color: theme.colors.ink,
                    ),
              ),
              SizedBox(height: theme.spacing.sm),
            ],
            Text(
              widget.text,
              style:
                  widget.textStyle ??
                  theme.typography.body.copyWith(
                    color: theme.colors.ink,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );

    final thumb = ListenableBuilder(
      listenable: Listenable.merge([_fraction, _scrollable, _dragging]),
      builder: (context, _) {
        if (!_scrollable.value) return const SizedBox.shrink();
        final dragging = _dragging.value;
        final top = inset + _fraction.value * _travel(inset) - hitPad;
        return PositionedDirectional(
          start: thumbStart,
          top: top,
          child: Semantics(
            label: widget.thumbSemanticLabel,
            value: _percent(_fraction.value),
            increasedValue: _percent(_fraction.value + _pageFraction()),
            decreasedValue: _percent(_fraction.value - _pageFraction()),
            onIncrease: () => _page(1),
            onDecrease: () => _page(-1),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => _dragging.value = true,
              onVerticalDragUpdate: (d) {
                final travel = _travel(inset);
                if (travel <= 0) return;
                _jumpToFraction(_fraction.value + d.delta.dy / travel);
              },
              onVerticalDragEnd: (_) => _dragging.value = false,
              onVerticalDragCancel: () => _dragging.value = false,
              child: Padding(
                padding: EdgeInsets.all(hitPad),
                child: _Thumb(
                  size: widget.thumbSize,
                  color: widget.thumbColor ?? theme.colors.pink,
                  dragging: dragging,
                ),
              ),
            ),
          ),
        );
      },
    );

    return Container(
      constraints: BoxConstraints(maxHeight: math.max(widget.maxHeight, 40)),
      decoration: theme.decoration(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRect(child: content),
          PositionedDirectional(
            start: inset,
            top: inset,
            bottom: inset,
            width: widget.railWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.ink,
                borderRadius: BorderRadius.circular(widget.railWidth / 2),
              ),
            ),
          ),
          thumb,
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.size,
    required this.color,
    required this.dragging,
  });

  final double size;
  final Color color;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final grip = theme.colors.onColor(color);
    return AnimatedScale(
      scale: dragging ? 1.1 : 1,
      duration: theme.motion.fast,
      child: Container(
        width: size,
        height: size,
        decoration: theme.decoration(
          color: color,
          radius: theme.radii.sm,
          borderWidth: theme.borders.regular,
          shadow: dragging ? const Offset(1, 1) : theme.shadows.sm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                width: size * 0.45,
                height: 1.2,
                margin: const EdgeInsets.symmetric(vertical: 0.8),
                color: grip,
              ),
          ],
        ),
      ),
    );
  }
}
