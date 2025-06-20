//
//  ViewLessonVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 18/06/25.
//

import UIKit

@available(iOS 14.0, *)
class ViewLessonVC: UIViewController {


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
    var Filters = ["All","yet to Start","In Progress","Completed"]
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    var LessonPlanStatus = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BAckBtn.configureAsBackButton(firstLine: MenuStringFile.LessonPlan, secondLine: staffDetails?.school_name ?? "")
        
        SearchBar.isHidden = true
        TableView.showsVerticalScrollIndicator = false
        TableView.showsHorizontalScrollIndicator = false
        
        let nib = UINib(nibName: CellConfingName.LessonViewTvCell, bundle: nil)
        TableView.register(nib, forCellReuseIdentifier: CellConfingName.LessonViewTvCell)
        
        TableView.delegate = self
        TableView.dataSource = self
        
        let cvnib = UINib(nibName:CellConfingName.FiltersCvCell , bundle: nil)
        FilterCV.register(cvnib, forCellWithReuseIdentifier: CellConfingName.FiltersCvCell)
        
        FilterCV.delegate = self
        FilterCV.dataSource = self
        
        View_Lesson_Plan_Api(status: LessonPlanStatus)
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    func View_Lesson_Plan_Api(status: Int){
        
        let param: [String: Any] = [LessonPlanStringFile.section_subject_id : SubjectId ?? "",LessonPlanStringFile.lesson_plan_status: status]
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_lesson_plan_view, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [self] (result: Result<LessonPlanDetailResponse,Error>) in
            
            switch result {
            case .success(let success):
                
                DispatchQueue.main.async { [self] in
                    
                    ViewLessonData = success.data
                    NoDataImg.isHidden = !(ViewLessonData?.isEmpty ?? false)
                    NoDataLbl.isHidden = !(ViewLessonData?.isEmpty ?? false)
                   // SearchBar.isHidden = (ViewLessonData?.isEmpty ?? false)
                    FilterCV.isHidden = (ViewLessonData?.isEmpty ?? false)
                    NoDataLbl.text = success.message
                    TableView.reloadData()
                }
                
            case .failure(let failure):
                
                DispatchQueue.main.async {[self] in
                    SearchBar.isHidden = true
                    NoDataImg.isHidden = false
                    NoDataLbl.isHidden = false
                    NoDataLbl.text = failure.localizedDescription
                    
                    print("Error: ",failure.localizedDescription)
                }
            }
        }
    }
    
    func Delete_LessonPlan_Api(particularID: String){
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_lesson_plan_delete, parameters: [LessonPlanStringFile.particular_id: particularID], type: ApitTypeSringFile.Put, token: staffDetails?.access_token ?? "") {[self] (result: Result<CommonApiSuc,Error>) in
            
            switch result{
                
            case .success(let success):
                
                DispatchQueue.main.async {
                    
                    let title = success.status == true ? AlertstringFile.Success : AlertstringFile.Failed
                    CustomAlert().showAlert(title: title, message: success.message ?? "", on: self)
                }
            case .failure(let error):
                CustomAlert().showAlert(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
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
        
        return ViewLessonData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TableView.dequeueReusableCell(withIdentifier: CellConfingName.LessonViewTvCell, for: indexPath) as! LessonViewTvCell
        
        let lesson = ViewLessonData?[indexPath.row]
        let colour: UIColor
        switch lesson?.lesson_plan_status{
            
        case 1:
            colour = .systemOrange
            cell.StatusLbl.text = "Yet to Start"
            
        case 2:
            colour = .systemBlue
            cell.StatusLbl.text = "Inprogress"
            
        case 3:
            colour = .systemGreen
            cell.StatusLbl.text = "Completed"
        default:
            colour = .systemOrange
        }
        
        cell.EditBtn.tag = indexPath.row
        cell.EditBtn.addTarget(self, action: #selector(EditBtnAct(_:)), for: .touchUpInside)
        
        cell.DeleteBtn.tag = indexPath.row
        cell.DeleteBtn.addTarget(self, action: #selector(DeleteBtnAct(_:)), for: .touchUpInside)
        
        cell.ProgressView2.backgroundColor = colour.withAlphaComponent(0.1)
        cell.ProgressView2.layer.borderColor = colour.cgColor
        cell.StatusLbl.textColor = colour
        
        let details = ViewLessonData?[indexPath.row].details ?? []

        cell.configure(with: details)
        
        return cell
    }
    
    @objc func EditBtnAct(_ sender: UIButton) {
        
        let particularId = ViewLessonData?[sender.tag].particular_id
        
        let vc = EditLessonVC(nibName: nil, bundle: nil)
        vc.particular_Id = particularId
        vc.ReqestType  = Reqest_Type
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc func DeleteBtnAct(_ sender: UIButton) {
        
        let particularId = ViewLessonData?[sender.tag].particular_id ?? ""
        
        CustomAlert().showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.Are_you_sure_you_want_to_Delete_Lesson, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
            
            self.Delete_LessonPlan_Api(particularID: particularId)
        }, onNo: {
            
        })
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
        
        cell.CheckboxImg.image = indexPath == selectedIndex ? UIImage(named: "RadioCheck") : UIImage(named: "CheckCircle")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        
        let type = Filters[selectedIndex.item]
        
        View_Lesson_Plan_Api(status: selectedIndex.item)
        FilterCV.reloadData()
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
