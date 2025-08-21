//
//  LSRWPreviewVC.swift
//  School Chimes
//
//  Created by Chandhru on 14/08/25.
//

import UIKit

class LSRWPreviewVC: UIViewController, UITableViewDataSource, UITableViewDelegate, AssignmentDetailTVCDelegate {
    func didSelectAttachment(at index: Int, allAttachments: [FilePath], subjectName: String) {
        
        let imageVC = ImageShowVc(nibName: nil, bundle: nil)
        imageVC.fileURL = allAttachments
        imageVC.subjectName = "Event"
        imageVC.scrollIndex = IndexPath(index:index)
        imageVC.index = index
        imageVC.modalPresentationStyle = .fullScreen
        present(imageVC, animated: true)
    }
    
    @IBOutlet weak var priviewTable: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    var filterAssignment: [StudentSubmission] = []
    var submittedAssignment: [StudentSubmission] = []
    var report:LSRWTask?
    override func viewDidLoad() {
        super.viewDidLoad()
        backBtn.configureAsBackButton(firstLine: "LSRW",secondLine:"Listening, Speaking, Reading,Writing")
        if #available(iOS 15.0, *) {
            priviewTable.sectionHeaderTopPadding = 0
        }
        priviewTable.register(UINib(nibName: "LSWTaskTVC", bundle: nil), forCellReuseIdentifier: "LSWTaskTVC")
        priviewTable.register(UINib(nibName: "SubmitedStudentTVC", bundle: nil), forCellReuseIdentifier: "SubmitedStudentTVC")
        priviewTable.dataSource = self
        priviewTable.delegate = self
        getSubmission()
        
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    func getSubmission() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_submissions_list,
            parameters: ["id":"180652", "type": "TOTAL"],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<StudentSubmissionResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        self?.submittedAssignment = response.data ?? []
                        self?.filterAssignment = response.data ?? []
                        self?.priviewTable.reloadData()
                        //                        self?.updateCountLabels()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.priviewTable.reloadData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                    //                    self?.showAlert(message: "Network error occurred. Please try again.")
                    self?.priviewTable.reloadData()
                }
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : filterAssignment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Submitted Student
        if indexPath.section == 0 {
            if #available(iOS 15.0, *) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSWTaskTVC", for: indexPath) as? LSWTaskTVC else {
                    return UITableViewCell()
                }
                
                if let data = report {
                    cell.configureCell(with: data, attachments: data.file_path ?? [])
                }
                cell.delegate = self
                return cell
            } else {
                // Fallback for iOS < 15
                let cell = UITableViewCell(style: .default, reuseIdentifier: "defaultCell")
                cell.textLabel?.text = "Not supported on < iOS 15"
                return cell
            }
        }
        else{
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
            var date: String?
            let txt: String
            
            if let submittedOn = lastSubmittedOn, !submittedOn.isEmpty {
                date = submittedOn
                txt = "Submitted"
            } else {
                date = "\(report?.created_on ?? "")"
                txt = "Due Date"
            }
            
            cell.submitDate.text = "\(txt): \(formattedDateStatus(from: date ?? ""))"
            cell.statusView.setImage(icon, for: .normal)
            cell.statusView.tintColor = statusColor
            
            // Optional: Adjust image & title spacing
            cell.statusView.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            cell.statusView.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            cell.outerView.setShadow()
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Task Details:"
        case 1:
            return "Submited Students"
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
