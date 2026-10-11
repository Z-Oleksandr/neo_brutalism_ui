import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final format = neoMaterialLocalizations(context)
        .timeOfDayFormat(alwaysUse24HourFormat: always);
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
          onTyped: (n) {
            if (h24 && n <= 23) {
              onChanged(value.replacing(hour: n));
            } else if (!h24 && n >= 1 && n <= 12) {
              final pm = value.period == DayPeriod.pm ? 12 : 0;
              onChanged(value.replacing(hour: n % 12 + pm));
            }
          },
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
          onTyped: (n) {
            if (n <= 59) onChanged(value.replacing(minute: n));
          },
          onEditingDone: () {
            final snapped = snap(value, minuteInterval);
            if (snapped != value) onChanged(snapped);
          },
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
    required this.onTyped,
    this.onEditingDone,
  });

  final String label;
  final String semanticLabel;
  final String increaseLabel;
  final String decreaseLabel;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<int> onTyped;
  final VoidCallback? onEditingDone;

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
          _NumberField(
            text: label,
            onTyped: onTyped,
            onIncrease: onIncrease,
            onDecrease: onDecrease,
            onEditingDone: onEditingDone,
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

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.text,
    required this.onTyped,
    required this.onIncrease,
    required this.onDecrease,
    required this.onEditingDone,
  });

  final String text;
  final ValueChanged<int> onTyped;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback? onEditingDone;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );
  late final FocusNode _focus = FocusNode(onKeyEvent: _onKey);
  bool _stepped = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text == _controller.text) return;
    if (!_focus.hasFocus || _stepped) {
      _stepped = false;
      _setText(selectAll: _focus.hasFocus);
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _setText({required bool selectAll}) {
    _controller.value = TextEditingValue(
      text: widget.text,
      selection: selectAll
          ? TextSelection(baseOffset: 0, extentOffset: widget.text.length)
          : TextSelection.collapsed(offset: widget.text.length),
    );
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      _setText(selectAll: true);
    } else {
      widget.onEditingDone?.call();
      _setText(selectAll: false);
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key != LogicalKeyboardKey.arrowUp &&
        key != LogicalKeyboardKey.arrowDown) {
      return KeyEventResult.ignored;
    }
    _stepped = true;
    key == LogicalKeyboardKey.arrowUp
        ? widget.onIncrease()
        : widget.onDecrease();
    return KeyEventResult.handled;
  }

  void _onChanged(String raw) {
    final n = int.tryParse(raw);
    if (n != null) widget.onTyped(n);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final colors = theme.colors;
    return ListenableBuilder(
      listenable: _focus,
      builder: (context, child) => Container(
        width: 88,
        padding: EdgeInsets.symmetric(vertical: theme.spacing.xs),
        decoration: theme.decoration(
          radius: theme.radii.md,
          borderColor: _focus.hasFocus ? colors.focus : null,
          shadow: Offset.zero,
        ),
        child: child,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: TextField(
          controller: _controller,
          focusNode: _focus,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          onChanged: _onChanged,
          onSubmitted: (_) => _focus.unfocus(),
          cursorColor: colors.ink,
          style: theme.typography.display.copyWith(
            color: colors.ink,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
