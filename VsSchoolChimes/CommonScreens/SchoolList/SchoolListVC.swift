//
//  SchoolListVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 22/03/25.
//

import UIKit
import DropDown

class SchoolListVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var chooseDefaultLbl: UILabel!
    @IBOutlet weak var acidmicYrLbl: UILabel!
    @IBOutlet weak var acidamicYrDropView: UIView!
    @IBOutlet weak var sendBtnName: UIButton!
    @IBOutlet weak var segmentName: UISegmentedControl!
    @IBOutlet weak var listTable: UITableView!
   
    @IBOutlet weak var norecordImg: UIImageView!
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
    var selectedAcadimicYearId : Int?
    var accadmicDefaultYrName : String?
    var uploadedURLs: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        applyShadowAndCornerRadius(to: acidamicYrDropView)
        target_type = TargetTypes.school
       
        ViewAnimator.hideFade(chooseDefaultLbl)
        ViewAnimator.hideFade(acidamicYrDropView)
        ViewAnimator.hideFade(sendBtnName)
    
        getacadmicYr()
        for i in 0..<(school_details?.count ?? 0) {
            school_details?[i].isSelected = true
            if let school_id = school_details?[i].school_id{
                array_selectedSchoolId
                    .append(school_id)
            }
        }
        
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
            
            selectedAcadimicYearId = AcadimicYearDatas[index].id ?? 0
            acidmicYrLbl.text = item
           
    
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
           
            ViewAnimator.hideFade(chooseDefaultLbl)
            ViewAnimator.hideFade(sendBtnName)
            ViewAnimator.hideFade(acidamicYrDropView)
            listTable.reloadData()
            
        }else{
           
            ViewAnimator.showFade(sendBtnName)
            ViewAnimator.showFade(chooseDefaultLbl)
            ViewAnimator.showFade(acidamicYrDropView)
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
            cell.rightArrow.isHidden = true
            cell.arrowWidth.constant = 0
            cell.selectBtnWidth.constant = 20
            cell.selectedBtn.isHidden = false
            
        }else{
            cell.selectedBtn.isHidden = true
            cell.rightArrow.isHidden = false
            cell.arrowWidth.constant = 20
            cell.selectBtnWidth.constant = 0
            cell.rightArrow.setImage(UIImage(systemName: "chevron.right"), for: .normal)
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
        var message : String?
        if accadmicDefaultYrName == acidmicYrLbl.text{
            message = AlertstringFile.Selected_target + "\(array_selectedSchoolId.count)" + "\n" + AlertstringFile.AreYouSureYouWantToProceed
        }else{
            
            message = AlertstringFile.Selected_target + "\(array_selectedSchoolId.count)" + "\n" + AlertstringFile.Change_academic_year + " " + (
                acidmicYrLbl.text ?? "") + AlertstringFile.Change_academic_year1 +   "\n" + AlertstringFile.Change_academic_year2
        }
        let title = AlertstringFile.Alert_title
        
        alert.showAlertCancel(
            title: title,
            message: message ?? "",
            actionLbl1: AlertstringFile.OK,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: { [self] in
                switch screen_type {
                case screenType.communication_text:
                    sendtextmessage_communication()
                    
                case screenType.is_emergencyvoice, screenType.non_emergencyvoice:
                    uploadAndSendVoiceMessage(file: user_inputs.voice_link) {
                        self.sendVoiceMessage_communication()
                    }
                default:
                    print("❗️Unhandled communication screen type: \(screen_type)")
                }
            },
            onNo: {
                print("❌ User canceled.")
            }
        )
    }
    
    private func uploadAndSendVoiceMessage(file: Any, completion: @escaping () -> Void) {
        var completed = 0

        switch file {

        // 🎙️ Case: Audio File from String (URL Path)
        case let files as String:
            guard let audioURL = URL(string: files) else {
                print("❌ Invalid audio URL.")
                return
            }
            let total = 1
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
            let today_date = AwsCurrentDateString()
            AWSUploadManager.shared.uploadFileToAWS(
               
                file: audioURL,
                bucketPath:  "communication" + "/" + (UserDefaultFileManager
                    .get_staff_Details()?.school_id ?? "") + "/" + today_date
                    ,
                bucketName: "schoolchimes-communication",
                progressHandler: { progress in
                    CircularProgressLoader.shared.updateProgress(to: progress)
                },
                completion: { url in
                    if let uploadedURL = url {
                        print("✅ Audio uploaded: \(uploadedURL)")
                        user_inputs.voice_link = uploadedURL
                    } else {
                        print("❌ Audio upload failed.")
                    }

                    completed += 1
                    let progress = (Double(completed) / Double(total)) * 100
                    CircularProgressLoader.shared.updateProgress(to: progress)

                    if completed == total {
                        CircularProgressLoader.shared.hide()
                        completion()
                    }
                }
            )

        // 🖼️ Case: Array of Images
        case let images as [UIImage]:
            let total = images.count
            guard !images.isEmpty else {
                completion()
                return
            }

            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)

            for (index, img) in images.enumerated() {
                AWSUploadManager.shared.uploadFileToAWS(
                    file: img,
                    bucketPath: "uploads/images/",
                    bucketName: "schoolchimes-communication",
                    progressHandler: { progress in
                        // Optional: Update progress per file individually if you want
                    },
                    completion: { [self] url in
                        if let uploadedURL = url {
                            uploadedURLs.append(uploadedURL)
                            
                        } else {
                            print("❌ Failed to upload image \(index)")
                        }

                        completed += 1
                        let progress = (Double(completed) / Double(total)) * 100
                        CircularProgressLoader.shared.updateProgress(to: progress)

                        if completed == total {
                            CircularProgressLoader.shared.hide()
                            // Do something with uploadedURLs if needed
                            completion()
                        }
                    }
                )
            }
            // 🖼️ Case: Array of Images
        case let files as [String]:
                let total = files.count
                guard !files.isEmpty else {
                    completion()
                    return
                }

                CircularProgressLoader.shared.show(style: .circle)
                CircularProgressLoader.shared.updateProgress(to: 0)

                for (index, url) in files.enumerated() {
                    guard let PdfURL = URL(string: url) else {
                        print("❌ Invalid audio URL.")
                        return
                    }
                    AWSUploadManager.shared.uploadFileToAWS(
                        file: PdfURL,
                        bucketPath: "uploads/Documents/",
                        bucketName: "schoolchimes-communication",
                        progressHandler: { progress in
                            // Optional: Update progress per file individually if you want
                        },
                        completion: { [self] url in
                            if let uploadedURL = url {
                                uploadedURLs.append(uploadedURL)
                                
                            } else {
                                print("❌ Failed to upload image \(index)")
                            }

                            completed += 1
                            let progress = (Double(completed) / Double(total)) * 100
                            CircularProgressLoader.shared.updateProgress(to: progress)

                            if completed == total {
                                CircularProgressLoader.shared.hide()
                                // Do something with uploadedURLs if needed
                                completion()
                            }
                        }
                    )
                }
        default:
            print("❌ Unsupported file type")
            return
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
                            var hasCurrentYear = false
                            for i in 0..<(AcadimicYearDatas.count){
                                if AcadimicYearDatas[i].current_academic_year ?? false == true{
                                        acidmicYrLbl.text = AcadimicYearDatas[i].year
                                    accadmicDefaultYrName = AcadimicYearDatas[i].year
                                        selectedAcadimicYearId = AcadimicYearDatas[i].id ?? 0
                                    hasCurrentYear = true
                                    segmentName.isUserInteractionEnabled = hasCurrentYear
                                    listTable.reloadData()
                                        break
                                   
                                }
                            }
                            
                            if !hasCurrentYear {
                                listTable.isHidden = true
                                sendBtnName.isHidden = true
                                segmentName.isUserInteractionEnabled = false
//                                nodata(false, message: "")
                                norecordImg.isHidden = false
                                noRecordLbl.isHidden = false
                                acidamicYrDropView.isUserInteractionEnabled = false
                                
                                let fullText = "Your academic year configuration are incorrect. Please contact your School Chimes at support@savyasasy.com"
                                let attributedString = NSMutableAttributedString(string: fullText)

                                let email = "support@savyasasy.com"
                                if let range = fullText.range(of: email) {
                                    let nsRange = NSRange(range, in: fullText)
                                    
                                    // Color and underline
                                    attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: nsRange)
                                    attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                                }

                                noRecordLbl.attributedText = attributedString
                                noRecordLbl.isUserInteractionEnabled = true
                                
                                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleEmailTap(_:)))
                                noRecordLbl.addGestureRecognizer(tapGesture)

                            }
                            
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            self.alert
                                .showAlert(
                                    title: "Error",
                                    message: successMessage.message ?? "" ,
                                    on: self
                                )
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
    }
    
    @objc func handleEmailTap(_ gesture: UITapGestureRecognizer) {
        guard let text = noRecordLbl.attributedText?.string else { return }
           let email = "support@savyasasy.com"

           if let range = text.range(of: email) {
               let nsRange = NSRange(range, in: text)

               let tapLocation = gesture.location(in: noRecordLbl)
               let layoutManager = NSLayoutManager()
               let textContainer = NSTextContainer(size: noRecordLbl.bounds.size)
               let textStorage = NSTextStorage(attributedString: noRecordLbl.attributedText!)

               textContainer.lineFragmentPadding = 0
               textContainer.maximumNumberOfLines = noRecordLbl.numberOfLines
               textContainer.lineBreakMode = noRecordLbl.lineBreakMode
               layoutManager.addTextContainer(textContainer)
               textStorage.addLayoutManager(layoutManager)

               let index = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

               if NSLocationInRange(index, nsRange) {
                   let subject = ""
                   let body = ""
                   
                   // URL encode
                   let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                   let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                   
                   // Try Gmail URL
                   if let gmailURL = URL(string: "googlegmail://co?to=\(email)&subject=\(encodedSubject)&body=\(encodedBody)"),
                      UIApplication.shared.canOpenURL(gmailURL) {
                       UIApplication.shared.open(gmailURL)
                   } else if let fallbackURL = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
                       UIApplication.shared.open(fallbackURL)
                   }
               }
           }
    }
    func sendtextmessage_communication(){
        
        APIService.shared
            .makeApi(url: ServiceUrl.comm_text_message_send_text, parameters:[
                
                send_textmessageStringFile.description : user_inputs.title,
                send_textmessageStringFile.message : user_inputs.description,
                send_textmessageStringFile.target_code: array_selectedSchoolId,
                send_textmessageStringFile.target_type: TargetTypes.school,
                send_textmessageStringFile.academic_year_id: selectedAcadimicYearId ?? 0
                
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
                send_voicemeassageStringFile.circular_type : circular_type.school,
                send_voicemeassageStringFile.academic_year_id: selectedAcadimicYearId ?? 0
                
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

