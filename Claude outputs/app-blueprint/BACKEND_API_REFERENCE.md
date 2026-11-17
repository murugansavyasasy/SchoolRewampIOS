# Backend API Reference

Generated from the iOS source (every `AppConstant` endpoint string and every `makeApi` call site). It describes the contract the app expects. The server code was not available, so request bodies are taken from what the app sends and response shapes from the Swift `Codable` models it decodes into.

## Conventions

| Item | Value |
|---|---|
| Base host (`isBaseUrl: true`) | `https://apiv8.schoolchimes.net/` (India region; region chosen from `app/api/setup/countries`) |
| Report host (`isBaseUrl: false`) | `https://reportv8.schoolchimes.net/` |
| Pauket host | `https://api.pauket.com/api/partner/` (partner key in header — keep server-side in a new app) |
| Headers | `Accept: Application/json`, `Content-Type: Application/json`, `Authorization: <access_token>` (raw token, no `Bearer`) |
| GET params | query string |
| POST/PUT body | JSON |
| Envelope | `{ "status": true/false, "message": "...", "data": [ ... ] }` — `data` is almost always an array, even for one object |
| Token | one `access_token` per staff record / per child record from `validate-user`; the token selects the school, role and child |
| Failure | `status:false` + `message` shown as a toast; an invalid/expired token returns `status:false`; the app has no special handling — it re-runs `validate-user` on every launch, which issues fresh tokens |

Legend — **Host**: `base`, `report` or `pauket`. **Method** marked "(shared sender)" means the call goes through `com_SendingAPI` (create = POST, update = PUT) so the method was not a literal at the call site. **Unused** = constant exists but no screen calls it.

## Endpoint count by service

| Service prefix | Area | Endpoints |
|---|---|---|
| `app` | App setup & authentication | 11 |
| `dashboard` | Dashboard, menus, reconcile, reviews, Pauket | 12 |
| `comm` | Communication (messages, homework, assignments, interaction, leave, certificates, recipients) | 67 |
| `admin` | Administration (notice board, events, profiles, concerns, reports) | 24 |
| `exam` | Exams & marks | 23 |
| `fee` | Fees | 7 |
| `lms` | Learning (lesson plan, LSRW, quiz, timetable) | 31 |
| `ptm` | Parent-teacher meetings | 12 |
| `stud-attd` | Student & hostel attendance | 18 |
| `staff-attd` | Staff attendance (geo-fenced) | 10 |
| `transport` | Transport / bus tracking | 3 |
| `ocr` | OCR mark upload | 1 |
| `pauket` | Pauket rewards partner (external host) | 6 |
| **Total** | | **224** |

## `app` — App setup & authentication

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `app/api/auth/device-token` | POST | base | mobile_number, device_token, device_type, secure_id, device_info, manufacturer, model, device, brand, os_version, app_version | DeviceTokenResponseSuc | CustomDashboard, CustomParentDashboardVC |
| `app/api/auth/logout` | POST | base | mobile_number, device_type, secure_id | CommonApiSuc | LogoutViewController |
| `app/api/auth/validate-otp` | POST | base | mobile_number, otp | ValidateOTPSuc | OTPVc |
| `app/api/auth/validate-user` | POST | base | mobile_number, device_type, secure_id, password | UserValidationResponseSuc | LoginVc, MobileNumberVc, PasswordVc, SplashVC |
| `app/api/cred/change-password` | POST | base | mobile_number, new_password, old_password | ResetPasswordSuc | CreatePasswordVc |
| `app/api/cred/create-new-password` | POST | base | mobile_number, new_password | CreateNewPasswordSuc | CreatePasswordVc |
| `app/api/cred/forgot-password` | POST | base | mobile_number | ForgotPasswordResponeSuc | LoginVc, OTPVc, PasswordVc |
| `app/api/cred/reset-password` | POST | base | mobile_number, new_password | ResetPasswordSuc | CreatePasswordVc |
| `app/api/global/global-variables` | POST | report | key_names | GlobalVariablesResponse | CustomDashboard, CustomParentDashboardVC |
| `app/api/setup/countries` | GET | base | — | CountryListSuccess | CountryListVC |
| `app/api/setup/version-check` | POST | report | device_type, version_code, country_id, mobile_number, school_id | VersionCheckResponse | SplashVC, SplashViewController |

