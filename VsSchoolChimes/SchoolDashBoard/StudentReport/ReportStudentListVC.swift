//
//  ReportStudentListVC.swift
//  VsSchoolChimes
//
//  Created by admin on 09/12/24.
//

import UIKit
import DropDown

class ReportStudentListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var searchHeight: NSLayoutConstraint!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var nodataImg: UIImageView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var classView: UIView!
    @IBOutlet weak var reportTable: UITableView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var selectedType: UIButton!
    @IBOutlet weak var sectionBtn: UIButton!
    @IBOutlet weak var clsBtn: UIButton!
    var sectionDropdown = DropDown()
    var classDropdown = DropDown()
    var fillterDropdown = DropDown()
    var AcodemicDropdown = DropDown()
    var sectionsDetails: [sectionsDetail]?
    var standardDetails: [StandardDetail]?
    var AcadimicYearDatas : [AcadimicYearData] = []
    var accadimYr :[String] = []
    @IBOutlet weak var sectionSelection: UIStackView!
    @IBOutlet weak var classSelection: UIStackView!
    @IBOutlet weak var getStanderd: UIStackView!
    
    @IBOutlet weak var reportSegment: UISegmentedControl!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    var standerdArray = [String]()
    var sectionArray = [String]()
    var selectStudentType = ""
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var studentList : [StudentData]?
    var imgs = ["shiyam","StudImg","stuentimg 1"]
    var filterStudent : [StudentData]?
    var sortedStudent : [StudentData]?
    let menuName = MenuStringFile()
    var classId:String?
    var sectionId:String?
    var selection:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        searchBar.applyRightTxt()
        getacadmicYr()
        uiConfic()
        
        if #available(iOS 14.0, *) {
            searchBar.searchTextField.addDoneButton()
            searchBar.delegate = self
        }
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    
    func uiConfic(){
        reportTable.register(UINib(nibName: CellConfingName.ReportStudentTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.ReportStudentTVC)
        sectionView.layer.cornerRadius = 10
        sectionView.layer.shadowColor = UIColor.black.cgColor
        sectionView.layer.shadowOffset = CGSize(width: 4, height: 4)
        sectionView.layer.shadowOpacity = 0.5
        sectionView.layer.shadowRadius = 4
        classView.layer.cornerRadius = 10
        classView.layer.shadowColor = UIColor.black.cgColor
        classView.layer.shadowOffset = CGSize(width: 4, height: 4)
        filterBtn.layer.cornerRadius = 10
        filterBtn.layer.shadowColor = UIColor.black.cgColor
        filterBtn.layer.shadowOffset = CGSize(width: 4, height: 4)
        filterBtn.layer.shadowOpacity = 0.5
        filterBtn.layer.shadowRadius = 4
        filterBtn.backgroundColor = .white
        getStanderd.isHidden = true
        selectedType.layer.cornerRadius = 10
        selectedType.layer.shadowColor = UIColor.black.cgColor
        selectedType.layer.shadowOffset = CGSize(width: 4, height: 4)
        selectedType.layer.shadowOpacity = 0.5
        selectedType.layer.shadowRadius = 4
        selectedType.backgroundColor = .white
        classView.layer.shadowOpacity = 0.5
        classView.layer.shadowRadius = 4
        
        //MARK: Label Font
        sectionBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        clsBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        selectedType.setTitleFont(style: .body, size: FontSize.BodySize)
        searchBar.placeholder = CommonStringFile.Search.translated()
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func Search(_ sender: UIButton) {
        sender.isSelected.toggle()
        searchHeight.constant = sender.isSelected ? 60 : 0
        let img = sender.isSelected ? UIImage(systemName: "magnifyingglass.circle.fill"):UIImage(systemName: "magnifyingglass")
        sender.setImage(img, for: .normal)
    }
    @IBAction func sortArray(_ sender: UISegmentedControl) {
        guard let sortedStudent = sortedStudent else { return }

        switch sender.selectedSegmentIndex {
        case 0:
            // Sort by name ascending (A-Z)
            filterStudent = sortedStudent.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
            
        case 1:
            // Sort by name descending (Z-A)
            filterStudent = sortedStudent.sorted { $0.name.localizedCompare($1.name) == .orderedDescending }

        case 2:
            // Sort by admission_no ascending
            filterStudent = sortedStudent.sorted { $0.admission_no < $1.admission_no }

        case 3:
            // Sort by admission_no descending
            filterStudent = sortedStudent.sorted { $0.admission_no > $1.admission_no }

        default:
            // Default fallback: sort by name descending
            filterStudent = sortedStudent.sorted { $0.name.localizedCompare($1.name) == .orderedDescending }
        }

        reportTable.reloadData()
    }

    
    @IBAction func filterStudent(_ sender: UIButton) {
        
        fillterDropdown.dataSource = [CommonStringFile.getAllStudent.translated(),CommonStringFile.getStanderd.translated(),CommonStringFile.getStanderd_Section.translated()]
        fillterDropdown.anchorView = filterView
        fillterDropdown.bottomOffset = CGPoint(x:0, y: (filterBtn.bounds.height))
        fillterDropdown.direction = .bottom
        
        fillterDropdown.show()
        fillterDropdown.selectionAction = { [self] (index: Int, item: String) in
            self.filterBtn.setTitle(item.translated(), for: .normal)
            
            switch item.translated(){
            case CommonStringFile.getStanderd_Section.translated():
                getStanderd.isHidden = false
                sectionSelection.isHidden = false
                selection = CommonStringFile.getStanderd_Section.translated()
                getStudentAPI(class_id:classId,section_id:sectionId)
            case CommonStringFile.getStanderd.translated():
                getStanderd.isHidden = false
                sectionSelection.isHidden = true
                selection = CommonStringFile.getStanderd.translated()
                getStudentAPI(class_id:classId)
            default:
                getStanderd.isHidden = true
                getStudentAPI()
                
            }
            reportTable.reloadData()
            self.filterBtn.setTitle(item.translated(), for: .normal)
        }
    }
    @IBAction func selectCatagory(_ sender: UIButton) {
        AcodemicDropdown.dataSource = accadimYr
        
        AcodemicDropdown.anchorView = selectedType
        AcodemicDropdown.bottomOffset = CGPoint(x: 0, y: selectedType.bounds.height)
        AcodemicDropdown.direction = .bottom
        AcodemicDropdown.width = selectedType.bounds.width
        AcodemicDropdown.show()
        AcodemicDropdown.selectionAction = { [self] (index: Int, item: String) in
            getStandardsAPI(academic_year_id: AcadimicYearDatas[index].id ?? 0)
            selectedType.setTitle("\(selectStudentType) \(item)", for: .normal)
        }
    }
    
    @IBAction func section(_ sender: UIButton) {
        sectionDropdown.dataSource = sectionArray
        
        sectionDropdown.anchorView = sectionView
        sectionDropdown.bottomOffset = CGPoint(x: 0, y: sectionView.bounds.height)
        sectionDropdown.direction = .bottom
        sectionDropdown.width = sectionView.bounds.width
        sectionDropdown.show()
        sectionDropdown.selectionAction = { [self] (index: Int, item: String) in
            sectionId = sectionsDetails?[index].id ?? ""
            getStudentAPI(class_id:classId,section_id:sectionId)
            self.sectionBtn.setTitle(item, for: .normal)
        }
    }
    @IBAction func classSelection(_ sender: UIButton) {
        // Configuring the dropdown
        classDropdown.dataSource = standerdArray
        classDropdown.anchorView = classView
        classDropdown.bottomOffset = CGPoint(x: 0, y: classView.bounds.height)
        classDropdown.direction = .bottom
        classDropdown.width = classView.bounds.width
        // Show the dropdown
        classDropdown.show()
        classDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            sectionsDetails = standardDetails?[index].sections
            
            sectionArray = sectionsDetails?.compactMap { $0.name } ?? []
            self.clsBtn.setTitle(item.translated(), for: .normal)
            self.sectionBtn.setTitle(standardDetails?[index].sections?.first?.name, for: .normal)
            classId = standardDetails?[index].id ?? ""
            sectionId = standardDetails?[index].sections?.first?.id ?? ""
            if selection == CommonStringFile.getStanderd_Section.translated(){
                getStudentAPI(class_id:classId,section_id:sectionId)
            }else{
                getStudentAPI(class_id:standardDetails?[index].id ?? "")
            }
        }
    }
    func getStandardsAPI(academic_year_id:Int){
        standerdArray.removeAll()
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: [COMMON_PARAMETER.academic_year_id : academic_year_id], type: ApitTypeSringFile.GET, token:UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [self] (result:Result <GetStandardsSuc,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        sectionArray.removeAll()
                        standerdArray.removeAll()
                        standardDetails = successMessage.data
                        sectionsDetails = standardDetails?.first?.sections
                        standerdArray = standardDetails?.compactMap { $0.name } ?? []
                        sectionArray = sectionsDetails?.compactMap { $0.name } ?? []
                        clsBtn.setTitle(standardDetails?.first?.name, for: .normal)
                        sectionBtn.setTitle(sectionsDetails?.first?.name, for: .normal)
                        classId = standardDetails?.first?.id
                        sectionId = sectionsDetails?.first?.id
                        classId = ""
                        sectionId = ""
                        getStanderd.isHidden = true
                        self.filterBtn.setTitle(CommonStringFile.getAllStudent.translated(), for: .normal)
                        getStudentAPI()
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    print(error.localizedDescription)
                    
                }
                
            }
        }
        
    }
    func getStudentAPI(class_id:String? = nil,section_id:String? = nil){
        var param: [String: Any] = [:]
        
        if let classID = class_id {
            param[GetStudentReport.class_id] = classID
        }
        if let sectionID = section_id {
            param[GetStudentReport.section_id] = sectionID
        }
        APIService.shared.makeApi(url: ServiceUrl.api_get_student_report, parameters:param, type: ApitTypeSringFile.GET, token:UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [self] (result:Result<StudentReportResponse,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        studentList = successMessage.data
                        nodataLbl.isHidden = true
                        nodataImg.isHidden = true
                        reportSegment.isHidden = false
                        filterStudent = studentList
                        sortedStudent = studentList
                        reportTable.reloadData()
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        studentList = successMessage.data
                        nodataLbl.text = successMessage.message
                        nodataImg.isHidden = false
                        nodataLbl.isHidden = false
                        reportSegment.isHidden = true
                        filterStudent = studentList
                        sortedStudent = studentList
                        reportTable.reloadData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    print(error.localizedDescription)
                    nodataLbl.text = error.localizedDescription
                    nodataImg.isHidden = false
                }
                
            }
        }
        
    }
    func getacadmicYr(){
        APIService.shared
            .makeApi(url: ServiceUrl.comm_recipient_get_academic_year_list , parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <get_academic_yearSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            AcadimicYearDatas = successMessage.data ?? []
                            for i in 0..<(AcadimicYearDatas.count){
                                if AcadimicYearDatas[i].current_academic_year ?? false == true{
                                    selectedType.setTitle("\(AcadimicYearDatas[i].year ?? "")", for: .normal)
                                    getStandardsAPI(academic_year_id: AcadimicYearDatas[i].id ?? 0)
                                }
                                accadimYr.append(AcadimicYearDatas[i].year ?? "")
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterStudent?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reportTable.dequeueReusableCell(withIdentifier: CellConfingName.ReportStudentTVC, for: indexPath) as! ReportStudentTVC
        cell.smsBtn.tag = indexPath.row
        cell.mobleNo.tag = indexPath.row
        cell.emailBtn.tag = indexPath.row
        
        if let studentDetail = filterStudent?[indexPath.row]{
           
            cell.confic(student: studentDetail)
            if let mobile = studentDetail.primary_mobile, !mobile.isEmpty,
               let email = studentDetail.email, !email.isEmpty {
                
                let attributedString = NSAttributedString(
                    string: mobile,
                    attributes: [
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .foregroundColor: cell.mobleNo.titleColor(for: .normal) ?? UIColor.systemBlue
                    ]
                )
                let attributedString1 = NSAttributedString(
                    string: email,
                    attributes: [
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .foregroundColor: cell.emailBtn.titleColor(for: .normal) ?? UIColor.systemBlue
                    ]
                )
                cell.smsNumber = mobile
                cell.mobleNo.setAttributedTitle(attributedString, for: .normal)
                cell.emailBtn.setAttributedTitle(attributedString1, for: .normal)
                cell.mobleNo.isHidden = false
                cell.smsBtn.isHidden = false
            } else {
                cell.mobleNo.isHidden = true
                cell.smsBtn.isHidden = true
                cell.emailBtn.isHidden = true
            }



            cell.tcherLbl.text = studentDetail.class_teacher
            cell.admissionLbl.text = studentDetail.admission_no
            cell.dobLbl.text = studentDetail.dob
            cell.studentNmae.text = studentDetail.name
            cell.standerdLbl.text = studentDetail.class_name
            cell.sectionLbl.text = studentDetail.section_name
            cell.genderLbl.text = studentDetail.gender
            cell.fatherName.text = studentDetail.father_name
            cell.imgView.contentMode = .scaleAspectFill
            if let img = URL(string: studentDetail.profile){
                cell.imgView.kf.setImage(with:img)
            }else{
                cell.imgView.image = ImageName.Default_profile
            }
            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}


class GradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [
            UIColor(red: 147/255, green: 112/255, blue: 219/255, alpha: 1.0).cgColor, // Purple
            UIColor.white.cgColor // White
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0) // Bottom-center
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 10 // Add corner radius to gradient layer
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = self.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = self.bounds // Ensure gradient resizes with view
            gradientLayer.cornerRadius = 10 // Reapply corner radius on resize
        }
        self.layer.cornerRadius = 10 // Add corner radius to the view itself
        self.clipsToBounds = true // Ensure corners are clipped
    }
}

