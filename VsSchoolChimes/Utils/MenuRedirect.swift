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
    
    var items : [String] = [ "Communication","Image/Pdf","Video Upload","Circulars","Notice Board","Leave Requests","Assignment","Online Meeting","Homework","Schedule Exam/Test","Attendance marking","Messages from management","Interaction with student","Lesson Plan","PTM", "Text to Parents/Staff","School / Class Events","School Needs","Very Important Info"
                             
                             ,"Absentees Report","School strength","Daily Collection","Student Report","Fee Pending Report","Mark Your Attendance","Staff Wise Attendance Report"]
    
    //
    
    var Imgitems : [String] = [ "Communication","ImagePdf","Video Upload","Circulars","Notice Board","Leave Requests","Assignment","Online Meeting","Homework","Schedule ExamTest","Attendance marking","Messages from management","Interaction with student","Lesson Plan","PTM","Text to Parents/Staff","School / Class Events","School Needs","Very Important Info"
                                
                                ,"Absentees Report","School strength","Daily Collection","Student Report","Fee Pending Report","Mark Your Attendance","Staff Wise Attendance Report"]
    
    
    var receiverItems : [String] = [ "Communication","Homework" ,"Exam/Test","Exam Marks","Image/Pdf","Video Upload","Circulars","Notice Board","Assignment","Online Meeting","Attendance Report"
                                     
                                     ,"Events/Holidays","Request Leave","Fee Details","Images","Interaction with Staff","Quiz Exam","LSRW","Class Timetable","Certificate Request","PTM"]
    
    
    
    var receiverImageItems : [String] = [ "Communication","Homework" ,"Exam/Test","Exam Marks","Image/Pdf","Video Upload","Circulars","Notice Board","Assignment","Online Meeting","Attendance Report"
                                          
                                          ,"Events/Holidays","Request Leave","Fee Details","Images","Interaction with Staff","Quiz Exam","LSRW","Class Timetable","Certificate Request","PTM"]
    
    
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
        
//        let vc = SenderNoticeBoardVC(nibName: nil, bundle: nil)
//        
//        vc.modalPresentationStyle = .fullScreen
//        
//        viewController.present(vc, animated: true)
        
        let vc = EventPageVC(nibName: nil, bundle: nil)
        
        vc.page1 = SenderNoticeBoardVC(nibName: nil, bundle: nil)
        
        vc.page2 = NoticeBoardVc(nibName: nil, bundle: nil)
        
        //        vc.titleLbl = items[indexPath.row].translated()
        
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
        
        vc.page1 = SenderNoticeBoardVC(nibName: nil, bundle: nil)
        
        vc.page2 = NoticeBoardVc(nibName: nil, bundle: nil)
        
        //        vc.titleLbl = items[indexPath.row].translated()
        
        vc.modalPresentationStyle = .fullScreen
        
        viewController.present(vc, animated: true)
        
        
        
    }
    
    
    
    
    
    func senderLeaveRequestNavigate(from viewController: UIViewController) {
        
        let vc = StudentHistryVC(nibName: nil, bundle: nil)
        
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
    
    
    
    
    
    
    //
    //        func senderNewDailyNavigate(from viewController: UIViewController) {
    //
    //        let vc = NewDailyCollectionViewController(nibName: nil, bundle: nil)
    //
    //        vc.modalPresentationStyle = .fullScreen
    //
    //            viewController.present(vc, animated: true)
    
    
    
    
    
    
    
    
    
    
    
    func receiverVideoNavigate(from viewController: UIViewController) {
        
        let vc = VideoVC(nibName: nil, bundle: nil)
        
        vc.modalPresentationStyle = .fullScreen
        
        viewController.present(vc, animated: true)
        
        
        
    }
    
    func receiverCommunicationNavigate(from viewController: UIViewController) {
        
        let vc = ComunicationVC(nibName: nil, bundle: nil)
        
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
        
        let vc = SenderNoticeBoardVC(nibName: nil, bundle: nil)
        
        vc.modalPresentationStyle = .fullScreen
        
        viewController.present(vc, animated: true)
        
        
        
    }
    
    
    
    
    
    func receiverAssignmentNavigate(from viewController: UIViewController) {
        
        let vc = PageVC(nibName: nil, bundle: nil)
        
        vc.modalPresentationStyle = .fullScreen
        
        viewController.present(vc, animated: true)
        
        
        
    }
    
    func receiverLeaveRequestNavigate(from viewController: UIViewController) {
        
        let vc = StudentHistryVC(nibName: nil, bundle: nil)
        
        vc.modalPresentationStyle = .fullScreen
        
        viewController.present(vc, animated: true)
        
        
        
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
    
}
