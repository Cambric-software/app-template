# Cambric design system

This is the app template's copy of the Cambric interface standard. The web and
game templates carry the same palette and radii, so a customer moving between
Cambric products sees one family. If a value changes here, it changes in
`web-template` and `game-template` in the same pass.

The code is the authority: `lib/theme/app_colors.dart`,
`lib/theme/design_tokens.dart`, `lib/theme/app_theme.dart` and
`lib/widgets/ds_widgets.dart`. This page explains the rules those files encode.

## Colour

Screens never name a hex value. They ask for a role, and the role resolves for
the current brightness. The same is true of status: colour is never the only
signal; every status also has a word and an icon.

### Brand and status

| Role | Light | Dark |
|---|---|---|
| Primary | `#3B6FE0` | `#7FA8FF` |
| Primary, pressed | `#24509F` | `#24509F` |
| Accent | `#12A594` | `#35D0BC` |
| Success | `#12855F` | `#43C79A` |
| Warning | `#B26A00` | `#E8A33C` |
| Danger | `#C63A34` | `#F0736B` |

### Surfaces and text

| Role | Light | Dark |
|---|---|---|
| Page background | `#F6F8FC` | `#0E1116` |
| Card surface | `#FFFFFF` | `#161B23` |
| Raised surface (inputs, nested panels) | `#FAFBFE` | `#1D232D` |
| Hairline / border | `#E2E6EF` | `#262E3A` |
| Primary text | `#101828` | `#EDF0F6` |
| Secondary text | `#5A6478` | `#A8B2C6` |
| Muted text | `#8A94A6` | `#737E92` |

Cards are separated by a hairline border, not by a shadow. A soft shadow
disappears on a dark surface and reads as smudge. Shadows are reserved for
surfaces that genuinely float (dialogs, dragged items, the app bar when
scrolled).

### Web

The static pages use the same family with a slightly deeper dark background,
because a marketing page is read rather than used:

| Role | Light | Dark |
|---|---|---|
| Background | `#F6F7FB` | `#0E1015` |
| Surface | `#FFFFFF` | `#171A22` |
| Raised | `#F0F2F7` | `#1E222C` |
| Border | `#E0E3EC` | `#2A2F3B` |
| Text | `#171A22` | `#E8EAF0` |
| Muted | `#5C6474` | `#9AA3B5` |
| Accent | `#3F6FE0` | `#5B8CFF` |
| Accent 2 | `#6A44E0` | `#7C5BFF` |

The web pages follow `prefers-color-scheme`; they do not ship a manual toggle
unless the product has a reason to.

## Spacing

Everything is a multiple of 4. The scale is `2, 4, 8, 12, 16, 24, 32, 48`.
Use `16` as the default gap, `24` between groups and `32` between sections.
Page padding is `20` on compact screens and `48` on large ones.

If a screen needs a value that is not on the scale, that is a signal the value
is arbitrary, not that the scale is incomplete.

## Radii

| Use | Radius |
|---|---:|
| Chip, tag | 6 |
| Input, nested panel | 8 |
| Button | 11 |
| Card (default) | 14 |
| Large panel | 20 |
| Sheet, dialog | 28 |
| Pill, avatar | 999 |

The web pages use 14 for cards, 11 for buttons and 6 for chips. That is
deliberate: the download page and the app must feel like one product.

## Type

Named by role, not by size.

| Role | Size | Weight | Use |
|---|---:|---:|---|
| Display | 32 | 700 | Screen title |
| Metric | 44 | 700 | One large number |
| Metric small | 26 | 700 | Secondary number |
| Title | 18 | 600 | Card and section title |
| Body | 15 | 400 | Reading text |
| Caption | 13 | 500 | Supporting detail |
| Overline | 11 | 700 | Section labels, upper case |

Numbers use tabular figures so a value does not shift sideways when it changes.
Line height is 1.45 for body text and 1.15–1.25 for titles.

## Components

`lib/widgets/ds_widgets.dart` is the only place a new control should be
invented. A screen composes these:

| Component | Job |
|---|---|
| `DsPage` | Page scaffold: title, scroll body, page padding, max width |
| `DsSection` | A titled group with optional trailing action |
| `DsCard` | Opaque surface, hairline border, radius 14, optional tap |
| `DsMetricTile` | Label, large value with unit, optional delta and footnote |
| `DsStatusPill` | Status word with icon and semantic colour |
| `DsEmptyState` | Icon, title, explanation and one action |
| `DsSegmented` | Two to five mutually exclusive views |
| `DsGrid` | Responsive card grid, 1 column compact, N columns when wide |

Rules:

1. A card holds one idea. If it needs two headings, it is two cards.
2. A button says what happens ("Save changes"), not what it is ("Submit").
3. Disabled controls state why they are disabled, in text next to them or in a
   tooltip. A disabled control with no reason is a bug.
4. Touch targets are at least 48×48 logical pixels.
5. Destructive actions are danger-coloured, confirm in a dialog, and name the
   thing being destroyed.
6. Empty states explain what would appear here and how to make it appear.
7. No lorem ipsum and no invented data. A template placeholder is labelled as a
   placeholder.

## Motion

`120 ms` for press feedback, `220 ms` for state changes, `380 ms` for larger
transitions. `easeOutCubic` entering, `easeInCubic` leaving. Respect the
platform's reduced-motion setting: no decorative motion when it is on.

## Layout

| Width | Layout |
|---|---|
| `< 600` | One column, bottom navigation |
| `600–1099` | One or two columns, bottom navigation |
| `≥ 1100` | Navigation rail, content max width 1080 |

The app is usable at 390×844 and 1440×900. Those are the two widths every
screen is checked at.

## Download page

`app/landing/` is the shared download page. It uses the web palette above,
opaque cards, radius 14 and buttons radius 11. Its links use the
version-independent `releases/latest/download/` alias, and it never prints a
version unless one is supplied. Read `app/landing/README.md` before publishing.
