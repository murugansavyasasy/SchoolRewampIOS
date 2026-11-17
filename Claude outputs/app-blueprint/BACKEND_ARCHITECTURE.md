# Backend Architecture

This document describes the backend that a new app needs, under any brand name. The server code was **not** in the repository, so everything here comes from what the iOS app sends and expects:

- **Facts** are marked with ✅. They are read directly from the app code.
- **Inferences** are marked with 🔶. They are recommendations for building a compatible backend.

---

## 1. Topology

```
                ┌──────────────────────────── Mobile app (iOS / Android) ───────────────────────────┐
                │  Auth · Dashboard · Modules · Uploads · Push                                         │
                └───────┬───────────────────────┬────────────────────────┬──────────────┬─────────────┘
                        │ writes / auth          │ reads / reports         │ files        │ video
                        ▼                        ▼                         ▼              ▼
              Base API (apiv8)          Report API (reportv8)     Presign service →    Vimeo
              POST/PUT, login           GET lists, dashboards      AWS S3 bucket
                        │                        │
                        └──────────┬─────────────┘
                                   ▼
                     Shared database (schools, users, classes, content …)
                                   │
              FCM (push) ◄─────────┤──────► SMS / voice-call gateway (send-voice, send-text, absentee SMS)
                                   └──────► Pauket partner API (rewards)
```

### Hosts and request conventions

✅ **Two hosts per region.** Both are returned by `app/api/setup/countries` and refreshed by `version-check` (`country_details.base_url` and `reporting_url`):

- **base:** login and most writes
- **report:** dashboards, lists and reports.

🔶 **Read/write split.** This looks like a read replica or reporting service in front of the same data. A new backend can serve both from one service, as long as both hosts are configurable per country.

✅ **Request format:**

- Every path is `<service>/api/<resource>/<action>` with kebab-case actions.
- GET calls send their parameters in the query string.
- POST and PUT calls send a JSON body.
- **Deletes are PUT** (soft delete).

---

## 2. Service modules (by URL prefix)

| Prefix | Responsibility | Main entities 🔶 |
|---|---|---|
| `app/api/setup` | Countries/regions, app version policy | Country, AppVersion |
| `app/api/auth` | Login, OTP, device/push token, logout | User (mobile), Device, Session/token |
| `app/api/cred` | Password create / change / forgot / reset | Credential, OTP |
| `app/api/global` | Key/value config for the app | GlobalVariable |
| `dashboard/api` | Role menus, counts, notifications, FAQ, what's new, reviews, reconcile, Pauket points | Menu, MenuPermission, Notification, Review |
| `comm/api` | Circulars (voice, text), homework, assignments, attachments, interaction, leave, certificates, recipients | Message, MessageTarget, ReadReceipt, Homework, Assignment, Submission, LeaveRequest, Certificate |
| `admin/api` | Notice board, events, concerns, student/staff profiles, strength, student report | Notice, Event, Concern, StudentProfile |
| `exam/api` | Class tests, term exams, marks, progress card, analysis | Exam, Subject, Mark, Remark |
| `fee/api` | Fee details, invoices, payment proof, pending/daily reports | FeeStructure, Invoice, Payment, PaymentProof |
| `lms/api` | Lesson plans, LSRW skills, quiz, timetable | LessonPlan, Skill, Quiz, Question, Timetable |
| `ptm/api` | Parent-teacher meeting slots | PtmSlot, Booking |
| `stud-attd/api` | Student and hostel attendance, outpass | Attendance, Hostel, Room, Outpass |
| `staff-attd/api` | Geo-fenced staff attendance | GeoFence, Punch |
| `transport/api` | Routes and live bus location | Route, Vehicle, GeoPing |
| `ocr/api` | Mark-sheet image → marks | (AI/OCR job) |

---

## 3. Identity, tenancy and tokens

### Identity

✅ The user's identity is the **mobile number**, with an optional password. The OTP is sent by the server.

- `secure_id` is a per-install device UUID.
- `device_type` is `"Iphone"` (Android sends its own value 🔶).

### One login, many records

✅ `validate-user` returns one **record per role context**:

- `staff_details[]`: one record per school where the number is staff. Each has `school_id`, `role`, `priority_level` (p1–p5) and its own `access_token`.
- `child_details[]`: one record per child. Each has `school_id`, `class_id`, `section_id`, `academic_year_id` and its own `access_token`.

### What the token does

✅ The token is sent raw in `Authorization` (no `Bearer`). **The token alone tells the server who is calling, which school it is, which role applies and which child is selected.** That is why most endpoints carry no school or child id.

🔶 For a new backend:

- Issue a signed token (for example a JWT) with the claims `{user_id, school_id, member_type: staff|parent, staff_id | child_id, role, academic_year_id}`.
- Add expiry plus a 401 response. The current app has no expiry handling; it re-logs in on every launch.

### Tenancy and white-label

✅ **Tenant = school.** A group head (p1) spans several schools, so the app calls school-scoped endpoints with the token of the selected staff record.

✅ **White-label apps** send a fixed `school_id` in `version-check`.

🔶 That `school_id` is used to:

- restrict who can log in to that branded app
- return the school's branding and policy URLs.

---

## 4. Authorization model

### Menus

