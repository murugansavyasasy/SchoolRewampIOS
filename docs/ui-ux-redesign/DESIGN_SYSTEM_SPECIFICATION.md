# Design System Specification — School Chimes iOS (proposed)

> Documentation only. Values are **recommendations** unless marked "existing". Contrast ratios were calculated with the WCAG 2.1 formula against white (`#FFFFFF`).

## 1. Principles for tokens

- Screens use **semantic tokens** only (`color.text.primary`), never raw hex.
- Each white-label flavour overrides only the **brand** tokens; all other tokens are shared.
- Tokens map to asset-catalog colours and text styles so XIBs and code read the same names.

## 2. Colour

### 2.1 Brand tokens (per flavour)

| Token | Use | School Chimes | Sri Sudha Dhone | Sri Kalaivani | Wisdom Group |
| --- | --- | --- | --- | --- | --- |
| `color.brand` (existing `BackGroundClr`) | Illustrations, large areas, splash | `#377CF4` | `#F62B37` | `#7F1A37` | `#6BB557` |
| `color.brand.strong` (new) | Buttons, links, selected states, text on white | `#1F5FD1` (5.81:1) | `#C81E29` (5.72:1) | `#7F1A37` (9.97:1) | `#3D7A32` (5.21:1) |
| `color.brand.subtle` (new) | Tile backgrounds, selected chips | brand at 12% on white | same rule | same rule | same rule |
| `color.on.brand` | Text/icons on `brand.strong` | `#FFFFFF` | `#FFFFFF` | `#FFFFFF` | `#FFFFFF` |

Existing brand colours are kept for identity; text and controls move to the **strong** shade so they pass AA (the existing values give 3.92, 3.95, 9.97 and 2.51:1).

### 2.2 Neutrals (shared)

| Token | Light | Notes |
| --- | --- | --- |
| `color.background` | `#F8FAFC` | Screen background |
| `color.surface` | `#FFFFFF` | Cards, sheets, bars |
| `color.surface.secondary` | `#F1F5F9` | Expanded rows, chips, inputs |
| `color.border` | `#E2E8F0` | Hairlines, field borders |
| `color.text.primary` | `#0F172A` | Body and titles (most used dark in XIBs today) |
| `color.text.secondary` | `#475569` | Meta text (7.58:1) |
| `color.text.tertiary` | `#64748B` | Captions only (4.76:1; existing most-used grey) |
| `color.text.disabled` | `#94A3B8` | Disabled only (decorative) |

Greys used today for body text (`#8E9AA8`, `#9AA8BC`) fail contrast and should map to `color.text.secondary`.

### 2.3 Semantic and status (shared)

| Token | Strong (text/icon) | Subtle (background) | Use |
| --- | --- | --- | --- |
| `color.success` | `#047857` (5.48:1) | `#ECFDF5` | Approved, Paid, Present, Sent |
| `color.warning` | `#B45309` (5.02:1) | `#FFFBEB` | Pending, due soon |
| `color.danger` | `#B91C1C` (6.47:1) | `#FEF2F2` | Rejected, Absent, Failed, destructive |
| `color.info` | `#2563EB` (5.17:1) | `#EFF6FF` | Partially paid, Scheduled, information |
| `color.neutral` | `#475569` | `#F1F5F9` | Unknown / other |

### 2.4 Dark appearance (optional phase)
Today the app forces Light mode (existing). If dark mode is added later: background `#0B1220`, surface `#111827`, surface secondary `#1F2937`, border `#334155`, text primary `#F1F5F9`, secondary `#CBD5E1`; brand strong uses the original brand colour (sufficient on dark), re-checked per flavour.

### 2.5 Chart palette
Categorical (in order): `#2563EB`, `#D97706`, `#059669`, `#DB2777`, `#7C3AED`, `#0891B2`. Status charts use the status tokens. Brand colour may lead series 1 when it passes 3:1 against white.

## 3. Typography

Font: **SF Pro** (system) via iOS text styles so Dynamic Type works. Poppins (existing brand font) only for `type.display` if the brand wants it.

