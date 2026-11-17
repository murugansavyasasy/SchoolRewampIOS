# UI/UX Audit — School Chimes iOS

> Documentation only. Findings come from a static scan of all 468 XIB/storyboard files and the Swift source (counts below are exact at the time of analysis). No rendered screenshots were available, so visual judgements are inferred from layout attributes; confirm on device before prioritising.

## 1. Summary

The app is functional and feature-rich, but its interface grew screen by screen without a shared design system. The biggest problems are **inconsistent visual language** (30 font sizes, 258 hard-coded colours), **modal-only navigation** (536 `present` vs 2 `push`), **blocking feedback patterns** (full-screen loader, alerts for everything), **no accessibility support** (0 accessibility settings in XIBs, 6 Dynamic Type labels) and **brand colours that fail contrast** in two white-label apps.

## 2. Evidence from the scan

| Measure | Value | What it means |
| --- | --- | --- |
| Distinct font sizes in XIBs | 30 (9 pt to 32 pt; most used 17, 14, 13, 12, 15) | No type scale |
| Font families in XIBs | System, plus stray Futura, HelveticaNeue, Optima | Inconsistent typography |
| Poppins applied in code | 457 `setFont(style:)` calls; sizes `FontSize.HeaderSize 15`, `TitleSize 14`, `BodySize 13` | XIB fonts are overridden at runtime, so XIBs do not show the real UI |
| Hard-coded RGB colours in XIBs | 258 distinct values | No colour tokens |
| Named colours in XIBs | 74 (mix of system colours and app assets such as `BackGroundClr`, `PrimeryColor`, `topBackgroundCLr`) | Partial theming |
| Colours created in code | 395 `UIColor(red:)`, 76 `UIColor(hex:)` | More untracked colours |
| Corner radius set in code | 1,059 assignments; XIB values 5, 6, 7, 8, 9, 10, 12, 15, 16, 20, 23 | No shape scale |
| Accessibility settings | 0 in XIBs; 12 accessibility label/hint/trait uses in code | VoiceOver users get unlabeled buttons and icons |
| Dynamic Type | 6 labels adjust for text size; 16 code uses | Text does not grow with user settings |
| Appearance | `UIUserInterfaceStyle = Light` forced | Dark mode unsupported |
| Navigation | 536 `present`, 2 `pushViewController`, 282 explicit full-screen modals | No swipe-back, no navigation history, stacked modals |
| Headers | 81 screens use the custom `BottomRoundedView` header; others use different bars | Header is close to a pattern but not a component |
| Empty-state images | At least 12 different illustrations (`NoMessage`, `NohomeWork`, `noEvents`, `noSearchData`, …) | Empty states vary by module |
| Loading | `showActivityLoader` (71 uses): full-screen dim overlay with Lottie, auto-closes after 10 s | Blocks the whole UI; can disappear while still loading |
| Pull to refresh | 2 screens | Most lists cannot be refreshed in place |
| Feedback | 251 `showAlert`, 111 `UIAlertController`, 39 toasts | Alerts used for routine messages |
| Devices | iPhone and iPad targeted; iPad allows landscape; 19 idiom checks in code | iPad gets stretched phone layouts |
| RTL | Arabic shipped, but `UIApplicationSupportsRightToLeft = false` | Arabic text appears in left-to-right layouts |

## 3. Contrast of brand colours (white text on brand colour, as used in headers and buttons)

WCAG AA needs 4.5:1 for normal text, 3:1 for large text and icons.

| Flavour / colour | Hex | White-on-colour | Result |
| --- | --- | --- | --- |
| School Chimes `BackGroundClr` | `#377CF4` | 3.92:1 | Passes only for large text |
| School Chimes `PrimeryColor` | `#3C82EC` | 3.75:1 | Large text only |
| Sri Sudha Dhone | `#F62B37` | 3.95:1 | Large text only |
| Wisdom Group | `#6BB557` | 2.51:1 | **Fails** |
| Sri Kalaivani | `#7F1A37` | 9.97:1 | Passes |
| `ButtonColor` (orange) | `#E16B25` | 3.32:1 | Large text only |
| `auth_screenClr` | `#1EBCE6` | 2.24:1 | **Fails** |
| Grey text `#8E9AA8` / `#9AA8BC` on white | — | 2.86:1 / 2.41:1 | **Fail** for body text |

