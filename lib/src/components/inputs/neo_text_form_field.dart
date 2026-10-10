import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'neo_text_field.dart';

/// A [NeoTextField] that participates in a [Form]: validation errors are
/// shown through the field's error slot.
class NeoTextFormField extends FormField<String> {
  NeoTextFormField({
    super.key,
    this.controller,
    String? initialValue,
    this.focusNode,
    this.label,
    this.hintText,
    this.helperText,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.autofillHints,
    this.prefixIcon,
    this.suffix,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    super.enabled,
    super.restorationId,
  }) : assert(controller == null || initialValue == null),
       super(
         initialValue: controller?.text ?? initialValue ?? '',
         builder: _build,
       );

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hintText;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;
  final Widget? suffix;

  static Widget _build(FormFieldState<String> field) {
    final state = field as _NeoTextFormFieldState;
    final w = state.widget;
    return NeoTextField(
      controller: state._effectiveController,
      focusNode: w.focusNode,
      label: w.label,
      hintText: w.hintText,
      helperText: w.helperText,
      errorText: field.errorText,
      enabled: w.enabled,
      onChanged: (value) {
        field.didChange(value);
        w.onChanged?.call(value);
      },
      onSubmitted: w.onFieldSubmitted,
      keyboardType: w.keyboardType,
      textInputAction: w.textInputAction,
      obscureText: w.obscureText,
      maxLength: w.maxLength,
      minLines: w.minLines,
      maxLines: w.maxLines,
      inputFormatters: w.inputFormatters,
      textCapitalization: w.textCapitalization,
      autocorrect: w.autocorrect,
      autofillHints: w.autofillHints,
      prefixIcon: w.prefixIcon,
      suffix: w.suffix,
    );
  }

  @override
  FormFieldState<String> createState() => _NeoTextFormFieldState();
}

class _NeoTextFormFieldState extends FormFieldState<String> {
  TextEditingController? _ownController;

  @override
  NeoTextFormField get widget => super.widget as NeoTextFormField;

  TextEditingController get _effectiveController =>
      widget.controller ??
      (_ownController ??= TextEditingController(text: widget.initialValue));

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_syncFromController);
  }

  @override
  void didUpdateWidget(NeoTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_syncFromController);
      widget.controller?.addListener(_syncFromController);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_syncFromController);
    _ownController?.dispose();
    super.dispose();
  }

  @override
  void reset() {
    _effectiveController.text = widget.initialValue ?? '';
    super.reset();
  }

  void _syncFromController() {
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }
  }
}
