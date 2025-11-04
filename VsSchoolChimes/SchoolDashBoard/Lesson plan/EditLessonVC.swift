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
    var     EditData: [LessonEditData]?
    var particular_Id : String?
    var ReqestType: String?
    var editedFields: [String: String] = [:]
    let alert = CustomAlert()
    var isCreate = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BottomView.layer.shadowColor = UIColor.black.cgColor
        BottomView.layer.shadowOpacity = 0.25
        BottomView.layer.shadowOffset = CGSize(width: 0, height: 4)
        BottomView.layer.shadowRadius = 8
        BottomView.layer.masksToBounds = false
        
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: staffDetails?.school_name ?? "")
        CancelBtn.layer.cornerRadius = 10
        UpdateBtn.layer.cornerRadius = 10
        CancelBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        UpdateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        if isCreate{
            UpdateBtn.setTitle("Create", for: .normal)
        }else{
            UpdateBtn.setTitle("Update", for: .normal)
        }
        Tableview.showsVerticalScrollIndicator = false
        Tableview.showsHorizontalScrollIndicator = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let nib = UINib(nibName: "LessonEditTV", bundle: nil)
        Tableview.register(nib, forCellReuseIdentifier: "LessonEditTV")
        Tableview.delegate = self
        Tableview.dataSource = self
    }
    
    func addTopBorderAndShadow(to view: UIView) {
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
        addTopBorderAndShadow(to: BottomView)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        Tableview.contentInset.bottom = keyboardHeight
        
        var insets = Tableview.verticalScrollIndicatorInsets
        insets.bottom = keyboardHeight
        Tableview.verticalScrollIndicatorInsets = insets
        
        // Optionally scroll to the active cell
        if let firstResponder = view.currentFirstResponder(),
           let cell = firstResponder.superview(of: UITableViewCell.self),
           let indexPath = Tableview.indexPath(for: cell) {
            Tableview.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        Tableview.contentInset = .zero
        Tableview.verticalScrollIndicatorInsets = .zero
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Lesson Edit Api call
    
    func Get_Edit_Details(){
        
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        let param: [String: Any] = [LessonPlanStringFile.particular_id: particular_Id ?? "",LessonPlanStringFile.request_type: ReqestType ?? ""]
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_lesson_plan_get_data_for_edit, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") {[ weak self] (result: Result<LessonEditResponse,Error>) in
            
            DispatchQueue.main.async {[weak self] in
                
                guard let self = self else {return}
                
                if #available(iOS 15.0, *) {
                    self.hideActivityLoader()
                }
                
                
                switch result {
                    
                case .success(let success):
                    if user_inputs.clearTempData(){
                        let parms = [ "mobile_number": UserDefaultFileManager.get_staff_Details()?.mobile_no ?? "",
                                       "activity": "EDIT_LESSONPLAN",
                                       "user_type": 1,
                                       "menu_id": 2]
                        paketApiCall(params:parms)
                    }
                    self.EditData = success.data ?? []
                    self.Tableview.reloadData()
                    
                case .failure(let error):
                    
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func LessonPlan_Update_Api(){
        
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        let converted = editedFields.map { (key, value) in
            return ["field_id": key, "value": value]
        }
        let LessonPlanid = isCreate ? LessonPlanStringFile.section_subject_id : LessonPlanStringFile.particular_id
        let type = isCreate ? ApitTypeSringFile.POST : ApitTypeSringFile.PUT
        let baseUrl = isCreate ? ServiceUrl.lms_api_lesson_plan_add : ServiceUrl.lms_api_lesson_plan_update
        let param : [String: Any] = [LessonPlanid: particular_Id ?? "",LessonPlanStringFile.key_value_data:converted]
        APIService.shared
            .makeApi(url:baseUrl, parameters: param, type: type, token: staffDetails?.access_token ?? "") {[weak self] (
                result: Result<CommonApiSuc,
                Error>
            ) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else {return}
                
                if #available(iOS 15.0, *){
                    self.hideActivityLoader()
                }
                
                switch result {
                    
                case .success(let Success):
                    if Success.status == true {
                        if user_inputs.clearTempData(){
                            let parms = [ "mobile_number": UserDefaultFileManager.get_staff_Details()?.mobile_no ?? "",
                                           "activity": "EDIT_LESSONPLAN",
                                           "user_type": 1,
                                          "menu_id": Menu_id.staffSelectedMenuId]
                            paketApiCall(params:parms)
                        }
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: Success.message ?? "", on: self, okAction: {
                            self.dismiss(animated: true)
                        })
                    }else {
                        
                        self.alert.showAlert(title: AlertstringFile.Failed, message:Success.message ?? "", on: self)
                    }
                    
                case .failure(let error):
                    
                    self.alert.showAlert(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                }
            }
        }
    }
    func paketApiCall(params:[String:Any]){
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {

                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(response.message, duration: 2.0, position: .bottom)
                    }
                case .failure(let error):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                    }
                }
            }
        }
    }
    
    @IBAction func CancelAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func UpdateAct(_ sender: Any) {
        
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.Are_you_sure_you_want_to_update_Lesson, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
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
        
        if var edit = EditData?[indexPath.row] {
            
            if let updatedValue = editedFields[edit.field_id ?? ""] {
                edit.value = updatedValue
            }
            cell.configure(with: edit)
        }
        
        cell.onEdit = { [weak self] fieldID, newValue in
            self?.editedFields[fieldID] = newValue
            print("editedFields: ", self?.editedFields ?? [:])
        }
        
        return cell
    }
    
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
}

extension UIView {
    func currentFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subview in subviews {
            if let firstResponder = subview.currentFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }
    
    func superview<T: UIView>(of type: T.Type) -> T? {
        return superview as? T ?? superview?.superview(of: T.self)
    }
}