## `dashboard` — Dashboard, menus, reconcile, reviews, Pauket

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `dashboard/api/dashboard/delete-notification` | PUT | base | id | notificationSuc | NotificationViewController |
| `dashboard/api/dashboard/faqs` | GET | report | — | FAQResponse | FAQViewController |
| `dashboard/api/dashboard/features` | GET | base | — | IntroResponse | OnboardingVC |
| `dashboard/api/dashboard/menu-counts` | GET | report | member_type | MenuCountResponse | CustomDashboard, CustomParentDashboardVC |
| `dashboard/api/dashboard/menus` | GET | report | member_type, mobile_number, language_code | MenuResponse | CustomDashboard, CustomParentDashboardVC |
| `dashboard/api/dashboard/new-updates` | GET | report | role_type | UpdateResponse | WhatsNewVc |
| `dashboard/api/dashboard/notifications` | GET | report | device_type | notificationSuc | NotificationViewController |
| `dashboard/api/pauket/add-points` | POST | base | target_type, target_code, subject_id, class_id, open_to_student, mobile_number, activity, user_type, menu_id | EventResponse | ApplyLeaveReqVC, AssignmentListVC, AssignmentPriview, AttendanceMarkingVC |
| `dashboard/api/reconcile/online-payment-details-for-student` | GET | report | country_id | transactionDataSuc | FeeDetails |
| `dashboard/api/reconcile/update-unreceived-payment-status-for-student` | POST | base | id | SecondCommonApiSuc | FeeDetails |
| `dashboard/api/reviews/add` | POST | base | mobile_number, rating, description, categories | ValidateOTPSuc | RateUsViewController |
| `dashboard/api/reviews/list` | GET | report | mobile_number | ReviewResponse | RateUsViewController |

