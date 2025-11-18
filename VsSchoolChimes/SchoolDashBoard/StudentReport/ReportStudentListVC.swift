//
//  ReportStudentListVC.swift
//  VsSchoolChimes
//
//  Created by admin on 09/12/24.
//

import UIKit
import DropDown

class ReportStudentListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var searchHidBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchHeight: NSLayoutConstraint!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var nodataImg: UIImageView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var classView: UIView!
    @IBOutlet weak var reportTable: UITableView!
    @IBOutlet weak var FilterCV: UICollectionView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var selectedType: UIButton!
    @IBOutlet weak var sectionBtn: UIButton!
    @IBOutlet weak var clsBtn: UIButton!
    var sectionDropdown = DropDown()
    var classDropdown = DropDown()
    var fillterDropdown = DropDown()
    var AcodemicDropdown = DropDown()
    var GenderDropdown = DropDown()
    var sectionsDetails: [sectionsDetail]?
    var standardDetails: [StandardDetail]?
    var accadimYr :[String] = []
    @IBOutlet weak var sectionSelection: UIStackView!
    @IBOutlet weak var classSelection: UIStackView!
    @IBOutlet weak var getStanderd: UIStackView!
    
    @IBOutlet weak var reportSegment: UISegmentedControl!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var GenderBtn: UIButton!
    
    var standerdArray = [String]()
    var sectionArray = [String]()
    var selectStudentType = ""
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var imgs = ["shiyam","StudImg","stuentimg 1"]
    var Sorting = ["Name A-Z ","Name Z-A","Roll No ↑","Roll No ↓","Admission No ↓","Admission No ↑"]
    var Gender = ["All","Male","Female","Others"]
    var Filters = ["All students"]
    var studentList : [StudentData]?
    var filterStudent : [StudentData]?
    var sortedStudent : [StudentData]?
    let menuName = MenuStringFile()
    var classId:String?
    var sectionId:String?
   // var selection:String?
    var showSearch:Bool = false
    var academicId = 0
    var noRecord:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        searchBar.applyRightTxt()
        getacadmicYr()
        uiConfic()
        
        let cvnib = UINib(nibName:CellConfingName.FiltersCvCell , bundle: nil)
        FilterCV.register(cvnib, forCellWithReuseIdentifier: CellConfingName.FiltersCvCell)
        
        if #available(iOS 14.0, *) {
            FilterCV.dataSource = self
            FilterCV.delegate = self
        }
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
        
        GenderBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        GenderBtn.layer.cornerRadius = 10
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
//        searchHidBtn.isHidden = true
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
        showSearch.toggle()
        searchHeight.constant = showSearch ? 60 : 0
        if sender.isSelected{
            searchBar.becomeFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else{
            searchBar.resignFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            searchBar.searchTextField.text = ""
            nodataImg.isHidden = true
            nodataLbl.isHidden = true
            filterStudent = studentList
            reportTable.reloadData()
           
            
        }
    }
    @IBAction func hideSearch(_ sender: UIButton) {
        showSearch.toggle()
        searchHeight.constant = showSearch ? 60 : 0
        let img = showSearch ? UIImage(systemName: "magnifyingglass.circle.fill") : UIImage(systemName: "magnifyingglass")
        searchBtn.setImage(img, for: .normal)
        searchBar.text = ""
        nodataImg.isHidden = true
        nodataLbl.isHidden = true
        filterStudent = studentList
        reportTable.reloadData()
//        searchHidBtn.isHidden = !showSearch
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
        
        fillterDropdown.dataSource = Filters
        fillterDropdown.anchorView = filterView
        fillterDropdown.bottomOffset = CGPoint(x:0, y: (filterBtn.bounds.height))
        fillterDropdown.direction = .bottom
        
        fillterDropdown.show()
        fillterDropdown.selectionAction = { [self] (index: Int, item: String) in
            self.filterBtn.setTitle(item.translated(), for: .normal)
            
            if !noRecord  {
                switch index{
                case 0:
                    
                    getStanderd.isHidden = true
                    getStudentAPI()
                  
                case 1:
                    
                    if sectionArray.first != "All" {
                        sectionArray.insert("All", at: 0)
                    }
                    sectionBtn.setTitle(sectionArray.first, for: .normal)
                    getStanderd.isHidden = false
                    sectionSelection.isHidden = false
                    classId = standardDetails?.first?.id
                    getStudentAPI(class_id:classId)
                    
                default:
                    getStanderd.isHidden = true
                    getStudentAPI()
                }
                
                reportTable.reloadData()
                //self.filterBtn.setTitle(item.translated(), for: .normal)
            }
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
            searchHeight.constant = 0
            searchBar.text = ""
            searchBtn
                .setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            getStandardsAPI(
                academic_year_id: localData.accidamic_year_data?
                    .data?[index].id ?? 0
            )
            academicId = localData.accidamic_year_data?.data?[index].id ?? 0
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
            self.sectionBtn.setTitle(item, for: .normal)
            if index == 0{
                getStudentAPI(class_id:classId)
                
            }else{
                sectionId = sectionsDetails?[index - 1].id ?? ""
                getStudentAPI(class_id:classId,section_id:sectionId)
            }
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
            if sectionArray.first != "All" {
                   sectionArray.insert("All", at: 0)
               }
            self.clsBtn.setTitle(item.translated(), for: .normal)
            self.sectionBtn.setTitle(sectionArray.first, for: .normal)
            classId = standardDetails?[index].id ?? ""
            sectionId = standardDetails?[index].sections?.first?.id ?? ""
//            if selection == CommonStringFile.getStanderd_Section.translated(){
//                getStudentAPI(class_id:classId,section_id:sectionId)
//            }else{
                getStudentAPI(class_id:standardDetails?[index].id ?? "")
           //}
        }
    }
    
    @IBAction func GenderSelection(_ sender: UIButton) {
        
        GenderDropdown.dataSource = Gender
           GenderDropdown.anchorView = GenderBtn
           GenderDropdown.bottomOffset = CGPoint(x: 0, y: GenderBtn.bounds.height)
           GenderDropdown.width = GenderBtn.bounds.width

           GenderDropdown.selectionAction = { [weak self] (index: Int, selectedGender: String) in
               guard let self = self else { return }
               searchBar.text = ""
               self.GenderBtn.setTitle(selectedGender, for: .normal)
               self.filterStudents(by: selectedGender)
               self.reportTable.reloadData()
           }

           GenderDropdown.show()
    }
    
    private func filterStudents(by gender: String) {
        guard let students = studentList else {
            filterStudent = []
            return
        }

        switch gender.lowercased() {
        case "male":
            filterStudent = students.filter { $0.gender.lowercased() == "male" }

        case "female":
            filterStudent = students.filter { $0.gender.lowercased() == "female" }

        case "others":
            filterStudent = students.filter {
                let g = $0.gender.lowercased()
                return g != "male" && g != "female"
            }

        case "all":
            filterStudent = students

        default:
            filterStudent = students
        }
        
        selectedIndex = IndexPath(item: 0, section: 0)
        FilterCV.reloadData()
        self.sortedStudent = self.filterStudent?.sorted {
            $0.name.localizedCompare($1.name) == .orderedAscending
        }
        
        self.filterStudent = self.sortedStudent
        nodataImg.isHidden = !(filterStudent?.isEmpty ?? false)
        nodataLbl.isHidden = !(filterStudent?.isEmpty ?? false)
        nodataLbl.text = "No data found"

        print("Filtered student count: \(filterStudent?.count ?? 0)")
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
                        if Filters.count == 1{
                            Filters.append("Class & Section")
                        }
                        sectionsDetails = standardDetails?.first?.sections
                        standerdArray = standardDetails?.compactMap { $0.name } ?? []
                        sectionArray = sectionsDetails?.compactMap { $0.name } ?? []
                        clsBtn.setTitle(standardDetails?.first?.name, for: .normal)
                        //sectionBtn.setTitle(sectionsDetails?.first?.name, for: .normal)
                        classId = standardDetails?.first?.id
                        sectionId = sectionsDetails?.first?.id
//                        classId = ""
//                        sectionId = ""
                        searchBtn.isHidden = false
                        getStanderd.isHidden = true
                        noRecord = false
                        self.filterBtn.setTitle("All students", for: .normal)
                        getStudentAPI()
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        sectionArray.removeAll()
                        standerdArray.removeAll()
                        studentList?.removeAll()
                        filterStudent?.removeAll()
                        getStanderd.isHidden = true
                        self.filterBtn.setTitle("All students", for: .normal)
                        nodataImg.isHidden = false
                        searchBtn.isHidden = true
                        nodataLbl.isHidden = false
                        nodataLbl.text = successMessage.message
                        FilterCV.isHidden = true
                        GenderBtn.isHidden = true
                        noRecord = true
//                        Filters.removeLast()
//                        Filters.removeAll()
                        FilterCV.reloadData()
                        reportTable.reloadData()
                       // getStudentAPI()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    print(error.localizedDescription)
                    
                }
                
            }
        }
        
    }
    func getStudentAPI(class_id: String? = nil, section_id: String? = nil) {
        var param: [String: Any] = [:]
        param[COMMON_PARAMETER.academic_year_id] = academicId
        if let classID = class_id {
            param[GetStudentReport.class_id] = classID
        }
        if let sectionID = section_id {
            param[GetStudentReport.section_id] = sectionID
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.api_get_student_report,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<StudentReportResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status == true {
                        self.studentList = response.data
                        self.filterStudent = self.studentList
                      
                        if let gender = self.GenderDropdown.selectedItem {
                            self.filterStudents(by: gender)
                        }else {
                            self.filterStudents(by: self.Gender.first ?? "All")
                        }
                        
                        self.sortedStudent = self.filterStudent?.sorted {
                            $0.name.localizedCompare($1.name) == .orderedAscending
                        }
                        
                        self.filterStudent = self.sortedStudent
                        
                        self.selectedIndex = IndexPath(item: 0, section: 0)
                        self.nodataImg.isHidden = !(self.filterStudent?.isEmpty ?? false)
                        self.nodataLbl.isHidden = !(self.filterStudent?.isEmpty ?? false)
                        self.FilterCV.isHidden = (self.filterStudent?.isEmpty ?? false)
                        self.GenderBtn.isHidden = (self.filterStudent?.isEmpty ?? false)
                        //self.reportSegment.isHidden = false
                        self.searchBtn.isHidden = false
                        self.FilterCV.reloadData()
                    } else {
                        self.studentList = response.data
                        self.sortedStudent = response.data
                        self.filterStudent = response.data
                        self.searchBtn.isHidden = true
                        self.nodataLbl.text = response.message
                        self.nodataLbl.isHidden = false
                        self.nodataImg.isHidden = false
                        self.FilterCV.isHidden = true
                        self.GenderBtn.isHidden = true
                        self.searchBtn.isHidden = true
                        //                    self.reportSegment.isHidden = true
                    }
                    self.reportTable.reloadData()
                    
                case .failure(let error):
                    self.nodataLbl.text = error.localizedDescription
                    self.nodataLbl.isHidden = false
                    self.nodataImg.isHidden = false
                    print("API Error: \(error.localizedDescription)")
                    self.filterStudent = []
                    self.studentList = []
                    self.searchBtn.isHidden = true
                    self.reportTable.reloadData()
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
                    if localData.accidamic_year_data?.status == true{
                        DispatchQueue.main.async { [self] in
                            for i in 0..<(
                                localData.accidamic_year_data?.data?.count ?? 0
                            ){
                                if localData.accidamic_year_data?
                                    .data?[i].current_academic_year ?? false == true{
                                    selectedType.setTitle((localData.accidamic_year_data?
                                    .data?[i].year ?? ""), for: .normal)
                                    academicId = localData.accidamic_year_data?
                                        .data?[i].id ?? 0
                                    getStandardsAPI(academic_year_id: localData.accidamic_year_data?
                                        .data?[i].id ?? 0)
                                }
                                accadimYr.append(localData.accidamic_year_data?
                                    .data?[i].year ?? "")
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
            
            let trimmedMobile = studentDetail.primary_mobile?.trimmingCharacters(in: .whitespacesAndNewlines)
            cell.CallBtn.isHidden = trimmedMobile?.isEmpty ?? true
            cell.SmsNewBtn.isHidden = trimmedMobile?.isEmpty ?? true

            let trimmedEmail = (studentDetail.email ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            cell.EmailNewBtn.isHidden = trimmedEmail.isEmpty

            cell.smsNumber = studentDetail.primary_mobile ?? ""
            cell.Email = studentDetail.email ?? ""
            
            cell.tcherLbl.text = studentDetail.class_teacher
            cell.rollNo.text = studentDetail.roll_no
            cell.admissionLbl.text = studentDetail.admission_no
            cell.dobLbl.text = studentDetail.dob.convertToTargetDateFormat()
            cell.studentNmae.text = studentDetail.name
            cell.standerdLbl.text = studentDetail.class_name + " - " + studentDetail.section_name
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
@available(iOS 14.0, *)
extension ReportStudentListVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Sorting.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = FilterCV.dequeueReusableCell(withReuseIdentifier: CellConfingName.FiltersCvCell, for: indexPath) as! FiltersCvCell
        
        cell.FilterLbl.text = Sorting[indexPath.item]
        let isSelected = indexPath == selectedIndex
        
        cell.cellView.backgroundColor = isSelected ? UIColor.countryClr  : UIColor.systemGray5
        //        cell.cellView.layer.cornerRadius = 12
        //        cell.cellView.layer.borderWidth = isSelected ? 1 : 0
        //        cell.cellView.layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.clear.cgColor
        cell.cellView.layer.masksToBounds = false
        
        // Shadow settings
        cell.cellView.layer.shadowColor = UIColor.black.cgColor
        cell.cellView.layer.shadowOpacity = isSelected ? 0.2 : 0.0
        cell.cellView.layer.shadowRadius = isSelected ? 4 : 0
        cell.cellView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.CheckboxImg.isHidden = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < Sorting.count else { return }
        searchBar.text = ""
        selectedIndex = indexPath
        let selectedFilter = Sorting[indexPath.item]
        
        guard let sortedStudent = filterStudent else { return }
        
        switch selectedFilter {
            case Sorting[0]:   // Name A-Z
                filterStudent = sortedStudent.sorted {
                    $0.name.localizedCompare($1.name) == .orderedAscending
                }
                
            case Sorting[1]:   // Name Z-A
                filterStudent = sortedStudent.sorted {
                    $0.name.localizedCompare($1.name) == .orderedDescending
                }
                
            case Sorting[2]:   // Roll no ascending
                filterStudent = sortedStudent.sorted {
                    $0.roll_no < $1.roll_no
                    
                }
                
            case Sorting[3]:   // Roll no descending
                filterStudent = sortedStudent.sorted {
                    $0.roll_no > $1.roll_no
                }

            case Sorting[4]:   // Admission no ascending
                filterStudent = sortedStudent.sorted {
                    $0.admission_no.compare($1.admission_no,
                                             options: [.numeric, .caseInsensitive]) == .orderedAscending
                }

            case Sorting[5]:   // Admission no descending
                filterStudent = sortedStudent.sorted {
                    $0.admission_no.compare($1.admission_no,
                                             options: [.numeric, .caseInsensitive]) == .orderedDescending
                }

            default:
                filterStudent = sortedStudent
            }
            
            FilterCV.reloadData()
            reportTable.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let text = Sorting[indexPath.item] // Assuming your label text is from a data source
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16) // Use the same font as in Storyboard
        label.text = text
        label.sizeToFit()
        
        let width = label.frame.width + 60  // Add padding
        return CGSize(width: width, height: 40) // Adjust height accordingly
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
                (student.primary_mobile?.lowercased().contains(lowercasedSearch) ?? false) ||
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
        
        reportTable.reloadData()
        
        let isEmpty = filterStudent?.isEmpty ?? true
        nodataImg.isHidden = !isEmpty
        nodataLbl.isHidden = !isEmpty
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


