//
//  ExamTmTblVCViewController.swift
//  VsSchoolChimes
//
//  Created by chandhru on 23/11/24.
//

import UIKit
import EventKit

class ExamTmTblVCViewController: UIViewController, ReminderCellDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var examCVC: UICollectionView!
    @IBOutlet weak var tv: UITableView!

    // MARK: - Properties
    var selectedIndex: IndexPath?
    var examDetails: [DetailedExamItem]?
    var subject_details: [SubjectDetail]?
    let eventStore = EKEventStore()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tv.register(UINib(nibName: "ExamListTV", bundle: nil), forCellReuseIdentifier: "ExamListTV")
        setupCollectionView()
        setupTableView()
        selectedIndex = IndexPath(row: 0, section: 0)
        examDetailApi()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyGradient(
            colors: [Colornames.gradientBlue, Colornames.gradientgreen],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }

    // MARK: - Setup Methods
    private func setupCollectionView() {
        let nib = UINib(nibName: "ExamCatogoryCVC", bundle: nil)
        examCVC.register(nib, forCellWithReuseIdentifier: "ExamCatogoryCVC")
        examCVC.delegate = self
        examCVC.dataSource = self
    }

    private func setupTableView() {
        let nib = UINib(nibName: CellConfingName.Tvcell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.Tvcell)
        tv.delegate = self
        tv.dataSource = self
    }

    // MARK: - Actions
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
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
                    self?.subject_details = response.data?.first?.exam_subject_details
                    self?.selectedIndex = IndexPath(row: 0, section: 0)
                    self?.examCVC.reloadData()
                    self?.tv.reloadData()
                case .failure(let error):
                    print("API Error:", error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITableView Delegate & DataSource
extension ExamTmTblVCViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return examDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerview = UIView()
        headerview.backgroundColor = .clear
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.setFont(style: .title, size: 20)
        label.text = examDetails?[section].name
        
        headerview.addSubview(label)
        
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: headerview.leadingAnchor, constant: 15),label.trailingAnchor.constraint(equalTo: headerview.trailingAnchor, constant: -15),label.topAnchor.constraint(equalTo: headerview.topAnchor, constant: 5),label.bottomAnchor.constraint(equalTo: headerview.bottomAnchor, constant: -5)])
        
        return headerview
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return examDetails?[section].exam_subject_details?.count ?? 0//subject_details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: "ExamListTV", for: indexPath) as! ExamListTV
        
        let data = examDetails?[indexPath.section].exam_subject_details?[indexPath.row]
        cell.SubjectLbl.text = data?.subject_name
        cell.syllabusLbl.text = data?.syllabus
        cell.DateBtn.setTitle(data?.exam_date, for: .normal)
        cell.MaxMarkBtn.setTitle("Marks : " + (data?.max_mark ?? ""), for: .normal)
       // cell.TimeBtn.setTitle(data?., for: .normal)
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }

//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: CellConfingName.Tvcell, for: indexPath
//        ) as? Tvcell else {
//            return UITableViewCell()
//        }
//        let subject = subject_details?[indexPath.row]
//        cell.subjectTitleLbl.text = subject?.subject_name ?? "-"
//        cell.dateLbl.text = subject?.exam_date?.convertToTargetDateFormat() ?? "-"
//        cell.syllabusLbl.text = subject?.syllabus ?? "-"
//        cell.markBtn.setTitle("Max Mark \(subject?.max_mark ?? "-")", for: .normal)
//        return cell
//    }

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

// MARK: - UICollectionView Delegate & DataSource
extension ExamTmTblVCViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return examDetails?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = examCVC.dequeueReusableCell(withReuseIdentifier: "ExamCatogoryCVC", for: indexPath) as? ExamCatogoryCVC else {
            return UICollectionViewCell()
        }

        if let examName = examDetails?[indexPath.row].name {
            cell.examNameLbl.text = examName
        } else {
            cell.examNameLbl.text = "-"
        }

        // Style the outer view
        cell.outerView.layer.borderWidth = 1
        cell.outerView.layer.borderColor = UIColor.lightGray.cgColor
        cell.outerView.layer.cornerRadius = 12
        cell.outerView.clipsToBounds = true

        // Optional: highlight selected item
        if selectedIndex == indexPath {
            cell.outerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
            cell.examNameLbl.textColor = .white
        } else {
            cell.outerView.backgroundColor = .white
            cell.examNameLbl.textColor = .black
        }

        return cell
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        subject_details = examDetails?[indexPath.row].exam_subject_details
        examCVC.reloadData()
        tv.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let text = examDetails?[indexPath.row].name else {
            return CGSize(width: 100, height: collectionView.frame.height) // default width
        }

        let font = UIFont.systemFont(ofSize: 14) // match your `examNameLbl` font
        let padding: CGFloat = 30 // padding on both sides (adjust as per UI)
        let textHeight = collectionView.frame.height // full height

        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width

        return CGSize(width: textWidth + padding + 20, height: textHeight)
    }
}
