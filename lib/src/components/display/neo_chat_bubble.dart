import 'package:flutter/widgets.dart';

import '../../primitives/neo_pressable.dart';
import '../../theme/neo_theme.dart';

/// A chat message bubble aligned to the end edge when [isMine].
///
/// Shows [text] or a custom [child], an optional [sender] for others'
/// messages, and a meta row with [timestamp] and a [status] widget.
class NeoChatBubble extends StatelessWidget {
  const NeoChatBubble({
    super.key,
    this.text,
    this.child,
    this.isMine = false,
    this.sender,
    this.timestamp,
    this.status,
    this.color,
    this.maxWidthFraction = 0.78,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  }) : assert(text != null || child != null);

  final String? text;
  final Widget? child;
  final bool isMine;
  final String? sender;
  final String? timestamp;

  /// Trailing meta widget such as a delivery icon.
  final Widget? status;

  /// Defaults to the theme green for own messages and surface for others.
  final Color? color;
  final double maxWidthFraction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = NeoTheme.of(context);
    final fill = color ?? (isMine ? theme.colors.green : theme.colors.surface);
    final fg = theme.colors.onColor(fill);
    final muted = fg == theme.colors.ink ? theme.colors.inkMuted : fg;
    final big = Radius.circular(theme.radii.lg);
    final small = Radius.circular(theme.radii.sm);
    final radius = BorderRadiusDirectional.only(
      topStart: big,
      topEnd: big,
      bottomStart: isMine ? big : small,
      bottomEnd: isMine ? small : big,
    );

    final bubble = Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        theme.spacing.md,
        theme.spacing.sm,
        theme.spacing.md,
        theme.spacing.sm,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.regular,
        ),
        boxShadow: [
          BoxShadow(color: theme.colors.shadow, offset: theme.shadows.sm),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMine && sender != null) ...[
            Text(
              sender!,
              style: theme.typography.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: theme.spacing.xs / 2),
          ],
          DefaultTextStyle.merge(
            style: theme.typography.body.copyWith(color: fg),
            child: IconTheme.merge(
              data: IconThemeData(color: fg),
              child: child ?? Text(text!),
            ),
          ),
          if (timestamp != null || status != null) ...[
            SizedBox(height: theme.spacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (timestamp != null)
                  Text(
                    timestamp!,
                    style: theme.typography.caption.copyWith(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                if (timestamp != null && status != null)
                  SizedBox(width: theme.spacing.xs),
                if (status != null)
                  IconTheme.merge(
                    data: IconThemeData(color: muted, size: 14),
                    child: status!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    final interactive = onTap == null && onLongPress == null
        ? bubble
        : NeoPressable(
            onPressed: onTap,
            onLongPress: onLongPress,
            isButton: false,
            minTapTarget: Size.zero,
            focusRadius: BorderRadius.circular(theme.radii.lg),
            builder: (context, states, press) => bubble,
          );

    return Align(
      alignment: isMine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: LayoutBuilder(
        builder: (context, constraints) => ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.hasBoundedWidth
                ? constraints.maxWidth * maxWidthFraction
                : double.infinity,
          ),
          child: Semantics(
            container: true,
            label: semanticLabel,
            child: interactive,
          ),
        ),
      ),
    );
  }
}
