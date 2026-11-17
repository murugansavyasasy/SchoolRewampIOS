# App Workflow

The School Chimes app works end to end as described below, traced from the iOS source. Use it as the functional spec for building the same product under a new name. Endpoint paths are listed in full in `BACKEND_API_REFERENCE.md`, and field shapes in `DATA_MODELS.md`.

---

## 1. Product in one paragraph

This is a school communication and management app with **two kinds of users on one login**:

- **Staff** — teachers, principals, admins, group heads and non-teaching staff. Staff send content (voice calls, texts, homework, notices, events, assignments), take attendance, enter marks and view reports.
- **Parents** — parents receive that content for each child, pay or check fees, book PTMs, track the bus and raise concerns.

One mobile number can be staff at one or more schools **and** a parent of one or more children. The server returns every "record" (staff-at-school or child) with its own access token, and the user picks which one to act as.

---

## 2. Roles and priority levels

| Code | Role | Constant | What changes |
|---|---|---|---|
| `p1` | Group head | `PriorityType.is_grouphead` | Management. Sees all schools in the group; school picker before school-scoped menus |
| `p2` | Principal | `is_principal` | Management. Same as p1 for multi-school; full reports |
| `p3` | Teaching staff | `is_staff` | Class-scoped sending, attendance and marks |
| `p4` | Admin | `is_admin` | Management. Same picker behaviour as p1/p2 |
| `p5` | Non-teaching staff | `is_non_teaching_staff` | Limited menus (server decides) |
| — | Parent | `login_astype = 2` | Receiver menus for the selected child |

- **The server decides the menus.** The app never hard-codes which role sees which menu. It asks `dashboard/menus` with the record's token, then maps each returned menu `id` to a screen (section 6).
- **Multi-school rule (management only).** If the user is p1, p2 or p4 **and** has more than one staff record, then tapping a school-scoped menu first opens `SchoolListVC` to choose the school. Teachers (p3) and p5 go straight to the screen.

---

## 3. Launch → login → home

```
App start
 └─ SplashVC (animation)
     ├─ first install → Onboarding pages (dashboard/features) → CountryListVC (app/api/setup/countries)
     │                   └─ store country: base_url, reporting_url, country_id
     └─ returning user
          ├─ Biometric (Face ID / Touch ID) if enabled in Settings
          └─ version-check (report host: device_type, version_code, country_id, mobile, school_id*)
               ├─ force update → ForceUpdatePopup (blocks) / optional update → dismissible
               └─ silent validate-user with stored mobile + password + secure_id
                    └─ records → (1 record) TapBarVC  |  (many) PriorityVC → TapBarVC
```

`*school_id` is the white-label school id from the flavour (`School_Id` string). It is empty for the generic app.

### 3.1 First login

1. **MobileNumberVc.** The user enters a mobile number and accepts the terms, then the app calls `validate-user` with no password.
2. **The server branches on `data[0]`:**
   - `is_number_exists = false` → the app shows `message` and `dial_numbers` (support contacts).
   - `otp_sent = true` → **OTPVc**, then `validate-otp` (mobile, otp).
   - The number exists and `is_password_updated = true` → **PasswordVc**, then `validate-user` with password.
   - No password set yet → after OTP comes **CreatePasswordVc**, which calls `cred/create-new-password`.
3. **Forgot password.** `cred/forgot-password` sends an OTP, then `validate-otp`, then `cred/reset-password`.
4. **Success.** The app stores the mobile, password and `secure_id` locally (the device UUID is generated once) and saves the `user_details`.
5. **Records:**
   - one staff **or** child record → home directly
   - several → **PriorityVC**, which has Staff and Parent tabs and lists each school or child; the user taps one.
6. **Home loads.** The app registers the push token with `auth/device-token` (FCM token plus device info), then loads `global-variables` (support numbers, privacy and terms URLs, `presigned_cred_base_url`, fees URL, marketplace URL).