## 4. Findings by area

Each finding: **Problem → Impact → Recommendation.** Severity: High (blocks or misleads users), Medium (slows or confuses), Low (polish).

### 4.1 Visual hierarchy and layout

| # | Problem | Impact | Recommendation | Severity |
| --- | --- | --- | --- | --- |
| V1 | Home is a flat grid of server menus (two columns) plus a "frequently used" carousel, with no grouping | Staff with 20+ menus scan the whole grid for daily tasks | Group tiles into sections (Communicate, Academics, Attendance, Reports, Admin) using a client-side map of menu IDs; keep server order inside groups; pin "Today" tasks on top | Medium |
| V2 | Large coloured header (`BottomRoundedView`, about 150 pt tall) on most screens | Less content above the fold on small phones | Compact header (56–64 pt) with large-title on scroll; keep brand colour as accent | Medium |
| V3 | Spacing and radii vary per screen (11 radius values, ad hoc padding) | App feels assembled from different apps | Spacing and radius tokens (see design system) | Low |
| V4 | Splash runs long decorative animations before work starts | Slower perceived launch, especially for daily users | Static brand splash; show progress only while waiting on network | Medium |

### 4.2 Navigation and information architecture

| # | Problem | Impact | Recommendation | Severity |
| --- | --- | --- | --- | --- |
| N1 | Every module opens as a full-screen modal; deeper steps stack more modals; "back to dashboard" is done by dismissing several presenting controllers | No swipe-back; users lose context; fragile return paths | One navigation stack per tab; push for drill-down; sheets only for short tasks | High |
| N2 | Tab bar holds Home, Holidays, Settings, Profile; side menu repeats Profile and Settings | Duplicate entry points; two low-frequency tabs use prime space | Tabs: Home, Inbox (messages/notifications), Calendar (holidays/events), Profile (settings inside) | Medium |
| N3 | Switching school/child is hidden in the side menu ("Switch Login") and re-runs the role screen | Users with several children or schools do not know which record is active | Persistent switcher in the header showing name, class/school; one-tap switch sheet | High |
| N4 | Management must pick a school in `SchoolListVC` before many features, and that choice silently changes the active record | Confusing state; later screens use a school the user did not expect | Show the active school in the header; ask once per session or keep last choice visible | High |
| N5 | Role picker mixes "tap a row" (teachers) and "Next" (management); non-teaching staff with several schools can get stuck | Dead end for some users | Single pattern: list of records, tap to choose | High |
| N6 | Unmapped menu IDs show an empty "OK" alert on the parent side | Users tap a tile that does nothing | Hide unmapped tiles or show "Coming soon" with context | Low |

### 4.3 Typography, colour and consistency

| # | Problem | Impact | Recommendation | Severity |
| --- | --- | --- | --- | --- |
| T1 | 30 font sizes; Poppins applied in code over system fonts in XIBs; stray Futura/Optima/Helvetica | Inconsistent rhythm; XIB preview differs from runtime | One type scale mapped to iOS text styles; one family (recommendation: system SF Pro for UI, Poppins only for brand headings if kept) | Medium |
| T2 | 258 RGB colours + 74 named + 471 in code | Brand changes need edits in hundreds of places; inconsistent greys | Semantic colour tokens per flavour | Medium |
| T3 | Brand colours fail contrast in Wisdom and auth screens; light grey body text fails | Hard to read in sunlight; accessibility failure | Add an accessible "brand strong" shade per flavour for text/buttons; minimum grey `#64748B` on white | High |
| T4 | Status colours (pending, approved, absent) are defined per screen | Same status looks different across modules | Shared status palette and status chip component | Medium |

### 4.4 Accessibility and readability

| # | Problem | Impact | Recommendation | Severity |
| --- | --- | --- | --- | --- |
| A1 | No accessibility labels on icon buttons, tiles, audio controls | VoiceOver unusable on key flows (login, home, recording) | Label every interactive element; group cards as one element | High |
| A2 | No Dynamic Type | Older parents with large text settings cannot read | Text styles with scaling; layouts that wrap | High |
| A3 | Small text (9–11 pt in 186 places) | Hard to read | Minimum 12 pt for secondary, 15–17 pt for body | Medium |
| A4 | Arabic without right-to-left layout | Broken reading order for Arabic users | Enable RTL and use leading/trailing constraints | Medium |
| A5 | Many custom controls (radio buttons, checkboxes as images) | No state announced | Use controls with traits/values | Medium |

