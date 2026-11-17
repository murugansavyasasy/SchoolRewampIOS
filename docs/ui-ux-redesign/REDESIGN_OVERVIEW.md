# Redesign Overview — School Chimes iOS

> Documentation only. Everything in this file is a **recommendation** for a future redesign unless it is explicitly labelled "existing". Nothing here has been implemented.

## 1. Goals

1. **Faster daily tasks.** A teacher should send a message, mark attendance or post homework in under 30 seconds from launch; a parent should see today's messages and homework on the first screen.
2. **Always know the context.** The active role, school and child are visible on every screen and switchable in one tap.
3. **One consistent app.** A single design system across ~200 screens and four white-label brands.
4. **Accessible by default.** VoiceOver, Dynamic Type, AA contrast and right-to-left Arabic.
5. **No business logic change.** Same APIs, same menu IDs, same rules, same permissions.

## 2. Design principles

| Principle | In practice |
| --- | --- |
| Context first | Header shows who and where (name · school/child); every action applies to that context. |
| Content over chrome | Compact headers, no decorative blocks above content, brand colour used as accent. |
| Native iOS behaviour | Navigation stack with swipe-back, sheets for short tasks, system controls where possible. |
| Progressive disclosure | Summaries first (counts, totals, status), details on tap. |
| Clear status | One status vocabulary and colour set (Pending, Approved, Rejected, Paid, Partially paid, Absent, Present, Sent, Scheduled, Failed). |
| Forgiving input | Inline validation, drafts, undo where the backend allows, confirmation only for high-impact sends. |
| Brand-flexible | All brand colour comes from tokens per flavour; layouts never assume a hue. |

## 3. Design direction

### 3.1 Visual style (recommendation)
Clean, light, card-based iOS style: neutral backgrounds, white cards, one brand accent per flavour, SF Symbols iconography, generous whitespace, subtle shadows only on floating elements. Friendly but not playful: celebrations (birthday, quiz complete) keep their animations, everyday screens stay calm.

### 3.2 Colour (recommendation, see design system for tokens)
- **Brand accent** per flavour (existing values kept: `#377CF4`, `#F62B37`, `#7F1A37`, `#6BB557`).
- **Brand strong** shade per flavour for text, buttons and headers so white text passes 4.5:1: School Chimes `#1F5FD1` (5.81:1), Sri Sudha Dhone `#C81E29` (5.72:1), Sri Kalaivani `#7F1A37` (9.97:1, unchanged), Wisdom `#3D7A32` (5.21:1).
- **Neutrals:** slate scale (`#0F172A` … `#F8FAFC`) — the current XIBs already use `#64748B` and `#0F172A` most often.
- **Semantic:** success green, warning amber, danger red, info blue — fixed across flavours.

### 3.3 Typography (recommendation)
SF Pro (system) for all UI text through iOS text styles so Dynamic Type works. Poppins optional for the app name and large display headings only (existing brand font). One scale: Large Title 34, Title 1 28, Title 2 22, Title 3 20, Headline 17 semibold, Body 17, Callout 16, Subheadline 15, Footnote 13, Caption 12.

### 3.4 Spacing, layout, shape
4-pt grid (4, 8, 12, 16, 20, 24, 32, 40). Screen margins 16 pt (iPhone), 20–24 pt (iPad). Corner radius: 8 (inputs, chips), 12 (cards), 16 (sheets), full (pills, avatars). Minimum touch target 44 × 44 pt.

### 3.5 Iconography
SF Symbols for all UI icons (the app already uses 198 symbols in XIBs). Custom illustrations only for empty states, in one style. Menu tiles: symbol on a tinted rounded square.

### 3.6 Accessibility (summary)
WCAG 2.1 AA contrast, VoiceOver labels on every control, Dynamic Type up to Accessibility XL without clipping, Reduce Motion respected, RTL for Arabic. Details in `RESPONSIVE_AND_ACCESSIBILITY_REQUIREMENTS.md`.

## 4. Proposed information architecture

### 4.1 Tab bar (both sides)

| Tab | Staff | Parent |
| --- | --- | --- |
| Home | Today summary + grouped feature grid | Today summary for the active child + grouped feature grid |
| Inbox | Message from management, chat, notifications | Messages, voice, notices, homework alerts, notifications |
| Calendar | Holidays, events, PTM, exam schedule | Holidays, events, PTM bookings, exams |
| Profile | Profile, account switcher, language, password, biometric, help, logout | Same |

Existing tabs Home, Holidays, Settings, Profile map onto Home, Calendar and Profile; the side menu is removed (its items move to Profile and to the header switcher).

### 4.2 Header (every screen)
Back button (when pushed) · title · context chip (avatar + "Arun · Class V-B" or "Principal · Sri Sudha Dhone") opening the **account switcher sheet**.

### 4.3 Home grouping (client-side map of server menu IDs)

| Group | Staff menu IDs | Parent menu IDs |
| --- | --- | --- |
| Communicate | 7, 22, 17, 23, 39, 9/29 | 7, 23, 39, 16, 9 |
| Academics | 15, 2, 19, 20, 27, 206, 41 | 15, 2, 20, 27, 206, 10, 6 |
| Attendance | 3, 1, 21, 33, 202 | 4, 202 |
| Requests | 18/28, 203, 204, 207, 5/26 | leave, 207, 5, 26 |
| Reports and fees | 35, 14, 8, 31 | 12 |
| Transport and more | 205, 24, 30, 36, 40 | 205, 24, 25, 30, 36, 40 |

Server order and visibility stay authoritative: a tile appears only if the server sends it; unknown IDs go to "More".

### 4.4 Today panel (top of Home)
- **Staff:** attendance not yet marked today, unread management messages, pending leave approvals, scheduled sends.
- **Parent:** today's homework, unread messages, attendance today, next bus ETA (if enabled), fee due.

All counts come from APIs already called (`menu-counts`, dashboard menus) or existing module lists. Anything that would need a new API is marked as a future option.

## 5. Scope

| In scope | Out of scope |
| --- | --- |
| Visual design, layout, navigation, components, states, accessibility, responsive rules for every existing screen | New features, API or database changes, business rule changes, backend-driven content changes |

## 6. Deliverables in this folder

| File | Content |
| --- | --- |
| `PROJECT_ANALYSIS.md` | Project, stack, structure, constraints |
| `FEATURE_INVENTORY.md` | Every feature, rules, what to preserve |
| `UI_UX_AUDIT.md` | Problems, impact, recommendations |
| `REDESIGN_OVERVIEW.md` | This file |
| `PAGE_BY_PAGE_SPECIFICATION.md` | Screen templates, key screen specs, full screen list |
| `COMPONENT_SPECIFICATION.md` | Reusable components |
| `USER_FLOWS.md` | Current and proposed journeys |
| `DESIGN_SYSTEM_SPECIFICATION.md` | Tokens and states |
| `RESPONSIVE_AND_ACCESSIBILITY_REQUIREMENTS.md` | Devices, size classes, accessibility |
| `IMPLEMENTATION_GUIDELINES.md` | How to deliver it safely |
