//
//  ViewLessonVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 18/06/25.
//

import UIKit

@available(iOS 14.0, *)
class ViewLessonVC: UIViewController, SelectedId {
    func selectId(id: String?, edit: Bool?) {
        if edit ?? false{
            Get_Edit_Details(id: id ?? "", reqestType: self.Reqest_Type ?? "")
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                CustomAlert().showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.Are_you_sure_you_want_to_Delete_Lesson, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
                    
                    self.Delete_LessonPlan_Api(particularID: id ?? "")
                }, onNo: {
                    
                })
            }
        }
    }

    @IBOutlet weak var creteBtn: UIButton!
    @IBOutlet weak var BAckBtn: UIButton!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var NoDataImg: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var FilterCV: UICollectionView!
    @IBOutlet weak var menuNameLbl: UILabel!
    
    @IBOutlet weak var searchBtnName: UIButton!
    
    var SubjectId : String?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var ViewLessonData: [LessonPlanDetail]?
    var FilteredData: [LessonPlanDetail]?
    var searchData: [LessonPlanDetail]?
    var Reqest_Type: String?
    var Filters = [CommonStringFile.all,LessonplanStringFile.yetToStart,LessonplanStringFile.inProgress,CommonStringFile.completed]
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    var LessonPlanStatus = 0
    var IsDeleteHiden = false
    var LesonPlanReport : LessonPlanStaffReport?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuNameLbl.configureAsBackTitle(
                firstLine: MenuStringFile.LessonPlan,
                secondLine: staffDetails?.school_name ?? ""
            )
        creteBtn.setShadow(cornerRadius: creteBtn.frame.width/2)
        creteBtn.isHidden = IsDeleteHiden
        NoDataImg.isHidden = true
        NoDataLbl.isHidden = true
        NoDataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        
        SearchBar.isHidden = true
        SearchBar.searchTextField.addDoneButton()
        SearchBar.placeholder = CommonStringFile.Search.translated()
        SearchBar.searchTextField.backgroundColor = .systemGray5
        SearchBar.layer.cornerRadius = 8
        SearchBar.searchTextField.layer.masksToBounds = true
        SearchBar.delegate = self
        SearchBar.applyRightTxt()
        SearchBar.searchTextField.addDoneButton()
        TableView.showsVerticalScrollIndicator = false
        TableView.showsHorizontalScrollIndicator = false
        let nib = UINib(nibName: "LessonPlanTVC", bundle: nil)
        TableView.register(nib, forCellReuseIdentifier: "LessonPlanTVC")
        
        TableView.delegate = self
        TableView.dataSource = self
        
        let cvnib = UINib(nibName:CellConfingName.FiltersCvCell , bundle: nil)
        FilterCV.register(cvnib, forCellWithReuseIdentifier: CellConfingName.FiltersCvCell)
        
        FilterCV.delegate = self
        FilterCV.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        View_Lesson_Plan_Api()
    }
    
    
    @IBAction func searchBtnAct(_ sender: UIButton) {
        
        SearchBar.becomeFirstResponder()
        sender.isSelected.toggle()
        
        if sender.isSelected{
            SearchBar.isHidden = false
            SearchBar.becomeFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else{
            
            SearchBar.isHidden = true
            NoDataImg.isHidden = true
            NoDataLbl.isHidden = true
            SearchBar.resignFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            SearchBar.searchTextField.text = ""
            FilteredData = searchData
            TableView.reloadData()
        }
        
    }
    
    //MARK: Api Call Functions
    
    func View_Lesson_Plan_Api(){
        
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        let param: [String: Any] = [LessonPlanStringFile.section_subject_id : SubjectId ?? "",LessonPlanStringFile.lesson_plan_status: 0]
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_lesson_plan_view, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (result: Result<LessonPlanDetailResponse,Error>) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else{return}
                
                if #available(iOS 15.0, *) {
                    self.hideActivityLoader()
                }
                
                switch result {
                case .success(let success):
                    
                    
                    if success.status == true{
                        self.ViewLessonData = success.data
                        FilteredData = ViewLessonData
                        searchData = ViewLessonData
                    }else {
                        self.ViewLessonData = []
                        self.FilterCV.isHidden = true
                        self.NoDataLbl.text = success.message
                        self.NoDataImg.isHidden = false
                        self.NoDataLbl.isHidden = false
                        self.searchBtnName.isHidden = !success.status
                    }
                    TableView.reloadData()
                    
                    
                case .failure(let failure):
                    
                    self.SearchBar.isHidden = true
                    self.NoDataImg.isHidden = false
                    self.NoDataLbl.isHidden = false
                    self.NoDataLbl.text = failure.localizedDescription
                    
                    print("Error: ",failure.localizedDescription)
                }
            }
        }
    }
    func Get_Edit_Details(id:String,reqestType:String) {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        let param: [String: Any] = [
            LessonPlanStringFile.particular_id: id,
            LessonPlanStringFile.request_type: reqestType
        ]
        
        APIService.shared.makeApi(
            url: ServiceUrl.lms_api_lesson_plan_get_data_for_edit,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<LessonEditResponse, Error>) in
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if #available(iOS 15.0, *) {
                    self.hideActivityLoader()
                }
                
                switch result {
                case .success(let success):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let vc = EditLessonVC(nibName: nil, bundle: nil)
                        vc.EditData = success.data ?? []
                        vc.particular_Id = id
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                    
                case .failure(let error):
                    print("API Error:", error.localizedDescription)
                }
            }
        }
    }
    func Delete_LessonPlan_Api(particularID: String){
        
        APIService.shared
            .makeApi(url: ServiceUrl.lms_api_lesson_plan_delete, parameters: [LessonPlanStringFile.particular_id: particularID], type: ApitTypeSringFile.PUT, token: staffDetails?.access_token ?? "") {[weak self] (
                result: Result<CommonApiSuc,
                Error>
            ) in
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else{return}
                switch result{
                    
                case .success(let success):
                    
                    let title = success.status == true ? AlertstringFile.Success : AlertstringFile.Failed
                    
                    if success.status == true {
                        CustomAlert.showAlertWithOkAction(title: title, message: success.message ?? "", on: self, okAction: {
                            self.ViewLessonData?.removeAll{$0.particular_id == particularID}
                            self.FilteredData?.removeAll{$0.particular_id == particularID}
                            self.searchData?.removeAll{$0.particular_id == particularID}
                            self.TableView.reloadData()
                        })
                    }else {
                        CustomAlert().showAlert(title: title, message: success.message ?? "", on: self)
                    }
                    
                case .failure(let error):
                    CustomAlert().showAlert(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                }
            }
        }
    }
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    @IBAction func createLessonPlan(_ sender: UIButton) {
        let param: [String: Any] = [
            LessonPlanStringFile.request_type: Reqest_Type ?? ""]
        
        APIService.shared.makeApi(
            url: ServiceUrl.lms_api_lesson_plan_get_data_for_add,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<LessonEditResponse, Error>) in
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let success):
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let vc = EditLessonVC(nibName: nil, bundle: nil)
                        vc.EditData = success.data ?? []
                        vc.particular_Id = self.SubjectId ?? ""
                        vc.isCreate = true
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                    
                case .failure(let error):
                    print("API Error:", error.localizedDescription)
                }
            }
        }
    }
}

