//
//  LessonPlanVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/12/24.
//

import UIKit


@available(iOS 15.0, *)
class LessonPlanVC: UIViewController {
    
    @IBOutlet weak var MenuNameLbl: UILabel!
    @IBOutlet weak var searchIconBtn: UIButton!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NodataLbl: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var ButtonStack: UIStackView!
    @IBOutlet weak var AllClassBtn: UIButton!
    @IBOutlet weak var MyClassBtn: UIButton!
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var ViewLessonData: [LessonPlanDetail]?
    var ReqestType = "myclass"
    var staffRole = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role
    var LessonPlanData: [LessonPlanStaffReport]?
    var SearchData: [LessonPlanStaffReport]?
    var isAllClassSelected: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIupdate()
        BackBtn.applyBackButton()
        searchBar.applyRightTxt()
        searchBar.searchTextField.addDoneButton()
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.searchTextField.backgroundColor = .systemGray5
        searchBar.layer.cornerRadius = 8
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.delegate = self
        
        let menuName = MenuStringFile.LessonPlan.translated()
        MenuNameLbl.configureAsBackTitle(firstLine: menuName.translated(), secondLine: staffDetails?.school_name?.translated() ?? "")
        searchBar.isHidden = true
        MyClassBtn.setTitle(LessonplanStringFile.myClasses.translated(), for: .normal)
        AllClassBtn.setTitle(LessonplanStringFile.allClasses.translated(), for: .normal)
        MyClassBtn.setTitleFont(style: .body, size: FontSize.HeaderSize)
        AllClassBtn.setTitleFont(style: .body, size: FontSize.HeaderSize)
        
        addUnderline(to: AllClassBtn, unselectedButton: MyClassBtn)
        
        if staffRole == "p3" {
            ReqestType = LessonPlanStringFile.myclass
            segmentControl.isHidden = true
            ButtonStack.isHidden = true
            
        }else{
            ReqestType = LessonPlanStringFile.allclass
        }
        
        tableview.showsHorizontalScrollIndicator = false
        tableview.showsVerticalScrollIndicator = false
        
        lesson_plan_staff_report_Api()
        
        let nib2 = UINib(nibName: CellConfingName.LessonDashboardTv, bundle: nil)
        tableview.register(nib2, forCellReuseIdentifier: CellConfingName.LessonDashboardTv)
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    func UIupdate(){
        NodataImage.isHidden = true
        NodataLbl.isHidden = true
        NodataLbl.setFont(style: .title, size: FontSize.HeaderSize)
    }
    
    //MARK: Lesson plan Api call
    func lesson_plan_staff_report_Api(){
        showActivityLoader()
        let param: [String: Any] = [LessonPlanStringFile.request_type: ReqestType]
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_lesson_plan_staff_report, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (result: Result<LessonPlanStaffReportResponse,Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.hideActivityLoader()
                switch result{
                case .success(let success):
                    self.LessonPlanData = success.data
                    self.SearchData = LessonPlanData
                    self.NodataLbl.text = success.status ? CommonStringFile.No_data_found.translated() : success.message.translated()
                    let Hidden = SearchData?.isEmpty ?? false
                    self.NodataImage.isHidden = !Hidden
                    self.NodataLbl.isHidden = !Hidden
                    self.tableview.reloadData()
                    
                case .failure(let error):
                    self.NodataImage.isHidden = false
                    self.NodataLbl.isHidden = false
                    self.NodataLbl.text = error.localizedDescription
                    
                    print("Error: ",error.localizedDescription)
                }
            }
        }
    }
    
    func addUnderline(to selectedButton: UIButton, unselectedButton: UIButton) {
        // Remove underline from both buttons
        [selectedButton, unselectedButton].forEach { button in
            button.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
            button.tintColor = .black
        }
        // Add underline to the selected button
        selectedButton.tintColor = .backGroundClr
        let underline = UIView()
        underline.tag = 999
        underline.backgroundColor = .backGroundClr
        underline.translatesAutoresizingMaskIntoConstraints = false
        selectedButton.addSubview(underline)
        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: selectedButton.bottomAnchor)
        ])
    }
    
    @IBAction func SegmentAct(_ sender: Any) {
        if segmentControl.selectedSegmentIndex == 0{
            ReqestType = LessonPlanStringFile.allclass
        }else {
            ReqestType = LessonPlanStringFile.myclass
        }
        lesson_plan_staff_report_Api()
    }
    
    @IBAction func AllClassAct(_ sender: Any) {
        addUnderline(to: AllClassBtn, unselectedButton: MyClassBtn)
        ReqestType = LessonPlanStringFile.allclass
        searchBar.text = ""
        searchBar.isHidden = true
        searchIconBtn.setImage(ImageName.magnifyingglass, for: .normal)
        searchBar.resignFirstResponder()
        lesson_plan_staff_report_Api()
    }
    
    @IBAction func MyClassAct(_ sender: Any) {
        addUnderline(to: MyClassBtn, unselectedButton: AllClassBtn)
        ReqestType = LessonPlanStringFile.myclass
        searchBar.text = ""
        searchBar.isHidden = true
        searchIconBtn.setImage(ImageName.magnifyingglass, for: .normal)
        searchBar.resignFirstResponder()
        lesson_plan_staff_report_Api()
    }
    
    @IBAction func SearchButtonAct(_ sender: UIButton) {
        searchBar.becomeFirstResponder()
        sender.isSelected.toggle()
        if sender.isSelected{
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
            sender.setImage(ImageName.magnifyingglass_circle_fill, for: .normal)
        }else{
            searchBar.isHidden = true
            NodataImage.isHidden = true
            NodataLbl.isHidden = true
            searchBar.resignFirstResponder()
            sender.setImage(ImageName.magnifyingglass, for: .normal)
            searchBar.searchTextField.text = ""
            SearchData = LessonPlanData
            tableview.reloadData()
        }
    }
    @IBAction func BackBtnAct(_ sender: Any) {
        dismiss(animated: true)
    }
}


