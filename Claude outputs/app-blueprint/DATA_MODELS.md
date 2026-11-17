# Data Models

All 474 `Codable`/`Decodable` types the app decodes from (or encodes to) the backend, extracted from the Swift source. Field names are the JSON keys (`CodingKeys` applied). Every field is optional in the app (`?`), so the server may omit any of them; a rebuilt app should stay equally lenient.

## Key models (read these first)

### Login — `app/api/auth/validate-user` → `UserValidationResponseSuc`

```
data[0]
├─ otp_sent: Bool            # true → go to OTP screen
├─ message, more_info, dial_numbers   # help text + support numbers
└─ user_details: UserDetails
   ├─ is_staff, is_parent: Bool
   ├─ staff_role, role_name     # p1 group head · p2 principal · p3 staff · p4 admin · p5 non-teaching
   ├─ max_*_sms_count, max_*_voice_duration, image_count   # sending limits
   ├─ staff_details: [StaffDetails]   # one per school the person works at
   │    staff_id, emp_id, school_id, school_name, school_logo, role, priority_level,
   │    is_payment_pending, biometric_enable, allow_video_download, gps_type, access_token
   └─ child_details: [ChildDetails]   # one per child of this mobile number
        child_id, standard_name, section_name, class_id, section_id, school_id, school_name,
        academic_year_id, academic_year_name, roll_number, is_not_allow, gps_type, access_token
```

### Dashboard — `dashboard/api/dashboard/menus` → `MenuResponse`

```
data[0]
├─ is_birthday: Bool
├─ contact_details: { alert_title, alert_message, alert_content, display_name, numbers, button_content }
├─ frequently_used: [MenuDetail]
└─ menus: [MenuDetail]        # { id, name, unread_count, description }  — id decides the screen
```

`menu-counts` returns the same `contact_details` plus `menu_details: [{id, name, unread_count}]` for badge refresh.

### Generic envelope

```json
{ "status": true, "message": "Fetched", "data": [ { ... } ] }
```

## All models by area

### Core/ApiService/Model.swift (shared models)

