//
//  AssignmentPriview.swift
//  School Chimes
//
//  Created by Chandhru on 08/08/25.
//

import UIKit

class AssignmentPriview: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchDelegate, AssignmentDetailTVCDelegate {
    func didSelectAttachment(at index: Int, allAttachments: [FilePath], subjectName: String) {
        
        let imageVC = ImageShowVc(nibName: nil, bundle: nil)
        imageVC.fileURL = allAttachments
        imageVC.subjectName = data?.subject ?? ""
        imageVC.scrollIndex = IndexPath(index:index)
        imageVC.index = index
        imageVC.modalPresentationStyle = .fullScreen
        present(imageVC, animated: true)
    }
    
    func searchText(_ searchText: String) {
        print(searchText)
        
        if searchText == "All" {
            filterAssignment = submittedAssignment
            selectedAssignment = submittedAssignment
        }
        else if searchText == "Submited" {
            filterAssignment = submittedAssignment.filter {
                ($0.submit_status ?? "") != "NOTSUBMITTED"
            }
            selectedAssignment = filterAssignment
        }
        else if searchText == "Pending" {
            filterAssignment = submittedAssignment.filter {
                ($0.submit_status ?? "") == "NOTSUBMITTED"
            }
            selectedAssignment = filterAssignment
        }
        else if searchText == "true" {
            assignmentTable.endUpdates()
            assignmentTable.beginUpdates()
        }else if searchText.isEmpty {
            filterAssignment = selectedAssignment
        }else {
            filterAssignment = selectedAssignment.filter {
                ($0.student_name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.standard?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.section?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        assignmentTable.reloadSections(IndexSet(integer: 3), with: .automatic)
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var assignmentTable: UITableView!
    // MARK: - Properties
    var data: Report?
    var submittedAssignment: [StudentSubmission] = []
    var filterAssignment: [StudentSubmission] = []
    var selectedAssignment: [StudentSubmission] = []
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var userNameValue:String?
    var sectionValue:String?
    var reciver = false
    var onDismiss: (() -> Void)?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        if data?.is_unread ?? false{
            ReadStatusUpdate(type: "ASSIGNMENT", detail_id: data?.id ?? "")
        }
        getAssignment()
        let Name = userNameValue ?? ""
        let Standard = sectionValue ?? ""
        userName.configureAsBackTitle(firstLine: Name, secondLine: Standard)
    }
    
    func ReadStatusUpdate(type: String,detail_id: String){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
            switch result {
            case .success(let SuccessMessage):
                if SuccessMessage.status == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        if user_inputs.clearTempData(){
                            let parms = [ "mobile_number": UserDefaultFileManager.get_staff_Details()?.mobile_no ?? "",
                                          "activity": "VIEW_ASSIGNMENT",
                                          "user_type": 1,
                                          "menu_id": Menu_id.staffSelectedMenuId] as [String : Any]
                            self?.paketApiCall(params:parms)
                            self?.onDismiss?()
                        }
                    }
                }
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    func paketApiCall(params:[String:Any]){
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {

                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(response.message, duration: 2.0, position: .bottom)
                    }
                case .failure(let error):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                    }
                }
            }
        }
    }
    // MARK: - TableView Setup
    private func setupTableView() {
        assignmentTable.register(UINib(nibName: "AssignmentDetailTVC", bundle: nil), forCellReuseIdentifier: "AssignmentDetailTVC")
        assignmentTable.register(UINib(nibName: "SubmitedStudentTVC", bundle: nil), forCellReuseIdentifier: "SubmitedStudentTVC")
        assignmentTable.register(UINib(nibName: "AssignmentsearchTVC", bundle: nil), forCellReuseIdentifier: "AssignmentsearchTVC")
        assignmentTable.register(UINib(nibName: "PreviewTargetTVC", bundle: nil), forCellReuseIdentifier: "PreviewTargetTVC")
        // Keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide),name: UIResponder.keyboardWillHideNotification, object: nil)
        assignmentTable.delegate = self
        assignmentTable.dataSource = self
        assignmentTable.tableFooterView = UIView()
    }
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let bottomInset = keyboardFrame.height - view.safeAreaInsets.bottom + 190
            assignmentTable.contentInset.bottom = bottomInset
            
            if #available(iOS 13.0, *) {
                assignmentTable.verticalScrollIndicatorInsets.bottom = bottomInset
            } else {
                assignmentTable.scrollIndicatorInsets.bottom = bottomInset
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        assignmentTable.contentInset.bottom = 0
        
        if #available(iOS 13.0, *) {
            assignmentTable.verticalScrollIndicatorInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        } else {
            assignmentTable.scrollIndicatorInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
    func getAssignment() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_submissions_list,
            parameters: ["id": data?.id ?? "", "type": "TOTAL"],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<StudentSubmissionResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        self?.submittedAssignment = response.data ?? []
                        self?.filterAssignment = response.data ?? []
                        self?.assignmentTable.reloadData()
                        //                        self?.updateCountLabels()
                    }
                } else {
                    DispatchQueue.main.async {
                        //                        // Handle API error response
                        //                        self?.showAlert(message: response.message ?? "Failed to load assignments")
                        self?.assignmentTable.reloadData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                    //                    self?.showAlert(message: "Network error occurred. Please try again.")
                    self?.assignmentTable.reloadData()
                }
            }
        }
    }
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return reciver ? 1 : 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reciver {
            return 1
        }else{
            if section == 3 {
                return filterAssignment.count
            } else {
                return  1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
                case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentDetailTVC", for: indexPath) as? AssignmentDetailTVC else {
                return UITableViewCell()
            }
            if let report = data{
                cell.configureCell(with: report, attachments: report.file_path ?? [])
            }
            cell.delegate = self
            return cell
                case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewTargetTVC", for: indexPath) as? PreviewTargetTVC else {
                return UITableViewCell()
            }
            cell.confic(TargetType: data?.target_type ?? "", id: data?.id ?? "")
            return cell
                case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentsearchTVC", for: indexPath) as? AssignmentsearchTVC else {
                return UITableViewCell()
            }
            cell.allBtn.setTitle("All Students(\(data?.total_count ?? 0))", for: .normal)
            cell.submitedBtn.setTitle("Submitted(\(data?.submitted_count ?? 0))", for: .normal)
            cell.pendingBtn.setTitle(
                "Pending(\((data?.total_count ?? 0) - (data?.submitted_count ?? 0)))",
                for: .normal
            )
            cell.delegate = self
            return cell
                case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitedStudentTVC", for: indexPath) as? SubmitedStudentTVC else {
                return UITableViewCell()
            }
            let student = filterAssignment[indexPath.row]
            cell.studentNameLbl.text = student.student_name
            if let firstLetter = student.student_name?.first {
                cell.initialBtn.setTitle(String(firstLetter).uppercased(), for: .normal)
            } else {
                cell.initialBtn.setTitle("-", for: .normal) // fallback if name is nil or empty
            }
            cell.standerdScection?.text = "\(student.standard ?? "") - \(student.section ?? "")"
            let isNotSubmitted = student.submit_status == "NOTSUBMITTED"
            let statusText = isNotSubmitted ? "Pending" : "Submitted"
            let statusColor = isNotSubmitted ? UIColor.brown : UIColor.systemGreen
            
            // Background color & corner radius
            cell.statusView.backgroundColor = isNotSubmitted ? UIColor.systemGray5 : UIColor.systemGray6
            cell.statusView.layer.cornerRadius = 8
            cell.statusView.clipsToBounds = true
            
            // Attributed text
            let fullText = NSMutableAttributedString(
                string: statusText,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13, weight: .medium),
                    .foregroundColor: statusColor
                ]
            )
            
            cell.statusView.setAttributedTitle(fullText, for: .normal)
            
            // Resize icon to match text height
            let iconSize: CGFloat = 13 // same as text size
            let iconConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .medium)
            let icon = UIImage(
                systemName: isNotSubmitted ? "arrowshape.down.circle" : "checkmark.circle.fill",
                withConfiguration: iconConfig
            )
            let lastSubmittedOn = student.submissions_details?.last?.submitted_on
            let date: String?
            let txt: String
            
            if let submittedOn = lastSubmittedOn, !submittedOn.isEmpty {
                date = submittedOn
                txt = "Submitted"
            } else {
                date = data?.end_date
                txt = "Due Date"
            }
            
            cell.submitDate.text = "\(txt): \(formattedDateStatus(from: date ?? ""))"
            cell.statusView.setImage(icon, for: .normal)
            cell.statusView.tintColor = statusColor
            
            // Optional: Adjust image & title spacing
            cell.statusView.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            cell.statusView.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            
            return cell
                default:
                    return UITableViewCell()
                }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Only handle tap for Section 2 (submitted students list)
        guard indexPath.section == 3,
              indexPath.row < filterAssignment.count else { return }
        
        let selectedStudent = filterAssignment[indexPath.row]
        if selectedStudent.submit_status == "NOTSUBMITTED" {
            let alert = UIAlertController(
                title: "No Submission",
                message: "\(selectedStudent.student_name ?? "This student") has not submitted the assignment yet.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Open AssignmentSummitionVC with proper data
        let submissionVC = AssignmentSummitionVC(nibName: nil, bundle: nil)
        submissionVC.subject = data?.subject
        submissionVC.titleName = data?.title
        submissionVC.submitedList = true
        submissionVC.submissions_details = selectedStudent.submissions_details
        submissionVC.modalPresentationStyle = .fullScreen
        
        present(submissionVC, animated: false)
    }
    
    // MARK: - TableView Delegate (Optional)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

