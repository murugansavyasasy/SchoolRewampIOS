//
//  StudentHistryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 20/11/24.
//

import UIKit
import DropDown

class StudentHistryVC: UIViewController, UISearchBarDelegate, Attendence {
    
    func statusUpdate(status: Bool,index:Int) {
        StudentDetails[index].isAbsent = status
        filterData?[index].isAbsent = status
        // Calculate the total count of present students
        totalcount = StudentDetails.filter { $0.isAbsent == true }.count
        if totalcount == 0 {
            // All students are absent
            selectAllBtn.setImage(UIImage(systemName: "checkmark.square.portrait.fill"), for: .normal)
        } else {
            // At least one student is present
            selectAllBtn.setImage(UIImage(systemName: "square"), for: .normal)
        }
    }
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var HeaderviewHeight: NSLayoutConstraint!
    @IBOutlet weak var studentCollection: UICollectionView!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var rollNoLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var categoryDropDownView: UIView!
    @IBOutlet weak var sendbtnName: UIButton!
    @IBOutlet weak var historyTable: UITableView!
    var switchCell = 1
    var dropDown = DropDown()
    
    var isSelectAllEnabled = false
    var id = 1
    var dataVisibility: [Bool] = []
    var selectedRows: [Bool] = []
    
//    var studentData:[Student] = [Student(name: "viswahSGDFHWEEAHGSVVDVFWYDSfcwgsadcdg2cwqgascdg", isAbsent: false, rollnumber: "76979871", phoneNo: "9087654321"),
//                                 Student(name: "chandhru", isAbsent: false, rollnumber: "76979871", phoneNo: "9597296160"),
//                                 Student(name: "kothai", isAbsent: false, rollnumber: "76979872", phoneNo: "9360183031"),
//                                 Student(name: "shiyam", isAbsent: false, rollnumber: "76979873", phoneNo: "98762356335"),
//                                 Student(name: "Navin", isAbsent: false, rollnumber: "76979874", phoneNo: "7456792347"),
//                                 Student(name: "Nicolash", isAbsent: false, rollnumber: "76979875", phoneNo: "9835546472"),
//                                 Student(name: "sharmila", isAbsent: false, rollnumber: "76979876", phoneNo: "89873456543"),
//                                 Student(name: "sharmila", isAbsent: false, rollnumber: "76979877", phoneNo: "89873456543"),
//                                 Student(name: "Navin", isAbsent: false, rollnumber: "76979878", phoneNo: "7456792347"),
//                                 Student(name: "kothai", isAbsent: false, rollnumber: "76979879", phoneNo: "9360183031"),
//                                 Student(name: "kothai", isAbsent: false, rollnumber: "769798710", phoneNo: "9360183031")]
//    
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.setTitle(standard_sectionlabel, for: .normal)
        sendbtnName.layer.cornerRadius = 10
        target_type = TargetTypes.student
        circular_types =  circular_type.student
        StyleAndTranslater()
        BackBtn.applyBackButton()
        
        
        
        if id == 1{
            HeaderviewHeight.constant = 0
            headerView.isHidden = true
        }
        
        registerCell()
        recipient_get_student_list(
            selected_sectionId: selected_sectionID ?? "",
            academic_year_id: selectedAcadimicYearId ?? 0
        )
        search.delegate = self
        headerView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        let categoryGesture = UITapGestureRecognizer(target: self, action: #selector(fliter))
        categoryDropDownView.addGestureRecognizer(categoryGesture)
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    func StyleAndTranslater() {
        
        //MARK: Label And Button Font Style
        HeaderLabel.setFont(style: .header, size: FontSize.HeaderSize)
        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        rollNoLbl.setFont(style: .title, size: FontSize.TitleSize)
        statusLbl.setFont(style: .title, size: FontSize.TitleSize)
        filterBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Translation
        rollNoLbl.text = CommonStringFile.RollNo.translated()
        nameLbl.text = CommonStringFile.Name.translated()
        statusLbl.text = CommonStringFile.Status.translated()
        HeaderLabel.text = CommonStringFile.Section.translated()
        search.placeholder = CommonStringFile.Search.translated()
        filterBtn.setTitle(CommonStringFile.Filter, for: .normal)
        
    }
    
    func registerCell(){
        historyTable.register(UINib(nibName: CellConfingName.SpecificStudentTvcell, bundle: nil), forCellReuseIdentifier: CellConfingName.SpecificStudentTvcell)
        historyTable.register(UINib(nibName: CellConfingName.AttendenceTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AttendenceTVC)
        historyTable.register(UINib(nibName: CellConfingName.StudentHistryTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.StudentHistryTVC)
        historyTable.register(UINib(nibName: CellConfingName.MarkAtendenceTV, bundle: nil), forCellReuseIdentifier: CellConfingName.MarkAtendenceTV)
        
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
                let sortedByRollNumber = studentData.sorted { $0.rollnumber < $1.rollnumber }
                filterData = sortedByRollNumber
            case CommonStringFile.RollNoDESC:
                let sortedByName = studentData.sorted { $0.rollnumber > $1.rollnumber }
                filterData = sortedByName
            case CommonStringFile.NameASC:
                let sortedByName = studentData.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
                filterData = sortedByName
            case CommonStringFile.NameDESC:
                let sortedByName = studentData.sorted { $0.name > $1.name }
                filterData = sortedByName
            case CommonStringFile.Absent:
                
                filterData = studentData.sorted {
                    !$0.isAbsent && $1.isAbsent
                }
            case CommonStringFile.Present:
                filterData = studentData.sorted {
                    $0.isAbsent && !$1.isAbsent // Absent students first
                }
            default:
                filterData = studentData
                
            }
            historyTable.reloadData()
            // Update the label inside the UIView
            if let label = self.categoryDropDownView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self.filterBtn.setTitle(item.translated(), for: .normal)
            }
        }
        
    }
    
