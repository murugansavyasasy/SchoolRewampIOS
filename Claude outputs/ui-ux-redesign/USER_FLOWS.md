# User Flows — current and proposed

> Documentation only. "Current" steps are traced from the source code. "Proposed" steps are recommendations that keep the same APIs and rules.

Notation: **U** = user action, **S** = system response, **E** = error scenario.

---

## F1. First login (new device)

**Current**
1. S: Splash animation → onboarding pages → country list.
2. U: Choose country. S: stores API hosts.
3. S: Version check → `MobileNumberVc`.
4. U: Enter mobile, accept terms, Continue. S: `validate-user` (no password).
5. S: OTP sent → `OTPVc`; or password exists → `PasswordVc`.
6. U: Enter OTP / password. S: `validate-otp` or `validate-user` with password.
7. S: No password yet → `CreatePasswordVc` → save.
8. S: One record → dashboard; several → `PriorityVC`.
- E: wrong length → alert "Enter a valid Mobile Number". Unknown number → alert with server message. Network failure on password/OTP screens → nothing shown (only logged).

**Proposed**
1. S: Short splash → onboarding (skippable) → country pre-selected from device region (U can change).
2. U: Enter mobile (formatted), accept terms inline. S: same `validate-user`.
3. S: Same server branch, but in one flow with a progress indicator: OTP **or** password **or** create password.
4. S: Account switcher shown once if several records; choice remembered.
5. S: Home.
- E: inline field errors; network errors show a banner with Retry; OTP resend timer visible; "Didn't get the code?" help.

## F2. Returning user (every launch)

**Current:** Splash → biometric (if enabled) → version check → silent `validate-user` with stored credentials → `PriorityVC` every time for multi-record accounts → dashboard.
**Proposed:** Splash → biometric → version check → silent login → **last used account opens directly** → Home. Switch from the header chip.
- E (both): stored login rejected → login screen with message "Please sign in again" (proposed copy).

## F3. Switch school / child / role

**Current:** Side menu → Switch Login → `PriorityVC` (tabs Staff/Parent; tap school or child; management uses Next) → `TapBarVC` reloads.
**Proposed:** Tap header chip → switcher sheet → tap record → Home reloads with a toast "Switched to Class V-B".
- E: blocked child (`is_not_allow`) → row disabled with server message (current: blocking alert).

## F4. Staff sends a voice call or text to parents (Communication, ID 7)

**Current**
1. U: Home → Communication tile. S: (management, several schools) school list first.
2. U: Choose text or voice; record/type. S: limits from login data.
3. U: Select recipients in `RecipientVc` (types depend on role).
4. U: Send now / schedule (management). S: API call; alert on result.
- E: limit exceeded → alert; upload failure → alert.

**Proposed**
1. U: Home → Communicate → Message. S: active school shown in header (change from chip).
2. U: Text | Voice segment; counter/timer against the same limits.
3. U: "To:" row → recipient sheet (same allowed types) → summary "64 parents in V-B, VI-A".
4. U: Send → confirmation sheet for voice calls/emergency/entire school → Confirm.
5. S: progress in button → toast "Call scheduled for 4:00 PM" → item at top of Sent.
- E: inline limit warnings before send; failed upload keeps draft with Retry.

## F5. Teacher marks attendance (ID 3)

**Current:** tile → (school list for management) → choose class/section/date → tap each student status → preview of absentees with the note that parents get an automatic call → confirm → alert.
**Proposed:** tile → class/date prefilled with the teacher's class and today → all students default Present → tap to mark Absent/OD → sticky counts → Submit → absent preview sheet (kept) → Confirm → toast + summary.
- E: already marked today → show existing marks for edit (only if the API supports edit — **not verified**); network error keeps selections.

## F6. Teacher posts homework (ID 15)

**Current:** tile → composer with text/attachments → recipients → send → alert.
**Proposed:** tile → composer (T5) with attachment grid and upload progress → To: sections → Send → toast → list with new item.
- E: more than 2 videos → inline message at the picker; upload failure → per-file retry.

## F7. Staff views a student's fees (ID 35)

**Current (recent change):** tile → (school list for management) → student list (search, filters) → tap student → Student Fee Details (summary + categories, expandable payments/breakdowns).
**Proposed:** same flow; student list gains class filter chips; fee details keep the current layout with design-system tokens.
- E: no fee data → empty state "No fee details for this academic year"; API failure → banner with Retry.

## F8. Parent checks today's information

**Current:** login → (child picker if several) → dashboard grid → open each module separately (messages, homework, attendance).
**Proposed:** Home shows Today panel for the active child (unread messages; future: homework, attendance, bus ETA, fee due) → tap a card to open the module.

## F9. Parent uploads fee payment proof (ID 12)

**Current:** Fees tile → web view → Payment proof button → proof list (filters) → detail.
**Proposed:** Fees tile → native summary (if API supports) → "Upload payment proof" → choose image(s), enter amount → submit → proof appears as Pending with AI reading when available.
- E: invalid image → shown after AI reading as "Not a valid payment image" (existing data) with Replace action.

## F10. Parent tracks the bus (ID 205)

**Current:** tile → bus list → map screen (own tracker) or Dhundhoo tracker depending on `gps_type`.
**Proposed:** tile → if one bus, open map directly → bottom sheet with ETA, next stop, last updated, call driver.
- E: no live location → "Bus location not available right now" with last known time.

## F11. Opening a push notification

**Current:** tap → `AppDelegate` matches school + staff/child IDs → saves that record → presents `TapBarVC` → opens the module.
**Proposed:** same matching; if the record differs from the current one, show a toast "Switched to {child/school}"; module opens pushed on Home's stack (back returns to Home).
- E: record not found on device → open Home with message "This notification is for another account".

## F12. Logout

**Current:** side menu or Settings → confirmation → `auth/logout` → login screen.
**Proposed:** Profile → Log out → system alert → same API → login screen (mobile prefilled).
- E: logout API fails → still allow local sign-out with explanation (recommendation; confirm with backend).

## F13. Error and offline scenarios (all flows)

| Scenario | Current | Proposed |
| --- | --- | --- |
| Offline | `NetworkMonitor` returns "No internet connection" as an alert | Offline banner at top; cached content stays visible; actions disabled with reason |
| Expired session (token rejected) | Not detected; empty screens or decode errors | Detect (needs status-code handling) → "Session expired" → silent re-login → retry once |
| Slow server | Full-screen loader for up to 10 s, then hidden | Skeleton/inline spinner until result; cancel by leaving screen |
| Server message on failure | Alert with raw message | Inline banner with friendly copy; raw text in logs |
