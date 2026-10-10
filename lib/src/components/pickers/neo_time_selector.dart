import 'dart:async';

import 'package:flutter/material.dart';

import '../../primitives/neo_pressable_surface.dart';
import '../../theme/neo_theme.dart';
import '../../theme/neo_theme_data.dart';
import '../buttons/neo_icon_button.dart';
import 'neo_picker_dialog.dart';

/// Hour and minute steppers with an AM/PM toggle in 12-hour locales.
///
/// Steppers react to taps and repeat while long-pressed, and expose
/// adjustable semantics (increase/decrease) to screen readers.
class NeoTimeSelector extends StatelessWidget {
  const NeoTimeSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.minuteInterval = 1,
    this.use24HourFormat,
  }) : assert(minuteInterval > 0 && 60 % minuteInterval == 0);

  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  /// Minute step. Must divide 60.
  final int minuteInterval;

  /// Defaults to the platform and locale preference.
  final bool? use24HourFormat;

  /// Whether [context] prefers a 24-hour clock.
  static bool prefers24Hour(BuildContext context) {
    final always = MediaQuery.maybeAlwaysUse24HourFormatOf(context) ?? false;
    final format = neoMaterialLocalizations(
      context,
    ).timeOfDayFormat(alwaysUse24HourFormat: always);
    return always || hourFormat(of: format) != HourFormat.h;
  }

  /// [time] with its minute rounded down to [interval].
  static TimeOfDay snap(TimeOfDay time, int interval) =>
      time.replacing(minute: time.minute - time.minute % interval);

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final l10n = neoMaterialLocalizations(context);
    final h24 = use24HourFormat ?? prefers24Hour(context);
    final hourLabel = l10n.formatHour(value, alwaysUse24HourFormat: h24);
    final minuteLabel = l10n.formatMinute(value);

    TimeOfDay hours(int delta) =>
        value.replacing(hour: (value.hour + delta) % 24);
    TimeOfDay minutes(int delta) {
      final total = value.minute + delta * minuteInterval;
      return value.replacing(minute: total % 60);
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: theme.spacing.sm,
      runSpacing: theme.spacing.md,
      children: [
        _Stepper(
          label: hourLabel,
          semanticLabel: l10n.timePickerHourLabel,
          increaseLabel: l10n.formatHour(hours(1), alwaysUse24HourFormat: h24),
          decreaseLabel: l10n.formatHour(hours(-1), alwaysUse24HourFormat: h24),
          onIncrease: () => onChanged(hours(1)),
          onDecrease: () => onChanged(hours(-1)),
        ),
        ExcludeSemantics(
          child: Text(
            ':',
            style: theme.typography.display.copyWith(color: theme.colors.ink),
          ),
        ),
        _Stepper(
          label: minuteLabel,
          semanticLabel: l10n.timePickerMinuteLabel,
          increaseLabel: l10n.formatMinute(minutes(1)),
          decreaseLabel: l10n.formatMinute(minutes(-1)),
          onIncrease: () => onChanged(minutes(1)),
          onDecrease: () => onChanged(minutes(-1)),
        ),
        if (!h24) _period(theme, l10n),
      ],
    );
  }

  Widget _period(NeoThemeData theme, MaterialLocalizations l10n) {
    Widget option(DayPeriod period, String text) {
      final selected = value.period == period;
      return NeoPressableSurface(
        sunken: selected,
        selected: selected,
        color: selected ? theme.colors.primary : theme.colors.surface,
        shadow: theme.shadows.sm,
        radius: theme.radii.sm,
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        onPressed: () {
          if (selected) return;
          onChanged(
            value.replacing(
              hour: period == DayPeriod.am ? value.hour - 12 : value.hour + 12,
            ),
          );
        },
        child: Text(text, style: theme.typography.label),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        option(DayPeriod.am, l10n.anteMeridiemAbbreviation),
        SizedBox(height: theme.spacing.xs),
        option(DayPeriod.pm, l10n.postMeridiemAbbreviation),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.semanticLabel,
    required this.increaseLabel,
    required this.decreaseLabel,
    required this.onIncrease,
    required this.onDecrease,
  });

  final String label;
  final String semanticLabel;
  final String increaseLabel;
  final String decreaseLabel;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    return Semantics(
      container: true,
      label: semanticLabel,
      value: label,
      increasedValue: increaseLabel,
      decreasedValue: decreaseLabel,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: _RepeatButton(
              icon: Icons.keyboard_arrow_up,
              onStep: onIncrease,
            ),
          ),
          SizedBox(height: theme.spacing.xs),
          ExcludeSemantics(
            child: Container(
              constraints: const BoxConstraints(minWidth: 72),
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.md,
                vertical: theme.spacing.xs,
              ),
              decoration: theme.decoration(
                radius: theme.radii.md,
                shadow: Offset.zero,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: theme.typography.display.copyWith(
                  color: theme.colors.ink,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          SizedBox(height: theme.spacing.xs),
          ExcludeSemantics(
            child: _RepeatButton(
              icon: Icons.keyboard_arrow_down,
              onStep: onDecrease,
            ),
          ),
        ],
      ),
    );
  }
}

class _RepeatButton extends StatefulWidget {
  const _RepeatButton({required this.icon, required this.onStep});

  final IconData icon;
  final VoidCallback onStep;

  @override
  State<_RepeatButton> createState() => _RepeatButtonState();
}

class _RepeatButtonState extends State<_RepeatButton> {
  static const Duration _interval = Duration(milliseconds: 90);
  Timer? _timer;

  void _start() {
    _timer?.cancel();
    widget.onStep();
    _timer = Timer.periodic(_interval, (_) => widget.onStep());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) => _stop(),
      onPointerCancel: (_) => _stop(),
      child: NeoIconButton(
        icon: widget.icon,
        semanticLabel: '',
        size: 40,
        onPressed: widget.onStep,
        onLongPress: _start,
      ),
    );
  }
}
