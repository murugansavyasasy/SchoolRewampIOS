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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let vc = EditLessonVC(nibName: nil, bundle: nil)
                vc.particular_Id = id
                vc.ReqestType  = self.Reqest_Type
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                CustomAlert().showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.Are_you_sure_you_want_to_Delete_Lesson, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
                    
                    self.Delete_LessonPlan_Api(particularID: id ?? "")
                }, onNo: {
                    
                })
            }
        }
    }
    @IBOutlet weak var BAckBtn: UIButton!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var NoDataImg: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var FilterCV: UICollectionView!
    
    var SubjectId : String?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var ViewLessonData: [LessonPlanDetail]?
    var FilteredData: [LessonPlanDetail]?
    var Reqest_Type: String?
    var Filters = [CommonStringFile.all,LessonplanStringFile.yetToStart,LessonplanStringFile.inProgress,CommonStringFile.completed]
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    var LessonPlanStatus = 0
    var IsDeleteHiden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BAckBtn
            .configureAsBackButton(
                firstLine: MenuStringFile.LessonPlan,
                secondLine: staffDetails?.school_name ?? ""
            )
        
        NoDataImg.isHidden = true
        NoDataLbl.isHidden = true
        NoDataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        
        SearchBar.isHidden = true
        TableView.showsVerticalScrollIndicator = false
        TableView.showsHorizontalScrollIndicator = false
        
//        let nib = UINib(nibName: CellConfingName.LessonViewTvCell, bundle: nil)
        let nib = UINib(nibName: "LessonPlanTVC", bundle: nil)
//        TableView.register(nib, forCellReuseIdentifier: CellConfingName.LessonViewTvCell)
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
                        self.LessonFilter(Status: LessonPlanStatus)
                        self.NoDataLbl.text = CommonStringFile.No_data_found
                    }else {
                        self.ViewLessonData = []
                        self.FilterCV.isHidden = true
                        self.NoDataLbl.text = success.message
                        self.NoDataImg.isHidden = false
                        self.NoDataLbl.isHidden = false
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
    
}

@available(iOS 14.0, *)
extension ViewLessonVC: UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FilteredData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TableView.dequeueReusableCell(withIdentifier: "LessonPlanTVC", for: indexPath) as! LessonPlanTVC
        
        let lesson = FilteredData?[indexPath.row]
//        let colour: UIColor
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
        
        cell.cellView.backgroundColor = indexPath == selectedIndex ? UIColor.blue.withAlphaComponent(0.6) : .systemGray5
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
        }else{
            FilteredData = ViewLessonData?.filter{$0.lesson_plan_status == Status}
        }
        
        NoDataImg.isHidden = !(FilteredData?.isEmpty ?? false)
        NoDataLbl.isHidden = !(FilteredData?.isEmpty ?? false)
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
