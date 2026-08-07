//
//  selectExamVc.swift
//  School Chimes
//
//  Created by apple on 04/08/26.
//

import UIKit

class selectExamVc: UIViewController ,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var standardAndSec: UILabel!
    @IBOutlet weak var admissinNoLbl: UILabel!
    @IBOutlet weak var rollnumberLbl: UILabel!
    @IBOutlet weak var selectedStudentAvatarView: UIView!
    @IBOutlet weak var selectedStudentInitialsLabel: UILabel!
    @IBOutlet weak var selectedStudentNameLabel: UILabel!
   
    
    @IBOutlet weak var examsTableView: UITableView!
    @IBOutlet weak var examsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedExamsCountLabel: UILabel!
    
    @IBOutlet weak var viewAnalysisButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    
    // MARK: - Injected Properties

    var student: StudentDetails?
    var classAndSectionText: String = ""
    
    // MARK: - Private Properties
    private var exams: [Exam] = []
    private var selectedExams: Set<String> = []
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadExams()
    }
    
    @IBAction func backBtnAct(_ sender: UIButton) {
        dismiss(animated: true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeight()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1.0)
        
        // 1. Configure Header Card
        selectedStudentAvatarView.layer.cornerRadius = 20
        selectedStudentAvatarView.clipsToBounds = true
        
        changeButton.layer.cornerRadius = 15
        changeButton.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.96, alpha: 1.0)
        changeButton.setTitleColor(UIColor(red: 0.35, green: 0.45, blue: 0.56, alpha: 1.0), for: .normal)
        
        if let student = student {
            selectedStudentNameLabel.text = student.name
            let rollText = student.roll_no?.isEmpty == nil ? "--" : "\(student.roll_no ?? "")"
            rollnumberLbl.text = "Roll No: \(rollText)"
            admissinNoLbl.text = "Admin No: \(student.admission_no ?? "--")"
            standardAndSec.text = classAndSectionText
            selectedStudentInitialsLabel.text = getInitials(from: student.name ?? "")
            selectedStudentAvatarView.backgroundColor = getAvatarColor(from: student.name ?? "")
        }
        
        // 2. Configure TableView
        examsTableView.dataSource = self
        examsTableView.delegate = self
        examsTableView.register(UINib(nibName: "ExamTableViewCell", bundle: nil), forCellReuseIdentifier: "ExamTableViewCell")
        examsTableView.isScrollEnabled = false
        examsTableView.separatorStyle = .none
        examsTableView.backgroundColor = .clear
        
        // 3. Configure Footer Area
        backButton.layer.cornerRadius = 10
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0).cgColor
        backButton.backgroundColor = .white
        backButton.setTitleColor(UIColor(red: 0.05, green: 0.14, blue: 0.23, alpha: 1.0), for: .normal)
        
        viewAnalysisButton.layer.cornerRadius = 10
//        viewAnalysisButton.backgroundColor = UIColor(red: 0.05, green: 0.14, blue: 0.23, alpha: 1.0)
        viewAnalysisButton.setTitleColor(.white, for: .normal)
        
        updateFooterStatus()
    }
    
    private func loadExams() {
        exams = MockData.loadExams()
        
        // No exams selected by default as requested
        
        examsTableView.reloadData()
        updateFooterStatus()
        
        DispatchQueue.main.async {
            self.updateTableViewHeight()
        }
    }
    

    
    func getAnaylisExam(classid: String,sectionid : String){
        
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: ["class_id" : "" ,"section_id" : ""], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (result: Result<analysisRespSuc , Error>) in
            
            DispatchQueue.main.sync { [weak self] in
                
                guard let self = self else {return}
                
                switch result {
                case .success(let success):
                    if success.status ?? false{
                       
                    }else{
                        
                    }
                    
                case .failure(let failure):
                    
                }
            }
            
        }
    }
    
    private func updateTableViewHeight() {
        examsTableViewHeightConstraint.constant = examsTableView.contentSize.height
        view.layoutIfNeeded()
    }
    
    private func updateFooterStatus() {
        let count = selectedExams.count
        selectedExamsCountLabel.text = "\(count) exams selected"
        
        // Select All button toggle text
        if count == exams.count {
            selectAllButton.setTitle("Deselect all", for: .normal)
        } else {
            selectAllButton.setTitle("Select all", for: .normal)
        }
    }
    
    // MARK: - Actions
    @IBAction func didTapChange(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSelectAll(_ sender: UIButton) {
        if selectedExams.count == exams.count {
            selectedExams.removeAll()
        } else {
            selectedExams = Set(exams.map { $0.id })
        }
        examsTableView.reloadData()
        updateFooterStatus()
    }
    
    @IBAction func didTapViewAnalysis(_ sender: UIButton) {
        guard let student = student else { return }
        
        if selectedExams.isEmpty {
            showAlert(title: "Selection Required", message: "Please select at least one exam to include in the analysis.")
            return
        }
        
        let selectedLabels = exams.filter { selectedExams.contains($0.id) }.map { $0.label }
        let message = """
        Student: \(student.name)
        Class Details: \(classAndSectionText)
        Selected Exams: \(selectedLabels.joined(separator: ", "))
        """
        
        showAlert(title: "Mark Analysis Ready", message: message)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helper Formatting
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count > 1, let first = components.first?.first, let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        } else if let first = name.first {
            if name.count > 1 {
                let secondIndex = name.index(name.startIndex, offsetBy: 1)
                return "\(first)\(name[secondIndex])".uppercased()
            }
            return "\(first)".uppercased()
        }
        return "ST"
    }
    
    private func getAvatarColor(from name: String) -> UIColor {
        let colors: [UIColor] = [
            UIColor(red: 0.62, green: 0.38, blue: 0.93, alpha: 1.0), // AV purple
            UIColor(red: 0.0, green: 0.69, blue: 0.81, alpha: 1.0),
            UIColor(red: 0.0, green: 0.74, blue: 0.83, alpha: 1.0),
            UIColor(red: 0.18, green: 0.49, blue: 0.96, alpha: 1.0)
        ]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExamTableViewCell", for: indexPath) as? ExamTableViewCell else {
            return UITableViewCell()
        }
        let exam = exams[indexPath.row]
        let isSelected = selectedExams.contains(exam.id)
        cell.configure(with: exam, isSelected: isSelected, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exam = exams[indexPath.row]
        if selectedExams.contains(exam.id) {
            selectedExams.remove(exam.id)
        } else {
            selectedExams.insert(exam.id)
        }
        tableView.reloadData()
        updateFooterStatus()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
}
