//
//  AppStringFile.swift
//  VsSchoolChimes
//
//  Created by Admin on 06/12/24.
//

import Foundation

struct MenuStringFile{
    
//    static let Communication = TranslationManager.shared.translate(key:"Communication");
//    static let ImagePdf = TranslationManager.shared.translate(key:"Image/Pdf");
//    static let VideoUpload = TranslationManager.shared.translate(key:"Video Upload");
//    static let Circulars = TranslationManager.shared.translate(key:"Circulars");
//    static let NoticeBoard = TranslationManager.shared.translate(key:"Notice Board");
//    static let LeaveRequests = TranslationManager.shared.translate(key:"Leave Requests");
//    static let Assignment = TranslationManager.shared.translate(key:"Assignment");
//    static let OnlineMeeting = TranslationManager.shared.translate(key:"Online Meeting");
//    static let Homework = TranslationManager.shared.translate(key:"Homework");
//    static let ScheduleExamTest = TranslationManager.shared.translate(key:"Schedule Exam/Test");
//    static let AttendanceMarking = TranslationManager.shared.translate(key:"Attendance marking");
//    static let MessagesFromManagement = TranslationManager.shared.translate(key:"Messages from management");
//    static let InteractionWithStudent = TranslationManager.shared.translate(key:"Interaction with student");
//    static let LessonPlan = TranslationManager.shared.translate(key:"Lesson Plan");
//    static let PTM = TranslationManager.shared.translate(key:"PTM");
//    static let TextToParentsStaff = TranslationManager.shared.translate(key:"Text to Parents/Staff");
//    static let SchoolClassEvents = TranslationManager.shared.translate(key:"School / Class Events");
//    static let SchoolNeeds = TranslationManager.shared.translate(key:"School Needs");
//    static let VeryImportantInfo = TranslationManager.shared.translate(key:"Very Important Info");
//    static let AbsenteesReport = TranslationManager.shared.translate(key:"Absentees Report");
//    static let SchoolStrength = TranslationManager.shared.translate(key:"School strength");
//    static let DailyCollection = TranslationManager.shared.translate(key:"Daily Collection");
//    static let StudentReport = TranslationManager.shared.translate(key:"Student Report");
//    static let FeePendingReport = TranslationManager.shared.translate(key:"Fee Pending Report");
//    static let MarkYourAttendance = TranslationManager.shared.translate(key:"Mark Your Attendance");
//    static let StaffWiseAttendanceReport = TranslationManager.shared.translate(key:"Staff Wise Attendance Report");
//    static let LSRW = TranslationManager.shared.translate(key:"LSRW");
  
    static let Communication = "Communication"
    static let ImagePdf = "Image/Pdf"
    static let VideoUpload = "Video Upload"
    static let Video = "Video"
    static let Circulars = "Circulars"
    static let NoticeBoard = "Notice Board"
    static let LeaveRequest = "Leave Request"
    static let Assignment = "Assignment"
    static let OnlineMeeting = "Online Meeting"
    static let Homework = "Homework"
    static let ScheduleExamTest = "Schedule Exam/Test"
    static let AttendanceMarking = "Attendance marking"
    static let MessagesFromManagement = "Messages from management"
    static let InteractionWithStudent = "Interaction with student"
    static let LessonPlan = "Lesson Plan".translated()
    static let PTM = "PTM".translated()
    static let TextToParentsStaff = "Text to Parents/Staff"
    static let SchoolClassEvents = "Events"
    static let EventsHolidays = "Events"
    static let SchoolNeeds = "School Needs"
    static let VeryImportantInfo = "Very Important Info"
    static let AbsenteesReport = "Absentees Report"
    static let SchoolStrength = "School Strength"
    static let DailyCollection = "Daily Collection"
    static let StudentReport = "Student Report"
    static let FeePendingReport = "Fee Pending Report"
    static let MarkYourAttendance = "Mark Your Attendance"
    static let StaffWiseAttendanceReport = "Staff Wise Attendance Report"
    static let LSRW = "LSRW"
    static let MarkAttendance = "Mark Attendance"
    static let GeometricAttendance = "Geometric Attendance"
    static let AbsentStudents = "Absent Students"
    static var selectedMenuName = ""
}



