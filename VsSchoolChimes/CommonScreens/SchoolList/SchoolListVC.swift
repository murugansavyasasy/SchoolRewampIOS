//
//  SchoolListVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 22/03/25.
//

import UIKit
import DropDown

@available(iOS 14.0, *)
class SchoolListVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var chooseUrSchoolLbl: UILabel!
    @IBOutlet weak var headerSchoolLbl: UILabel!
    @IBOutlet weak var radioBtnStack: UIStackView!
    @IBOutlet weak var studentBtnName: UIButton!
    @IBOutlet weak var staffBtnName: UIButton!
    @IBOutlet weak var allbtnName: UIButton!
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
    var accadimYr :[String] = []
    let acidamicdrops = DropDown()
    var selectedAcadimicYearId : Int?
    var accadmicDefaultYrName : String?
    var uploadedURLs: [String] = []
    var come_fromLogin = false
    let MenuRedirect = MenuRedirectHandler.shared
    var selectedTarget = "all"
    var Common_request_params: [String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTable.register(UINib(nibName:CellConfingName.SchoolListTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.SchoolListTVC)
        
        setupRadioButton(button: allbtnName)
        setupRadioButton(button: studentBtnName)
        setupRadioButton(button: staffBtnName)
      
        chooseUrSchoolLbl.setFont(style: .header, size: FontSize.HeaderSize)
        headerSchoolLbl.setFont(style: .header, size: FontSize.HeaderSize)
        
        if come_fromLogin{
            ViewAnimator.hideFade(segmentName)
            ViewAnimator.hideFade(chooseDefaultLbl)
            ViewAnimator.hideFade(sendBtnName)
            ViewAnimator.hideFade(acidamicYrDropView)
            segmentName.selectedSegmentIndex = 0
        }else{
            applyShadowAndCornerRadius(to: acidamicYrDropView)
            target_type = TargetTypes.school
            ViewAnimator.hideFade(chooseDefaultLbl)
            ViewAnimator.hideFade(acidamicYrDropView)
            getacadmicYr()
            for i in 0..<(school_details?.count ?? 0) {
                school_details?[i].isSelected = true
                if let school_id = school_details?[i].school_id{
                    array_selectedSchoolId
                        .append(school_id)
                }
            }
            
            if Menu_id.staffSelectedMenuId == Menu_id.noticeboardMenuId{
                radioButtonTapped(allbtnName)
                ViewAnimator.hideFade(segmentName)
                ViewAnimator.showFade(radioBtnStack)
                ViewAnimator.showFade(sendBtnName)
                segmentName.selectedSegmentIndex = 1
            }
            let acidmaciyrClick = UITapGestureRecognizer(target: self, action: #selector(academicYearDrop_action))
            acidamicYrDropView.addGestureRecognizer(acidmaciyrClick)
        }
    }
    
    func setupRadioButton(button: UIButton) {
       
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "circle.inset.filled"), for: .selected)
        // Optional: Set content alignment
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 15)
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [ Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    @IBAction func radioButtonTapped(_ sender: UIButton) {
        // Deselect all
        [allbtnName, staffBtnName,
         studentBtnName].forEach { $0?.isSelected = false }

           // Select the tapped button
           sender.isSelected = true

           // Optional: print or handle selection
           if sender == allbtnName {
               print("All selected")
               selectedTarget = "all"
           } else if sender == staffBtnName {
               print("Staff selected")
               selectedTarget = "staff"
           } else if sender == studentBtnName {
               print("Student selected")
               selectedTarget = "student"
           }
    }
    
    @IBAction func academicYearDrop_action() {
        accadimYr.removeAll()
        for i in 0..<(localData.accidamic_year_data?.data?.count ?? 0){
            accadimYr.append(localData.accidamic_year_data?.data?[i].year ?? "")
        }
        acidamicdrops.anchorView = acidamicYrDropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acidamicYrDropView.bounds.height)
        acidamicdrops.show()
        
        acidamicdrops.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            
            selectedAcadimicYearId = localData.accidamic_year_data?.data?[index].id ?? 0
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
       
        if come_fromLogin{
            if let data = school_details?[indexPath.row]{
                UserDefaultFileManager.saveStaffDetails(data: data)}
            
            switch Menu_id.staffSelectedMenuId{
    
            case Menu_id.staffGeoAttendaceReport:
                MenuRedirect.StaffWiseAttendance(from: self)
            case Menu_id.geoMatricAttendace:
                MenuRedirect.senderMarkAttendanceNavigate(from: self)
            case Menu_id.homeWorkMenuId:
                MenuRedirect.senderHomeWorkNavigate(from: self)
            case Menu_id.studentReport:
                MenuRedirect.senderStudentreportNavigate(from: self)
            case Menu_id.noticeboardMenuId:
                MenuRedirect.senderNoticeboardNavigate(from: self)
            case Menu_id.event:
                MenuRedirect.senderEventNavigate(from: self)
            case Menu_id.attendance:
                 MenuRedirect.senderMarkAttendence(from: self)
            case Menu_id.feependingreport:
                MenuRedirect.senderFeePendingNavigate(from: self)
            case Menu_id.dailyCollection:
                MenuRedirect.senderDailyCollectionNavigate(from: self)
            case Menu_id.schoolStrength:
                 MenuRedirect.senderSchoolStrength(from: self)
            case Menu_id.AbsenteeismReport:
                MenuRedirect.senderAbsenteesReport(from: self)
            case Menu_id.isAssaignment:
                MenuRedirect.senderAssignmentNavigate(from: self)
            case Menu_id.LessonPlan:
                MenuRedirect.senderLessonplanNavigate(from: self)
            case Menu_id.MessageFromManagement:
                MenuRedirect.senderMgmt(from: self)
            case Menu_id.MessageFromManagement:
                 MenuRedirect.Senderchat(from: self)
            case Menu_id.ptm :
                MenuRedirect.senderPtmNavigate(from: self)
            case Menu_id.quiz :
                MenuRedirect.senderQuiz(from: self)
            default:
                print("staffSelectedMenuId",Menu_id.staffSelectedMenuId)
            }
            
        }else{
        

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
                vc.Common_request_params = Common_request_params
                vc.ScreenType = screen_type
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
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
        
        
        let comm = commonApi_forSending()
        switch Menu_id.staffSelectedMenuId {
        case Menu_id.communicationMenuId:
            SendingCommunicationFlow()
        case Menu_id.noticeboardMenuId:
            let params: [String: Any] = [
                SendNoticeStringFile.intended_for : selectedTarget]
            
            Common_request_params.merge(params) { _, new in new }
            sendAttachmentFlow(
                via: comm,
                url: ServiceUrl.api_notice_board_send_notice,
                subjectId:""
            )
        case Menu_id.AttachmentMenuId:
            
            sendAttachmentFlow(
                via: comm,
                url: ServiceUrl.comm_attachment_send_attachment,
                subjectId:""
            )
        default:
            print("❗️Unhandled menu ID: \(screenType.staffSelectedMenuId)")
        }
    }
   
    
    
    
    
    private func sendAttachmentFlow(
        via comm: commonApi_forSending,
        url baseURL: String,
        subjectId: String
    ) {
        
        var message : String?
        if accadmicDefaultYrName == acidmicYrLbl.text{
            message = AlertstringFile.Selected_target + "\(array_selectedSchoolId.count)" + "\n" + AlertstringFile.AreYouSureYouWantToProceed
        }else{
            
            message = AlertstringFile.Selected_target + "\(array_selectedSchoolId.count)" + "\n" + AlertstringFile.Change_academic_year + " " + (
                acidmicYrLbl.text ?? "") + AlertstringFile.Change_academic_year1 +   "\n" + AlertstringFile.Change_academic_year2
        }
        
        comm.SendingAttachmentFlow(
            selectedAcadimicYearId: selectedAcadimicYearId ?? 0,
            target_type: target_type ?? 0,
            selectedId: array_selectedSchoolId,
            baseURL: baseURL,
            subjectId: subjectId,
            message: message ?? "",
            from: self,
            Common_request_params: Common_request_params
        ) { response in
            DispatchQueue.main.async {
                CircularProgressLoader.shared.hide()
                CustomAlert.showAlertWithOkAction(
                    title: AlertstringFile.Success,
                    message: response.message,
                    on: self
                ) { [self] in
                    gotoDashboard()
                }
            }
        }
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
        case let attachments as [AttachmentItem]:
            let uploadableItems = attachments.filter { $0.image != nil || $0.imageURL != nil }
            let total = uploadableItems.count
            guard total > 0 else {
                completion()
                return
            }
            
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
            
            for item in uploadableItems {
                if let image = item.image {
                    // 🖼️ Upload local image
                    AWSUploadManager.shared.uploadFileToAWS(
                        file: image,
                        bucketPath: "uploads/images/",
                        bucketName: "schoolchimes-communication",
                        progressHandler: nil,
                        completion: { url in
                            if let uploadedURL = url {
                                self.uploadedURLs.append(uploadedURL)
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
                } else if let fileURLStr = item.imageURL {
                    if fileURLStr.lowercased().starts(with: "http") {
                        self.uploadedURLs.append(fileURLStr)
                        completed += 1
                        let progress = (Double(completed) / Double(total)) * 100
                        CircularProgressLoader.shared.updateProgress(to: progress)

                        if completed == total {
                            CircularProgressLoader.shared.hide()
                            // Do something with uploadedURLs if needed
                            completion()
                        }
                    } else if let fileURL = URL(string: fileURLStr) {
                        let path = item.fileType.lowercased() != CommonStringFile.IMAGE ? "uploads/Documents/" : "uploads/images/"
                        
                        AWSUploadManager.shared.uploadFileToAWS(
                            file: fileURL,
                            bucketPath: path,
                            bucketName: "schoolchimes-communication",
                            progressHandler: nil,
                            completion: { url in
                                if let uploadedURL = url {
                                    self.uploadedURLs.append(uploadedURL)
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
                    } else {
                        print("❌ Invalid fileURL: \(fileURLStr)")
                        completed += 1
                        let progress = (Double(completed) / Double(total)) * 100
                        CircularProgressLoader.shared.updateProgress(to: progress)

                        if completed == total {
                            CircularProgressLoader.shared.hide()
                            // Do something with uploadedURLs if needed
                            completion()
                        }
                    }
                }
            }
        default:
            print("❌ Unsupported file type")
            return
        }
    }


    
    func getacadmicYr(){
        
        if  localData.accidamic_year_data?.status == true{
            DispatchQueue.main.async { [self] in
                var hasCurrentYear = false
                for i in 0..<(
                    localData.accidamic_year_data?.data?.count ?? 0
                ){
                    if localData.accidamic_year_data?.data?[i].current_academic_year ?? false == true{
                        acidmicYrLbl.text = localData.accidamic_year_data?.data?[i].year
                        accadmicDefaultYrName = localData.accidamic_year_data?.data?[i].year
                        selectedAcadimicYearId = localData.accidamic_year_data?.data?[i].id ?? 0
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
                        message: localData.accidamic_year_data?.message ?? "" ,
                        on: self
                    )
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
    
    
    
    
    //MARK: Sender Noticeboard
    private func SendingNoticeboardFlow() {
        
        let title = AlertstringFile.Confirm_title
        
        alert.showAlertCancel(
            title: title,
            message: AlertstringFile.are_yousure_youWant_to_send_Notice,
            actionLbl1: AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            
            onOk: {[self] in
                
                let file: Any = user_inputs.SelectedUrls
                uploadAndSendVoiceMessage(file: file) { [self] in
                    
                    CircularProgressLoader.shared.hide()
                    let uploadedFiles: [[String:String]] = uploadedURLs.compactMap{ url in
                        
                        if let url = URL(string: url) {
                            let type = url.pathExtension.lowercased()
                            user_inputs.selectedFileType = type == CommonStringFile.jpg ? CommonStringFile.IMAGE : type
                        }
                        return [
                            CommonStringFile.url: url,
                            CommonStringFile.type: user_inputs.selectedFileType
                        ]
                    }
                    
                    let parameters : [String: Any] = [
                        
                        SendNoticeStringFile.title : user_inputs.title,
                        SendNoticeStringFile.description : user_inputs.description,
                        SendNoticeStringFile.target_code : array_selectedSchoolId,
                        SendNoticeStringFile.intended_for : selectedTarget,
                        SendNoticeStringFile.visible_from : user_inputs.FromDate,
                        SendNoticeStringFile.visible_to : user_inputs.ToDate,
                        SendNoticeStringFile.file_path : uploadedFiles,
                    ]
                    
                    APIService.shared.makeApi(url: ServiceUrl.api_notice_board_send_notice, parameters: parameters, type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [self] (result: Result<NoticeResponse,Error>) in
                        
                        switch result {
                            
                        case .success(let SuccessMessage):
                            
                            if SuccessMessage.status == true {
                                
                                DispatchQueue.main.async { [self] in
                                    
                                    CustomAlert.showAlertWithOkAction(
                                        title: AlertstringFile.Success,
                                        message: SuccessMessage.message ?? "",
                                        on: self) {
                                            
                                            self.gotoDashboard()
                                        }
                                }
                            }else {
                                
                                DispatchQueue.main.async { [self] in
                                    
                                    CustomAlert.showAlertWithOkAction(
                                        title: AlertstringFile.Alert_title,
                                        message: SuccessMessage.message ?? "",
                                        on: self) {
                                            
                                            self.gotoDashboard()
                                        }
                                }
                            }
                            
                            
                        case .failure(let error):
                            
                            print("Error : \(error.localizedDescription)")
                        }
                        
                    }
                }
            },
            
            onNo: {
                print("User Canceled")
            }
            
        )
    }
    
    
    
    func gotoDashboard() {
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
    }
}
struct School {
    let name: String
    let address: String
    var isSelected: Bool
}

