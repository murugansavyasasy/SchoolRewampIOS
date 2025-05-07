//
//  MenuRedirect.swift
//  VsSchoolChimes
//
//  Created by Admin on 11/12/24.
//

import Foundation
import UIKit



@available(iOS 14.0, *)

class MenuRedirectHandler {
    
    
    
    static let shared = MenuRedirectHandler()
    
    
    static func createInstance() -> MenuRedirectHandler {
        
        return MenuRedirectHandler()
        
    }
    var getValue = 1
    var items : [String] = [ MenuStringFile.Communication,MenuStringFile.ImagePdf,MenuStringFile.VideoUpload,MenuStringFile.NoticeBoard,MenuStringFile.LeaveRequests,MenuStringFile.Assignment,MenuStringFile.OnlineMeeting,MenuStringFile.Homework,MenuStringFile.AttendanceMarking,MenuStringFile.MessagesFromManagement,MenuStringFile.InteractionWithStudent,MenuStringFile.LessonPlan,MenuStringFile.PTM,MenuStringFile.SchoolClassEvents,MenuStringFile.SchoolNeeds,MenuStringFile.VeryImportantInfo,MenuStringFile.AbsenteesReport,MenuStringFile.SchoolStrength,MenuStringFile.DailyCollection,MenuStringFile.StudentReport,MenuStringFile.FeePendingReport,MenuStringFile.MarkYourAttendance,MenuStringFile.StaffWiseAttendanceReport]
    
    
    var Imgitems: [MenuImage] = [
        // MenuImage(id: 0, name: "Communication"),
        MenuImage(id: 1, name: "Absentees Report"),
        MenuImage(id: 2, name: "Assignment"),
        MenuImage(id: 3, name: "Attendance marking"),
        MenuImage(id: 4, name: "Attendance Report"),
        MenuImage(id: 5, name: "Certificate Request"),
        MenuImage(id: 6, name: "Class Timetable"),
        MenuImage(id: 7, name: "Communication"),
        MenuImage(id: 8, name: "Daily Collection"),
        MenuImage(id: 9, name: "Events"),
        MenuImage(id: 10, name: "ExamTest"),
        MenuImage(id: 11, name: "ExamTest"),
        MenuImage(id: 12, name: "Fee Details"),
        MenuImage(id: 13, name: "PTM"),
        MenuImage(id: 14, name: "Fee Pending Report"),
        MenuImage(id: 15, name: "Homework"),
        MenuImage(id: 16, name: "Interaction with Staff"),
        MenuImage(id: 17, name: "Interaction with student"),
        MenuImage(id: 18, name: "Request Leave"),
        MenuImage(id: 19, name: "Lesson Plan"),
        MenuImage(id: 20, name: "LSRW"),
        MenuImage(id: 21, name: "Mark Your Attendance"),
        MenuImage(id: 22, name: "Messages from management"),
        MenuImage(id: 23, name: "Notice Board"),
        MenuImage(id: 24, name: "Online Meeting"),
        MenuImage(id: 25, name: "PTM"),
        MenuImage(id: 26, name: "PTM"),
        MenuImage(id: 27, name: "QuizExam"),
        MenuImage(id: 28, name: "PTM"),
        MenuImage(id: 29, name: "CalssEvent"),
        MenuImage(id: 30, name: "School Needs"),
        MenuImage(id: 31, name: "School strength"),
        MenuImage(id: 32, name: "PTM"),
        MenuImage(id: 33, name: "Staff Wise Attendance Report"),
        MenuImage(id: 34, name: "PTM"),
        MenuImage(id: 35, name: "Student Report"),
        MenuImage(id: 36, name: "important"),
        MenuImage(id: 37, name: "Your Profile"),
        MenuImage(id: 38, name: "ExamTest" ),
        MenuImage(id: 39, name: "Attachements"),
        MenuImage(id: 194, name: "Finance")
    ]


    

//    13    Fee Payment
//    14    Fee Pending Report
    
   
   
   
   
    
   
   
   
 
  
    
   
    

   
          
    
    var receiverItems : [String] = [ MenuStringFile.Communication,ReceiverMenuItems.Homework ,ReceiverMenuItems.ExamTest,ReceiverMenuItems.ExamMarks,ReceiverMenuItems.ImagePdf,ReceiverMenuItems.Video,ReceiverMenuItems.NoticeBoard,ReceiverMenuItems.Assignment,ReceiverMenuItems.OnlineMeeting,ReceiverMenuItems.AttendanceReport,ReceiverMenuItems.EventsHolidays,ReceiverMenuItems.RequestLeave,ReceiverMenuItems.FeeDetails,ReceiverMenuItems.InteractionWithStaff,ReceiverMenuItems.QuizExam,ReceiverMenuItems.LSRW,ReceiverMenuItems.ClassTimetable,ReceiverMenuItems.CertificateRequest,ReceiverMenuItems.PTM,ReceiverMenuItems.Map]
    
