# Page-by-Page Specification — School Chimes iOS (proposed redesign)

> Documentation only; nothing here is implemented. All layouts are **recommendations**. "Existing" marks current behaviour verified in source.
>
> The app has **207 view controllers**. Many follow the same pattern, so this document is organised as:
> 1. **Screen templates** (T1–T9): the full specification every screen of that type follows.
> 2. **Key screen specifications**: detailed specs for the 28 most-used or most complex screens.
> 3. **Appendix: every screen**, mapped to a template with screen-specific notes.
>
> Device behaviour uses iOS size classes: **compact width** (all iPhones portrait) and **regular width** (iPad, and iPad split view at 678 pt and wider). Desktop does not apply (iOS app). See `RESPONSIVE_AND_ACCESSIBILITY_REQUIREMENTS.md`.

---

## 1. Screen templates

Each template lists layout, components, interactions, states, device behaviour and accessibility. Component names refer to `COMPONENT_SPECIFICATION.md`.

### T1 — Auth step
- **Purpose:** one question per screen (country, mobile, password, OTP, new password).
- **Layout:** brand logo (64 pt) · title (Title 2) · one-line explanation (Subheadline, secondary) · input · primary button pinned above keyboard · secondary links (Forgot password, Change number, Terms).
- **Interaction:** primary button disabled until input valid; Return key submits; keyboard opens on appear.
- **States:** loading = button spinner (no full-screen overlay); error = inline message under the field + haptic; network error = inline banner with Retry.
- **Compact:** single column, 16 pt margins. **Regular:** card 480 pt wide, centred.
- **Accessibility:** field labels (not placeholders only), OTP field as one-time-code text content, errors announced.

### T2 — Dashboard (Home)
- **Layout:** header with context chip · Today panel (horizontal cards) · grouped tile grid · "More" group for unknown IDs.
- **Interaction:** tile tap pushes the module; long-press shows the description (server `description` field, existing); badges from `menu-counts` (existing).
- **States:** skeleton tiles on first load; cached last menus shown instantly on next launch (recommendation); error banner with Retry; empty "No features enabled for this account. Contact your school."
- **Compact:** 3 tiles per row (375 pt and wider), 2 on 320 pt. **Regular:** 5–6 per row; Today panel as a 2-column grid.
- **Accessibility:** each tile one element: "Homework, 3 new".

### T3 — List / history
- **Layout:** header (title + optional add action) · search field (collapsible) · filter chips (status/type/date) · list of cards · pull to refresh · pagination footer.
- **Card:** primary text, secondary meta (date · sender/target), status chip, trailing chevron or attachment count.
- **Interaction:** tap → detail (push); swipe actions only for existing actions (approve/reject, mark read, delete where the API exists).
- **States:** skeleton rows; empty state with reason and primary action ("Send homework"); filter-empty "No results for 'Pending'" + Clear filters; error with Retry; end-of-list footer.
- **Regular width:** split view — list (360 pt) + detail.
- **Accessibility:** card = one element with combined label; swipe actions also in a context menu.

### T4 — Detail
- **Layout:** header · summary block (title, status chip, key facts) · sections (grouped inset lists) · attachments grid · actions bar (sticky bottom) for existing actions.
- **States:** skeleton; error with Retry; deleted/unavailable message.
- **Regular:** max content width 720 pt, two-column facts.

### T5 — Composer (send / create)
- **Used by:** communication, homework, assignment, notice, event, attachment, LSRW task, quiz, lesson plan, leave apply, concern.
- **Layout:** header with Cancel (left) and Send/Next (right) · recipient row ("To: Class V-B, VI-A · 64 students") opening the recipient picker · content fields (title, description with character counter, voice recorder, attachments) · options (schedule, emergency, date) · sticky primary button.
- **Validation:** inline; counters show limits from login data (existing limits); Send disabled until required fields are valid.
- **Confirmation:** summary sheet before high-impact sends (voice call to parents, entire school, emergency, absent calls) — mirrors existing confirmations.
- **States:** upload progress per attachment with retry; sending = button spinner; success = toast + return to list with the new item highlighted; failure = keep draft + error banner.
- **Regular:** form max width 640 pt; recipient summary in a side panel.

### T6 — Report / analytics
- **Layout:** filter bar (date range, class/section, school when Mgmt) · summary cards (counts, totals) · chart (where data has a shape) · list/table below.
- **States:** skeleton cards; "No data for this period" with change-filter action.
- **Regular:** cards in a 4-column row; table with more columns.

