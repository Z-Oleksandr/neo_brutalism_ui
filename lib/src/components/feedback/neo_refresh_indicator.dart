import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/neo_strings.dart';
import '../../theme/neo_theme.dart';

/// Triggers a [NeoRefreshIndicator] programmatically.
class NeoRefreshController {
  _NeoRefreshIndicatorState? _state;

  bool get isRefreshing => _state?._inFlight != null;

  /// Shows the indicator and runs its `onRefresh`. Returns the in-flight
  /// refresh when one is already running.
  Future<void> refresh() => _state?._refresh() ?? Future<void>.value();
}

enum _Phase { idle, pulling, armed, refreshing, done }

/// Cross-platform pull-to-refresh with a bold floating badge.
///
/// Works with clamping and bouncing scroll physics. The badge lives in its
/// own repaint layer and is driven by listenables, so pulling never rebuilds
/// [child].
class NeoRefreshIndicator extends StatefulWidget {
  const NeoRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.controller,
    this.triggerOffset = 80,
    this.badgeOffset = 20,
    this.words = const ['WAIT', 'HOLD', 'LOAD', 'SOON', 'YEAH'],
    this.pullLabel = '↓',
    this.armedLabel = 'GO!',
    this.doneLabel = 'DONE ✓',
    this.colors,
    this.semanticsLabel,
  });

  final Widget child;
  final Future<void> Function() onRefresh;
  final NeoRefreshController? controller;

  /// Pull distance that arms the refresh.
  final double triggerOffset;

  /// Resting distance of the badge from the top while refreshing.
  final double badgeOffset;

  /// Labels cycled while refreshing.
  final List<String> words;
  final String pullLabel;
  final String armedLabel;
  final String doneLabel;

  /// Badge fills cycled while refreshing. Defaults to the theme accents.
  final List<Color>? colors;
  final String? semanticsLabel;

  @override
  State<NeoRefreshIndicator> createState() => _NeoRefreshIndicatorState();
}

