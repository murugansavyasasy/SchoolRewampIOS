//
//  SubmittedAssignmentVC.swift
//  School Chimes
//
//  Created by Chandhru on 18/06/25.
//

import UIKit

class SubmitedAssignmentVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    
    @IBOutlet weak var submitedCountView: UIView!
    @IBOutlet weak var notSubmitedCountView: UIView!
    @IBOutlet weak var notSubmitedCountLbl: UILabel!
    @IBOutlet weak var SubmitedCountLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var submitionList: UITableView!
    
    var submittedAssignment: [StudentSubmission] = []
    var filteredAssignment: [StudentSubmission] = []
    var id: String?
    var type = "TOTAL"
    var subject: String?
    var titleString: String?
    var submittedCount: String?
    var notSubmittedCount: String?
    var totalCount: String?
    var shouldShowFooter = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSearchBar()
        getAssignment()
    }
    
    private func setupUI() {
        StandardLbl.text = UserDefaultFileManager.get_staff_Details()?.school_name
        NameLbl.text = UserDefaultFileManager.get_staff_Details()?.name
    }
    
    private func setupTableView() {
        submitionList.delegate = self
        submitionList.dataSource = self
        submitionList.register(UINib(nibName: "SubmitedStudentTVC", bundle: nil), forCellReuseIdentifier: "SubmitedStudentTVC")
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.delegate = self
        searchBar.layer.borderWidth = 0
        searchBar.backgroundImage = UIImage()
        searchBar.addDoneButton()
        searchBar.isHidden = true
    }
    
    private func updateCountLabels() {
        let submitted = submittedAssignment.filter { $0.submit_status != "NOTSUBMITTED" }.count
        let notSubmitted = submittedAssignment.filter { $0.submit_status == "NOTSUBMITTED" }.count
        let total = submittedAssignment.count
        
        DispatchQueue.main.async { [weak self] in
            self?.SubmitedCountLbl.attributedText = self?.styledCountText(count: submitted, label: "Submitted")
            self?.notSubmitedCountLbl.attributedText = self?.styledCountText(count: notSubmitted, label: "Pending")
            self?.notSubmitedCountLbl.textColor = UIColor.red
            self?.SubmitedCountLbl.textColor = UIColor.systemGreen
        }
    }
    private func styledCountText(count: Int, label: String) -> NSAttributedString {
        let numberString = "\(count)\n"
        let labelString = label
        let fullString = numberString + labelString
        
        let attributedString = NSMutableAttributedString(string: fullString)
        
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: NSRange(location: 0, length: numberString.count))
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: numberString.count, length: labelString.count))
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: fullString.count))
        
        return attributedString
    }
    
    func getAssignment() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_submissions_list,
            parameters: ["id": id ?? "", "type": type],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<StudentSubmissionResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        self?.submittedAssignment = response.data ?? []
                        self?.filteredAssignment = response.data ?? []
                        self?.submitionList.reloadData()
                        self?.updateCountLabels()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showAlert(message: response.message ?? "Failed to load assignments")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                    self?.showAlert(message: "Network error occurred. Please try again.")
                }
            }
        }
    }
    
    func getAssignmentArchive() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_submissions_list_archive,
            parameters: ["id": id ?? "", "type": type],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<StudentSubmissionResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        // Append archived data to existing data
                        let archivedData = response.data ?? []
                        self?.submittedAssignment.append(contentsOf: archivedData)
                        self?.filteredAssignment = self?.submittedAssignment ?? []
                        self?.submitionList.reloadData()
                        self?.updateCountLabels()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        searchBtn.setImage(UIImage(systemName: icon), for: .normal)
        searchBar.isHidden = !sender.isSelected
        
        if sender.isSelected {
            searchBar.becomeFirstResponder()
        } else {
            searchBar.resignFirstResponder()
            searchBar.text = ""
            filteredAssignment = submittedAssignment
            submitionList.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAssignment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitedStudentTVC", for: indexPath) as? SubmitedStudentTVC  else {
            return UITableViewCell()
        }
        
        let student = filteredAssignment[indexPath.row]
        cell.studentNameLbl.text = student.student_name
        if let firstLetter = student.student_name?.first {
            cell.initialBtn.setTitle(String(firstLetter).uppercased(), for: .normal)
        } else {
            cell.initialBtn.setTitle("-", for: .normal) // fallback if name is nil or empty
        }
        cell.standerdScection?.text = "\(student.standard ?? "") - \(student.section ?? "")"
        
        let isNotSubmitted = student.submit_status == "NOTSUBMITTED"
        let dueDateString = "Due: Mon, 11" // format from your date
        let statusText = isNotSubmitted ? "Pending" : "Submitted"
        let statusColor = isNotSubmitted ? UIColor.brown : UIColor.systemGreen
        
        let fullText = NSMutableAttributedString(
            string: statusText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: statusColor
            ]
        )
        
        fullText.append(NSAttributedString(
            string: "  \(dueDateString)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.darkGray
            ]
        ))
        
        cell.statusView.setAttributedTitle(fullText, for: .normal)
        cell.statusView.setImage(
            UIImage(systemName: isNotSubmitted ? "arrowshape.down.circle" : "checkmark.circle.fill"),
            for: .normal
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedStudent = filteredAssignment[indexPath.row]
        guard selectedStudent.submit_status != "NOTSUBMITTED" else {
            showAlert(message: "This student has not submitted the assignment yet.")
            return
        }
    }
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            filteredAssignment = submittedAssignment
        } else {
            let lowercasedText = trimmedText.lowercased()
            
            filteredAssignment = submittedAssignment.filter { submission in
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredAssignment = submittedAssignment
        submitionList.reloadData()
    }
}