✅ Menus are **server-driven**: `dashboard/menus?member_type=staff|parent&language_code=` returns the allowed menu ids, and the app only maps an id to a screen.

🔶 Back this with tables for role → menu (per school) and plan → menu, so features can be switched on per school or subscription.

### Limits

✅ Limits come from `user_details`:

- `max_general_sms_count` and `max_homework_sms_count`
- `max_emergency_voice_duration`, `max_general_voice_duration` and `max_hw_voice_duration`
- `image_count`.

🔶 Enforce the same limits on the server too.

### Flags

✅ The app reads these flags:

| Flag | Effect in the app |
|---|---|
| `is_payment_pending` | 🔶 school subscription is due |
| `biometric_enable` | biometric login is allowed |
| `allow_video_download` | videos can be downloaded |
| `is_not_allow` | the child is blocked and the app shows `display_message` |
| `gps_type` | `"dhundhoo"` selects third-party bus tracking |

---

## 5. Content targeting (core data pattern)

✅ Every outbound item (message, homework, notice, event, attachment, assignment, quiz, LSRW, PTM) has:

- `target_type`: 1 school · 2 standard · 3 section · 4 group · 5 student · 6 staff
- `target_code`: the list of ids for that type.

🔶 The schema to support this:

```
content(id, school_id, module, title, description, file_type, file_path[], iframe, created_by, academic_year_id,
        visible_from, visible_to, is_emergency, is_schedule, schedule_date[], start_time, end_time, deleted)
content_target(content_id, target_type, target_code)
content_recipient(content_id, child_id|staff_id, delivered_at, read_at, call_status)   -- fan-out at send time
submission(content_id, child_id, files[], text, remark, status, submitted_at)          -- assignments, LSRW, quiz
```

- **Fan-out:** recipients are resolved at send time so `report` and `target-details` can show who received, read or submitted.
- **Delivery:** each recipient gets an FCM push. Voice and text also go out through the SMS or IVR gateway.
- **Archive:** `list-archive` returns items from previous academic years.

---

## 6. File and media pipeline

1. ✅ The app reads `presigned_cred_base_url` from `app/api/global/global-variables`.
2. ✅ It calls `GET {presigned_cred_base_url}get-s3-presigned-url?bucket=&fileName=&bucketPath=&fileType=`, which returns `{presignedUrl, fileUrl}`.
3. ✅ It PUTs the file to `presignedUrl` and sends `fileUrl` in the module payload (`file_path`).
4. ✅ The bucket path is `<module>/<school_id>/<yyyy-mm-dd>`, where module is assignment, skills, events or marksheets.
5. ✅ Videos are uploaded to Vimeo. The app stores the link and the iframe.

🔶 In a new app, do the Vimeo upload server-side (the app currently holds a Vimeo token), or use S3 plus a transcoder.

---

## 7. Notifications

✅ After login the app registers the device with `auth/device-token`: FCM token, device model, OS and app version.

✅ The push payload must let the app pick the record and the screen. Include:

- `menu_id`
- `message_id`
- `school_id`
- `staff_id` or `child_id`
- `member_type`.

✅ The in-app notification list uses `dashboard/notifications`. Deleting one calls `delete-notification`.

---

## 8. External integrations to recreate

| Integration | Used for | Recreate with |
|---|---|---|
| Firebase (FCM, Crashlytics/Analytics) | Push, crash reporting | Your own Firebase project per app |
| AWS S3 | Files | Your bucket + presign service |
| Vimeo | Video | Vimeo/Mux/S3+CloudFront |
| SMS / voice-call gateway 🔶 | `send-voice`, `send-text`, absentee SMS | Any CPaaS (Exotel, Twilio, MSG91 …) |
| Payment gateway 🔶 | Online fee payment (web `fees_url`), reconcile | Razorpay/PayU etc. |
| Google Maps / MapLibre | Bus and geo attendance | Your keys / tiles |
| Pauket | Rewards and coupons | Optional; partner key must stay on the server |
| OCR/AI | Mark-sheet reading | Any vision/OCR service |

---

## 9. Response contract to keep

```json
{ "status": true, "message": "Human readable text", "data": [ { } ] }
```

- `data` is always an array, even when it holds one object.
- On failure, return `status:false` with a user-facing `message`. 🔶 Use HTTP 401 for an invalid token.
- Keep JSON keys **snake_case** and make every field optional or nullable. The app decodes leniently, but missing keys must not crash a new client.
- Dates in responses appear as `dd-MM-yyyy`, `dd MMM yyyy` and `dd MMM yyyy hh:mm a`.
- 🔶 Standardise on ISO-8601 in a new backend and format on the client.

---

## 10. Minimum backend to launch a rebranded app

These are the endpoints the app needs before anything works.

**Auth and setup:**

- `setup/countries`
- `setup/version-check`
- `auth/validate-user`
- `auth/validate-otp`
- `cred/*`
- `auth/device-token`
- `auth/logout`
- `global/global-variables`

**Home:**

- `dashboard/menus`
- `dashboard/menu-counts`
- `dashboard/notifications`

**Sending:**

- `comm/recipient/*`
- the presign service
- at least one module, usually `comm/communication` plus `voice` and `text-message`, or homework.

Add the other modules as their menu ids are switched on.
