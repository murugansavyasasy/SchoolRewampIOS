# Project Analysis — School Chimes iOS

> Part of the UI/UX redesign documentation set (`docs/ui-ux-redesign/`). Documentation only: nothing in the application was changed to produce it.
> Analysis date: 15 Oct 2026 · Branch analysed: `development` · Method: static reading of the Swift source, XIBs, storyboards, asset catalogs, Xcode project and git metadata.

## 1. What the product is

School Chimes is an iPhone app (also installable on iPad) that connects a school with its staff and with parents. One binary contains two experiences:

| Side | Users | Core jobs |
| --- | --- | --- |
| Staff | Group head, principal, admin, teaching staff, non-teaching staff | Send messages and voice calls, mark attendance, post homework/assignments/notices/events, enter marks, run reports, manage leave, hostel, bus and PTM |
| Parent | Parents/guardians (one login can hold several children) | Receive messages and voice calls, view homework, marks, attendance, timetable, fees; upload fee payment proof; track the bus; raise concerns; apply leave |

The same code is shipped as four App Store apps (white-label "flavours"): **School Chimes** (multi-school) plus three single-school brands — **Sri Sudha Dhone**, **Sri Kalaivani Vidhyalaya**, **Wisdom Group of Institutions**.

## 2. Technology and dependencies (verified)

| Area | Finding |
| --- | --- |
| Language / UI | Swift 5, UIKit. Layout in **XIBs (465)** and **3 storyboards**; some screens add views in code. No SwiftUI screens. |
| Size | ~556 Swift files, ~131k lines; **207 view controllers**, **~253 cell classes** (table + collection). |
| Minimum OS | iOS 16.0 for app targets. |
| Devices | `TARGETED_DEVICE_FAMILY = 1,2` (iPhone **and iPad**). iPhone portrait only; iPad allows all orientations. |
| Appearance | `UIUserInterfaceStyle = Light` forced on all app targets (dark mode disabled). |
| Packages (SPM) | Firebase (Core, Messaging, Crashlytics), AWS S3/Core, Google Maps, MapLibre, Kingfisher, SDWebImage, Lottie, DGCharts, FSCalendar, MarqueeLabel. Bundled DropDown library source. |
| Fonts | Poppins (Medium, Bold, SemiBold registered; Regular file present but not registered), RobotoSlab files present but unused. System font in XIBs; Poppins applied in code via `setFont(style:)` (457 calls). |
| Localisation | `.lproj` for English, Arabic, Hindi, Tamil, Thai; runtime switch through `String.translated()`; `UIApplicationSupportsRightToLeft = false`. |

## 3. Code structure

| Folder | Role |
| --- | --- |
| `App/` | `AppDelegate` (Firebase, push handling), `SceneDelegate` (language sync, temp-file cleanup). |
| `Core/ApiService/` | `APIService` (single HTTP client), `AppConstant` (endpoint paths, menu IDs, priority codes), request keys, all response models (`Model.swift`, ~4k lines). |
| `Core/AWS/` | S3 uploads through presigned URLs; downloads. |
| `Core/ExtenstionsFiles/` | UI extensions, `MenuRedirectHandler` (menu ID → screen), photo picker, network monitor, Vimeo upload, toast, loader, colours. |
| `Core/UserDefaultFiles/` | `UserDefaultFileManager` — credentials, login response, active staff/child record, country, settings. |
| `Features/Auth/` | Splash, onboarding, country, mobile, password, OTP, create password, role picker, biometric, force update, terms. |
| `Features/SchoolDashBoard/` | Staff home, side menu, tab bar, settings, profile, notifications and ~38 staff modules (148 view controllers). |
| `Features/ParentDashBoard/` | Parent home and ~28 parent modules (92 view controllers). |
| `Features/CommonScreens/` | Recipient picker, school picker, image/video viewers, date picker, popups, birthday, what's new. |
| `ParentVC's/` | Older duplicates of some parent screens (exam marks, timetable, LSRW). |
| `Flavours/`, `Scripts/`, `BaseConfig/` | White-label configuration and generator scripts. |
| `Resource/` | Fonts, Lottie/GIF animations, confetti and fireworks effects. |

