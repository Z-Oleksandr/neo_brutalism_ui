import 'package:flutter/widgets.dart';

import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';
import 'neo_segment_face.dart';

/// One option of a [NeoSegmentedControl].
@immutable
class NeoSegment<T> {
  const NeoSegment({
    required this.value,
    this.label,
    this.icon,
    this.semanticLabel,
  }) : assert(label != null || icon != null);

  final T value;
  final String? label;
  final IconData? icon;
  final String? semanticLabel;
}

/// A row of mutually exclusive (or, with [multiSelect], independent)
/// options. Selected segments are pressed in and filled with [activeColor].
class NeoSegmentedControl<T> extends StatelessWidget {
  const NeoSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.multiSelect = false,
    this.emptySelectionAllowed = false,
    this.activeColor,
    this.segmentHeight = 40,
  });

  final List<NeoSegment<T>> segments;
  final Set<T> selected;

  /// Receives the complete new selection. Null disables the control.
  final ValueChanged<Set<T>>? onChanged;
  final bool multiSelect;

  /// Allows deselecting the last selected segment.
  final bool emptySelectionAllowed;

  /// Defaults to the theme primary.
  final Color? activeColor;
  final double segmentHeight;

  void _toggle(T value) {
    final isOn = selected.contains(value);
    final next = multiSelect ? {...selected} : <T>{};
    if (isOn) {
      if (!multiSelect && !emptySelectionAllowed) return;
      next.remove(value);
      if (next.isEmpty && !emptySelectionAllowed) return;
    } else {
      next.add(value);
    }
    onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final active = activeColor ?? theme.colors.primary;
    return NeoSurface(
      padding: EdgeInsets.all(theme.spacing.sm),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) SizedBox(width: theme.spacing.sm),
            Expanded(
              child: NeoSegmentFace(
                active: selected.contains(segments[i].value),
                activeColor: active,
                height: segmentHeight,
                label: segments[i].label,
                icon: segments[i].icon,
                semanticLabel: segments[i].semanticLabel,
                toggle: multiSelect,
                onPressed: onChanged == null
                    ? null
                    : () => _toggle(segments[i].value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
