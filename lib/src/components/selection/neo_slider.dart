import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/neo_theme.dart';

/// A slider with a square thumb on a bordered track.
///
/// Snaps to [divisions] when set. Supports drag, tap, arrow keys and screen
/// reader increase/decrease. Disabled when [onChanged] is null.
class NeoSlider extends StatefulWidget {
  const NeoSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChangeStart,
    this.onChangeEnd,
    this.label,
    this.semanticFormatter,
    this.activeColor,
    this.trackColor,
    this.thumbColor,
    this.focusNode,
    this.autofocus = false,
  }) : assert(min < max),
       assert(divisions == null || divisions > 0);

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  /// Semantic label describing what the slider controls.
  final String? label;

  /// Formats the value for screen readers.
  final String Function(double value)? semanticFormatter;

  /// Fill of the track up to the thumb. Defaults to the theme primary.
  final Color? activeColor;
  final Color? trackColor;
  final Color? thumbColor;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<NeoSlider> createState() => _NeoSliderState();
}

class _AdjustIntent extends Intent {
  const _AdjustIntent(this.direction);

  final int direction;
}

class _NeoSliderState extends State<NeoSlider> {
  static const double _thumb = 24;
  static const double _trackHeight = 12;
  static const double _height = 48;

  bool _focused = false;
  bool _dragging = false;
  double _dragValue = 0;

  bool get _enabled => widget.onChanged != null;

  double get _step => widget.divisions != null
      ? (widget.max - widget.min) / widget.divisions!
      : (widget.max - widget.min) / 20;

  double _snap(double v) {
    final clamped = v.clamp(widget.min, widget.max);
    final divisions = widget.divisions;
    if (divisions == null) return clamped;
    final range = widget.max - widget.min;
    final k = ((clamped - widget.min) / range * divisions).round();
    return widget.min + range * k / divisions;
  }

  double _valueAt(double dx, double width) {
    final usable = width - _thumb;
    if (usable <= 0) return widget.value;
    var t = ((dx - _thumb / 2) / usable).clamp(0.0, 1.0);
    if (Directionality.of(context) == TextDirection.rtl) t = 1 - t;
    return _snap(widget.min + t * (widget.max - widget.min));
  }

  void _emit(double v) {
    _dragValue = v;
    if (v != widget.value) widget.onChanged?.call(v);
  }

  void _start(double dx, double width) {
    setState(() => _dragging = true);
    widget.onChangeStart?.call(widget.value);
    _emit(_valueAt(dx, width));
  }

  void _end() {
    setState(() => _dragging = false);
    widget.onChangeEnd?.call(_dragValue);
  }

  void _adjust(int direction) {
    if (!_enabled) return;
    final next = _snap(widget.value + direction * _step);
    if (next == widget.value) return;
    widget.onChangeStart?.call(widget.value);
    _emit(next);
    widget.onChangeEnd?.call(next);
  }

  String _format(double v) {
    final formatter = widget.semanticFormatter;
    if (formatter != null) return formatter(v);
    if (widget.min == 0 && widget.max == 1) return '${(v * 100).round()}%';
    return v == v.roundToDouble() ? '${v.toInt()}' : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final colors = theme.colors;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final range = widget.max - widget.min;
    final t = ((widget.value - widget.min) / range).clamp(0.0, 1.0);
    final enabled = _enabled;
    final active = enabled
        ? (widget.activeColor ?? colors.primary)
        : colors.inkSubtle;
    final increase = rtl ? -1 : 1;

    return Semantics(
      slider: true,
      enabled: enabled,
      label: widget.label,
      value: _format(widget.value),
      increasedValue: _format(_snap(widget.value + _step)),
      decreasedValue: _format(_snap(widget.value - _step)),
      onIncrease: enabled ? () => _adjust(1) : null,
      onDecrease: enabled ? () => _adjust(-1) : null,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        shortcuts: {
          const SingleActivator(LogicalKeyboardKey.arrowUp):
              const _AdjustIntent(1),
          const SingleActivator(LogicalKeyboardKey.arrowDown):
              const _AdjustIntent(-1),
          const SingleActivator(LogicalKeyboardKey.arrowRight): _AdjustIntent(
            increase,
          ),
          const SingleActivator(LogicalKeyboardKey.arrowLeft): _AdjustIntent(
            -increase,
          ),
        },
        actions: {
          _AdjustIntent: CallbackAction<_AdjustIntent>(
            onInvoke: (intent) => _adjust(intent.direction),
          ),
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final usable = (width - _thumb).clamp(0.0, double.infinity);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: enabled
                  ? (d) {
                      _start(d.localPosition.dx, width);
                      _end();
                    }
                  : null,
              onHorizontalDragStart: enabled
                  ? (d) => _start(d.localPosition.dx, width)
                  : null,
              onHorizontalDragUpdate: enabled
                  ? (d) => _emit(_valueAt(d.localPosition.dx, width))
                  : null,
              onHorizontalDragEnd: enabled ? (_) => _end() : null,
              onHorizontalDragCancel: enabled ? _end : null,
              child: SizedBox(
                width: width,
                height: _height,
                child: Stack(
                  children: [
                    PositionedDirectional(
                      start: _thumb / 2,
                      end: _thumb / 2,
                      top: (_height - _trackHeight) / 2,
                      height: _trackHeight,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: enabled
                              ? (widget.trackColor ?? colors.surface)
                              : colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: colors.border,
                            width: theme.borders.thick,
                          ),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: FractionallySizedBox(
                            widthFactor: t,
                            heightFactor: 1,
                            child: ColoredBox(color: active),
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: t * usable,
                      top: (_height - _thumb) / 2,
                      child: Container(
                        width: _thumb,
                        height: _thumb,
                        decoration: BoxDecoration(
                          color: enabled
                              ? (widget.thumbColor ?? colors.surface)
                              : colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: _focused ? colors.focus : colors.border,
                            width: theme.borders.thick,
                          ),
                          boxShadow: enabled && !_dragging
                              ? [
                                  BoxShadow(
                                    color: colors.shadow,
                                    offset: theme.shadows.sm,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