@available(iOS 14.0, *)
extension ReportStudentListVC: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let studentList = studentList else {
            filterStudent = []
            nodataImg.isHidden = false
            nodataLbl.isHidden = false
            reportTable.reloadData()
            return
        }

        let lowercasedSearch = searchText.lowercased()

        if searchText.isEmpty {
            filterStudent = studentList
        } else {
            filterStudent = studentList.filter { student in
                return student.id.lowercased().contains(lowercasedSearch) ||
                       student.name.lowercased().contains(lowercasedSearch) ||
                ((student.primary_mobile?.lowercased().contains(lowercasedSearch)) != nil) ||
                       student.admission_no.lowercased().contains(lowercasedSearch) ||
                       student.roll_no.lowercased().contains(lowercasedSearch) ||
                       student.dob.lowercased().contains(lowercasedSearch) ||
                       student.class_id.lowercased().contains(lowercasedSearch) ||
                       student.class_name.lowercased().contains(lowercasedSearch) ||
                       student.section_id.lowercased().contains(lowercasedSearch) ||
                       student.section_name.lowercased().contains(lowercasedSearch) ||
                       student.father_name.lowercased().contains(lowercasedSearch) ||
                       student.class_teacher.lowercased().contains(lowercasedSearch)
            }
        }

        let isEmpty = filterStudent?.isEmpty ?? true
        nodataImg.isHidden = !isEmpty
        nodataLbl.isHidden = !isEmpty

        reportTable.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
struct StudentList{
    let name:String
    let AdmissionId:String
    let PhoneNumber:String
    let EmailId:String
    let DOB:String
    let fatherName:String
    let teacherName:String
    let gender:String
    let sectionName:String
    let classname:String
    let img : String
}


