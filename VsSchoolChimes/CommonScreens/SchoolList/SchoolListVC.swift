//
//  SchoolListVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 22/03/25.
//

import UIKit

class SchoolListVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var sendBtnName: UIButton!
    @IBOutlet weak var segmentName: UISegmentedControl!
    @IBOutlet weak var listTable: UITableView!
   
    var screen_type : Int?
    var isEmergency : Int?
    var isNoticeBoard : Int?
    
    var school_details = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    let alert = CustomAlert()
    var communicatio_textDetails :[String] = []
    var array_selectedSchoolId :[String] = []
    var target_type:Int?
    var requestCommonDataDetails : [String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        target_type = TargetTypes.school
        
        if (isEmergency == 1 || isNoticeBoard == 1){
            segmentName.isHidden = true
            segmentName.selectedSegmentIndex = 0
            sendBtnName.isHidden = false
        }
        for i in 0..<(school_details?.count ?? 0) {
            school_details?[i].isSelected = true
            if let school_id = school_details?[i].school_id{
                array_selectedSchoolId
                    .append(school_id)
            }
        }
        
        listTable.register(UINib(nibName:CellConfingName.SchoolListTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.SchoolListTVC)
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [ Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    @IBAction func segment_action(_ sender: Any) {
       
        if segmentName.selectedSegmentIndex == 0 {
            sendBtnName.isHidden = false
            listTable.reloadData()
        }else{
            sendBtnName.isHidden = true
            listTable.reloadData()
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return school_details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: CellConfingName.SchoolListTVC, for: indexPath) as! SchoolListTVC
        let schools_details  = school_details?[indexPath.row]
        cell.name.text = schools_details?.school_name
        cell.address.text = schools_details?.school_address
        cell.schoolRelignLangLbl.text = schools_details?.school_name_regional
        
        if segmentName.selectedSegmentIndex == 0{
            let img = schools_details?.isSelected ?? false ? UIImage(named: "checkedSquare") : UIImage(
                named: "uncheckedSquare")
            cell.selectedBtn.setImage(img, for: .normal)
        }else{
            
            cell.selectedBtn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
       
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        if segmentName.selectedSegmentIndex == 0{

            school_details?[indexPath.row].isSelected?.toggle()
            if let id = school_details?[indexPath.row].school_id {
                if school_details?[indexPath.row].isSelected == true {
                    if !array_selectedSchoolId.contains(id) {
                        array_selectedSchoolId.append(id)
                    }
                } else {
                    array_selectedSchoolId.removeAll(where: { $0 == id })
                }
            }
            listTable.reloadData()
            
        }else{
            if let data = school_details?[indexPath.row]{
                UserDefaultFileManager.saveStaffDetails(data: data)}
            let vc = RecipientVc(nibName: nil, bundle: nil)
            vc.communicatio_textDetails = communicatio_textDetails
            vc.ScreenType = screen_type
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    @IBAction func selectedSchool(_ sender: Any) {
        
        print("array_selectedSchoolId",array_selectedSchoolId)
        if array_selectedSchoolId.count != 0 {
            
            if screenType.communication_text == screen_type{
                
                alert
                    .showAlertCancel(
                        title: AlertstringFile.Alert_title,
                        message: AlertstringFile.AreYouSureYouWantToProceed + String(
                            array_selectedSchoolId.count) ,
                        actionLbl1: AlertstringFile.OK,
                        actionLbl2: AlertstringFile.Cancel,
                        on: self,
                        onOk: { [self] in
                            
                            sendtextmessage_communication()
                        } ,
                        onNo: {print("Canceled")})
            }else if screenType.is_emergencyvoice == screen_type{
                let today = getCurrentDateString()
               
                alert
                    .showAlertCancel(
                        title: AlertstringFile.Alert_title,
                        message: AlertstringFile.AreYouSureYouWantToProceed + String(
                            array_selectedSchoolId.count) ,
                        actionLbl1: AlertstringFile.OK,
                        actionLbl2: AlertstringFile.Cancel,
                        on: self,
                        onOk: { [self] in
                            
                            sendVoiceMessage_communication()
                        } ,
                        onNo: {print("Canceled")})
            }
            
        }else{
            
            alert
                .showAlert(
                    title: AlertstringFile.Alert_title,
                    message:AlertstringFile.Choose_any_target,
                    on: self
                )
        }
        
    }
   
    
    func sendtextmessage_communication(){
        
        
        
        
        APIService.shared
            .makeApi(url: ServiceUrl.comm_text_message_send_text, parameters:[
                 
                   send_textmessageStringFile.description : user_inputs.title,
                   send_textmessageStringFile.message : user_inputs.description,
                   send_textmessageStringFile.target_code: array_selectedSchoolId,
                   send_textmessageStringFile.target_type: target_type ?? 0
                 
            ] , type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "" ){ [self] (
                result : Result<CommonApiSuc,
                Error>
            ) in
                
                switch result {
                    
                case.success(let succesmessage) :
                    
                    if succesmessage.status == true {
                        
                        DispatchQueue.main.async { [self] in
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: "Success",
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) {
                                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                                    
                                }
                            
                        }
                    }else {
                        
                        DispatchQueue.main.async {
                            
                            
                        }
                    }
                    
                case.failure(let error) :
                    
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
                
            }
        
        
    }
    
    
    func sendVoiceMessage_communication() {
        
        
        APIService.shared
            .makeApi(url: ServiceUrl.comm_voice_send_voice, parameters:[
                
                send_voicemeassageStringFile.voice_link : user_inputs.voice_link,
                send_voicemeassageStringFile.target_type : target_type ?? 0,
                send_voicemeassageStringFile.target_code : array_selectedSchoolId,
                send_voicemeassageStringFile.duration : user_inputs.duration,
                send_voicemeassageStringFile.description : user_inputs.description,
                send_voicemeassageStringFile.is_emergency : user_inputs.is_emergency,
                send_voicemeassageStringFile.is_schedule : user_inputs.is_schedule,
                send_voicemeassageStringFile.schedule_date : user_inputs.schedule_date,
                send_voicemeassageStringFile.start_time : user_inputs.start_time,
                send_voicemeassageStringFile.end_time :user_inputs.end_time,
                send_voicemeassageStringFile.file_name : user_inputs.file_name
                
            ] , type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "" ){ [self] (
                result : Result<CommonApiSuc,
                Error>
            ) in
                
                switch result {
                    
                case.success(let succesmessage) :
                    
                    if succesmessage.status == true {
                        
                        DispatchQueue.main.async { [self] in
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: "Success",
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) {
                                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                                    
                                }
                            
                        }
                    }else {
                        
                        DispatchQueue.main.async {
                            
                            
                        }
                    }
                    
                case.failure(let error) :
                    
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
                
            }
        
    }
}
struct School {
    let name: String
    let address: String
    var isSelected: Bool
}

