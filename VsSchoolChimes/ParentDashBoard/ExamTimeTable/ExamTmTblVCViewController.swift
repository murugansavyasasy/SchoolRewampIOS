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
    var groupedExamDetails: [GroupedExam] = []
    weak var delegate : Searchable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NoDataImage.isHidden = true
        NoDataLbl.isHidden = true
        searchBar.isHidden = true
        searchBar.placeholder = CommonStringFile.Search
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        searchBar.backgroundImage = UIImage()
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
            showActivityLoader()
        }

        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_exam_get_exams,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<DetailedExamListResponse, Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) { self.hideActivityLoader() }
                switch result {
                case .success(let response):
                    self.examDetails = response.data
                    self.FilteredExamDetails = self.examDetails
                    
                    self.subject_details = response.data?.first?.exam_subject_details
//                    self?.prepareGroupedData()
                    self.tv.reloadData()
                    let isEmpty = self.examDetails?.isEmpty ?? true
                    self.NoDataLbl.isHidden = !isEmpty
                    self.NoDataLbl.text = response.message ?? ""
                    self.NoDataImage.isHidden = !isEmpty
                    self.delegate?.childViewController(self, didUpdateDataIsEmpty: isEmpty)
                    
                    
                case .failure(let error):
                    print("API Error:", error.localizedDescription)
                    self.NoDataLbl.text = error.localizedDescription
                    self.NoDataLbl.isHidden = false
                    self.NoDataImage.isHidden = false
                    self.delegate?.childViewController(self, didUpdateDataIsEmpty: true)
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
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .primery
        titleLabel.setFont(style: .body, size: 25)
        titleLabel.text = FilteredExamDetails?[section].name
        
        headerview.addSubview(titleLabel)
        
        // Body Label
//        let bodyLabel = UILabel()
//        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
//        bodyLabel.textColor = .secondaryLabel
//        bodyLabel.setFont(style: .body, size: 14)
//        bodyLabel.numberOfLines = 0
//        bodyLabel.text = FilteredExamDetails?[section].created_on   // ← உன் dataல இருக்க body text
//        
//        headerview.addSubview(bodyLabel)
        
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: headerview.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: headerview.trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: headerview.topAnchor, constant: 5),
            titleLabel.bottomAnchor.constraint(equalTo: headerview.bottomAnchor, constant: -5)
            
            // Body label constraints
//            bodyLabel.leadingAnchor.constraint(equalTo: headerview.leadingAnchor, constant: 15),
//            bodyLabel.trailingAnchor.constraint(equalTo: headerview.trailingAnchor, constant: -15),
//            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            bodyLabel.bottomAnchor.constraint(equalTo: headerview.bottomAnchor, constant: -5)
        ])
        
        return headerview
    }

    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let headerView = UIView()
//        headerView.backgroundColor = .clear
//        
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.spacing = 4
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let titleLabel = UILabel()
//        titleLabel.setFont(style: .body, size: 25)
//        titleLabel.textColor = UIColor.systemBlue
//        titleLabel.text = FilteredExamDetails?[section].name
//        
//        let bodyLabel = UILabel()
//        bodyLabel.font = UIFont.systemFont(ofSize: 14)
//        bodyLabel.textColor = .secondaryLabel
//        if let created = FilteredExamDetails?[section].created_on {
//            bodyLabel.text = "Created on: \(created.components(separatedBy: " ").first ?? "")"
//        }
//        
//        stackView.addArrangedSubview(titleLabel)
//        stackView.addArrangedSubview(bodyLabel)
//        
//        headerView.addSubview(stackView)
//        
//        NSLayoutConstraint.activate([
//            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
//            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
//            stackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
//            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
//        ])
//        
//        return headerView
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerview = UIView()
//        headerview.backgroundColor = .clear
//        
//        let examNameLabel = UILabel()
//        examNameLabel.translatesAutoresizingMaskIntoConstraints = false
//        examNameLabel.textColor = .label
//        examNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        examNameLabel.text = groupedExamDetails[section].examName
//        
//        let createdOnLabel = UILabel()
//        createdOnLabel.translatesAutoresizingMaskIntoConstraints = false
//        createdOnLabel.textColor = .secondaryLabel
//        createdOnLabel.font = UIFont.systemFont(ofSize: 14)
//        createdOnLabel.text = groupedExamDetails[section].createdOn
//        
//        let dashedView = DashedLineWithTextView()
//        dashedView.translatesAutoresizingMaskIntoConstraints = false
//        dashedView.setText(groupedExamDetails[section].date.convertToHeaderDate())
//        
//        headerview.addSubview(examNameLabel)
//        headerview.addSubview(createdOnLabel)
//        headerview.addSubview(dashedView)
//        
//        NSLayoutConstraint.activate([
//            examNameLabel.leadingAnchor.constraint(equalTo: headerview.leadingAnchor, constant: 15),
//            examNameLabel.trailingAnchor.constraint(equalTo: headerview.trailingAnchor, constant: -15),
//            examNameLabel.topAnchor.constraint(equalTo: headerview.topAnchor, constant: 5),
//            
//            createdOnLabel.leadingAnchor.constraint(equalTo: examNameLabel.leadingAnchor),
//            createdOnLabel.trailingAnchor.constraint(equalTo: examNameLabel.trailingAnchor),
//            createdOnLabel.topAnchor.constraint(equalTo: examNameLabel.bottomAnchor, constant: 2),
//            
//            dashedView.leadingAnchor.constraint(equalTo: headerview.leadingAnchor, constant: 15),
//            dashedView.trailingAnchor.constraint(equalTo: headerview.trailingAnchor, constant: -15),
//            dashedView.topAnchor.constraint(equalTo: createdOnLabel.bottomAnchor, constant: 8),
//            dashedView.bottomAnchor.constraint(equalTo: headerview.bottomAnchor, constant: -5),
//            dashedView.heightAnchor.constraint(equalToConstant: 25)
//        ])
//        
//        return headerview
//    }