@available(iOS 14.0, *)
extension ViewLessonVC: UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FilteredData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TableView.dequeueReusableCell(withIdentifier: "LessonPlanTVC", for: indexPath) as! LessonPlanTVC
        
        let lesson = FilteredData?[indexPath.row]
        cell.titleNameLbl.text = LesonPlanReport?.subject_name
        cell.chapterLbl.text = "Chapters Completed " + (
            LesonPlanReport?.items_completed ?? ""
        )
        switch lesson?.lesson_plan_status{
            
        case 1:
            cell.statusBtn.setImage(UIImage.pending, for: .normal)
            cell.statusBtn.tintColor = .systemOrange
            
        case 2:
            cell.statusBtn.setImage(UIImage(systemName: "arrow.2.circlepath.circle.fill"), for: .normal)
            cell.statusBtn.tintColor = .systemBlue
            
        case 3:
            cell.statusBtn.setImage(UIImage(systemName: "checkmark.arrow.trianglehead.counterclockwise"), for: .normal)
            cell.statusBtn.tintColor = .systemGreen
        default:
            cell.statusBtn.setImage(UIImage.pending, for: .normal)
            cell.statusBtn.tintColor = .systemOrange
        }
        cell.levelBtn.setTitle("\(indexPath.row+1)", for: .normal)
        cell.EditBtn.tag = indexPath.row
        cell.EditBtn1.tag = indexPath.row
        let details = FilteredData?[indexPath.row].details ?? []
        cell.edit(edit:true, delete:  IsDeleteHiden, selectedId: FilteredData?[indexPath.row].particular_id  ?? "")
        cell.delegate = self
        cell.configure(with: details)
        
        return cell
    }
}

