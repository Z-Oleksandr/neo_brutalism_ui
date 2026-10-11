import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../primitives/neo_pressable.dart';
import '../../theme/neo_theme.dart';
import '../../theme/neo_theme_data.dart';
import '../buttons/neo_icon_button.dart';
import 'neo_picker_dialog.dart';

/// Called with the range start and, once chosen, its end.
typedef NeoRangeChanged = void Function(DateTime start, DateTime? end);

/// A localized month grid for picking a single date or a date range.
///
/// Selection is controlled: pass [selectedDate] (single) or [rangeStart] and
/// [rangeEnd] (range) and update them from [onDateSelected] or
/// [onRangeChanged]. Month names, weekday headers and the first day of the
/// week come from [MaterialLocalizations].
class NeoCalendar extends StatefulWidget {
  const NeoCalendar({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.selectedDate,
    this.onDateSelected,
    this.initialMonth,
    this.currentDate,
    this.selectableDayPredicate,
    this.onMonthChanged,
    this.color,
  }) : rangeStart = null,
       rangeEnd = null,
       onRangeChanged = null;

  const NeoCalendar.range({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.rangeStart,
    this.rangeEnd,
    required NeoRangeChanged this.onRangeChanged,
    this.initialMonth,
    this.currentDate,
    this.selectableDayPredicate,
    this.onMonthChanged,
    this.color,
  }) : selectedDate = null,
       onDateSelected = null;

  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  /// The first tap starts a range, the second completes it (swapping if
  /// earlier than the start), the next one starts over. See [nextRange].
  final NeoRangeChanged? onRangeChanged;
  final DateTime? initialMonth;

  /// "Today". Defaults to [DateTime.now].
  final DateTime? currentDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final ValueChanged<DateTime>? onMonthChanged;

  /// Selection fill. Defaults to the theme primary.
  final Color? color;

  bool get isRange => onRangeChanged != null;

  /// Number of blank cells before day 1 of [month] when weeks start on
  /// [firstDayOfWeekIndex] (0 = Sunday).
  static int leadingBlankDays(DateTime month, int firstDayOfWeekIndex) {
    final weekday = DateTime(month.year, month.month).weekday % 7;
    return (weekday - firstDayOfWeekIndex) % 7;
  }

  /// The range after tapping [day], given the current [start] and [end].
  /// A null [end] means only the start is chosen.
  static (DateTime, DateTime?) nextRange(
    DateTime? start,
    DateTime? end,
    DateTime day,
  ) {
    if (start == null || end != null) return (day, null);
    return day.isBefore(start) ? (day, start) : (start, day);
  }

  @override
  State<NeoCalendar> createState() => _NeoCalendarState();
}

class _NeoCalendarState extends State<NeoCalendar> {
  late DateTime _month = _initialMonth();

  DateTime _initialMonth() {
    final seed =
        widget.initialMonth ??
        widget.selectedDate ??
        widget.rangeStart ??
        widget.currentDate ??
        DateTime.now();
    final first = DateUtils.dateOnly(widget.firstDate);
    final last = DateUtils.dateOnly(widget.lastDate);
    final clamped = seed.isBefore(first)
        ? first
        : (seed.isAfter(last) ? last : seed);
    return DateTime(clamped.year, clamped.month);
  }

  bool get _canGoBack {
    final first = widget.firstDate;
    return _month.isAfter(DateTime(first.year, first.month));
  }

  bool get _canGoForward {
    final last = widget.lastDate;
    return _month.isBefore(DateTime(last.year, last.month));
  }

  void _shiftMonth(int delta) {
    setState(() => _month = DateUtils.addMonthsToMonthDate(_month, delta));
    widget.onMonthChanged?.call(_month);
  }

  bool _isEnabled(DateTime day) {
    if (day.isBefore(DateUtils.dateOnly(widget.firstDate))) return false;
    if (day.isAfter(DateUtils.dateOnly(widget.lastDate))) return false;
    return widget.selectableDayPredicate?.call(day) ?? true;
  }

