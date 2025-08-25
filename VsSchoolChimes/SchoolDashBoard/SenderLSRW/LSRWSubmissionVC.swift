//
//  LSRWSubmissionVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/07/25.
//

import UIKit

class LSRWSubmissionVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var backStack: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var submitionList: UITableView!

    var submitedAssignment: [LSRWStudent] = []
    var filterAssignment: [LSRWStudent] = []
    var dueDate: String?
    var report: [LSRWTask]?
    var isTask = false
    var btnTitle:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isTask = !(report?.isEmpty ?? false)
        backBtn.isHidden = !isTask
        backBtn.setTitle(btnTitle ?? "", for: .normal)
        submitionList.delegate = self
        submitionList.dataSource = self
        
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.delegate = self
        searchBar.layer.borderWidth = 0
        searchBar.backgroundImage = UIImage()
        searchBar.addDoneButton()
        
        submitionList.register(UINib(nibName: "LSRWSubmitTVC", bundle: nil), forCellReuseIdentifier: "LSRWSubmitTVC")
        submitionList.register(UINib(nibName: "LSRWTaskTVC", bundle: nil), forCellReuseIdentifier: "LSRWTaskTVC")
        
        filterAssignment = submitedAssignment
    }
    
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isTask ? (report?.count ?? 0) : filterAssignment.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isTask {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWTaskTVC",
                                                           for: indexPath) as? LSRWTaskTVC else {
                return UITableViewCell()
            }
            if let task = report?[indexPath.row] {
                cell.configure(with: task)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWSubmitTVC",
                                                           for: indexPath) as? LSRWSubmitTVC else {
                return UITableViewCell()
            }
            
            let student = filterAssignment[indexPath.row]
            
            // Student Name
            cell.nameLbl.text = student.student_name
            if let firstLetter = student.student_name?.first {
                cell.iniciatBtn.setTitle(String(firstLetter).uppercased(), for: .normal)
            } else {
                cell.iniciatBtn.setTitle("-", for: .normal)
            }
            
            // Class info
            cell.classLbl?.text = "\(student.standard ?? "") - \(student.section ?? "")"
            
            // Status
            let isNotSubmitted = student.submit_status == "NOTSUBMITTED"
            let statusText = isNotSubmitted ? "Pending" : "Submitted"
            let statusColor = isNotSubmitted ? UIColor.brown : UIColor.systemGreen
            
            cell.statusBtn.backgroundColor = isNotSubmitted ? UIColor.systemGray5 : UIColor.systemGray6
            cell.statusBtn.layer.cornerRadius = 8
            cell.statusBtn.clipsToBounds = true
            
            let fullText = NSAttributedString(
                string: statusText,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13, weight: .medium),
                    .foregroundColor: statusColor
                ]
            )
            cell.statusBtn.setAttributedTitle(fullText, for: .normal)
            
            // Icon
            let iconSize: CGFloat = 13
            let iconConfig = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .medium)
            let icon = UIImage(
                systemName: isNotSubmitted ? "arrowshape.down.circle" : "checkmark.circle.fill",
                withConfiguration: iconConfig
            )
            cell.statusBtn.setImage(icon, for: .normal)
            cell.statusBtn.tintColor = statusColor
            
            // Submitted / Due date
            let lastSubmittedOn = student.submitted_date
            var date: String?
            var labelText: String
            
            if let submittedOn = lastSubmittedOn, !submittedOn.isEmpty {
                date = submittedOn
                labelText = "Submitted"
            } else {
                date = dueDate ?? "--"
                labelText = "Due Date"
            }
            
            cell.submitedDateLbl.text = "\(labelText): \(formattedDateStatus(from: date ?? ""))"
            
            // Spacing
            cell.statusBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            cell.statusBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            
            cell.outerView.setShadow()
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isTask {
            if let selectedTask = report?[indexPath.row] {
                navigateToTaskDetail(task: selectedTask)
            }
        } else {
            if #available(iOS 15.0, *) {
                let vc = LSRWSubmisionListVC()
                vc.attachment = filterAssignment[indexPath.row].file_path
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        }
    }
    
    private func navigateToTaskDetail(task: LSRWTask) {
        let vc = LSRWPreviewVC()
        vc.modalPresentationStyle = .fullScreen
        vc.report = task
        present(vc, animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filterAssignment = submitedAssignment
        } else {
            let lowercasedText = searchText.lowercased()
            
            filterAssignment = submitedAssignment.filter { submission in
                let name = submission.student_name?.lowercased() ?? ""
                let standard = submission.standard?.lowercased() ?? ""
                let section = submission.section?.lowercased() ?? ""
                
                return name.contains(lowercasedText) ||
                       standard.contains(lowercasedText) ||
                       section.contains(lowercasedText)
            }
        }
        submitionList.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // Helper to get top controller if needed
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .topMostViewController()
    }
}
