# Rebrand Guide — the same app under a different name

There are two ways to ship this app under a new name:

- **Path A — a new flavour (white-label) in this project.** This is the fastest. It uses the same code and backend, with a new name, icon, colours and bundle id. The project already does this for three schools.
- **Path B — a new app built from scratch** against the same backend contract, or against your own backend that follows `BACKEND_API_REFERENCE.md`.

---

## Path A — add a flavour

### A1. How flavours work today

| Piece | Location | What it holds |
|---|---|---|
| Source of truth | `Scripts/flavours.json` | `id`, `targetName`, `bundleId`, `displayName`, `strings` (welcome text, terms URL, bug-report greeting, `School_Id`, `APP_STORE_ID`) |
| Generated config | `Flavours/<ID>/<ID>.xcconfig` | `FLAVOUR_ID`, `PRODUCT_BUNDLE_IDENTIFIER`, `APP_DISPLAY_NAME` (auto-generated — edit the JSON instead) |
| Per-flavour assets | `Flavours/<ID>/Assets.xcassets` | `AppIcon`, `AppColorsFolder` (brand colours), `SplachScreen`, `ClassTimeTable` images |
| Firebase | `Flavours/<ID>/GoogleService-Info.plist` | Push/analytics for that bundle id |
| Strings | `Flavours/<ID>/Localizable.strings` | Generated from `strings`; the app reads `School_Id`, `TERMS_URL`, etc. via `NSLocalizedString` |
| Defaults | `BaseConfig/Base.xcconfig` | Version numbers, default product name/bundle id, Google reversed client id |
| Generator | `Scripts/setup_flavours.swift` | Runs `generate_flavours` → `generate_xcconfigs` → `generate_flavour_strings` → `sync_selected_assets` |

Existing flavours:

| Flavour | School_Id |
|---|---|
| Sri Sudha Dhone | 6053 |
| Sri Kalaivani Vidhyalaya | 6748 |
| Wisdom Group | 7645 |

Note: for Wisdom Group, the generated xcconfig shows the display name "Wisdom Smart Connect", while the JSON says "WISDOM GROUP". Keep the JSON and the xcconfig in sync.

### A2. Steps

1. **Pick the identity:**
   - flavour id (uppercase, no spaces)
   - target name
   - bundle id, for example `com.yourbrand.app`
   - display name.
2. **Ask the backend team for the `School_Id`** of the school or group. A generic multi-school app leaves it empty, like the main School Chimes target.
3. **Add an entry to `Scripts/flavours.json`:**
   ```json
   {
     "id": "YOURBRAND",
     "targetName": "Your Brand",
     "bundleId": "com.yourbrand.app",
     "displayName": "Your Brand",
     "strings": {
       "WELCOME_STRING": "WELCOME TO YOUR BRAND",
       "TERMS_URL": "https://<your-terms-page>?id=<School_Id>",
       "REPORT_BUG_STRING": "Dear Your Brand Team",
       "Empowering": "Dear Your Brand Team",
       "School_Id": "<School_Id>",
       "APP_STORE_ID": "<filled after App Store Connect record is created>"
     }
   }
   ```
4. **Run the generator** from the project root: `swift Scripts/setup_flavours.swift`. This creates `Flavours/YOURBRAND/` and the Xcode target.
5. **Replace the assets in `Flavours/YOURBRAND/Assets.xcassets`:**
   - App icon (1024 px master plus generated sizes)
   - Brand colours in `AppColorsFolder`. Check text contrast is at least 4.5:1. See `docs/ui-ux-redesign/DESIGN_SYSTEM_SPECIFICATION.md`; the current Wisdom colour fails.
   - Splash and launch images.
6. **Firebase:**
   - Create an iOS app in Firebase with the new bundle id.
   - Put its `GoogleService-Info.plist` in `Flavours/YOURBRAND/`.
   - Upload an APNs key so FCM can deliver pushes.
   - Give the backend the FCM server credentials for this app.
7. **Apple Developer:**
   - App ID with Push Notifications (and Associated Domains if used).
   - Provisioning profiles.
   - New App Store Connect record. Then put its id in `APP_STORE_ID`, which the force-update screen uses.
8. **Google sign-in / Maps keys.** If you use separate keys, update `GOOGLE_REVERSED_CLIENT_ID` and the URL scheme for the new target.
9. **Backend registration for the new app:**
   - version-check policy for the new app
   - terms and privacy URLs in global-variables
   - push credentials
   - the login allow-list for the `School_Id`.
10. **Build and test with the checklist below.** Then submit.

---

## Path B — new app on the same contract

Use this path for a new codebase (for example SwiftUI, Flutter or React Native) or a new backend.

1. **Product scope.** Use `APP_WORKFLOW.md` as the functional spec, and pick which menu ids to launch with.
2. **Backend:**
   - **Reuse:** point the new app at the same hosts and keep request and response shapes exactly as in `BACKEND_API_REFERENCE.md` and `DATA_MODELS.md`.
   - **Rebuild:** follow `BACKEND_ARCHITECTURE.md`. Implement the "minimum backend" list first, keep the URL paths and the `{status, message, data[]}` envelope, and keep snake_case keys. Then a client built from these docs works unchanged.
3. **Client architecture.** Recommended layers:
   - **API client:** one generic request function with base/report host, token header and envelope decoding (the equivalent of `makeApi`).
   - **Session store:** stored credentials, all records, the current record, and the current token.
   - **Menu router:** a table from menu id to screen, with a "Coming soon" fallback and the management school-picker rule.
   - **Recipient picker** and **composer/uploader:** shared by all send flows.
   - **Push router:** payload → switch record → open the screen.
4. **Design.** Follow `docs/ui-ux-redesign/` (design system, components, page specs).
5. **Improvements to make while rebuilding** (all optional, contract-compatible):
   - Handle token expiry (401 → silent re-login → retry once) instead of re-logging in only at launch.
   - Remember the last chosen record instead of asking every launch.
   - Move Vimeo, Pauket and AWS secrets out of the app and behind your backend.
   - Fix the `comm/api//leave-req-for-staff/list` double slash.
   - Remove or implement the unused endpoints listed in the API reference.

---

## Secrets and identifiers — replace, never copy

The current app contains several third-party credentials. **Do not copy any of these into a new app:**

- AWS keys
- Vimeo access token
- Pauket partner key
- Google API keys and client ids
- Firebase config.

For each one:

- Create new credentials for the new brand.
- Keep server-side keys on the server, and have the app call your backend for presigned or proxied access.

These docs list where such keys are used, but not their values.

---

## Test checklist for a rebranded build

- [ ] Fresh install → onboarding → country → mobile → OTP → create password → home
- [ ] Returning launch with biometric on and off
- [ ] Number with staff and parent records → role picker → switch login
- [ ] Management (p1/p2/p4) with several schools → school picker appears on school-scoped menus
- [ ] Each launched menu id opens the right screen; unknown id → "Coming soon"
- [ ] Send with an attachment (image, PDF, video) → received by a parent account with push
- [ ] Push tap for a different child/school switches record and opens the item
- [ ] Force-update and optional-update responses from version-check
- [ ] Blocked child (`is_not_allow`) shows the server message
- [ ] Logout clears local data and the device token
- [ ] App name, icon, splash, colours, terms/privacy links, support numbers and App Store link all show the new brand