struct ReceiverMenuItems {
    static let Communication = "Communication"
    static let Homework = "Homework"
    static let ExamTest = "Exam Test"
    static let ExamMarks = "Exam Marks"
    static let ImagePdf = "Image Pdf"
    static let Video = "Video"
    static let NoticeBoard = "Notice Board"
    static let Assignment = "Assignment"
    static let OnlineMeeting = "Online Meeting"
    static let AttendanceReport = "Attendance Report"
    static let EventsHolidays = "Events"
    static let RequestLeave = "Request Leave"
    static let FeeDetails = "Fee Details"
    static let Images = "Images"
    static let InteractionWithStaff = "Interaction with Staff"
    static let QuizExam = "Quiz Exam"
    static let LSRW = "LSRW"
    static let ClassTimetable = "Class Timetable"
    static let CertificateRequest = "Certificate Request"
    static let PTM = "PTM"
    static let Map = "MySchoolBus"
    
}

struct AlertstringFile{
    
    static let title = "Confirm Action".translated()
    static let voice_or_title_is_required = "Voice and title is required".translated()
    static let enter_title_description = "Enter title and description".translated()
    static let Choose_any_target = "Choose any target to send message".translated()
    static let Choose_any_standard_section = "Choose any standard and section".translated()
    static let Choose_any_section = "Choose any section and subject".translated()
    static let Audio_exceeds_3_minutes = "Audio exceeds 3 minutes. Please select a shorter audio.".translated()
    static let Alert_title = "Alert".translated()
    static let Audio_file_should80 = "Audio file should be less than 30 seconds".translated()
    static let Audio_file_should180 = "Audio file should be less than 180 seconds".translated()
    static let Success = "Success".translated()
    static let Confirm_title = "Confirmation".translated()
    static let select_date = "Select sheduled date".translated()
    static let Warning = "Warning".translated()
    static let Confirm = "Confirm".translated()
    static let Change_academic_year = "NOTE : This message is addressed to students in".translated()
    static let Change_academic_year1 = " which is not the communication academic year ".translated()
    static let Change_academic_year2 = "Do you want to proceed?".translated()
    static let Selected_target = "Selected target : ".translated()
    static let AreYouSureYouWantToProceed = "Are you sure you want to send this message?".translated()
    static let are_yousure_youWant_to_send_voiceMessage = "Are you sure you want to send this voice message?".translated()
    static let are_yousure_youWant_to_sendHomeWork = "Are you sure you want to send this Home Work?".translated()
    static let are_yousure_youWant_to_sendAttachment = "Are you sure you want to send this Attachment?".translated()
    static let deletemessage = "Are you sure you want to Delete?".translated()
    static let are_yousure_youWant_to_send_Notice = "Are you sure you want to send this Notice?".translated()
    static let are_yousure_youWant_to_send_emergency_voiceMessage = "Are you sure you want to send this Emergency voice message? note: this will send to all your contacts".translated()
    static let ConfirmLeave = "Are you sure want to ".translated()
    static let ConfirmLogout = "Are you sure you want to Logout".translated()
    static let No = "No".translated()
    static let Submit = "Submit".translated()
    static let Successfully_password_created = "Successfully password created".translated()
    static let Password_Missmatched = "Password Missmatched".translated()
    static let enter_valid_password = "Enter valid password".translated()
    static let Select_from_history = "Select from history".translated()
    static let Enter_the_new_password = "Enter the new password".translated()
    static let Enterthe_confirm_password = "Enter the confirm password".translated()
    static let Enter_valid_Mobile = "Enter valid Mobile Number".translated()
    static let Invalid = "Invalid Password".translated()
    static let Enter_the_10_digit = "Enter the 10 digit mobile number".translated()
    static let Terms_And_Conditions = "Please agree to the terms and conditions".translated()
    static let Enter_Otp = "Enter the otp".translated()
    static let OK = "Ok".translated()
    static let Yes_Send = "Yes,Send".translated()
    static let Yes_Update = "Yes,Update".translated()
    static let delete = "Delete".translated()
    static let  enableRemindersAccess =  "Please enable reminders access in Settings.".translated()
    static let  PermissionDenied = "Permission Denied".translated()
    static let  Done = "Done".translated()
    static let  Reach_Your_Limit = "Reach Your Limit".translated()
    static let  Already_Reach_Your_Limit = "Already Reach Your Maximum Limit".translated()
    static let Sectionorstudent = "Section or student".translated()
    static let Standardorsection = "Standard or section".translated()
    static let Select = "Select".translated()
    static let Chooseanoption = "Choose an option".translated()
    static let CameraNotAvailable = "Camera Not Available".translated()
    static let devicehasnoCamara = "This device has no camera.".translated()
    static let Camera = "Camera".translated()
    static let Gallery = "Gallery".translated()
    static let PDF = "PDF".translated()
    static let Document = "Document".translated()
    static let Cancel = "Cancel".translated()
    static let  LeaveRequest = " Leave Request".translated()
    static let Mark_All_as_Present = "Mark All as Present?"
    static let Failed_to_upload_video = "Failed to upload video".translated()
    static let Please_choose_video = "Please choose a Video".translated()
    static let Fill_All_Required_Fields = "Fill All Required Fields".translated()
    static let invalidSelection = "invalidSelection".translated()
    static let selectDatesWithinMonth = "selectDatesWithinMonth".translated()
    static let Location_Access_Needed = "Location Access Needed".translated()
    static let Please_allow_location_access = "Please allow location access in Settings to use this feature.".translated()
    static let Open_Settings = "Open Settings".translated()
    static let Distance_Should = "Distance Should be  above 10 Meter(s)".translated()
    static let Please_Select_Your_Country = "Please Select Your Country".translated()
    static let Please_Add_Attachment = "Please Add Any Attachment".translated()
    static let Please_Select_a_Video = "Please Select a Video".translated()
    static let Please_Select_a_Image = "Please Select a Image".translated()
    static let Please_Select_a_Document = "Please Select a Document".translated()
    static let Enter_location_name = "Enter your location name".translated()
    static let Are_you_sure_you_want_to_submit_leave_request = "Are you sure you want to submit this leave request?".translated()
    static let Enter_reason = "Please Enter the reason".translated()
    static let Failed = "Failed".translated()
    static let Are_you_sure_you_want_to_update_Lesson = "Are you sure you want to Update this Lesson Plan?".translated()
    static let Are_you_sure_you_want_to_Delete_Lesson = "Are you sure you want to Delete this Lesson Plan?".translated()
    static let submitAttendanceConfirmation = "Are you sure you want to submit the attendance?".translated()

    
}

