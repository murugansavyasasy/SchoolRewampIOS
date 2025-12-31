//
//  MarkReviewVC.swift
//  School Chimes
//
//  Created by Chandhru on 25/12/25.
//

import UIKit

class MarkReviewVC: UIViewController {

    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var studentTableView: UITableView!
    @IBOutlet weak var saveMarksBtn: UIButton!
    @IBOutlet weak var subjectsCollectionView: UICollectionView!
    
    var studentRecords: [StudentRecord] = []
    private var subjectColumns: [ColumnConfig] = []
    private var isSyncing = false
    private var editedMarks: [String: [String: String]] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        setupColumns()
        if #available(iOS 15.0, *) {
            studentTableView.sectionHeaderTopPadding = 0
        }
        saveMarksBtn.layer.cornerRadius = 8
        
    }
    
    // MARK: - Setup Columns (Dynamic from StudentRecords)
    
    private func setupColumns() {

        subjectColumns.removeAll()

        var uniqueSubjects: [String] = []
        var subjectMaxMarks: [String: Int] = [:]

        for record in studentRecords {
            if let subjects = record.subjects {
                for subject in subjects {
                    let subjectName = subject.Subject

                    if !uniqueSubjects.contains(subjectName) {
                        uniqueSubjects.append(subjectName)
                    }

                    if subjectMaxMarks[subjectName] == nil {
                        subjectMaxMarks[subjectName] = 100
                    }
                }
            }
        }

        uniqueSubjects.sort()

        for subjectName in uniqueSubjects {
            subjectColumns.append(
                ColumnConfig(
                    displayName: subjectName,
                    type: .subject,
                    keyPath: nil,
                    subjectName: subjectName,
                    maxMarks: subjectMaxMarks[subjectName] ?? 100,
                    width: 120
                )
            )
        }
    }

    
    @IBAction func saveAllMarks(_ sender: UIButton) {
        var marksData: [[String: Any]] = []
        
        // Iterate through all students
        for student in studentRecords {
            guard let studentName = student.studentName,
                  let subjects = student.subjects else { continue }
            for subject in subjects {
                // Check if mark was edited
                let editedMark = editedMarks[studentName]?[subject.Subject]
                let finalMark = editedMark ?? subject.value
                
                let markEntry: [String: Any] = [
                    "studentId": studentName,
                    "studentRegNo": student.regNo ?? 0,
                    "subject": subject.Subject,
                    "mark": finalMark,
                    "originalMark": subject.value,
                    "isEdited": editedMark != nil,
                    "confidenceLevel": subject.cnfidenceLvl,
                    "reason": subject.reason
                ]
                marksData.append(markEntry)
            }
        }
        
        // Print for debugging
        print("✅ Total marks collected: \(marksData.count)")
        print("📊 Marks Data: \(marksData)")
        print("📝 Edited marks: \(editedMarks)")
        
        // Use this data to send to API or save locally
        sendMarksToAPI(marksData)
    }
    
    // MARK: - API Call to Save Marks
    
    private func sendMarksToAPI(_ marksData: [[String: Any]]) {
        guard !isSyncing else {
            print("⚠️ Already syncing, skipping save")
            return
        }
        
        isSyncing = true
        saveMarksBtn.isEnabled = false
        
        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Saving Marks", message: "Please wait...", preferredStyle: .alert)
        present(loadingAlert, animated: true)
        
        // Prepare JSON payload
        let payload: [String: Any] = [
            "records": marksData,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "totalRecords": marksData.count
        ]
        
        // Convert to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted) else {
            print("❌ Failed to serialize JSON")
            isSyncing = false
            saveMarksBtn.isEnabled = true
            loadingAlert.dismiss(animated: true)
            showAlert(title: "Error", message: "Failed to prepare data for saving")
            return
        }
        
    }
    
    // MARK: - Helper Alert
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        setupStudentTable()
        setupSubjectsCollection()
    }
    
    private func setupStudentTable() {
        studentTableView.register(UINib(nibName: "StudentNameTVC", bundle: nil),
                                 forCellReuseIdentifier: "StudentNameTVC")
        
        studentTableView.dataSource = self
        studentTableView.delegate = self
        studentTableView.separatorStyle = .singleLine
        studentTableView.rowHeight = 50
        studentTableView.isScrollEnabled = true
        studentTableView.showsVerticalScrollIndicator = false
        studentTableView.showsHorizontalScrollIndicator = false
        studentTableView.alwaysBounceHorizontal = false
        studentTableView.alwaysBounceVertical = false
        studentTableView.bounces = true
        studentTableView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.3)
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
        subjectsCollectionView.backgroundColor = .systemBackground
    }
    
    // MARK: - Data Loading
    
    private func loadData() {

        studentRecords.removeAll()

        for i in 1...40 {

            let name = i <= 10 ? ["ARUN K","DIVYA R","KARTHIK M","SNEHA P","RAHUL S",
                                  "PRIYA T","NAVEEN B","MEENA L","SANJAY D","LATHA V"][i-1]
                               : "STUDENT \(i)"

            let student = StudentRecord(
                sNo: i,
                regNo: 1000 + i,
                studentName: name,
                subjects: makeSubjects(name: name, i: i)
            )

            studentRecords.append(student)
        }

        studentTableView.reloadData()
        subjectsCollectionView.reloadData()
    }

    func makeSubjects(name: String, i: Int) -> [Subjects] {

        func mark(_ val: Int) -> String {
            if val > 100 { return "105" }
            return "\(val)"
        }

        return [
            Subjects(student_id: name, Subject: "TERM I SCI", value: mark(70 + i % 20), cnfidenceLvl: true, reason: ""),
            Subjects(student_id: name, Subject: "TERM II SCI", value: mark(72 + i % 18), cnfidenceLvl: true, reason: ""),
            Subjects(student_id: name, Subject: "TERM III SCI", value: "AB", cnfidenceLvl: false, reason: "Invalid mark"),

            Subjects(student_id: name, Subject: "TERM I ENG", value: mark(68 + i % 15), cnfidenceLvl: true, reason: ""),
            Subjects(student_id: name, Subject: "TERM II ENG", value: "110", cnfidenceLvl: false, reason: "Marks out of range"),
            Subjects(student_id: name, Subject: "TERM III ENG", value: mark(72 + i % 13), cnfidenceLvl: true, reason: ""),

            Subjects(student_id: name, Subject: "TERM I SOCIAL", value: mark(65 + i % 12), cnfidenceLvl: true, reason: ""),
            Subjects(student_id: name, Subject: "TERM II SOCIAL", value: "", cnfidenceLvl: false, reason: "Invalid mark"),
            Subjects(student_id: name, Subject: "TERM III SOCIAL", value: mark(67 + i % 10), cnfidenceLvl: true, reason: "")
        ]
    }

    // MARK: - API Integration
    
    func loadFromAPI(jsonData: Data) {
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(StudentResponse.self, from: jsonData)
            studentRecords = response.records
            
            setupColumns()
            studentTableView.reloadData()
            subjectsCollectionView.reloadData()
        } catch {
            print("❌ Decode error: \(error)")
        }
    }
    
    // MARK: - Scroll Synchronization
    
    func syncVerticalScroll(from sender: UIScrollView, offset: CGPoint) {
        guard !isSyncing else { return }
        isSyncing = true
        if studentTableView != sender {
            let syncOffset = CGPoint(x: 0, y: offset.y)
            studentTableView.setContentOffset(syncOffset, animated: false)
        }
        for cell in subjectsCollectionView.visibleCells {
            if let colCell = cell as? MarkReviewCVC,
               colCell.listTable != sender {
                colCell.listTable.setContentOffset(offset, animated: false)
            }
        }
        
        isSyncing = false
    }
    
    // MARK: - Data Access & Updates
    
    func updateMark(row: Int, column: Int, value: String) {
        guard row < studentRecords.count,
              column < subjectColumns.count else { return }
        
        let student = studentRecords[row]
        let colConfig = subjectColumns[column]
        
        guard var studentSubjects = student.subjects,
              let studentId = student.studentName,
              let subjectName = colConfig.subjectName else { return }
        if editedMarks[studentId] == nil {
            editedMarks[studentId] = [:]
        }
        editedMarks[studentId]?[subjectName] = value
        if let index = studentSubjects.firstIndex(where: { $0.Subject == subjectName }) {
            studentSubjects[index].value = value
            studentRecords[row].subjects = studentSubjects
        }
        
        print("✅ Mark updated immediately:")
        print("   Student: \(studentId)")
        print("   Subject: \(subjectName)")
        print("   New Value: \(value)")
        print("   Edited Marks: \(editedMarks)")
    }
}

