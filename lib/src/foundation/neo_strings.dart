import 'package:flutter/material.dart';

/// Default user-visible strings. Resolved from [MaterialLocalizations] when
/// available so apps get translations for free, English otherwise.
@immutable
class NeoStrings {
  const NeoStrings({
    this.ok = 'OK',
    this.cancel = 'Cancel',
    this.close = 'Close',
    this.back = 'Back',
    this.clear = 'Clear',
    this.search = 'Search',
    this.loading = 'Loading',
    this.dismiss = 'Dismiss',
  });

  factory NeoStrings.of(BuildContext context) {
    final m = Localizations.of<MaterialLocalizations>(
      context,
      MaterialLocalizations,
    );
    if (m == null) return const NeoStrings();
    return NeoStrings(
      ok: m.okButtonLabel,
      cancel: m.cancelButtonLabel,
      close: m.closeButtonLabel,
      back: m.backButtonTooltip,
      clear: m.clearButtonTooltip,
      search: m.searchFieldLabel,
      dismiss: m.modalBarrierDismissLabel,
    );
  }

  final String ok;
  final String cancel;
  final String close;
  final String back;
  final String clear;
  final String search;
  final String loading;
  final String dismiss;
}
