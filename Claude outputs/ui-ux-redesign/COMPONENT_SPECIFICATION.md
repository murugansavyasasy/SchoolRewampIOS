# Component Specification — School Chimes iOS (proposed redesign)

> Documentation only. Components listed here exist today in some form (the "Today" line names the current implementation) and are specified for the redesign. Token names (`color.*`, `space.*`, `radius.*`, `type.*`) refer to `DESIGN_SYSTEM_SPECIFICATION.md`. Values are recommendations.

Every component must support: light appearance (dark optional, see design system), Dynamic Type, VoiceOver, right-to-left, and the states listed.

---

## 1. Navigation

### 1.1 Header bar
- **Today:** custom `BottomRoundedView` (~150 pt, brand colour, white back chevron and title) on 81 screens; other screens use ad hoc bars.
- **Proposed:** standard navigation bar. Height 44 pt (+ large title 52 pt on top-level tabs). Background `color.surface` with hairline `color.border` on scroll; brand colour only for the back chevron and primary bar button.
- **Content:** back (when pushed) · title (`type.headline`, 1 line, truncates middle) · trailing: up to 2 icon buttons or 1 text button · **context chip** on top-level screens.
- **States:** default, scrolled (shadow/border), search active.
- **Accessibility:** title is the screen's accessibility heading; back labelled with the previous screen's title.

### 1.2 Context chip and account switcher
- **Today:** "Switch Login" in side menu → `PriorityVC`.
- **Proposed:** chip in header: 24 pt avatar + "Name · Class V-B" or "Principal · School". Tap opens a sheet (medium detent) listing Staff records (school logo, school, role) and Parent records (photo, name, class, school), current one checked, disabled rows show reason (`display_message`).
- **States:** single record (chip not tappable), multiple, loading switch (row spinner), blocked record.
- **Accessibility:** "Account: Arun, Class 5 B. Double-tap to switch."

### 1.3 Tab bar
- **Today:** custom tab bar in `TapBarVC`: Home, Holidays, Settings, Profile.
- **Proposed:** system tab bar: Home, Inbox, Calendar, Profile. Icons SF Symbols (`house`, `tray`, `calendar`, `person.crop.circle`), selected tint `color.brand.strong`. Badge on Inbox from unread counts.
- **Regular width:** sidebar-adaptable tab bar on iPad.

### 1.4 Side menu
- **Today:** `SideMenuVC` with Profile, Settings, Switch Login, Logout.
- **Proposed:** removed. Items move to the Profile tab and the context chip.

### 1.5 Stepper (multi-step flows)
- Horizontal steps with numbers and short titles (class test, exam marks, PTM). Current step `color.brand.strong`; completed steps checkmark; tap completed steps to go back.

---

## 2. Home components

### 2.1 Feature tile
- **Today:** two-column collection cells with icon and server name; "frequently used" carousel.
- **Proposed:** 72 × 72 pt icon tile area: tinted rounded square (radius 16, `color.brand.subtle` background, SF Symbol 28 pt in `color.brand.strong`) + label below (`type.footnote`, 2 lines max). Badge (top-right) for unread counts.
- **States:** default, pressed (scale 0.97), disabled (not used — server decides visibility), badge.
- **Accessibility:** "Homework, 3 new, button".

### 2.2 Tile group
- Section title (`type.headline`) + grid of tiles; groups collapse to "Show all" after 2 rows on compact width.

### 2.3 Today card
- Horizontal scroll of cards 260 × 112 pt: icon, title, value/summary, one action ("Mark now"). Only data already available (see REDESIGN_OVERVIEW §4.4).

---

## 3. Buttons and controls

### 3.1 Buttons
| Variant | Use | Style |
| --- | --- | --- |
| Primary | Main action per screen (Send, Submit, Continue) | Filled `color.brand.strong`, white text `type.headline`, height 50, radius 12, full width in forms |
| Secondary | Alternative action | Tinted `color.brand.subtle` fill, brand text |
| Tertiary | Low-emphasis (Skip, Change) | Text only, brand colour |
| Destructive | Logout, Reject, Delete | Filled `color.danger` or text in `color.danger` |
| Icon button | Toolbar actions | 44 × 44 hit area, 22 pt symbol |
- **States:** default, pressed (darken 8%), disabled (40% opacity, not focusable as action), loading (spinner replaces label, width fixed).

### 3.2 Text field
- Label above (`type.subheadline`), field 48 pt, radius 8, border `color.border`, focus border `color.brand.strong` 2 pt, helper text below, error text in `color.danger` with icon, character counter trailing when a limit exists.
- **States:** empty, focused, filled, error, disabled, read-only.

### 3.3 Text area
- Same as text field, min height 120 pt, grows with content to 240 pt, counter "120 / 160".

