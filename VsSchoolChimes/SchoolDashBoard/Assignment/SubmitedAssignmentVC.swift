//
//  SubmitedAssignmentVC.swift
//  School Chimes
//
//  Created by Chandhru on 18/06/25.
//

import UIKit

class SubmitedAssignmentVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var submitionList: UITableView!

    var submitedAssignment: [StudentSubmission] = []
    var filterAssignment: [StudentSubmission] = []
    var id :String?
    var type:String?
    var subject:String?
    var titleString:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        submitionList.delegate = self
        submitionList.dataSource = self

        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.delegate = self
        searchBar.layer.borderWidth = 0
        searchBar.backgroundImage = UIImage()
        searchBar.addDoneButton()
        submitionList.register(UINib(nibName: "SubmitedStudentTVC", bundle: nil), forCellReuseIdentifier: "SubmitedStudentTVC")
        getAssigment()
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    func getAssigment() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_submissions_list,
            parameters: ["id": id ?? "","type":type ?? ""],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<StudentSubmissionResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        self?.submitedAssignment = response.data ?? []
                        self?.filterAssignment = response.data ?? []
                        self?.submitionList.reloadData()
                    }
                }
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterAssignment.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubmitedStudentTVC", for: indexPath) as! SubmitedStudentTVC
        let student = filterAssignment[indexPath.row]
        cell.studentNameLbl.text = student.student_name
        cell.standerdScection?.text = "\(student.standard ?? "") - \(student.section ?? "")"
        cell.subject.text = subject ?? ""
        cell.titleLbl.text = titleString ?? ""
        
        let emoji = (student.submit_status == "NOTSUBMITTED") ? "❎" : "✅"
        cell.indicationBtn.isHidden = (student.submit_status == "NOTSUBMITTED")
        let count = student.submissions_details?.count ?? 0
        cell.submitedCount.text = (student.submit_status == "NOTSUBMITTED") ? "\(emoji) \(student.submit_status ?? "")" : "\(emoji) \(student.submit_status ?? ""): \(count)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if #available(iOS 14.0, *) {
            if filterAssignment[indexPath.row].submit_status != "NOTSUBMITTED"{
                if let currentVC = getCurrentViewController() {
                    let vcc = AssignmentSummitionVC(nibName: nil, bundle: nil)
                    vcc.id = id
                    vcc.subject = subject
                    vcc.titleName = titleString
                    vcc.submitedList = true
                    vcc.submissions_details = filterAssignment[indexPath.row].submissions_details
                    vcc.modalPresentationStyle = .fullScreen
                    currentVC.present(vcc, animated: false, completion: nil)
                }
            }
           
        }
    }
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
    // MARK: - UISearchBarDelegate (Optional Filtering)

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
}
