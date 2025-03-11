//
//  AppStringFile.swift
//  VsSchoolChimes
//
//  Created by Admin on 06/12/24.
//

import Foundation

class MenuStringFile{
    
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
    static let LeaveRequests = "Leave Requests"
    static let Assignment = "Assignment"
    static let OnlineMeeting = "Online Meeting"
    static let Homework = "Homework"
    static let ScheduleExamTest = "Schedule Exam/Test"
    static let AttendanceMarking = "Attendance marking"
    static let MessagesFromManagement = "Messages from management"
    static let InteractionWithStudent = "Interaction with student"
    static let LessonPlan = "Lesson Plan"
    static let PTM = "PTM"
    static let TextToParentsStaff = "Text to Parents/Staff"
    static let SchoolClassEvents = "Events"
    static let EventsHolidays = "Events"
    static let SchoolNeeds = "School Needs"
    static let VeryImportantInfo = "Very Important Info"
    static let AbsenteesReport = "Absentees Report"
    static let SchoolStrength = "School strength"
    static let DailyCollection = "Daily Collection"
    static let StudentReport = "Student Report"
    static let FeePendingReport = "Fee Pending Report"
    static let MarkYourAttendance = "Mark Your Attendance"
    static let StaffWiseAttendanceReport = "Staff Wise Attendance Report"
    static let LSRW = "LSRW"
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
    static let Map = "Map"
    
}

class AlertstringFile{
    
    static let title = "Confirm Action".translated()
    static let Confirm = "Confirm".translated()
    static let AreYouSureYouWantToProceed = "Are you sure you want to proceed?".translated()
    static let ConfirmLeave = "Are you sure want to ".translated()
    static let ConfirmLogout = "Are you sure you want to Logout".translated()
    static let No = "No".translated()
    static let Submit = "Submit".translated()
    static let Successfully_password_created = "Successfully password created".translated()
    static let Password_Missmatched = "Password Missmatched".translated()
    
    static let Enter_the_new_password = "Enter the new password".translated()
    static let Enterthe_confirm_password = "Enter the confirm password".translated()
    static let Enter_valid_Mobile = "Enter valid Mobile".translated()
    static let Invalid = "Invalid Password".translated()
    static let Enter_the_10_digit = "Enter the 10 digit mobile number".translated()
    static let Terms_And_Conditions = "Please agree to the terms and conditions".translated()
    static let Enter_Otp = "Enter the otp".translated()
    static let OK = "Ok".translated()
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
    static let Cancel = "Cancel".translated()
    static let  LeaveRequest = " Leave Request".translated()
  
   
    static let Mark_All_as_Present = "Mark All as Present?"
   
    static let Failed_to_upload_video = "Failed to upload video".translated()
    static let Please_choose_video = "Please choose a Video".translated()
    static let Fill_All_Required_Fields = "Fill All Required Fields".translated()
    
    static let invalidSelection = "invalidSelection".translated()
    static let selectDatesWithinMonth = "selectDatesWithinMonth".translated()
    
    
}

struct classTimeTableStrings {
    static let weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    static let weekDaysShort = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat","Sun"]
    static let subjects = ["Mathematics", "Science", "History", "English", "Geography", "Physics", "Chemistry", "Biology", "Computer Science", "Art"]

    static var timeArr = ["8 AM", "10 AM",  "12 PM",  "2 PM",  "4 PM",  "6 PM",  "8 PM","10 PM"]
    static var toTimeArr = [ "9 AM",  "11 AM", "1 PM",  "3 PM",  "5 PM",  "7 PM", "9 PM", "11 PM"]
    static let timeGet = "10 AM"
    
    
    static var timetable : [SubItem] = [
        SubItem.init(subName: "Maths", subDuration: "30 minutes", techer: "Viji"),
        SubItem.init(subName: "Science", subDuration: "45 minutes", techer: "Banumathi"),
        SubItem.init(subName: "History", subDuration: "2 hours", techer: "Priya"),
        SubItem.init(subName: "English", subDuration: "1 hour", techer: "Keerthana"),

        SubItem.init(subName: "English", subDuration: "1 hour", techer: "Seetha"),
        SubItem.init(subName: "PET", subDuration: "40 minutes", techer: "Padma"),
        SubItem.init(subName: "Tamil", subDuration: "50 minutes", techer: "Thangam"),
        SubItem.init(subName: "Social Science", subDuration: "35 minutes", techer: "Suchithra")
        ]
        
}

class MenuTapbar{
    static let FAQ = "FAQ".translated()
    static let Rate_Us = "Rate Us".translated()
    static let Report_a_bug = "Report a bug".translated()
    static let Settings = "Settings"
    static let Contact_Us = "Contact Us".translated()
    static let Notifications = "Notifications".translated()
    static let ComposeNotifications = "Compose NoticeBoard".translated()
    static let Video = "Video"//.translated()
    static let Assignment = "Assignment".translated()
    static let Noticeboard = "Noticeboard".translated()
    static let Help = "Help".translated()
    
    
    
}