class _NeoRefreshIndicatorState extends State<NeoRefreshIndicator>
    with TickerProviderStateMixin {
  static const double _damping = 0.5;
  static const Duration _hold = Duration(milliseconds: 700);

  final ValueNotifier<_Phase> _phase = ValueNotifier(_Phase.idle);
  final ValueNotifier<double> _distance = ValueNotifier(0);
  late final AnimationController _snap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  late final AnimationController _busy = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );
  Timer? _holdTimer;
  Future<void>? _inFlight;
  double _snapFrom = 0;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _snap.duration = _reduced
        ? Duration.zero
        : const Duration(milliseconds: 300);
    _fade.duration = _reduced
        ? Duration.zero
        : const Duration(milliseconds: 200);
    if (_reduced) _busy.stop();
  }

  @override
  void didUpdateWidget(NeoRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._state == this) {
        oldWidget.controller!._state = null;
      }
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller!._state = null;
    _holdTimer?.cancel();
    _snap.dispose();
    _fade.dispose();
    _busy.dispose();
    _phase.dispose();
    _distance.dispose();
    super.dispose();
  }

  double get _progress =>
      (_distance.value / widget.triggerOffset).clamp(0.0, 1.0);

  bool get _locked =>
      _phase.value == _Phase.refreshing || _phase.value == _Phase.done;

  void _setDistance(double value) {
    _distance.value = math.max(0, value);
    if (_distance.value < 2) {
      _phase.value = _Phase.idle;
      return;
    }
    final armed = _progress >= 1;
    if (armed && _phase.value != _Phase.armed) {
      HapticFeedback.mediumImpact();
    }
    _phase.value = armed ? _Phase.armed : _Phase.pulling;
  }

  void _reset() {
    _distance.value = 0;
    _phase.value = _Phase.idle;
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical || _locked) {
      return false;
    }
    if (n is OverscrollNotification) {
      if (n.overscroll < 0 && n.dragDetails != null) {
        _setDistance(_distance.value - n.overscroll * _damping);
      }
    } else if (n is ScrollUpdateNotification) {
      final over = n.metrics.minScrollExtent - n.metrics.pixels;
      if (over > 0) {
        if (n.dragDetails == null && _phase.value == _Phase.armed) {
          unawaited(_refresh());
        } else {
          _setDistance(over * _damping);
        }
      } else if (_phase.value != _Phase.idle) {
        _reset();
      }
    } else if (n is ScrollEndNotification) {
      if (_phase.value == _Phase.armed) {
        unawaited(_refresh());
      } else if (_phase.value == _Phase.pulling) {
        _reset();
      }
    }
    return false;
  }

  double get _pullTop => math.max(0, _distance.value - 20);

  Future<void> _refresh() {
    final inFlight = _inFlight;
    if (inFlight != null) return inFlight;
    _holdTimer?.cancel();
    _fade.value = 0;
    _snapFrom = _phase.value == _Phase.idle ? 0 : _pullTop;
    _phase.value = _Phase.refreshing;
    _snap.forward(from: 0);
    if (!_reduced) _busy.repeat();
    return _inFlight = _run();
  }

  Future<void> _run() async {
    try {
      await widget.onRefresh();
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'slab_ui',
          context: ErrorDescription('while running NeoRefreshIndicator'),
        ),
      );
    } finally {
      _inFlight = null;
      if (mounted) _complete();
    }
  }

  void _complete() {
    _busy.stop();
    _phase.value = _Phase.done;
    _holdTimer = Timer(_reduced ? Duration.zero : _hold, () {
      if (!mounted || _phase.value != _Phase.done) return;
      _fade.forward(from: 0).whenCompleteOrCancel(() {
        if (mounted && _phase.value == _Phase.done) _reset();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: widget.child,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _phase,
                  _distance,
                  _snap,
                  _fade,
                  _busy,
                ]),
                builder: (context, _) => _buildBadge(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context) {
    final phase = _phase.value;
    if (phase == _Phase.idle) return const SizedBox.shrink();
    final theme = NeoTheme.of(context);
    final palette = widget.colors ?? theme.colors.accents;
    final p = _progress;

    var top = _pullTop;
    var scale = 0.4 + 0.6 * p;
    var angle = 0.0;
    var opacity = math.max(0.3, p);
    String label;
    Color fill;

    switch (phase) {
      case _Phase.pulling:
        label = widget.pullLabel;
        fill = palette.first;
      case _Phase.armed:
        label = widget.armedLabel;
        fill = theme.colors.primary;
        scale = 1;
        opacity = 1;
      case _Phase.refreshing || _Phase.done:
        final t = Curves.easeOutBack.transform(_snap.value);
        top = _snapFrom + (widget.badgeOffset - _snapFrom) * t;
        scale = 1;
        opacity = 1 - _fade.value;
        if (phase == _Phase.done) {
          label = widget.doneLabel;
          fill = theme.colors.success;
        } else {
          final count = widget.words.isEmpty ? 1 : widget.words.length;
          final index = (_busy.value * count * 2).floor() % count;
          label = widget.words.isEmpty ? '' : widget.words[index];
          fill = palette[index % palette.length];
          angle = math.sin(_busy.value * math.pi * 8) * 0.06;
        }
      case _Phase.idle:
        return const SizedBox.shrink();
    }

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.md,
        vertical: theme.spacing.sm,
      ),
      decoration: theme.decoration(color: fill, shadow: theme.shadows.md),
      child: Text(
        label,
        style: theme.typography.label.copyWith(
          color: theme.colors.onColor(fill),
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );

    return Semantics(
      excludeSemantics: true,
      liveRegion: phase == _Phase.refreshing,
      label: phase == _Phase.refreshing
          ? widget.semanticsLabel ?? NeoStrings.of(context).loading
          : null,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, top),
          child: Center(
            child: Transform.rotate(
              angle: angle,
              child: Transform.scale(scale: scale, child: badge),
            ),
          ),
        ),
      ),
    );
  }
}
