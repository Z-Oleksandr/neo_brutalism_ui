# neo_brutalism_ui

Neobrutalism UI components for Flutter: thick borders, hard shadows, bold type
and saturated colors. Fully themeable, light and dark, accessible, and with
no dependencies beyond Flutter.

- 50+ components: buttons, inputs, selection controls, navigation, overlays,
  feedback, display, media and date/time pickers
- One theme object (`NeoThemeData`) for colors, type, spacing, radii, borders,
  shadows and motion. Works as a Material `ThemeExtension` or standalone
- Readable text on any fill: foreground colors are picked by WCAG contrast
- Keyboard and screen-reader support, 48dp tap targets, focus rings, RTL,
  text scaling and reduced motion handled by every interactive component
- Localized defaults through `MaterialLocalizations`

## Install

```yaml
dependencies:
  neo_brutalism_ui:
    git:
      url: <repository url>
```

```dart
import 'package:neo_brutalism_ui/neo_brutalism_ui.dart';
```

## Quick start

```dart
MaterialApp(
  theme: NeoThemeData.light().toThemeData(),
  darkTheme: NeoThemeData.dark().toThemeData(),
  home: const HomePage(),
);
```

`toThemeData()` derives a matching Material theme (color scheme, scaffold
background, text selection) and registers the neo theme as an extension.
Without any setup, components fall back to the default light or dark theme
based on the ambient `Theme` brightness.

```dart
NeoButton(label: 'Join party', icon: Icons.add, onPressed: join);

NeoTextField(
  label: 'Email',
  hintText: 'you@example.com',
  errorText: emailError,
  onChanged: validate,
);

final ok = await showNeoConfirmDialog(
  context: context,
  title: 'Delete club?',
  message: 'This cannot be undone.',
  destructive: true,
);
```

## Theming

Every visual value comes from `NeoThemeData`. Read it with
`NeoTheme.of(context)` or the `context.neo` shortcut.

```dart
final brand = NeoThemeData.light(
  fontFamily: 'Space Grotesk',
  colors: NeoColors.light().copyWith(primary: const Color(0xFF00C2A8)),
).copyWith(
  radii: const NeoRadii(sm: 2, md: 4, lg: 6),
  shadows: const NeoShadows(md: Offset(6, 6)),
);

MaterialApp(theme: brand.toThemeData());
```

| Group        | Tokens |
| ------------ | ------ |
| `colors`     | 9 accents, `primary` `secondary` `success` `warning` `danger` `info`, `background`, `surface`, `surfaceMuted`, `border`, `shadow`, `ink` (+ muted, faint, subtle), `focus`, `scrim`, skeleton tones |
| `typography` | `display`, `headline`, `title`, `titleSmall`, `body`, `bodyStrong`, `label`, `caption`, `overline` |
| `spacing`    | `xs` 4, `sm` 8, `md` 12, `lg` 16, `xl` 24, `xxl` 32 |
| `radii`      | `sm` 4, `md` 8, `lg` 12 |
| `borders`    | `thin` 1.5, `regular` 2, `thick` 3 |
| `shadows`    | `sm` (2,2), `md` (4,4), `lg` (6,6), zero blur |
| `motion`     | `press`, `fast`, `medium`, `slow`, `curve` |

Use `colors.onColor(fill)` for text or icons drawn on any color. Wrap a
subtree in `NeoTheme(data: ..., child: ...)` to restyle only that part.
Themes interpolate, so animated theme changes work out of the box.

## Components

| Category   | Components |
| ---------- | ---------- |
| Buttons    | `NeoButton` (filled, outlined, inverted, ghost; small to large; loading; expanded), `NeoIconButton` |
| Inputs     | `NeoTextField`, `NeoTextFormField`, `NeoSearchField`, `NeoDropdown`, `showNeoMenu` |
| Selection  | `NeoCheckbox`, `NeoRadio`, `NeoSwitch`, `NeoChip`, `NeoSlider` |
| Navigation | `NeoAppBar`, `NeoTabBar`, `NeoSliverTabBar`, `NeoNavBar`, `NeoSegmentedControl` |
| Overlays   | `showNeoDialog` + `NeoDialog`, `showNeoConfirmDialog`, `showNeoBottomSheet`, `showNeoActionSheet`, `showNeoToast` |
| Feedback   | `NeoShimmer` + `NeoSkeleton`, `NeoLoadingDots`, `NeoProgressBar`, `NeoRefreshIndicator`, `NeoAlertBanner`, `NeoEmptyState`, `NeoErrorHighlight`, `NeoSticker` |
| Display    | `NeoCard`, `NeoBanner`, `NeoListTile`, `NeoAvatar`, `NeoAvatarGroup`, `NeoBadge`, `NeoTag`, `NeoDivider`, `NeoExpansionPanel`, `NeoQuoteBlock`, `NeoChatBubble` |
| Media      | `NeoImage`, `NeoMediaGallery`, `showNeoMediaViewer` |
| Pickers    | `NeoCalendar`, `NeoTimeSelector`, `showNeoDatePicker`, `showNeoTimePicker`, `showNeoDateTimePicker`, `showNeoDateRangePicker` |

Common patterns:

```dart
NeoRefreshIndicator(onRefresh: reload, child: ListView(...));

NeoShimmer(
  child: Row(children: [
    NeoSkeleton.avatar(size: 48),
    Expanded(child: NeoSkeleton.text(lines: 3)),
  ]),
);

NeoImage(image: NetworkImage(url), width: 120, height: 120);

final range = await showNeoDateRangePicker(
  context: context,
  firstDate: DateTime.now(),
  lastDate: DateTime.now().add(const Duration(days: 365)),
);

showNeoToast(context, message: 'Saved', type: NeoToastType.success);
```

Components never add outer margins, so layout stays in your hands.
Interactive components are disabled when their callback is `null`.

## Building your own

The primitives behind every component are public:

- `NeoSurface`: a bordered box with a hard shadow and a legible foreground
- `NeoPressableSurface`: the same box pressing down onto its shadow, with
  focus, keyboard, hover, semantics and a minimum tap target
- `NeoPressable`: the interaction layer alone, with a builder that receives
  the widget states and the press animation

```dart
NeoPressableSurface(
  color: context.neo.colors.pink,
  semanticLabel: 'Open profile',
  onPressed: openProfile,
  child: const Icon(Icons.person),
);
```

## Example

`example/` is a catalog of every component, with toggles for dark mode, RTL
and large text:

```sh
cd example && flutter run
```

## License

MIT