// MARK: - Student TableView (Fixed Column)

extension MarkReviewVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentNameTVC",
                                                 for: indexPath) as! StudentNameTVC
        
        let record = studentRecords[indexPath.row]
        cell.configure(name: record.studentName ?? "Unknown", rollNo: "\(record.regNo ?? 0)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        let subject = studentRecords[indexPath.row]

        let text = subject.studentName ?? ""
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let labelWidth: CGFloat = 160

        let dynamicHeight = textHeight(text: text,
                                       font: font,
                                       width: labelWidth)

        return max(50, dynamicHeight + 20)
    }
    
    func textHeight(text: String, font: UIFont, width: CGFloat) -> CGFloat {

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)

        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )

        return ceil(boundingBox.height)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == studentTableView {
            if scrollView.contentOffset.x != 0 {
                scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: false)
            }
            syncVerticalScroll(from: scrollView, offset: scrollView.contentOffset)
        }
    }
}

// MARK: - Subjects CollectionView (Scrollable Columns)

extension MarkReviewVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subjectColumns.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarkReviewCVC",
                                                      for: indexPath) as! MarkReviewCVC
        
        let column = subjectColumns[indexPath.item]
        cell.configure(
            columnIndex: indexPath.item,
            columnConfig: column,
            studentRecords: studentRecords,
            parentVC: self)
        