struct classTimeTableStrings {
    static let weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    static let weekDaysShort = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat","Sun"]
    static let subjects = ["Mathematics", "Science", "History", "English", "Geography", "Physics", "Chemistry", "Biology", "Computer Science", "Art"]

    static var timeArr = ["8 AM", "10 AM",  "12 PM",  "2 PM",  "4 PM",  "6 PM",  "8 PM","10 PM"]
    static var toTimeArr = [ "9 AM",  "11 AM", "1 PM",  "3 PM",  "5 PM",  "7 PM", "9 PM", "11 PM"]
    static let timeGet = "10 AM"
    
}

class MenuTapbar{
    static var shared = MenuTapbar()
    
     let FAQ = "FAQ".translated()
     let Rate_Us = "Rate Us".translated()
    let Report_a_bug = "Report a bug".translated()
     let Settings = "Settings"
     let Contact_Us = "Contact Us".translated()
    let Notifications = "Notifications".translated()
    let ComposeNotifications = "Compose NoticeBoard".translated()
     let Video = "Video"//.translated()
     let Assignment = "Assignment".translated()
     let Noticeboard = "Noticeboard".translated()
     let Help = "Help".translated()
    
    let setting = SettingStringFile()
}

class SettingStringFile{
    
    static var shared = SettingStringFile()
    
