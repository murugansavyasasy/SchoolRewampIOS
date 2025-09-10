//
//  ExamTmTblVCViewController.swift
//  VsSchoolChimes
//
//  Created by chandhru on 23/11/24.
//

import UIKit
import EventKit

class ExamTmTblVCViewController: UIViewController, ReminderCellDelegate {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var examDetails: [DetailedExamItem]?
    var FilteredExamDetails: [DetailedExamItem]?
    var subject_details: [SubjectDetail]?
    let eventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NoDataImage.isHidden = true
        NoDataLbl.isHidden = true
        searchBar.isHidden = true
        searchBar.placeholder = CommonStringFile.Search
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        NoDataLbl.setFont(style: .title, size: FontSize.TitleSize)
        setupTableView()
        examDetailApi()
    }
    
    private func setupTableView() {
        tv.register(UINib(nibName: "ExamListTV", bundle: nil), forCellReuseIdentifier: "ExamListTV")
        tv.delegate = self
        tv.dataSource = self
    }

    // MARK: - API Call
    func examDetailApi() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }

        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_exam_get_exams,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<DetailedExamListResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) { self?.hideLottieProgressLoader() }
                switch result {
                case .success(let response):
                    self?.examDetails = response.data
                    self?.FilteredExamDetails = self?.examDetails
                    self?.subject_details = response.data?.first?.exam_subject_details
                    self?.tv.reloadData()
                    self?.NoDataLbl.isHidden = response.status ?? false
                    self?.NoDataLbl.text = response.message ?? ""
                    self?.NoDataImage.isHidden = response.status ?? false
                    
                case .failure(let error):
                    print("API Error:", error.localizedDescription)
                    self?.NoDataLbl.text = error.localizedDescription
                    self?.NoDataLbl.isHidden = false
                    self?.NoDataImage.isHidden = false
                }
            }
        }
    }
}

// MARK: - UITableView Delegate & DataSource
extension ExamTmTblVCViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return FilteredExamDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerview = UIView()
        headerview.backgroundColor = .clear
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.setFont(style: .title, size: 20)
        label.text = FilteredExamDetails?[section].name
        
        headerview.addSubview(label)
        
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: headerview.leadingAnchor, constant: 15),label.trailingAnchor.constraint(equalTo: headerview.trailingAnchor, constant: -15),label.topAnchor.constraint(equalTo: headerview.topAnchor, constant: 5),label.bottomAnchor.constraint(equalTo: headerview.bottomAnchor, constant: -5)])
        
        return headerview
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FilteredExamDetails?[section].exam_subject_details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: "ExamListTV", for: indexPath) as! ExamListTV
        if (indexPath.row % 2) == 0 {
            cell.cellView.backgroundColor = UIColor(hex: "#DEECFD")
        }else {
            cell.cellView.backgroundColor = UIColor(hex: "#F1EBFC")
        }
        let data = FilteredExamDetails?[indexPath.section].exam_subject_details?[indexPath.row]
        cell.SubjectLbl.text = data?.subject_name
        cell.syllabusLbl.text = data?.syllabus
        cell.DateBtn.setTitle(data?.exam_date?.convertToTargetDateFormat(), for: .normal)
        cell.MaxMarkBtn.setTitle("Marks : " + (data?.max_mark ?? ""), for: .normal)
        cell.TimeBtn.setTitle(data?.start_time, for: .normal)
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func createReminder(for task: String) {
        eventStore.requestAccess(to: .reminder) { [weak self] (granted, error) in
            if let error = error {
                print("Error requesting access: \(error.localizedDescription)")
                return
            }
            
            if granted {
                self?.addReminder(task: task)
            } else {
                print("Access to reminders not granted.")
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: AlertstringFile.PermissionDenied,
                        message: AlertstringFile.enableRemindersAccess,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    func addReminder(task: String) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = task
        reminder.notes = "Task reminder for \(task)"
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date().addingTimeInterval(3600)) // Due in 1 hour
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        do {
            try eventStore.save(reminder, commit: true)
            print("Reminder added for \(task).")
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Success",
                    message: "Reminder added for \(task).",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        } catch {
            print("Failed to save reminder: \(error.localizedDescription)")
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Failed to create reminder.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    func didTapCreateReminder(at indexPath: IndexPath) {
        let taskName = examDetails?[indexPath.section].exam_subject_details?[indexPath.row].subject_name
        
        // Show confirmation alert
        let alert = UIAlertController(
            title: "Set Reminder",
            message: "Do you want to set a reminder for \(taskName ?? "")?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.createReminder(for: taskName ?? "")
        }))
        alert.addAction(UIAlertAction(title: AlertstringFile.No, style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ExamTmTblVCViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.lowercased()
        
        if query.isEmpty {
            FilteredExamDetails = examDetails
        } else {
            FilteredExamDetails = examDetails?.compactMap { exam in
                
                // 🔹 Exam name check
                let examMatches = exam.name?.lowercased().contains(query) ?? false
                
                // 🔹 Subject-level filtering
                let matchedSubjects = exam.exam_subject_details?.filter {
                    let subjectMatch = $0.subject_name?.lowercased().contains(query) ?? false
                    let syllabusMatch = $0.syllabus?.lowercased().contains(query) ?? false
                    
                    // 🔹 Date conversion and check
                    let dateString = $0.exam_date?.convertToTargetDateFormat()?.lowercased() ?? ""
                    let dateMatch = dateString.contains(query)
                    
                    return subjectMatch || syllabusMatch || dateMatch
                }
                
                if examMatches {
                    return exam
                } else if let matchedSubjects, !matchedSubjects.isEmpty {
                    var newExam = exam
                    newExam.exam_subject_details = matchedSubjects
                    return newExam
                } else {
                    return nil
                }
            }
        }
        
        NoDataLbl.text = CommonStringFile.No_data_found
        NoDataLbl.isHidden = !(FilteredExamDetails?.isEmpty ?? false)
        NoDataImage.isHidden = !(FilteredExamDetails?.isEmpty ?? false)
        tv.reloadData()
    }
}
