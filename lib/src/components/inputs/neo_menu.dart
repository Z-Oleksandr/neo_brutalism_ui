import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/neo_strings.dart';
import '../../primitives/neo_pressable.dart';
import '../../primitives/neo_surface.dart';
import '../../theme/neo_theme.dart';

/// One entry of a menu opened with [showNeoMenu].
@immutable
class NeoMenuItem<T> {
  const NeoMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;
}

/// Opens a neobrutalist popup menu anchored to [context]'s render box (or
/// [anchorRect] in global coordinates) and resolves to the chosen value.
///
/// The menu opens below the anchor, flips above when there is more room
/// there, stays inside the screen, and supports arrow keys, Enter and Escape.
Future<T?> showNeoMenu<T>({
  required BuildContext context,
  required List<NeoMenuItem<T>> items,
  Rect? anchorRect,
  T? selected,
  Color? selectedColor,
}) {
  final navigator = Navigator.of(context);
  final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
  final anchor =
      anchorRect ??
      () {
        final box = context.findRenderObject()! as RenderBox;
        return box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
      }();
  final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  return navigator.push(
    _NeoMenuRoute<T>(
      anchor: anchor,
      items: items,
      selected: selected,
      selectedColor: selectedColor,
      themes: InheritedTheme.capture(from: context, to: navigator.context),
      textDirection: Directionality.of(context),
      barrierLabel: NeoStrings.of(context).dismiss,
      duration: reduced ? Duration.zero : NeoTheme.of(context).motion.fast,
    ),
  );
}

class _NeoMenuRoute<T> extends PopupRoute<T> {
  _NeoMenuRoute({
    required this.anchor,
    required this.items,
    required this.selected,
    required this.selectedColor,
    required this.themes,
    required this.textDirection,
    required this.barrierLabel,
    required this.duration,
  });

  final Rect anchor;
  final List<NeoMenuItem<T>> items;
  final T? selected;
  final Color? selectedColor;
  final CapturedThemes themes;
  final TextDirection textDirection;
  final Duration duration;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return themes.wrap(
      CustomSingleChildLayout(
        delegate: _MenuLayout(
          anchor: anchor,
          textDirection: textDirection,
          padding: MediaQuery.paddingOf(context),
        ),
        child: FadeTransition(
          opacity: animation,
          child: _NeoMenu<T>(
            items: items,
            selected: selected,
            selectedColor: selectedColor,
          ),
        ),
      ),
    );
  }
}

class _MenuLayout extends SingleChildLayoutDelegate {
  _MenuLayout({
    required this.anchor,
    required this.textDirection,
    required this.padding,
  });

  final Rect anchor;
  final TextDirection textDirection;
  final EdgeInsets padding;

  static const double _margin = 8;
  static const double _gap = 6;

  double _below(Size size) => math.max(
    0,
    size.height - anchor.bottom - padding.bottom - _margin - _gap,
  );

  double _above(Size size) =>
      math.max(0, anchor.top - padding.top - _margin - _gap);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final size = constraints.biggest;
    final maxWidth = math.max(0.0, size.width - _margin * 2);
    return BoxConstraints(
      minWidth: math.min(anchor.width, maxWidth),
      maxWidth: maxWidth,
      maxHeight: math.max(_below(size), _above(size)),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final below = _below(size);
    final placeBelow = childSize.height <= below || below >= _above(size);
    final y = placeBelow
        ? anchor.bottom + _gap
        : anchor.top - _gap - childSize.height;
    final rawX = textDirection == TextDirection.rtl
        ? anchor.right - childSize.width
        : anchor.left;
    final maxX = math.max(_margin, size.width - childSize.width - _margin);
    return Offset(rawX.clamp(_margin, maxX), y);
  }

  @override
  bool shouldRelayout(_MenuLayout old) =>
      anchor != old.anchor ||
      textDirection != old.textDirection ||
      padding != old.padding;
}

class _NeoMenu<T> extends StatelessWidget {
  const _NeoMenu({
    required this.items,
    required this.selected,
    required this.selectedColor,
  });

  final List<NeoMenuItem<T>> items;
  final T? selected;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final hasSelected = items.any((i) => i.value == selected);
    final firstEnabled = items.indexWhere((i) => i.enabled);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: NeoSurface(
        padding: const EdgeInsets.all(6),
        child: Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
            SingleActivator(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
          },
          child: FocusTraversalGroup(
            child: SingleChildScrollView(
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, item) in items.indexed)
                      _MenuEntry<T>(
                        item: item,
                        isSelected: item.value == selected,
                        autofocus: hasSelected
                            ? item.value == selected
                            : i == firstEnabled,
                        selectedColor: selectedColor ?? theme.colors.primary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuEntry<T> extends StatelessWidget {
  const _MenuEntry({
    required this.item,
    required this.isSelected,
    required this.autofocus,
    required this.selectedColor,
  });

  final NeoMenuItem<T> item;
  final bool isSelected;
  final bool autofocus;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final colors = theme.colors;
    return NeoPressable(
      onPressed: item.enabled
          ? () => Navigator.of(context).pop(item.value)
          : null,
      autofocus: autofocus && item.enabled,
      selected: isSelected,
      minTapTarget: Size.zero,
      showFocusRing: false,
      builder: (context, states, press) {
        final highlighted =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed);
        final fill = isSelected
            ? selectedColor
            : (highlighted ? colors.surfaceMuted : colors.surface);
        final fg = item.enabled ? colors.onColor(fill) : colors.inkFaint;
        return Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: theme.spacing.md,
          ),
          alignment: AlignmentDirectional.centerStart,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(theme.radii.sm),
            border: isSelected
                ? Border.all(color: colors.border, width: theme.borders.regular)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 18, color: fg),
                SizedBox(width: theme.spacing.sm),
              ],
              Flexible(
                child: Text(
                  item.label,
                  style:
                      (isSelected
                              ? theme.typography.label
                              : theme.typography.bodyStrong)
                          .copyWith(color: fg),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