     let general = "GENERAL"
     let notifications = "Notifications"
     let faq = "FAQ"
     let contactUs = "Contact Us"
     let termsAndConditions = "Terms and Conditions"
     let changeAppLanguage = "Change App Language"
     let feedback = "Rate Us"
     let reportABug = "Report a bug"
     let sendFeedback = "Send Feedback"
     let logout = "Logout"
    let faceID  = "Face ID/Touch ID"
}


class QuizListStringFile{
    static let Chapter = "Chapter"
    static let Question = "Question"
    static let Option_A = "Option A"
    static let Option_B = "Option B"
    static let Option_C = "Option C"
    static let Option_D = "Option D"
    static let Correct_Ans = "Correct Ans"
    static let Mark = "Mark"
}

struct CommonStringFile{
    //MARK:
    static let Search = "Search".translated()
    static let You_can_only_select_up_to2_video_files = "You can only select up to 2 video files.".translated()
    static let Cancel = "Cancel".translated()
    static let Camera = "Camera".translated()
    static let Document = "Document".translated()
    static let Video = "Video".translated()
    static let Photos = "Photos".translated()
    static let VIDEO = "VIDEO"
    static let M4A = "M4A"
    static let seeLess = "See less".translated()
    static let seemore = " See more".translated()
    static let selectedText = " selected Text".translated()
    static let RollNoASC = "Roll No ASC".translated()
    static let RollNoDESC = "Roll No DESC".translated()
    static let NameASC = "Name ASC".translated()
    static let NameDESC = "Name DESC".translated()
    static let Present = "Present".translated()
    static let Absent = "Absent".translated()
    static let getAllStudent = "Get All Student".translated()
    static let getStanderd_Section = "Standard & Section".translated()
    static let getStanderd = "Standard".translated()
    static let Logout = "Logout".translated()
    static let Select_from_history = "Select from history".translated()
    static let RollNo = "Roll No".translated()
    static let Name = "Name".translated()
    static let Status = "Status".translated()
    static let Section = "Section".translated()
    static let Standard = "Standard".translated()
    static let Academic_Year = "Academic Year".translated()
    static let Filter = "Filter".translated()
    static let UploadAttachment = "Upload Attachment".translated()
    static let UploadImagepdf = "Upload Image/Document".translated()
    static let UploadImagepdfoptional = "Upload Image/Document (Optional)".translated()
    static let Description = "Description".translated()
    static let Starts_on = "Starts on".translated()
    static let Groups = "Groups".translated()
    static let Sectionorstudent = "Section or student".translated()
    static let Standardorsection = "Standard or section".translated()
    static let FromTime = "From Time".translated()
    static let Schedule = "Schedule date".translated()
    static let ToTime = "Do not dial beyond".translated()
    static let Emergencyvoicemessages = " Emergency call   ℹ️ ".translated()
    static let VoiceMessage = "Instant Call".translated()
    static let TextMessage = "Text Message".translated()
    static let ScheduleCall = "Schedule Call".translated()
    static let EnterTextHere = "Enter Text Here".translated()
    static let EnterReason = "Enter Reason".translated()
    static let BacktoTextMessage = "Back to compose".translated()
    static let BackToVoiceMessage = "Back to compose".translated()
    static let Venue = "Venue".translated()
    static let AddPhotos = "Add Photos".translated()
    static let EventDetails = "Event Details".translated()
    static let EventTitle = "Event Title".translated()
    static let Optional = "(Optional?)".translated()
    static let AddPhotos1 = "Add Photos1".translated()
    static let egChennai = "egChennai".translated()
    static let egYogaEvent = "egYogaEvent".translated()
    static let completed = "completed".translated()
    static let pending = "pending".translated()
    static let Enterbugs = "Enter bugs".translated()
    static let Profile = "Profile".translated()
    static let AboutStudent = "About Student".translated()
    static let AboutStaff = "About Staff".translated()
    static let Contactdetails = "Contact details".translated()
    static let Registernumber = "Register number".translated()
    static let FamilyDetails = "Family Details".translated()
    static let Fathername = "Father name".translated()
    static let Fatheroccupation = "Father occupation".translated()
    static let Mothername = "Mother name".translated()
    static let Motheroccupation = "Mother occupation".translated()
    static let SecondaryPhoneno = "Secondary Phone no".translated()
    static let ContactSupport = "Contact Support".translated()
    static let TermsandConditions = "Terms and Conditions".translated()
    static let scheduleExam = "schedule Exam".translated()
    static let From = "From".translated()
    static let To = "To".translated()
    static let Days = "Days".translated()
    static let Day = "Day".translated()
    static let CreateLeaveRequest = "Create Leave Request".translated()
    static let LeaveRequestInfo = "LeaveRequestInfo".translated()
    static let Parent = "Student/Parent".translated()
    static let OrParent = "or Student/Parent".translated()
    static let Principal = "Principal".translated()
    static let LoginAsTeacherOrParent = "Login As Teacher Or Parent".translated()
    static let LoginAs = "Login As".translated()
    static let ChooseYourRole = "Choose Your Role".translated()
    static let Proceed = "Proceed".translated()
    static let CreateEvent = "Create Event".translated()
    static let Title = "Title".translated()
    static let selectedDate = "Submission Date".translated()
    static let SelectCatagorie = "Select Catagorie".translated()
    static let AddPdfoptional = "Add Pdf (Optional?)".translated()
    static let Add_attachment_optional = "Add attachment (Optional?)".translated()
    static let Recording_Time = "Recording Time (Optional?)".translated()
    static let Add_attachment = "Add attachment".translated()
    static let RTime = "Recording Time".translated()
    static let AddPdf = "Add Pdf".translated()
    static let AddDocuments = "Add Documents".translated()
    static let AddVideo = "Add Video".translated()
    static let Tap_SEND_to_share_this = "Tap SEND to share this message with everyone in the school.".translated()
    static let Your_academic_year_configuration = "The academic year configuration for your school are incorrect. Please contact  School Chimes at support@savyasasy.com".translated()
    static let support_savyasasy_com = "support@savyasasy.com"
    static let jpg = "jpg"
    static let IMAGE = "IMAGE"
    static let path = "path"
    static let url = "url"
    static let type = "type"
    static let pdf = "pdf"
    static let audio = "audio"
    static let Tap_on_the_punch = "Tap on the Punch button to record your attendance for the day. A confirmation message will appear once your attendance is successfully marked."
    