## `comm` — Communication (messages, homework, assignments, interaction, leave, certificates, recipients)

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `comm/api//leave-req-for-staff/list` (note: double slash in the app constant — use `comm/api/leave-req-for-staff/list`) | GET | report | staff_id | LeaveInfoResponse | SenderLeaveRqstVC, StaffDetailsPreviewVc |
| `comm/api/assignment/delete` | PUT | base | id | ResetPasswordSuc, Send_AttachmentResponse | AssignmentReport |
| `comm/api/assignment/delete-submission` | PUT | base | id | ResetPasswordSuc | AssignmentSummitionVC |
| `comm/api/assignment/list` | GET | report | — | AssignmentReportResponse | AssignmentListVC |
| `comm/api/assignment/list-archive` | ? | ? | — | — | **Unused** |
| `comm/api/assignment/my-submissions` | GET | report | id | SubmissionResponse | AssignmentSummitionVC |
| `comm/api/assignment/report` | GET | report | academic_year_id | AssignmentReportResponse | AssignmentReport |
| `comm/api/assignment/send-assignment` | POST (shared sender) | base | — | — | RecipientVc, StudentHistryVC |
| `comm/api/assignment/submissions-list` | GET | report | id, type | StudentSubmissionResponse | AssignmentPriview, SubmitedAssignmentVC |
| `comm/api/assignment/submit-assignment` | POST (update-submission = PUT) | base | id, description, iframe, file_size, file_path | Send_AttachmentResponse | SubmitVC |
| `comm/api/assignment/target-details` | GET | report | id, target_type | targetSuc | PreviewTargetTVC |
| `comm/api/assignment/update` | PUT (shared sender) | base | — | — | SenderAssignmentTextViewController |
| `comm/api/assignment/update-submission` | PUT (shared sender) | base | id, description, iframe, file_size, file_path | Send_AttachmentResponse | SubmitVC |
| `comm/api/attachment/delete` | PUT | base | id | ResetPasswordSuc | AttachHistroyVC |
| `comm/api/attachment/list` | GET | report | — | AttachmentsResponse | AttachmentsVc |
| `comm/api/attachment/list-archive` | GET | report | — | AttachmentsResponse | AttachmentsVc |
| `comm/api/attachment/report` | GET | report | — | AttachmentsResponse | AttachHistroyVC |
| `comm/api/attachment/send-attachment` | POST (shared sender) | base | — | — | RecipientVc, SchoolListVC, StudentHistryVC |
| `comm/api/attachment/target-details` | GET (inferred) | report (inferred) | — | — | AttachHistroyVC |
| `comm/api/attachment/update` | PUT (shared sender) | base | — | — | SenderAttachmentVC |
| `comm/api/certificate/request-list` | GET | report | — | CertificateResponse | certificateReqVc |
| `comm/api/certificate/send-request` | POST | base | requested_for, urgency_level, reason | ChangePasswordSuc | certificateReqVc |
| `comm/api/certificate/types` | GET | report | — | ResetPasswordSuc | certificateReqTVCell |
| `comm/api/communication/list` | GET | report | — | CommunicationReciverResponse | ParentCommunicationVc |
| `comm/api/communication/list-archive` | GET | report | — | CommunicationReciverResponse | ParentCommunicationVc |
| `comm/api/communication/read-status-update` | POST | base | type, detail_id | CommonApiSuc, ReadStatusResponse | AssignmentPriview, AttachmentsVc, IntractwithStudentVc, LSRWActivitesVC |
| `comm/api/communication/read-status-update-archive` | POST | base | type, detail_id | ReadStatusResponse | AttachmentsVc, MessageFromManagementViewController, ParentCommunicationVc |
| `comm/api/homework/delete` | PUT | base | id | ResetPasswordSuc | SenderHomeWorkVC |
| `comm/api/homework/list` | GET | report | date | HomeworListkResponse | homeWorkVc |
| `comm/api/homework/list-archive` | ? | ? | — | — | **Unused** |
| `comm/api/homework/mark-complete` | PUT | base | — | CommonApiSuc | PrivewVc |
| `comm/api/homework/report` | GET | report | section_id, date, academic_year_id | HomeworkResponse | SenderHomeWorkVC |
| `comm/api/homework/send-homework` | POST (shared sender) | base | — | — | RecipientVc |
| `comm/api/homework/submissions-list` | GET | report | id | HomeWorkSubmissionList | PrivewVc |
| `comm/api/homework/update` | PUT (shared sender) | base | — | — | SenderSideHomeWorkViewController |
| `comm/api/interaction/block-student` | PUT | base | student_id, is_block, reason, class_id, section_id, class_name, section_name | CommonApiSuc | IntractwithStudentVc, chatWithStudentVc |
| `comm/api/interaction/blocked-students` | GET | report | — | BlockedStudentsResponse | IntractwithStudentVc |
| `comm/api/interaction/classes-for-chat` | GET | report | — | StaffListResponse | IntractwithStudentVc |
| `comm/api/interaction/get-staff-answers` | GET | report | staff_id, subject_id, offset, is_class_teacher | ChatMessageSuc | ChatVC |
| `comm/api/interaction/staff-ans-question` | POST | base | question_id, answer, reply_type, is_change_answer, file_path | StaffAnswerResponse | chatWithStudentVc |
| `comm/api/interaction/staff-details-for-chat` | GET | report | — | StaffListResponse | InteractionVC |
| `comm/api/interaction/staff-get-questions` | GET | report | section_id, subject_id, offset, is_class_teacher | StaffChatResponse | chatWithStudentVc |
| `comm/api/interaction/student-ask-question` | POST | base | staff_id, subject_id, question, is_class_teacher, file_path | MessageSuc | ChatVC |
| `comm/api/leave-req-for-staff/apply` | POST | base | leave_from, leave_to, reason, f_session, t_session, leave_type | CommonApiSuc | ApplyLeaveReqVC |
| `comm/api/leave-req-for-staff/delete` | PUT | base | id | CommonApiSuc | SenderLeaveRqstVC |
| `comm/api/leave-req-for-staff/leave-categories` | GET | report | — | LeaveTypesResponse | ApplyLeaveReqVC |
| `comm/api/leave-req-for-staff/update` | PUT | base | id, leave_from, leave_to, reason, f_session, t_session, leave_type | CommonApiSuc | ApplyLeaveReqVC |
| `comm/api/leave-req-for-staff/update-status` | PUT | base | id, is_approve | CommonApiSuc | **Unused** |
| `comm/api/leave-req/apply` | POST | base | leave_from, leave_to, reason, f_session, t_session, leave_type | CommonApiSuc | LeveCreateVC |
| `comm/api/leave-req/delete` | PUT | base | id | CommonApiSuc | LeveHistoryVC |
| `comm/api/leave-req/leave-categories` | GET | report | — | LeaveTypesResponse | LeveCreateVC |
| `comm/api/leave-req/list` | GET | report | member_type | LeaveInfoResponse | LeveHistoryVC, SenderLeaveRqstVC |
| `comm/api/leave-req/update` | PUT | base | id, leave_from, leave_to, reason, f_session, t_session, leave_type | CommonApiSuc | LeveCreateVC |
| `comm/api/leave-req/update-status` | PUT | base | id, is_approve | CommonApiSuc | SenderLeaveRqstVC |
| `comm/api/msg-from-management/get-messages-staff` | GET | report | — | MessageFromManagementResp | MessageFromManagementViewController |
| `comm/api/msg-from-management/get-messages-staff-archive` | GET | report | — | MessageFromManagementResp | MessageFromManagementViewController |
| `comm/api/recipient/get-academic-year-list` | GET | report | — | get_academic_yearSuc | CustomDashboard, ExamReportsVC, HostelDashBoardVc, LocationHistoryVc |
| `comm/api/recipient/get-group-list` | GET | report | academic_year_id | GrouplistSuc | RecipientVc |
| `comm/api/recipient/get-staff-list` | GET | report | — | GetStafflistSuc | LocationHistoryVc, RecipientVc, StaffWiseAttendaceVC |
| `comm/api/recipient/get-standards` | GET | report | academic_year_id | GetStandardsSuc, TestStandardResponse | CreateMeetingVc, CreateTestViewModel, ExamAnaylzeSelectionVc, MarkAttendenceVC |
| `comm/api/recipient/get-student-list` | GET | report | section_id, academic_year_id | GetStudentlistSuc | ExamAnaylzeSelectionVc, StudentHistryVC |
| `comm/api/recipient/get-subject-list` | GET | report | section_ids | GetSubjectlistSuc | RecipientVc |
| `comm/api/text-message/get-text-history` | GET | report | — | TextDetailsResponse | ComunicationVC, TextMessageVC |
| `comm/api/text-message/send-text` | POST | base | content, title, target_code, target_type, academic_year_id | CommonApiSuc | RecipientVc, SchoolListVC, StudentHistryVC |
| `comm/api/voice/get-voice-history` | GET | report | — | VoiceResponse | ComunicationVC, VoiceMessageVc, VoiceMessagesVC |
| `comm/api/voice/send-voice` | POST | base (inferred) | voice_link, target_type, target_code, duration, title, is_emergency, is_schedule, schedule_date, start_time, end_time, file_name, circular_type, academic_year_id | — | RecipientVc, SchoolListVC, StudentHistryVC |
| `comm/api/voice/update-notification-call-log` | POST | base | ei1, ei2, ei3, ei4, ei5, receiver_id, circular_id, duration, start_time, end_time, retry_count, phone, diallist_id, call_status, url | CommonApiSuc | NotificationCallVC |