@available(iOS 14.0, *)
extension ViewLessonVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return Filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = FilterCV.dequeueReusableCell(withReuseIdentifier: CellConfingName.FiltersCvCell, for: indexPath) as! FiltersCvCell
        
        cell.FilterLbl.text = Filters[indexPath.item]
        
        cell.cellView.backgroundColor = indexPath == selectedIndex ? UIColor.primery
            .withAlphaComponent(0.8) : .systemGray5
        cell.FilterLbl.textColor = indexPath == selectedIndex ? UIColor.white : .black
        cell.CheckboxImg.isHidden = false
        
        switch Filters[indexPath.item]{
        case LessonplanStringFile.yetToStart:
            cell.CheckboxImg.image = UIImage.pending
            cell.CheckboxImg.tintColor = indexPath == selectedIndex ? UIColor.white : .systemOrange
        case LessonplanStringFile.inProgress:
            cell.CheckboxImg.image = UIImage(systemName: "arrow.2.circlepath.circle.fill")
            cell.CheckboxImg.tintColor = indexPath == selectedIndex ? UIColor.white : .systemBlue
        case CommonStringFile.completed:
            cell.CheckboxImg.image = UIImage(systemName: "checkmark.arrow.trianglehead.counterclockwise")
            cell.CheckboxImg.tintColor = indexPath == selectedIndex ? UIColor.white : .systemGreen
        default:
            cell.CheckboxImg.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        LessonPlanStatus = indexPath.item
        LessonFilter(Status: LessonPlanStatus)
        
        FilterCV.reloadData()
        TableView.reloadData()
    }
    
    func LessonFilter(Status:Int){
        if Status == 0{
            FilteredData = ViewLessonData
            searchData = FilteredData
        }else{
            FilteredData = ViewLessonData?.filter{$0.lesson_plan_status == Status}
            searchData = ViewLessonData?.filter{$0.lesson_plan_status == Status}
        }
        searchBtnName.isHidden = (FilteredData?.isEmpty ?? true)
        SearchBar.isHidden = (FilteredData?.isEmpty ?? true)
        SearchBar.searchTextField.text = ""
        NoDataImg.isHidden = !(FilteredData?.isEmpty ?? true)
        NoDataLbl.isHidden = !(FilteredData?.isEmpty ?? true)
        NoDataLbl.text = (FilteredData?.isEmpty ?? true) ? "No LessonPlan Found" : ""
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let text = Filters[indexPath.item] // Assuming your label text is from a data source
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16) // Use the same font as in Storyboard
        label.text = text
        label.sizeToFit()
        
        let width = label.frame.width + 60  // Add padding
        return CGSize(width: width, height: 40) // Adjust height accordingly
    }
    
}
@available(iOS 14.0, *)
extension ViewLessonVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchLesson(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchLesson(_ searchText: String) {
        guard let allData = searchData else { return }
        var baseFiltered: [LessonPlanDetail]
        if LessonPlanStatus == 0 {
            baseFiltered = allData
        } else {
            baseFiltered = allData.filter { $0.lesson_plan_status == LessonPlanStatus }
        }

        // Now apply search filter
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // No search text → show normal filtered data
            FilteredData = baseFiltered
        } else {
            let lowerText = searchText.lowercased()
            FilteredData = baseFiltered.filter { lesson in
                // Search inside each detail item (name or value)
                return lesson.details.contains { item in
                    (item.name?.lowercased().contains(lowerText) ?? false) ||
                    (item.value?.lowercased().contains(lowerText) ?? false)
                }
            }
        }

        // Handle empty state
        NoDataImg.isHidden = !(FilteredData?.isEmpty ?? false)
        NoDataLbl.isHidden = !(FilteredData?.isEmpty ?? false)
        NoDataLbl.text = (FilteredData?.isEmpty ?? false) ? "No LessonPlan Found" : ""

        TableView.reloadData()
    }

}
