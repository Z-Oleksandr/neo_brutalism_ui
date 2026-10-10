import 'package:flutter/material.dart';

import '../../primitives/neo_pressable_surface.dart';
import '../../theme/neo_theme.dart';
import 'neo_menu.dart';

/// A select button that opens a [showNeoMenu] list of [items].
///
/// Disabled when [onChanged] is null. [onChanged] only fires when a different
/// value is chosen.
class NeoDropdown<T> extends StatelessWidget {
  const NeoDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.labelBuilder,
    this.iconBuilder,
    this.hint,
    this.expanded = false,
    this.color,
    this.selectedColor,
    this.semanticLabel,
  });

  final List<T> items;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String Function(T item) labelBuilder;
  final IconData? Function(T item)? iconBuilder;

  /// Shown when [value] is null.
  final String? hint;
  final bool expanded;

  /// Button fill. Defaults to the theme surface.
  final Color? color;

  /// Highlight of the selected menu entry. Defaults to the theme primary.
  final Color? selectedColor;
  final String? semanticLabel;

  Future<void> _open(BuildContext context) async {
    final result = await showNeoMenu<T>(
      context: context,
      selected: value,
      selectedColor: selectedColor,
      items: [
        for (final item in items)
          NeoMenuItem(
            value: item,
            label: labelBuilder(item),
            icon: iconBuilder?.call(item),
          ),
      ],
    );
    if (result is T && result != value) onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final current = value;
    final hasValue = current != null;
    final enabled = onChanged != null;
    final icon = hasValue ? iconBuilder?.call(current as T) : null;
    final text = hasValue ? labelBuilder(current as T) : (hint ?? '');
    return NeoPressableSurface(
      onPressed: enabled ? () => _open(context) : null,
      color: color,
      width: expanded ? double.infinity : null,
      constraints: const BoxConstraints(minHeight: 44),
      padding: EdgeInsetsDirectional.only(
        start: theme.spacing.md,
        end: theme.spacing.sm,
      ),
      alignment: AlignmentDirectional.centerStart,
      semanticLabel: semanticLabel,
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            SizedBox(width: theme.spacing.sm),
          ],
          Flexible(
            fit: expanded ? FlexFit.tight : FlexFit.loose,
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: hasValue
                  ? theme.typography.label
                  : theme.typography.bodyStrong.copyWith(
                      color: theme.colors.inkFaint,
                    ),
            ),
          ),
          SizedBox(width: theme.spacing.xs),
          const Icon(Icons.arrow_drop_down, size: 22),
        ],
      ),
    );
  }
}
