import 'package:flutter/material.dart';

import '../../foundation/neo_strings.dart';
import '../../theme/neo_theme.dart';
import 'neo_calendar.dart';
import 'neo_picker_dialog.dart';

/// Shows a neobrutalist date range picker. Completes with the chosen range,
/// or null when cancelled or dismissed.
Future<DateTimeRange?> showNeoDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialRange,
  DateTime? currentDate,
  SelectableDayPredicate? selectableDayPredicate,
  String? title,
  String? confirmLabel,
  String? cancelLabel,
  bool barrierDismissible = true,
}) {
  return showNeoPickerDialog<DateTimeRange>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => _DateRangePickerDialog(
      firstDate: firstDate,
      lastDate: lastDate,
      initialRange: initialRange,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      title: title,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    ),
  );
}

class _DateRangePickerDialog extends StatefulWidget {
  const _DateRangePickerDialog({
    required this.firstDate,
    required this.lastDate,
    this.initialRange,
    this.currentDate,
    this.selectableDayPredicate,
    this.title,
    this.confirmLabel,
    this.cancelLabel,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTimeRange? initialRange;
  final DateTime? currentDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final String? title;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  State<_DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  late DateTime? _start = widget.initialRange == null
      ? null
      : DateUtils.dateOnly(widget.initialRange!.start);
  late DateTime? _end = widget.initialRange == null
      ? null
      : DateUtils.dateOnly(widget.initialRange!.end);

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final l10n = neoMaterialLocalizations(context);
    final strings = NeoStrings.of(context);
    final start = _start;
    final end = _end;
    final summary = start == null
        ? l10n.dateRangeStartLabel
        : '${l10n.formatMediumDate(start)} – '
              '${end == null ? l10n.dateRangeEndLabel : l10n.formatMediumDate(end)}';
    return NeoPickerFrame(
      title: widget.title ?? l10n.dateRangePickerHelpText,
      confirmLabel: widget.confirmLabel ?? strings.ok,
      cancelLabel: widget.cancelLabel ?? strings.cancel,
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: start == null || end == null
          ? null
          : () =>
                Navigator.of(context)
                    .pop(DateTimeRange(start: start, end: end)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              summary,
              textAlign: TextAlign.center,
              style: theme.typography.bodyStrong.copyWith(
                color: theme.colors.ink,
              ),
            ),
          ),
          SizedBox(height: theme.spacing.md),
          NeoCalendar.range(
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            currentDate: widget.currentDate,
            rangeStart: start,
            rangeEnd: end,
            selectableDayPredicate: widget.selectableDayPredicate,
            onRangeChanged: (s, e) => setState(() {
              _start = s;
              _end = e;
            }),
          ),
        ],
      ),
    );
  }
}