    static let locationErrorMessage = """
        Note: You are outside the institute's boundary. You will not be able to mark your attendance.

        Please try again when you are within the designated area.
        """
    
    static let add_location_firstMessage = """
        Accurate location settings are crucial for ensuring that attendance is only marked when users are within the designated area of the institute. Please double-check the location before submitting.
        """
    
    static let add_location_secondMessage = """
        Once saved, this location will be used to verify the proximity of users when they mark their attendance. Ensure that the location is correct as it will directly impact attendance functionality.
        """
    
    static let No_data_found = "No Data Found!".translated()
    static let Notice_Display_Date_Range = "Notice Display Date Range"
    static let all = "All".translated()
    static let edit = "Edit".translated()

}


struct ChangePasswordStringFile{
    
    static let Enter_the_new_password = "Enter the new password".translated()
    static let Enter_the_old_password = "Enter the old password".translated()
    static let create_newpassword = "Create the new password".translated()
    static let confirm_password = "Re-enter the new  password".translated()
    static let change_password = "Change password".translated()
    static let Reset_password = "Reset password".translated()
}
struct OTPScreenStringFile{
    
    static let Resend = "Resend"
}
struct RatingCellStringFile{
    
    static let Bad =  "Bad".translated()
    static let Not_bad =  "Not bad".translated()
    static let Better =  "Better".translated()
    static let Nice =  "Nice".translated()
    static let Well_done =  "Well done".translated()
    static let Excellent =  "Excellent".translated()
    static let Good =  "Good".translated()
    
}
struct PiechartCvcellStringFile{
    