## `admin` — Administration (notice board, events, profiles, concerns, reports)

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `admin/api/get-school-strength` | GET | report | academic_year_id | SchoolStrengthResponse | SchoolStrengthVC |
| `admin/api/get-student-report` | GET | report | academic_year_id, class_id, section_id | StudentReportResponse | ReportStudentListVC |
| `admin/api/notice-board/delete` | PUT | base | id | ResetPasswordSuc | NoticeBoardVc |
| `admin/api/notice-board/get-notice` | GET | report | — | NoticeResponse | NoticeBoardVc, ReciverNoticeBoardVC |
| `admin/api/notice-board/report` | GET | report | — | NoticeResponse | NoticeBoardVc |
| `admin/api/notice-board/send-notice` | POST | base | title, description, target_code, intended_for, visible_from, visible_to, file_path | NoticeResponse | SchoolListVC |
| `admin/api/notice-board/update` | PUT (shared sender) | base | — | — | SenderNoticeBoardVC |
| `admin/api/parent-concern/action-taken` | PUT | base | concern_id, action, action_taken, action_file_path, student_id, description | CommonApiSuc | addConcernVc, concernListVc |
| `admin/api/parent-concern/delete` | PUT | base | id | CommonApiSuc | concernListVc |
| `admin/api/parent-concern/get-concern-types` | GET | report | — | concernRespSuc | addConcernVc |
| `admin/api/parent-concern/get-concerns` | GET | report | — | ConcernResponse | concernListVc |
| `admin/api/parent-concern/raise-concern` | POST | base | concern_type_id, raised_to, description, file_path | CommonApiSuc | addConcernVc |
| `admin/api/school-event/categories` | GET | report | — | EventCategoryResponse | EventsVC |
| `admin/api/school-event/delete` | PUT | base | id | ResetPasswordSuc | EventHistoryVC |
| `admin/api/school-event/get-event` | GET | report | — | EventResponse | EventResiverVC |
| `admin/api/school-event/report` | GET | report | — | EventResponse | EventHistoryVC |
| `admin/api/school-event/send-event` | POST (shared sender) | base | — | — | RecipientVc |
| `admin/api/school-event/target-details` | GET (inferred) | report (inferred) | — | — | EventHistoryVC |
| `admin/api/school-event/update` | PUT (shared sender) | base | — | — | EventsVC |
| `admin/api/school-event/view-holidays` | GET | report | — | EventHolidayResponse | HolidayVC |
| `admin/api/staff-profile/list` | GET | report | — | UserProfileResponse | UpdateProfileVC |
| `admin/api/student-profile/list` | GET | report | — | UserProfileResponse | UpdateProfileVC |
| `admin/api/student-profile/pre-submission` | POST | base | — | Send_AttachmentResponse | UpdateProfileVC |
| `admin/api/student-profile/update-profile` | POST | report | file_path, student_id | GetStandardsSuc | ReportStudentListVC |

