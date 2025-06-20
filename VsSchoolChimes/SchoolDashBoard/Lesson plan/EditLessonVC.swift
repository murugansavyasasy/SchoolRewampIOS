//
//  EditLessonVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 18/06/25.
//

import UIKit

@available(iOS 14.0, *)
class EditLessonVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var CancelBtn: UIButton!
    @IBOutlet weak var UpdateBtn: UIButton!
    @IBOutlet weak var BottomView: UIView!
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var EditData: [LessonEditData]?
    var particular_Id : String?
    var ReqestType: String?
    var editedFields: [String: String] = [:]
    let alert = CustomAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BottomView.layer.shadowColor = UIColor.black.cgColor
        BottomView.layer.shadowOpacity = 0.25
        BottomView.layer.shadowOffset = CGSize(width: 0, height: 4)
        BottomView.layer.shadowRadius = 8
        BottomView.layer.masksToBounds = false
        
        BackBtn.configureAsBackButton(firstLine: "Edit Lesson Plan", secondLine: staffDetails?.school_name ?? "")
        CancelBtn.layer.cornerRadius = 10
        UpdateBtn.layer.cornerRadius = 10
        CancelBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        UpdateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        Tableview.showsVerticalScrollIndicator = false
        Tableview.showsHorizontalScrollIndicator = false
        
        let nib = UINib(nibName: "LessonEditTV", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: "LessonEditTV")
        
        Tableview.delegate = self
        Tableview.dataSource = self
        Get_Edit_Details()
    }

    func addTopBorderAndShadow(to view: UIView) {
        // 1. Add Top Border
//        let border = CALayer()
//        border.backgroundColor = UIColor.lightGray.cgColor
//        border.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0.3) // 1pt height
//        view.layer.addSublayer(border)

        // 2. Add Top Shadow
        let shadowPath = UIBezierPath()
        shadowPath.move(to: CGPoint(x: 0, y: 0))
        shadowPath.addLine(to: CGPoint(x: view.bounds.width, y: 0))
        shadowPath.addLine(to: CGPoint(x: view.bounds.width, y: -2))
        shadowPath.addLine(to: CGPoint(x: 0, y: -2))
        shadowPath.close()

        view.layer.shadowPath = shadowPath.cgPath
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 2
    }

    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
        
        addTopBorderAndShadow(to: BottomView)
    }
    
    //MARK: Lesson Edit Api call
    
    func Get_Edit_Details(){

        let param: [String: Any] = [LessonPlanStringFile.particular_id: particular_Id ?? "",LessonPlanStringFile.request_type: ReqestType ?? ""]
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_lesson_plan_get_data_for_edit, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") {[self] (result: Result<LessonEditResponse,Error>) in
            
            switch result {
                
            case .success(let success):
                
                DispatchQueue.main.async { [self] in
                    
                    EditData = success.data ?? []
                    Tableview.reloadData()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    
    func LessonPlan_Update_Api(){
        
        let converted = editedFields.map { (key, value) in
            return ["field_id": key, "value": value]
        }
        
        print("converted",converted)
        
        let param : [String: Any] = [LessonPlanStringFile.particular_id: particular_Id ?? "",LessonPlanStringFile.key_value_data:converted]
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_lesson_plan_update, parameters: param, type: ApitTypeSringFile.Put, token: staffDetails?.access_token ?? "") {[self] (result: Result<CommonApiSuc,Error>) in
            
            switch result {
                
            case .success(let Success):
                
                DispatchQueue.main.async { [self] in
                    
                    alert.showAlert(title: "", message: Success.message ?? "", on: self)
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async { [self] in
                    
                    alert.showAlert(title: "", message: error.localizedDescription, on: self)
                }
            }
        }
    }
    
    
    @IBAction func CancelAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func UpdateAct(_ sender: Any) {
        
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.Are_you_sure_you_want_to_Edit_Lesson, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
            
            self.LessonPlan_Update_Api()
            
        }, onNo: {
            
        })
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return EditData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Tableview.dequeueReusableCell(withIdentifier: "LessonEditTV", for: indexPath) as! LessonEditTV
        
        cell.tableView = self.Tableview
        
        if let edit = EditData?[indexPath.row] {
            cell.configure(with: edit)
        }
        
        cell.onEdit = { [weak self] fieldID, newValue in
            self?.editedFields[fieldID] = newValue
            print("editedFields: ", self?.editedFields ?? [:]) // ✅ Move print here
        }

          return cell
    }
    

    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
}