### 3.4 Phone number field
- Country code prefix (from country list) + number; formats to the country length; numeric keypad.

### 3.5 OTP field
- One field rendered as 6 boxes; one-time-code content type; auto-advance and paste support.

### 3.6 Selection controls
- Checkbox and radio rows use system list accessories (checkmark) rather than image toggles; segmented control for 2–4 exclusive options (Text/Voice; P/A/OD).

### 3.7 Dropdown / menu picker
- **Today:** bundled DropDown library and custom pickers.
- **Proposed:** pull-down menu for ≤ 7 options; sheet with search for longer lists (classes, subjects, academic years).

### 3.8 Date, time and range picker
- **Today:** `DatePickerVC`, `RiminderTimePicker`, FSCalendar views.
- **Proposed:** compact system date picker inline; range picker in a sheet with quick ranges (Today, This week, This month).

### 3.9 Search field
- System search field in navigation bar; scope chips below when filters exist; recent searches optional.

### 3.10 Filter chips
- Horizontal scroll of pill chips (height 32, radius full). Selected: `color.brand.strong` fill + white text; unselected: `color.surface.secondary` + `color.text.primary`. Show counts where available ("Pending 4").

---

## 4. Data display

### 4.1 List card
- Container: `color.surface`, radius 12, padding 16, spacing 8. Leading status bar (4 pt) optional for status-driven lists. Lines: title (`type.headline`), meta (`type.subheadline`, secondary), body preview (2 lines), footer (chips, attachment count, chevron).
- **States:** default, pressed, unread (bold title + dot), selected (iPad split view).

### 4.2 Status chip
- Pill with icon + label; colours from `color.status.*`: Pending (amber), Approved/Paid/Present/Sent (green), Partially paid/Scheduled (blue), Rejected/Absent/Failed (red), Other (slate). Background 14% tint, text in the strong shade (AA).

### 4.3 Summary stat card
- Label (`type.caption`), value (`type.title2` bold), optional delta or progress bar. Used in fee summary, reports, attendance counts.

### 4.4 Key–value list
- Inset grouped rows; key secondary left, value primary right, wraps under key when long.

### 4.5 Expandable row
- Row with chevron; expanded area on `color.surface.secondary`, radius 8, two-line items (name, then amounts). Used for fee breakdowns, month details, rubric details.

### 4.6 Data table (iPad / reports)
- Sticky header row and first column; zebra rows optional; numeric columns right-aligned with tabular figures; horizontal scroll on compact width.

### 4.7 Charts
- **Today:** DGCharts pie charts (7 XIB uses), custom progress views.
- **Proposed:** bar charts for comparisons (class-wise strength, attendance by day), line for trends (marks across exams), single progress bar for part-of-whole (fee paid). Pie only for 2–3 slices. Colours from categorical tokens; labels direct, not legend-only.

### 4.8 Calendar and date strip
- Month calendar with dots for events/attendance status; horizontal date strip for homework.

### 4.9 Avatar
- Circle 24/32/40/64 pt; image via URL with initials fallback.

---

## 5. Media

### 5.1 Attachment picker and grid
- Add button opens menu: Camera, Photos, Files, Record audio, Video (only types the feature allows). Grid of 88 pt thumbnails with type icon, remove button, upload progress ring, retry on failure.

### 5.2 Audio recorder
- Large circular record button (64 pt), timer "0:12 / 1:00" against the feature limit, waveform, play / re-record / delete.

### 5.3 Audio player
- Inline: play/pause, scrubber, elapsed/total, speed (1×, 1.5×).

### 5.4 Media viewer
- Full-screen, pinch zoom, swipe between items, share/download, close.

### 5.5 Map with bottom sheet
- Map fills screen; sheet with bus/geofence details; recenter button; last-updated time.

---

## 6. Feedback

### 6.1 Loading
- **Today:** full-screen dim + Lottie loader, auto-hides after 10 s.
- **Proposed:** skeleton placeholders for content; inline spinner in buttons; small progress bar under the navigation bar for background refresh; no timeout-based hiding.

### 6.2 Empty state
- Icon or illustration (one style), title, one sentence explaining why, optional primary action. Never just "No data found".

### 6.3 Error state
- Inline banner (`color.danger.subtle`) with message and Retry for screen-level failures; field errors inline. Map server `message` to friendly copy where possible.

### 6.4 Toast / snackbar
- Bottom, 3–4 s, for success and non-blocking info ("Homework sent"), optional Undo where supported.

### 6.5 Alert (blocking)
- System alert only for destructive confirmation and forced update.

### 6.6 Confirmation sheet
- Summary of a high-impact action (recipients, call to parents, emergency) with Confirm and Cancel.

### 6.7 Badge
- Red dot or count (max "99+") on tiles, tab items, list rows.