## `exam` — Exams & marks

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `exam/api/exam-new/common-remarks` | GET | report | standard_id | CommonRemarksResponse | EnterMarkVC |
| `exam/api/exam-test/analysis-sets-list` | GET | report | class_id, section_id | analysisRespSuc | selectExamVc |
| `exam/api/exam-test/class-test-details` | GET | report | class_test_id, exam_date, academic_year_id | StaffClassTestResponse | ExamReportsVC |
| `exam/api/exam-test/class-tests-for-student` | GET | report | — | ClassTestResponse | ParentClassTestVc |
| `exam/api/exam-test/create-class-test` | POST (shared sender) | base | — | SlotValidationResponse | SelectReviewViewController |
| `exam/api/exam-test/delete` | PUT | base | class_test_id | — | ExamReportsVC |
| `exam/api/exam-test/delete-class-test-subject` | PUT | base | class_test_subject_id | CommonApiSuc | ExamRecordsVC |
| `exam/api/exam-test/mark-details` | GET | report | class_test_id, class_test_subject_id, section_id | — | CreateTestViewModel |
| `exam/api/exam-test/publish-marks` | ? | ? | — | — | **Unused** |
| `exam/api/exam-test/section-wise-subjects` | GET | report | section_ids | TestSubjectsResponse | CreateTestViewModel |
| `exam/api/exam-test/student-analysis` | GET | report | student_id, analysis_set_id | AnalysisResponse | anaylizesVc |
| `exam/api/exam-test/upload-marks` | POST | base | class_test_id, section_id, is_publish, subjects | Send_AttachmentResponse | CreateTestViewModel |
| `exam/api/exam-test/view-marks-for-student` | GET | report | class_test_id | ClassTestMarksResponse | MarksDetailsViewController |
| `exam/api/exam/get-exams` | ? | ? | — | — | **Unused** |
| `exam/api/exam/list` | ? | ? | — | — | **Unused** |
| `exam/api/new-exam/get-exams` | GET | report | — | NewExamResponseSuc | ExamTmTblVCViewController |
| `exam/api/new-exam/get-mark-details` | GET | report | report_id | ExamMarksResponse | MarkListVC |
| `exam/api/new-exam/get-marks-to-upload-details` | POST | report | — | MarkDetailsResponse | EnterMarkVC |
| `exam/api/new-exam/get-report-status` | GET | report | — | ExamListResponse | ExameMarVC |
| `exam/api/new-exam/get-staffwise-exam` | GET | report | section_id, academic_year_id | StaffExamListResponse | ExamListVC |
| `exam/api/new-exam/get-student-progresscard` | POST | base | report_id, type | examSucApi | ExameMarVC |
| `exam/api/new-exam/get-subject-activities` | GET | report | exam_id, section_id | SubjectWiseExamResponse | ExamActivitySelectionVC, ExamListVC |
| `exam/api/new-exam/upload-exam-mark` | POST | base | — | Send_AttachmentResponse | EnterMarkVC |

## `fee` — Fees

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `fee/api/fee-details/invoice-details` | GET | report | invoice_id | CommonApiSuc | FeeDetails |
| `fee/api/fee-details/payment-proof` | GET | report | country_id | PaymentProofAPIResponse | paymentProofVc |
| `fee/api/fee-details/student-fee-details` | GET | report | student_id, country_id, academic_year_id | StaffFeeProofResponse, StudentFeeDetailsResponse | StudentFeeDetailsVC, StudentFeeProofListVC |
| `fee/api/fee-details/student-invoice` | GET | report | — | InvoiceDetailsResponse | FeeDetails |
| `fee/api/fee-report/daily-collection` | GET | report | from_date, to_date, type, country_id | DailyCollectionResponse | NewDailyCollectionViewController |
| `fee/api/fee-report/detailed-class-wise-pending-report` | GET | report | academic_year_id, country_id | PendingReportsResponse | PendingFeeReportViewController |
| `fee/api/fee-report/detailed-pending-report` | GET | report | academic_year_id, country_id | PendingReportsResponse | PendingFeeReportViewController |

