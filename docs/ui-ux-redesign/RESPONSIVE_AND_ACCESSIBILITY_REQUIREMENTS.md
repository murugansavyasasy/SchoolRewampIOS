# Responsive and Accessibility Requirements

> Documentation only. "Existing" = verified current state; everything else is a requirement for the redesign. Target standard: **WCAG 2.1 AA** and Apple Human Interface Guidelines.

## 1. Device and orientation support

| Item | Existing | Requirement |
| --- | --- | --- |
| Device family | iPhone and iPad (`TARGETED_DEVICE_FAMILY = 1,2`) | **Decision needed:** either support iPad properly (regular-width layouts below) or remove iPad from the targets. Do not ship stretched phone layouts. |
| iPhone orientation | Portrait only | Keep portrait; media viewer and maps may allow landscape. |
| iPad orientation | All four | If iPad is kept: all orientations with regular-width layouts. |
| Minimum iOS | 16.0 | Unchanged. |
| Smallest width | 320 pt (iPhone SE 1st gen, if still supported) | Every screen must work at 320 pt with no horizontal scroll except data tables. |

## 2. Layout rules per size class

| Element | Compact width (iPhone) | Regular width (iPad) |
| --- | --- | --- |
| Navigation | Tab bar at bottom | Sidebar-adaptable tab bar |
| Lists → detail | Push | Split view (list 320–360 pt + detail) |
| Home tiles | 2 / 3 / 4 per row by width | 5–6 per row |
| Forms | Full width, 16 pt margins | Centred, max width 640 pt |
| Reports | Cards stacked, table scrolls horizontally | Cards in a row, table fits |
| Sheets | Bottom sheet (medium/large) | Form sheet or popover |
| Maps | Full screen + bottom sheet | Map + side panel |

**General rules:** no fixed heights on text containers; use content hugging and `minimum` heights only; keyboard must never cover the focused field or the primary button; safe areas respected on all edges.

## 3. Accessibility requirements

### 3.1 Perceivable
| Requirement | Existing | Target |
| --- | --- | --- |
| Text contrast | Brand and grey text fail in places (see audit §3) | 4.5:1 body, 3:1 large text and icons; use `brand.strong` tokens |
| Dynamic Type | 6 labels support it | All text uses text styles; layouts work up to Accessibility XL; tiles switch to a list at accessibility sizes |
| Colour not alone | Status shown mainly by colour in several lists | Status chips always carry text + icon |
| Images | No alternative text | Meaningful images labelled; decorative images hidden from VoiceOver |
| Audio content | Voice messages without transcript | Show message title/description with every voice item (transcripts are a future option) |

### 3.2 Operable
| Requirement | Target |
| --- | --- |
| Touch targets | Minimum 44 × 44 pt, 8 pt apart |
| VoiceOver | Every control labelled (0 accessibility settings in XIBs today); logical focus order; cards grouped into one element; custom actions for swipe actions |
| Switch Control / Full Keyboard Access | All actions reachable without gestures; no gesture-only features (long-press has a menu alternative) |
| Time limits | OTP and recording timers announced; no auto-dismiss of errors |
| Motion | Respect Reduce Motion (splash particles, confetti, fireworks, ripples) |

### 3.3 Understandable
| Requirement | Target |
| --- | --- |
| Form errors | Inline, specific, announced; field keeps focus |
| Consistent navigation | Same header, back and tab behaviour everywhere |
| Language | All strings through the translation lookup; no hard-coded English in new layouts |
| Plain wording | Replace technical server/system messages with friendly copy |

### 3.4 Robust
| Requirement | Target |
| --- | --- |
| Standard controls | Prefer system controls (segmented control, switches, pickers) over image-based toggles |
| Traits | Buttons, headers, selected and adjustable traits set correctly |

## 4. Localisation and right-to-left

| Item | Existing | Requirement |
| --- | --- | --- |
| Languages | English, Arabic, Hindi, Tamil, Thai | Unchanged |
| RTL | `UIApplicationSupportsRightToLeft = false` | Enable for Arabic; use leading/trailing constraints, mirrored chevrons, natural text alignment |
| Text expansion | Fixed-width labels in places | Allow 40% growth (Tamil, Hindi) without truncating actions |
| Numbers and currency | Server-formatted amounts (e.g. "₹2,64,970.00") | Display as received; do not re-format server amounts |
| Dates | Server strings in several formats | Display as received unless a module already parses them |

## 5. Testing checklist (per screen)

- [ ] iPhone SE (320 or 375 pt) and Pro Max, portrait
- [ ] iPad portrait and landscape (if iPad kept)
- [ ] Largest Dynamic Type and Accessibility XL
- [ ] VoiceOver: every control announced, order logical
- [ ] Arabic (RTL) layout
- [ ] Each flavour's brand colour (4 apps)
- [ ] Loading, empty, error, offline and success states
- [ ] Reduce Motion on
