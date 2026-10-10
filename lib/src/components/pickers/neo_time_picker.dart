import 'package:flutter/material.dart';

import '../../foundation/neo_strings.dart';
import 'neo_picker_dialog.dart';
import 'neo_time_selector.dart';

/// Shows a neobrutalist time picker. Completes with the chosen time, or null
/// when cancelled or dismissed.
Future<TimeOfDay?> showNeoTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  int minuteInterval = 1,
  bool? use24HourFormat,
  String? title,
  String? confirmLabel,
  String? cancelLabel,
  bool barrierDismissible = true,
}) {
  return showNeoPickerDialog<TimeOfDay>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => _TimePickerDialog(
      initialTime: initialTime,
      minuteInterval: minuteInterval,
      use24HourFormat: use24HourFormat,
      title: title,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );
}

class _TimePickerDialog extends StatefulWidget {
  const _TimePickerDialog({
    required this.initialTime,
    required this.minuteInterval,
    this.use24HourFormat,
    this.title,
    this.confirmLabel,
    this.cancelLabel,
  });

  final TimeOfDay initialTime;
  final int minuteInterval;
  final bool? use24HourFormat;
  final String? title;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  State<_TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  late TimeOfDay _time = NeoTimeSelector.snap(
    widget.initialTime,
    widget.minuteInterval,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = neoMaterialLocalizations(context);
    final strings = NeoStrings.of(context);
    return NeoPickerFrame(
      title: widget.title ?? l10n.timePickerDialHelpText,
      confirmLabel: widget.confirmLabel ?? strings.ok,
      cancelLabel: widget.cancelLabel ?? strings.cancel,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: () => Navigator.of(context).pop(_time),
      child: NeoTimeSelector(
        value: _time,
        minuteInterval: widget.minuteInterval,
        use24HourFormat: widget.use24HourFormat,
        onChanged: (t) => setState(() => _time = t),
      ),
    );
  }
}