## `lms` — Learning (lesson plan, LSRW, quiz, timetable)

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `lms/api/lesson-plan/add` | POST (shared sender) | base | particular_id, request_type | CommonApiSuc | EditLessonVC |
| `lms/api/lesson-plan/delete` | PUT | base | particular_id | CommonApiSuc | ViewLessonVC |
| `lms/api/lesson-plan/get-data-for-add` | GET | base | request_type | LessonEditResponse | ViewLessonVC |
| `lms/api/lesson-plan/get-data-for-edit` | GET | report | particular_id, request_type | LessonEditResponse | EditLessonVC, ViewLessonVC |
| `lms/api/lesson-plan/staff-report` | GET | report | request_type | LessonPlanStaffReportResponse | LessonPlanVC |
| `lms/api/lesson-plan/update` | PUT (shared sender) | base | particular_id, request_type | CommonApiSuc | EditLessonVC |
| `lms/api/lesson-plan/view` | GET | report | section_subject_id, lesson_plan_status | LessonPlanDetailResponse | ViewLessonVC |
| `lms/api/lsrw/create-skill` | POST (shared sender) | base | — | — | RecipientVc |
| `lms/api/lsrw/delete` | PUT | base | id | ResetPasswordSuc | LSRWVC |
| `lms/api/lsrw/my-submissions` | GET | report | id | LSWSubmissionResponse | LSRWActivitesVC |
| `lms/api/lsrw/remark` | PUT | base | — | Send_AttachmentResponse | LSRWSubmisionListVC |
| `lms/api/lsrw/skill-list` | GET | report | — | LSRWListResponse | LsrwListShowViewController |
| `lms/api/lsrw/skills-report` | GET | report | — | LSRWReportResponse | LSRWVC |
| `lms/api/lsrw/stats` | GET | report | month_id | SkillResponse | SelectedLSRWSubmissionVC |
| `lms/api/lsrw/submission-list` | GET | report | id | LSWSubmissionResponse | LSRWPreviewVC |
| `lms/api/lsrw/submit-skill` | POST | base | — | Send_AttachmentResponse | LSRWActivitesVC |
| `lms/api/quiz/add-question` | POST | base | — | QuizaddQuestionSuc | CreateQuizQutionVc |
| `lms/api/quiz/check-level` | GET | report | class_id, subject_id | checkQuizLevelSuc | RecipientVc |
| `lms/api/quiz/create-quiz` | POST | base | target_type, target_code, subject_id, class_id, open_to_student | CommonApiSuc | RecipientVc |
| `lms/api/quiz/delete` | PUT | base | id | CommonApiSuc | ReportsQuizVc |
| `lms/api/quiz/delete-question` | PUT | base | id | CommonApiSuc | CreateQuizQutionVc |
| `lms/api/quiz/get-questions` | GET | base | id | QuizQuestionSuc | NewPlayQuizVC |
| `lms/api/quiz/my-submissions` | GET | report | id, student_id | MyQuizSuc | QuizCompletedVc |
| `lms/api/quiz/pick-from-qbank` | GET | report | subject_id | QuestionsResponse | CreateQuizQutionVc |
| `lms/api/quiz/questions-report` | GET | report | id | QuizaddQuestionSuc | CreateQuizQutionVc |
| `lms/api/quiz/quiz-exam-list` | GET | report | type, status_type | QuizListSuc | QuizVC |
| `lms/api/quiz/report` | GET | report | type | senderQuizListSuc | ReportsQuizVc |
| `lms/api/quiz/submission-list` | GET | report | id | QuizStudentReportSuc | QuizSubmissionVc |
| `lms/api/quiz/submit` | PUT | base | id, answers | CommonApiSuc | NewPlayQuizVC |
| `lms/api/quiz/update` | PUT | base | id, title, description | CommonApiSuc | SenderQuizVc |
| `lms/api/time-table/get-schedule` | GET | report | day_id | TimetableResponse | TimetableBottomVC |