- **CountryListSuccess** — `status`: Bool?, `message`: String?, `data`: [CountryData]?
- **CountryData** — `id`: Int?, `name`: String?, `code`: Int?, `mobile_number_length`: Int?, `mobile_no_hint`: String?, `base_url`: String?, `reporting_url`: String?, `flag_url`: String?
- **VersionCheckResponse** — `status`: Bool?, `message`: String?, `data`: [VersionData]?
- **VersionData** — `update_available`: Bool?, `force_update`: Bool?, `new_version`: String?, `new_version_updates`: String?, `country_details`: CountryData?, `toaster_title`: String?, `play_store_market_id`: String?, `play_store_link`: String?, `app_store_link`: String?, `description`: String?, `is_rate_as`: Bool?
- **UserValidationResponseSuc** — `status`: Bool?, `message`: String?, `data`: [UserData]?
- **UserData** — `is_number_exists`: Bool?, `is_password_updated`: Bool?, `otp_sent`: Bool?, `message`: String?, `more_info`: String?, `dial_numbers`: String?, `user_details`: UserDetails?
- **UserDetails** — `is_staff`: Bool?, `staff_role`: String?, `role_name`: String?, `staff_details`: [StaffDetails]?, `is_parent`: Bool?, `child_details`: [ChildDetails]?, `max_general_sms_count`: Int?, `max_homework_sms_count`: Int?, `max_emergency_voice_duration`: Int?, `max_general_voice_duration`: Int?, `max_hw_voice_duration`: Int?, `image_count`: Int?
- **StaffDetails** — `name`: String?, `staff_id`: String?, `emp_id`: String?, `mobile_no`: String?, `address`: String?, `email`: String?, `blood_group`: String?, `staff_profile`: String?, `school_id`: String?, `school_name`: String?, `school_name_regional`: String?, `school_city`: String?, `school_logo`: String?, `role`: String?, `priority_level`: String?, `is_payment_pending`: String?, `schedule_call_type`: Int?, `biometric_enable`: Bool?, `allow_video_download`: Bool?, `school_address`: String?, `access_token`: String?, `gps_type`: String?
- **ChildDetails** — `name`: String?, `child_id`: String?, `standard_name`: String?, `section_name`: String?, `school_name`: String?, `school_name_regional`: String?, `school_city`: String?, `school_logo_url`: String?, `profile`: String?, `roll_number`: String?, `display_message`: String?, `access_token`: String?, `school_id`: String?, `address`: String?, `class_id`: Int?, `section_id`: Int?, `email`: String?, `father_name`: String?, `mother_name`: String?, `father_occupation`: String?, `mother_occupation`: String?, `blood_group`: String?, `secondary_mobile`: String?, `whatsapp_number`: String?, `class_teacher`: String?, `academic_year_id`: Int?, `academic_year_name`: String?, `is_not_allow`: Bool?, `gps_type`: String?
- **ValidateOTPSuc** — `status`: Bool?, `message`: String?, `data`: [String]?
- **ChangePasswordSuc** — `status`: Bool?, `message`: String?, `data`: [String]?
- **ForgotPasswordResponeSuc** — `status`: Bool?, `message`: String?, `data`: [ForgotPasswordData]?
- **ForgotPasswordData** — `dial_numbers`: String?, `more_info`: String?, `forgot_otp_message`: String?
- **ResetPasswordSuc** — `status`: Bool?, `message`: String?, `data`: [String]?
- **CreateNewPasswordSuc** — `status`: Bool?, `message`: String?, `data`: [String]?
- **GlobalVariablesResponseSuc** — `status`: Bool?, `message`: String?, `data`: [GlobalVariablesData]?
- **GlobalVariablesData** — `new_version`: String?, `new_updates`: String?
- **DeviceTokenResponseSuc** — `status`: Bool?, `message`: String?, `data`: [String]?
- **GrouplistSuc** — `status`: Bool?, `message`: String?, `data`: [GroupDetail]?
- **GroupDetail** — `id`: String?, `name`: String?, `created_on`: String?, `isSelect`: Bool?
- **GetStandardsSuc** — `status`: Bool?, `message`: String?, `data`: [StandardDetail]?
- **StandardDetail** — `id`: String?, `name`: String?, `sections`: [sectionsDetail]?, `isSelect`: Bool?
- **sectionsDetail** — `id`: String?, `name`: String?, `isSelect`: Bool?
- **GetStudentlistSuc** — `status`: Bool?, `message`: String?, `data`: [StudentDetails]?
- **StudentDetails** — `id`: String?, `name`: String?, `admission_no`: String?, `roll_no`: String?, `isSelect`: Bool?, `isAbsent`: Bool?
- **GetSubjectlistSuc** — `status`: Bool?, `message`: String?, `data`: [GetSubjectDetails]?
- **GetSubjectDetails** — `id`: String?, `name`: String?, `isSelect`: Bool?
- **GetStafflistSuc** — `status`: Bool?, `message`: String?, `data`: [GetStaffDetails]?
- **GetStaffDetails** — `id`: String?, `name`: String?, `emp_id`: String?, `designation`: String?, `isSelect`: Bool?
- **DashboardResponse** — `status`: Bool?, `message`: String?, `data`: [DashboardData]?
- **DashboardData** — `contact_details`: ContactDetails?, `menu_details`: [MenuDetail]?
- **ContactDetails** — `alert_message`: String?, `alert_content`: String?, `alert_title`: String?, `display_name`: String?, `numbers`: String?, `button_content`: String?
- **MenuDetail** — `id`: Int?, `name`: String?, `unread_count`: Int?, `description`: String?
- **MenuResponse** — `status`: Bool?, `message`: String?, `data`: [MenuData]?
- **MenuCountResponse** — `status`: Bool?, `message`: String?, `data`: [MenuCount]?
- **MenuCount** — `contact_details`: ContactDetails?, `menu_details`: [MenuCountDetail]?
- **MenuCountDetail** — `id`: Int?, `name`: String?, `unread_count`: Int?
- **MenuData** — `is_birthday`: Bool?, `contact_details`: ContactDetails?, `frequently_used`: [MenuDetail]?, `menus`: [MenuDetail]?
- **CommonApiSuc** — `status`: Bool?, `message`: String?, `data`: [String]?
- **examSucApi** — `status`: Bool?, `message`: String?, `data`: [linkdata]?
- **linkdata** — `link`: String?
- **SecondCommonApiSuc** — `status`: Bool?, `message`: String?, `data`: [String]?
- **VoiceResponse** — `status`: Bool?, `message`: String?, `data`: [VoiceData]?
- **VoiceData** — `file_path`: String?, `url`: String?, `title`: String?, `sent_on`: String?, `school_id`: String?, `header_id`: String?, `duration`: Int?, `playDruration`: Double?, `isPlaying`: Bool?
- **TextDetailsResponse** — `status`: Bool?, `message`: String?, `data`: [TextDetail]?
- **TextDetail** — `id`: String?, `title`: String?, `content`: String?, `date`: String?, `isExpand`: Bool?
- **HomeworkResponse** — `status`: Bool?, `message`: String?, `data`: [Homework]?
- **Homework** — `title`: String?, `description`: String?, `subject_name`: String?, `sent_by`: String?, `file_path`: [FilePath]?, `is_completed`: Bool?, `id`: String?, `is_unread`: Bool?, `detail_id`: String?, `can_edit`: Bool?, `can_delete`: Bool?, `created_on`: String?, `date`: String?
- **HomeworListkResponse** — `status`: Bool?, `message`: String?, `data`: [Homework]?
- **HomeworkList** — `date`: String?, `completed_count`: Int?, `homework`: [Homework]?
- **FilePath** — `url`: String?, `type`: String?, `playbackSeconds`: Double?, `isBase64`: Bool
- **AwsResps** — `status`: Int, `message`: String, `data`: AwsData?
- **AwsData** — `presignedUrl`: String, `fileUrl`: String
- **CommunicationReciverResponse** — `status`: Bool?, `message`: String?, `data`: [CommunicationReciverData]?
- **CommunicationReciverData** — `type`: String?, `id`: String?, `header_id`: String?, `content`: String?, `title`: String?, `date`: String?, `time`: String?, `sender_info`: String?, `is_emergency`: Bool?, `is_unread`: Bool?, `isExpand`: Bool?, `is_archive`: Bool?, `duration`: Int?, `playbackSeconds`: Double?, `loadFile`: Bool?, `sent_by`: String?
- **ReadStatusResponse** — `status`: Bool, `message`: String, `data`: [String]
- **get_academic_yearSuc** — `status`: Bool?, `message`: String?, `data`: [AcadimicYearData]?
- **AcadimicYearData** — `id`: Int?, `year`: String?, `current_academic_year`: Bool?
- **Send_AttachmentResponse** — `status`: Bool, `message`: String, `data`: [String]
- **AttachmentsResponse** — `status`: Bool?, `message`: String?, `data`: [Attachment]?
- **Attachment** — `id`: String?, `type`: String?, `title`: String?, `description`: String?, `date`: String?, `time`: String?, `sender_info`: String?, `sent_by`: String?, `header_id`: String?, `is_unread`: Bool?, `is_archive`: Bool?, `file_path`: [FilePath]?, `iframe`: String?, `can_edit`: Bool?, `can_delete`: Bool?, `isExpanded`: Bool?, `school_id`: String?, `target_type`: String?
- **AttachmentFilePath** — `path`: String?, `type`: String?
- **StaffAttendanceResponse** — `status`: Bool?, `message`: String?, `data`: [StaffAttendance]?
- **StaffAttendance** — `name`: String?, `staff_id`: String?, `date`: String?, `leave_type`: String?, `designation`: String?, `role`: String?, `attendance_type`: [String:, `in_time`: String?, `out_time`: String?, `working_hours`: String?
- **attendanceType** — `FD`: String?, `FH`: String?, `SH`: String?
- **PunchHistoryResponse** — `status`: Bool?, `message`: String?, `data`: [PunchList]?
- **PunchList** — `date`: String?, `timings`: [puchHistoryList]?
- **puchHistoryList** — `time`: String?, `punch_type`: punchType?, `device_model`: String?, `device_id`: String?
- **punchType** — `id`: Int?, `value`: String?
- **StaffGeometricLocation** — `status`: Bool?, `message`: String?, `data`: [GeometricLocation]?
- **GeometricLocation** — `id`: Int?, `latitude`: String?, `longitude`: String?, `location`: String?, `distance`: String?, `time`: String?, `visitedCount`: String?
- **DailyCollectionResponse** — `status`: Bool?, `message`: String?, `data`: [CollectionReportData]?
- **CollectionReportData** — `collections`: [DailyCollectionData]?, `total_collection`: String?
- **DailyCollectionData** — `category`: String?, `total`: String?, `fee_data`: [FeeData]?
- **FeeData** — `type_name`: String?, `amount`: String?
- **NoticeResponse** — `status`: Bool?, `message`: String?, `data`: [Notice]?
- **Notice** — `id`: String?, `title`: String?, `description`: String?, `created_on`: String?, `day`: String?, `visible_from`: String?, `visible_to`: String?, `intended_for`: String?, `is_management`: Bool?, `file_path`: [FilePath]?, `iframe`: String?, `file_size`: String?, `thumbnail`: String?, `sent_by`: String?, `can_edit`: Bool?, `can_delete`: Bool?, `school_id`: String?, `school_name`: String?
- **AttendanceReportResponse** — `status`: Bool?, `message`: String?, `data`: [AttenenceReportData]?
- **AttenenceReportData** — `holiday_message`: String?, `attd_report`: [AttendanceDataList]?
- **AttendanceDataList** — `student_name`: String?, `admission_no`: String?, `att_status`: String?, `absent_on`: String?, `roll_no`: String?
- **StudentStatisticsResponse** — `status`: Bool?, `message`: String?, `data`: [StudentStatistics]?
- **StudentStatistics** — `total_working_days`: Double?, `present_days`: Double?, `absent_days`: Double?, `absent_limit`: Double?, `completed_working_days`: Double?, `upcoming_working_days`: Double?, `attendance_percentage`: String?, `weekly_status`: WeeklyStatus?
- **WeeklyStatus** — `start`: String?, `end`: String?, `student_name`: String?, `att_list`: [String]?
- **EventResponse** — `status`: Bool?, `message`: String?, `data`: [EventSection]?
- **EventSection** — `categories`: [EventCategory]?, `on_going`: [EventList]?, `up_coming`: [EventList]?, `completed`: [EventList]?
- **EventCategoryResponse** — `status`: Bool, `message`: String, `data`: [EventCategory]
- **EventCategory** — `id`: Int?, `name`: String?, `url`: String?
- **EventList** — `id`: String?, `title`: String?, `category`: String?, `description`: String?, `school_id`: String?, `date`: String?, `time`: String?, `venue`: String?, `iframe`: String?, `file_size`: String?, `thumbnail`: String?, `sent_by`: String?, `can_edit`: Bool?, `can_delete`: Bool?, `file_path`: [FilePath]?
- **PendingReportsResponse** — `status`: Bool?, `message`: String?, `data`: [PendingReportData]?
- **PendingReportData** — `pending_details`: [PendingDetail]?, `total_pending`: String?
- **PendingDetail** — `category`: String?, `total`: String?, `pending_data`: [FeeData]?
- **StudentReportResponse** — `status`: Bool, `message`: String, `data`: [StudentData]
- **StudentData** — `id`: String, `name`: String, `primary_mobile`: String?, `admission_no`: String, `email`: String?, `profile`: String, `roll_no`: String, `gender`: String, `dob`: String, `class_id`: String, `class_name`: String, `section_id`: String, `section_name`: String, `father_name`: String, `class_teacher`: String, `is_profile_edit`: Bool
- **EventHolidayResponse** — `status`: Bool?, `message`: String?, `data`: [EventHolidayData]?
- **EventHolidayData** — `name`: String?, `year`: String?, `date`: String?
- **SchoolStrengthResponse** — `status`: Bool?, `message`: String?, `data`: [SchoolStrength]?
- **SchoolStrength** — `previous`: Previous?, `total_student_strength`: String?, `total_staff_strength`: String?, `total_male_staffs_strength`: String?, `total_female_staffs_strength`: String?, `total_other_staffs_strength`: String?, `total_boys_strength`: String?, `total_girls_strength`: String?, `total_others_strength`: String?, `standards`: [Standard]?
- **Previous** — `total_student_strength`: String?, `total_male_staffs_strength`: String?, `total_female_staffs_strength`: String?, `total_other_staffs_strength`: String?, `total_boys_strength`: String?, `total_girls_strength`: String?, `total_others_strength`: String?, `total_staff_strength`: String?, `message`: String?
- **Standard** — `id`: String?, `name`: String?, `level`: String?, `boys_count`: String?, `girls_count`: String?, `other_count`: String?, `total_students`: String?, `sections`: [SectionList]?
- **SectionList** — `name`: String?, `level`: String?, `id`: String?, `boys_count`: String?, `girls_count`: String?, `others_count`: String?, `total_students`: String?
- **StudentAttendanceResponse** — `status`: Bool?, `message`: String?, `data`: [StudentAttendance]?
- **StudentAttendance** — `date`: String?, `day`: String?, `type`: String?, `is_Archive`: Bool?
- **AbsenteesResponse** — `status`: Bool?, `message`: String?, `data`: [AbsenteeDate]?
- **AbsenteeDate** — `date`: String?, `day`: String?, `absent_date_only`: String?, `total_absentees`: String?, `class_wise`: [ClassWise]?
- **ClassWise** — `class_id`: String?, `student_counts`: String?, `class_name`: String?, `total_absentees`: String?, `section_wise`: [SectionWise]?
- **SectionWise** — `section_id`: String?, `section_name`: String?, `total_absentees`: String?, `student_counts`: String?
- **AbsentisReportStudentResponse** — `status`: Bool, `message`: String, `data`: [AbsentisReportStudent]
- **AbsentisReportStudent** — `student_id`: String?, `student_name`: String?, `roll_no`: String?, `admission_no`: String?, `photo_path`: String?, `primary_mobile`: String?, `gender`: String?, `attd_status`: String?
- **LeaveTypesResponse** — `status`: Bool?, `message`: String?, `data`: [LeaveType]?
- **LeaveType** — `id`: Int?, `name`: String?, `leave_name`: String?
- **LeaveInfoResponse** — `status`: Bool?, `message`: String?, `data`: [LeaveMonth]?
- **LeaveMonth** — `month`: String?, `details`: [LeaveInfo]?
- **LeaveInfo** — `id`: String?, `staff_id`: String?, `applied_on`: String?, `staff_name`: String?, `student_name`: String?, `class_name`: String?, `section_name`: String?, `leave_from`: String?, `leave_to`: String?, `no_of_days`: String?, `reason`: String?, `status`: String?, `updated_on`: String?, `from_session`: String?, `to_session`: String?, `approved_by`: String?, `leave_type`: String?, `from_date`: String?, `to_date`: String?, `leave_type_id`: FlexibleString?, `status_id`: String?, `role`: String?, `mobile_no`: String?, `email`: String?, `address`: String?, `created_by_own`: Bool?
- **FlexibleString** — `value`: String?
- **SubmissionResponse** — `status`: Bool?, `message`: String?, `data`: [Submission]?
- **Submission** — `id`: String?, `description`: String?, `title`: String?, `submitted_on`: String?, `file_path`: [FilePath]?
- **LessonPlanStaffReportResponse** — `status`: Bool, `message`: String, `data`: [LessonPlanStaffReport]
- **LessonPlanStaffReport** — `section_subject_id`: String, `staff_name`: String, `class_name`: String, `section_name`: String, `subject_name`: String, `completed_items`: String, `total_items`: String, `percentage_value`: Int, `items_completed`: String
- **LessonPlanDetailResponse** — `status`: Bool, `message`: String, `data`: [LessonPlanDetail]
- **LessonPlanDetail** — `particular_id`: String, `lesson_plan_status`: Int, `details`: [LessonDetailItem]
- **LessonDetailItem** — `name`: String?, `value`: String?
- **LessonEditResponse** — `status`: Bool?, `message`: String?, `data`: [LessonEditData]?
- **LessonEditData** — `id`: String?, `name`: String?, `field_id`: String?, `value`: String?, `field_type`: String?, `field_name`: String?, `field_data`: [String]?, `is_disable`: Bool?
- **ActivateCouponResponse** — `status`: Bool?, `message`: String?, `data`: CouponDetails?
- **CouponDetails** — `coupons`: [Coupons]?, `merchant_logo`: String?, `offer`: String?, `redirect_url`: String?, `isCTAvalid`: Bool?, `CTAname`: String?, `CTAredirect`: String?
- **Coupons** — `coupon_code`: String?, `qr_code`: String?, `expiry_date`: String?
- **CampaignResponse** — `status`: Bool?, `message`: String?, `data`: CampaignDetailsData?
- **CampaignDetailsData** — `campaign_details`: CampaignDetails?
- **CampaignDetails** — `campaign_name`: String?, `expiry_date`: String?, `cover_image`: String?, `merchant_name`: String?, `threshold_amount`: String?, `offer_text`: String?, `offer_type`: String?, `discount`: Int?, `how_to_use`: String?, `terms_and_conditions`: String?, `merchant_logo`: String?, `campaign_type`: String?, `coupon_valid_for`: String?, `customer_buys_value`: String?, `customer_gets_value`: String?, `template_file`: String?, `offer_to_show`: String?, `expiry_type`: String?, `points`: String?
- **CampaignsResponse** — `status`: Bool?, `message`: String?, `data`: CampaignData?
- **CampaignData** — `total_count`: Int?, `campaigns`: CampaignPagination?
- **CampaignPagination** — `current_page`: Int?, `data`: [Campaign]?, `first_page_url`: String?, `from`: Int?, `next_page_url`: String?, `path`: String?, `per_page`: String?, `prev_page_url`: String?, `to`: Int?
- **Campaign** — `temp_id`: Int?, `source_link`: String?, `campaign_name`: String?, `campaign_type`: String?, `threshold_amount`: String?, `offer_text`: String?, `thumbnail`: String?, `expiry_date`: String?, `end_date`: String?, `offer_type`: String?, `discount`: Int?, `merchant_name`: String?, `category_name`: String?, `category_image`: String?, `points`: String?, `merchant_logo`: String?, `offer_to_show`: String?, `coupon_status`: String?, `coupon_code`: String?, `isCTAvalid`: Bool?
- **CategoriesResponse** — `status`: Bool?, `message`: String?, `data`: CategoryData?
- **CategoryData** — `categories`: [Categorys]?, `total_pages`: Int?
- **Categorys** — `id`: Int?, `category_name`: String?, `category_image`: String?
- **MyCouponResponse** — `status`: Bool?, `data`: CouponData?, `message`: String?
- **CouponData** — `coupon_list`: CouponList?, `total_pages`: Int?
- **CouponList** — `first_page_url`: String?, `next_page_url`: String?, `current_page`: Int?, `from`: Int?, `to`: Int?, `path`: String?, `data`: [Coupon]?
- **Coupon** — `qr_code`: String?, `campaign_type`: String?, `CTAname`: String?, `merchant_name`: String?, `expiry_date`: String?, `cover_image`: String?, `industry_name`: String?, `coupon_status`: String?, `source_link`: String?, `template_files`: [String]?, `expires_in`: Int?, `merchant_id`: Int?, `discount`: Int?, `offer_type`: String?, `id`: Int?, `category_name`: String?, `location_list`: [Location]?, `about_merchant`: String?, `coupon_code`: String?, `offer_to_show`: String?, `expiry_type`: String?, `campaign_name`: String?, `merchant_logo`: String?, `cta_url`: String?, `isCTAvalid`: Bool?, `CTAredirect`: String?, `how_to_use`: String?, `terms_and_conditions`: String?
- **Location** — `longitude`: String?, `latitude`: String?, `location_name`: String?
- **GetCoinResponse** — `status`: Int?, `message`: String?, `data`: GetCoinData?
- **GetCoinData** — `pointsEarned`: Int?, `pointsSpent`: Int?, `pointsRemaining`: Int?, `pointsPerCoupon`: Int?
- **AssignmentReportResponse** — `status`: Bool?, `message`: String?, `data`: [Report]?
- **Report** — `id`: String?, `header_id`: String?, `title`: String?, `description`: String?, `category`: String?, `subject`: String?, `date`: String?, `time`: String?, `school_id`: String?, `school_name`: String?, `recipient_type`: String?, `target_type`: String?, `created_date`: String?, `created_time`: String?, `progress`: Float?, `submitted_count`: Int?, `total_count`: Int?, `end_date`: String?, `is_unread`: Bool?, `sent_by`: String?, `can_edit`: Bool?, `can_delete`: Bool?, `sort_order`: String?, `is_archive`: Bool?, `iframe`: String?, `file_size`: String?, `thumbnail`: String?, `file_path`: [FilePath]?
- **StudentSubmissionResponse** — `status`: Bool?, `message`: String?, `data`: [StudentSubmission]?
- **StudentSubmission** — `student_id`: String?, `student_name`: String?, `standard`: String?, `section`: String?, `submit_status`: String?, `is_archive`: Bool?, `submissions_details`: [SubmissionDetail]?
- **SubmissionDetail** — `id`: String?, `description`: String?, `submitted_on`: String?, `created_on`: String?, `iframe`: String?, `file_size`: String?, `file_path`: [FilePath]?
- **MessageFromManagementResp** — `status`: Bool?, `message`: String?, `data`: [ManagemantMessageData]?
- **StaffListResponse** — `status`: Bool?, `message`: String?, `data`: [StaffMember]?
- **StaffMember** — `id`: String?, `name`: String?, `is_blocked`: Bool?, `reason`: String?, `blocked_on`: String?, `profile`: String?, `subject_id`: String?, `subject_name`: String?, `is_assigned`: Bool?, `is_class_teacher`: Bool?, `unread_count`: Int?, `last_msg_time`: String?, `last_msg`: String?, `section_id`: String?, `section_name`: String?
- **ChatMessageSuc** — `status`: Bool?, `message`: String?, `data`: [ChatMessage]?
- **ChatMessage** — `question_id`: String?, `question`: String?, `student_id`: String?, `student_name`: String?, `asked_on`: String?, `quesfilepath`: [MediaFile]?, `reply_type`: String?, `answer`: String?, `answered_on`: String?, `ansfilepath`: [MediaFile]?, `chat_count`: Int?, `my_question`: Bool?
- **StaffChatResponse** — `status`: Bool?, `message`: String?, `data`: [StaffChatMessage]?
- **StaffChatMessage** — `id`: String?, `question`: String?, `student_id`: String?, `student_name`: String?, `is_blocked`: Bool?, `reason`: String?, `created_on`: String?, `chat_count`: Int?, `ques_file_path`: [String]?, `answer`: String?, `answer_on`: String?, `change_answer`: Bool?, `ans_file_path`: [String]?, `reply_type`: String?
- **BlockedStudentsResponse** — `status`: Bool?, `message`: String?, `data`: [BlockedStudent]?
- **BlockedStudent** — `id`: String?, `name`: String?, `gender`: String?, `blocked_on`: String?, `class_name`: String?, `section_name`: String?, `class_id`: String?, `section_id`: String?, `reason`: String?
- **MediaFile** — `url`: String, `type`: String
- **MessageSuc** — `status`: Bool?, `message`: String?, `data`: [MessageSucResp]?
- **MessageSucResp** — `id`: String?, `name`: String?, `section_id`: String?, `question`: String?, `created_on`: String?, `chat_count`: Int?, `file_path`: [String]?
- **StaffAnswerResponse** — `status`: Bool?, `message`: String?, `data`: [AnswerData]?
- **AnswerData** — `question_id`: String?, `answer`: String?, `answer_on`: String?, `reply_type`: String?, `created_on`: String?, `file_path`: [MediaFile]?
- **ManagemantMessageData** — `type`: String?, `id`: String?, `header_id`: String?, `title`: String?, `description`: String?, `content`: String?, `file_path`: [FilePath]?, `iframe`: String?, `file_size`: String?, `thumbnail`: String?, `date`: String?, `time`: String?, `sender_info`: String?, `sent_by`: String?, `role`: String?, `school_id`: String?, `school_name`: String?, `is_unread`: Bool?, `is_archive`: Bool?, `is_emergency`: Bool?, `duration`: Int?, `order_date`: String?, `isExpand`: Bool?
- **TimetableResponse** — `status`: Bool?, `message`: String?, `data`: [TimetableHour]?
- **TimetableHour** — `name`: String?, `start_time`: String?, `end_time`: String?, `duration`: String?, `order`: Int?, `hour_type`: String?, `subject_name`: String?, `staff_name`: String?, `facalty_name`: String?
- **CertificateResponse** — `status`: Bool?, `message`: String?, `data`: [CertificateRequest]?
- **CertificateRequest** — `url`: String?, `type`: String?, `reason`: String?, `urgency_level`: String?, `requested_on`: String?, `status`: String?, `issued_on`: String?, `message`: String?
- **DetailedExamListResponse** — `status`: Bool?, `message`: String?, `data`: [DetailedExamItem]?
- **DetailedExamItem** — `id`: String?, `name`: String?, `description`: String?, `created_on`: String?, `exam_subject_details`: [SubjectDetail]?
- **SubjectDetail** — `subject_name`: String?, `exam_date`: String?, `exam_session`: String?, `max_mark`: String?, `syllabus`: String?, `start_time`: String?, `end_time`: String?
- **ExamListResponse** — `status`: Bool?, `message`: String?, `data`: [ExamItem]?
- **ExamItem** — `report_id`: Int?, `reportName`: String?, `report_sent`: Bool?, `mark_sent`: Bool?, `type`: String?
- **ExamMarksResponse** — `status`: Bool?, `message`: String?, `data`: [ExamData]?
- **ExamData** — `subject_marks`: [SubjectMark]?, `assessments`: [Assessment]?, `groups`: [Groups]?, `is_unread`: Bool?
- **SubjectMark** — `name`: String?, `split`: [SplitMark]?, `max_mark`: String?, `mark_obtained`: String?, `percentage`: String?
- **SplitRubricMark** — `name`: String?, `max_mark`: String?, `mark_obtained`: String?
- **SplitMark** — `name`: String?, `max_mark`: String?, `mark_obtained`: String?, `rubrics`: [SplitRubricMark]?
- **Assessment** — `Rank`: String?, `Total`: String?, `PresentDays`: String?, `TotalWorkingDays`: String?, `Remarks`: String?, `percentage`: String?, `total_mark`: String?, `total_obtained`: String?, `grade`: String?, `message`: String?
- **Groups** — `name`: String?, `mark`: String?, `subjects`: [SubGroup]?
- **SubGroup** — `name`: String?, `mark`: String?
- **FileData** — `url`: String, `type`: String
- **LSRW** — `title`: String, `description`: String, `subject`: String, `submitedOn`: String, `duration`: String, `recording`: String, `iframe`: String, `type`: String, `filePath`: [FileData], `test`: [TestQuestion]
- **SkillListResponse** — `status`: Bool?, `message`: String?, `data`: [SkillData]?
- **SkillData** — `id`: String?, `detail_id`: String?, `title`: String?, `description`: String?, `activity_type`: String?, `subject`: String?, `date`: String?, `time`: String?, `submitted_date`: String?, `is_submitted`: Bool?, `is_unread`: Bool?, `sent_by`: String?, `iframe`: String?, `file_size`: String?, `thumbnail`: String?, `file_path`: [FilePath]?, `test`: [TestQuestion]?, `duration`: String?
- **TestQuestion** — `question`: String, `options`: [String]
- **PTMSlotResponse** — `status`: Bool, `message`: String, `data`: [SlotDateData]?
- **SlotDateData** — `today`: [EventGroup]?, `upcoming`: [EventGroup]?, `completed`: [EventGroup]?
- **EventGroup** — `details`: [SlotEventDetail]?
- **SlotEventDetail** — `date`: String?, `start_time`: String?, `end_time`: String?, `event_name`: String?, `event_mode`: String?, `meeting_duration`: Int?, `break_duration`: Int?, `profiles`: [String]?, `slots`: [SlotItem]?, `std_sec_details`: [ClassSectionDetail]?, `event_link`: String?
- **SlotItem** — `slot_id`: String?, `from_time`: String?, `to_time`: String?, `is_cancelled`: Bool?, `is_booked`: Bool?, `booked_by`: String?, `my_class`: String?, `my_section`: String?, `profile_url`: String?, `mobile_no`: String?, `status`: String?, `event_name`: String?, `event_mode`: String?, `meeting_duration`: Int?, `break_duration`: Int?, `is_cancelled_by_staff`: Bool?, `date`: String?, `sent_by`: String?, `can_cancel`: Bool?, `father_name`: String?, `mother_name`: String?, `event_link`: String?
- **ClassSectionDetail** — `class_id`: String?, `section_id`: String?, `class_name`: String?, `section_name`: String?
- **BookedSlotsResponse** — `status`: Bool, `message`: String, `data`: [BookedSlotsData]
- **BookedSlotsData** — `today`: [BookedSlot]?, `upcoming`: [BookedSlot]?, `completed`: [BookedSlot]?
- **BookedSlot** — `slot_id`: String?, `date`: String?, `from_time`: String?, `to_time`: String?, `event_name`: String?, `event_mode`: String?, `event_link`: String?, `meeting_duration`: Int?, `sent_by`: String?, `student_id`: String?, `student_name`: String?, `father_name`: String?, `mother_name`: String?, `mobile_no`: String?, `class_id`: String?, `section_id`: String?, `class_name`: String?, `section_name`: String?, `slot_status`: String?, `is_booked`: Bool?, `profile_url`: String?, `can_cancel`: Bool?, `is_cancelled`: Bool?, `is_cancelled_by_staff`: Bool?
- **SlotValidationResponse** — `status`: Bool?, `message`: String?, `data`: [ValidatedSlotData]?
- **ValidatedSlotData** — `institute_id`: String?, `staff_id`: String?, `break_time`: Int?, `date`: String?, `duration`: Int?, `event_name`: String?, `meeting_mode`: String?, `from_time`: String?, `to_time`: String?, `slots`: [Slot]?, `std_sec_details`: [StdSecDetail]?
- **Slot** — `slot_from`: String?, `slot_to`: String?, `slot_availablity`: String?, `type`: Int?
- **StdSecDetail** — `class_id`: String?, `section_id`: String?
- **ValidatedSlot** — `slot_from`: String?, `slot_to`: String?, `type`: Int?, `slot_availablity`: String?
- **StudentSlotResponse** — `status`: Bool?, `message`: String?, `data`: [EventData]?
- **EventData** — `staff_id`: String?, `staff_name`: String?, `event_name`: String?, `subject_name`: String?, `start_time`: String?, `end_time`: String?, `slots`: [StudentSlot]?
- **StudentSlot** — `id`: String?, `slot_from`: String?, `slot_to`: String?, `is_booked`: Bool?, `staff_id`: String?, `staff_name`: String?, `subject_name`: [String]?, `event_name`: String?, `event_mode`: String?, `event_link`: String?, `my_booking`: Bool?, `userSelected`: Bool?, `is_conflictDisabled`: Bool?
- **SubjectListResponse** — `status`: Bool?, `message`: String?, `data`: [Subject]?
- **Subject** — `id`: String?, `name`: String?
- **SlotDetailsResponse** — `status`: Bool?, `message`: String?, `data`: [SlotCategory]?
- **SlotCategory** — `today`: [BookedSlotItem]?, `upcoming`: [BookedSlotItem]?, `completed`: [BookedSlotItem]?
- **BookedSlotItem** — `id`: String?, `date`: String?, `time`: String?, `status`: String?, `purpose`: String?, `mode`: String?, `event_link`: String?, `staff_id`: String?, `staff_name`: String?, `subject_name`: [String]?, `duration`: Int?, `staff_mobile_no`: String?, `is_cancelled_by_staff`: Bool?
- **AvailableSlotsResponse** — `status`: Bool?, `message`: String?, `data`: [AvailableSlot]?
- **AvailableSlot** — `event_date`: String?, `count`: String?
- **LSRWReportResponse** — `status`: Bool?, `message`: String?, `data`: [LSRWData]?
- **LSRWListResponse** — `status`: Bool?, `message`: String?, `data`: [LSRWTask]?
- **LSRWData** — `overview`: [Overview]?, `active`: [LSRWTask]?, `completed`: [LSRWTask]?
- **Overview** — `title`: String?, `value`: String?, `subtitle`: String?
- **LSRWTask** — `id`: String?, `detail_id`: String?, `title`: String?, `description`: String?, `sent_to`: String?, `activity_type`: LSRWType?, `subject`: String?, `date`: String?, `time`: String?, `submitted_date`: String?, `is_submitted`: Bool?, `is_unread`: Bool?, `sent_by`: String?, `created_on`: String?, `iframe`: String?, `file_size`: String?, `thumbnail`: String?, `file_path`: [FilePath]?, `test`: [TestQuestion]?, `submittedCount`: Int?, `totalCount`: Int?, `can_delete`: Bool?, `submitted_average`: String?
- **notificationSuc** — `status`: Bool?, `message`: String?, `data`: [notificationData]?
- **notificationData** — `menu_id`: Int?, `menu_name`: String?, `details`: [notificationDetails]?
- **notificationDetails** — `id`: String?, `name`: String?, `member_id`: String?, `type`: String?, `menu_id`: Int?, `message`: String?, `sent_on`: String?, `header_id`: String?, `device`: String?
- **QuizListSuc** — `status`: Bool?, `message`: String?, `data`: [QuizListData]?
- **senderQuizListSuc** — `status`: Bool?, `message`: String?, `data`: [senderQuizListData]?
- **QuizListData** — `id`: String?, `standard`: String?, `mark`: String?, `type_name`: String?, `submission_date`: String?, `section`: String?, `sent_time`: String?, `quiz_id`: String?, `title`: String?, `description`: String?, `max_mark`: Int?, `subject_id`: String?, `subject`: String?, `level`: Int?, `submitted_on`: String?, `created_on`: String?, `is_submitted`: Bool?, `is_unread`: Bool?, `SentBy`: String?, `sent_by`: String?, `no_of_questions`: Int?, `right_answer`: Int?, `wrong_answer`: Int?, `submitted_count`: Int?, `total_mark`: String?, `no_of_levels`: String?
- **QuizStudentReportSuc** — `status`: Bool?, `message`: String?, `data`: [QuizStudentReportData]?
- **QuizStudentReportData** — `id`: String?, `standard`: String?, `section`: String?, `student_name`: String?, `mobile_no`: String?, `is_submitted`: String?, `is_submit`: Bool?, `submitted_on`: String?, `student_id`: String?, `gender`: String?, `is_unread`: Bool?
- **senderQuizListData** — `id`: String?, `sent_time`: String?, `title`: String?, `description`: String?, `standard`: String?, `section`: String?, `level`: Int?, `level_flag`: Bool?, `subject_id`: String?, `subject`: String?, `sent_by`: String?, `submission_date`: String?, `mark`: String?, `type_name`: String?, `no_of_questions`: Int?, `submitted_count`: Int?, `can_edit`: Bool?, `can_delete`: Bool?, `open_to_student`: Bool?
- **QstDetail** — `id`: String?, `chapter`: String?, `question`: String?, `mark`: String?, `options`: [OptionsDeatil]?, `q_file_path`: [FilePath]?
- **OptionsDeatil** — `option`: String?, `value`: String?, `image`: String?
- **QuizQuestionSuc** — `status`: Bool?, `message`: String?, `data`: [QstDetail]?
- **QuizaddQuestionSuc** — `status`: Bool?, `message`: String?, `data`: [QuizQuestiondata]?
- **MyQuizSuc** — `status`: Bool?, `message`: String?, `data`: [myQuizDetails]?
- **myQuizDetails** — `message`: String?, `student_id`: String?, `right_answer`: String?, `wrong_answer`: String?, `un_answer`: String?, `quiz_details`: [MyQuizDetails]?
- **MyQuizDetails** — `id`: String?, `quiz_id`: String?, `question`: String?, `mark`: Int?, `student_answer`: String?, `correct_answer`: String?, `options`: [OptionsDeatil]?, `file_path`: [FilePath]?
- **QuizQuestiondata** — `id`: String?, `quiz_id`: String?, `chapter`: String, `question`: String, `answer`: String?, `a_option`: String, `b_option`: String, `c_option`: String, `d_option`: String, `mark`: Int?, `option_a_counts`: Int?, `option_b_counts`: Int?, `option_c_counts`: Int?, `option_d_counts`: Int?, `correct_answer_counts`: Int?, `incorrect_answer_counts`: Int?, `correct_answer_text`: String?, `q_file_path`: [FilePath]?, `a_image`: String?, `b_image`: String?, `c_image`: String?, `d_image`: String?, `ques_no`: String?
- **QuestionsResponse** — `status`: Bool?, `message`: String?, `data`: [QuestionItem]?
- **QuestionItem** — `id`: String?, `topic`: String?, `chapter`: String?, `class_id`: String?, `section_id`: String?, `subject_id`: String?, `level`: Int?, `question`: String?, `answer`: String?, `a_option`: String?, `b_option`: String?, `c_option`: String?, `d_option`: String?, `correct_answer_text`: String?, `mark`: Int?
- **SubmittedActivitiesResponse** — `status`: Bool?, `message`: String?, `data`: [SubmittedActivity]?
- **SubmittedActivity** — `id`: String?, `header_id`: String?, `submitted_date`: String?, `iframe`: String?, `file_size`: String?, `thumbnail`: String?, `file_path`: [FilePath]?
- **LSWSubmissionResponse** — `status`: Bool?, `message`: String?, `data`: [LSRWStudent]?
- **LSRWStudent** — `id`: String?, `student_id`: String?, `student_name`: String?, `standard`: String?, `description`: String?, `header_id`: String?, `remark`: String?, `section`: String?, `mobile_no`: String?, `submit_status`: String?, `submitted_date`: String?, `iframe`: String?, `file_size`: String?, `thumbnail`: String?, `file_path`: [FilePath]?
- **SkillResponse** — `status`: Bool, `message`: String, `data`: [PerformanceData]
- **PerformanceData** — `today_submitted`: [SkillSubmission]?, `listening`: SkillCategory?, `speaking`: SkillCategory?, `reading`: SkillCategory?, `writing`: SkillCategory?
- **SkillCategory** — `over_all_percentage`: String?, `student_count`: String?, `details`: [SkillSubmission]?
- **SkillSubmission** — `id`: String?, `title`: String?, `description`: String?, `activity_type`: String?, `sent_by`: String?, `subject`: String?, `submitted_average`: String?, `member_count`: Int?, `submission_date`: String?, `submitted_count`: Int?, `student_id`: String?, `student_name`: String?, `remark`: String?, `std_sec`: String?, `student_submited_on`: String?, `is_submitted`: Bool?, `file_path`: [FilePath]?, `created_on`: String?
- **UserProfileResponse** — `status`: Bool?, `message`: String?, `data`: [ProfileData]?
- **ProfileData** — `General`: [UserDetailItem]?, `Father Details`: [UserDetailItem]?, `Mother Details`: [UserDetailItem]?, `Communication`: [UserDetailItem]?, `Address`: [UserDetailItem]?, `Physical`: [UserDetailItem]?, `Identifiers`: [UserDetailItem]?, `Community`: [UserDetailItem]?, `Bank Details`: [UserDetailItem]?, `PhotoPath`: [UserDetailItem]?, `Documents`: [UserDetailItem]?, `TransportDetails`: [UserDetailItem]?
- **UserDetailItem** — `title`: String, `type`: UserDetailFieldType, `value`: String?, `is_editable`: Bool?, `optional`: Bool?, `options`: [String]?, `file_path`: [DocumentFile]?, `node`: String?
- **DocumentFile** — `documentPath`: String?, `documentName`: String?, `documentDisplayName`: String?, `isViewChange`: Int?
- **InvoiceDetailsResponse** — `status`: Bool?, `message`: String?, `data`: [InvoiceItem]?
- **InvoiceItem** — `id`: String?, `invoice_no`: String?, `invoice_date`: String?, `invoice_amount`: String?
- **TargetDetailsResponse** — `status`: Bool, `message`: String, `data`: [TargetDetail]?
- **TargetDetail** — `type`: String?, `name`: [TargetName]?
- **TargetName** — `institute`: [String]?, `standard`: [String]?, `group_name`: [String]?, `sections`: [String]?, `name`: String?
- **targetSuc** — `status`: Bool?, `message`: String?, `data`: [targetDataDetails]?
- **targetDataDetails** — `type`: String?, `name`: [targetInfoData]?
- **targetInfoData** — `institute`: [String]?, `standard`: [String]?, `group`: [String]?, `section`: [String]?, `name`: String?, `role`: String?, `sec`: String?, `std`: String?, `mobile`: String?
- **GlobalVariablesResponse** — `status`: Bool?, `message`: String?, `data`: [GlobalVariable]?
- **GlobalVariable** — `resend_otp_timer`: String?, `image_size`: String?, `pdf_size`: String?, `file_content`: String?, `video_size_limit`: String?, `video_size_limit_alert`: String?, `aws_access_key`: String?, `aws_secrete_key`: String?, `in_app_update`: String?, `offers_link`: String?, `alert_content`: String?, `aws_master_bucket_name`: String?, `aws_master_bucket_region`: String?, `aws_trans_bucket_name`: String?, `aws_trans_bucket_region`: String?, `aws_trans_cognito_pool_id`: String?, `aws_master_cognito_pool_id`: String?, `version_alert_content`: String?, `helpline_url`: String?, `reports_link`: String?, `profile_link`: String?, `is_alert_available`: String?, `ad_timer_interval`: String?, `new_version`: String?, `new_updates`: String?, `otp_dial_inbound`: String?, `video_vimeo_token`: String?, `ebooks_url`: String?, `market_place_url`: String?, `fees_url`: String?, `v_card_numbers`: String?, `contact_display_name`: String?, `contact_alert_title`: String?, `contact_alert_content`: String?, `support_email`: String?, `support_contact`: String?, `privacy_policy`: String?, `about_the_app`: String?, `how_to_use`: String?, `presigned_cred_base_url`: String?, `wl_privacy`: String?, `wl_terms`: String?
- **checkQuizLevelSuc** — `status`: Bool?, `message`: String?, `data`: [checkQuizLevelData]?
- **checkQuizLevelData** — `level`: Int?
- **UpdateResponse** — `status`: Bool?, `message`: String?, `data`: [UpdateItem]?
- **UpdateItem** — `id`: Int?, `name`: String?, `description`: String?, `app_redirect_link`: String?, `video_link`: String?, `downloadable_image`: String?
- **IntroResponse** — `status`: Bool?, `message`: String?, `data`: [IntroFeature]?
- **IntroFeature** — `id`: String?, `title`: String?, `description`: String?, `file_path`: [FilePath]?
- **AttendanceStudentListResponse** — `status`: Bool?, `message`: String?, `data`: [AttendanceStudentListData]?
- **AttendanceStudentListData** — `is_edit`: Bool?, `total_strength`: String?, `attd_details`: [AttendanceStudentListDetails]?
- **AttendanceStudentListDetails** — `id`: String?, `name`: String?, `admission_no`: String?, `roll_no`: String?, `att_type`: String?, `att_status`: String?, `is_leave_approved`: Bool, `leave_from`: String?, `leave_to`: String?, `reason`: String?
- **FAQResponse** — `status`: Bool?, `message`: String?, `data`: [SchoolQA]?
- **SchoolQA** — `id`: String?, `question`: String?, `answer`: [String]?
- **ReviewResponse** — `status`: Bool?, `message`: String?, `data`: [Review]?
- **Review** — `id`: String?, `mobile`: String?, `rating`: Int?, `description`: String?, `created_on`: String?, `updated_on`: String?, `remarks`: [CategoriesSection]?
- **CategoriesSection** — `rating`: Int?, `value`: String?, `name`: String?, `category`: [Categories]?
- **Categories** — `name`: String?, `selected`: Bool?
- **StaffExamListResponse** — `status`: Bool?, `message`: String?, `data`: [StaffExamData]?
- **StaffExamData** — `id`: String?, `name`: String?, `date`: String?, `ref_flag`: Int?, `ai_mark_entry`: Bool?
- **SubjectWiseExamResponse** — `status`: Bool?, `message`: String?, `data`: [SubjectExamData]?
- **SubjectExamData** — `section_id`: String?, `section_name`: String?, `class_id`: String?, `class_name`: String?, `subject_id`: String?, `subject_name`: String?, `splitup_details`: [SplitDetail]?
- **SplitDetail** — `id`: String?, `name`: String?, `max_mark`: String?, `isChecked`: Bool?, `selectedAIOption`: String?
- **SubjectWiseExamResponse** — `status`: Bool?, `message`: String?, `data`: [exanmData]?
- **exanmData** — `subjects`: [SubjectExamData]?, `co_scholastic`: [coscholastic]?
- **SubjectExamData** — `subject_id`: String?, `institute_subject_id`: String?, `subject_name`: String?, `activities`: [ActivityData]?
- **ActivityData** — `activity_id`: String?, `activity_name`: String?, `max_mark`: String?, `rubrics`: [RubricData]?, `isChecked`: Bool?, `selectedAIOption`: String?
- **RubricData** — `rubric_id`: String?, `rubric_name`: String?, `max_mark`: String?, `isChecked`: Bool?, `selectedAIOption`: String?
- **coscholastic** — `id`: String?, `name`: String?, `type`: String?, `isChecked`: Bool?, `selectedAIOption`: String?
- **MarksAIresponse** — `status`: Bool?, `message`: String?, `data`: MarkAiData?
- **MarkAiData** — `table_structure`: TableStructure?, `review_flags`: [ReviewFlag]?, `records`: [DynamicRecord]?
- **TableStructure** — `selected_columns`: [String]?
- **ReviewFlag** — `student_id`: String?, `field`: String?, `value`: String?, `reason`: String?
- **DynamicRecord** — `values`: [String:
- **RecordItem** — `name`: String, `value`: String, `isReview`: Bool, `reason`: String?
- **ConvertedStudentRecord** — `studentId`: String, `sNo`: String, `regNo`: String, `studentName`: String, `marks`: [RecordItem]
- **HostelListSuc** — `status`: Bool?, `message`: String?, `data`: [HostelListData]?
- **HostelListData** — `id`: String?, `name`: String?, `institute_id`: String?, `institute_name`: String?, `type`: String?, `max_capacity`: Int?, `address`: String?
- **HostelDashBoardSuc** — `status`: Bool?, `message`: String?, `data`: [HostelDashBoardData]?
- **HostelDashBoardData** — `stats`: statsDataDetails?, `floors`: [HostelDashBoardFloor]?
- **statsDataDetails** — `total_students`: String?, `outpass_requests`: String?
- **HostelDashBoardFloor** — `id`: String?, `floor_no`: String?, `floor_name`: String?, `rooms`: [HostelDashBoardRooms]?
- **HostelDashBoardRooms** — `id`: String?, `number`: String?, `max_occupancy`: Int?, `current_occupancy`: Int?, `total_beds`: Int?, `students`: [String]?
- **HostelStudentListSuc** — `status`: Bool?, `message`: String?, `data`: [HostelStudentListData]?
- **HostelStudentListData** — `id`: String?, `name`: String?, `admission_no`: String?, `roll_no`: String?, `gender`: String?, `class_id`: String?, `class_name`: String?, `section_id`: String?, `section_name`: String?, `primary_mobile`: String?, `status`: String?, `outpass_id`: String?, `out_date`: String?, `in_date`: String?, `reason`: String?, `outpasss_status`: String?, `is_select`: String?
- **HostelSessionListSuc** — `status`: Bool?, `message`: String?, `data`: [HostelSessionListData]?
- **HostelSessionListData** — `id`: String?, `name`: String?
- **HomeWorkSubmissionList** — `status`: Bool?, `message`: String?, `data`: [HomeworkDetails]?
- **HomeworkDetails** — `id`: String?, `name`: String?, `admission_no`: String?, `roll_no`: String?, `status`: String?
- **DetailedAttendanceDay** — `dayLabel`: String, `status`: [String]
- **DetailedAttendanceModel** — `sessions`: [String], `days`: [DetailedAttendanceDay]
- **AttendanceHistoryResponse** — `status`: Bool, `message`: String, `data`: [AttendanceHistoryData]
- **AttendanceHistoryData** — `room_id`: String, `room_no`: String, `sessions`: [AttendanceHistorySession]
- **AttendanceHistorySession** — `session_type_id`: String, `session_name`: String, `present_count`: String, `absent_count`: String, `students`: [AttendanceHistoryStudent]
- **AttendanceHistoryStudent** — `student_id`: String, `student_name`: String, `admission_no`: String, `class_name`: String, `section_name`: String, `primary_mobile`: String, `status`: String
- **OutpassResponseSuc** — `status`: Bool, `message`: String, `data`: [OutpassSection]
- **OutpassSection** — `status`: String?, `attd_details`: [OutpassStudent]?
- **OutpassStudent** — `id`: String?, `room_no`: String?, `student_id`: String?, `student_name`: String?, `admission_no`: String?, `class_name`: String?, `section_name`: String?, `primary_mobile`: String?, `gender`: String?, `out_date`: String?, `in_date`: String?, `reason`: String?, `status`: String?
- **HostelDashboardResponse** — `status`: Bool?, `message`: String?, `data`: [HostelDashboardData]?
- **HostelDashboardData** — `gate_pass`: [GatePass]?, `today_attendance`: [String]?, `out_pass_requests`: [OutPassRequest]?, `hostel_info`: [HostelInfo]?, `attendance_details`: [AttendanceDetails]?, `fee_details`: [HostelFeeDetails]?
- **GatePass** — `action_by`: String?, `admission_no`: String?, `reason`: String?, `profile`: String?, `floor_no`: String?, `room_no`: String?, `fromdate_todate`: String?, `request_time`: String?, `status`: String?
- **OutPassRequest** — `reason`: String?, `fromdate_todate`: String?, `request_time`: String?, `status`: String?, `action_by`: String?
- **HostelInfo** — `hostel_id`: String?, `hostel_name`: String?, `hostel_type`: String?, `no_of_floors`: Int?, `no_of_rooms`: Int?, `warden_type`: String?, `max_capacity`: Int?, `warden_name`: [String]?, `institute_name`: String?, `institute_address`: String?
- **AttendanceDetails** — `sessions`: [String]?, `days`: [AttendanceDay]?
- **AttendanceDay** — `date_label`: String?, `status`: [String]?
- **HostelFeeDetails** — `fee_id`: Int?, `fee_name`: String?, `fee_group`: String?, `hostel_details`: HostelRoomDetails?, `summary`: hostelFeeSummary?, `payments`: [Payment]?
- **HostelRoomDetails** — `hostel_name`: String?, `room_no`: String?, `bed_no`: String?
- **hostelFeeSummary** — `total_amount`: String?, `paid_amount`: String?, `pending_amount`: String?, `discount`: String?, `status`: String?
- **Payment** — `paid_amount`: String?, `paid_date`: String?, `payment_mode`: String?
- **HostelDetailsResponse** — `status`: Bool?, `message`: String?, `data`: [HostelDetailsData]?
- **HostelDetailsData** — `room_allocation_id`: String?, `hostel_id`: String?, `hostel_name`: String?, `student_id`: String?, `student_name`: String?, `admission_no`: String?, `primary_mobile`: String?, `gender`: String?, `floor_id`: String?, `floor_no`: String?, `floor_name`: String?, `room_id`: String?, `room_no`: String?, `room_type_id`: String?, `room_type`: String?
- **StaffAttendanceResponseSuc** — `status`: Bool?, `message`: String?, `data`: [DatasClasss]?
- **DatasClasss** — `overall_stat`: OverallStat?, `all_attd`: [String:
- **OverallStat** — `present`: Int?, `absent`: Int?, `not_marked`: Int?
- **AttendanceDays** — `stat`: DayStat?, `attd_details`: [NewStaffAttendance]?
- **DayStat** — `present`: Int?, `absent`: Int?, `not_marked`: Int?
- **NewStaffAttendance** — `staff_id`: String?, `name`: String?, `date`: String?, `designation`: String?, `role`: String?, `attendance_type`: [String:, `in_time`: String?, `out_time`: String?, `working_hours`: String?
- **transactionDataSuc** — `status`: Bool?, `message`: String?, `data`: [transactionData]?
- **transactionData** — `id`: String?, `student_id`: String?, `total_amount`: String?, `order_status`: String?, `order_id`: String?, `created_on`: String?, `order_status_update_on`: String?
- **student_routDataDetails** — `status`: Bool?, `message`: String?, `data`: [student_routData]?
- **student_routData** — `student_id`: String?, `student_name`: String?, `admission_no`: String?, `route_id`: String?, `route_name`: String?, `stop_id`: String?, `stop_name`: String?, `vehicle_id`: String?, `vehicle_no`: String?, `tentative_pickup_time`: String?, `tentative_drop_time`: String?
- **livebusDetails** — `status`: Bool?, `message`: String?, `data`: [livebusData]?
- **livebusData** — `thing_id`: String?, `tracking_url`: String?
- **GeoLocationResponse** — `status`: Bool?, `message`: String?, `data`: [GeoLocationData]?
- **GeoLocationData** — `id`: String?, `deviceId`: String?, `vehicleId`: String?, `latitude`: String?, `longitude`: String?, `speed`: String?, `altitudeLevel`: String?, `vehicleDirection`: String?, `gpsTime`: String?
- **StudentRouteDetailsResponse** — `status`: Bool?, `message`: String?, `data`: [StudentRouteData]?
- **StudentRouteData** — `student_id`: String?, `map_url_schoolchimes`: String?, `student_name`: String?, `admission_no`: String?, `route_id`: String?, `route_name`: String?, `stop_id`: String?, `stop_name`: String?, `latitude`: String?, `longitude`: String?, `landmark`: String?, `vehicle_id`: String?, `vehicle_no`: String?, `vehicle_reg_no`: String?, `tentative_pickup_time`: String?, `tentative_drop_time`: String?, `stopping_points`: [StoppingPoint]?
- **StoppingPoint** — `vehicle_id`: String?, `route_name`: String?, `journey_type`: String?, `start_time`: String?, `end_time`: String?, `working_days`: [String]?, `stops`: [Stops]?
- **Stops** — `stop_id`: String?, `stop_name`: String?, `stop_time`: String?, `latitude`: String?, `longitude`: String?, `landmark`: String?, `isCompleted`: Bool?, `isCurrent`: Bool?
- **ClassTestResponse** — `status`: Bool?, `message`: String?, `data`: [ClassTest]?
- **ClassTest** — `class_test_id`: String?, `exam_name`: String?, `subjects`: [TestsSubject]
- **TestsSubject** — `subject_id`: String?, `subject_name`: String?, `activities`: [TestsActivity]
- **TestsActivity** — `class_test_subject_id`: String?, `exam_date`: String?, `session`: String?, `activity_name`: String?, `max_mark`: String?, `min_mark`: String?, `syllabus`: String?, `status`: String?, `is_mark_uploaded`: Bool?, `attendance`: String?, `mark`: String?, `remarks`: String?
- **ClassTestMarksResponse** — `status`: Bool?, `message`: String?, `data`: [ClassTestMarks]?
- **ClassTestMarks** — `class_test_id`: String?, `exam_name`: String?, `over_all_student_marks`: String?, `over_all_Marks`: String?, `over_all_persentage`: String?, `subjects`: [MarksSubject]
- **MarksSubject** — `subject_id`: String?, `subject_name`: String?, `activities`: [MarksActivity]
- **MarksActivity** — `class_test_subject_id`: String?, `exam_date`: String?, `session`: String?, `activity_name`: String?, `max_mark`: String?, `min_mark`: String?, `syllabus`: String?, `attendance`: String?, `mark`: String?, `remarks`: String?
- **HeaderColumnConfig** — `displayName`: String?, `subjectName`: String?, `subjectId`: String?, `activityId`: String?, `activityName`: String?, `maxMarks`: Int?, `rubrics`: [RubricMark]?, `isCo_scholastic`: Bool?, `isRemarks`: Bool?, `isAttendance`: Bool?, `childColumns`: [ColumnConfig]?
- **RubricMark** — `id`: String?, `name`: String?, `max_mark`: String?, `subjectName`: String?, `displayName`: String?
- **ColumnConfig** — `displayName`: String?, `subjectName`: String?, `subjectId`: String?, `activityId`: String?, `activityName`: String?, `maxMarks`: Int?, `isRubric`: Bool, `rubricId`: String?, `isCo_scholastic`: Bool?, `isRemarks`: Bool?, `isAttendance`: Bool?
- **MarkDetailsResponse** — `status`: Bool?, `message`: String?, `data`: [MarkDetails]?
- **MarkDetails** — `exam_section_id`: String?, `exam_id`: String?, `upload_details`: [StudentMark]?
- **StudentMark** — `student_id`: String?, `student_name`: String?, `roll_no`: String?, `admission_no`: String?, `gender`: String?, `marks`: [SubjectMarks]?, `co_scholastic`: [co_scholasticMarks]?, `remarks`: [Remarks]?, `attendance_details`: [ExamAttendanceDetails]?
- **SubjectMarks** — `subject_id`: String?, `subject_name`: String?, `activities`: [ActivityMark]?
- **ActivityMark** — `id`: String?, `name`: String?, `mark`: String?, `max_mark`: String?, `is_edit`: Bool?, `selected_name`: String?, `change_mark`: String?, `isReview`: Bool?, `reason`: String?, `rubrics`: [RubricActivityMark]?
- **RubricActivityMark** — `id`: String?, `name`: String?, `mark`: String?, `max_mark`: String?, `is_edit`: Bool?, `selected_name`: String?, `change_mark`: String?, `isReview`: Bool?, `reason`: String?
- **co_scholasticMarks** — `id`: String?, `name`: String?, `mark`: String?, `is_edit`: Bool?, `selected_name`: String?, `change_mark`: String?, `isReview`: Bool?, `reason`: String?
- **Remarks** — `reference_type`: String?, `mark`: String?, `is_edit`: Bool?
- **ExamAttendanceDetails** — `reference_type`: String?, `mark`: String?, `is_edit`: Bool?
- **CommonRemarksResponse** — `status`: Bool?, `message`: String?, `data`: [CommonRemarks]?
- **CommonRemarks** — `id`: String?, `academic_remarks`: String?, `behavioural_remarks`: String?
- **analysisRespSuc** — `status`: Bool?, `message`: String?, `data`: [analysisData]?
- **analysisData** — `id`: String?, `setName`: String?, `class_tests`: [analysisClass_tests]?
- **analysisClass_tests** — `id`: String?, `examName`: String?
- **AnalysisResponse** — `status`: Bool, `message`: String, `data`: [StudentAnalysisData]
- **StudentAnalysisData** — `exam_series`: [String], `subjects`: [AnalysisSubject], `trend`: [AnalysisTrendPoint], `summary`: AnalysisSummary
- **AnalysisSummary** — `exams_analysed`: String, `average_total`: String, `average_percentage`: String, `best_exam`: AnalysisSummaryExam, `worst_exam`: AnalysisSummaryExam
- **AnalysisSummaryExam** — `exam_id`: String, `label`: String, `total`: String, `percentage`: String
- **AnalysisSubject** — `subject_id`: String, `subject_name`: String, `total_marks`: String, `obtained_marks`: String, `percentage`: String, `marks`: [AnalysisSubjectMark]
- **AnalysisSubjectMark** — `id`: String, `exam_name`: String, `obtained_mark`: String, `max_mark`: String, `attendance`: String, `remarks`: String, `activity_name`: String?, `exam_date`: String, `session`: String, `min_mark`: String, `syllabus`: String, `is_publish`: String, `color_code`: String?
- **AnalysisTrendPoint** — `exam_name`: String, `total`: String, `max`: String, `percentage`: String
- **concernRespSuc** — `status`: Bool?, `message`: String?, `data`: [concernData]?
- **concernData** — `id`: String?, `name`: String?

### Features/ParentDashBoard/ConcernVc

- **ConcernAttachment** — `url`: String?, `type`: String?, `fileName`: String
- **Concern** — `id`: String, `student_id`: String, `student_name`: String, `class_name`: String, `section_name`: String, `type_name`: String, `description`: String, `status`: ConcernStatus, `file_path`: [FilePath], `action_file_path`: [FilePath], `acknowledged_by`: String, `acknowledged_on`: String, `action_taken`: String, `action_taken_by`: String, `action_taken_on`: String, `raised_on`: String, `can_delete`: Bool, `acknowledgement`: String, `is_acknowledged`: Bool, `is_action`: Bool, `initials`: String, `classAndSection`: String, `formattedAcknowledgedOn`: String, `formattedActionByDate`: String, `formattedActionByName`: String, `formattedRaisedOn`: String, `formattedAkOn`: String, `formattedACtOn`: String
- **ConcernResponse** — `status`: Bool, `message`: String, `data`: [Concern]

### Features/ParentDashBoard/ExamMarkVc

- **NewExamResponseSuc** — `status`: Bool?, `message`: String?, `data`: [NewExam]?
- **NewExam** — `exam_id`: String?, `exam_name`: String?, `subjects`: [NewSubject]?
- **NewSubject** — `subject_id`: String?, `subject_name`: String?, `total_mark`: String?, `activities`: [NewActivity]?
- **NewActivity** — `activity_id`: String?, `activity_name`: String?, `max_mark`: String?, `pass_mark`: String?, `scheduling_details`: SchedulingDetails?, `rubrics`: [Rubric]?, `hasSchedulingDetails`: Bool
- **Rubric** — `rubric_id`: String?, `rubric_name`: String?, `max_mark`: String?, `pass_mark`: String?, `scheduling_details`: SchedulingDetails?
- **SchedulingDetails** — `date`: String?, `start_time`: String?, `end_time`: String?, `session`: String?, `venue`: String?, `syllabus`: String?, `formattedTimeRange`: String?, `formattedDate`: String?

### Features/ParentDashBoard/FeeDetail

- **PaymentProofAPIResponse** — `status`: Bool, `message`: String, `data`: [PaymentProofDataGroup]
- **PaymentProofDataGroup** — `student_details`: paymentProofStudentDetails, `payment_details`: [PaymentDetailItem]
- **paymentProofStudentDetails** — `student_id`: String, `student_name`: String, `class_name`: String, `section_name`: String, `formattedClassSection`: String, `formattedStudentID`: String
- **FeeDetailsContainer** — `term`: [TermFeeGroup]?, `others`: [OtherFeeGroup]?, `carryover`: [CarryoverFeeGroup]?, `transport`: [TransportFeeGroup]?, `hostel`: [HostelFeeGroup]?, `quantity`: [QuantityFeeGroup]?
- **TermFeeGroup** — `term_name`: String?, `term_id`: String?, `fees_details`: [TermFeeDetail]?, `displayAmount`: String
- **TermFeeDetail** — `fee_id`: String?, `fee_name`: String?, `fee_amount`: String?, `discount_availed`: String?, `actual_paid`: String?, `amount_to_be_paid`: String?, `displayAmount`: String, `displayFeeAmount`: String, `displayDiscount`: String, `displayPaid`: String
- **OtherFeeGroup** — `fee_name`: String?, `fee_amount`: String?, `discount_availed`: String?, `actual_paid`: String?, `amount_to_be_paid`: String?, `month_details`: [OtherMonthDetail]?, `displayAmount`: String, `displayFeeAmount`: String, `displayDiscount`: String, `displayPaid`: String
- **OtherMonthDetail** — `month_name`: String?, `amount_per_month`: String?, `discount_amount`: String?, `paid`: String?, `amount_to_be_paid`: String?, `pending`: String?, `displayAmount`: String, `displayFeeAmount`: String, `displaypending`: String, `displayPaid`: String, `displayMonth`: String
- **CarryoverFeeGroup** — `id`: String?, `fee_name`: String?, `fee_group_type_name`: String?, `amount_to_be_paid`: String?, `carry_over_fee`: [CarryoverItem]?, `displayAmount`: String, `detailedGroups`: [CarryoverGroupDetail]
- **CarryoverItem** — `fee_group_type_name`: String?, `fee_name`: String?, `fee_amount`: String?, `pending_amount`: String?, `paid_amount`: String?, `discount_amount`: String?
- **TransportFeeGroup** — `route_name`: String?, `stop_name`: String?, `route_fee_type_name`: String?, `actual_amount`: String?, `paid_amount`: String?, `pending_amount`: String?, `discount_given`: String?, `bus_month_details`: [BusMonthDetail]?, `cleanRouteName`: String, `formattedGroupTitle`: String, `displayAmount`: String, `displayFeeAmount`: String, `displayDiscount`: String, `displayPaid`: String
- **BusMonthDetail** — `month_name`: String?, `fee_amount`: String?, `discount_amount`: String?, `paid_amount`: String?, `pending_amount`: String?, `displayAmount`: String, `displayFeeAmount`: String, `displayDiscount`: String, `displayPaid`: String, `displayMonth`: String
- **HostelFeeGroup** — `hostel_name`: String?, `room_no`: String?, `bed_no`: String?, `actual_amount`: String?, `pending_amount`: String?, `paid_amount`: String?, `discount_amount`: String?, `month_details`: [HostelMonthDetail]?, `formattedTitle`: String, `formattedGroupTitle`: String, `displayAmount`: String, `displayFeeAmount`: String, `displayDiscount`: String, `displayPaid`: String
- **HostelMonthDetail** — `month_name`: String?, `actual_amount`: String?, `pending_amount`: String?, `discount_amount`: String?, `paid_amount`: String?, `displayAmount`: String, `displayFeeAmount`: String, `displayDiscount`: String, `displayPaid`: String, `displayMonth`: String
- **QuantityFeeGroup** — `fee_name`: String?, `qom_given`: String?, `amount_to_be_paid`: String?, `uom_price`: String?, `displayAmount`: String, `displayuom_price`: String, `displayDiscount`: String, `displayPaid`: String
- **PaymentDetailItem** — `total_amount`: String, `ai_detected_amount`: String, `user_enter_amount`: String, `is_payment_validated`: String, `validated_by`: String, `validated_on`: String, `payment_id`: String, `proof_uploaded`: [ProofUploadedItem], `created_on`: String, `remarks`: String, `proof_details`: [ProofDetailInfo], `fee_details`: FeeDetailsContainer?, `validationStatus`: PaymentValidationStatus, `cleanAmount`: String, `currencySymbol`: String, `differenceAmount`: String, `hasAIMismatch`: Bool, `shortDate`: String, `cleanValidator`: String?, `photosCountText`: String, `metadataSubtitle`: String, `termCategoryTotal`: String, `othersCategoryTotal`: String, `carryoverGroupTypeName`: String, `carryoverCategoryTotal`: String, `transportCategoryTotal`: String, `hostelCategoryTotal`: String, `quantityCategoryTotal`: String, `detailedCarryoverGroups`: [CarryoverGroupDetail], `groupedCarryoverItems`: [
- **ProofUploadedItem** — `url`: String, `file_name`: String, `original_file_name`: String, `type`: String, `displayName`: String, `badgeText`: String, `subtitleText`: String
- **ProofDetailInfo** — `payment_status`: String, `receipt_type`: String, `payment_method`: String, `upi_provider`: String, `receipt_date`: String, `validation_message`: String, `transaction_id`: String, `reference_number`: String, `paid_amount`: String, `receipt_time`: String, `bank_name`: String, `payer_name`: String, `payee_name`: String, `upi_id`: String, `account_number`: String, `failure_reason`: String, `confidence`: Int, `formattedProviderBank`: String, `formattedPaidAmount`: String, `formattedTime`: String

### Features/SchoolDashBoard/Classtest

- **TestStandardResponse** — `status`: Bool, `message`: String, `data`: [TestStandard]
- **TestStandard** — `id`: String, `name`: String, `sections`: [TestSection]
- **TestSection** — `id`: String, `name`: String
- **TestSubjectsResponse** — `status`: Bool, `message`: String, `data`: [TestSectionSubjects]
- **TestSectionSubjects** — `section_id`: String, `section_name`: String, `subjects`: [TestSubject]
- **TestSubject** — `id`: String, `name`: String
- **TestDetails** — `id`: UUID, `examName`: String, `testDate`: String, `session`: String, `maxMarks`: String, `minMarks`: String, `syllabus`: String, `activity_name`: String
- **SubjectExamConfig** — `subjectId`: String, `subjectName`: String, `sectionId`: String, `sectionName`: String, `tests`: [TestDetails]
- **ExamRequestItem** — `exam_name`: String, `section_id`: String, `subject_id`: String, `test_date`: String, `session`: String, `max_mark`: Int, `min_mark`: Int, `syllabus`: String
- **TestMarkData** — `class_test_id`: String, `section_id`: String, `subjects`: [TestMarkSubject]
- **TestMarkSubject** — `subject_id`: String, `subject_name`: String, `activities`: [TestMarkActivity]
- **TestMarkActivity** — `class_test_subject_id`: String, `activity_name`: String, `exam_date`: String, `session`: String, `max_mark`: String, `min_mark`: String, `syllabus`: String, `students`: [TestMarkStudent]
- **TestMarkStudent** — `student_id`: String, `admission_no`: String, `roll_no`: String, `student_name`: String, `attendance`: String, `mark`: String, `remarks`: String
- **StaffClassTestResponse** — `status`: Bool?, `message`: String?, `data`: [StaffClassTest]?
- **StaffClassTest** — `class_test_id`: String?, `exam_name`: String?, `sent_by`: String?, `sent_on`: String?, `sections`: [StaffSection]?, `can_delete`: Bool?
- **StaffSection** — `class_name`: String?, `section_id`: String?, `section_name`: String?, `subjects`: [StaffSubject]?
- **StaffSubject** — `subject_id`: String?, `subject_name`: String?, `activities`: [StaffActivity]?
- **StaffActivity** — `class_test_subject_id`: String?, `exam_date`: String?, `status`: String?, `session`: String?, `activity_name`: String?, `max_mark`: String?, `min_mark`: String?, `syllabus`: String?, `can_delete`: Bool?

### Features/SchoolDashBoard/ExamAnaylze

- **ExamAnaliseStandardResponse** — `status`: Bool, `message`: String, `data`: [ExameAnaliseStandard]
- **ExameAnaliseStandard** — `id`: String, `name`: String, `sections`: [ExameAnaliseSection]
- **ExameAnaliseSection** — `id`: String, `name`: String
- **StudentResponse** — `status`: Bool, `message`: String, `data`: [Student]
- **Student** — `id`: String, `name`: String, `admission_no`: String, `roll_no`: String
- **ExamResponse** — `status`: Bool, `message`: String, `data`: [Exam]
- **Exam** — `id`: String, `label`: String, `type`: String, `conductedOn`: String, `standardId`: String

### Features/SchoolDashBoard/PTM

- **RequestSlot** — `from_time`: String, `to_time`: String
- **RequestStdSecDetail** — `class_id`: String, `section_id`: String
- **RequestBodyItem** — `date`: String, `event_name`: String, `from_time`: String, `to_time`: String, `duration`: Int, `break_time`: Int, `event_link`: String, `meeting_mode`: String, `std_sec_details`: [RequestStdSecDetail], `slots`: [RequestSlot]

### Features/SchoolDashBoard/Quiz

- **FilePaths** — `fileName`: String, `fileURL`: URL, `fileType`: FileType

### Features/SchoolDashBoard/SenderLSRW

- **MonthlyReport** — `weeklyReport`: [PerformanceReport], `topPerformance`: [TopReport]
- **TopReport** — `name`: String, `studentClass`: String, `section`: String, `percentage`: Double
- **PerformanceReport** — `title`: String, `percentage`: Int

### Features/SchoolDashBoard/StudentAttendanceReport

- **SectionAbsentees** — `class_name`: String, `class_id`: String, `section_name`: String, `section_id`: String, `total_absentees`: String, `student_counts`: String

### Features/SchoolDashBoard/StudentReport

- **StudentFeeDetailsResponse** — `status`: Bool?, `message`: String?, `data`: [FeeJSON]?, `details`: StudentFeeDetails?
- **StaffFeeProofResponse** — `status`: Bool?, `message`: String?, `data`: [StaffFeeProofGroup]?
- **StaffFeeProofGroup** — `student_details`: StaffFeeStudent?, `payment_details`: [StaffFeePayment]?
- **StaffFeeStudent** — `student_id`: String?, `student_name`: String?, `class_name`: String?, `section_name`: String?
- **StaffFeePayment** — `total_amount`: String?, `ai_detected_amount`: String?, `user_enter_amount`: String?, `fee_details`: StaffFeeBreakdown?, `is_payment_validated`: String?, `validated_by`: String?, `validated_on`: String?, `payment_id`: String?, `proof_uploaded`: [StaffFeeProofFile]?, `created_on`: String?, `created_by`: String?, `remarks`: String?, `proof_details`: [StaffFeeProofReading]?, `status`: StaffFeeStatus, `uploadedBy`: String, `aiCheck`: StaffFeeAICheck, `categoryNames`: [String]
- **StaffFeeProofFile** — `url`: String?, `type`: String?, `file_name`: String?, `original_file_name`: String?, `isImage`: Bool
- **StaffFeeProofReading** — `payment_status`: String?, `receipt_type`: String?, `payment_method`: String?, `upi_provider`: String?, `receipt_date`: String?, `validation_message`: String?, `transaction_id`: String?, `reference_number`: String?, `paid_amount`: LossyString?, `receipt_time`: String?, `bank_name`: String?, `payer_name`: String?, `payee_name`: String?, `upi_id`: String?, `account_number`: String?, `failure_reason`: String?, `confidence`: LossyString?, `isValidImage`: Bool
- **LossyString** — `value`: String
- **StaffFeeBreakdown** — `term`: [StaffTermGroup]?, `others`: [StaffOtherFee]?, `carryover`: [StaffCarryover]?, `transport`: [StaffTransportFee]?, `hostel`: [StaffHostelFee]?, `quantity`: [StaffQuantityFee]?
- **StaffTermGroup** — `term_name`: String?, `term_id`: String?, `fees_details`: [StaffTermFee]?
- **StaffTermFee** — `fee_id`: String?, `fee_name`: String?, `fee_amount`: String?, `discount_availed`: String?, `actual_paid`: String?, `amount_to_be_paid`: String?
- **StaffOtherFee** — `fee_id`: String?, `fee_name`: String?, `fee_amount`: String?, `discount_availed`: String?, `actual_paid`: String?, `amount_to_be_paid`: String?, `month_details`: [StaffOtherMonth]?
- **StaffOtherMonth** — `month_name`: String?, `amount_per_month`: String?, `discount_amount`: String?, `paid`: String?, `amount_to_be_paid`: String?, `pending`: String?, `is_paid`: String?
- **StaffCarryover** — `id`: String?, `fee_name`: String?, `fee_category_name`: String?, `fee_group_type_name`: String?, `pending_carried_over`: String?, `discount_amount`: String?, `paid_amount`: String?, `amount_to_be_paid`: String?, `carry_over_fee`: [StaffCarryoverItem]?
- **StaffCarryoverItem** — `fee_group_type_name`: String?, `fee_id`: String?, `fee_name`: String?, `fee_amount`: String?, `paid_amount`: String?, `pending_amount`: String?, `discount_amount`: String?
- **StaffTransportFee** — `route_name`: String?, `stop_name`: String?, `route_fee_type_name`: String?, `actual_amount`: String?, `paid_amount`: String?, `pending_amount`: String?, `discount_given`: String?, `bus_month_details`: [StaffMonthAmount]?
- **StaffHostelFee** — `hostel_name`: String?, `room_no`: String?, `bed_no`: String?, `actual_amount`: String?, `pending_amount`: String?, `paid_amount`: String?, `discount_amount`: String?, `month_wise_fee`: [StaffMonthAmount]?
- **StaffMonthAmount** — `month_name`: String?, `fee_amount`: String?, `actual_amount`: String?, `discount_amount`: String?, `paid_amount`: String?, `pending_amount`: String?, `amount`: String?
- **StaffQuantityFee** — `id`: String?, `fee_name`: String?, `uom_price`: String?, `qom_given`: String?, `amount_to_be_paid`: String?
- **AcademicPerformance** — `overallPercentage`: Double?, `grade`: String?, `gpa`: Double?, `attendancePercentage`: Double?, `classRank`: Int?, `totalStudents`: Int?
- **ExamPerformance** — `improvementPercentage`: Double?, `highestScore`: Double?, `highestExamName`: String?, `exams`: [ExamScore]?
- **ExamScore** — `examName`: String?, `score`: Double?
- **SubjectWisePerformance** — `strongestSubject`: String?, `weakestSubject`: String?, `subjects`: [SubjectPerformance]?
- **SubjectPerformance** — `subjectName`: String, `marks`: Double, `grade`: String
- **AttendanceOverview** — `attendancePercentage`: Double?, `presentDays`: Int?, `absentDays`: Int?, `leaveDays`: Int?, `weeklyAttendance`: [DayAttendance]?
- **DayAttendance** — `dayName`: String?, `date`: Int?, `status`: AttendanceStatus?
- **PaymentHistory** — `paymentId`: String?, `paid_date`: String?, `pending_amount`: Double?, `paid_amount`: Double?, `amount_given`: Double?, `discount_amount`: Double?, `in_progress`: Double?, `payment_mode`: String?
- **FeeResponse** — `status`: Bool?, `message`: String?, `data`: [FeeData1]?
- **FeeData1** — `summary`: FeeSummary?, `transport_fee`: TransportFee?, `hostel_fee`: TermFee?, `paymentHistory`: [PaymentHistory]?, `quantity_fees`: TermFee?, `other_fees`: TermFee?, `carryover_fees`: TermFee?, `term_fees`: TermFee?, `Academic_Performance`: AcademicPerformance?, `ExamPerformance`: ExamPerformance?, `SubjectWisePerformance`: SubjectWisePerformance?, `AttendanceOverview`: AttendanceOverview?
- **TransportFee** — `actual_amount`: Double?, `paid_amount`: Double?, `discount_amount`: Double?, `pending_amount`: Double?, `route_name`: String?, `stop_name`: String?, `vehicle_no`: String?, `paid_details`: [PaymentHistory]?
- **FeeSummary** — `total_amount`: Double?, `total_paid`: Double?, `total_discount`: Double?, `total_pending`: Double?, `paymentProgress`: Double?
- **TermFee** — `id`: Int?, `fee_name`: String?, `term_name`: String?, `term_id`: Int?, `actual_amount`: Double?, `paid_amount`: Double?, `discount_amount`: Double?, `pending_amount`: Double?, `status`: InstallmentStatus?, `hostel_name`: String?, `room_no`: String?, `bed_no`: String?, `isExpand`: Bool?, `breakDown`: [CarryoverBreakdown]?, `paid_details`: [PaymentHistory]?
- **CarryoverBreakdown** — `fee_group_type_id`: Int?, `fee_group_type_name`: String?, `fee_id`: Int?, `fee_name`: String?, `m_feeamount`: Double?, `discount_amount`: Double?, `paid_amount`: Double?, `pending_amount`: Double?, `due_date`: String?, `status`: InstallmentStatus?
