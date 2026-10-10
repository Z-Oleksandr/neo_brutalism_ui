import 'package:flutter/material.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

import '../catalog/catalog_page.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final NeoRefreshController _refresh = NeoRefreshController();
  double _progress = 0.35;
  int _refreshes = 0;
  int _errors = 0;
  bool _alertVisible = true;

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _refreshes++);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    return NeoRefreshIndicator(
      controller: _refresh,
      onRefresh: _onRefresh,
      child: CatalogPage(
        children: [
          CatalogSection(
            title: 'Pull to refresh',
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Pull this page down. Refreshed $_refreshes times.',
                    style: theme.typography.body.copyWith(
                      color: theme.colors.ink,
                    ),
                  ),
                ),
                NeoButton(
                  label: 'Refresh',
                  size: NeoButtonSize.small,
                  onPressed: _refresh.refresh,
                ),
              ],
            ),
          ),
          CatalogSection(
            title: 'Loading dots',
            child: DemoWrap(
              children: [
                const NeoLoadingDots(),
                NeoLoadingDots(size: 12, color: theme.colors.pink),
              ],
            ),
          ),
          CatalogSection(
            title: 'Skeletons',
            child: NeoShimmer(
              child: NeoCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NeoSkeleton.avatar(size: 48),
                    SizedBox(width: theme.spacing.md),
                    const Expanded(child: NeoSkeleton.text()),
                  ],
                ),
              ),
            ),
          ),
          CatalogSection(
            title: 'Progress',
            child: Column(
              children: [
                NeoProgressBar(value: _progress, semanticLabel: 'Upload'),
                SizedBox(height: theme.spacing.md),
                DemoWrap(
                  children: [
                    NeoButton(
                      label: '-10%',
                      size: NeoButtonSize.small,
                      variant: NeoButtonVariant.outlined,
                      onPressed: () => setState(
                        () => _progress = (_progress - 0.1).clamp(0, 1),
                      ),
                    ),
                    NeoButton(
                      label: '+10%',
                      size: NeoButtonSize.small,
                      variant: NeoButtonVariant.outlined,
                      onPressed: () => setState(
                        () => _progress = (_progress + 0.1).clamp(0, 1),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: theme.spacing.lg),
                NeoProgressBar(color: theme.colors.pink),
              ],
            ),
          ),
          CatalogSection(
            title: 'Alert banners',
            child: Column(
              children: [
                for (final type in NeoAlertType.values)
                  if (type != NeoAlertType.info || _alertVisible)
                    Padding(
                      padding: EdgeInsets.only(bottom: theme.spacing.md),
                      child: NeoAlertBanner(
                        type: type,
                        title: type.name.toUpperCase(),
                        message: 'This is a ${type.name} message.',
                        actionLabel: type == NeoAlertType.error
                            ? 'Retry'
                            : null,
                        onAction: type == NeoAlertType.error ? () {} : null,
                        onDismiss: type == NeoAlertType.info
                            ? () => setState(() => _alertVisible = false)
                            : null,
                      ),
                    ),
              ],
            ),
          ),
          CatalogSection(
            title: 'Stickers',
            child: DemoWrap(
              children: [
                const NeoSticker(label: 'OFFLINE', icon: Icons.wifi_off),
                NeoSticker(label: 'NEW!', angle: -6, color: theme.colors.lime),
                NeoSticker(
                  label: 'SALE',
                  angle: 4,
                  color: theme.colors.yellow,
                  animate: false,
                ),
              ],
            ),
          ),
          CatalogSection(
            title: 'Error highlight',
            child: DemoWrap(
              children: [
                NeoErrorHighlight(
                  error: _errors == 0 ? null : _errors,
                  child: NeoTag(
                    label: 'Failed $_errors times',
                    size: NeoTagSize.medium,
                  ),
                ),
                NeoButton(
                  label: 'Fail',
                  size: NeoButtonSize.small,
                  color: theme.colors.danger,
                  onPressed: () => setState(() => _errors++),
                ),
              ],
            ),
          ),
          CatalogSection(
            title: 'Empty state',
            child: NeoCard(
              child: NeoEmptyState(
                icon: Icons.inbox,
                title: 'No parties yet',
                message: 'Create one and invite your friends.',
                actionLabel: 'Create party',
                onAction: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