| Token | iOS text style | Size / line height (default) | Weight | Use |
| --- | --- | --- | --- | --- |
| `type.display` | Large Title | 34 / 41 | Bold | Tab top titles |
| `type.title1` | Title 1 | 28 / 34 | Bold | Summary values |
| `type.title2` | Title 2 | 22 / 28 | Bold | Screen headings, auth titles |
| `type.title3` | Title 3 | 20 / 25 | Semibold | Section headings on detail screens |
| `type.headline` | Headline | 17 / 22 | Semibold | Card titles, buttons |
| `type.body` | Body | 17 / 22 | Regular | Body text, inputs |
| `type.callout` | Callout | 16 / 21 | Regular | Message previews |
| `type.subheadline` | Subheadline | 15 / 20 | Regular | Meta lines, field labels |
| `type.footnote` | Footnote | 13 / 18 | Regular | Tile labels, helper text |
| `type.caption` | Caption 1 | 12 / 16 | Regular | Timestamps, chart labels (minimum size) |

Rules: no text below 12 pt; numbers in tables and amounts use monospaced digits; maximum 2 weights per card.

## 4. Spacing and layout

| Token | Value |
| --- | --- |
| `space.1` … `space.10` | 4, 8, 12, 16, 20, 24, 32, 40, 48, 64 pt |
| Screen margin | 16 pt (compact), 20 pt (regular), max content width 720 pt |
| Card padding | 16 pt |
| Gap between cards | 12 pt |
| Section gap | 24 pt |
| List row min height | 44 pt (single line), 60 pt (two lines) |

## 5. Shape, borders, elevation

| Token | Value | Use |
| --- | --- | --- |
| `radius.sm` | 8 | Inputs, chips, small buttons, expanded rows |
| `radius.md` | 12 | Cards, primary buttons |
| `radius.lg` | 16 | Sheets, tiles |
| `radius.full` | 999 | Pills, avatars, status chips |
| `border.hairline` | 1 px `color.border` | Separators, card borders when no shadow |
| `border.focus` | 2 pt `color.brand.strong` | Focused inputs |
| `elevation.0` | none | Cards on `color.background` |
| `elevation.1` | y 1, blur 3, black 8% | Floating buttons, sticky bars |
| `elevation.2` | y 8, blur 24, black 12% | Sheets, toasts |

Replaces today's 11 radius values and ad hoc shadows.

## 6. Iconography

SF Symbols, weight Regular (Semibold in tiles), sizes 17 (inline), 22 (bar buttons), 28 (tiles), 44 (empty states). Filled variants for selected tab items and status icons.

## 7. Motion

| Token | Duration | Curve | Use |
| --- | --- | --- | --- |
| `motion.fast` | 150 ms | ease-out | Pressed states, chip toggles |
| `motion.standard` | 250 ms | ease-in-out | Expand/collapse, sheets |
| `motion.slow` | 400 ms | spring | Celebration only |
With Reduce Motion: cross-fade instead of movement; no confetti, ripples or particle effects.

## 8. Responsive breakpoints (size classes)

| Class | Width | Devices | Layout |
| --- | --- | --- | --- |
| Compact S | 320–374 pt | iPhone SE (1st gen) | 2 tiles per row, single column |
| Compact M | 375–429 pt | Most iPhones | 3 tiles per row |
| Compact L | 430+ pt | Pro Max / Plus | 4 tiles per row |
| Regular | 678+ pt | iPad, iPad split view | Sidebar tabs, split view lists, 5–6 tiles per row, max content 720 pt in forms |

## 9. Component states (shared)

| State | Visual |
| --- | --- |
| Default | Tokens as specified |
| Pressed | Darken fill 8% or scale 0.97 (tiles) |
| Focused | `border.focus` |
| Selected | `color.brand.subtle` background + `color.brand.strong` content, checkmark where relevant |
| Disabled | 40% opacity, not tappable, explained nearby when not obvious |
| Loading | Skeleton (content) or spinner (actions) |
| Error | `color.danger` text + icon, `color.danger.subtle` background for banners |
| Success | `color.success` icon + toast |
| Unread | Bold title + 8 pt `color.brand.strong` dot |
