//
//  StudentHistryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 20/11/24.
//

import UIKit

class StudentHistryVC: UIViewController, UISearchBarDelegate, Attendence {
    
    func statusUpdate(status: Bool, index: Int) {
        guard let studentId = filterData?[index].id else { return }
        if let originalIndex = studentsDetails?.firstIndex(where: { $0.id == studentId }) {
            studentsDetails?[originalIndex].isAbsent = status
            filterData?[index].isAbsent = status
            // Count of students marked as absent
            totalcount = studentsDetails?.filter { $0.isAbsent == false }.count ?? 0
            let PresenrCount = studentsDetails?.filter { $0.isAbsent == true }.count ?? 0
//            PresentCountLbl.text = String(PresenrCount)
//            AbsentCountLbl.text = String(totalcount)
            let image = totalcount == studentsDetails?.count ?? 0  ? ImageName.checkmark:ImageName.square
            selectAllBtn.setImage(image, for: .normal)
        }
    }
    
    @IBOutlet weak var SearchStack: UIStackView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var sendbtnName: UIButton!
    @IBOutlet weak var historyTable: UITableView!
    @IBOutlet weak var TopView: UIView!
    var switchCell = 1
    var dropDown = DropDown()
    
    var isSelectAllEnabled = false
    var isAttandanceMarkingScreen = false
    var dataVisibility: [Bool] = []
    var selectedRows: [Bool] = []
    let YOUR_VIMEO_TOKEN = "8d74d8bf6b5742d39971cc7d3ffbb51a"
    var vimeoUploader: VimeoUploader?
    var StandardString: String?
    var SectionString: String?
    var img = ["shiyam","stuentimg 1"]
    var totalcount = 0
    var filterData : [StudentDetails]?
    var studentsDetails: [StudentDetails]?
    var selected_sectionID : String?
    var selected_student : [String] = []
    var ScreenType:Int?
    let alert = CustomAlert()
    var communicatio_textDetails :[String] = []
    var target_type : Int?
    var circular_types : String?
    var standard_sectionlabel : String? = "10"
    var selectedAcadimicYearId : Int?
    let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    
    let staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var uploadedURLs: [String] = []
    var AlertMessageContent:Bool?
    var accidmaticNAme:String?
    var Common_request_params : [String : Any] = [:]
    var selected_subjectID : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        sendbtnName.layer.cornerRadius = 10
        target_type = TargetTypes.student
        circular_types =  circular_type.student
        StyleAndTranslater()
        BackBtn.applyBackButton()
        search.searchTextField.addDoneButton()
        search.searchTextField.borderStyle = .none
        search.backgroundImage = UIImage()
        search.searchTextField.layer.cornerRadius = 8
        search.searchTextField.backgroundColor = .systemGray5
        search.layer.cornerRadius = 8
        search.searchTextField.layer.masksToBounds = true
        search.placeholder = "Search"
        TopView.layer.cornerRadius = 20
        TopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
             
        SearchStack.isHidden = true
                
        selectAllBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        sendbtnName.setTitleFont(style: .body, size: FontSize.BodySize)
        
        let firstline = (StandardString ?? "") + "-" + (SectionString ?? "")
        BackBtn.configureAsBackButton(firstLine: firstline, secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        
        
            filterBtn.isHidden = true
            selectAllBtn.setImage(ImageName.square, for: .normal)
            selectAllBtn.semanticContentAttribute = .forceRightToLeft
            filterBtn.isUserInteractionEnabled = true
            
        
        registerCell()
        recipient_get_student_list(
            selected_sectionId: selected_sectionID ?? "",
            academic_year_id: selectedAcadimicYearId ?? 0
        )
        search.delegate = self
  
    }
    
    override func viewDidLayoutSubviews() {
//        view.applyGradient(
//            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
//            startPoint: CGPoint(x: 1, y: 0.5),
//            endPoint: CGPoint(x: 0, y: 0.5)
//        )
    }
    
