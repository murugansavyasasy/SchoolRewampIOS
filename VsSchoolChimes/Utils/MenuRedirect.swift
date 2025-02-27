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
    
    var Imgitems : [String] = [ "Communication","ImagePdf","Upload Video","Notice Board","Request Leave","Assignment","Online Meeting","Homework","Attendance marking","Messages from management","Interaction with student","Lesson Plan","PTM","Events","School Needs","Very Important Info","Absentees Report","School strength","Daily Collection","Student Report","Fee Pending Report","Mark Your Attendance","Staff Wise Attendance Report"]
    
    var receiverItems : [String] = [ MenuStringFile.Communication,ReceiverMenuItems.Homework ,/*ReceiverMenuItems.ExamTest,*/ReceiverMenuItems.ExamMarks,ReceiverMenuItems.ImagePdf,ReceiverMenuItems.Video,ReceiverMenuItems.NoticeBoard,ReceiverMenuItems.Assignment,ReceiverMenuItems.OnlineMeeting,ReceiverMenuItems.AttendanceReport,ReceiverMenuItems.EventsHolidays,ReceiverMenuItems.RequestLeave,ReceiverMenuItems.FeeDetails,ReceiverMenuItems.InteractionWithStaff,ReceiverMenuItems.QuizExam,ReceiverMenuItems.LSRW,ReceiverMenuItems.ClassTimetable,ReceiverMenuItems.CertificateRequest,ReceiverMenuItems.PTM,ReceiverMenuItems.Map]
    
    var receiverImageItems : [String] = ["Communication","Homework" ,/*"ExamTest",*/"Exam Marks","ImagePdf","Video","Notice Board","receiver_assignment","online_meeting","attendance_report","Events","Request Leave","Fee Details","Interaction with Staff","QuizExam","LSRW","Class Timetable","Certificate Request","PTM","Map"]
    
    //MARK: SenderSideMenuViewContoller Starts
    
    func senderVideoNavigate(from viewController: UIViewController) {
        let vc = SenderSideVideoViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func senderHomeWorkNavigate(from viewController: UIViewController) {
        let vc = SenderSideHomeWorkViewController(nibName: nil, bundle: nil)
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
    
    func senderPtmNavigate(from viewController: UIViewController) {
        let vc = StaffPtmViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
        
    }
    
    func senderEventNavigate(from viewController: UIViewController) {
        let vc = EventPageVC(nibName: nil, bundle: nil)
        vc.page1 = EventsVC(nibName: nil, bundle: nil)
        vc.page2 = NoticeBoardVc(nibName: nil, bundle: nil)
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
        let vc = ExamCreatVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    func RecipientNavigat(from viewController: UIViewController){
        let vc = SelectRecipientVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
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
    //
    //    func senderLeaveRequestNavigate(from viewController: UIViewController) {
    //        let vc = SenderLeaveRqstVC(nibName: nil, bundle: nil)
    //        vc.modalPresentationStyle = .fullScreen
    //        viewController.present(vc, animated: true)
    //
    //    }
    
    
    func senderMarkAttendanceNavigate(from viewController: UIViewController) {
        let vc = MarkAttendenceVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    func senderAbsenteesNavigate(from viewController: UIViewController) {
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
    func dailyCollectionNavigate(from viewController: UIViewController) {
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
        let vc = ImagePdfVC(nibName: nil, bundle: nil)
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
        let vc = ExamTmTblVCViewController(nibName: nil, bundle: nil)
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
//        let vc = ChatVC(nibName: nil, bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
//        vc.getValue = getValue
//        viewController.present(vc, animated: true)
        let vc = InteractionVC(nibName: nil, bundle: nil)
        vc.passvalue = 1
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
        let vc = ExameMarVC(nibName: nil, bundle: nil)
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
    func ParantMapVC(from viewController: UIViewController){
        let vc = VsSchoolChimes.ParantMapVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
}

