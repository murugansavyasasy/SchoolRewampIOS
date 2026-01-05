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
    

    // MARK: - IBOutlets
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var assignmentTable: UITableView!

    // MARK: - Properties
    var data: Report?
    var submittedAssignment: [StudentSubmission] = []
    var filterAssignment: [StudentSubmission] = []
    var selectedAssignment: [StudentSubmission] = []
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var userNameValue: String?
    var sectionValue: String?
    var reciver = false
    var onDismiss: (() -> Void)?
    var isNoDataFound = false
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        if data?.is_unread ?? false {
            ReadStatusUpdate(type: "ASSIGNMENT", detail_id: data?.id ?? "")
        }
        getAssignment()

        // Configure user name header
        let name = userNameValue ?? ""
        let standard = sectionValue ?? ""
        userName.configureAsBackTitle(firstLine: name, secondLine: standard)
    }

    // MARK: - Assignment Read Update
    func ReadStatusUpdate(type: String, detail_id: String) {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_communication_read_status_update,
            parameters: [
                ReadStatusUpdateStringFile.type: type,
                ReadStatusUpdateStringFile.detail_id: detail_id
            ],
            type: ApitTypeSringFile.POST,
            token: studentDetails?.access_token ?? "", isBaseUrl: true
        ) { [self] (result: Result<ReadStatusResponse, Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        guard let self = self else { return }
                        if user_inputs.clearTempData() {
                            let params: [String: Any] = [
                                "mobile_number": UserDefaultFileManager.get_staff_Details()?.mobile_no ?? "",
                                "activity": "VIEW_ASSIGNMENT",
                                "user_type": 1,
                                "menu_id": Menu_id.staffSelectedMenuId
                            ]
                            self.paketApiCall(params: params)
                            self.onDismiss?()
                        }
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func paketApiCall(params: [String: Any]) {
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: studentDetails?.access_token ?? "", isBaseUrl: true
        ) { (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    UIApplication.shared.windows.first?.makeToast(response.message, duration: 2.0, position: .bottom)
                case .failure(let error):
                    UIApplication.shared.windows.first?.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                }
            }
        }
    }

    // MARK: - Table Setup
    private func setupTableView() {
        assignmentTable.register(UINib(nibName: "AssignmentDetailTVC", bundle: nil), forCellReuseIdentifier: "AssignmentDetailTVC")
        assignmentTable.register(UINib(nibName: "SubmitedStudentTVC", bundle: nil), forCellReuseIdentifier: "SubmitedStudentTVC")
        assignmentTable.register(UINib(nibName: "AssignmentsearchTVC", bundle: nil), forCellReuseIdentifier: "AssignmentsearchTVC")
        assignmentTable.register(UINib(nibName: "PreviewTargetTVC", bundle: nil), forCellReuseIdentifier: "PreviewTargetTVC")

        assignmentTable.delegate = self
        assignmentTable.dataSource = self
        assignmentTable.tableFooterView = UIView()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let bottomInset = keyboardFrame.height - view.safeAreaInsets.bottom + 190
            assignmentTable.contentInset.bottom = bottomInset
            assignmentTable.verticalScrollIndicatorInsets.bottom = bottomInset
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        assignmentTable.contentInset.bottom = 0
        assignmentTable.verticalScrollIndicatorInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: false)
    }

    // MARK: - API
    func getAssignment() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_submissions_list,
            parameters: ["id": data?.id ?? "", "type": "TOTAL"],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<StudentSubmissionResponse, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    if response.status ?? false {
                        self.submittedAssignment = response.data ?? []
                        self.filterAssignment = response.data ?? []
                        self.selectedAssignment = response.data ?? []
                    }
                    self.assignmentTable.reloadData()
                }
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.assignmentTable.reloadData()
                }
            }
        }
    }
    func searchText(_ searchText: String) {
        print(searchText)
        
        if searchText == "All" {
            filterAssignment = submittedAssignment
            selectedAssignment = submittedAssignment
        } else if searchText == "Submited" {
            filterAssignment = submittedAssignment.filter { ($0.submit_status ?? "") != "NOTSUBMITTED" }
            selectedAssignment = filterAssignment
        } else if searchText == "Pending" {
            filterAssignment = submittedAssignment.filter { ($0.submit_status ?? "") == "NOTSUBMITTED" }
            selectedAssignment = filterAssignment
        } else if searchText == "true" {
            filterAssignment = selectedAssignment
        } else if searchText.isEmpty {
            filterAssignment = selectedAssignment
        } else {
            filterAssignment = selectedAssignment.filter {
                ($0.student_name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.standard?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.section?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        DispatchQueue.main.async {
            if self.assignmentTable.numberOfSections > 3 {
                UIView.performWithoutAnimation {
                    self.assignmentTable.reloadSections(IndexSet(integer: 3), with: .none)
                }
            } else {                self.assignmentTable.reloadData()
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return reciver ? 1 : 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reciver {
            return 1
        } else {
            if section == 3 {
                return filterAssignment.isEmpty ? 1 : filterAssignment.count
            } else {
                return 1
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentDetailTVC", for: indexPath) as? AssignmentDetailTVC else {
                return UITableViewCell()
            }
            if let report = data {
                cell.configureCell(with: report, attachments: report.file_path ?? [])
            }
            cell.delegate = self
            return cell

        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewTargetTVC", for: indexPath) as? PreviewTargetTVC else {
                return UITableViewCell()
            }
            cell.configure(targetType: data?.target_type ?? "", id: data?.id ?? "")
            return cell

        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentsearchTVC", for: indexPath) as? AssignmentsearchTVC else {
                return UITableViewCell()
            }
            cell.allBtn.setTitle("All Students(\(data?.total_count ?? 0))", for: .normal)
            cell.submitedBtn.setTitle("Submitted(\(data?.submitted_count ?? 0))", for: .normal)
            cell.pendingBtn.setTitle("Pending(\((data?.total_count ?? 0) - (data?.submitted_count ?? 0)))", for: .normal)
            cell.delegate = self
            return cell

        case 3:
            guard !filterAssignment.isEmpty else {
                let noDataCell = UITableViewCell(style: .default, reuseIdentifier: "NoDataCell")
                    noDataCell.selectionStyle = .none
                    noDataCell.backgroundColor = .clear

                    // Image
                    let imageView = UIImageView(image: UIImage(named: "noSearchData"))
                    imageView.contentMode = .scaleAspectFit
                    imageView.translatesAutoresizingMaskIntoConstraints = false

                    // Label
                    let label = UILabel()
                    label.text = "No Data Found"
                    label.textColor = .gray
                    label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
                    label.textAlignment = .center
                    label.numberOfLines = 0
                    label.translatesAutoresizingMaskIntoConstraints = false

                    noDataCell.contentView.addSubview(imageView)
                    noDataCell.contentView.addSubview(label)

                    NSLayoutConstraint.activate([
                        // Image constraints
                        imageView.topAnchor.constraint(equalTo: noDataCell.contentView.topAnchor, constant: 40),
                        imageView.centerXAnchor.constraint(equalTo: noDataCell.contentView.centerXAnchor),
                        imageView.widthAnchor.constraint(equalToConstant: 150),
                        imageView.heightAnchor.constraint(equalToConstant: 150),

                        // Label constraints
                        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                        label.leadingAnchor.constraint(equalTo: noDataCell.contentView.leadingAnchor, constant: 20),
                        label.trailingAnchor.constraint(equalTo: noDataCell.contentView.trailingAnchor, constant: -20),
                        label.bottomAnchor.constraint(lessThanOrEqualTo: noDataCell.contentView.bottomAnchor, constant: -40)
                    ])
                    return noDataCell
            }

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitedStudentTVC", for: indexPath) as? SubmitedStudentTVC else {
                return UITableViewCell()
            }

            let student = filterAssignment[indexPath.row]
            cell.studentNameLbl.text = student.student_name
            if let firstLetter = student.student_name?.first {
                cell.initialBtn.setTitle(String(firstLetter).uppercased(), for: .normal)
            } else {
                cell.initialBtn.setTitle("-", for: .normal)
            }
            cell.standerdScection?.text = "\(student.standard ?? "") - \(student.section ?? "")"
            let isNotSubmitted = student.submit_status == "NOTSUBMITTED"
            let statusText = isNotSubmitted ? "Pending" : "Submitted"
            let statusColor = isNotSubmitted ? UIColor.brown : UIColor.systemGreen

            cell.statusView.backgroundColor = isNotSubmitted ? UIColor.systemGray5 : UIColor.systemGray6
            cell.statusView.layer.cornerRadius = 8
            cell.statusView.clipsToBounds = true

            let fullText = NSMutableAttributedString(
                string: statusText,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13, weight: .medium),
                    .foregroundColor: statusColor
                ]
            )
            cell.statusView.setAttributedTitle(fullText, for: .normal)

            let iconSize: CGFloat = 13
            let iconConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .medium)
            let icon = UIImage(systemName: isNotSubmitted ? "arrowshape.down.circle" : "checkmark.circle.fill", withConfiguration: iconConfig)

            let lastSubmittedOn = student.submissions_details?.last?.submitted_on
            let date: String? = lastSubmittedOn?.isEmpty == false ? lastSubmittedOn : data?.end_date
            let txt = (lastSubmittedOn?.isEmpty == false) ? "Submitted" : "Due Date"

            cell.submitDate.text = "\(txt): \(formattedDateStatus(from: date ?? ""))"
            cell.statusView.setImage(icon, for: .normal)
            cell.statusView.tintColor = statusColor
            cell.statusView.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            cell.statusView.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            return cell

        default:
            return UITableViewCell()
        }
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 3, indexPath.row < filterAssignment.count else { return }

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

        let submissionVC = AssignmentSummitionVC(nibName: nil, bundle: nil)
        submissionVC.subject = data?.subject
        submissionVC.titleName = data?.title
        submissionVC.submitedList = true
        submissionVC.submissions_details = selectedStudent.submissions_details
        submissionVC.backBtnTittle1 = userNameValue ?? ""
        submissionVC.backBtnTittle2 = sectionValue ?? ""
        submissionVC.isStudent = "Submission"
        submissionVC.modalPresentationStyle = .fullScreen
        present(submissionVC, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Label Extension
extension UILabel {
    func configureAsBackTitle(firstLine: String?, secondLine: String?) {
        let first = firstLine ?? "-"
        let second = secondLine ?? "-"
        let fullText = "\(first)\n\(second)"
        let attrString = NSMutableAttributedString(string: fullText)

        attrString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 15),
            .foregroundColor: UIColor.label
        ], range: NSRange(location: 0, length: first.count))

        attrString.addAttributes([
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.gray
        ], range: NSRange(location: first.count + 1, length: second.count))

        self.numberOfLines = 2
        self.textAlignment = .left
        self.attributedText = attrString
    }
}
