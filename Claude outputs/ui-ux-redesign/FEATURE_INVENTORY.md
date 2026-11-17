# Feature Inventory — School Chimes iOS

> Documentation only. Every feature below was found in the source code (screens, menu mapping in `CustomDashboard` / `CustomParentDashboardVC` / `MenuRedirectHandler`, endpoints in `AppConstant.swift`, messages in `AppStringFile.swift`). Where a rule could not be confirmed in the source it is marked **(not verified)**.
>
> **Menu ID** is the numeric ID the server sends with each dashboard tile. Tile **names come from the server**, so names below describe the feature, not the exact label users see.

## How to read each entry

| Field | Meaning |
| --- | --- |
| Users | Who reaches it. "Mgmt" = group head `p1`, principal `p2`, admin `p4`. "Staff" = all staff roles. |
| Behaviour | What it does today. |
| Screens | Main view controllers. |
| Data / API | Endpoint groups it calls. |
| Rules | Business rules visible in code. |
| Validation & errors | What the app checks and how it reports problems. |
| Preserve | What a redesign must keep. |
| Opportunity | Experience improvement that does not change business logic. |

---

## A. Authentication and account

### A1. Onboarding and country selection
- **Users:** everyone, first launch.
- **Behaviour:** carousel of intro pages (`OnboardingVC`), then country list (`CountryListVC`) that sets API hosts and mobile-number length.
- **Data / API:** `app/api/setup/countries`.
- **Rules:** country decides base URLs, phone length and hint text.
- **Validation & errors:** "Please Select Your Country".
- **Preserve:** country choice before login; stored hosts.
- **Opportunity:** pre-select the country from device region; make onboarding skippable.

### A2. Splash, version check, update prompt, rate-us
- **Users:** everyone, every launch.
- **Behaviour:** animated splash (stars, confetti, ripples, dots), optional biometric unlock, version check, optional or forced update popup (`ForceUpdateVc`), rate-us popover.
- **Data / API:** `app/api/setup/version-check` (sends version code, country, mobile, white-label school ID).
- **Rules:** forced update blocks the app; optional update can be dismissed.
- **Preserve:** forced-update blocking; biometric gate when enabled.
- **Opportunity:** shorten splash (animation runs before any network work); show a progress state instead.

### A3. Login (mobile → password / OTP)
- **Users:** everyone.
- **Behaviour:** two entry screens: `MobileNumberVc` (number only) on first login, `LoginVc` (number + password) after a logout. Server decides whether to ask for OTP (`OTPVc`) or password (`PasswordVc`). New users create a password (`CreatePasswordVc`).
- **Data / API:** `app/api/auth/validate-user`, `validate-otp`; `app/api/cred/forgot-password`, `reset-password`, `create-new-password`, `change-password`.
- **Rules:** number length must equal the country's `mobile_number_length`; terms must be accepted; auto-login on every launch with stored credentials.
- **Validation & errors:** "Enter a valid Mobile Number", "Invalid Password", "Please accept the Terms and Conditions to Proceed"; server `message` shown in an alert. Network failures on several login screens are silent **(verified: only printed)**.
- **Preserve:** the server-driven branch (OTP vs password vs create password); forgot-password via OTP; device `secure_id`.
- **Opportunity:** one adaptive login screen; inline errors; visible retry on network failure; OTP auto-fill; resend timer visible.

### A4. Role, school and child selection
- **Users:** accounts with more than one record, or staff who are also parents.
- **Behaviour:** `PriorityVC` with Staff/Parent tabs; teaching staff tap a school; management press **Next** (first school); parents tap a child. **Switch Login** in the side menu re-opens it.
- **Rules:** management works on the first school and picks a school per feature (`SchoolListVC`); `is_not_allow` blocks a child with a server message.
- **Validation & errors:** blocked child → non-dismissable alert.
- **Preserve:** per-record tokens; management multi-school behaviour; blocked-child rule.
- **Opportunity:** a persistent account switcher in the header showing the active school/child; remember the last choice; explain why a child is blocked with a next step.

### A5. Biometric lock
- **Behaviour:** optional Face ID / Touch ID before the app continues (`BiometricAuthentication`).
- **Preserve:** opt-in setting and gate.

### A6. Logout
- **Behaviour:** confirmation sheet (`LogoutViewController`) → `app/api/auth/logout` → login screen.
- **Preserve:** server logout call; flag that sends the next login to the password screen.

### A7. Profile, settings, help
- **Users:** everyone.
- **Behaviour:** profile view/edit with photo (`UpdateProfileVC`), settings (`SettingsViewController`: language, change password, biometric, rate us, report bug, contact, FAQ, help), language picker (`LanguageVc`).
- **Data / API:** `admin/api/staff-profile`, `admin/api/student-profile`.
- **Preserve:** language switch (5 languages); change password; contact/report bug.

