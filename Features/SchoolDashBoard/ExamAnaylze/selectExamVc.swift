//
//  selectExamVc.swift
//  School Chimes
//
//  Created by apple on 04/08/26.
//

import UIKit

class selectExamVc: UIViewController ,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var defaultLblStack: UIStackView!
    @IBOutlet weak var noRecLabel: UILabel!
    @IBOutlet weak var noRecStack: UIStackView!
    @IBOutlet weak var studentInfoView: UIView!
    @IBOutlet weak var standardAndSec: UILabel!
    @IBOutlet weak var admissinNoLbl: UILabel!
    @IBOutlet weak var rollnumberLbl: UILabel!
    @IBOutlet weak var selectedStudentAvatarView: UIView!
    @IBOutlet weak var selectedStudentInitialsLabel: UILabel!
    @IBOutlet weak var selectedStudentNameLabel: UILabel!
   
    @IBOutlet weak var topBackBtnName: UIButton!
    @IBOutlet weak var examsTableView: SelfSizingTableView!
    
    @IBOutlet weak var selectedExamsCountLabel: UILabel!
    
    @IBOutlet weak var viewAnalysisButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    
    // MARK: - Injected Properties
    var student: StudentDetails?
    var classAndSectionText: String = ""
    var classId :String?
    var sectionId:String?
    var setId: String?
    // MARK: - Private Properties
    private var exams: [Exam] = []
    var selectedExamId: String?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var childDetails = UserDefaultFileManager.get_child_Details()
    var loginType: Int?
    var examAnalsyist: [analysisData] = []
    private var selectedSetId: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        getAnaylisExam(classid: classId ?? "" , sectionid: sectionId ?? "")
    }
    
    @IBAction func backBtnAct(_ sender: UIButton) {
        dismiss(animated: true)
    }
   
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1.0)
//        topBackBtnName.setTitle(MenuStringFile.selectedMenuName, for: .normal)
        // 1. Configure Header Card
        selectedStudentAvatarView.layer.cornerRadius = 20
        selectedStudentAvatarView.clipsToBounds = true
        
        changeButton.layer.cornerRadius = 15
        changeButton.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.96, alpha: 1.0)
        changeButton.setTitleColor(UIColor(red: 0.35, green: 0.45, blue: 0.56, alpha: 1.0), for: .normal)
        studentInfoView.isHidden = loginType == 2 ? true : false
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
        examsTableView.register(UINib(nibName: "SetTableViewCell", bundle: nil), forCellReuseIdentifier: "SetTableViewCell")
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
        viewAnalysisButton.setTitleColor(.white, for: .normal)
        
        updateButtonState()
    }

    

    
    func getAnaylisExam(classid: String,sectionid : String){
        showActivityLoader()
        APIService.shared.makeApi(url: ServiceUrl.exam_api_exam_test_analysis_sets_list, parameters: ["class_id" : loginType == 2 ? "" : classid ,"section_id" : loginType == 2 ? "" : sectionid ], type: ApitTypeSringFile.GET, token: loginType == 2 ? childDetails?.access_token ?? "" : staffDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (result: Result<analysisRespSuc , Error>) in
            
            DispatchQueue.main.sync { [weak self] in
                
                guard let self = self else {return}
                
                switch result {
                case .success(let success):
                    if success.status ?? false{
                        noRecStack.isHidden = true
                        examsTableView.isHidden = false
                        examAnalsyist = success.data ?? []
                        viewAnalysisButton.isHidden = false
                        defaultLblStack.isHidden = false
                        examsTableView.reloadData()
                        hideActivityLoader()
                    }else{
                        examAnalsyist = []
                        examsTableView.reloadData()
                        examsTableView.isHidden = true
                        viewAnalysisButton.isHidden = true
                        noRecStack.isHidden = false
                        defaultLblStack.isHidden = true
                        noRecLabel.text = success.message
                        hideActivityLoader()
                    }
                    
                case .failure(let failure):
                    examsTableView.isHidden = true
                    viewAnalysisButton.isHidden = true
                    noRecStack.isHidden = false
                    defaultLblStack.isHidden = true
                    noRecLabel.text = failure.localizedDescription
                    hideActivityLoader()
                }
            }
            
        }
    }
    
  
    

    
    // MARK: - Actions
    @IBAction func didTapChange(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func didTapSelectAll(_ sender: UIButton) {
////        if selectedExams.count == examAnalsyist.count {
////            selectedExams.removeAll()
////        } else {
////            selectedExams = Set(examAnalsyist.map { $0.id ?? "" })
////        }
////        examsTableView.reloadData()
////        updateFooterStatus()
//    }
    
    @IBAction func didTapViewAnalysis(_ sender: UIButton) {

       
        let vc = anaylizesVc()
        vc.student = student
        vc.loginType = loginType
        vc.SetId = selectedSetId
        vc.classAndSectionText = classAndSectionText
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
        return examAnalsyist.count
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SetTableViewCell", for: indexPath) as? SetTableViewCell else {
            return UITableViewCell()
        }
        let set = examAnalsyist[indexPath.row]
        let isSelected = (set.id == selectedSetId)
        cell.configure(with: set, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let set = examAnalsyist[indexPath.row]
        selectedSetId = set.id ?? ""
        tableView.reloadData()
        updateButtonState()
    }
    
    private func updateButtonState() {
        let isEnabled = !selectedSetId.isEmpty
        viewAnalysisButton.isEnabled = isEnabled
        viewAnalysisButton.alpha = isEnabled ? 1.0 : 0.5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