## `ptm` — Parent-teacher meetings

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `ptm/api/ptm-schedule/available-slots-count-for-student` | GET | report | — | AvailableSlotsResponse | PtmParentVC |
| `ptm/api/ptm-schedule/book-slots-for-student` | PUT | base | slot_ids | CommonApiSuc | PtmParentVC |
| `ptm/api/ptm-schedule/cancel-and-close-slot` | PUT | base | slot_ids | CommonApiSuc | NewPtmVC, SlotListVC |
| `ptm/api/ptm-schedule/cancel-and-reopen-slot` | PUT | base | slot_id | CommonApiSuc | NewPtmVC, SlotListVC |
| `ptm/api/ptm-schedule/cancel-slot-by-student` | PUT | base | slot_id, cancelled_reason | CommonApiSuc | PtmHistoryVC |
| `ptm/api/ptm-schedule/create-slots` | POST (shared sender) | base | — | CommonApiSuc | CreateSlotsBottomVC |
| `ptm/api/ptm-schedule/datewise-booked-slots` | GET | report | event_date | BookedSlotsResponse | NewPtmVC |
| `ptm/api/ptm-schedule/slot-details-for-staff` | GET | report | event_date | PTMSlotResponse | NewPtmVC |
| `ptm/api/ptm-schedule/slot-history-for-student` | GET | report | — | SlotDetailsResponse | PtmHistoryVC |
| `ptm/api/ptm-schedule/subject-list-with-class-teacher` | GET | report | — | SubjectListResponse | PtmParentVC |
| `ptm/api/ptm-schedule/teacherwise-slots-availability-for-student` | GET | report | event_date, subject_id, class_teacher_id, is_management | StudentSlotResponse | PtmParentVC |
| `ptm/api/ptm-schedule/validate-slots-for-staff` | POST (`PtmApi` helper) | report | — | SlotValidationResponse | CreateMeetingVc |

## `stud-attd` — Student & hostel attendance

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `stud-attd/api/attendance/get-absent-dates-for-child` | GET | report | — | StudentAttendanceResponse | NewAttendanceReportVC |
| `stud-attd/api/attendance/get-absentees-count-by-date` | GET | report | month_id, year_id | AbsenteesResponse | NewAbsenteesViewController |
| `stud-attd/api/attendance/get-absentees-students-by-date` | GET | report | absent_on, section_id, standard_id | AbsentisReportStudentResponse | NewAbsenteesViewController |
| `stud-attd/api/attendance/send-absentees-sms-with-session-type` | POST | base | class_id, section_id, all_present, attendance_type, session_type, attendance_date, student_details, student_id | CommonApiSuc | AttendanceMarkingVC, MarkAttendenceVC, StudentHistryVC |
| `stud-attd/api/attendance/student-attendance-report` | GET | report | from_date, to_date, standard_id, section_id | AttendanceReportResponse | MarkAttendenceVC |
| `stud-attd/api/attendance/student-list` | GET | report | section_id, class_id, date, attendance_type, academic_year_id | AttendanceStudentListResponse | AttendanceMarkingVC |
| `stud-attd/api/attendance/student-stats` | GET | report | — | StudentStatisticsResponse | ReciverAttendanceReportVC |
| `stud-attd/api/hostel-attendance/apply-outpass` | POST | base | hostel_id, room_id, out_date, in_date, emergency_contact, reason | CommonApiSuc | NewOutpassRequestVC |
| `stud-attd/api/hostel-attendance/attendance-report` | GET | report | hostel_id, academic_year_id, date | AttendanceHistoryResponse | AttendanceHistoryViewController |
| `stud-attd/api/hostel-attendance/hostel-info` | GET | report | — | HostelDetailsResponse | parentHostelDashboardVC |
| `stud-attd/api/hostel-attendance/hostel-list` | GET | report | — | HostelListSuc | HostelListVc |
| `stud-attd/api/hostel-attendance/mark-attendance` | POST | base | hostel_id, session_type_id, attendance_date, room_id, academic_year_id, student_details | HostelSessionListSuc | MarkAttendanceViewController |
| `stud-attd/api/hostel-attendance/outpass-report` | GET | report | year_id, month_id, hostel_id, academic_year_id | OutpassResponseSuc | OutpassRequestsViewController |
| `stud-attd/api/hostel-attendance/parent-dashboard-new` | GET | report | hostel_id, year_id, month_id, country_id | HostelDashboardResponse | parentHostelDashboardVC |
| `stud-attd/api/hostel-attendance/room-details` | GET | report | hostel_id, academic_year_id | HostelDashBoardSuc | HostelDashBoardVc |
| `stud-attd/api/hostel-attendance/session-types` | GET | base | — | HostelSessionListSuc | MarkAttendanceViewController |
| `stud-attd/api/hostel-attendance/students-for-hostel-attd` | GET | base | session_type_id, hostel_id, room_id, academic_year_id, date | HostelStudentListSuc | MarkAttendanceViewController |
| `stud-attd/api/hostel-attendance/update-status` | PUT | base | id, is_approve | CommonApiSuc | MarkAttendanceViewController, OutpassRequestsViewController |

