import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/neo_theme.dart';

typedef NeoPressableWidgetBuilder = Widget Function(
  BuildContext context,
  Set<WidgetState> states,
  Animation<double> press,
);

/// Interaction core shared by every tappable neo component.
///
/// Handles tap, long press, keyboard activation (Enter/Space), focus ring,
/// hover, mouse cursor, button semantics, a minimum tap target and a press
/// animation that honors reduced motion. Visuals come from [builder], which
/// receives the current [WidgetState]s and a 0..1 press animation.
class NeoPressable extends StatefulWidget {
  const NeoPressable({
    super.key,
    required this.builder,
    this.onPressed,
    this.onLongPress,
    this.semanticLabel,
    this.selected,
    this.toggled,
    this.isButton = true,
    this.sunken = false,
    this.focusNode,
    this.autofocus = false,
    this.focusRadius,
    this.showFocusRing = true,
    this.minTapTarget = const Size.square(48),
    this.mouseCursor,
    this.excludeSemantics = false,
  });

  final NeoPressableWidgetBuilder builder;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final bool? selected;
  final bool? toggled;
  final bool isButton;

  /// Keeps the pressed-in look, e.g. for an active tab.
  final bool sunken;
  final FocusNode? focusNode;
  final bool autofocus;
  final BorderRadius? focusRadius;

  /// Draws an outset ring while keyboard-focused. Disable when the builder
  /// shows focus itself, e.g. in tightly stacked lists.
  final bool showFocusRing;

  /// Layout is grown to at least this size, with the visual centered.
  final Size minTapTarget;
  final MouseCursor? mouseCursor;
  final bool excludeSemantics;

  bool get enabled => onPressed != null || onLongPress != null;

  @override
  State<NeoPressable> createState() => _NeoPressableState();
}

class _NeoPressableState extends State<NeoPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    value: widget.sunken ? 1 : 0,
  );
  bool _down = false;
  bool _hovered = false;
  bool _focused = false;

  late final Map<Type, Action<Intent>> _actions = {
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => _activate(),
    ),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _press.duration = MediaQuery.maybeDisableAnimationsOf(context) == true
        ? Duration.zero
        : NeoTheme.of(context).motion.press;
  }

  @override
  void didUpdateWidget(NeoPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sunken != widget.sunken && !_down) {
      widget.sunken ? _press.forward() : _press.reverse();
    }
    if (!widget.enabled && _down) _down = false;
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  Set<WidgetState> get _states => {
    if (!widget.enabled) WidgetState.disabled,
    if (_down) WidgetState.pressed,
    if (_hovered) WidgetState.hovered,
    if (_focused) WidgetState.focused,
    if (widget.selected ?? widget.toggled ?? false) WidgetState.selected,
  };

  void _setDown(bool value) {
    if (_down == value) return;
    setState(() => _down = value);
  }

  void _handleTapDown(TapDownDetails _) {
    _setDown(true);
    _press.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _setDown(false);
    _release();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _setDown(false);
    _release();
  }

  void _release() {
    if (widget.sunken) return;
    _press.forward().whenCompleteOrCancel(() {
      if (mounted && !_down && !widget.sunken) _press.reverse();
    });
  }

  void _activate() {
    if (widget.onPressed == null) return;
    _release();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final enabled = widget.enabled;
    Widget child = widget.builder(context, _states, _press);
    if (_focused && widget.showFocusRing) {
      child = CustomPaint(
        foregroundPainter: _FocusRingPainter(
          color: theme.colors.focus,
          radius: widget.focusRadius ?? BorderRadius.circular(theme.radii.md),
        ),
        child: child,
      );
    }
    return Semantics(
      container: true,
      button: widget.isButton,
      enabled: enabled,
      selected: widget.selected,
      toggled: widget.toggled,
      label: widget.semanticLabel,
      excludeSemantics: widget.excludeSemantics,
      child: _MinTapTarget(
        minSize: widget.minTapTarget,
        child: FocusableActionDetector(
          enabled: enabled,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          actions: _actions,
          mouseCursor:
              widget.mouseCursor ??
              (enabled ? SystemMouseCursors.click : MouseCursor.defer),
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          onShowHoverHighlight: (v) => setState(() => _hovered = v),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled ? _handleTapDown : null,
            onTapUp: enabled ? _handleTapUp : null,
            onTapCancel: enabled ? _handleTapCancel : null,
            onLongPress: widget.onLongPress == null
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    widget.onLongPress!();
                  },
            child: child,
          ),
        ),
      ),
    );
  }
}

class _FocusRingPainter extends CustomPainter {
  _FocusRingPainter({required this.color, required this.radius});

  final Color color;
  final BorderRadius radius;
  static const double _gap = 3;
  static const double _stroke = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).inflate(_gap + _stroke / 2);
    final rrect = radius.resolve(TextDirection.ltr).toRRect(rect);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_FocusRingPainter old) =>
      old.color != color || old.radius != radius;
}

class _MinTapTarget extends SingleChildRenderObjectWidget {
  const _MinTapTarget({required this.minSize, super.child});

  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMinTapTarget(minSize);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMinTapTarget renderObject,
  ) {
    renderObject.minSize = minSize;
  }
}

class _RenderMinTapTarget extends RenderShiftedBox {
  _RenderMinTapTarget(this._minSize) : super(null);

  Size _minSize;

  set minSize(Size value) {
    if (_minSize == value) return;
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(super.computeMinIntrinsicWidth(height), _minSize.width);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(super.computeMaxIntrinsicWidth(height), _minSize.width);

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(super.computeMinIntrinsicHeight(width), _minSize.height);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.max(super.computeMaxIntrinsicHeight(width), _minSize.height);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childSize = child?.getDryLayout(constraints) ?? Size.zero;
    return constraints.constrain(
      Size(
        math.max(childSize.width, _minSize.width),
        math.max(childSize.height, _minSize.height),
      ),
    );
  }

  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = constraints.constrain(_minSize);
      return;
    }
    c.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(
      Size(
        math.max(c.size.width, _minSize.width),
        math.max(c.size.height, _minSize.height),
      ),
    );
    (c.parentData! as BoxParentData).offset = Alignment.center.alongOffset(
      (size - c.size) as Offset,
    );
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) return true;
    final c = child;
    if (c == null || !size.contains(position)) return false;
    final center = c.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, position) => c.hitTest(result, position: center),
    );
  }
}