### 4.5 Forms and validation

| # | Problem | Impact | Recommendation | Severity |
| --- | --- | --- | --- | --- |
| F1 | Validation errors appear as alerts after tapping submit ("Please fill all required field") | Users must dismiss, then hunt for the field | Inline field errors, disabled primary button until valid, required markers | Medium |
| F2 | Login network failures are silent on some screens; loader can stay | Users think the app froze | Inline error with Retry | High |
| F3 | Long multi-step creation (class test, PTM, quiz) has no visible step indicator on every screen | Users do not know how far they are | Stepper with step titles; save draft | Medium |
| F4 | Date and time selection uses several custom pickers | Inconsistent input | One date/range picker component | Low |

### 4.6 Data presentation and discoverability

| # | Problem | Impact | Recommendation | Severity |
| --- | --- | --- | --- | --- |
| D1 | Reports are long lists with limited sorting/filtering; charts used in a few screens only | Hard to find exceptions (absentees, pending fees) | Summary cards first, then filterable list; consistent charts | Medium |
| D2 | Message history and inbox lists mix types without filters | Parents miss important messages | Filters (All, Messages, Voice, Notices, Homework) and unread state | Medium |
| D3 | Fees on the parent side are a web view | Inconsistent look; poor offline behaviour | Native fee summary using the same layout as the staff fee details | Medium |

### 4.7 Loading, empty, error and success states

| # | Problem | Impact | Recommendation | Severity |
| --- | --- | --- | --- | --- |
| S1 | Full-screen blocking loader, auto-hidden after 10 s even if the call is still running | Users cannot cancel; may see stale data | Skeletons for content, inline spinners for actions, no timeout-based hiding | High |
| S2 | Empty states use 12+ different illustrations and wording | Inconsistent | One empty-state component: icon, title, one-line reason, optional action | Low |
| S3 | Errors: alerts with raw server or system messages | Confusing technical text | Friendly message + retry; log technical detail | Medium |
| S4 | Success: alerts or toasts depending on screen | Inconsistent confirmation | Toast/snackbar for success; full confirmation screen only after high-impact sends (calls to all parents) | Low |
| S5 | Pull to refresh in 2 screens | Users reopen screens to refresh | Pull to refresh on every list | Medium |

### 4.8 Responsive behaviour

| # | Problem | Impact | Recommendation | Severity |
| --- | --- | --- | --- | --- |
| R1 | iPad supported but layouts are phone layouts stretched; iPad landscape allowed | Wide, sparse screens on iPad | Either remove iPad from targets or define regular-width layouts (split view, 2–3 column grids) | Medium |
| R2 | Fixed heights in many XIBs (e.g. 150 pt headers, 300 pt images) | Clipping on iPhone SE and with larger text | Content-hugging layouts; min heights only | Medium |

### 4.9 Unnecessary interactions and confusing workflows

| # | Problem | Impact | Recommendation | Severity |
| --- | --- | --- | --- | --- |
| W1 | Role screen shown on every launch for multi-record accounts | Extra taps daily | Remember last record; switch from header | Medium |
| W2 | Login split across mobile screen, password screen, OTP screen, and a combined login screen after logout | Different paths for the same task | One adaptive flow | Medium |
| W3 | Attendance marking requires per-student taps and a confirmation of absent calls | Slow for large classes | Default "all present", tap to mark absent; keep the absent-call confirmation | Medium |
| W4 | School picker before many management features | Repeated interruption | Remember choice; show it in header | Medium |

## 5. Top problems (ranked)

1. Modal-only navigation without back stack (N1).
2. Hidden or confusing account/school/child context (N3, N4, N5).
3. No accessibility or Dynamic Type (A1, A2).
4. Blocking loader and silent/alert-based errors (S1, F2, S3).
5. Brand colour contrast failures (T3).
6. No design system: fonts, colours, radii, status colours (T1, T2, T4, V3).