  void _tap(DateTime day) {
    if (!widget.isRange) {
      widget.onDateSelected?.call(day);
      return;
    }
    final (start, end) = NeoCalendar.nextRange(
      widget.rangeStart,
      widget.rangeEnd,
      day,
    );
    widget.onRangeChanged!(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final l10n = neoMaterialLocalizations(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 7 * 48.0;
        final cell = math.min(48.0, width / 7);
        return Center(
          heightFactor: 1,
          child: SizedBox(
            width: cell * 7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _header(theme, l10n),
                SizedBox(height: theme.spacing.sm),
                _weekdays(theme, l10n, cell),
                SizedBox(height: theme.spacing.xs),
                _grid(theme, l10n, cell),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(NeoThemeData theme, MaterialLocalizations l10n) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      children: [
        NeoIconButton(
          icon: rtl ? Icons.chevron_right : Icons.chevron_left,
          semanticLabel: l10n.previousMonthTooltip,
          size: 36,
          onPressed: _canGoBack ? () => _shiftMonth(-1) : null,
        ),
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Text(
              l10n.formatMonthYear(_month),
              textAlign: TextAlign.center,
              style: theme.typography.titleSmall.copyWith(
                color: theme.colors.ink,
              ),
            ),
          ),
        ),
        NeoIconButton(
          icon: rtl ? Icons.chevron_left : Icons.chevron_right,
          semanticLabel: l10n.nextMonthTooltip,
          size: 36,
          onPressed: _canGoForward ? () => _shiftMonth(1) : null,
        ),
      ],
    );
  }

  Widget _weekdays(
    NeoThemeData theme,
    MaterialLocalizations l10n,
    double cell,
  ) {
    final first = l10n.firstDayOfWeekIndex;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 7; i++)
            SizedBox(
              width: cell,
              child: Text(
                l10n.narrowWeekdays[(first + i) % 7],
                textAlign: TextAlign.center,
                style: theme.typography.caption.copyWith(
                  color: theme.colors.inkMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _grid(NeoThemeData theme, MaterialLocalizations l10n, double cell) {
    final blanks = NeoCalendar.leadingBlankDays(
      _month,
      l10n.firstDayOfWeekIndex,
    );
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final rows = ((blanks + days) / 7).ceil();
    final today = DateUtils.dateOnly(widget.currentDate ?? DateTime.now());
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < rows; r++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var c = 0; c < 7; c++)
                SizedBox.square(
                  dimension: cell,
                  child: _cell(
                    theme,
                    l10n,
                    r * 7 + c - blanks + 1,
                    days,
                    today,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget? _cell(
    NeoThemeData theme,
    MaterialLocalizations l10n,
    int dayNumber,
    int days,
    DateTime today,
  ) {
    if (dayNumber < 1 || dayNumber > days) return null;
    final day = DateTime(_month.year, _month.month, dayNumber);
    final enabled = _isEnabled(day);
    final state = _stateOf(day);
    return _DayCell(
      label: l10n.formatDecimal(dayNumber),
      semanticLabel: l10n.formatFullDate(day),
      state: state,
      isToday: DateUtils.isSameDay(day, today),
      enabled: enabled,
      color: widget.color ?? theme.colors.primary,
      onTap: enabled ? () => _tap(day) : null,
    );
  }

  _DayState _stateOf(DateTime day) {
    if (!widget.isRange) {
      return DateUtils.isSameDay(day, widget.selectedDate)
          ? _DayState.selected
          : _DayState.none;
    }
    final start = widget.rangeStart;
    final end = widget.rangeEnd;
    if (DateUtils.isSameDay(day, start) || DateUtils.isSameDay(day, end)) {
      return _DayState.selected;
    }
    if (start != null &&
        end != null &&
        day.isAfter(start) &&
        day.isBefore(end)) {
      return _DayState.inRange;
    }
    return _DayState.none;
  }
}

enum _DayState { none, selected, inRange }

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.semanticLabel,
    required this.state,
    required this.isToday,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final _DayState state;
  final bool isToday;
  final bool enabled;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final colors = theme.colors;
    final selected = state == _DayState.selected;
    return NeoPressable(
      onPressed: onTap,
      semanticLabel: semanticLabel,
      selected: state != _DayState.none,
      excludeSemantics: true,
      minTapTarget: Size.zero,
      focusRadius: BorderRadius.circular(theme.radii.sm),
      builder: (context, states, press) {
        final hovered =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed);
        final Color? fill = switch (state) {
          _DayState.selected => color,
          _DayState.inRange => Color.alphaBlend(
            color.withValues(alpha: 0.35),
            colors.surface,
          ),
          _DayState.none => hovered ? colors.surfaceMuted : null,
        };
        final fg = !enabled
            ? colors.inkSubtle
            : (fill == null ? colors.ink : colors.onColor(fill));
        final showBorder = selected || isToday;
        return Container(
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(theme.radii.sm),
            border: showBorder
                ? Border.all(
                    color: colors.border,
                    width: selected
                        ? theme.borders.thick
                        : theme.borders.regular,
                  )
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: theme.typography.label.copyWith(
                color: fg,
                fontWeight: selected || isToday
                    ? FontWeight.w900
                    : FontWeight.w700,
                decoration: enabled ? null : TextDecoration.lineThrough,
                decorationColor: colors.inkSubtle,
              ),
            ),
          ),
        );
      },
    );
  }
}
