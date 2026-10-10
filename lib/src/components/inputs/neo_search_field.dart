import 'dart:async';

import 'package:flutter/material.dart';

import '../../foundation/neo_strings.dart';
import '../../primitives/neo_pressable.dart';
import '../../theme/neo_theme.dart';
import 'neo_text_field.dart';

/// A search input with a search icon, a clear button while text is present
/// and optional debouncing of [onChanged].
class NeoSearchField extends StatefulWidget {
  const NeoSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.clearLabel,
    this.onChanged,
    this.onSubmitted,
    this.onCleared,
    this.debounce,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Defaults to the localized "Search".
  final String? hintText;

  /// Semantic label of the clear button. Defaults to the localized "Clear".
  final String? clearLabel;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCleared;

  /// Delays [onChanged] until typing pauses for this long.
  final Duration? debounce;
  final bool autofocus;
  final bool enabled;

  @override
  State<NeoSearchField> createState() => _NeoSearchFieldState();
}

class _NeoSearchFieldState extends State<NeoSearchField> {
  TextEditingController? _ownController;
  Timer? _debounce;
  bool _hasText = false;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleText);
  }

  @override
  void didUpdateWidget(NeoSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_handleText);
      _controller.addListener(_handleText);
      _hasText = _controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_handleText);
    _ownController?.dispose();
    super.dispose();
  }

  void _handleText() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _handleChanged(String value) {
    final onChanged = widget.onChanged;
    if (onChanged == null) return;
    final delay = widget.debounce;
    if (delay == null) {
      onChanged(value);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(delay, () => onChanged(value));
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onChanged?.call('');
    widget.onCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    final strings = NeoStrings.of(context);
    final colors = NeoTheme.of(context).colors;
    return NeoTextField(
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      hintText: widget.hintText ?? strings.search,
      prefixIcon: Icons.search,
      textInputAction: TextInputAction.search,
      onChanged: _handleChanged,
      onSubmitted: widget.onSubmitted,
      suffix: _hasText && widget.enabled
          ? NeoPressable(
              onPressed: _clear,
              semanticLabel: widget.clearLabel ?? strings.clear,
              focusRadius: BorderRadius.circular(24),
              builder: (context, states, press) =>
                  Icon(Icons.close, size: 20, color: colors.inkMuted),
            )
          : null,
    );
  }
}
