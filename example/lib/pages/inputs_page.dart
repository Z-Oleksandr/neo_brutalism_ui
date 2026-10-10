import 'package:flutter/material.dart';
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';

import '../catalog/catalog_page.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({super.key});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  String _query = '';
  String? _size;
  String _city = 'Berlin';
  String _visibility = 'Open';
  String? _menuChoice;

  @override
  Widget build(BuildContext context) {
    final theme = context.neo;
    final gap = SizedBox(height: theme.spacing.lg);
    return CatalogPage(
      children: [
        CatalogSection(
          title: 'Text field',
          child: Column(
            children: [
              const NeoTextField(
                label: 'Name',
                hintText: 'Ada Lovelace',
                helperText: 'As shown on your profile',
                prefixIcon: Icons.person,
              ),
              gap,
              NeoTextField(
                label: 'Password',
                hintText: 'At least 8 characters',
                obscureText: _obscure,
                prefixIcon: Icons.lock,
                suffix: NeoPressable(
                  semanticLabel: _obscure ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  builder: (context, states, press) => Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                  ),
                ),
              ),
              gap,
              const NeoTextField(
                label: 'Email',
                hintText: 'you@example.com',
                errorText: 'Enter a valid email address',
              ),
              gap,
              const NeoTextField(
                label: 'Bio',
                hintText: 'Tell people about yourself',
                minLines: 3,
                maxLines: 6,
                maxLength: 200,
              ),
              gap,
              const NeoTextField(
                label: 'Disabled',
                hintText: 'Not editable',
                enabled: false,
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Form validation',
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                NeoTextFormField(
                  label: 'Party name',
                  hintText: 'Rooftop session',
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'A name is required' : null,
                ),
                gap,
                NeoTextFormField(
                  label: 'Guests',
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      int.tryParse(v ?? '') == null ? 'Enter a number' : null,
                ),
                gap,
                NeoButton(
                  label: 'Validate',
                  expanded: true,
                  onPressed: () => _formKey.currentState!.validate(),
                ),
              ],
            ),
          ),
        ),
        CatalogSection(
          title: 'Search (debounced)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeoSearchField(
                hintText: 'Search parties',
                debounce: const Duration(milliseconds: 300),
                onChanged: (v) => setState(() => _query = v),
              ),
              SizedBox(height: theme.spacing.sm),
              Text(
                _query.isEmpty ? 'Type to search' : 'Searching for "$_query"',
                style: theme.typography.caption.copyWith(
                  color: theme.colors.inkMuted,
                ),
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Dropdown',
          child: DemoWrap(
            children: [
              NeoDropdown<String>(
                items: const ['Small', 'Medium', 'Large'],
                value: _size,
                hint: 'Pick a size',
                labelBuilder: _identity,
                onChanged: (v) => setState(() => _size = v),
              ),
              NeoDropdown<String>(
                items: const ['Berlin', 'Kyiv', 'Lisbon', 'Tokyo'],
                value: _city,
                color: theme.colors.blue,
                iconBuilder: (_) => Icons.location_city,
                labelBuilder: _identity,
                onChanged: (v) => setState(() => _city = v),
              ),
              const NeoDropdown<String>(
                items: ['Locked'],
                value: 'Locked',
                labelBuilder: _identity,
                onChanged: null,
              ),
              NeoDropdown<String>(
                items: const ['Open', 'Private', 'Secret'],
                value: _visibility,
                expanded: true,
                labelBuilder: _identity,
                onChanged: (v) => setState(() => _visibility = v),
              ),
            ],
          ),
        ),
        CatalogSection(
          title: 'Menu',
          child: DemoWrap(
            children: [
              Builder(
                builder: (context) => NeoButton(
                  label: 'Actions',
                  icon: Icons.more_horiz,
                  variant: NeoButtonVariant.outlined,
                  onPressed: () => _openMenu(context),
                ),
              ),
              Text(
                _menuChoice == null ? 'Nothing chosen' : 'Chose $_menuChoice',
                style: theme.typography.body.copyWith(color: theme.colors.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    final choice = await showNeoMenu<String>(
      context: context,
      items: const [
        NeoMenuItem(value: 'Edit', label: 'Edit', icon: Icons.edit),
        NeoMenuItem(value: 'Share', label: 'Share', icon: Icons.share),
        NeoMenuItem(
          value: 'Delete',
          label: 'Delete',
          icon: Icons.delete,
          enabled: false,
        ),
      ],
    );
    if (choice != null && mounted) setState(() => _menuChoice = choice);
  }
}

String _identity(String s) => s;