## `staff-attd` — Staff attendance (geo-fenced)

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `staff-attd/api/geometric/entry-using-app` | POST | base | device_id, PunchStringFile.device_model, punch_type, staff_or_student | CommonApiSuc | LocationViewController |
| `staff-attd/api/geometric/geometric-principal-attendance-report` | GET | report | — | StaffAttendanceResponse | LocationHistoryVc |
| `staff-attd/api/geometric/geometric-principal-attendance-report-date-wise` | GET | report | from_date, to_date, staff_id, is_all | StaffAttendanceResponseSuc | StaffWiseAttendaceVC |
| `staff-attd/api/geometric/geometric-punch-history` | GET | report | from_date, to_date, staff_id | PunchHistoryResponse | PunchHistoryListVC |
| `staff-attd/api/geometric/geometric-staff-attendance-report` | GET | report | attendance_dt | StaffAttendanceResponse | LocationReportVC |
| `staff-attd/api/geometric/get-geometric-location-history` | GET | report | — | StaffGeometricLocation | AddLocationHistory |
| `staff-attd/api/geometric/get-staff-geometric-location` | GET | report | — | StaffGeometricLocation | LocationViewController |
| `staff-attd/api/geometric/remove-geometric-location` | POST | base | location_id | StaffGeometricLocation | AddLocationHistory |
| `staff-attd/api/geometric/set-geometric-location` | POST | base | location, longitude, latitude, distance | StaffGeometricLocation | CreateLocationViewController |
| `staff-attd/api/geometric/update-geometric-location` | POST | base | — | StaffGeometricLocation | AddLocationHistory |

## `transport` — Transport / bus tracking

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `transport/api/get-latest-geo-location` | GET | report | device_id, vehicle_id, route_id | GeoLocationResponse | BusTrakingVC |
| `transport/api/get-student-route-list` | GET | report | — | StudentRouteDetailsResponse | busListVC |
| `transport/api/get-vehicle-live-tracking-details` | GET | report | journey_type | livebusDetails | whereismybusVc |

## `ocr` — OCR mark upload

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `ocr/api/upload-marks` | POST multipart image (`uploadImageApi`) | base (inferred) | — | MarksAIresponse | ExamImgUploadVC |

## `pauket` — Pauket rewards partner (external host)

| Path | Method | Host | Request fields | Response model | Used by |
|---|---|---|---|---|---|
| `activate_coupon` | POST | pauket | source_link, mobile_no | ActivateCouponResponse | BottomView |
| `get-Points` | ? | pauket | — | — | **Unused** |
| `get_campaign_details` | GET/POST | pauket | source_link, mobile_no | CampaignResponse | BottomView, CooponViewVC |
| `get_campaigns` | POST | pauket | — | CampaignsResponse | HomePaucktVC |
| `get_category_list` | GET | pauket | — | CategoriesResponse | HomePaucktVC |
| `my_coupons` | POST | pauket | mobile_no, coupon_status | MyCouponResponse | ReedimHistoryVc |

## Shared "send" payload (`com_SendingAPI`)

Used by circulars, notice board, homework, assignments, events, attachments, voice, text messages and message-from-management.

| Field | Meaning |
|---|---|
| `id` | 0/omitted on create; record id on update (PUT) |
| `title`, `description` | text content |
| `file_type`, `file_path`, `file_size` | attachment metadata; file already uploaded to S3/Vimeo |
| `iframe` | Vimeo embed for video |
| `target_type` | 1 school · 2 standard · 3 section · 4 group · 5 student · 6 staff |
| `target_code` | ids of the selected targets |
| `academic_year_id` | current academic year |
| `venue`, `event_date`, `event_time` | events only |
| `intended_for`, `visible_from`, `visible_to` | audience and visibility window |

Response: `Send_AttachmentResponse` (`status`, `message`, `data`). Circular type codes used in list filters: school `A`, standard `C`, section `S`, group `G`, `student`, `staff`.

## Third-party services the backend/app depend on

| Service | Purpose | Note for a new app |
|---|---|---|
| AWS S3 | file storage; app asks `get-s3-presigned-url` then PUTs the file | presigned URLs must be generated server-side |
| Vimeo | video upload/stream | move the upload token to the server |
| Firebase Cloud Messaging | push notifications; device token registered after login | new Firebase project per app |
| Google Maps / MapLibre | bus tracking, geo attendance | new API keys |
| Pauket | rewards / coupons | partner key must not ship in the app |