@available(iOS 15.0, *)
extension LessonPlanVC : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LessonDashboardTv, for: indexPath) as! LessonDashboardTv
        
        let Lesson =  SearchData?[indexPath.row]
        cell.Cellview.backgroundColor = UIColor(hex: "#F2F8FD")
        cell.SideColourView.backgroundColor = UIColor(hex: "#F2F8FD")
        cell.SubjectLbl.text = Lesson?.subject_name
        cell.StandardLbl.text = (Lesson?.class_name ?? "") + " - " + (Lesson?.section_name ?? "")
        cell.StaffNameLbl.text = Lesson?.staff_name
        cell.CompletedItemsLbl.text = "\(LessonplanStringFile.itemsCompleted.translated()) : \(Lesson?.items_completed ?? "")"
        cell.ArrowImage.isHidden = Lesson?.total_items == "0"
        let percentage = Double(Lesson?.percentage_value ?? 0)
        cell.setProgress(to: percentage)
        cell.isAnimate = false
        cell.ViewBtn.tag = indexPath.row
        cell.ViewBtn.addTarget(self, action: #selector(ViewbtnAct(_:)), for: .touchUpInside)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let lesson = SearchData?[indexPath.row] else { return }
        let vc = ViewLessonVC(nibName: nil, bundle: nil)
        vc.Reqest_Type = ReqestType
        vc.LesonPlanReport = lesson
        vc.SubjectId = lesson.section_subject_id
        vc.IsDeleteHiden = ReqestType == "myclass" ? false : true
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc func ViewbtnAct(_ sender: UIButton) {
        let index = sender.tag
        guard let lesson = SearchData?[index] else { return }
        let vc = ViewLessonVC(nibName: nil, bundle: nil)
        vc.Reqest_Type = ReqestType
        vc.SubjectId = lesson.section_subject_id
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

@available(iOS 15.0, *)
extension LessonPlanVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty{
            SearchData = LessonPlanData
        }else {
            let search = searchText.lowercased()
            SearchData = LessonPlanData?.filter{ Lesson in
                let combined = "\(Lesson.class_name) - \(Lesson.section_name)".lowercased()
                
                return combined.contains(search) ||
                (Lesson.class_name.lowercased().contains(search)) ||
                (Lesson.section_name.lowercased().contains(search)) ||
                (Lesson.staff_name.lowercased().contains(search)) ||
                (Lesson.subject_name.lowercased().contains(search))
            }
        }
        
        NodataLbl.text = "No Data Found!"
        NodataImage.isHidden = !(SearchData?.isEmpty ?? false)
        NodataLbl.isHidden = !(SearchData?.isEmpty ?? false)
        tableview.reloadData()
    }
}
