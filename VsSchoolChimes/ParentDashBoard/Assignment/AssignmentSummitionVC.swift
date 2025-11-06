//
//  AssignmentSummitionVC.swift
//  School Chimes
//
//  Created by Chandhru on 09/06/25.
//

import UIKit

class AssignmentSummitionVC: UIViewController,UITableViewDelegate,UITableViewDataSource, SelectedId{
    func selectId(id: String?, edit: Bool?) {
        if edit ?? false{
            if let selectedNotice = self.assignments?.first(where: { $0.id == id }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if #available(iOS 14.0, *) {
                        let vc = SubmitVC()
                        vc.editReport = selectedNotice
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.deleteEvent(id: id)
            }
        }
    }
    
    
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var MenuName: UILabel!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var noDtaImg: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var sumitionList: UITableView!
    var assignments: [Submission]?
    var titleName:String?
    var subject:String?
    var id:String?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    let transitionDelegate = TransitioningDelegate()
    var submissions_details: [SubmissionDetail]?
    let alert = CustomAlert()
    var submitedList = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = studentDetails?.name ?? ""
        let standard = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        studentNameLbl.configureAsBackTitle(firstLine: name, secondLine: standard)
        MenuName.text = "My Submission"
        noDtaImg.isHidden = true
        nodataLbl.isHidden = true
        sumitionList.delegate = self
        sumitionList.dataSource = self
        sumitionList.register(UINib(nibName: "SubmissionTVC", bundle: nil), forCellReuseIdentifier: "SubmissionTVC")
        if !submitedList{
            ReadStatusUpdate()
        }
        
    }

    func ReadStatusUpdate(){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_my_submissions, parameters: ["id":id ?? ""], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_child_Details()?.access_token ?? "") { [self] (result : Result<SubmissionResponse,Error>) in
            
            switch result {
            case .success(let SuccessMessage):
                DispatchQueue.main.async { [self] in
                    assignments = SuccessMessage.data
                    noDtaImg.isHidden = !(SuccessMessage.data?.isEmpty ?? false)
                    nodataLbl.isHidden = !(SuccessMessage.data?.isEmpty ?? false)
                    nodataLbl.text = SuccessMessage.message
                    sumitionList.reloadData()
                }
            case .failure(let error):
                
                DispatchQueue.main.async {
                    self.assignments = []
                    self.sumitionList.reloadData()
                    print(error.localizedDescription)
                }
            }
        }
    }
    func deleteEvent(id: String?) {
        guard let targetID = id, !targetID.isEmpty else {
            print("❌ Invalid assignment ID")
            return
        }
        
        alert.showAlertCancel(
            title: AlertstringFile.Confirm,
            message: AlertstringFile.deletemessage,
            actionLbl1: AlertstringFile.delete,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                APIService.shared.makeApi(
                    url: ServiceUrl.comm_api_assignment_delete_submission,
                    parameters: ["id": targetID],
                    type: ApitTypeSringFile.PUT,
                    token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
                ) { [weak self] (result: Result<ResetPasswordSuc, Error>) in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let response):
                            if response.status == true {
                                CustomAlert.showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: response.message ?? "Deleted successfully.",
                                    on: self
                                ) {
                                    self.assignments?.removeAll { $0.id == targetID }
                                    
                                    if self.assignments?.isEmpty == true {
                                        self.dismiss(animated: true)
                                    } else {
                                        self.sumitionList.reloadData()
                                    }
                                }
                            } else {
                                self.alert.showAlert(
                                    title: AlertstringFile.Failed,
                                    message: response.message ?? "Failed to delete the assignment.",
                                    on: self
                                )
                            }
                            
                        case .failure(let error):
                            print("❌ Error deleting assignment: \(error.localizedDescription)")
                            self.alert.showAlert(
                                title: "Error",
                                message: error.localizedDescription,
                                on: self
                            )
                        }
                    }
                }
            },
            onNo: {
                print("User canceled deletion")
            }
        )
    }

    @IBAction func BackBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return submitedList ? submissions_details?.count ?? 0 : assignments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sumitionList.dequeueReusableCell(withIdentifier: "SubmissionTVC", for: indexPath) as! SubmissionTVC
        if submitedList {
            if let data = submissions_details?[indexPath.row],
               let submittedDate = data.submitted_on?.submissionTimeDisplay() {
                
                let (timeAgo, dateString) = submittedDate
                cell.assignmentTitle.text = titleName
                cell.subjectName.text = subject
//                cell.date.text = dateString
                cell.FilesUrl = data.file_path
//                cell.timeLeft.text = "Submited: \(timeAgo)"
                if let dateString = data.submitted_on,
                   let formattedDate = dateString.convertToTargetDateFormat() {
                    cell.timeLeft.text = "Submitted: \(formattedDate)"
                } else {
                    cell.timeLeft.text = "Submitted: N/A"
                }
                cell.descriptionLbl.text = data.description
                cell.loadFiles(into: cell, files: data.file_path ?? [])
            }
            return cell
        }else{
            if let data = assignments?[indexPath.row]{
                if let (timeAgo, dateString) = data.submitted_on?.submissionTimeDisplay(){
//                    cell.date.text = dateString
//                    cell.timeLeft.text = "Submited: \(timeAgo)"
                    if let dateString = data.submitted_on,
                       let formattedDate = dateString.convertToTargetDateFormat() {
                        cell.timeLeft.text = "Submitted: \(formattedDate)"
                    } else {
                        cell.timeLeft.text = "Submitted: N/A"
                    }
                }
                cell.assignmentTitle.text = titleName
                cell.subjectName.text = subject
                
                cell.FilesUrl = data.file_path
                cell.loadFiles(into: cell, files: data.file_path ?? [])
                cell.descriptionLbl.text = data.description
                cell.edit(edit:true, delete: true, selectedId: data.id ?? "")
                cell.delegate = self
            }
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row >= 0 else { return }
        
        let cellFrameInSuperview = tableView.rectForRow(at: indexPath)
        let convertedFrame = tableView.convert(cellFrameInSuperview, to: view)
        
        let detailVC = PrivewVc()
        
        if submitedList {
            guard let submission = submissions_details?[indexPath.row] else { return }
            detailVC.attachmetList = submission.file_path
            detailVC.selectedDate = submission.submitted_on
            detailVC.descriptionString = submission.description
        } else {
            guard let assignment = assignments?[indexPath.row] else { return }
            detailVC.attachmetList = assignment.file_path
            detailVC.selectedDate = assignment.submitted_on
            detailVC.descriptionString = assignment.description
        }
        
        detailVC.titleString = titleName
        detailVC.subject_name = MenuStringFile.selectedMenuName
        detailVC.modalPresentationStyle = .custom
        
        transitionDelegate.originFrame = convertedFrame
        detailVC.transitioningDelegate = transitionDelegate
        
        present(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension String {
    func submissionTimeDisplay(format: String = "dd-MM-yyyy hh:mm:ss a") -> (String, String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = formatter.date(from: self) else {
            return ("Invalid time", "")
        }
        
        let now = Date()
        let calendar = Calendar.current
        let submittedDay = calendar.startOfDay(for: date)
        let currentDay = calendar.startOfDay(for: now)
        
        let components = calendar.dateComponents([.day], from: submittedDay, to: currentDay)
        let interval = now.timeIntervalSince(date)
        
        // Time part
        var timeAgo = ""
        if calendar.isDateInToday(date) {
            if interval < 60 {
                timeAgo = "Just now"
            } else if interval < 3600 {
                timeAgo = "\(Int(interval / 60)) min ago"
            } else {
                timeAgo = "\(Int(interval / 3600)) hr ago"
            }
        } else if let days = components.day {
            timeAgo = "\(days) Day\(days > 1 ? "s" : "") Ago"
        }
        
        // Date part
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        let dateString = dateFormatter.string(from: date)
        
        return (timeAgo, dateString)
    }
    func chatTimeDisplay() -> (String, String) {
        let possibleFormats = [
            "dd-MM-yyyy hh:mm a",
            "dd-MM-yyyy hh:mm:ss a",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd hh:mm a",
            "yyyy-MM-dd'T'HH:mm:ssZ"
        ]
        
        var date: Date? = nil
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        for format in possibleFormats {
            formatter.dateFormat = format
            if let parsedDate = formatter.date(from: self) {
                date = parsedDate
                break
            }
        }
        
        guard let date = date else {
            return ("Invalid time", "")
        }
        
        let now = Date()
        let calendar = Calendar.current
        let submittedDay = calendar.startOfDay(for: date)
        let currentDay = calendar.startOfDay(for: now)
        
        let components = calendar.dateComponents([.day], from: submittedDay, to: currentDay)
        let interval = now.timeIntervalSince(date)
        
        // Time ago part
        var timeAgo = ""
        if calendar.isDateInToday(date) {
            if interval < 60 {
                timeAgo = "Just now"
            } else if interval < 3600 {
                timeAgo = "\(Int(interval / 60)) min ago"
            } else {
                timeAgo = "\(Int(interval / 3600)) hr ago"
            }
        } else if let days = components.day {
            timeAgo = "\(days) Day\(days > 1 ? "s" : "") Ago"
        }
        
        // Date part
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        let dateString = dateFormatter.string(from: date)
        
        return (timeAgo, dateString)
    }

}

