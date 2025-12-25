//
//  MarkReviewVC.swift
//  School Chimes
//
//  Created by Chandhru on 25/12/25.
//

import UIKit

class MarkReviewVC: UIViewController {

    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var subjectsCollectionView: UICollectionView!
    
    // Data Model
    var students: [Student] = []
    var subjects: [Subjects] = []
    var marks: [[String]] = [] // [studentIndex][subjectIndex]
    
    private var isSyncing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupStudentTable()
        setupSubjectsCollection()
    }
    
    // MARK: - Setup
    
    private func setupData() {
        // Initialize students
        students = [
            Student(name: "Alice Johnson", rollNo: "001"),
            Student(name: "Bob Smith", rollNo: "002"),
            Student(name: "Charlie Davis", rollNo: "003"),
            Student(name: "Diana Martinez", rollNo: "004"),
            Student(name: "Ethan Wilson", rollNo: "005"),
            Student(name: "Fiona Chen", rollNo: "006"),
            Student(name: "George Taylor", rollNo: "007")
        ]
        
        // Initialize subjects
        subjects = [
            Subjects(name: "Paper 1 - Algebra", maxMarks: 100),
            Subjects(name: "Paper 2 - Geometry", maxMarks: 100),
            Subjects(name: "Paper 3 - Calculus", maxMarks: 100)
        ]
        
        // Initialize marks array with empty strings
        marks = Array(repeating: Array(repeating: "", count: subjects.count),
                     count: students.count)
    }
    
    private func setupStudentTable() {
        studentTableView.register(UINib(nibName: "StudentNameTVC", bundle: nil),
                                 forCellReuseIdentifier: "StudentNameTVC")
        studentTableView.dataSource = self
        studentTableView.delegate = self
        studentTableView.separatorStyle = .singleLine
        
        // DISABLE SCROLLING - Student table is fixed
        studentTableView.isScrollEnabled = false
        studentTableView.showsVerticalScrollIndicator = false
        studentTableView.bounces = false
    }
    
    private func setupSubjectsCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        subjectsCollectionView.collectionViewLayout = layout
        subjectsCollectionView.register(UINib(nibName: "MarkReviewCVC", bundle: nil),
                                       forCellWithReuseIdentifier: "MarkReviewCVC")
        subjectsCollectionView.dataSource = self
        subjectsCollectionView.delegate = self
        subjectsCollectionView.showsHorizontalScrollIndicator = true
        subjectsCollectionView.bounces = true
    }
    
    // MARK: - Scroll Synchronization (Only for subject columns)
    
    func syncVerticalScroll(from sender: UIScrollView, offset: CGPoint) {
        guard !isSyncing else { return }
        isSyncing = true
        
        // Sync ONLY subject column tables (not student table)
        for cell in subjectsCollectionView.visibleCells {
            if let colCell = cell as? MarkReviewCVC,
               colCell.listTable != sender {
                colCell.listTable.setContentOffset(offset, animated: false)
            }
        }
        
        isSyncing = false
    }
    
    // MARK: - Data Updates
    
    func updateMark(row: Int, column: Int, value: String) {
        guard row < marks.count, column < marks[row].count else { return }
        marks[row][column] = value
        print("Updated mark at [\(row), \(column)] = \(value)")
    }
    
    func getMark(row: Int, column: Int) -> String {
        guard row < marks.count, column < marks[row].count else { return "" }
        return marks[row][column]
    }
}

// MARK: - Student TableView DataSource & Delegate

extension MarkReviewVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentNameTVC",
                                                 for: indexPath) as! StudentNameTVC
        let student = students[indexPath.row]
        cell.configure(name: student.name, rollNo: student.rollNo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // NO scroll delegate for student table - it's fixed
}

// MARK: - Subjects CollectionView DataSource & Delegate

extension MarkReviewVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarkReviewCVC",
                                                      for: indexPath) as! MarkReviewCVC
        
        let subject = subjects[indexPath.item]
        cell.configure(subjectIndex: indexPath.item,
                      headerTitle: subject.name,
                      maxMarks: subject.maxMarks,
                      parentVC: self)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSize(width: 180, height: height)
    }
}

// MARK: - Data Models

struct Student {
    let name: String
    let rollNo: String
}

struct Subjects {
    let name: String
    let maxMarks: Int
}
