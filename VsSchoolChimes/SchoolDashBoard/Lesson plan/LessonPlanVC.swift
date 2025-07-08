//
//  LessonPlanVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/12/24.
//

import UIKit


class LessonPlanVC: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NodataLbl: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let cellcolour = [Colornames.lesson1,Colornames.lesson2,Colornames.lesson3]
    let colours1 = ["AttendenceColor","Clr","Color","lesson1","lesson3"]
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var ViewLessonData: [LessonPlanDetail]?
    var ReqestType = "myclass"
    var staffRole = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role
    var LessonPlanData: [LessonPlanStaffReport]?
    var SearchData: [LessonPlanStaffReport]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIupdate()
        BackBtn.applyBackButton()
        searchBar.applyRightTxt()
        searchBar.searchTextField.addDoneButton()
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: staffDetails?.school_name ?? "")
        
        if staffRole == "p3" {
            ReqestType = LessonPlanStringFile.myclass
            segmentControl.isHidden = true
        }else{
            ReqestType = LessonPlanStringFile.allclass
        }
        
        tableview.showsHorizontalScrollIndicator = false
        tableview.showsVerticalScrollIndicator = false
        
        lesson_plan_staff_report_Api()
        
        let nib1 = UINib(nibName: CellConfingName.LessonPlanTvCell, bundle: nil)
        tableview.register(nib1, forCellReuseIdentifier: CellConfingName.LessonPlanTvCell)
        let nib = UINib(nibName: CellConfingName.LessonProgressCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.LessonProgressCell)
        
        let nib2 = UINib(nibName: CellConfingName.LessonDashboardTv, bundle: nil)
        tableview.register(nib2, forCellReuseIdentifier: CellConfingName.LessonDashboardTv)
        
        let nib3 = UINib(nibName: "LessonViewTvCell", bundle: nil)
        tableview.register(nib3, forCellReuseIdentifier: "LessonViewTvCell")
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    func UIupdate(){
        
        NodataImage.isHidden = true
        NodataLbl.isHidden = true
        NodataLbl.setFont(style: .title, size: FontSize.HeaderSize)
    }
    
    //MARK: Lesson plan Api call
    func lesson_plan_staff_report_Api(){
        
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        let param: [String: Any] = [LessonPlanStringFile.request_type: ReqestType]
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_lesson_plan_staff_report, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (result: Result<LessonPlanStaffReportResponse,Error>) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else {return}
                
                if #available(iOS 15.0, *) {
                    self.hideLottieProgressLoader()
                }
                
                switch result{
                    
                case .success(let success):
                   
                    self.LessonPlanData = success.data
                    self.SearchData = LessonPlanData
                    self.NodataLbl.text = success.status ? CommonStringFile.No_data_found : success.message
                    let Hidden = SearchData?.isEmpty ?? false
                    self.NodataImage.isHidden = !Hidden
                    self.NodataLbl.isHidden = !Hidden
                    self.searchBar.isHidden = Hidden
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
    
    
    @IBAction func SegmentAct(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0{
            ReqestType = LessonPlanStringFile.allclass
        }else {
            ReqestType = LessonPlanStringFile.myclass
        }
        
        lesson_plan_staff_report_Api()
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
        
        cell.SubjectLbl.text = Lesson?.subject_name
        cell.StandardLbl.text = (Lesson?.class_name ?? "") + " - " + (Lesson?.section_name ?? "")
        cell.StaffNameLbl.text = Lesson?.staff_name
        cell.CompletedItemsLbl.text = "Items completed : \(Lesson?.items_completed ?? "")"
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
        
        if lesson.total_items != "0"{
            let vc = ViewLessonVC(nibName: nil, bundle: nil)
            vc.Reqest_Type = ReqestType
            vc.SubjectId = lesson.section_subject_id
            vc.IsDeleteHiden = ReqestType == "myclass" ? false : true
            vc.modalPresentationStyle = .fullScreen
            
            present(vc, animated: true)
        }
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
