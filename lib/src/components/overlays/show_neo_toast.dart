import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../../primitives/neo_pressable.dart';
import '../../theme/neo_theme.dart';
import 'neo_toast.dart';

/// Controls a toast shown by [showNeoToast].
class NeoToastHandle {
  NeoToastHandle._(this._queue);

  final _ToastQueue _queue;
  final Completer<void> _closed = Completer<void>();
  _ToastHostState? _host;
  bool _dismissRequested = false;

  /// Completes once the toast has left the screen or was dropped from the
  /// queue.
  Future<void> get closed => _closed.future;

  bool get isClosed => _closed.isCompleted;

  /// Hides the toast now, or removes it from the queue if not yet shown.
  void dismiss() {
    if (isClosed) return;
    final host = _host;
    if (host != null) {
      host.dismiss();
    } else {
      _queue.drop(this);
    }
  }

  void _complete() {
    if (!_closed.isCompleted) _closed.complete();
  }
}

/// Shows a toast at the bottom of the nearest root [Overlay].
///
/// Toasts are queued and shown one at a time. Each stays for [duration],
/// can be swiped or tapped away, and is announced to screen readers.
NeoToastHandle showNeoToast(
  BuildContext context, {
  required String message,
  NeoToastType type = NeoToastType.info,
  String? title,
  IconData? icon,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
  double bottomOffset = 0,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final themes = InheritedTheme.capture(from: context, to: overlay.context);
  final queue = _ToastQueue.of(overlay);
  final handle = NeoToastHandle._(queue);
  queue.add(
    _ToastRequest(
      handle: handle,
      duration: duration,
      bottomOffset: bottomOffset,
      builder: (context, onDismissRequest) => themes.wrap(
        NeoToast(
          message: message,
          type: type,
          title: title,
          icon: icon,
          actionLabel: actionLabel,
          onAction: onAction == null
              ? null
              : () {
                  onAction();
                  onDismissRequest();
                },
        ),
      ),
    ),
  );
  return handle;
}

typedef _ToastBuilder = Widget Function(
  BuildContext context,
  VoidCallback onDismissRequest,
);

class _ToastRequest {
  _ToastRequest({
    required this.handle,
    required this.duration,
    required this.bottomOffset,
    required this.builder,
  });

  final NeoToastHandle handle;
  final Duration duration;
  final double bottomOffset;
  final _ToastBuilder builder;
}

class _ToastQueue {
  _ToastQueue(this.overlay);

  static final Expando<_ToastQueue> _queues = Expando<_ToastQueue>();

  static _ToastQueue of(OverlayState overlay) =>
      _queues[overlay] ??= _ToastQueue(overlay);

  final OverlayState overlay;
  final Queue<_ToastRequest> _pending = Queue<_ToastRequest>();
  OverlayEntry? _entry;

  void add(_ToastRequest request) {
    _pending.add(request);
    _showNext();
  }

  void drop(NeoToastHandle handle) {
    final queued = _pending.any((r) => r.handle == handle);
    if (!queued) {
      handle._dismissRequested = true;
      return;
    }
    _pending.removeWhere((r) => r.handle == handle);
    handle._complete();
  }

  void _showNext() {
    if (_entry != null || _pending.isEmpty || !overlay.mounted) return;
    final request = _pending.removeFirst();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastHost(
        request: request,
        onClosed: () {
          entry.remove();
          entry.dispose();
          _entry = null;
          request.handle._complete();
          _showNext();
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }
}

class _ToastHost extends StatefulWidget {
  const _ToastHost({required this.request, required this.onClosed});

  final _ToastRequest request;
  final VoidCallback onClosed;

  @override
  State<_ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<_ToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    widget.request.handle._host = this;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _controller.duration = reduced
        ? Duration.zero
        : NeoTheme.of(context).motion.medium;
    if (_controller.status == AnimationStatus.dismissed && !_closing) {
      _controller.forward();
      _timer ??= Timer(widget.request.duration, dismiss);
      if (widget.request.handle._dismissRequested) dismiss();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.request.handle._host = null;
    _controller.dispose();
    super.dispose();
  }

  void dismiss() {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    _controller.reverse().whenCompleteOrCancel(_finish);
  }

  void _finish() {
    if (!mounted) return;
    widget.request.handle._host = null;
    widget.onClosed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final insets = MediaQuery.viewPaddingOf(context);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: theme.motion.curve,
    );
    return Positioned(
      left: theme.spacing.lg,
      right: theme.spacing.lg,
      bottom: insets.bottom + theme.spacing.lg + widget.request.bottomOffset,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: curved,
                child: Dismissible(
                  key: ObjectKey(widget.request),
                  onDismissed: (_) {
                    _closing = true;
                    _timer?.cancel();
                    _finish();
                  },
                  child: NeoPressable(
                    onPressed: dismiss,
                    isButton: false,
                    minTapTarget: Size.zero,
                    builder: (context, _, _) =>
                        widget.request.builder(context, dismiss),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