---

## B. Staff features

| ID | Feature | Users | Behaviour (today) | Screens | Data / API | Rules & validation | Preserve | Opportunity |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 7 | Communication: text and voice messages, emergency/scheduled voice calls | Staff (scheduling, history, emergency = Mgmt) | Compose text or record voice, pick recipients, send now or schedule; history of sent messages | `ComunicationVC`, `RecipientVc`, `TextMessageVC`, `VoiceMessageVc`, `ScheduleCallVC` | `comm/api/text-message`, `comm/api/voice`, `comm/api/recipient` | Character and duration limits come from login data (`max_general_sms_count`, `max_*_voice_duration`); recipient types depend on role; multi-school send for Mgmt | Limits, recipient rules, scheduling, emergency flag | Single composer with clear text/voice switch; recipient summary before send; history as its own tab |
| 15 | Homework | Staff | Post homework (text, files, voice, video) to sections; report of who completed | `SenderSideHomeWorkViewController`, `SenderHomeWorkVC` | `comm/api/homework` | "Enter Homework Description"; attachment type checks; max 2 videos | Attachments, targets, report | Draft saving; attachment preview grid |
| 2 | Assignments | Staff | Create assignment with submission date; view submissions per student; report | `SenderAssignmentTextViewController`, `AssignmentReport`, `SubmitedAssignmentVC` | `comm/api/assignment` | Submission date required | Submission tracking | Status filters on submissions |
| 39 | Attachments (circulars/files) | Staff | Send images/PDF/video; history | `SenderAttachmentVC`, `AttachHistroyVC` | `comm/api/attachment` | "Please Add Any Attachment"; S3/Vimeo uploads with progress | Upload progress, file types | Clear upload progress per file; retry failed uploads |
| 23 | Notice board | Staff (history view for Mgmt) | Post notices with images; list | `SenderNoticeBoardVC`, `NoticeBoardVc` | `admin/api/notice-board` | Title + description required | Role-specific history | Unified list with "New notice" action |
| 9, 29 | Events | Staff | Create events with images; history | `EventsVC`, `EventHistoryVC` | `admin/api/school-event` | Event targets (no section/staff targets) | Target rules | Calendar view |
| 3 | Student attendance marking | Staff | Mark present/absent/OD for a section and date | `MarkAttendenceVC`, `AttendanceMarkingVC`, `absentPrivewVC` | `stud-attd/api/attendance` | **Absent students' parents receive an automatic call** (confirmation note shown) | Absent-call warning and confirmation step | Default-all-present with quick toggles; sticky summary counts |
| 1 | Absentees report | Staff | Absentee list by date/section | `NewAbsenteesViewController` | `stud-attd/api/attendance` | — | — | Export/share |
| 21 | Staff geo attendance (punch in/out) | Staff | Punch only inside school geofence; manage locations (Mgmt); punch history | `LocationViewController`, `CreateLocationViewController`, `PunchHistoryListVC` | `staff-attd/api/geometric` | Must be inside boundary ("outside the institute's boundary"); location permission required | Geofence rule | Map with boundary and live distance |
| 33 | Staff-wise attendance report | Mgmt | Staff attendance by date | `StaffWiseAttendaceVC`, `LocationReportVC` | `staff-attd/api/geometric` | — | — | Charts + filters |
| 202 | Hostel attendance & outpass | Staff | Hostel list, mark attendance, mess timetable, outpass approvals | `HostelListVc`, `MarkAttendanceViewController`, `OutpassRequestsViewController`, `AdminRequestsViewController` | `stud-attd/api/hostel-attendance` | — (not verified) | Approval actions | Pending-approvals badge |
| 18, 28 | Student leave requests | Staff | Approve/reject leave from parents | `SenderLeaveRqstVC` | `comm/api/leave-req` | Rejection reason required ("Enter Reason") | Approve/reject + reason | Swipe actions; bulk approve (only if backend allows) |
| 203, 204 | Staff leave (apply / approve) | Staff / Mgmt | Apply own leave; approve staff leave | `ApplyLeaveReqVC`, `SenderLeaveRqstVC` | `comm/api/leave-req-for-staff` | Leave type, from and to dates required | Validation | Date-range picker |
| 19 | Lesson plan | Staff (`p3` own class; others all classes) | View/edit lesson plans | `LessonPlanVC`, `EditLessonVC`, `ViewLessonVC` | `lms/api/lesson-plan` | Scope by role | Role scope | Progress indicator per unit |
| 20 | LSRW (listening, speaking, reading, writing) skills | Staff | Create skill tasks; review submissions | `SenderLSRWVC`, `LSRWSubmissionVC` | `lms/api/lsrw` | Audio/file attachments | Review flow | Inline audio player |
| 27 | Quiz | Staff | Create questions (or pick from bank), publish, view submissions/report | `SenderQuizVc`, `CreateQuizQutionVc`, `QuizSubmissionVc`, `ReportsQuizVc` | `lms/api/quiz` | Question limit; correct answer and 4 options required | Limits | Step progress for quiz creation |
| 206 | Class test | Staff | Multi-step creation: standard → sections → subjects → details → review; records and reports | `CreateClassTestVc`, `Select*ViewController`, `ExamRecordsVC`, `ExamReportsVC` | `exam/api/exam-test` | Step validation | Steps | Visible stepper |
| 41 | Exam marks entry (incl. AI from image) | Staff | Pick exam/class → upload marksheet photo for AI reading or enter manually → edit grid | `staffExamMarkVC`, `ExamImgUploadVC`, `ExamActivitySelectionVC`, `EnterMarkVC` | `exam/api/new-exam`, `ocr/api/upload-marks` | Select exam and at least one activity | AI + manual paths | Spreadsheet-like grid with keyboard navigation |
| — | Exam analysis / schedule exam | Staff | Analysis charts; schedule exams | `ExamAnaylzeSelectionVc`, `anaylizesVc`, `ScheduleExamVC` | `exam/api/*` | — | — | — |
| 5, 26 | Parent–teacher meeting | Staff | Create meeting slots (mode, classes, dates, duration, breaks); view bookings | `NewPtmVC`, `CreateMeetingVc`, `SlotListVC` | `ptm/api/ptm-schedule` | Slot duration, break, at least one slot | Slot rules | Visual slot timeline |
| 24 | Online meeting | Staff | Create/join meetings | `OnlineMeetingVC` | (not verified) | — | — | — |
| 17 | Chat with students/parents | Staff | Threaded chat | `IntractwithStudentVc`, `ChatVC` | `comm/api/interaction` | — | — | Unread markers |
| 22 | Message from management | Staff | Inbox from management; school filter for multi-school | `MessageFromManagementViewController` | `comm/api/msg-from-management` | — | Unread badge | — |
| 35 | Student report → student fee details | Staff | Student list (search, filters, call/SMS/email, photo update) → fee details for a student | `ReportStudentListVC`, `StudentFeeDetailsVC` | `admin/api/get-student-report`, `fee/api/fee-details/student-fee-details` | Fee categories, status per fee | Fee figures exactly as sent | Summary-first layout |
| 14 | Pending fee report | Mgmt | Pending fee by class | `PendingFeeReportViewController` | `fee/api/fee-report` | — | — | Sort + export |
| 8 | Daily fee collection | Mgmt | Collections by date | `NewDailyCollectionViewController` | `fee/api/fee-report` | — | — | Charts |
| 31 | School strength | Mgmt | Student counts by class/gender | `SchoolStrengthVC` | `admin/api/get-school-strength` | — | — | Charts |
| 207 | Parent concerns | Staff | Review and respond to concerns | `concernListVc` | `admin/api/parent-concern` | — | — | Status filters |
| 205 | Bus tracking (staff) | Staff | Bus list and live map | `busListVC` | `transport/api/*` | Provider depends on `gps_type` | Provider rule | — |
| 30, 36 | School needs / important info | Staff | Web content | `ImportantInfoViewController` | web view | — | — | — |
| 40 | Pauket rewards | Staff | Points, coupons, history | `CustomTabVC`, `HomePaucktVC` | Pauket API | — | — | — |
| — | Notifications list, voice-call screen | Staff | List of notifications; incoming school voice call via push | `NotificationViewController`, `NotificationCallVC` | `dashboard/api/*` | — | — | — |