    @IBAction func selectAllStd(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        // Update data model to mark all students as present/absent
        let isSelectingAll = sender.isSelected
        if id == 2{
            for i in 0..<studentData.count {
                studentData[i].isAbsent = !isSelectingAll // If selecting all, students are not absent
                filterData?[i].isAbsent = !isSelectingAll
                
                // Properly access the cell using indexPath, not historyTable.cell
                let indexPath = IndexPath(row: i, section: 0)
                if let customCell = historyTable.cellForRow(at: indexPath) as? AttendenceTVC {
                    customCell.custSwitch.isOn = isSelectingAll
                    customCell.hideLbl(isAbsent: isSelectingAll)
                }
                
            }
        }
        else{
            isSelectAllEnabled.toggle()
            for i in 0..<(studentsDetails?.count ?? 0) {
                let indexPath = IndexPath(row: i, section: 0)
                if let customCell = historyTable.cellForRow(at: indexPath) as? SpecificStudentTvcell {
                    if isSelectAllEnabled {
                        
                        customCell.CheckBoxImgview.image = ImageName.checkedSquares
                        selected_student.append(studentsDetails?[i].id ?? "" )
                    } else {
                        customCell.CheckBoxImgview.image = ImageName.uncheckedSquares
                        selected_student.removeAll()
                    }
                }
                
                // Update `selectedRows` to match the state
                selectedRows[i] = isSelectAllEnabled
            }
        }
        // Update select all button image and total count
        if isSelectingAll {
            selectAllBtn.setImage(ImageName.checkmark, for: .normal)
            totalcount = studentData.count
        } else {
            selectAllBtn.setImage(ImageName.square, for: .normal)
            totalcount = 0
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
                            filterData = studentsDetails
                            if var students = studentsDetails {
                                for i in students.indices {
                                    students[i].isSelect = false
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
                            historyTable.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            historyTable.isHidden = true
                            //                        noRecordLbl.text = successMessage.message
                        }
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
    }
    
    
    
    @IBAction func sendBtnAction(_ sender: UIButton) {
        
        guard !selected_student.isEmpty else {
            alert.showAlert(
                title: AlertstringFile.Alert_title,
                message: AlertstringFile.Choose_any_target,
                on: self
            )
            return
        }
        
        switch Menu_id.staffSelectedMenuId{
        case Menu_id.communicationMenuId:
            SendingCommunicationFlow()
            
        case Menu_id.homeWorkMenuId:
            handleHomeworkFlow()
            
        default:
            print("❗️Unhandled menu ID: \(Menu_id.staffSelectedMenuId)")
        }
    }
    
    
    
    private func handleHomeworkFlow() {
        
        
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
    
    func sendtextmessage_communication(){
        
        APIService.shared
            .makeApi(url: ServiceUrl.comm_text_message_send_text, parameters:[
                
                send_textmessageStringFile.description : user_inputs.title,
                send_textmessageStringFile.message : user_inputs.description,
                send_textmessageStringFile.target_code: selected_student,
                send_textmessageStringFile.target_type: target_type ?? 0,
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
    
    
}

extension StudentHistryVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if id == 2{
            return studentsDetails?.count ?? 0
        }else{
            return studentsDetails?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if id == 1{
            let cell = historyTable.dequeueReusableCell(withIdentifier: CellConfingName.SpecificStudentTvcell, for: indexPath) as! SpecificStudentTvcell
            let backgroundColor = colorForName(
                studentsDetails?[indexPath.row].name ?? ""
            )
            
            cell.NameLbl.text =  studentsDetails?[indexPath.row].name ?? ""
            cell.AdmisionNoLbl.text = studentsDetails?[indexPath.row].admission_no ?? ""
            cell.RollNoLbl.text = studentsDetails?[indexPath.row].roll_no ?? ""
            if let firstChar =  studentsDetails?[indexPath.row].name?.first {
                cell.alphabetLbl.text = String(firstChar)
            } else {
                cell.alphabetLbl.text = "" // Fallback for empty string
            }
            cell.AlphabetView.backgroundColor = backgroundColor
            cell.DropdownImg.image = dataVisibility[indexPath.row] ? UIImage(named: "arrow_up") : UIImage(named: "arrow_down")
            
            if let select = studentsDetails?[indexPath.row].isSelect {
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
        else{
            if switchCell == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.StudentHistryTVC, for: indexPath) as! StudentHistryTVC
                cell.nameLbl.text = filterData?[indexPath.row].name
                cell.AdmisNomber.text = filterData?[indexPath.row].phoneNo
                cell.rollNomber.text = filterData?[indexPath.row].rollnumber
                let img = filterData?[indexPath.row].isAbsent  ?? false ? ImageName.apsent : ImageName.present
                cell.statusBtn.setImage(img, for: .normal)
                cell.outerView.layer.borderColor = filterData?[indexPath.row].isAbsent ?? false ? UIColor.red.cgColor : Colornames.AprovedClr?.cgColor
                cell.outerView.layer.borderWidth = 1
                
                return cell
            }else if switchCell == 1{
                let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.AttendenceTVC, for: indexPath) as! AttendenceTVC
                cell.nameLbl.text = filterData?[indexPath.row].name
                cell.rollNo.setTitle(filterData?[indexPath.row].rollnumber, for: .normal)
                cell.hideLbl(isAbsent: filterData?[indexPath.row].isAbsent ?? true)
                cell.custSwitch.isOn = filterData?[indexPath.row].isAbsent ?? true
                cell.phnBtn.tag = indexPath.row
                cell.phnBtn.setTitle(filterData?[indexPath.row].phoneNo, for: .normal)
                cell.custSwitch.index = indexPath.row
                cell.delegate = self
                return cell
            }else{
                
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: CellConfingName.MarkAtendenceTV,
                    for: indexPath
                ) as! MarkAtendenceTV
                cell.nameLbl.text = filterData?[indexPath.row].name
                cell.addmisionLbl.text = filterData?[indexPath.row].phoneNo
                cell.rollNoLbl.text = filterData?[indexPath.row].rollnumber
                let img = filterData?[indexPath.row].isAbsent  ?? false ? ImageName.apsent : ImageName.present
                cell.btnView.backgroundColor = filterData?[indexPath.row].isAbsent  ?? false ? UIColor.red : Colornames.AprovedClr
                let name = filterData?[indexPath.row].isAbsent  ?? false ? "Absent" : "Present"
                cell.btnView.layer.cornerRadius = 20
                
                cell.stsBtn.setTitle(name, for: .normal)
                return cell
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if id == 2{
            let cell = tableView.cellForRow(at: indexPath) as? StudentHistryTVC
            guard let cell = cell else { return }
            if studentData[indexPath.row].isAbsent == true{
                // Create the flip animation
                UIView.transition(with: cell.outerView,
                                  duration: 0.3,
                                  options: [.transitionFlipFromTop],  // Change direction as needed
                                  animations: {
                    // Change background color to red
                    cell.outerView.layer.borderColor = Colornames.AprovedClr?.cgColor
                    cell.outerView.layer.borderWidth = 1
                    self.studentData[indexPath.row].isAbsent = false
                    cell.statusBtn.setImage(ImageName.present, for: .normal)
                },
                                  completion: nil)
                totalcount += 1
            }else{
                UIView.transition(with: cell.outerView,
                                  duration: 0.3,
                                  options: [.transitionFlipFromBottom],  // Change direction as needed
                                  animations: {
                    // Change background color to red
                    cell.outerView.layer.borderColor = UIColor.red.cgColor
                    cell.statusBtn.setImage(ImageName.apsent, for: .normal)
                    self.studentData[indexPath.row].isAbsent = true
                },
                                  completion: nil)
                totalcount -= 1
            }
            
        }
        
        else{
            // Toggle the state
            selectedRows[indexPath.row] = !selectedRows[indexPath.row]
            
            if let id = studentsDetails?[indexPath.row].id {
                if studentsDetails?[indexPath.row].isSelect == true {
                    if !selected_student.contains(id) {
                        selected_student.append(id)
                    }
                } else {
                    selected_student.removeAll(where: { $0 == id })
                }
            }
            if indexPath.row < (studentsDetails?.count ?? 0) {
                studentsDetails?[indexPath.row].isSelect?.toggle()
                
                if let id = studentsDetails?[indexPath.row].id {
                    if studentsDetails?[indexPath.row].isSelect == true {
                        if !selected_student.contains(id) {
                            selected_student.append(id)
                        }
                    } else {
                        selected_student.removeAll(where: { $0 == id })
                    }
                }
            }
            
            // Reload the specific row to update the checkbox image
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func handleImageTap(at indexPath: IndexPath) {
        dataVisibility[indexPath.row].toggle() // Toggle the visibility state
        
        // Reload the specific row
        historyTable.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Reset to full data when the search text is cleared
            filterData = studentData
        } else {
            // Filter data based on the search text
            filterData = studentData.filter { student in
                student.name.lowercased().contains(searchText.lowercased())
            }
        }
        historyTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss the keyboard
    }
    
    
    
    func gotoDashboard(){
        
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
        
        // Add segments from updated array
        
    }
}

struct Student {
    var name: String
    var isAbsent: Bool
    var rollnumber:String
    var phoneNo:String
}
struct SpecificStudent{
    
    var name : String
    var rollnumber : String
    var admissionNo : String
}
