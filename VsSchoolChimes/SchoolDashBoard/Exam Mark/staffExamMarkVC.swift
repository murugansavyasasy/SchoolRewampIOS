//
//  staffExamMarkVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 24/11/25.
//

import UIKit

class staffExamMarkVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var academicYearBtn: UIButton!
    @IBOutlet weak var selectYourClassLbl: UILabel!
    @IBOutlet weak var chooseClassLbl: UILabel!
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var AcadimicYears: [AcadimicYearData] = []
    var AcademicDropdown = DropDown()
    var classList: [ClassDisplayItem] = []
    var filteredClassList: [ClassDisplayItem] = []
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectYourClassLbl.setFont(style: .title, size: FontSize.HeaderSize)
        chooseClassLbl.setFont(style: .body, size: FontSize.BodySize)
        noDataLbl.setFont(style: .body, size: FontSize.TitleSize)
        academicYearBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        titleLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName,secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        
        selectYourClassLbl.text = ExamMarkUploadString.Select_Your_Class.translated()
        chooseClassLbl.text = ExamMarkUploadString.Choose_a_class_to_start_processing_marks.translated()
        
        noDataImage.isHidden = true
        noDataLbl.isHidden = true
        searchBtn.isHidden = true
        
        searchBar.isHidden = true
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.backgroundImage = UIImage()
        
        tv.register(UINib(nibName: CellConfingName.Exam_ClassListTV, bundle: nil), forCellReuseIdentifier: CellConfingName.Exam_ClassListTV)
        
        tv.delegate = self
        tv.dataSource = self
        
        if localData.accidamic_year_data?.data?.isEmpty == false {
            getacadmicYr()
        }
    }
    
    func getacadmicYr() {
        AcadimicYears = localData.accidamic_year_data?.data ?? []
        let currentYear = AcadimicYears.first(where: { $0.current_academic_year == true })
        academicYearBtn.setTitle(currentYear?.year, for: .normal)
        Get_standardSection_Api(academicId: currentYear?.id ?? 0)
    }
    
    @IBAction func academicYearDrop_action(_ sender: UIButton) {
        
        AcademicDropdown.anchorView = academicYearBtn
        AcademicDropdown.dataSource = AcadimicYears.compactMap{$0.year}
        AcademicDropdown.bottomOffset = CGPoint(x: 0, y: academicYearBtn.bounds.height)
        AcademicDropdown.show()
        AcademicDropdown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            academicYearBtn.setTitle(item, for: .normal)
            Get_standardSection_Api(academicId: AcadimicYears[index].id ?? 0)
        }
    }
    
    func Get_standardSection_Api(academicId : Int){
        
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: [COMMON_PARAMETER.academic_year_id: academicId], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (result: Result<GetStandardsSuc , Error>) in
            
            DispatchQueue.main.sync { [weak self] in
                
                guard let self = self else {return}
                
                switch result {
                case .success(let success):
                    
                    classList.removeAll()
                    let standardData =  success.data ?? []
                    
                    for standard in standardData{
                        for section in standard.sections ?? [] {
                            
                            let displayName = "\(CommonStringFile.Standard.translated()) \(standard.name ?? "") - \(CommonStringFile.Section.translated()) \(section.name ?? "")"
                            classList.append(ClassDisplayItem(displayName: displayName, standardId: standard.id ?? "", sectionId: section.id ?? ""))
                        }
                    }
                    
                    filteredClassList = classList
                    let hide = filteredClassList.isEmpty
                    noDataImage.isHidden = !hide
                    noDataLbl.isHidden = !hide
                    searchBtn.isHidden = hide
                    selectYourClassLbl.isHidden = hide
                    chooseClassLbl.isHidden = hide
                    noDataLbl.text = success.message ?? ""
                    tv.reloadData()
                    
                    
                case .failure(let failure):
                    classList.removeAll()
                    filteredClassList.removeAll()
                    noDataImage.isHidden = false
                    noDataLbl.isHidden = false
                    searchBtn.isHidden = true
                    selectYourClassLbl.isHidden = true
                    chooseClassLbl.isHidden = true
                    noDataLbl.text = failure.localizedDescription
                    tv.reloadData()
                }
            }
            
        }
    }
    
    @IBAction func searchBtnAct(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected{
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
            searchBtn.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else{
            searchBar.isHidden = true
            view.endEditing(true)
            searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            searchBar.searchTextField.text = ""
            filteredClassList = classList
            let hide = filteredClassList.isEmpty
            noDataImage.isHidden = !hide
            noDataLbl.isHidden = !hide
            selectYourClassLbl.isHidden = hide
            chooseClassLbl.isHidden = hide
            tv.reloadData()
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            // Show all data
            filteredClassList = classList
        } else {
            // Filter by displayName
            filteredClassList = classList.filter {
                $0.displayName.localizedCaseInsensitiveContains(trimmedText)
            }
        }
        let hide = filteredClassList.isEmpty
        noDataImage.isHidden = !hide
        noDataLbl.isHidden = !hide
        selectYourClassLbl.isHidden = hide
        chooseClassLbl.isHidden = hide
        noDataLbl.text = AlertstringFile.No_Data_Found.translated()
        tv.reloadData()
    }
    
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredClassList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.Exam_ClassListTV, for: indexPath) as! Exam_ClassListTV
        
        let standard = filteredClassList[indexPath.row]
        cell.classNameLbl.text = standard.displayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc  = ExamListVC()
        vc.standard = filteredClassList[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}