    func StyleAndTranslater() {
        filterBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        search.placeholder = CommonStringFile.Search.translated()
    }
    
    func registerCell(){
        historyTable.register(UINib(nibName: CellConfingName.SpecificStudentTvcell, bundle: nil), forCellReuseIdentifier: CellConfingName.SpecificStudentTvcell)
        historyTable.register(UINib(nibName: CellConfingName.AttendenceTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AttendenceTVC)
        
    }
    
    @IBAction func fliter(_ sender: UIButton) {
        dropDown.dataSource = [CommonStringFile.RollNoDESC.translated(),CommonStringFile.RollNoASC.translated(),CommonStringFile.NameASC.translated(),CommonStringFile.NameDESC.translated(), CommonStringFile.Absent.translated(),CommonStringFile.Present.translated()]
        dropDown.anchorView = filterBtn
        dropDown.bottomOffset = CGPoint(x: 0, y: (filterBtn.bounds.height))
        
        dropDown.direction = .bottom
        
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            self.filterBtn.setTitle(item.translated(), for: .normal)
            
            switch item{
            case CommonStringFile.RollNoASC:
                let sortedByRollNumber = studentsDetails?.sorted {
                    $0.roll_no ?? "" < $1.roll_no ?? ""
                }
                filterData = sortedByRollNumber
            case CommonStringFile.RollNoDESC:
                let sortedByName = studentsDetails?.sorted {
                    $0.roll_no ?? "" > $1.roll_no ?? ""
                }
                filterData = sortedByName
            case CommonStringFile.NameASC:
                let sortedByName = studentsDetails?.sorted {
                    $0.name?.localizedCompare($1.name ?? "") == .orderedAscending
                }
                filterData = sortedByName
            case CommonStringFile.NameDESC:
                let sortedByName = studentsDetails?.sorted {
                    $0.name ?? "" > $1.name ?? ""
                }
                filterData = sortedByName
            case CommonStringFile.Absent:
                
                filterData = studentsDetails?.sorted {
                    !($0.isAbsent ?? false) && ($1.isAbsent != nil)
                }
            case CommonStringFile.Present:
                filterData = studentsDetails?.sorted {
                    $0.isAbsent ?? false && !(
                        $1.isAbsent ?? false
                    ) // Absent students first
                }
            default:
                filterData = studentsDetails
                
            }
            historyTable.reloadData()
            self.filterBtn.setTitle(item.translated(), for: .normal)
        }
        
    }
    