    var receiverImageItems : [String] = ["Communication","Homework" ,"ExamTest","Exam Marks","ImagePdf","Video","Notice Board","receiver_assignment","online_meeting","attendance_report","Events","Request Leave","Fee Details","Interaction with Staff","QuizExam","LSRW","Class Timetable","Certificate Request","PTM","MySchoolBus"]
    
    
    
    
    //MARK: COMMONPAGE FOR MULTIPLE SCHOOL LIST PAGE
    
    func SchoolListVc(from viewController: UIViewController) {
        let vc = SchoolListVC(nibName: nil, bundle: nil)
        vc.come_fromLogin = true
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    
    //MARK: SenderSideMenuViewContoller Starts
    
    func senderVideoNavigate(from viewController: UIViewController) {
        let vc = SenderSideVideoViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func senderHomeWorkNavigate(from viewController: UIViewController) {
//        let vc = SenderSideHomeWorkViewController(nibName: nil, bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
//        viewController.present(vc, animated: true)
        
        let vc = CommonPageVC(nibName: nil, bundle: nil)
        vc.page1 = SenderSideHomeWorkViewController(nibName: nil, bundle: nil)
        vc.page2 = SenderHomeWorkVC(nibName: nil, bundle: nil)
//        vc.titleLbl = "Notice Board".translated()
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
        
        
    }
    
    func senderCommunicationNavigate(from viewController: UIViewController) {
        let vc = ComunicationVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
        
    }
    
    func senderImgPDfNavigate(from viewController: UIViewController) {
        let vc = SenderImgPdfVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func senderNoticeboardNavigate(from viewController: UIViewController) {
        let vc = EventPageVC(nibName: nil, bundle: nil)
        vc.page1 = SenderNoticeBoardVC(nibName: nil, bundle: nil)
        vc.page2 = NoticeBoardVc(nibName: nil, bundle: nil)
        vc.titleLbl = "Notice Board".translated()
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
//    func senderPtmNavigate(from viewController: UIViewController) {
//        let vc = StaffPtmViewController(nibName: nil, bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
//        viewController.present(vc, animated: true)
//        
//    }
    func senderPtmNavigate(from viewController: UIViewController) {
        let vc = StaffPtmViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .fade
        transition.subtype = .fromTop
        viewController.view.window?.layer.add(transition, forKey: kCATransition)
        viewController.present(vc, animated: false, completion: nil) // animated: false to avoid default animation
    }
    
    func senderEventNavigate(from viewController: UIViewController) {
        let vc = EventPageVC(nibName: nil, bundle: nil)
        vc.page1 = EventsVC(nibName: nil, bundle: nil)
        vc.page2 = EventHistoryVC(nibName: nil, bundle: nil)
        vc.titleLbl = CommonStringFile.CreateEvent.translated()
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func senderLeaveRequestNavigate(from viewController: UIViewController) {
        let vc = SenderLeaveRqstVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
        
    }
    func ScheduleExamVCNavigat(from viewController: UIViewController){
       // let vc = ExamCreatVC(nibName: nil, bundle: nil)
        let vc = SenderAttachmentVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    func RecipientNavigat(from viewController: UIViewController){
//        let vc = SelectRecipientVC(nibName: nil, bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
//        viewController.present(vc, animated: true)
    }
    func senderAssignmentNavigate(from viewController: UIViewController) {
        let vc = SenderAssignmentTextViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
        
    }
    
    func senderOnlineNavigate(from viewController: UIViewController) {
        let vc = OnlineMeetingVC(nibName: nil, bundle: nil)
        vc.passvalue = 1
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func Senderchat(from viewController: UIViewController){
        let vc = InteractionVC(nibName: nil, bundle: nil)
        vc.passvalue = 2
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func senderLessonplanNavigate(from viewController: UIViewController) {
        let vc = LessonPlanVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }

    func senderStudentreportNavigate(from viewController: UIViewController) {
        let vc = ReportStudentListVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
     
        
    }
    func senderMarkAttendence(from viewController: UIViewController) {
        let vc = MarkAttendenceVC (nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
        
    }
    
    //
//        func senderLeaveRequestNavigate(from viewController: UIViewController) {
//            let vc = SenderLeaveRqstVC(nibName: nil, bundle: nil)
//            vc.modalPresentationStyle = .fullScreen
//            viewController.present(vc, animated: true)
//    
//        }
    
    
    func senderMarkAttendanceNavigate(from viewController: UIViewController) {
        let vc = LocationViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func senderAbsenteesReport(from viewController: UIViewController) {
        let vc = NewAbsenteesViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func senderFeePendingNavigate(from viewController: UIViewController) {
        let vc = PendingFeeReportViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
        
    }
    
    func senderSchoolStrength(from viewController: UIViewController) {
        let vc = SchoolStrengthVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
        
    }
    
    func senderMgmt(from viewController: UIViewController) {
        let vc = MessageFromManagementViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
        
    }
    
    
    
    func senderLocationNavigate(from viewController: UIViewController) {
        let vc = LocationViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func senderImportantInfoNavigate(from viewController: UIViewController) {
        let vc = ImportantInfoViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    func senderSchoolNeedsNavigate(from viewController: UIViewController) {
        let vc = ImportantInfoViewController(nibName: nil, bundle: nil)
        vc.Header = "School Needs"
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    func senderAttachment(from viewController: UIViewController) {
        let vc = SenderAttachmentVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    func senderDailyCollectionNavigate(from viewController: UIViewController) {
        let vc = NewDailyCollectionViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    func StaffWiseAttendance(from viewController: UIViewController) {
        let vc = LocationHistoryVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    
    //MARK: ResiverSideMenuViewContoller Starts
    
    
    func receiverVideoNavigate(from viewController: UIViewController) {
        let vc = VideoVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func receiverCommunicationNavigate(from viewController: UIViewController) {
        
        let vc = ParentCommunicationVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func receiverImgPdfNavigate(from viewController: UIViewController) {
        let vc = ReciverAttachmentrVC(nibName: nil, bundle: nil)
//        vc.passValue = 0
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func receiverPtmNavigate(from viewController: UIViewController) {
        let vc = PTMViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    @available(iOS 14.0, *)
    func receiverNoticeBoardNavigate(from viewController: UIViewController) {
        let vc = ParentNoticeBoardVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func receiverAssignmentNavigate(from viewController: UIViewController) {
        let vc = PageVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func receiverLeaveRequestNavigate(from viewController: UIViewController) {
        
    }
    
    func receiverExamTestNavigate(from viewController: UIViewController) {
        
        let vc = ExamDetailsVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func receiverLsrwNavigate(from viewController: UIViewController) {
        let vc = LsrwListShowViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func receiverclassTimeTable(from viewController: UIViewController) {
        //let vc = ClassTimeTableViewController(nibName: nil, bundle: nil)
        let vc = TimetableVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func receiverAttendenceMark(from viewController: UIViewController){
        
        
        
    }
    func receiverchat(from viewController: UIViewController){
        let vc = InteractionVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        //vc.getValue = getValue
        vc.passvalue = 1
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func receiverAttachment(from viewController: UIViewController){
        
        let vc = AttachmentVCViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func LeaveRquest(from viewController: UIViewController){
        let vc = NavigationVC(nibName: nil, bundle: nil)
        vc.page1 = LeveCreateVC(nibName: nil, bundle: nil)
        vc.page2 = LeveHistoryVC(nibName: nil, bundle: nil)
        vc.titleLbl = ReceiverMenuItems.RequestLeave.translated()
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
        
    }
    func receiverEvent(from viewController: UIViewController){
        let vc = EventResiverVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func receiverOnlineNavigate(from viewController: UIViewController) {
        let vc = OnlineMeetingVC(nibName: nil, bundle: nil)
        vc.passvalue = 2
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func resiverExamMark(from viewController: UIViewController){
//        let vc = ExameMarVC(nibName: nil, bundle: nil)
        let vc = ExamDetailsVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    func receiverCertificateRequest(from viewController: UIViewController){
        //let vc = CertificateRequestViewController(nibName: nil, bundle: nil)
        let vc = CertificateRequestVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func receiverHomework(from viewController: UIViewController){
        let vc = ReciverHomeworkVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    func receiverAttendancereport(from viewController: UIViewController){
        let vc = ReciverAttendanceReportVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    func QuizExam(from viewController: UIViewController){
        let vc = QuizVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    func parantMapVC(from viewController: UIViewController){
        let vc = ParantMapVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
}

struct MenuImage{
    let id:Int
    let name:String
}