### T7 — Picker / selection
- **Used by:** recipient picker, school list, class/section/subject steps, exam selection, country list, date/time.
- **Layout:** sheet (medium/large detents) · search · grouped list with checkmarks · selection summary + Done.
- **States:** empty search; loading rows.
- **Accessibility:** selected state announced; "Select all" control.

### T8 — Media viewer, recorder and map
- **Image/PDF/video viewer:** full-screen, pinch zoom, share/download (existing actions), page indicator.
- **Audio recorder:** large record button, timer vs limit, waveform, play / re-record / delete.
- **Map screens:** full-screen map with a bottom sheet for details and actions.
- **States:** loading spinner over media; failed to load + Retry.

### T9 — Popup, sheet and confirmation
- **Used by:** logout, force update, rate us, birthday, what's new, date pickers, filters, slot creation.
- **Rule:** bottom sheet for choices and short forms; centred alert only for destructive or blocking messages (logout, forced update).

---

## 2. Key screen specifications

Each spec gives purpose, user and primary action, layout, content and components, interactions, states, device behaviour and accessibility notes beyond the template.

### 2.1 Splash (`SplashVC`) — T1
- **Purpose:** launch, version check, auto-login. **User:** everyone. **Primary action:** none (automatic).
- **Layout:** brand logo centred on brand colour; app name; small progress indicator after 1 s.
- **Keep (existing):** biometric gate, version check, forced/optional update, auto-login, routing.
- **States:** offline → "You're offline" + Retry (today it falls back to the login screen silently); forced update → blocking sheet with Update.
- **Accessibility:** announce "Loading School Chimes"; respect Reduce Motion (no confetti/ripple).

### 2.2 Onboarding (`OnboardingVC`) and country (`CountryListVC`) — T1 / T7
- Onboarding: 3 pages maximum, Skip always visible, page control. Country: list with flags and search, device region pre-selected.

### 2.3 Login: mobile (`MobileNumberVc`), login (`LoginVc`), password (`PasswordVc`) — T1
- **Proposed:** one adaptive flow. Step 1: mobile number with country-code prefix and length-aware formatting. Step 2 (server decides, existing): password **or** OTP **or** create password.
- **Content:** Terms checkbox with link (existing rule: must accept); "Forgot password?" → OTP flow.
- **Errors:** "Enter a valid 10-digit mobile number" inline; server messages inline; network failure → banner with Retry.

### 2.4 OTP (`OTPVc`) — T1
- 6 boxes behaving as one field (one-time-code autofill), resend timer (existing 30 s), "Didn't get it?" help using `more_info` / `dial_numbers` from the API (existing data), change-number link.

### 2.5 Create / reset password (`CreatePasswordVc`) — T1
- New + confirm fields with show/hide, inline match check.

