import 'package:flutter/material.dart';

import '../../primitives/neo_pressable.dart';
import '../../theme/neo_theme.dart';
import 'neo_divider.dart';

/// A bordered panel whose [child] collapses under a tappable [title] header.
///
/// Uncontrolled by default; pass [expanded] to control it from outside.
class NeoExpansionPanel extends StatefulWidget {
  const NeoExpansionPanel({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.subtitle,
    this.expanded,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.color,
    this.padding,
  });

  final Widget title;
  final Widget child;
  final Widget? leading;
  final Widget? subtitle;
  final bool? expanded;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  /// Panel fill. Defaults to the theme surface.
  final Color? color;

  /// Body padding. Defaults to the large theme spacing.
  final EdgeInsetsGeometry? padding;

  @override
  State<NeoExpansionPanel> createState() => _NeoExpansionPanelState();
}

class _NeoExpansionPanelState extends State<NeoExpansionPanel>
    with SingleTickerProviderStateMixin {
  late bool _open = widget.expanded ?? widget.initiallyExpanded;
  late final AnimationController _anim = AnimationController(
    vsync: this,
    value: _open ? 1 : 0,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _anim,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    _anim.addStatusListener((status) {
      if (status.isDismissed && mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    _anim.duration = reduced
        ? Duration.zero
        : NeoTheme.of(context).motion.medium;
  }

  @override
  void didUpdateWidget(NeoExpansionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.expanded;
    if (next != null && next != _open) _apply(next);
  }

  @override
  void dispose() {
    _curve.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _apply(bool open) {
    setState(() => _open = open);
    open ? _anim.forward() : _anim.reverse();
  }

  void _toggle() {
    final next = !_open;
    if (widget.expanded == null) _apply(next);
    widget.onExpansionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final fill = widget.color ?? theme.colors.surface;
    final fg = theme.colors.onColor(fill);
    final pad = theme.spacing.md;

    final header = NeoPressable(
      onPressed: _toggle,
      minTapTarget: Size.zero,
      focusRadius: BorderRadius.circular(theme.radii.md),
      builder: (context, states, _) => Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: EdgeInsets.all(pad),
        color: states.contains(WidgetState.hovered)
            ? Color.alphaBlend(theme.colors.ink.withValues(alpha: 0.06), fill)
            : null,
        child: Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              SizedBox(width: pad),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle.merge(
                    style: theme.typography.titleSmall.copyWith(color: fg),
                    child: widget.title,
                  ),
                  if (widget.subtitle != null)
                    DefaultTextStyle.merge(
                      style: theme.typography.caption.copyWith(
                        color: fg == theme.colors.ink
                            ? theme.colors.inkMuted
                            : fg,
                      ),
                      child: widget.subtitle!,
                    ),
                ],
              ),
            ),
            RotationTransition(
              turns: Tween(begin: 0.0, end: 0.5).animate(_curve),
              child: Icon(Icons.expand_more, color: fg),
            ),
          ],
        ),
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: theme.decoration(color: fill),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeSemantics(
            child: Semantics(expanded: _open, child: header),
          ),
          ClipRect(
            child: AnimatedBuilder(
              animation: _curve,
              builder: (context, child) => Align(
                alignment: AlignmentDirectional.topStart,
                heightFactor: _curve.value,
                child: child,
              ),
              child: Visibility(
                visible: _open || !_anim.isDismissed,
                maintainState: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const NeoDivider(),
                    Padding(
                      padding:
                          widget.padding ?? EdgeInsets.all(theme.spacing.lg),
                      child: DefaultTextStyle.merge(
                        style: theme.typography.body.copyWith(color: fg),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