    @IBAction func selectAllStd(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        // Update data model to mark all students as present/absent
        let isSelectingAll = sender.isSelected
        if isAttandanceMarkingScreen == true{
            for i in 0..<(studentsDetails?.count ?? 0) {
                studentsDetails?[i].isAbsent = !isSelectingAll
                filterData?[i].isAbsent = !isSelectingAll
                let indexPath = IndexPath(row: i, section: 0)
                if let customCell = historyTable.cellForRow(at: indexPath) as? AttendenceTVC {
                    customCell.custSwitch.isOn = !isSelectingAll
                    customCell.hideLbl(isAbsent: !isSelectingAll)
                }
                
            }
            // Update select all button image and total count
            if isSelectingAll {
                selectAllBtn.setImage(ImageName.checkmark, for: .normal)
                totalcount = studentsDetails?.count ?? 0
            } else {
                selectAllBtn.setImage(ImageName.square, for: .normal)
                totalcount = 0
         }
        }
        else{
            isSelectAllEnabled.toggle()
            for i in 0..<(studentsDetails?.count ?? 0) {
                studentsDetails?[i].isSelect = isSelectAllEnabled
                filterData?[i].isSelect = isSelectAllEnabled
                
                // Update `selectedRows` to match the state
                selectedRows[i] = isSelectAllEnabled
            }
            historyTable.reloadData()
            // Update select all button image and total count
            if isSelectAllEnabled {
                selectAllBtn.setImage(ImageName.checkmark, for: .normal)
                totalcount = studentsDetails?.count ?? 0
            } else {
                selectAllBtn.setImage(ImageName.square, for: .normal)
                totalcount = 0
            }
        }

    }
    
    
    @IBAction func SearchAct(_ sender: UIButton) {
        
        SearchStack.isHidden.toggle()
        
        
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        SearchStack?.isHidden = !sender.isSelected
        if sender.isSelected {
            SearchStack?.becomeFirstResponder()
        } else {
            filterData = studentsDetails
//            self.noDataImg.isHidden = !self.searchData.isEmpty
            historyTable.reloadData()
            search.searchTextField.text = ""
            search?.resignFirstResponder()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: Function to get color for a given name
    func colorForName(_ name: String) -> UIColor {
        let firstLetter = name.uppercased().first!
        let color = ColorManager.shared.letterColors[firstLetter]
        return color ?? .gradient1
    }
    
    func recipient_get_student_list(selected_sectionId: String,academic_year_id:Int){
        APIService.shared
            .makeApi(url: ServiceUrl.recipient_get_student_list, parameters: [
                
                speficStudentStringFile.section_id : selected_sectionId
                ,speficStudentStringFile.academic_year_id : academic_year_id
                
            ], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <GetStudentlistSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            historyTable.isHidden = false
                            studentsDetails = successMessage.data
                            
                            if var students = studentsDetails {
                                for i in students.indices {
                                    students[i].isSelect = false
                                    students[i].isAbsent = true
                                }
                                studentsDetails = students
                            }
                            dataVisibility = Array(
                                repeating: true,
                                count: studentsDetails?.count ?? 0
                            )
                            selectedRows = Array(
                                repeating: true,
                                count: studentsDetails?.count ?? 0
                            )
                            filterData = studentsDetails
                            historyTable.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            historyTable.isHidden = true
                        }
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
    }
    
    
    
    @IBAction func sendBtnAction(_ sender: UIButton) {
        
            selected_student = studentsDetails?
                .filter { $0.isSelect == true }
                .compactMap { $0.id } ?? []

            guard !selected_student.isEmpty else {
                alert.showAlert(
                    title: AlertstringFile.Alert_title,
                    message: AlertstringFile.Choose_any_target,
                    on: self
                )
                return
            }
            
            let comm = commonApi_forSending()
            switch Menu_id.staffSelectedMenuId{
            case Menu_id.communicationMenuId:
                SendingCommunicationFlow()
                
            case Menu_id.AttachmentMenuId:
                sendAttachmentFlow(
                    via: comm,
                    url:  ServiceUrl.comm_attachment_send_attachment,
                    subjectId: ""
                )
            case Menu_id.isAssaignment:
                sendAttachmentFlow(
                    via: comm,
                    url:  ServiceUrl.comm_assignment_send_assignment,
                    subjectId: selected_subjectID ?? ""
                )
                
            default:
                print("❗️Unhandled menu ID: \(Menu_id.staffSelectedMenuId)")
            }
    }
    
    
    
    private func sendAttachmentFlow(
        via comm: commonApi_forSending,
        url baseURL: String,
        subjectId: String
    ) {
        let message : String?
        if AlertMessageContent ?? false{
            
            message = AlertstringFile.Selected_target + "\(selected_student.count) " + "Student(s)" + "\n" + AlertstringFile.AreYouSureYouWantToProceed
            
        }else{
            
            message = AlertstringFile.Selected_target + "\(selected_student.count) " + "Student(s)" + "\n" + AlertstringFile.Change_academic_year + " " + (
                accidmaticNAme ?? "") + AlertstringFile.Change_academic_year1 +   "\n" + AlertstringFile.Change_academic_year2
            
        }
        
        comm.SendingAttachmentFlow(
            selectedAcadimicYearId: selectedAcadimicYearId ?? 0,
            target_type: target_type ?? 0,
            selectedId: selected_student,
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
        
        
        let message : String?
        let title = AlertstringFile.Confirm_title
        
        if AlertMessageContent ?? false{
            
            message = AlertstringFile.Selected_target + "\(selected_student.count) " + "Student(s)" + "\n" + AlertstringFile.AreYouSureYouWantToProceed
            
        }else{
            
            message = AlertstringFile.Selected_target + "\(selected_student.count) " + "Student(s)" + "\n" + AlertstringFile.Change_academic_year + " " + (
                accidmaticNAme ?? "") + AlertstringFile.Change_academic_year1 +   "\n" + AlertstringFile.Change_academic_year2
            
        }
        alert.showAlertCancel(
            title: title,
            message: message ?? "",
            actionLbl1: AlertstringFile.OK,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: { [self] in
                switch ScreenType {
                case screenType.communication_text:
                    sendtextmessage_communication()
                    
                case screenType.is_emergencyvoice, screenType.non_emergencyvoice:
                    if user_inputs.voice_link.contains("https:") {
                        // Voice link is already uploaded
                        sendVoiceMessage_communication()
                    } else {
                        // Voice link is local, needs to be uploaded first
                        uploadAndSendVoiceMessage(file: user_inputs.voice_link) {
                            CircularProgressLoader.shared.hide()
                            self.sendVoiceMessage_communication()
                        }
                    }
                    
                    
                default:
                    print("❗️Unhandled communication screen type: \(ScreenType)")
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
    
    func sendtextmessage_communication(){

        APIService.shared
            .makeApi(url: ServiceUrl.comm_text_message_send_text, parameters:[
                
                send_textmessageStringFile.description : user_inputs.title,
                send_textmessageStringFile.message : user_inputs.description,
                send_textmessageStringFile.target_code: selected_student,
                send_textmessageStringFile.target_type: target_type ?? 0,
                send_textmessageStringFile.academic_year_id: selectedAcadimicYearId ?? 0
                
            ] , type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "" ){ [self] (result : Result<CommonApiSuc,Error>) in
                
                switch result {
                case.success(let succesmessage) :
                    if succesmessage.status == true {
                        DispatchQueue.main.async { [self] in
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) { [self] in
                                    gotoDashboard()
                                    
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
                send_voicemeassageStringFile.target_code : selected_student,
                send_voicemeassageStringFile.duration : user_inputs.duration,
                send_voicemeassageStringFile.description : user_inputs.description,
                send_voicemeassageStringFile.is_emergency : user_inputs.is_emergency,
                send_voicemeassageStringFile.is_schedule : user_inputs.is_schedule,
                send_voicemeassageStringFile.schedule_date : user_inputs.schedule_date,
                send_voicemeassageStringFile.start_time : user_inputs.start_time,
                send_voicemeassageStringFile.end_time :user_inputs.end_time,
                send_voicemeassageStringFile.file_name : user_inputs.file_name,
                send_voicemeassageStringFile.circular_type  : circular_type.student,
                send_voicemeassageStringFile.academic_year_id  : selectedAcadimicYearId ?? 0
                
                
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
                                    title: AlertstringFile.Success,
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) {
                                    self.gotoDashboard()
                                    
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
    
    
    
    func markAttendaceApi(){

        print("attendance",selected_student)
        let MakeAbsentId: [[String: String]] = selected_student.compactMap { id in
            return [
                "ID": id
            ]
        }
        APIService.shared
            .makeApi(url: ServiceUrl.attendance_send_absentees_sms_with_session_type, parameters:[
                
                
                MarkAttendenceStringFile.student_id: MakeAbsentId,
                MarkAttendenceStringFile.class_id: user_inputs.class_id,
                MarkAttendenceStringFile.section_id: user_inputs.section_id,
                MarkAttendenceStringFile.all_present: user_inputs.all_present,
                MarkAttendenceStringFile.attendance_type: user_inputs.attendance_type,
                MarkAttendenceStringFile.session_type: user_inputs.session_type,
                MarkAttendenceStringFile.attendance_date: user_inputs.attendance_date
                
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
                                    title: AlertstringFile.Success,
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) {
                                    self.attendaceGoBackDashBoard()
                                    
                                }
                            
                        }
                    }else {
                        
                        DispatchQueue.main.async {
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) {
                                    self.attendaceGoBackDashBoard()
                                    
                                }
                            
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

extension StudentHistryVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filterData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = historyTable.dequeueReusableCell(withIdentifier: CellConfingName.SpecificStudentTvcell, for: indexPath) as! SpecificStudentTvcell
            let backgroundColor = colorForName(
                filterData?[indexPath.row].name ?? ""
            )
            
            cell.NameLbl.text =  filterData?[indexPath.row].name ?? ""
            cell.AdmisionNoLbl.text = filterData?[indexPath.row].admission_no ?? ""
            cell.RollNoLbl.text = filterData?[indexPath.row].roll_no ?? ""
            if let firstChar =  filterData?[indexPath.row].name?.first {
                cell.alphabetLbl.text = String(firstChar)
            } else {
                cell.alphabetLbl.text = "" // Fallback for empty string
            }
            cell.AlphabetView.backgroundColor = backgroundColor
            cell.DropdownImg.image = dataVisibility[indexPath.row] ? UIImage(named: "arrow_up") : UIImage(named: "arrow_down")
            
            if let select = filterData?[indexPath.row].isSelect {
                cell.CheckBoxImgview.image = select ? ImageName.checkedSquares: ImageName.uncheckedSquares
            }
            // Set visibility state
            cell.RollNoLbl.isHidden = !dataVisibility[indexPath.row]
            cell.AdmisionNoLbl.isHidden = !dataVisibility[indexPath.row]
            
            //             Configure tap action
            cell.tapAction = { [weak self] in
                self?.handleImageTap(at: indexPath)
            }
            
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isAttandanceMarkingScreen{
            if let originalIndex = studentsDetails?.firstIndex(where: { $0.id == filterData?[indexPath.row].id }) {
                studentsDetails?[originalIndex].isSelect?.toggle()
                filterData?[indexPath.row].isSelect?.toggle()
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            totalcount = studentsDetails?.filter { $0.isSelect == true }.count ?? 0
            let image = totalcount == studentsDetails?.count ?? 0  ? ImageName.checkmark:ImageName.square
            isSelectAllEnabled = totalcount == studentsDetails?.count ?? 0
            selectAllBtn.setImage(image, for: .normal)
        }
    }
    
    func handleImageTap(at indexPath: IndexPath) {
        dataVisibility[indexPath.row].toggle()
        historyTable.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.lowercased()
        if query.isEmpty {
            filterData = studentsDetails
            selectAllBtn.isHidden = false
        } else {
            filterData = studentsDetails?.filter { student in
                return student.name?.lowercased().contains(query) ?? false ||
                student.roll_no?.lowercased().contains(query) ?? false ||
                student.admission_no?.lowercased().contains(query) ?? false
            }
            selectAllBtn.isHidden = true
        }
        historyTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss the keyboard
    }
    
    
    
    func gotoDashboard(){
        DispatchQueue.main.async { [self] in
            if Menu_id.staffSelectedMenuId == Menu_id.communicationMenuId{
                
                switch staff_role {
                case PriorityType.is_staff:
                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    
                case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                    
                    
                    if (staffDetailsCount?.count ?? 0) > 1 {
                        self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        
                    } else {
                        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    }
                    
                default:
                    print("Unhandled staff role")
                }
            }else{
                
                
                switch staff_role {
                case PriorityType.is_staff:
                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    
                case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                    
                    
                    if (staffDetailsCount?.count ?? 0) > 1 {
                        self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        
                    } else {
                        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    }
                    
                default:
                    print("Unhandled staff role")
                }
                
            }
        }
    }
    
    func attendaceGoBackDashBoard(){
        
        switch staff_role {
        case PriorityType.is_staff:
            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
            
        case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
            
            
            if (staffDetailsCount?.count ?? 0) > 1 {
                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                
            } else {
                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
            }
            
        default:
            print("Unhandled staff role")
        }
    }
}

