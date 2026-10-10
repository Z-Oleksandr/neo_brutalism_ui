import 'package:flutter/material.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

import '../catalog/catalog_page.dart';

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  static const _defaultTags = ['rooftop', 'vinyl', 'late night'];

  final _toppings = {'Cheese': true, 'Olives': false, 'Peppers': false};
  final _interests = <String>{'Music'};
  final _tags = [..._defaultTags];
  String _visibility = 'open';
  bool _notifications = true;
  bool _location = false;
  double _volume = 0.4;
  double _radius = 10;

  bool? get _allToppings {
    final values = _toppings.values;
    if (values.every((v) => v)) return true;
    if (values.every((v) => !v)) return false;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    final colors = theme.colors;
    final labelStyle = theme.typography.label.copyWith(color: colors.ink);
    return CatalogPage(
      children: [
        CatalogSection(
          title: 'Checkbox',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeoCheckbox(
                value: _allToppings,
                tristate: true,
                label: 'All toppings',
                onChanged: (v) =>
                    setState(() => _toppings.updateAll((_, _) => v ?? false)),
              ),
              for (final entry in _toppings.entries)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: theme.spacing.xl),
                  child: NeoCheckbox(
                    value: entry.value,
                    label: entry.key,
                    color: colors.green,
                    onChanged: (v) =>
                        setState(() => _toppings[entry.key] = v ?? false),
                  ),
                ),
              const NeoCheckbox(
                value: true,
                label: 'Disabled',
                onChanged: null,
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Radio',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final option in const ['Open', 'Private', 'Secret'])
                NeoRadio<String>(
                  value: option.toLowerCase(),
                  groupValue: _visibility,
                  label: option,
                  onChanged: (v) => setState(() => _visibility = v),
                ),
              const NeoRadio<String>(
                value: 'club',
                groupValue: 'club',
                label: 'Club only (disabled)',
                onChanged: null,
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Switch',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeoSwitch(
                value: _notifications,
                label: 'Notifications',
                onChanged: (v) => setState(() => _notifications = v),
              ),
              NeoSwitch(
                value: _location,
                label: 'Share location',
                activeColor: colors.blue,
                onChanged: (v) => setState(() => _location = v),
              ),
              const NeoSwitch(value: true, label: 'Disabled', onChanged: null),
            ],
          ),
        ),
        CatalogSection(
          title: 'Filter chips',
          child: DemoWrap(
            children: [
              for (final (i, interest) in const [
                'Music',
                'Sports',
                'Art',
                'Food',
                'Games',
              ].indexed)
                NeoChip(
                  label: interest,
                  icon: Icons.tag,
                  color: colors.accents[i % colors.accents.length],
                  selected: _interests.contains(interest),
                  onSelected: (selected) => setState(
                    () => selected
                        ? _interests.add(interest)
                        : _interests.remove(interest),
                  ),
                ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Input chips',
          child: DemoWrap(
            children: [
              for (final tag in _tags)
                NeoChip(
                  label: tag,
                  onDeleted: () => setState(() => _tags.remove(tag)),
                ),
              if (_tags.isEmpty)
                NeoButton(
                  label: 'Restore tags',
                  size: NeoButtonSize.small,
                  onPressed: () => setState(() => _tags.addAll(_defaultTags)),
                ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Slider',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Volume ${(_volume * 100).round()}%', style: labelStyle),
              NeoSlider(
                value: _volume,
                label: 'Volume',
                onChanged: (v) => setState(() => _volume = v),
              ),
              Text('Radius ${_radius.round()} km', style: labelStyle),
              NeoSlider(
                value: _radius,
                min: 1,
                max: 50,
                divisions: 49,
                label: 'Radius',
                activeColor: colors.pink,
                semanticFormatter: (v) => '${v.round()} km',
                onChanged: (v) => setState(() => _radius = v),
              ),
              const NeoSlider(value: 0.6, label: 'Disabled', onChanged: null),
            ],
          ),
        ),
      ],
    );
  }
}