### 2.6 Account switcher (replaces `PriorityVC` and `SwitchRollVC` as daily UI) — T7
- **Purpose:** choose role, school or child. **Layout:** sheet: "Signed in as {mobile}" · **Staff** section (one row per school: logo, school name, role) · **Parent** section (one row per child: photo, name, class, school) · current row checked.
- **Rules to keep:** management rows (`p1/p2/p4`) open the first school and keep the per-feature school picker; blocked children (`is_not_allow`) shown disabled with the server message; non-teaching staff rows must be selectable (fixes today's dead end).
- **First login:** full-screen once; afterwards remembered (recommendation) and opened from the header chip.

### 2.7 Staff home (`CustomDashboard`) — T2
- Today panel cards (only from data already loaded): unread messages from management (`menu-counts`), birthday card (`is_birthday`). Future options needing new data: "attendance not marked", "pending leave approvals".
- Grouped tiles (see `REDESIGN_OVERVIEW.md` §4.3); search (existing) as a pull-down field.

### 2.8 Parent home (`CustomParentDashboardVC`) — T2
- Child chip in header. Today panel: unread counts (existing `menu-counts`); future options: today's homework, attendance today, bus ETA, fee due.

### 2.9 Profile and settings — T4 (`UpdateProfileVC`, `SettingsViewController`, `LanguageVc`, `HelpVc`, `FAQViewController`, `ContactUsVc`, `ReportBugVcViewController`, `RateUsViewController`, `LogoutViewController`)
- One Profile tab: profile card (photo edit) · Account (switch account, change password, biometric) · Preferences (language) · Support (help, FAQ, contact, report a bug, rate us) · Log out (destructive, confirmation alert).

### 2.10 Notifications (`NotificationViewController`) — T3
- Inside the Inbox tab; grouped by day; tap deep-links exactly like a push today.

### 2.11 Communication composer (`ComunicationVC`, `TextMessageVC`, `VoiceMessageVc`, `ScheduleCallVC`, `VoiceMessagesVC`, `CommonPagenationVc`) — T5
- Segmented **Text | Voice | Sent**. Text: counter against `max_general_sms_count`. Voice: recorder against `max_general_voice_duration` or the emergency limit. Options for management only (existing): Schedule, Emergency call, multi-school.
- Confirmation sheet: recipient count and type, schedule time, emergency flag.

### 2.12 Recipient picker (`RecipientVc`) — T7
- Large sheet. Segments only for allowed types (existing rules: `p3` → Section/Student and Group; management → Entire school, Standard, Section/Student, Group, Staff; events exclude Section and Staff). Academic year selector. Selected summary chips at the bottom. "Select all in class".

### 2.13 School picker (`SchoolListVC`) — T7
- Sheet listing schools; from multi-school send: checkboxes + "Send to N schools". The chosen school then shows in the header chip.

### 2.14 Mark attendance (`MarkAttendenceVC`, `AttendanceMarkingVC`, `absentPrivewVC`) — T5
- **Layout:** class/section and date at top · sticky counters (Present, Absent, OD) · student rows with a P / A / OD segmented control (default Present, recommendation) · Submit.
- **Keep:** absent preview and the warning that absent students' parents receive an automatic call.
- **Regular:** 2-column student grid.

### 2.15 Homework / assignment composer (`SenderSideHomeWorkViewController`, `SenderAssignmentTextViewController`) — T5
- Attachments grid (photo, PDF, voice, video — max 2 videos, existing), submission date for assignments.

### 2.16 Homework for parents (`homeWorkVc`, `PrivewVc`) — T3 / T4
- Date strip (existing) + one card per subject; attachments inline; "Mark complete" (existing).

### 2.17 Messages inbox for parents (`ParentCommunicationVc`) — T3
- Filters All · Text · Voice; voice cards with inline player; read state sent with the existing read-status API.

### 2.18 Student report list (`ReportStudentListVC`) — T3
- Search, class filter chips, student cards (photo, name, class, roll, admission no.); trailing call / SMS / email actions (existing); tap → student fee details.

### 2.19 Student fee details (`StudentFeeDetailsVC`, recently added) — T4
- Summary card (total, paid, discount, pending, paid progress) · one section per fee category with status chips · expandable payment history and carry-over breakdown. Use as the reference pattern for fee screens.

### 2.20 Parent fees (`FeeDetails`, `paymentProofVc`, `paymentProofDetailVc`, `ViewPaymentVC`) — T4 / T3
- Native summary with the 2.19 layout, replacing the web view where the parent API returns the same data (**open question**); "Upload payment proof" primary action; proof history with status filters and AI reading details.

### 2.21 Bus tracking (`busListVC`, `BusTrakingVC`, `whereismybusVc`, `BusDetailsVC`) — T8
- Full-screen map; bottom sheet with bus name, driver call, next stop, ETA, last-updated time; route line. Provider rule (`gps_type`) kept.

### 2.22 Exam marks entry (`staffExamMarkVC`, `ExamListVC`, `ExamImgUploadVC`, `ExamActivitySelectionVC`, `EnterMarkVC`, `FilterPopover`) — T7 → T5
- Stepper: Exam → Class → Upload mark sheet (AI) or Manual → Activities → Grid. Grid: sticky student column, numeric keypad, next cell on Return, maximum-mark check only if the API provides it (**not verified**).

### 2.23 Class test creation (`CreateClassTestVc`, `SelectStandardViewController`, `SelectSectionsViewController`, `SelectSubjectVc`, `SelectDetailsViewController`, `SelectReviewViewController`) — T5
- Visible 5-step stepper; Back keeps entries; Review step with edit links per step.

### 2.24 Parent–teacher meeting (`NewPtmVC`, `CreateMeetingVc`, `CreateSlotsBottomVC`, `SlotListVC`; parent `PtmParentVC`, `PtmHistoryVC`) — T5 / T7
- Staff: slot timeline preview while setting duration and breaks. Parent: day selector + slot grid; booking confirmation (existing); cancel requires a reason (existing).

### 2.25 Leave (`ApplyLeaveReqVC`, `SenderLeaveRqstVC`, `LeveCreateVC`, `LeveHistoryVC`) — T5 / T3
- Apply: leave type, date range, reason (existing required fields). Approvals: Pending / Approved / Rejected filters; approve or reject with a reason sheet.

### 2.26 Staff geo attendance (`LocationViewController`, `CreateLocationViewController`, `PunchHistoryListVC`, `LocationHistoryVc`) — T8
- Map with school boundary and current position; Punch button enabled only inside the boundary (existing rule) with a distance hint when outside; history below.

### 2.27 Quiz (staff `SenderQuizVc`, `CreateQuizQutionVc`; parent `QuizVC`, `NewPlayQuizVC`, `QuizCompletedVc`) — T5 / T3
- Staff: question editor with 4 options and correct-answer selector; counter against the question limit (existing). Parent: one question per screen, progress bar, result screen (celebration kept, Reduce Motion respected).

### 2.28 Chat (`IntractwithStudentVc`, `chatWithStudentVc`, `ChatVC`, `InteractionVC`) — T3 / T5
- Standard chat: bubbles, timestamps, attachment button, composer pinned above the keyboard, unread separator.

---

## 3. Appendix — every screen

Template assignment uses the screen's name, folder and place in navigation. Entries marked † were assigned from the name and folder only; confirm on device. "Remove" = unused or duplicated today (no redesign needed). "Container" = hosts other screens.

| Area | Screen | Template | Notes |
| --- | --- | --- | --- |
| App | `ViewController` | Remove | Template stub |
| Auth / CountryList | `CountryListVC` | T7 | Spec 2.2 |
| Auth / CreatePassword | `CreatePasswordVc` | T1 | Spec 2.5 |
| Auth / ForceUpdatePopup | `ForceUpdateVc` | T9 | Blocking when forced |
| Auth / Login | `LoginVc` | T1 | Spec 2.3 |
| Auth / MobileNumber | `MobileNumberVc` | T1 | Spec 2.3 |
| Auth / OnboardingFlow | `OnboardingVC` | T1 | Spec 2.2 |
| Auth / Otp | `OTPVc` | T1 | Spec 2.4 |
| Auth / Password | `PasswordVc` | T1 | Spec 2.3 |
| Auth / Priority | `PriorityVC` | T7 | Spec 2.6 |
| Auth / Splash | `SplashVC` | T1 | Spec 2.1 |
| Auth / Splash | `SplashViewController` | Remove | Never shown (not the storyboard entry) |
| Auth / TermsAndCondition | `TermsAndCondVC` | T4 | Terms content |
| CommonScreens / BirthdayVc | `BirthDayWishVC` | T9 | Becomes a dismissible card on Home |
| CommonScreens / CustomPopup | `UpdatePopupVC` | T9 |  |
| CommonScreens / DatePicker | `DatePickerVC` | T9 | Shared date picker |
| CommonScreens / ImageViewer | `ImageShowVc` | T8 |  |
| CommonScreens / ImageViewer | `shareAndDownloadVc` | T9 |  |
| CommonScreens / SchoolList | `SchoolListVC` | T7 | Spec 2.13 |
| CommonScreens / SelectRecipient | `RecipientVc` | T7 | Spec 2.12 |
| CommonScreens / VideoPreviewVC | `VideoPreviewVc` | T8 |  |
| CommonScreens / What'sNewVC | `WhatsNewVc` | T9 | Release notes |
| CommonScreens / popoverVc | `EmergencyInfoPopoverVCViewController` | T9 |  |
| ParentDashBoard / Assignment | `AssignmentListVC` | T3 | † |
| ParentDashBoard / Assignment | `AssignmentSummitionVC` | T3 | † |
| ParentDashBoard / Assignment | `SubmitVC` | T5 | † |
| ParentDashBoard / Attachments | `AttachmentsVc` | T3 | † |
| ParentDashBoard / CertificateRequest | `CertificatePreviewVc` | T4 | † |
| ParentDashBoard / CertificateRequest | `certificateReqVc` | T4 | † |
| ParentDashBoard / ClassTest | `MarksDetailsViewController` | T5 | † |
| ParentDashBoard / ClassTest | `ParentClassTestVc` | T4 | † |
| ParentDashBoard / ClassTimeTable | `TimetableBottomVC` | T9 | † |
| ParentDashBoard / ClassTimeTable | `TimetableVC` | T3 | † |
| ParentDashBoard / Communication | `ParentCommunicationVc` | T3 | Spec 2.17 |
| ParentDashBoard / ConcernVc | `addConcernVc` | T5 | † |
| ParentDashBoard / ConcernVc | `commonConcernVc` | T4 | † |
| ParentDashBoard / ConcernVc | `concernListVc` | T3 | † |
| ParentDashBoard / Event | `EventResiverVC` | T3 | † |
| ParentDashBoard / Event | `HolidayVC` | T3 | Calendar tab |
| ParentDashBoard / ExamMarkVc | `ExamDetailsVC` | T4 | † |
| ParentDashBoard / ExamMarkVc | `ExameMarVC` | T4 | † |
| ParentDashBoard / ExamMarkVc | `MarkListVC` | T3 | † |
| ParentDashBoard / ExamMarkVc | `RubricDetailViewController` | T4 | † |
| ParentDashBoard / ExamMarkVc | `ViewDetailsVc` | T4 | † |
| ParentDashBoard / ExamTimeTable | `ExamTmTblVCViewController` | T4 | † |
| ParentDashBoard / FeeDetail | `FeeDetails` | T4 | Spec 2.20 |
| ParentDashBoard / FeeDetail | `paymentProofDetailVc` | T4 | Spec 2.20 |
| ParentDashBoard / FeeDetail | `paymentProofVc` | T3 | Spec 2.20 |
| ParentDashBoard / FeeDetail | `ViewPaymentVC` | T4 | Spec 2.20 |
| ParentDashBoard / HostelDashboard | `NewOutpassRequestVC` | T3 | † |
| ParentDashBoard / HostelDashboard | `OutpassRequestsVC` | T3 | † |
| ParentDashBoard / HostelDashboard | `parentHostelDashboardVC` | T3 | † |
| ParentDashBoard / HostelDashboard | `yearAndMonthCalenderVc` | T4 | † |
| ParentDashBoard / IntractWithStudentVc | `chatWithStudentVc` | T5 | Spec 2.28 |
| ParentDashBoard / IntractWithStudentVc | `IntractwithStudentVc` | T3 | Spec 2.28 |
| ParentDashBoard / LSRW | `LSRWActivitesVC` | T4 | † |
| ParentDashBoard / LSRW | `LsrwListShowViewController` | T3 | † |
| ParentDashBoard / LSRW | `LSRWSubmisionListVC` | T3 | † |
| ParentDashBoard / LeaveRequest | `LeveCreateVC` | T5 | Spec 2.25 |
| ParentDashBoard / LeaveRequest | `LeveHistoryVC` | T3 | Spec 2.25 |
| ParentDashBoard / LeaveRequest | `OutpassVC` | T4 | † |
| ParentDashBoard / NoticeBoard | `ReciverNoticeBoardVC` | T3 | † |
| ParentDashBoard / NoticeBoard | `RiminderTimePicker` | T9 | † |
| ParentDashBoard / PTM | `PtmHistoryVC` | T3 | Spec 2.24 |
| ParentDashBoard / PTM | `PtmNavigationVC` | Container | Parent PTM container |
| ParentDashBoard / PTM | `PtmParentVC` | T7 | Spec 2.24 |
| ParentDashBoard / PageNavigationVC  | `NavigationVC` | Container |  |
| ParentDashBoard / ParentHomePage | `CustomParentDashboardVC` | T2 | Spec 2.8 |
| ParentDashBoard / Pauckt | `BottomView` | T9 | † |
| ParentDashBoard / Pauckt | `ClaimCouponVc` | T5 | † |
| ParentDashBoard / Pauckt | `CooponViewVC` | T4 | † |
| ParentDashBoard / Pauckt | `CustomTabVC` | Container | Pauket tabs |
| ParentDashBoard / Pauckt | `HomePaucktVC` | T4 | † |
| ParentDashBoard / Pauckt | `ReedimHistoryVc` | T3 | † |
| ParentDashBoard / Quiz | `NewPlayQuizVC` | T5 | Spec 2.27 one question per screen |
| ParentDashBoard / Quiz | `QuizCompletedVc` | T9 | Spec 2.27 result |
| ParentDashBoard / Quiz | `QuizVC` | T3 | Spec 2.27 |
| ParentDashBoard / ReciverAttendanceReport | `NewAttendanceReportVC` | T6 | † |
| ParentDashBoard / ReciverAttendanceReport | `PopoverViewVC` | T9 | † |
| ParentDashBoard / ReciverAttendanceReport | `ReciverAttendanceReportVC` | T6 | † |
| ParentDashBoard / ReciverHomework | `homeWorkVc` | T3 | Spec 2.16 |
| ParentDashBoard / ReciverHomework | `PrivewVc` | T4 | Spec 2.16 |
| ParentDashBoard / TrakingDriver | `BusDetailsVC` | T4 | Spec 2.21 |
| ParentDashBoard / TrakingDriver | `BusTrakingVC` | T8 | Spec 2.21 |
| ParentDashBoard / WhereIsBus | `busListVC` | T3 | Spec 2.21 |
| ParentDashBoard / WhereIsBus | `whereismybusVc` | T8 | Spec 2.21 |
| ParentVC's | `ExameMarVC` | Remove | Older duplicate of a ParentDashBoard screen |
| ParentVC's | `ExamTmTblVCViewController` | Remove | Older duplicate of a ParentDashBoard screen |
| ParentVC's | `ImagePdfVC` | Remove | Older duplicate of a ParentDashBoard screen |
| ParentVC's | `LsrwListShowViewController` | Remove | Older duplicate of a ParentDashBoard screen |
| ParentVC's | `LSRWTakingSkillViewController` | Remove | Older duplicate of a ParentDashBoard screen |
| ParentVC's | `PreviewLsrwViewController` | Remove | Older duplicate of a ParentDashBoard screen |
| ParentVC's | `SenderImgPdfVC` | Remove | Older duplicate of a ParentDashBoard screen |
| ParentVC's | `SubmitLsrwViewController` | Remove | Older duplicate of a ParentDashBoard screen |
| SchoolDashBoard / ApplyLeave | `ApplyLeaveReqVC` | T5 | Spec 2.25 |
| SchoolDashBoard / Assignment | `AssignmentPriview` | T4 | † |
| SchoolDashBoard / Assignment | `AssignmentReport` | T6 | † |
| SchoolDashBoard / Assignment | `AssignmentReportVc` | T6 | † |
| SchoolDashBoard / Assignment | `SenderAssignmentTextViewController` | T5 | Spec 2.15 |
| SchoolDashBoard / Assignment | `SubmitedAssignmentVC` | T5 | † |
| SchoolDashBoard / Attendance | `AttendanceMarkingVC` | T5 | Spec 2.14 |
| SchoolDashBoard / Attendance | `StudentHistryVC` | T6 | Student attendance history |
| SchoolDashBoard / Chat | `ChatVC` | T5 | Spec 2.28 |
| SchoolDashBoard / Chat | `InteractionVC` | T3 | Spec 2.28 |
| SchoolDashBoard / Classtest | `CreateClassTestVc` | T5 | Spec 2.23 |
| SchoolDashBoard / Classtest | `ExamRecordsVC` | T3 | † |
| SchoolDashBoard / Classtest | `ExamReportsVC` | T6 | † |
| SchoolDashBoard / Classtest | `SelectDetailsViewController` | T5 | Spec 2.23 |
| SchoolDashBoard / Classtest | `SelectReviewViewController` | T4 | Spec 2.23 |
| SchoolDashBoard / Classtest | `SelectSectionsViewController` | T7 | Spec 2.23 |
| SchoolDashBoard / Classtest | `SelectStandardViewController` | T7 | Spec 2.23 |
| SchoolDashBoard / Classtest | `SelectSubjectVc` | T7 | Spec 2.23 |
| SchoolDashBoard / Communication | `AppTourVC` | T9 | Coach marks |
| SchoolDashBoard / Communication | `ComunicationVC` | T5 | Spec 2.11 |
| SchoolDashBoard / DailyCollection | `NewDailyCollectionViewController` | T6 | † |
| SchoolDashBoard / Event | `EventHistoryVC` | T3 | † |
| SchoolDashBoard / Event | `EventsVC` | T3 | † |
| SchoolDashBoard / Event | `PreviewImageVC` | T4 | † |
| SchoolDashBoard / Exam Mark | `EnterMarkVC` | T5 | Spec 2.22 marks grid |
| SchoolDashBoard / Exam Mark | `ExamActivitySelectionVC` | T7 | Spec 2.22 |
| SchoolDashBoard / Exam Mark | `ExamImgUploadVC` | T5 | Spec 2.22 |
| SchoolDashBoard / Exam Mark | `ExamListVC` | T7 | Spec 2.22 |
| SchoolDashBoard / Exam Mark | `FilterPopover` | T9 | Spec 2.22 |
| SchoolDashBoard / Exam Mark | `staffExamMarkVC` | T7 | Spec 2.22 |
| SchoolDashBoard / ExamAnaylze | `anaylizesVc` | T6 | † |
| SchoolDashBoard / ExamAnaylze | `ExamAnaylzeSelectionVc` | T6 | † |
| SchoolDashBoard / ExamAnaylze | `selectExamVc` | T7 | † |
| SchoolDashBoard / HomePage | `CustomDashboard` | T2 | Spec 2.7 |
| SchoolDashBoard / HomePage | `SideMenuVC` | Remove | Items move to Profile tab and header switcher |
| SchoolDashBoard / HomePage | `SwitchRollVC` | T7 | Merge into Spec 2.6 |
| SchoolDashBoard / HomeWork | `SenderHomeWorkVC` | T5 | † |
| SchoolDashBoard / HomeWork | `SenderSideHomeWorkViewController` | T5 | Spec 2.15 |
| SchoolDashBoard / HostelAttendace | `AdminRequestsViewController` | T3 | † |
| SchoolDashBoard / HostelAttendace | `AttendanceHistoryViewController` | T3 | † |
| SchoolDashBoard / HostelAttendace | `HostelDashBoardVc` | T3 | † |
| SchoolDashBoard / HostelAttendace | `HostelListVc` | T3 | † |
| SchoolDashBoard / HostelAttendace | `MarkAttendanceViewController` | T5 | † |
| SchoolDashBoard / HostelAttendace | `MesstimeTabelVC` | T4 | † |
| SchoolDashBoard / HostelAttendace | `OutpassRequestsViewController` | T3 | † |
| SchoolDashBoard / ImportantInfo | `ImportantInfoViewController` | T4 | Web content |
| SchoolDashBoard / Lesson plan | `EditLessonVC` | T5 | † |
| SchoolDashBoard / Lesson plan | `LessonPlanVC` | T4 | † |
| SchoolDashBoard / Lesson plan | `ViewLessonVC` | T4 | † |
| SchoolDashBoard / Location | `AddLocationHistory` | T3 | † |
| SchoolDashBoard / Location | `CreateLocationViewController` | T5 | Spec 2.26 |
| SchoolDashBoard / Location | `LocationHistoryVc` | T3 | Spec 2.26 |
| SchoolDashBoard / Location | `LocationReportVC` | T6 | † |
| SchoolDashBoard / Location | `LocationViewController` | T8 | Spec 2.26 |
| SchoolDashBoard / Location | `PunchHistoryListVC` | T3 | Spec 2.26 |
| SchoolDashBoard / Mark Attendence | `absentPrivewVC` | T9 | Spec 2.14 absent preview |
| SchoolDashBoard / Mark Attendence | `MarkAttendenceVC` | T5 | Spec 2.14 |
| SchoolDashBoard / Message | `CommonPagenationVc` | T3 | Spec 2.11 history |
| SchoolDashBoard / Message | `ScheduleCallVC` | T9 | Spec 2.11 |
| SchoolDashBoard / Message | `TextMessageVC` | T5 | Spec 2.11 |
| SchoolDashBoard / Message | `VoiceMessagesVC` | T3 | Spec 2.11 Sent |
| SchoolDashBoard / Message | `VoiceMessageVc` | T5 | Spec 2.11 |
| SchoolDashBoard / MsgFrmManagement | `MessageFromManagementViewController` | T4 | † |
| SchoolDashBoard / MsgFrmManagement | `MsgViewVC` | T4 | † |
| SchoolDashBoard / NoticeBoard | `NoticeBoardVc` | T3 | † |
| SchoolDashBoard / NoticeBoard | `SenderNoticeBoardVC` | T3 | † |
| SchoolDashBoard / Online Meeting | `OnlineMeetingVC` | T4 | † |
| SchoolDashBoard / PTM | `CreateMeetingVc` | T5 | Spec 2.24 |
| SchoolDashBoard / PTM | `CreateSlotsBottomVC` | T9 | Spec 2.24 |
| SchoolDashBoard / PTM | `NewPtmVC` | T3 | Spec 2.24 |
| SchoolDashBoard / PTM | `PopupVC` | T9 | † |
| SchoolDashBoard / PTM | `SlotListVC` | T3 | Spec 2.24 |
| SchoolDashBoard / PendingFeeReport | `PendingFeeReportViewController` | T6 | † |
| SchoolDashBoard / Quiz | `CreateQuizQutionVc` | T5 | Spec 2.27 |
| SchoolDashBoard / Quiz | `QuistionPagenationVc` | T4 | † |
| SchoolDashBoard / Quiz | `QuizSubmissionVc` | T3 | † |
| SchoolDashBoard / Quiz | `ReportsQuizVc` | T6 | † |
| SchoolDashBoard / Quiz | `SenderQuizVc` | T3 | Spec 2.27 |
| SchoolDashBoard / ReuseViews | `ContactUsVc` | T4 | Spec 2.9 |
| SchoolDashBoard / ReuseViews | `FAQViewController` | T4 | Spec 2.9 |
| SchoolDashBoard / ReuseViews | `HelpVc` | T4 | Spec 2.9 |
| SchoolDashBoard / ReuseViews | `LanguageVc` | T7 | Spec 2.9 |
| SchoolDashBoard / ReuseViews | `LogoutViewController` | T9 | Spec 2.9 |
| SchoolDashBoard / ReuseViews | `NotificationCallVC` | T8 | Incoming school voice call, full screen |
| SchoolDashBoard / ReuseViews | `NotificationViewController` | T3 | Spec 2.10 |
| SchoolDashBoard / ReuseViews | `RateUsViewController` | T9 | Spec 2.9 |
| SchoolDashBoard / ReuseViews | `ReportBugVcViewController` | T5 | Spec 2.9 |
| SchoolDashBoard / ReuseViews | `SettingsViewController` | T4 | Spec 2.9 |
| SchoolDashBoard / ReuseViews | `TapBarVC` | Container | Tabs: Home, Inbox, Calendar, Profile |
| SchoolDashBoard / ReuseViews | `UpdateProfileVC` | T4 | Spec 2.9 |
| SchoolDashBoard / Schedule Exam | `ExamCreatVC` | T4 | † |
| SchoolDashBoard / Schedule Exam | `ScheduleExamsList` | T3 | † |
| SchoolDashBoard / Schedule Exam | `ScheduleExamVC` | T5 | † |
| SchoolDashBoard / Schedule Exam | `SchedulePopupVC` | T9 | † |
| SchoolDashBoard / SchoolStrength | `SchoolStrengthVC` | T6 | † |
| SchoolDashBoard / Sender Attachment | `AttachHistroyVC` | T4 | † |
| SchoolDashBoard / Sender Attachment | `SenderAttachmentVC` | T3 | † |
| SchoolDashBoard / SenderLSRW | `LSRWPreviewVC` | T4 | † |
| SchoolDashBoard / SenderLSRW | `LSRWSubmissionVC` | T3 | † |
| SchoolDashBoard / SenderLSRW | `LSRWVC` | T4 | † |
| SchoolDashBoard / SenderLSRW | `SelectedLSRWSubmissionVC` | T3 | † |
| SchoolDashBoard / SenderLSRW | `SenderLSRWVC` | T5 | † |
| SchoolDashBoard / SheduleExam | `SelectSubjectVc` | T7 | Spec 2.23 |
| SchoolDashBoard / SnderLeaveRequest | `SenderLeaveRqstVC` | T3 | Spec 2.25 |
| SchoolDashBoard / SnderLeaveRequest | `StaffDetailsPreviewVc` | T4 | † |
| SchoolDashBoard / StaffWiseAttendace | `StaffWiseAttendaceVC` | T4 | † |
| SchoolDashBoard / StudentAttendanceReport | `NewAbsenteesViewController` | T6 | † |
| SchoolDashBoard / StudentReport | `ReportStudentListVC` | T3 | Spec 2.18 |
| SchoolDashBoard / StudentReport | `StudentFeeDetailsVC` | T4 | Spec 2.19 |
| SchoolDashBoard / StudentReport | `StudentFeeImageViewerVC` | T8 | Proof image viewer |
| SchoolDashBoard / StudentReport | `StudentFeeProofDetailVC` | T4 | Not linked yet |
| SchoolDashBoard / StudentReport | `StudentFeeProofListVC` | T3 | Not linked yet; matches Spec 2.20 proof history |
| SchoolDashBoard / StudentReport | `StudentReportDashboardVC` | Remove | Not reachable (student tap opens fee details) |

**Screens listed:** 207. By template: Container 4, Remove 12, T1 7, T2 2, T3 51, T4 44, T5 30, T6 14, T7 15, T8 7, T9 21.