//    func numberOfSections(in tableView: UITableView) -> Int {
//        return groupedExamDetails.count
//    }

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return groupedExamDetails[section].exams.count
//    }
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

    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tv.dequeueReusableCell(withIdentifier: "ExamListTV", for: indexPath) as! ExamListTV
//        
//        let data = groupedExamDetails[indexPath.section].exams[indexPath.row]
//        
//        if (indexPath.row % 2) == 0 {
//            cell.cellView.backgroundColor = UIColor(hex: "#DEECFD")
//        } else {
//            cell.cellView.backgroundColor = UIColor(hex: "#F1EBFC")
//        }
//        
//        cell.SubjectLbl.text = data.subject_name
//        cell.syllabusLbl.text = data.syllabus
//        cell.DateBtn.setTitle(data.exam_date?.convertToHeaderDate(), for: .normal)
//        cell.MaxMarkBtn.setTitle("Marks : " + (data.max_mark ?? ""), for: .normal)
//        cell.TimeBtn.setTitle("\(data.start_time ?? "") - \(data.end_time ?? "")", for: .normal)
//        cell.indexPath = indexPath
//        cell.delegate = self
//        
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
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
    
//    func prepareGroupedData() {
//        guard let exams = examDetails else { return }
//        
//        var tempGrouped: [GroupedExam] = []
//        
//        for exam in exams {
//            if let subjects = exam.exam_subject_details {
//                
//                // Group subjects by date
//                let dict = Dictionary(grouping: subjects, by: { $0.exam_date ?? "" })
//                
//                for (date, subs) in dict {
//                    let grouped = GroupedExam(
//                        examName: exam.name ?? "",         // Same for all subjects
//                        createdOn: exam.created_on ?? "",  // Same for all subjects
//                        date: date,
//                        exams: subs
//                    )
//                    tempGrouped.append(grouped)
//                }
//            }
//        }
//        
//        // Sort by date
//        groupedExamDetails = tempGrouped.sorted {
//            $0.date.convertToDate() ?? Date() < $1.date.convertToDate() ?? Date()
//        }
//        
//        tv.reloadData()
//    }


}

struct GroupedExam {
    var examName: String
    var createdOn: String
    var date: String
    var exams: [SubjectDetail]
}


extension String {
    func convertToDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy" // API format
        return formatter.date(from: self)
    }
    
    func convertToHeaderDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        if let date = formatter.date(from: self) {
            formatter.dateFormat = "MMMM dd, yyyy" // September 30, 2025
            return formatter.string(from: date)
        }
        return self
    }
}

// MARK: - Custom View for Dashed Line + Date
class DashedLineWithTextView: UIView {
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.backgroundColor = .systemBackground // dark/light mode ok
        return label
    }()
    
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.addSublayer(shapeLayer)
        addSubview(textLabel)
        setDateToToday()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.sizeToFit()
        textLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let path = UIBezierPath()
        let y = bounds.midY
        
        // Left line
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: textLabel.frame.minX - 8, y: y))
        
        // Right line
        path.move(to: CGPoint(x: textLabel.frame.maxX + 8, y: y))
        path.addLine(to: CGPoint(x: bounds.width, y: y))
        
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [4, 4]
        shapeLayer.path = path.cgPath
    }
    
    func setText(_ text: String) {
        textLabel.text = text
        setNeedsLayout()
    }
    
    func setDateToToday() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        let todayString = formatter.string(from: Date())
        setText(todayString)
    }
}