    static let SchoolStrength = "School Strength".translated()
    static let TotalStrength = "Total Strength".translated()
    static let StaffStrength = "Staff's count".translated()
    static let boy  = "Boy's count".translated()
    static let  girls = "Girl's count".translated()
}
struct TexviewStringFile{
    
    static let Enter_video_Description = "Enter Video Description".translated()
    static let Enter_Chat_Description = "Type your message here...".translated()
    static let certificateReason = "Reason for certificate".translated()
    static let Enter_Meeting_Description = "Enter Meeting Description".translated()
    static let Enter_Homework_Description = "Enter Homework Description".translated()
    static let Enter_Assignment_Description = "Enter Assignment Description".translated()
}
struct textFieldStringFile{
    
    static let Upload_Video = "Upload Video".translated()
    static let Click_To_Choose_video = "Click To Choose Video From File".translated()
    static let Enter_Video_Title = "Enter Video Title".translated()
}



struct StringsName {
   
    var appname  = ""
    static var Home = "Home"
    static var Help = "Help"
    static var Settings = "Settings"
    static  var Profile = "Profile"
 
}



extension String {
    /// Translates the string using the language bundle defined in `UserDefaults`.
    ///
    ///
    func translated() -> String {
        let defaults = UserDefaults.standard
        
        // Retrieve the language code saved in UserDefaults
        if let languageCode = defaults.string(forKey: DefaultsKeys.Language),
           let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            
    
            // Translate using the specific language bundle
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        
        // Return the key itself if no translation is available
        return self
    }
}


struct DefaultsKeys {
    static let countryId = "countryId"
    static let LoginId = "LoginId"
    static let Language = "Language"
    static let  mobileNumber = "mobileNumber"
    static let  password = "pass"
    
    
}


class AwsCredentials {
 
 static var bucketNameIndia = "schoolchimes-files-india"
 static var bucketNameBangkok = "schoolchimes-files-bangkok"
 static var UploadProfileBucket = "schoolchimes-student-images"
 static var uploadprofileBrowes = "schoolchimes-docs"
 static var CognitoPoolID = "ap-south-1:a8650d2e-79d6-4668-85db-110e9917583f"

}

struct AttachmentTypeString {
    
    static var VIDEO = "VIDEO"
    static var IMAGE = "IMAGE"
    static var DOCUMENT = "DOCUMENT"
}

struct FilterString {
    
    static var All = "All"
    static var Text = "Text"
    static var Image = "Image"
    static var Document = "Document"
}

struct DateFormatString {
    
    static var Day_and_date = "EEE dd"
    static var Date_Day_month_year = "d EEE, MMM yyyy" 
    static var StandardFormat = "dd MMM yyyy"
    static var DayStandardFormat = "EEE, dd MMM yyyy"
}


class LessonplanStringFile {
    static let allClasses = "All Classes".translated()
    static let myClasses = "My Classes".translated()
    static let editLessonPlan = "Edit Lesson Plan".translated()
    static let itemsCompleted = "items completed".translated()
    static let yetToStart = "Yet to Start".translated()
    static let inProgress = "In Progress".translated()
}

struct ExamStringFile{
    
