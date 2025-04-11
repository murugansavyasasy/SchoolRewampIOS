//
//  SchoolListVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 22/03/25.
//

import UIKit
import DropDown

class SchoolListVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var acidamicYrDropView: UIView!
    @IBOutlet weak var sendBtnName: UIButton!
    @IBOutlet weak var segmentName: UISegmentedControl!
    @IBOutlet weak var listTable: UITableView!
   
    var screen_type : Int?
    var isEmergency : Int = 1
    var isNoticeBoard : Int = 1
    
    var school_details = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    let alert = CustomAlert()
    var communicatio_textDetails :[String] = []
    var array_selectedSchoolId :[String] = []
    var target_type:Int?
    var requestCommonDataDetails : [String:Any] = [:]
    var AcadimicYearDatas : [AcadimicYearData] = []
    var accadimYr :[String] = []
    let acidamicdrops = DropDown()
    override func viewDidLoad() {
        super.viewDidLoad()
        applyShadowAndCornerRadius(to: acidamicYrDropView)
        target_type = TargetTypes.school
        sendBtnName.isHidden = true
        if (isEmergency == screen_type || isNoticeBoard == screen_type){
            segmentName.isHidden = true
            segmentName.selectedSegmentIndex = 1
            sendBtnName.isHidden = false
        }
        for i in 0..<(school_details?.count ?? 0) {
            school_details?[i].isSelected = true
            if let school_id = school_details?[i].school_id{
                array_selectedSchoolId
                    .append(school_id)
            }
        }
        
        getacadmicYr()
        listTable.register(UINib(nibName:CellConfingName.SchoolListTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.SchoolListTVC)
        
        let acidmaciyrClick = UITapGestureRecognizer(target: self, action: #selector(academicYearDrop_action))
        acidamicYrDropView.addGestureRecognizer(acidmaciyrClick)
       
        
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [ Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    
    @IBAction func academicYearDrop_action() {
        accadimYr.removeAll()
        for i in 0..<(AcadimicYearDatas.count){
            accadimYr.append(AcadimicYearDatas[i].year ?? "")
        }
        acidamicdrops.anchorView = acidamicYrDropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acidamicYrDropView.bounds.height)
        acidamicdrops.show()
        
        acidamicdrops.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            
            if let label = self.acidamicYrDropView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
            }
           
    
        }
        
    }
    
    func applyShadowAndCornerRadius(to view: UIView, cornerRadius: CGFloat = 10, shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 4, height: 4), shadowOpacity: Float = 0.5, shadowRadius: CGFloat = 4, backgroundColor: UIColor = .white) {
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowRadius = shadowRadius
        view.backgroundColor = backgroundColor
    }
    @IBAction func segment_action(_ sender: Any) {
       
        if segmentName.selectedSegmentIndex == 0 {
           
            sendBtnName.isHidden = true
            listTable.reloadData()
        }else{
            sendBtnName.isHidden = false
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
        
        if segmentName.selectedSegmentIndex == 1{
            let img = schools_details?.isSelected ?? false ? UIImage(named: "checkedSquare") : UIImage(
                named: "uncheckedSquare")
            cell.selectedBtn.setImage(img, for: .normal)
        }else{
            
            cell.selectedBtn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        }
       
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        if segmentName.selectedSegmentIndex == 1{

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
        
        
        guard !array_selectedSchoolId.isEmpty else {
                alert.showAlert(
                    title: AlertstringFile.Alert_title,
                    message: AlertstringFile.Choose_any_target,
                    on: self
                )
                return
            }

            switch screenType.staffSelectedMenuId {
            case Menu_id.communicationMenuId:
                SendingCommunicationFlow()

            case Menu_id.homeWorkMenuId:
                handleHomeworkFlow()

            default:
                print("❗️Unhandled menu ID: \(screenType.staffSelectedMenuId)")
            }
    }
   
    
    
    private func handleHomeworkFlow() {
        
        
    }
    
    private func SendingCommunicationFlow() {
        let message = AlertstringFile.AreYouSureYouWantToProceed + "\(array_selectedSchoolId.count)"
        let title = AlertstringFile.Alert_title

        alert.showAlertCancel(
            title: title,
            message: message,
            actionLbl1: AlertstringFile.OK,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: { [self] in
                switch screen_type {
                case screenType.communication_text:
                    sendtextmessage_communication()

                case screenType.is_emergencyvoice, screenType.non_emergencyvoice:
                    uploadAndSendVoiceMessage(url : user_inputs.voice_link)

                default:
                    print("❗️Unhandled communication screen type: \(screen_type)")
                }
            },
            onNo: {
                print("❌ User canceled.")
            }
        )
    }
    
    private func uploadAndSendVoiceMessage(url: String) {
        guard let audioURL = URL(string: url) else {
            print("❌ Invalid audio URL.")
            return
        }

        AWSUploadManager.shared.uploadFileToAWS(
            file: audioURL,
            bucketPath: "uploads/audio/",
            bucketName: "schoolchimes-communication"
        ) { url in
            if let uploadedURL = url {
                print("✅ Audio uploaded: \(uploadedURL)")
                user_inputs.voice_link = uploadedURL
                self.sendVoiceMessage_communication()
            } else {
                print("❌ Audio upload failed.")
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
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            //                        listTable.isHidden = true
                            AcadimicYearDatas = successMessage.data ?? []
                            acidamicYrDropView.isUserInteractionEnabled = true
                            for i in 0..<(AcadimicYearDatas.count){
                                if AcadimicYearDatas[i].current_academic_year ?? false == true{
                                    if let label = self.acidamicYrDropView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                                        label.text = AcadimicYearDatas[i].year
                                        break
                                    }
                                }
                            }
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            acidamicYrDropView.isUserInteractionEnabled = false
                            listTable.isHidden = true
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
    }
    func sendtextmessage_communication(){
        
        
        APIService.shared
            .makeApi(url: ServiceUrl.comm_text_message_send_text, parameters:[
                
                send_textmessageStringFile.description : user_inputs.title,
                send_textmessageStringFile.message : user_inputs.description,
                send_textmessageStringFile.target_code: array_selectedSchoolId,
                send_textmessageStringFile.target_type: TargetTypes.school
                
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
                                    self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                                    
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
                send_voicemeassageStringFile.file_name : user_inputs.file_name,
                send_voicemeassageStringFile.circular_type : circular_type.school
                
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
                                    self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                                    
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

