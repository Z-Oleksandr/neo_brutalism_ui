import 'package:flutter/material.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

import '../catalog/catalog_page.dart';

class OverlaysPage extends StatefulWidget {
  const OverlaysPage({super.key});

  @override
  State<OverlaysPage> createState() => _OverlaysPageState();
}

class _OverlaysPageState extends State<OverlaysPage> {
  String _last = '—';

  void _report(Object? value) {
    if (mounted) setState(() => _last = '$value');
  }

  Future<void> _dialog() async {
    final result = await showNeoDialog<String>(
      context: context,
      builder: (context) => NeoDialog(
        title: 'Join party?',
        message: 'You will appear in the member list and get updates.',
        actions: [
          NeoButton(
            label: 'Later',
            variant: NeoButtonVariant.outlined,
            onPressed: () => Navigator.of(context).pop('later'),
          ),
          NeoButton(
            label: 'Join',
            onPressed: () => Navigator.of(context).pop('join'),
          ),
        ],
      ),
    );
    _report(result);
  }

  Future<void> _confirm() async {
    _report(
      await showNeoConfirmDialog(
        context: context,
        title: 'Delete club?',
        message: 'All posts and members will be removed.',
        confirmLabel: 'Delete',
        destructive: true,
      ),
    );
  }

  Future<void> _sheet() async {
    final result = await showNeoBottomSheet<String>(
      context: context,
      builder: (context) => NeoBottomSheet(
        title: 'Share party',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Invite friends with a link or QR code.'),
            SizedBox(height: context.neo.spacing.lg),
            NeoButton(
              label: 'Copy link',
              icon: Icons.link,
              expanded: true,
              onPressed: () => Navigator.of(context).pop('link'),
            ),
          ],
        ),
      ),
    );
    _report(result);
  }

  Future<void> _actions() async {
    _report(
      await showNeoActionSheet<String>(
        context: context,
        title: 'Message',
        actions: const [
          NeoSheetAction(label: 'Reply', value: 'reply', icon: Icons.reply),
          NeoSheetAction(label: 'Edit', value: 'edit', icon: Icons.edit),
          NeoSheetAction(
            label: 'Delete',
            value: 'delete',
            icon: Icons.delete,
            destructive: true,
          ),
        ],
      ),
    );
  }

  void _toast(NeoToastType type) {
    showNeoToast(
      context,
      type: type,
      title: type.name.toUpperCase(),
      message: 'Something happened just now.',
      actionLabel: type == NeoToastType.error ? 'Retry' : null,
      onAction: type == NeoToastType.error ? () => _report('retry') : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CatalogPage(
      children: [
        CatalogSection(
          title: 'Last result: $_last',
          child: const SizedBox.shrink(),
        ),
        CatalogSection(
          title: 'Dialogs',
          child: DemoWrap(
            children: [
              NeoButton(label: 'Dialog', onPressed: _dialog),
              NeoButton(
                label: 'Confirm',
                color: context.neo.colors.pink,
                onPressed: _confirm,
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Sheets',
          child: DemoWrap(
            children: [
              NeoButton(
                label: 'Bottom sheet',
                variant: NeoButtonVariant.outlined,
                onPressed: _sheet,
              ),
              NeoButton(
                label: 'Action sheet',
                variant: NeoButtonVariant.outlined,
                onPressed: _actions,
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Toasts (queued)',
          child: DemoWrap(
            children: [
              for (final type in NeoToastType.values)
                NeoButton(
                  label: type.name,
                  size: NeoButtonSize.small,
                  color: NeoToast.colorFor(type, context.neo),
                  onPressed: () => _toast(type),
                ),
            ],
          ),
        ),
        const CatalogSection(
          title: 'Inline toast',
          child: NeoToast(
            message: 'Saved to drafts',
            type: NeoToastType.success,
          ),
        ),
      ],
    );
  }
}