## C. Parent features

| ID | Feature | Behaviour (today) | Screens | Data / API | Rules & validation | Preserve | Opportunity |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 7 | Messages and voice | Inbox of text and voice messages; read status sent back | `ParentCommunicationVc` | `comm/api/communication` (+ archive) | Read-status update on open | Read receipts; archive | Unified inbox with filters |
| 15 | Homework | Homework by date (calendar strip); mark complete; preview attachments | `homeWorkVc`, `PrivewVc` | `comm/api/homework` | — | Mark complete | Today-first view |
| 2 | Assignments | List, submit work, see feedback | `AssignmentListVC`, `SubmitVC` | `comm/api/assignment` | Attachment required to submit (not verified) | Submission | Due-date grouping |
| 4 | Attendance report | Monthly calendar and summary | `ReciverAttendanceReportVC`, `NewAttendanceReportVC` | `stud-attd/api/attendance` | — | — | Calendar heatmap |
| 6 | Class timetable | Day-wise timetable | `TimetableVC` | `lms/api/time-table` | — | — | Current period highlight |
| 10 | Exam marks and exam timetable | Marks by exam, rubric details | `ExamDetailsVC`, `MarkListVC`, `RubricDetailViewController` | `exam/api/exam*` | — | — | Trend chart |
| 206 | Class tests | Test results | `ParentClassTestVc` | `exam/api/exam-test` | — | — | — |
| 12 | Fees and payment proof | Fee page (web view) with payment proof upload; proof history with AI reading and status | `FeeDetails`, `paymentProofVc`, `paymentProofDetailVc` | `fee/api/fee-details/*` | Proof status pending/approved/rejected | Proof upload and status | Native fee summary |
| 9 | Events | Upcoming/ongoing events, holidays | `EventResiverVC`, `HolidayVC` | `admin/api/school-event` | — | — | Calendar |
| 23 | Notice board | Notices with reminder option | `ReciverNoticeBoardVC`, `RiminderTimePicker` | `admin/api/notice-board` | Reminders permission ("enable reminders access") | Reminder creation | — |
| 39 | Attachments | Files sent by school | `AttachmentsVc` | `comm/api/attachment` | — | Downloads | — |
| 20 | LSRW activities | Do skill tasks: record audio, upload files, submit | `LSRWActivitesVC`, `LsrwListShowViewController`, `SubmitLsrwViewController` | `lms/api/lsrw` | Restrictions per task (`RestrictionVc`) | Recording + submit | Clear task steps |
| 27 | Quiz | Play quiz, see result | `QuizVC`, `NewPlayQuizVC`, `QuizCompletedVc` | `lms/api/quiz` | — | Timer/answers (not verified) | — |
| 26 | Parent–teacher meeting | Book slots, history | `PtmNavigationVC`, `PtmParentVC`, `PtmHistoryVC` | `ptm/api/ptm-schedule` | "Please select at least one slot"; booking confirmation; cancel needs reason | Booking rules | — |
| 16 | Chat with teacher | Threaded chat | `InteractionVC` | `comm/api/interaction` | — | — | — |
| 5 | Certificate request | Request and preview certificates | `certificateReqVc`, `CertificatePreviewVc` | `comm/api/certificate` | — | — | Request status tracker |
| 207 | Concerns | Raise concern with attachments; list | `commonConcernVc`, `addConcernVc` | `admin/api/parent-concern` | Description required | — | — |
| — | Leave and outpass | Apply leave for child; outpass | `LeveCreateVC`, `LeveHistoryVC`, `OutpassVC` | `comm/api/leave-req` | Leave type and dates required | — | — |
| 202 | Hostel dashboard | Hostel attendance, outpass requests | `parentHostelDashboardVC`, `NewOutpassRequestVC` | `stud-attd/api/hostel-attendance` | — | — | — |
| 205 | Bus tracking | Bus list, live map with route and ETA (own tracker) or Dhundhoo tracker | `busListVC`, `BusTrakingVC`, `whereismybusVc` | `transport/api/*`, OSRM, MapLibre | Provider by `gps_type` | Provider rule | Live ETA card |
| 40 | Pauket rewards | Points, coupons, redeem history | `CustomTabVC`, `ClaimCouponVc`, `ReedimHistoryVc` | Pauket API | — | — | — |
| 25, 30, 36 | E-books, marketplace, info | Web content | `ImportantInfoViewController` | web view | — | — | — |
| — | Birthday wish, what's new | Celebration popup; release notes | `BirthDayWishVC`, `WhatsNewVc` | dashboard menus `is_birthday` | — | — | — |

## D. Shared capabilities

| Capability | Behaviour | Preserve |
| --- | --- | --- |
| Recipient picker (`RecipientVc`) | Choose entire school, standard, section/student, group, staff (types depend on role and feature); academic year | Role rules per feature |
| School picker (`SchoolListVC`) | Management chooses a school per feature, or several schools for multi-school sending | Overwrites active record; multi-school send |
| Media | Photo/document picker, audio recorder/player, video picker and player, image viewer with share/download | File type and count limits; upload progress |
| Push notifications | Open the right module and switch record | Deep-link behaviour |
| Loader, toast, alerts | Full-screen dimmed Lottie loader (auto-hides after 10 s), toasts, alerts | — (presentation only) |
| Localisation | 5 languages at runtime | All strings through the translation lookup |

## E. Counts (verified)

| Item | Count |
| --- | --- |
| View controllers (UIViewController subclasses) | 207 (includes 8 older duplicates in `ParentVC's/`, 1 unused splash, popups and sheets) |
| Staff menu IDs mapped | 35 |
| Parent menu IDs mapped | 24 |
| Feature entries in this inventory | 62 (7 account, 32 staff, 23 parent) plus 6 shared capabilities |