class SettingStringFile{
    
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
    
    
}

class CommonStringFile{
    
    static let Search = "Search"
    static let seeLess = "See less"
    static let seemore = " See more"
    static let selectedText = " selected Text"
    static let RollNoASC = "Roll No ASC"
    static let RollNoDESC = "Roll No DESC"
    static let NameASC = "Name ASC"
    static let NameDESC = "Name DESC"
    static let Present = "Present"
    static let Absent = "Absent"
    static let getAllStudent = "get All Student"
    static let Logout = "Logout"
    
    static let RollNo = "Roll No"
    static let Name = "Name"
    static let Status = "Status"
    static let Section = "Section"
    static let Standard = "Standard"
    static let Filter = "Filter"
    static let UploadAttachment = "Upload Attachment"
    static let UploadImagepdf = "Upload Image/Pdf"
    static let UploadImagepdfoptional = "Upload Image/Pdf (Optional)"
    static let Description = "Description"
    static let Groups = "Groups"
    static let Sectionorstudent = "Section or student"
    static let Standardorsection = "Standard or section"
    static let FromTime = "From Time"
    static let Schedule = "Schedule"
    static let ToTime = "To Time"
    static let Emergencyvoicemessages = "Emergency voice messages"
    static let VoiceMessage = "voice"
    static let TextMessage = "text"
    static let ScheduleCall = "Schedule Call"
    static let EnterTextHere = "Enter Text Here"
    static let BacktoTextMessage = "Back To TextMessage"
    static let BackToVoiceMessage = "Back To Voice Message"
    static let Venue = "Venue"
    static let AddPhotos = "Add Photos"
    static let EventDetails = "Event Details"
    static let EventTitle = "Event Title"
    static let Optional = "(Optional)"
    static let AddPhotos1 = "Add Photos1"
    static let egChennai = "egChennai"
    static let egYogaEvent = "egYogaEvent"
    static let completed = "completed"
    static let pending = "pending"
    static let Enterbugs = "Enter bugs"
    static let Profile = "Profile"
    static let AboutStudent = "About Student"
    static let Contactdetails = "Contact details"
    static let Registernumber = "Register number"
    static let FamilyDetails = "Family Details"
    static let Fathername = "Father name"
    static let Fatheroccupation = "Father occupation"
    static let Mothername = "Mother name"
    static let Motheroccupation = "Mother occupation"
    static let SecondaryPhoneno = "Secondary Phone no"
    static let ContactSupport = "Contact Support"
    static let TermsandConditions = "Terms and Conditions"
    static let scheduleExam = "schedule Exam"
    static let From = "From"
    static let To = "To"
    static let Days = "Days"
    static let Day = "Day"
    static let CreateLeaveRequest = "Create Leave Request"
    static let LeaveRequestInfo = "LeaveRequestInfo"
    static let Parent = "Parent"
    static let Principal = "Principal"
    static let LoginAsTeacherOrParent = "Login As Teacher Or Parent"
    static let LoginAsPrincipalOrParent = "Login As Principal Or Parent"
    static let ChooseYourRole = "Choose Your Role"
    static let Proceed = "Proceed"
    static let CreateEvent = "Create Event"
    static let Title = "Title"
    static let AddPdfoptional = "Add Pdf (Optional?)"
    static let AddPdf = "Add Pdf"

}


class ChangePasswordStringFile{
    
    static let Reset_the_new_password = "Reset the new password".translated()
}
class OTPScreenStringFile{
    
    static let Resend = "Resend"
}
class RatingCellStringFile{
    
    static let Bad =  "Bad".translated()
    static let Not_bad =  "Not bad".translated()
    static let Better =  "Better".translated()
    static let Nice =  "Nice".translated()
    static let Well_done =  "Well done".translated()
    static let Excellent =  "Excellent".translated()
    static let Good =  "Good".translated()
    
}
class PiechartCvcellStringFile{
    
    static let SchoolStrength = "School Strength".translated()
    static let TotalStrength = "Total Strength".translated()
    static let StaffStrength = "Staff's count".translated()
    static let boy  = "Boy's count".translated()
    static let  girls = "Girl's count".translated()
}
class TexviewStringFile{
    
    static let Enter_video_Description = "Enter Video Description".translated()
    static let Enter_Chat_Description = "Type your message here...".translated()
    static let certificateReason = "Reason for certificate".translated()
    static let Enter_Meeting_Description = "Enter Meeting Description".translated()
    static let Enter_Homework_Description = "Enter Homework Description".translated()
    static let Enter_Assignment_Description = "Enter Assignment Description".translated()
}
class textFieldStringFile{
    
    static let Upload_Video = "Upload Video".translated()
    static let Click_To_Choose_video = "Click To Choose Video From File".translated()
    static let Enter_Video_Title = "Enter Video Title".translated()
}
