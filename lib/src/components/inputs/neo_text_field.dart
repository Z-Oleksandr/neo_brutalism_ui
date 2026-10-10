import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../theme/neo_theme.dart';
import '../../theme/neo_theme_data.dart';

/// A bordered text input with label, helper, counter and error rendered
/// outside the box.
///
/// The border turns focus-colored and thick while focused and danger-colored
/// when [errorText] is set.
class NeoTextField extends StatefulWidget {
  const NeoTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTap,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.autofillHints,
    this.prefixIcon,
    this.suffix,
    this.color,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hintText;
  final String? helperText;

  /// Shows an error below the field and paints the border danger-colored.
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final GestureTapCallback? onTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  /// Enforced limit; also shows a `length/max` counter.
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;

  /// Trailing widget inside the box, e.g. a clear or visibility button.
  final Widget? suffix;

  /// Box fill. Defaults to the theme surface.
  final Color? color;
  final TextAlign textAlign;

  @override
  State<NeoTextField> createState() => _NeoTextFieldState();
}

class _NeoTextFieldState extends State<NeoTextField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(NeoTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_handleFocus);
      _focusNode.addListener(_handleFocus);
      _focused = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _ownFocusNode?.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final colors = theme.colors;
    final hasError = widget.errorText != null;
    final enabled = widget.enabled;
    final fill = enabled
        ? (widget.color ?? colors.surface)
        : colors.surfaceMuted;
    final ink = enabled ? colors.onColor(fill) : colors.inkFaint;
    final borderColor = hasError
        ? colors.danger
        : (_focused ? colors.focus : colors.border);
    final shadow = hasError || _focused ? theme.shadows.sm : Offset.zero;
    final shadowColor = hasError
        ? colors.danger
        : (_focused ? colors.focus : colors.shadow);
    final duration = MediaQuery.maybeDisableAnimationsOf(context) == true
        ? Duration.zero
        : theme.motion.fast;

    final field = AnimatedContainer(
      duration: duration,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(theme.radii.md),
        border: Border.all(color: borderColor, width: theme.borders.regular),
        boxShadow: [BoxShadow(color: shadowColor, offset: shadow)],
      ),
      child: _Affixes(
        prefixIcon: widget.prefixIcon,
        iconColor: enabled ? colors.inkMuted : colors.inkFaint,
        suffix: widget.suffix,
        spacing: theme.spacing.md,
        onTapIcon: enabled ? _focusNode.requestFocus : null,
        child: Material(
          type: MaterialType.transparency,
          child: Semantics(
            label: widget.label,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onEditingComplete: widget.onEditingComplete,
              onTap: widget.onTap,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: widget.obscureText,
              enabled: enabled,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              maxLength: widget.maxLength,
              minLines: widget.minLines,
              maxLines: widget.obscureText ? 1 : widget.maxLines,
              inputFormatters: widget.inputFormatters,
              textCapitalization: widget.textCapitalization,
              autocorrect: widget.autocorrect,
              enableSuggestions: widget.enableSuggestions,
              autofillHints: widget.autofillHints,
              textAlign: widget.textAlign,
              cursorColor: ink,
              style: theme.typography.body.copyWith(color: ink),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                counterText: '',
                hintText: widget.hintText,
                hintStyle: theme.typography.body.copyWith(
                  color: colors.inkFaint,
                ),
                contentPadding: EdgeInsetsDirectional.symmetric(
                  horizontal: theme.spacing.md,
                  vertical: theme.spacing.md + 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final footer = _Footer(
      theme: theme,
      helperText: widget.helperText,
      errorText: widget.errorText,
      controller: widget.maxLength == null ? null : _controller,
      maxLength: widget.maxLength,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) ...[
          ExcludeSemantics(
            child: Text(
              widget.label!,
              style: theme.typography.label.copyWith(
                color: enabled ? colors.ink : colors.inkFaint,
              ),
            ),
          ),
          SizedBox(height: theme.spacing.xs + 2),
        ],
        field,
        if (footer.isVisible) ...[SizedBox(height: theme.spacing.xs), footer],
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.theme,
    required this.helperText,
    required this.errorText,
    required this.controller,
    required this.maxLength,
  });

  final NeoThemeData theme;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final int? maxLength;

  bool get isVisible =>
      helperText != null || errorText != null || controller != null;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final caption = theme.typography.caption;
    Widget? message;
    if (errorText != null) {
      message = Semantics(
        liveRegion: true,
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: theme.spacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: colors.danger,
            borderRadius: BorderRadius.circular(theme.radii.sm),
            border: Border.all(color: colors.border, width: theme.borders.thin),
          ),
          child: Text(
            errorText!,
            style: caption.copyWith(
              color: colors.onColor(colors.danger),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    } else if (helperText != null) {
      message = Text(
        helperText!,
        style: caption.copyWith(color: colors.inkMuted),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: message ?? const SizedBox.shrink(),
          ),
        ),
        if (controller != null)
          Padding(
            padding: EdgeInsetsDirectional.only(start: theme.spacing.sm),
            child: ListenableBuilder(
              listenable: controller!,
              builder: (context, _) => Text(
                '${controller!.text.characters.length}/$maxLength',
                style: caption.copyWith(color: colors.inkMuted),
              ),
            ),
          ),
      ],
    );
  }
}

class _Affixes extends StatelessWidget {
  const _Affixes({
    required this.child,
    required this.prefixIcon,
    required this.iconColor,
    required this.suffix,
    required this.spacing,
    required this.onTapIcon,
  });

  final Widget child;
  final IconData? prefixIcon;
  final Color iconColor;
  final Widget? suffix;
  final double spacing;
  final VoidCallback? onTapIcon;

  @override
  Widget build(BuildContext context) {
    if (prefixIcon == null && suffix == null) return child;
    return Row(
      children: [
        if (prefixIcon != null)
          GestureDetector(
            onTap: onTapIcon,
            excludeFromSemantics: true,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: spacing),
              child: ExcludeSemantics(
                child: Icon(prefixIcon, size: 20, color: iconColor),
              ),
            ),
          ),
        Expanded(child: child),
        if (suffix != null)
          _HeightNeutral(
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: spacing / 2),
              child: IconTheme.merge(
                data: IconThemeData(color: iconColor, size: 20),
                child: suffix!,
              ),
            ),
          ),
      ],
    );
  }
}

/// Lays out its child at natural size but contributes no height, so a tall
/// tap target never grows the field. Hits still reach the child.
class _HeightNeutral extends SingleChildRenderObjectWidget {
  const _HeightNeutral({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeightNeutral();
}

class _RenderHeightNeutral extends RenderShiftedBox {
  _RenderHeightNeutral() : super(null);

  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childSize =
        child?.getDryLayout(constraints.copyWith(minHeight: 0)) ?? Size.zero;
    return constraints.constrain(Size(childSize.width, 0));
  }

  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    c.layout(
      constraints.copyWith(minHeight: 0, maxHeight: double.infinity),
      parentUsesSize: true,
    );
    size = constraints.constrain(Size(c.size.width, 0));
    (c.parentData! as BoxParentData).offset = Offset(0, -c.size.height / 2);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!hitTestChildren(result, position: position)) return false;
    result.add(BoxHitTestEntry(this, position));
    return true;
  }
}
