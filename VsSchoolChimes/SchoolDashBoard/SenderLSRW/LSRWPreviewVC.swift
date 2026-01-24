//
//  LSRWPreviewVC.swift
//  School Chimes
//
//  Created by Chandhru on 14/08/25.
//

import UIKit

class LSRWPreviewVC: UIViewController, UITableViewDataSource, UITableViewDelegate, AssignmentDetailTVCDelegate {
    func didSelectAttachment(at index: Int, allAttachments: [FilePath], subjectName: String) {
        let filterArray = allAttachments.filter { $0.type?.uppercased() != CommonStringFile.M4A }
        if allAttachments[index].type?.uppercased() != CommonStringFile.M4A {
            let selectedFile = allAttachments[index]
            if let newIndex = filterArray.firstIndex(where: { $0.url == selectedFile.url }) {
                let imageVC = ImageShowVc(nibName: nil, bundle: nil)
                imageVC.fileURL = filterArray
                imageVC.subjectName = subjectName
                imageVC.scrollIndex = IndexPath(item: newIndex, section: 0)
                imageVC.index = newIndex
                imageVC.modalPresentationStyle = .fullScreen
                present(imageVC, animated: true)
            }
        }
    }

    
    @IBOutlet weak var priviewTable: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    var filterAssignment: [LSRWStudent] = []
    var submittedAssignment: [LSRWStudent] = []
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
            url: ServiceUrl.lms_api_lsrw_submission_list,
            parameters: ["id":report?.id ?? ""],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<LSWSubmissionResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        self?.submittedAssignment = response.data ?? []
                        self?.filterAssignment = response.data ?? []
                        self?.priviewTable.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.priviewTable.reloadData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
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
        if indexPath.section == 0 {
            if #available(iOS 15.0, *) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSWTaskTVC", for: indexPath) as? LSWTaskTVC else {
                    return UITableViewCell()
                }
                
                if let data = report {
                    cell.configureCell(with: data, attachments: data.file_path ?? [])
                }
                cell.exportRecordBtn.isHidden = true
                cell.reminderBtn.isHidden = true
                cell.delegate = self
                return cell
            } else {
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
            
            // Resize icon to match text height
            let iconSize: CGFloat = 13 // same as text size
            let iconConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .medium)
            let icon = UIImage(
                systemName: isNotSubmitted ? "arrowshape.down.circle" : "checkmark.circle.fill",
                withConfiguration: iconConfig
            )
            let lastSubmittedOn = student.submitted_date
            var date: String?
            let txt: String
            
            if let submittedOn = lastSubmittedOn, !submittedOn.isEmpty {
                date = submittedOn
                txt = "Submitted"
            } else {
                date = "\(report?.created_on ?? "")"
                txt = "Due Date"
            }
            
            cell.submitDate.text = "\(txt): \(ConvertDateStringSmart(date ?? "",toFormat: "dd MMM yyyy h.mm a"))"
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
            return "Submitted Students"
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filterAssignment[indexPath.row].submit_status != "NOTSUBMITTED"{
            if #available(iOS 15.0, *) {
                let vc = LSRWSubmisionListVC()
                vc.attachment = filterAssignment[indexPath.row].file_path
                vc.id = filterAssignment[indexPath.row].id
                vc.student_id = filterAssignment[indexPath.row].student_id
                vc.backTitle1 = filterAssignment[indexPath.row].student_name
                vc.titleSting = filterAssignment[indexPath.row].description
                vc.mark = filterAssignment[indexPath.row].remark
                vc.dateAndTimeForVideo = filterAssignment[indexPath.row].submitted_date
                vc.backTitle2 = "\(filterAssignment[indexPath.row].standard ?? "") - \(filterAssignment[indexPath.row].section ?? "")"
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
}
