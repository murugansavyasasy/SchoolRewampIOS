//
//  ParentClassTestVc.swift
//  School Chimes
//
//  Created by apple on 30/06/26.
//

import UIKit

class ParentClassTestVc: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private var classTests: [ClassTest] = []
    private let stateTracker = ClassTestsStateTracker()
    private var totalExams = 0
    private var totalSubjects = 0
    private var totalActivities = 0
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupTableView()
        loadMockData()
    }


    @IBAction func Backbtn(_ sender: UIButton) {
        
        
    }
    
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 244/255, green: 247/255, blue: 252/255, alpha: 1.0)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 20, right: 0)
        
        // Register Cell
        let cellNib = UINib(nibName: "ExamCardTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "ExamCardTableViewCell")
        
        // Enable Auto Dimension for dynamic heights
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        
        // Load and setup Header View
//        let headerView = ClassTestsHeaderView.loadFromNib()
//        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 195)
//        tableView.tableHeaderView = headerView
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        adjustHeaderHeight()
//    }

//    private func adjustHeaderHeight() {
//        guard let header = tableView.tableHeaderView as? ClassTestsHeaderView else { return }
//        let width = tableView.bounds.width
//        
//        // Update header width and recalculate correct fit height based on Auto Layout constraints
//        if header.frame.width != width {
//            header.frame.size.width = width
//            let fittingSize = header.systemLayoutSizeFitting(
//                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
//                withHorizontalFittingPriority: .required,
//                verticalFittingPriority: .fittingSizeLevel
//            )
//            if header.frame.height != fittingSize.height {
//                header.frame.size.height = fittingSize.height
//                tableView.tableHeaderView = header
//            }
//        }
//    }

    private func loadMockData() {
        let jsonString = """
        {
          "status": true,
          "message": "Class test details loaded",
          "data": [
            {
              "class_test_id": "1",
              "exam_name": "Unit Test 1",
              "subjects": [
                {
                  "subject_id": "113624",
                  "subject_name": "MATHS",
                  "activities": [
                    {
                      "class_test_subject_id": "1",
                      "exam_date": "25-06-2026",
                      "session": "AN",
                      "activity_name": "Formula Test",
                      "max_mark": "50.00",
                      "min_mark": "18.00",
                      "syllabus": "Lesson 1 to Lesson 2"
                    },
                    {
                      "class_test_subject_id": "2",
                      "exam_date": "25-06-2026",
                      "session": "FN",
                      "activity_name": "Diagram Test",
                      "max_mark": "50.00",
                      "min_mark": "18.00",
                      "syllabus": "Lesson 3 to Lesson 5"
                    }
                  ]
                }
              ]
            },
            {
              "class_test_id": "2",
              "exam_name": "Unit Test 2",
              "subjects": [
                {
                  "subject_id": "113624",
                  "subject_name": "MATHS",
                  "activities": [
                    {
                      "class_test_subject_id": "1",
                      "exam_date": "25-06-2026",
                      "session": "AN",
                      "activity_name": "Formula Test",
                      "max_mark": "50.00",
                      "min_mark": "18.00",
                      "syllabus": "Lesson 1 to Lesson 2"
                    },
                    {
                      "class_test_subject_id": "2",
                      "exam_date": "25-06-2026",
                      "session": "FN",
                      "activity_name": "Diagram Test",
                      "max_mark": "50.00",
                      "min_mark": "18.00",
                      "syllabus": "Lesson 3 to Lesson 5"
                    }
                  ]
                },
                {
                  "subject_id": "113623",
                  "subject_name": "TAMIL",
                  "activities": [
                    {
                      "class_test_subject_id": "1",
                      "exam_date": "25-06-2026",
                      "session": "AN",
                      "activity_name": "Formula Test",
                      "max_mark": "50.00",
                      "min_mark": "18.00",
                      "syllabus": "Lesson 1 to Lesson 2"
                    },
                    {
                      "class_test_subject_id": "2",
                      "exam_date": "25-06-2026",
                      "session": "FN",
                      "activity_name": "Diagram Test",
                      "max_mark": "50.00",
                      "min_mark": "18.00",
                      "syllabus": "Lesson 3 to Lesson 5"
                    }
                  ]
                },
                {
                  "subject_id": "113626",
                  "subject_name": "ENGLISH",
                  "activities": [
                    {
                      "class_test_subject_id": "2",
                      "exam_date": "25-06-2026",
                      "session": "FN",
                      "activity_name": "Diagram Test",
                      "max_mark": "50.00",
                      "min_mark": "18.00",
                      "syllabus": "Lesson 3 to Lesson 5"
                    }
                  ]
                }
              ]
            }
          ]
        }
        """
        
        guard let data = jsonString.data(using: .utf8) else { return }
        
        do {
            let response = try JSONDecoder().decode(ClassTestResponse.self, from: data)
            if response.status {
                self.classTests = response.data
                calculateStats()
            }
        } catch {
            print("Failed to decode JSON: \(error)")
        }
    }
//
    private func calculateStats() {
//        totalExams = classTests.count
//        
//        var uniqueSubjects = Set<String>()
//        var activityCount = 0
//        
//        for exam in classTests {
//            for subject in exam.subjects {
//                uniqueSubjects.insert(subject.subjectName)
//                activityCount += subject.activities.count
//            }
//        }
//        
//        totalSubjects = uniqueSubjects.count
//        totalActivities = activityCount
//        
//        // Bind to header view
//        if let headerView = tableView.tableHeaderView as? ClassTestsHeaderView {
//            headerView.configure(exams: totalExams, subjects: totalSubjects, activities: totalActivities)
//        }
//        
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classTests.count
    }

    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExamCardTableViewCell", for: indexPath) as? ExamCardTableViewCell else {
            return UITableViewCell()
        }
        configureCell(cell, at: indexPath)
        return cell
    }

    private func configureCell(_ cell: ExamCardTableViewCell, at indexPath: IndexPath) {
        let exam = classTests[indexPath.row]
        let isExpanded = stateTracker.isExamExpanded(exam.classTestId)
        
        cell.configure(with: exam, isExpanded: isExpanded, stateTracker: stateTracker, onToggle: { [weak self] in
            guard let self = self else { return }
            self.stateTracker.toggleExam(exam.classTestId)
            
            // Auto-expand all child subjects if the exam is expanded
            if self.stateTracker.isExamExpanded(exam.classTestId) {
                for subject in exam.subjects {
                    if !self.stateTracker.isSubjectExpanded(examId: exam.classTestId, subjectId: subject.subjectId) {
                        self.stateTracker.toggleSubject(examId: exam.classTestId, subjectId: subject.subjectId)
                    }
                }
            }
            
            // Reconfigure the cell in-place with the proper callbacks intact
            self.configureCell(cell, at: indexPath)
            
            // Force cell layout refresh before performBatchUpdates
            cell.contentView.layoutIfNeeded()
            
            // Animate row height change smoothly
            self.tableView.performBatchUpdates(nil, completion: nil)
        }, onSubjectToggle: { [weak self] in
            guard let self = self else { return }
            
            // Reconfigure the cell in-place with the proper callbacks intact
            self.configureCell(cell, at: indexPath)
            
            // Force cell layout refresh before performBatchUpdates
            cell.contentView.layoutIfNeeded()
            
            // Animate row height change smoothly
            self.tableView.performBatchUpdates(nil, completion: nil)
        })
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let exam = classTests[indexPath.row]
        stateTracker.toggleExam(exam.classTestId)
        
        // Auto-expand all child subjects if the exam is expanded
        if stateTracker.isExamExpanded(exam.classTestId) {
            for subject in exam.subjects {
                if !stateTracker.isSubjectExpanded(examId: exam.classTestId, subjectId: subject.subjectId) {
                    stateTracker.toggleSubject(examId: exam.classTestId, subjectId: subject.subjectId)
                }
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? ExamCardTableViewCell {
            configureCell(cell, at: indexPath)
            cell.contentView.layoutIfNeeded()
            tableView.performBatchUpdates(nil, completion: nil)
        }
    }
    
    
    }

    


extension UIView {
    static func loadFromNib() -> Self {
        let bundle = Bundle(for: self)
        let nibName = String(describing: self)
        guard let view = bundle.loadNibNamed(nibName, owner: nil, options: nil)?.first as? Self else {
            fatalError("Could not load view with nib name \(nibName)")
        }
        return view
    }
}
