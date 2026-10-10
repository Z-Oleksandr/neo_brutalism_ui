import 'package:flutter/material.dart';

import '../../foundation/neo_strings.dart';
import 'neo_calendar.dart';
import 'neo_picker_dialog.dart';

/// Shows a neobrutalist date picker. Completes with the chosen date, or null
/// when cancelled or dismissed.
Future<DateTime?> showNeoDatePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? initialDate,
  DateTime? currentDate,
  SelectableDayPredicate? selectableDayPredicate,
  String? title,
  String? confirmLabel,
  String? cancelLabel,
  bool barrierDismissible = true,
}) {
  return showNeoPickerDialog<DateTime>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => _DatePickerDialog(
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initialDate,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      title: title,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );
}

class _DatePickerDialog extends StatefulWidget {
  const _DatePickerDialog({
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
    this.currentDate,
    this.selectableDayPredicate,
    this.title,
    this.confirmLabel,
    this.cancelLabel,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialDate;
  final DateTime? currentDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final String? title;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  late DateTime? _selected = widget.initialDate == null
      ? null
      : DateUtils.dateOnly(widget.initialDate!);

  @override
  Widget build(BuildContext context) {
    final l10n = neoMaterialLocalizations(context);
    final strings = NeoStrings.of(context);
    final selected = _selected;
    return NeoPickerFrame(
      title: widget.title ?? l10n.datePickerHelpText,
      confirmLabel: widget.confirmLabel ?? strings.ok,
      cancelLabel: widget.cancelLabel ?? strings.cancel,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: selected == null
          ? null
          : () => Navigator.of(context).pop(selected),
      child: NeoCalendar(
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        currentDate: widget.currentDate,
        selectedDate: selected,
        selectableDayPredicate: widget.selectableDayPredicate,
        onDateSelected: (day) => setState(() => _selected = day),
      ),
    );
  }
}