    static var viewMarks = "View Marks".translated()
    static var viewProgress = "View Progress".translated()
    static var overallGrade = "Overall Grade".translated()
    static var subjectAndMarks = "Subject & Marks".translated()
    static var otherActivities = "Other Activities".translated()
    static var examTimetable = "Exam Timetable".translated()
    static var examMarks = "Exam Marks".translated()
}

struct AttendanceString{
    
    static let attendance = "Attendance".translated()
    static let thisWeekStatus = "This week status".translated()
    static let leaveTaken = "Leave Taken".translated()
    static let ongoingDays = "Ongoing Days".translated()
    static let askLeave = "Ask Leave".translated()
    static let leaveRequests = "Leave Requests".translated()
    static let attendanceReport = "Attendance Report".translated()
    static let holidays = "Holidays".translated()
    static let newLeave = "New Leave".translated()
    static let type = "Type".translated()
    static let cause = "Cause".translated()
    static let session = "Session".translated()
    static let selectFromDate = "Select From Date".translated()
    static let selectToDate = "Select To Date".translated()
    static let firstHalf = "First Half".translated()
    static let secondHalf = "Second Half".translated()
    static let selectLeaveType = "Select Leave Type".translated()
    static let enterReason = "Enter Reason".translated()
    static let applyLeave = "Apply Leave".translated()
    static let approved = "Approved".translated()
    static let rejected = "Rejected".translated()
    static let waiting = "Waiting".translated()
    static let awaiting = "Awaiting".translated()
    static let generateOutpass = "Generate Outpass".translated()
    static let absent = "Absent".translated()
    static let noHolidaysFor = "No Holidays for".translated()
    static let holidaysFor = "Holidays for".translated()
    static let LeaveHistory = "Leave History".translated()
    static let notTaken = "Not Taken".translated()
    static let present = "Present".translated()
    static let holiday = "Holiday".translated()
    static let dayApplication = "Day Application".translated()
    static let editLeaveRequest = "Edit Leave Request".translated()
    static let updateFor = "Update for".translated()
    static let daysLeave = "Days Leave".translated()

}


struct PTMString{
    
    static let ptm = "PTM".translated()
    static let scheduleMeeting = "Schedule Meeting".translated()
    static let yourMeetings = "Your Meetings".translated()
    static let bookSlot = "Book Slot".translated()
    static let allSubjects = "All Subjects".translated()
    static let completedMeetings = "Completed Meetings".translated()
    static let upcomingMeetings = "Upcoming Meetings".translated()
    static let todayMeetings = "Today Meetings".translated()
    static let date = "Date".translated()
    static let time = "Time".translated()
    static let call = "Call".translated()
    static let cancel = "Cancel".translated()
    static let with = "With".translated()
    static let create = "Create".translated()
    static let meetingsToday = "You have %d Meetings Today".translated()
    static let minutes = "Minutes".translated()
    static let virtual = "Virtual".translated()
    static let duration = "Duration".translated()
    static let createMeeting = "Create Meeting".translated()
    static let purposeOfMeeting = "Purpose of Meeting".translated()
    static let selectMeetingMode = "Select Meeting Mode".translated()
    static let inPerson = "In person".translated()
    static let phoneCall = "Phone call".translated()
    static let pasteMeetingLink = "Paste meeting Link".translated()
    static let selectYourClasses = "Select Your Classes".translated()
    static let chooseAcademicYear = "Choose academic year :".translated()
    static let selectDateTime = "Select Date & Time".translated()
    static let selectDates = "Select Dates".translated()
    static let startWith = "Start with".translated()
    static let endWith = "End with".translated()
    static let durationAndBreak = "Duration & Break".translated()
    static let needBreakBetweenSlots = "Need Break between slots?".translated()
    static let breakAfter = "Break After".translated()
    static let slot = "Slot".translated()
    static let breakDuration = "Break Duration".translated()
    static let checkSlotAvailability = "Check Slot Availability".translated()
    static let min = "%d Minutes".translated()
    static let custom = "Custom".translated()
    static let minShort = "%d Min".translated()
}