### 3.2 Every later launch

There is no refresh-token flow. **The app replays `validate-user` with the stored credentials on each launch**, which returns fresh per-record tokens. If that call fails (password changed, number removed), the user goes back to login.

### 3.3 Switch account / logout

- **Switch.** Side menu → *Switch login* → PriorityVC → TapBarVC reloads with the new record's token.
- **Logout.** Side menu or Settings → confirm → `auth/logout` (mobile, device_type, secure_id) → local data cleared → login screen.

### 3.4 Blocked child

`ChildDetails.is_not_allow = true` (for example, fees unpaid) blocks entry and shows the server's `display_message`.

---

## 4. Home (TapBarVC)

`login_astype` is **1 for staff** and **2 for parents**. The tab bar shows Home, Notifications, Profile/Settings and the side menu.

### Home screen (`CustomDashboard` for staff, `CustomParentDashboardVC` for parents)

1. `dashboard/menus` (member_type, mobile_number, language_code) returns:
   - `menus[]` and `frequently_used[]`
   - `contact_details`, an optional alert banner with call numbers
   - `is_birthday`, which triggers `BirthdayVc`
2. `dashboard/menu-counts` refreshes the unread badges on each menu.
3. Tapping a menu card runs the menu-ID router (section 6).

### Notifications tab, side menu and Settings

- **Notifications tab:** `dashboard/notifications`, with delete via `delete-notification`.
- **Side menu and Settings:**
  - profile
  - switch login
  - biometric toggle
  - language
  - What's New (`new-updates`)
  - FAQ (`faqs`)
  - Rate us (`reviews/add`, `reviews/list`)
  - report a bug (mail)
  - privacy and terms (URLs from global-variables or the flavour `TERMS_URL`)
  - logout

---

## 5. Common building blocks used by many modules

### 5.1 Recipient picker (`RecipientVc`)

The picker is used when staff send anything. Its tabs are **Entire School · Standards · Section/Students · Groups · Staff**. Data comes from:

- `recipient/get-standards`
- `get-student-list`
- `get-group-list`
- `get-staff-list`
- `get-subject-list`
- `get-academic-year-list`

The selection becomes `target_type` plus `target_code`:

| target_type | Meaning | circular_type |
|---|---|---|
| 1 | Entire school | `A` |
| 2 | Standard(s) | `C` |
| 3 | Section(s) | `S` |
| 4 | Group(s) | `G` |
| 5 | Student(s) | `student` |
| 6 | Staff | `staff` |

### 5.2 Compose → upload → send

1. Staff compose the title, description and attachments. The limits are up to **10 images or documents** and **2 videos**. SMS counts and voice durations are limited by `max_*` in `user_details`.
2. **Files go to S3:**
   - The app calls `{presigned_cred_base_url}get-s3-presigned-url?bucket&fileName&bucketPath&fileType`.
   - It PUTs the file to the presigned URL.
   - It keeps the returned `fileUrl`.
   - The bucket path is `<module>/<school_id>/<date>`, where module is assignment, skills, events or marksheets.
3. **Videos go to Vimeo.** The app keeps the link and the `iframe`.
4. **Send.** The shared sender (`com_SendingAPI`) POSTs to the module's `send-*` endpoint, or PUTs to `update` when editing.
5. **Response.** The app shows `message` and pops back. For gamified actions the app also calls `dashboard/pauket/add-points`.

### 5.3 Lists, history and read status

- **Staff:** `*/report` (who read or submitted) and `*/target-details` (who it was sent to).
- **Parents:** `*/list`, plus an archive list for previous years, plus `read-status-update`.
- **Delete** is a soft delete via `PUT */delete`.

### 5.4 Push notifications

FCM delivers the payload with menu id, message id, school id and staff or child id. The app then:

1. finds the matching local record
2. switches to that record
3. opens TapBarVC
4. routes with the same menu-ID router, passing `PushNotiMsgId` so the detail screen opens directly.

