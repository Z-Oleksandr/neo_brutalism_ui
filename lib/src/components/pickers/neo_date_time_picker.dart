import 'package:flutter/material.dart';

import '../../foundation/neo_strings.dart';
import '../../primitives/neo_pressable_surface.dart';
import '../../theme/neo_theme.dart';
import 'neo_calendar.dart';
import 'neo_picker_dialog.dart';
import 'neo_time_selector.dart';

/// Shows a two-step neobrutalist picker: a date, then a time. Completes with
/// the combined value, or null when cancelled or dismissed.
///
/// The result is kept within [firstDate] and [lastDate]; out-of-range
/// combinations disable confirmation and show [invalidLabel].
Future<DateTime?> showNeoDateTimePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? initialDateTime,
  DateTime? currentDate,
  SelectableDayPredicate? selectableDayPredicate,
  int minuteInterval = 1,
  bool? use24HourFormat,
  String? title,
  String? nextLabel,
  String? confirmLabel,
  String? cancelLabel,
  String? backLabel,
  String? invalidLabel,
  bool barrierDismissible = true,
}) {
  return showNeoPickerDialog<DateTime>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => _DateTimePickerDialog(
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateTime: initialDateTime,
      currentDate: currentDate,
      selectableDayPredicate: selectableDayPredicate,
      minuteInterval: minuteInterval,
      use24HourFormat: use24HourFormat,
      title: title,
      nextLabel: nextLabel,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      backLabel: backLabel,
      invalidLabel: invalidLabel,
    ),
  );
}

class _DateTimePickerDialog extends StatefulWidget {
  const _DateTimePickerDialog({
    required this.firstDate,
    required this.lastDate,
    required this.minuteInterval,
    this.initialDateTime,
    this.currentDate,
    this.selectableDayPredicate,
    this.use24HourFormat,
    this.title,
    this.nextLabel,
    this.confirmLabel,
    this.cancelLabel,
    this.backLabel,
    this.invalidLabel,
  });

  final DateTime firstDate;
  final DateTime lastDate;
  final int minuteInterval;
  final DateTime? initialDateTime;
  final DateTime? currentDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final bool? use24HourFormat;
  final String? title;
  final String? nextLabel;
  final String? confirmLabel;
  final String? cancelLabel;
  final String? backLabel;
  final String? invalidLabel;

  @override
  State<_DateTimePickerDialog> createState() => _DateTimePickerDialogState();
}

class _DateTimePickerDialogState extends State<_DateTimePickerDialog> {
  late DateTime? _date = widget.initialDateTime == null
      ? null
      : DateUtils.dateOnly(widget.initialDateTime!);
  late TimeOfDay _time = NeoTimeSelector.snap(
    widget.initialDateTime == null
        ? TimeOfDay.fromDateTime(widget.currentDate ?? DateTime.now())
        : TimeOfDay.fromDateTime(widget.initialDateTime!),
    widget.minuteInterval,
  );
  bool _timeStep = false;

  DateTime? get _value {
    final d = _date;
    if (d == null) return null;
    return DateTime(d.year, d.month, d.day, _time.hour, _time.minute);
  }

  bool get _inRange {
    final v = _value;
    return v != null &&
        !v.isBefore(widget.firstDate) &&
        !v.isAfter(widget.lastDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final l10n = neoMaterialLocalizations(context);
    final strings = NeoStrings.of(context);
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final date = _date;

    final Widget body = _timeStep
        ? Column(
            key: const ValueKey('time'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: NeoPressableSurface(
                  color: theme.colors.primary,
                  shadow: theme.shadows.sm,
                  radius: theme.radii.sm,
                  minTapTarget: Size.zero,
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.md,
                    vertical: theme.spacing.xs,
                  ),
                  semanticLabel: l10n.formatFullDate(date!),
                  excludeSemantics: true,
                  onPressed: () => setState(() => _timeStep = false),
                  child: Text(
                    l10n.formatMediumDate(date),
                    style: theme.typography.label,
                  ),
                ),
              ),
              SizedBox(height: theme.spacing.lg),
              NeoTimeSelector(
                value: _time,
                minuteInterval: widget.minuteInterval,
                use24HourFormat: widget.use24HourFormat,
                onChanged: (t) => setState(() => _time = t),
              ),
            ],
          )
        : NeoCalendar(
            key: const ValueKey('date'),
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            currentDate: widget.currentDate,
            selectedDate: date,
            selectableDayPredicate: widget.selectableDayPredicate,
            onDateSelected: (day) => setState(() => _date = day),
          );

    return NeoPickerFrame(
      title:
          widget.title ??
          (_timeStep ? l10n.timePickerDialHelpText : l10n.datePickerHelpText),
      confirmLabel: _timeStep
          ? (widget.confirmLabel ?? strings.ok)
          : (widget.nextLabel ?? l10n.continueButtonLabel),
      cancelLabel: _timeStep
          ? (widget.backLabel ?? strings.back)
          : (widget.cancelLabel ?? strings.cancel),
      message: _timeStep && !_inRange
          ? (widget.invalidLabel ?? l10n.invalidTimeLabel)
          : null,
      onCancel: _timeStep
          ? () => setState(() => _timeStep = false)
          : () => Navigator.of(context).pop(),
      onConfirm: _timeStep
          ? (_inRange ? () => Navigator.of(context).pop(_value) : null)
          : (date == null ? null : () => setState(() => _timeStep = true)),
      child: AnimatedSwitcher(
        duration: reduced ? Duration.zero : theme.motion.fast,
        child: body,
      ),
    );
  }
}
