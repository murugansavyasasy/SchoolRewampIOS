# Implementation Guidelines — for a future designer, developer or AI coding agent

> This file explains **how** to deliver the redesign later. It contains no UI code and nothing in it has been implemented. Read every document in this folder before starting.

## 1. Non-negotiables (preserve existing functionality)

1. **No API, model or business-rule changes.** Keep every endpoint, parameter, menu ID mapping, priority-code rule and limit exactly as documented in `FEATURE_INVENTORY.md`.
2. **Server-driven menus stay authoritative.** Grouping and Today panels are presentation only; a tile shows only when the server sends its ID.
3. **Account model stays.** One active staff or child record at a time, each with its own token; management multi-school behaviour (school picker, multi-school send) is kept.
4. **High-impact confirmations stay.** Absent-call warning, voice-call/emergency confirmations, forced update, logout confirmation.
5. **White-label parity.** Every change must work for all four flavours (School Chimes, Sri Sudha Dhone, Sri Kalaivani Vidhyalaya, Wisdom Group) using brand tokens.
6. **Localisation.** All visible text goes through the existing translation lookup; five languages must still work.
7. **Push deep links** must keep switching to the correct record and opening the same module.

## 2. Recommended delivery phases

| Phase | Scope | Exit criteria |
| --- | --- | --- |
| 0. Foundations | Colour assets for tokens (per flavour), text styles, spacing/radius constants, status palette; decision on iPad and dark mode | Tokens available to XIBs and code; no screen changed yet |
| 1. Shell | Tab bar (Home, Inbox, Calendar, Profile), navigation stack per tab, header with context chip, account switcher, removal of side menu | All modules still reachable; push deep links verified |
| 2. Core components | Buttons, fields, chips, list card, status chip, empty/error/loading states, toast, confirmation sheet | Component checklist (below) passes |
| 3. Auth flow | T1 screens (splash, onboarding, country, login, OTP, create password) | All server branches tested (OTP, password, create password, forgot password, blocked number) |
| 4. Home | Grouped tiles, Today panel, badges | Server menu lists of different roles render correctly |
| 5. High-traffic modules | Communication, attendance, homework, parent inbox, parent homework, fees, student report | Feature checklists pass |
| 6. Remaining modules | By template (T3–T9), module by module | Each module signed off |
| 7. Accessibility & polish | VoiceOver, Dynamic Type, RTL, iPad (if kept) | Checklist in `RESPONSIVE_AND_ACCESSIBILITY_REQUIREMENTS.md` |

Ship behind small, reviewable changes: one module or component per change set.

## 3. How to work within this codebase

- **UI technology:** the project uses XIBs (465) with view controllers. Keep that approach for redesigned screens unless the team decides otherwise; a mixed approach is acceptable only with a written decision.
- **Navigation migration:** replace full-screen `present` with pushes inside the tab's navigation stack module by module. Keep `MenuRedirectHandler` as the single place that maps menu IDs to screens; change only how it shows them.
- **Styling:** remove per-screen hex colours, fonts and radii as each screen is touched; use tokens only. Do not mass-replace across the project in one change.
- **Feedback:** replace the full-screen loader and routine alerts with the components in `COMPONENT_SPECIFICATION.md` §6, screen by screen.
- **Dead code:** `SplashViewController`, `ParentVC's/` duplicates, `SideMenuVC` (after phase 1) and `StudentReportDashboardVC` are not to be redesigned; remove only in separate, reviewed changes.
- **Data:** never re-format server amounts or dates unless the module already does.

## 4. Verification for every screen

| Check | How |
| --- | --- |
| Functional parity | Same API calls with the same parameters (compare network logs before/after) |
| Roles | Test as teaching staff, management with several schools, non-teaching staff, parent with several children, staff + parent |
| Flavours | Run all four schemes |
| States | Loading, empty, error, offline, success, long text, many items |
| Accessibility | VoiceOver pass, largest Dynamic Type, RTL Arabic |
| Devices | Smallest supported iPhone, largest iPhone, iPad (if kept) |
| Push | Open a notification for another school/child |

## 5. Component checklist (definition of done)

- [ ] Uses tokens only (no raw colours, fonts, radii)
- [ ] All states implemented (default, pressed, disabled, loading, error, selected where relevant)
- [ ] VoiceOver label, traits and value
- [ ] Dynamic Type to Accessibility XL without clipping
- [ ] RTL mirrored correctly
- [ ] Works on 320 pt width
- [ ] Documented in the team's component catalogue

## 6. Risks and mitigations

| Risk | Mitigation |
| --- | --- |
| Breaking hidden role-specific behaviour | Use the role matrix in `FEATURE_INVENTORY.md`; test every role per module |
| Push deep links break with new navigation | Phase 1 exit criteria include deep-link tests |
| Brand colour regressions in white-label apps | Flavour screenshots in every review |
| Scope creep into new features | Anything needing new API data is listed as a "future option" and needs separate approval |
| Large XIB diffs hard to review | One screen per change; include before/after screenshots |

## 7. Open questions to resolve before implementation

1. Keep iPad support (and design regular-width layouts) or drop it?
2. Add dark mode, or keep Light only (existing)?
3. Keep Poppins for headings, or move fully to the system font?
4. Can the parent fee web view be replaced by native screens (does the parent API return the same data as `student-fee-details`)?
5. Which Today-panel items can be supported by existing APIs, and which need backend work?
6. Should the last selected account be remembered between launches (currently re-chosen every launch)?