---

## 6. Menu-ID router

The server returns menu ids, and the app maps them to screens. **Any id not in the tables shows "Coming Soon".**

### Staff (`CustomDashboard`)

A ✓ in the "School picker" column means the id is in `needSchoolCheck`, so management users with several schools pick a school first.

| ID | Module | School picker |
|---|---|---|
| 1 | Absentees report | ✓ |
| 2 | Assignments (send / report) | ✓ |
| 3 | Mark attendance | ✓ |
| 5, 26 | PTM (create slots, bookings) | ✓ |
| 7 | Communication — voice call / text | |
| 8 | Daily fee collection report | ✓ |
| 9, 29 | Events | ✓ (29) |
| 14 | Fee pending report | ✓ |
| 15 | Homework | ✓ |
| 17 | Chat / interaction with students | ✓ |
| 18 | Leave requests (approve student leave) | ✓ |
| 19 | Lesson plan | ✓ |
| 20 | LSRW skills | ✓ |
| 21 | Geo attendance (staff punch) | ✓ |
| 22 | Message from management | |
| 23 | Notice board (p1/p2/p4 send; others view) | |
| 24 | Online meeting | |
| 27 | Quiz (create / reports) | ✓ |
| 30 | School needs / marketplace (web) | |
| 31 | School strength | ✓ |
| 33 | Staff-wise geo attendance report | ✓ |
| 35 | Student report → student fee details | ✓ |
| 36 | Important info | |
| 39 | Attachments | |
| 40 | Pauket rewards | |
| 41 | Upload exam marks (manual + OCR photo) | ✓ |
| 202 | Hostel management / attendance | ✓ |
| 203 | Apply leave (staff's own) | ✓ |
| 204 | Staff leave requests (approve) | ✓ |
| 205 | Bus list / live tracking | ✓ |
| 206 | Class test (create) | ✓ |
| 207 | Parent concerns (view / act) | ✓ |

### Parent (`CustomParentDashboardVC`)

| ID | Module |
|---|---|
| 2 | Assignments (view / submit) |
| 4 | Attendance report |
| 5 | Certificate request |
| 6 | Class timetable |
| 7 | Communication inbox (voice / text) |
| 9 | Events / holidays |
| 10 | Exam marks / progress card |
| 12 | Fee details, invoices, online payment, payment proof |
| 15 | Homework |
| 16 | Ask teacher (chat) |
| 20 | LSRW skills (submit) |
| 23 | Notice board |
| 24 | Online meeting |
| 25, 30, 36 | Important info / e-books / marketplace (web) |
| 26 | PTM booking |
| 27 | Quiz (attempt) |
| 39 | Attachments |
| 40 | Pauket rewards |
| 202 | Hostel dashboard, outpass |
| 205 | Where is my bus |
| 206 | Class test results |
| 207 | Raise concern / my concerns |

---

## 7. Module flows

Endpoint prefixes are shortened below. For example, `comm/homework/…` means `comm/api/homework/…`.

### Communication — voice and text (ID 7)

- **Staff:**
  1. Record audio or type a text and pick recipients.
  2. Options: emergency, schedule (dates and time window).
  3. Send: `comm/voice/send-voice` or `comm/text-message/send-text`.
  4. History: `get-voice-history` / `get-text-history`.
  5. Management with several schools pick the school first.
- **Parent:**
  1. The inbox comes from `comm/communication/list` (plus `list-archive`).
  2. Playing or reading a message calls `read-status-update`.
  3. The voice call log is recorded with `voice/update-notification-call-log`.

### Homework (ID 15)

- **Staff:**
  1. Pick a class and subject.
  2. Enter text and attachments.
  3. Send with `homework/send-homework`.
  4. Use `update` and `delete` to change it, and `report` / `submissions-list` to track it.
- **Parent:**
  1. `homework/list` shows the homework.
  2. `mark-complete` marks it done.

### Assignments (ID 2)

- **Staff:**
  1. Send with `assignment/send-assignment` (with a due date and category).
  2. Track with `report`, `submissions-list` and `target-details`.
- **Parent:**
  1. `assignment/list` shows assignments.
  2. Submit files or text with `submit-assignment`, and change the submission with `update-submission` or `delete-submission`.
  3. `my-submissions` lists what was submitted.

### Notice board (ID 23) / Events (ID 9, 29) / Attachments (ID 39)

- **Notices:** management send with `admin/notice-board/send-notice` and view with `report`. Everyone reads with `get-notice`.
- **Events:**
  1. Load categories from `school-event/categories`.
  2. Send with `send-event` (venue, date, time).
  3. Read with `get-event` and holidays with `view-holidays`.
- **Attachments:** the same send / list / report pattern under `comm/attachment/*`.

### Message from management (ID 22)

Staff read messages with `comm/msg-from-management/get-messages-staff` (plus the archive endpoint).

### Student attendance (ID 3, 1, 4)

- **Mark attendance:**
  1. Pick a class and section.
  2. Load students with `stud-attd/attendance/student-list` (with `attendance_type` and `session_type`).
  3. Mark absentees.
  4. Submit with `send-absentees-sms-with-session-type`, which also texts the parents of absentees.
- **Absentees report:** `get-absentees-count-by-date` then `get-absentees-students-by-date`.
- **Parent:**
  - `student-stats` and `student-attendance-report`
  - absent dates from `get-absent-dates-for-child`.

### Hostel (ID 202)

- **Staff:**
  1. Find the hostel and room with `hostel-list`, `room-details` and `session-types`.
  2. Load students with `students-for-hostel-attd`.
  3. Submit with `mark-attendance`.
  4. View `attendance-report` and `outpass-report`, and approve outpasses with `update-status`.
- **Parent:**
  - `parent-dashboard-new` and `hostel-info`
  - apply for an outpass with `apply-outpass`.

### Staff geo attendance (ID 21, 33)

1. An admin sets the school geofence with `staff-attd/geometric/set-geometric-location` (and `update` / `remove`).
2. Staff punch in and out with `entry-using-app`, which sends the GPS position.
3. The punch is accepted only inside the fence.
4. Reports:
   - `geometric-staff-attendance-report`
   - `geometric-principal-attendance-report(-date-wise)`
   - `geometric-punch-history`.

### Leave

- **Student leave:**
  - The parent applies with `comm/leave-req/apply`, choosing categories from `leave-categories`.
  - The teacher approves or rejects with `update-status`.
- **Staff leave (ID 203, 204):**
  - Staff apply with `comm/leave-req-for-staff/apply`.
  - The approver uses `…/list` and `update-status`.

### Exams and marks (ID 41, 206, 10)

- **Class test (206):**
  - Staff create it with `exam-test/create-class-test` (subjects from `section-wise-subjects`).
  - Staff enter marks with `exam-test/upload-marks`.
  - Analysis: `analysis-sets-list` and `student-analysis`.
  - Parents view with `class-tests-for-student` and `view-marks-for-student`.
- **Term exams (41):**
  1. `new-exam/get-staffwise-exam`
  2. `get-marks-to-upload-details`
  3. `upload-exam-mark` (activities from `get-subject-activities`, remarks from `exam-new/common-remarks`).
  - **OCR:** photograph the mark sheet → `ocr/api/upload-marks` (multipart image) → marks are pre-filled.
- **Parent progress card:** `new-exam/get-exams`, then `get-mark-details` and `get-student-progresscard`.

### Fees (ID 12, 14, 8, 35)

- **Parent:**
  - `fee/fee-details/student-fee-details` (term-wise with `break_down` and `paid_details`)
  - `student-invoice` and `invoice-details`
  - an online payment opens the web `fees_url`
  - reconcile with `dashboard/reconcile/online-payment-details-for-student`
  - report a payment not received with `update-unreceived-payment-status-for-student`
  - the uploaded payment proof comes from `payment-proof`.
- **Staff reports:**
  - pending fees: `fee-report/detailed-pending-report` and `detailed-class-wise-pending-report` (14)
  - daily collection: `daily-collection` (8)
  - student report (35): `admin/get-student-report` → tap a student → `student-fee-details`.

### PTM (ID 26 / 5)

- **Staff:**
  1. Load subjects with `ptm-schedule/subject-list-with-class-teacher`.
  2. Check slots with `validate-slots-for-staff`.
  3. Create them with `create-slots`.
  4. View with `slot-details-for-staff` and `datewise-booked-slots`.
  5. Manage with `cancel-and-close-slot` or `cancel-and-reopen-slot`.
- **Parent:**
  1. Check availability with `available-slots-count-for-student` and `teacherwise-slots-availability-for-student`.
  2. Book with `book-slots-for-student`.
  3. View `slot-history-for-student` and cancel with `cancel-slot-by-student`.

### Learning

- **Lesson plan (19):**
  - `lms/lesson-plan/get-data-for-add`, then `add`, `update` and `delete`
  - `view` and `staff-report`.
- **LSRW skills (20):**
  - Staff create with `lsrw/create-skill`, then use `submission-list` and `remark`, and view `skills-report` and `stats`.
  - Parents submit with `submit-skill` (audio or video) and view `my-submissions`.
- **Quiz (27):**
  - Staff build a quiz with `quiz/create-quiz` and `add-question` (or `pick-from-qbank`), then view `report` and `questions-report`.
  - Students: `check-level`, `quiz-exam-list`, `get-questions` and `submit`.
- **Timetable (6):** `lms/time-table/get-schedule`.

### Interaction / chat (ID 17, 16)

- **Parent:**
  1. Find the staff with `interaction/staff-details-for-chat`.
  2. Ask with `student-ask-question`.
  3. Read replies with `get-staff-answers`.
- **Staff:**
  1. Load classes with `classes-for-chat` and questions with `staff-get-questions`.
  2. Reply with `staff-ans-question`.
  3. Block students with `block-student` and list them with `blocked-students`.

### Certificates (ID 5), concerns (ID 207), profiles

- **Certificates:** parents choose from `certificate/types`, send with `send-request`, and view `request-list`.
- **Concerns:**
  - Parents raise one with `admin/parent-concern/raise-concern` (types from `get-concern-types`).
  - Staff use `get-concerns` and `action-taken`.
- **Profiles:**
  - Students: `admin/student-profile/list`, `pre-submission` and `update-profile`.
  - Staff: `staff-profile/list`.
- **School strength (31):** `admin/get-school-strength`.

### Transport (ID 205)

1. List the routes with `transport/get-student-route-list`.
2. Track with `get-vehicle-live-tracking-details` and `get-latest-geo-location`, polled and shown on Google Maps or MapLibre.
3. If `gps_type == "dhundhoo"`, the app uses the third-party tracker view instead of its own.

### Pauket rewards (ID 40)

- Staff actions earn points via `dashboard/pauket/add-points`.
- The rewards screen calls the Pauket partner API directly:
  - `get_category_list`
  - `get_campaigns`
  - `get_campaign_details`
  - `activate_coupon`
  - `my_coupons`

---

## 8. Error and edge behaviour to replicate (or improve)

| Case | Current behaviour |
|---|---|
| No internet | `NetworkMonitor` alert "No internet connection" |
| `status:false` | `message` shown as an alert or toast |
| Token rejected mid-session | No special handling; the next launch re-validates |
| Force update | `version-check` blocks the app until it is updated |
| Unknown menu id | "Coming Soon" alert |
| Child blocked | `is_not_allow` plus `display_message` |
| Several schools (management) | School picker before school-scoped modules |
| Notification for another record | The app switches record automatically before opening |
