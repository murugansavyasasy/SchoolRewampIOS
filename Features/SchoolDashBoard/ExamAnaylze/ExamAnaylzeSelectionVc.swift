//
//  ExamAnaylzeSelectionVc.swift
//  School Chimes
//
//  Created by apple on 04/08/26.
//

import UIKit

class ExamAnaylzeSelectionVc: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var standarFullView: UIView!
    @IBOutlet weak var studentListFullView: UIView!
    @IBOutlet weak var nodataStack: UIStackView!
    @IBOutlet weak var nodataFoundLbl: UILabel!
    @IBOutlet weak var academicYearBtn: UIButton!
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownLabel: UILabel!
  
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var studentTableView: SelfSizingTableView!
    @IBOutlet weak var viewAnalysisButton: UIButton!
    @IBOutlet weak var selectStudentBadgeView: UIView!
    @IBOutlet weak var selectStandardBadgeView: UIView!
    
    // MARK: - Data Properties
   
    private var selectedStudent: StudentDetails?
    var AcadimicYears: [AcadimicYearData] = []
    var AcademicDropdown = DropDown()
    var standardDropdown = DropDown()
    var classList: [ClassDisplayItem] = []
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var studentsDetails: [StudentDetails]?
    var selectedAcademicYearId: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1.0)
        
        dropdownView.layer.cornerRadius = 8
        dropdownView.layer.borderWidth = 1
        dropdownView.layer.borderColor = UIColor(red: 0.11, green: 0.44, blue: 0.95, alpha: 1.0).cgColor
        academicYearBtn.layer.cornerRadius = 8
        academicYearBtn.layer.borderWidth = 1
        academicYearBtn.layer.borderColor = UIColor.white.cgColor
        // Setup step badges
        setupBadge(selectStandardBadgeView)
        setupBadge(selectStudentBadgeView)
        
        // Setup TableView
        studentTableView.dataSource = self
        studentTableView.delegate = self
        studentTableView.register(UINib(nibName: "StudentTableViewCell", bundle: nil), forCellReuseIdentifier: "StudentTableViewCell")
        studentTableView.isScrollEnabled = false
        studentTableView.separatorStyle = .none
        studentTableView.backgroundColor = .clear
        
        // Button style
        viewAnalysisButton.layer.cornerRadius = 10
//        viewAnalysisButton.backgroundColor = UIColor(red: 0.05, green: 0.14, blue: 0.23, alpha: 1.0)
        viewAnalysisButton.setTitleColor(.white, for: .normal)
        viewAnalysisButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    private func setupBadge(_ badgeView: UIView) {
        badgeView.layer.cornerRadius = badgeView.frame.height / 2
        badgeView.clipsToBounds = true
        badgeView.backgroundColor = UIColor(red: 0.05, green: 0.14, blue: 0.23, alpha: 1.0)
    }
    
    private func loadData() {
        getacadmicYr()
        selectedStudent = nil
    }
    @IBAction func academicYearDrop_action(_ sender: UIButton) {
        
        AcademicDropdown.anchorView = academicYearBtn
        AcademicDropdown.dataSource = AcadimicYears.compactMap{$0.year}
        AcademicDropdown.bottomOffset = CGPoint(x: 0, y: academicYearBtn.bounds.height)
        AcademicDropdown.show()
        AcademicDropdown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            
            academicYearBtn.setTitle(item, for: .normal)
            Get_standardSection_Api(academicId :AcadimicYears[index].id ?? 0 )
        }
    }
    
    @IBAction func standardDrop_action(_ sender: UIButton) {

        standardDropdown.anchorView = sender
        standardDropdown.dataSource = classList.compactMap { $0.displayName }
        standardDropdown.bottomOffset = CGPoint(x: 0, y: sender.bounds.height)

        standardDropdown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }

            self.dropdownLabel.text = item

            self.recipient_get_student_list(
                selected_sectionId: self.classList[index].sectionId,
                academic_year_id: self.selectedAcademicYearId ?? 0
            )
        }

        standardDropdown.show()
    }
    func getacadmicYr() {
        AcadimicYears = localData.accidamic_year_data?.data ?? []
        let currentYear = AcadimicYears.first(where: { $0.current_academic_year == true })
        academicYearBtn.setTitle(currentYear?.year, for: .normal)
        selectedAcademicYearId = currentYear?.id
        Get_standardSection_Api(academicId: currentYear?.id ?? 0)
    }
    func Get_standardSection_Api(academicId : Int){
        
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: [COMMON_PARAMETER.academic_year_id: academicId], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (result: Result<GetStandardsSuc , Error>) in
            
            DispatchQueue.main.sync { [weak self] in
                
                guard let self = self else {return}
                
                switch result {
                case .success(let success):
                    if success.status ?? false{
                        classList.removeAll()
                        let standardData =  success.data ?? []
                        
                        for standard in standardData{
                            for section in standard.sections ?? [] {
                                
                                let displayName = "\(standard.name ?? "") - \(section.name ?? "")"
                                classList.append(ClassDisplayItem(displayName: displayName, standardId: standard.id ?? "", sectionId: section.id ?? ""))
                            }
                        }
                        dropdownLabel.text = classList.first?.displayName
                        recipient_get_student_list(selected_sectionId:classList.first?.sectionId ?? "" , academic_year_id: selectedAcademicYearId ?? 0)
                        nodata(isShow: true, message:success.message ?? "" )
                    }else{
                        nodata(isShow: false, message:success.message ?? "" )
                    }
                    
                case .failure(let failure):

                    nodata(isShow: false, message:failure.localizedDescription )
                }
            }
            
        }
    }
    
    
    func recipient_get_student_list(selected_sectionId: String,academic_year_id:Int){
        APIService.shared
            .makeApi(url: ServiceUrl.recipient_get_student_list, parameters: [
                speficStudentStringFile.section_id : selected_sectionId
                ,speficStudentStringFile.academic_year_id : academic_year_id
            ], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false){ [self] (
                result:Result <GetStudentlistSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            studentsDetails = successMessage.data
                            if var students = studentsDetails {
                                for i in students.indices {
                                    students[i].isSelect = false
                                    students[i].isAbsent = true
                                }
                                studentsDetails = students
                            }
                            
                            studentTableView.reloadData()
                            nodata(isShow: true, message:successMessage.message ?? "" )
                            
                        }
                        
                    }else{
                        DispatchQueue.main.async { [self] in
                            nodata(isShow: false, message:successMessage.message ?? "" )
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async { [self] in
                        print(error.localizedDescription)
                        nodata(isShow: false, message:error.localizedDescription)
                    }
                }
            }
        
    }

    private func nodata(isShow : Bool,message : String){
        studentListFullView.isHidden = !isShow
        standarFullView.isHidden = !isShow
        nodataStack.isHidden = isShow
        nodataFoundLbl.text = message
        footerView.isHidden = !isShow
    }

    
    @IBAction func didTapViewAnalysis(_ sender: UIButton) {
        guard let student = selectedStudent else {
            showAlert(title: "Selection Required", message: "Please select a student.")
            return
        }
        
        let examVC = selectExamVc()
        examVC.student = student
        examVC.classAndSectionText = dropdownLabel.text ?? ""
        examVC.modalPresentationStyle = .fullScreen
        present(examVC, animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableViewCell", for: indexPath) as? StudentTableViewCell else {
            return UITableViewCell()
        }
        guard let student = studentsDetails?[indexPath.row] else {return cell}
        let isSelected = selectedStudent?.id == student.id
        
        cell.configure(with: student , isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStudent = studentsDetails?[indexPath.row]
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