//        cell.layer.borderWidth = 0.5
//        cell.layer.borderColor = UIColor.systemGray4.cgColor
//        cell.backgroundColor = .systemBackground
//        cell.contentView.backgroundColor = .systemBackground
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let column = subjectColumns[indexPath.item]
        

        var widths: [CGFloat] = []

        let display = column.displayName
            let font = UIFont.systemFont(ofSize: 13, weight: .medium)
            widths.append(display.width(usingFont: font))

        if let subject = column.subjectName {
            let font = UIFont.systemFont(ofSize: 13, weight: .bold)
            widths.append(subject.width(usingFont: font))
        }

        if let max = column.maxMarks {
            let font = UIFont.systemFont(ofSize: 12, weight: .regular)
            widths.append("Max :\(max)".width(usingFont: font))
        }

        let padding: CGFloat = 24
        let minWidth: CGFloat = 60

        let maxTextWidth = widths.max() ?? minWidth
        let finalWidth = max(maxTextWidth + padding, minWidth)

        return CGSize(width: finalWidth,
                      height: collectionView.frame.height)
    }

}

// MARK: - Models

enum ColumnType {
    case studentName
    case rollNumber
    case subject
}

struct ColumnConfig {
    let displayName: String
    let type: ColumnType
    let keyPath: KeyPath<StudentRecord, String?>?
    let subjectName: String?
    let maxMarks: Int?
    let width: CGFloat
}

struct StudentResponse: Codable {
    let records: [StudentRecord]
}

struct StudentRecord: Codable {
    let sNo: Int?
    let regNo: Int?
    let studentName: String?
    var subjects: [Subjects]?
   
    enum CodingKeys: String, CodingKey {
        case sNo = "S.no"
        case regNo = "Reg No"
        case studentName = "Student Name"
        case subjects = "subjects"
    }
}

struct Subjects: Codable {
    let student_id: String
    let Subject: String
    var value: String
    let cnfidenceLvl: Bool
    let reason: String
}


extension String {
    func width(usingFont font: UIFont) -> CGFloat {
        let size = (self as NSString).size(withAttributes: [.font: font])
        return ceil(size.width)
    }
}