**Architecture pattern:** screen-centred MVC. View controllers call `APIService` directly and hold their own state; only the newer Class Test and fee modules use view models. Navigation is almost entirely **modal**: 536 `present` calls versus 2 `pushViewController`, with 282 explicit full-screen presentations.

## 4. Navigation model (as built)

1. `SplashVC` (storyboard entry) → onboarding / country → version check → auto-login or login screens.
2. Role selection in `PriorityVC` when the account has more than one staff/child record, or is both staff and parent.
3. `TapBarVC`: a custom tab bar with **Home, Holidays, Settings, Profile**. Home is `CustomDashboard` (staff) or `CustomParentDashboardVC` (parent).
4. Home shows a grid of **server-provided menu tiles** and a "frequently used" carousel. Each tile ID is mapped in code to a module's first screen, which is presented full-screen.
5. A **side menu** (`SideMenuVC`) repeats Profile and Settings and adds Switch Login and Logout.
6. Push notifications open `TapBarVC` and jump straight to the related module, switching the active school/child record when needed.

## 5. Authentication, roles and session (summary)

- One API, `app/api/auth/validate-user`, checks the mobile number and password, triggers OTP, and returns every **staff record** (one per school) and **child record** (one per child), each with its own access token.
- The app stores the mobile number and password and replays this call on every launch (no refresh token or expiry handling).
- Priority codes `p1` group head, `p2` principal, `p3` teaching staff, `p4` admin, `p5` non-teaching are used only to split management (`p1/p2/p4`) from class staff (`p3`).
- Detailed trace: see the separate "Login, Role & Permission Flow Analysis" and "Project Documentation" docs prepared earlier.

## 6. Data and backend dependencies

| Dependency | Use |
| --- | --- |
| School Chimes API (India: `apiv8.schoolchimes.net`, `reportv8.schoolchimes.net`; other countries use other hosts) | All features. Path groups: `app`, `dashboard`, `comm`, `lms`, `exam`, `ptm`, `stud-attd`, `staff-attd`, `admin`, `fee`, `transport`, `ocr`. |
| AWS S3 | Images, audio, documents (presigned upload). |
| Vimeo | Video upload and playback. |
| Firebase | Push notifications, crash reporting. |
| Pauket | Reward points and coupons. |
| Maps | Google Maps, MapLibre tiles, OSRM routing for bus tracking; third-party "Dhundhoo" tracker for some schools. |

The database is not part of this repository; no schema was available for review.

## 7. Facts that constrain a redesign

1. **Menus are server-driven.** Names, order and visibility come from `dashboard/api/dashboard/menus`; the client only maps numeric IDs to screens. A new home layout must render any server list, not a fixed set.
2. **White-label theming.** Brand colour, logo, app icon and some strings change per flavour through asset catalogs (`BackGroundClr`, `PrimeryColor`, `ParentClr`, `MenuClr`, `AttendenceColor`). Brand colours today: School Chimes `#377CF4`, Sri Sudha Dhone `#F62B37`, Sri Kalaivani `#7F1A37`, Wisdom `#6BB557`.
3. **Role-dependent screens.** The same screen changes content for management vs class staff (recipient types, scheduling, history views).
4. **Multi-record accounts.** One person may switch between schools and children; every screen works on the active record.
5. **Localisation.** Five languages, including Arabic; strings are looked up at runtime.
6. **XIB-based UI.** 465 XIBs; any redesign plan must work screen by screen inside this structure (or plan a deliberate migration).

## 8. What was and was not verified

| Verified from source | Not verified |
| --- | --- |
| Screens, navigation calls, menu ID mapping, API paths, models, fonts/colours/sizes in XIBs, build settings, assets | Live behaviour on a device, real server responses for most modules, backend/database rules, analytics, any design files (none in repo), user research |

No screenshots exist in the repository; visual findings come from XIB attributes and code, not from rendered screens.
