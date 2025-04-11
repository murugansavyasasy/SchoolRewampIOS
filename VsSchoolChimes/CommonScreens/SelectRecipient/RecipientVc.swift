//
//  RecipientVc.swift
//  VsSchoolChimes
//
//  Created by admin on 31/03/25.
//

import UIKit
import DropDown

class RecipientVc: UIViewController{
    
    @IBOutlet weak var backbtnMName: UIButton!
    @IBOutlet weak var drpodonLbl: UILabel!
    @IBOutlet weak var segmentName: UISegmentedControl!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var speficBtnName: UIButton!
    @IBOutlet weak var sendbtnName: UIButton!
    @IBOutlet weak var selectStandardDropDown: UIView!
    @IBOutlet weak var selectSubject: UIView!
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var acidamicYrDropView: UIView!
    
    var cv_itemsarry : [String] = []
    var dropDownArray = [String]()
    var subjectList = [String]()
    var uploadedURLs: [String] = []
    var subjectDetails: [GetSubjectDetails]?
    var studentsDetails: [StudentDetails]?
    var sectionsDetails: [sectionsDetail]?
    var standardDetails: [StandardDetail]?
    var staffDetails: [GetStaffDetails]?
    var groupDetails: [GroupDetail]?
    var lastSelectedButton: UIButton?
    let dropDown = DropDown()
    let StdDropdown = DropDown()
    var selectedId : IndexPath?
    var sectionId:Int?
    var ScreenType:Int?
    var sectionIds:String?
    let staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var segment_selected_index:Int?
    var array_selectedId : [String] = []
    var communicatio_textDetails :[String] = []
    var requestCommonDataDetails : [String:Any] = [:]
    var target_type : Int?
    let alert = CustomAlert()
    var circular_types : String?
    var subjectId : String?
    var AcadimicYearDatas : [AcadimicYearData] = []
    var accadimYr :[String] = []
    let acidamicdrops = DropDown()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backbtnMName
            .setTitle(
                UserDefaultFileManager.get_staff_Details()?.school_name,
                for: .normal
            )
        
        configureRecipientTabs()
        getacadmicYr()
        
        if ScreenType == screenType.isAssaignment || ScreenType == Menu_id.homeWorkMenuId{
            segmentName.isHidden = true
            speficBtnName.isHidden = true
            target_type = TargetTypes.section
            circular_types =  circular_type.section
            getStandardsAPI()
            speficBtnName.isHidden = ScreenType == screenType.isAssaignment || ScreenType == Menu_id.homeWorkMenuId
            speficBtnName.isEnabled = !(ScreenType == screenType.isAssaignment || ScreenType == Menu_id.homeWorkMenuId)
            contentLbl.isHidden = true
            tv.isHidden = false
            selectStandardDropDown.isHidden = false
            segment_selected_index = 1
        }else{
            speficBtnName.isEnabled = false
            selectStandardDropDown.isHidden = true
        }
        sendbtnName.layer.cornerRadius = 10
        speficBtnName.layer.cornerRadius = 10
        
        
        applyShadowAndCornerRadius(to: selectStandardDropDown)
        applyShadowAndCornerRadius(to: selectSubject)
        applyShadowAndCornerRadius(to: acidamicYrDropView)
        selectSubject.isHidden = true
        speficBtnName.backgroundColor = UIColor.gray
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(selectStd))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(selectedSubject))
        let acidmaciyrClick = UITapGestureRecognizer(target: self, action:
                                                        #selector(academicYearDrop_action))
        selectStandardDropDown.addGestureRecognizer(tap2)
        selectSubject.addGestureRecognizer(tap3)
        acidamicYrDropView.addGestureRecognizer(acidmaciyrClick)
        
        
        let nib = UINib(nibName: CellConfingName.RecipientTvCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.RecipientTvCell)
        
        tv.register(UINib(nibName:CellConfingName.Std_Grp_header, bundle: nil),forHeaderFooterViewReuseIdentifier: CellConfingName.Std_Grp_header)
        
        tv.delegate = self
        tv.dataSource = self
    }
    
    
    func configureRecipientTabs() {
        segmentName.removeAllSegments()
        cv_itemsarry.removeAll()
        
        switch staff_role {
        case PriorityType.is_staff:
            contentLbl.isHidden = true
            cv_itemsarry = [
                recipeint_tabBarName.Standard,
                recipeint_tabBarName.Section_Student,
                recipeint_tabBarName.Group
            ]
            target_type = TargetTypes.standard
            circular_types =  circular_type.standard
            getStandardsAPI()
            
        case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
            speficBtnName.isHidden = true
            
            if (staffDetailsCount?.count ?? 0) > 1 {
                contentLbl.isHidden = true
                cv_itemsarry = [
                    recipeint_tabBarName.Standard,
                    recipeint_tabBarName.Section_Student,
                    recipeint_tabBarName.Group,
                    recipeint_tabBarName.Staff
                ]
                target_type = TargetTypes.standard
                circular_types =  circular_type.standard
                getStandardsAPI()
            } else {
                cv_itemsarry = [
                    recipeint_tabBarName.Entier_School,
                    recipeint_tabBarName.Standard,
                    recipeint_tabBarName.Group,
                    recipeint_tabBarName.Staff
                ]
                tableHeight.constant = 0
            }
            
        default:
            print("Unhandled staff role")
        }
        
        // Add segments from updated array
        for (index, title) in cv_itemsarry.enumerated() {
            segmentName.insertSegment(withTitle: title, at: index, animated: false)
        }
        
        segmentName.selectedSegmentIndex = 0
    }
    
    
    func applyShadowAndCornerRadius(to view: UIView, cornerRadius: CGFloat = 10, shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 4, height: 4), shadowOpacity: Float = 0.5, shadowRadius: CGFloat = 4, backgroundColor: UIColor = .white) {
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowRadius = shadowRadius
        view.backgroundColor = backgroundColor
    }
    
    
    @IBAction func backbtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func send(_ sender: UIButton) {
        print("selectedId : \(array_selectedId)")
        guard !array_selectedId.isEmpty else {
            alert.showAlert(
                title: AlertstringFile.Alert_title,
                message: AlertstringFile.Choose_any_target,
                on: self)
            return
        }
        switch screenType.staffSelectedMenuId {
        case Menu_id.communicationMenuId:
            SendingCommunicationFlow()
        case Menu_id.homeWorkMenuId:
            handleHomeworkFlow()
        default:
            print("Unhandled menu ID: \(screenType.staffSelectedMenuId)")
        }
    }
    
    private func handleHomeworkFlow() {
        uploadAndSendVoiceMessage(file: user_inputs.selectedImg) { [self] in
            CircularProgressLoader.shared.hide()
            let uploadedFiles: [[String: String]] = uploadedURLs.compactMap { url in
                return [
                    "path": url,
                    "type": user_inputs.selectedFileType
                ]
            }
            let parameters: [String: Any] = [
                UploadMessageKeys.topic: user_inputs.title,
                UploadMessageKeys.text: user_inputs.description,
                UploadMessageKeys.sectionCode: array_selectedId,
                UploadMessageKeys.subjectId: subjectId ?? "",
                UploadMessageKeys.filePath:uploadedFiles
            ]

            APIService.shared
                .makeApi(url: ServiceUrl.comm_homework_sendhomework, parameters: parameters, type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "" ){ [self] (
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
    
    private func SendingCommunicationFlow() {
        let message = AlertstringFile.AreYouSureYouWantToProceed + "\(array_selectedId.count)"
        let title = AlertstringFile.Alert_title
        
        alert.showAlertCancel(
            title: title,
            message: message,
            actionLbl1: AlertstringFile.OK,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: { [self] in
                switch ScreenType {
                case screenType.communication_text:
                    sendtextmessage_communication()
                case screenType.is_emergencyvoice, screenType.non_emergencyvoice:
                    uploadAndSendVoiceMessage(file: user_inputs.voice_link) {
                        CircularProgressLoader.shared.hide()
                        self.sendVoiceMessage_communication()
                    }
                default:
                    print("Unhandled communication screen type: \(ScreenType)")
                }
            },
            onNo: {
                print("User canceled.")
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

            AWSUploadManager.shared.uploadFileToAWS(
                file: audioURL,
                bucketPath: "uploads/audio/",
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

        default:
            print("❌ Unsupported file type")
            return
        }
    }




    @IBAction func spefic_student_actionBtn(_ sender: UIButton) {
        
        let vc = StudentHistryVC(nibName: nil, bundle: nil)
        vc.selected_sectionID = array_selectedId.first
        vc.ScreenType = ScreenType
        //        vc.standard_sectionlabel =
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    @IBAction func segment_action(_ sender: UISegmentedControl) {
        array_selectedId.removeAll()
        segment_selected_index = sender.selectedSegmentIndex
        guard segment_selected_index ?? 0 >= 0, segment_selected_index ?? 0 < cv_itemsarry.count else {
            print("Invalid segment index.")
            return
        }
        let selectedTitle = cv_itemsarry[segment_selected_index ?? 0]
        
        switch selectedTitle {
            
        case recipeint_tabBarName.Entier_School:
            target_type = TargetTypes.school
            circular_types =  circular_type.school
            contentLbl.isHidden = false
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = true
            
        case recipeint_tabBarName.Group:
            target_type = TargetTypes.group
            circular_types =  circular_type.group
            getGrouplistAPI()
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            
        case recipeint_tabBarName.Standard:
            target_type = TargetTypes.standard
            circular_types =  circular_type.standard
            getStandardsAPI()
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            
        case recipeint_tabBarName.Section_Student:
            target_type = TargetTypes.section
            circular_types =  circular_type.section
            getStandardsAPI()
            speficBtnName.isHidden = ScreenType == screenType.isAssaignment || ScreenType == Menu_id.homeWorkMenuId
            speficBtnName.isEnabled = !(ScreenType == screenType.isAssaignment || ScreenType == Menu_id.homeWorkMenuId)
            contentLbl.isHidden = true
            tv.isHidden = false
            selectStandardDropDown.isHidden = false
            
        case recipeint_tabBarName.Staff:
            target_type = TargetTypes.staff
            circular_types =  circular_type.staff
            getStaffListAPI()
            contentLbl.isHidden = true
            tv.isHidden = false
            selectStandardDropDown.isHidden = true
            
        default:
            print("Unhandled tab selection: \(selectedTitle)")
        }
        
    }
    
    @IBAction func selectStd(){
        setupStdDropdown ()
    }
    @IBAction func selectedSubject(){
        setupSubjectDropdown ()
    }
    
    func setupStdDropdown() {
        StdDropdown.anchorView = selectStandardDropDown
        StdDropdown.dataSource = dropDownArray
        StdDropdown.bottomOffset = CGPoint(x: 0, y: selectStandardDropDown.bounds.height)
        StdDropdown.show()
        
        StdDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.sectionsDetails = self.standardDetails?.first(where: { $0.name == item })?.sections
            if let label = self.selectStandardDropDown.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
            }
            self.tv.isHidden = false
            self.tv.reloadData()
            DispatchQueue.main.async {
                self.tableHeight.constant = self.tv.contentSize.height
                self.view.layoutIfNeeded()
            }
        }
    }
    func setupSubjectDropdown() {
        StdDropdown.anchorView = selectSubject
        StdDropdown.dataSource = subjectList
        StdDropdown.bottomOffset = CGPoint(x: 0, y: selectSubject.bounds.height)
        StdDropdown.direction = .bottom
        StdDropdown.show()
        
        StdDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            if let label = self.selectSubject.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
                subjectId = subjectDetails?[index].id ?? ""
                speficBtnName.isHidden = true
            }
        }
    }
    
    @IBAction func academicYearDrop_action() {
        accadimYr.removeAll()
        for i in 0..<(AcadimicYearDatas.count) {
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
}


extension RecipientVc: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Std_Grp_header") as! Std_Grp_header
        
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            head.HeaderLabel.text = recipeint_tabBarName.Group
        case recipeint_tabBarName.Standard:
            head.HeaderLabel.text = recipeint_tabBarName.Standard
        case recipeint_tabBarName.Section_Student:
            head.HeaderLabel.text = recipeint_tabBarName.Section_Student
        case recipeint_tabBarName.Staff:
            head.HeaderLabel.text = recipeint_tabBarName.Staff
        default:
            head.HeaderLabel.text = ""
        }
        return head
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            return groupDetails?.count ?? 0
        case recipeint_tabBarName.Standard:
            return standardDetails?.count ?? 0
        case recipeint_tabBarName.Section_Student:
            return sectionsDetails?.count ?? 0
        case recipeint_tabBarName.Staff:
            return staffDetails?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.RecipientTvCell, for: indexPath) as! RecipientTvCell
        
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            cell.checkboxImg.isUserInteractionEnabled = true
            cell.cellLabel.text = groupDetails?[indexPath.row].name
            if let select = groupDetails?[indexPath.row].isSelect {
                cell.checkboxImg.image = select ? ImageName.checkedSquares :
                ImageName.uncheckedSquares
            }
            
        case recipeint_tabBarName.Standard:
            cell.cellLabel.text = standardDetails?[indexPath.row].name
            if let select = standardDetails?[indexPath.row].isSelect {
                cell.checkboxImg.image = select ? ImageName.checkedSquares :
                ImageName.uncheckedSquares
            }
        case recipeint_tabBarName.Section_Student:
            cell.cellLabel.text = sectionsDetails?[indexPath.row].name
            if let select = sectionsDetails?[indexPath.row].isSelect {
                cell.checkboxImg.image = select ? ImageName.checkedSquares :
                ImageName.uncheckedSquares
            }
            
        case recipeint_tabBarName.Staff:
            cell.cellLabel.text = staffDetails?[indexPath.row].name
            if let select = staffDetails?[indexPath.row].isSelect {
                cell.checkboxImg.image = select ? ImageName.checkedSquares :
                ImageName.uncheckedSquares
            }
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            if indexPath.row < (groupDetails?.count ?? 0) {
                groupDetails?[indexPath.row].isSelect?.toggle()
                
                if let id =  groupDetails?[indexPath.row].id {
                    if  groupDetails?[indexPath.row].isSelect == true {
                        if !array_selectedId.contains(id) {
                            array_selectedId.append(id)
                        }
                    } else {
                        array_selectedId.removeAll(where: { $0 == id})
                    }
                }
            }
        case recipeint_tabBarName.Standard:
            if indexPath.row < (standardDetails?.count ?? 0) {
                standardDetails?[indexPath.row].isSelect?.toggle()
                
                if let id = standardDetails?[indexPath.row].id {
                    if standardDetails?[indexPath.row].isSelect == true {
                        if !array_selectedId.contains(id) {
                            array_selectedId.append(id)
                        }
                    } else {
                        array_selectedId.removeAll(where: { $0 == id })
                    }
                }
            }
        case recipeint_tabBarName.Section_Student:
            if indexPath.row < (sectionsDetails?.count ?? 0) {
                guard var section = sectionsDetails?[indexPath.row] else { return }
                
                section.isSelect?.toggle()
                sectionsDetails?[indexPath.row].isSelect = section.isSelect
                if let id = section.id {
                    if section.isSelect == true {
                        if !array_selectedId.contains(id) {
                            array_selectedId.append(id)
                        }
                    } else {
                        array_selectedId.removeAll(where: { $0 == id })
                    }
                }
                let selectedSections = sectionsDetails?.filter { $0.isSelect == true } ?? []
                let selectedIds = selectedSections.compactMap { $0.id }
                sectionIds = selectedIds.joined(separator: ",")

                if let finalSectionIds = sectionIds, !finalSectionIds.isEmpty {
                    getSubjectListAPI(finalSectionIds)
                }
                selectSubject.isHidden = false
                speficBtnName.isEnabled = selectedSections.count == 1
                speficBtnName.backgroundColor = selectedSections.count == 1 ? .button : .gray

            }
            
        case recipeint_tabBarName.Staff:
            if indexPath.row < (staffDetails?.count ?? 0) {
                staffDetails?[indexPath.row].isSelect?.toggle()
                
                if let id = staffDetails?[indexPath.row].id {
                    if staffDetails?[indexPath.row].isSelect == true {
                        if !array_selectedId.contains(id) {
                            array_selectedId.append(id)
                        }
                    } else {
                        array_selectedId.removeAll(where: { $0 == id })
                    }
                }
            }
        default:
            break
        }
        tv.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK:  This api for  Listing Stars ============================
    
    func getGrouplistAPI(){
        APIService.shared
            .makeApi(
                url: ServiceUrl.recipient_get_group_list,
                parameters: [:],
                type: ApitTypeSringFile.GET ,
                token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
            ) {
                [self] (result: Result<GrouplistSuc,Error>) in
                switch result {
                case .success(let successmessage):
                    
                    if successmessage.status == true{
                        
                        DispatchQueue.main.async {[self] in
                            selectSubject.isHidden = true
                            tv.isHidden = false
                            groupDetails = successmessage.data
                            if var students = groupDetails {
                                for i in students.indices {
                                    students[i].isSelect = false
                                }
                                groupDetails = students
                            }
                            
                            tv.reloadData()
                            DispatchQueue.main.async {
                                self.tableHeight.constant = self.tv.contentSize.height
                                self.view.layoutIfNeeded()
                            }
                            
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            tv.isHidden = true
                            noRecordLbl.text = successmessage.message
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
            }
    }
    
    func getStandardsAPI(){
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [self] (result:Result <GetStandardsSuc,Error>) in
            switch result {
            case .success(let successMessage):
                print("successsuccess",successMessage.data)
                
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        selectSubject.isHidden = true
                        tv.isHidden = false
                        standardDetails = successMessage.data
                        standardDetails?.enumerated().forEach { index, student in
                            standardDetails?[index].isSelect = false
                            dropDownArray.append(student.name ?? "")
                            
                            if let sections = student.sections {
                                for j in 0..<sections.count {
                                    standardDetails?[index].sections?[j].isSelect = false
                                }
                            }
                        }
                        drpodonLbl.text = standardDetails?.first?.name
                        sectionsDetails = standardDetails?.first?.sections // Assign sections directly
                        tv.reloadData()
                        DispatchQueue.main.async {
                            self.tableHeight.constant = self.tv.contentSize.height
                            self.view.layoutIfNeeded()
                        }
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        
                        tv.isHidden = true
                        noRecordLbl.text = successMessage.message
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    func getStaffListAPI(){
        APIService.shared
            .makeApi(url: ServiceUrl.recipient_get_staff_list, parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <GetStafflistSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            tv.isHidden = false
                            staffDetails = successMessage.data
                            if var students = staffDetails {
                                for i in students.indices {
                                    students[i].isSelect = false
                                }
                                staffDetails = students
                            }
                            tv.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            selectSubject.isHidden = true
                            tv.isHidden = true
                            noRecordLbl.text = successMessage.message
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
    }
    func getSubjectListAPI(_ id:String){
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_subject_list , parameters: ["section_ids": id], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (result:Result <GetSubjectlistSuc,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        tv.isHidden = false
                        subjectDetails = successMessage.data
                        subjectDetails?.enumerated().forEach { index, student in
                            subjectList.append(student.name ?? "")
                        }
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        selectSubject.isHidden = true
                        tv.isHidden = true
                        noRecordLbl.text = successMessage.message
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
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
                      
//                        listTable.isHidden = true
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    } // MARK:   Listing  API END ===========================
    
    
    
   
    
    
    
    
    //MARK: ALL Sending API START ===========================
    
    
    func sendtextmessage_communication(){
        
        
        
        
        APIService.shared
            .makeApi(url: ServiceUrl.comm_text_message_send_text, parameters:[
                
                send_textmessageStringFile.description : user_inputs.title,
                send_textmessageStringFile.message : user_inputs.description,
                send_textmessageStringFile.target_code: array_selectedId,
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
                send_voicemeassageStringFile.target_code : array_selectedId,
                send_voicemeassageStringFile.duration : user_inputs.duration,
                send_voicemeassageStringFile.description : user_inputs.description,
                send_voicemeassageStringFile.is_emergency : user_inputs.is_emergency,
                send_voicemeassageStringFile.is_schedule : user_inputs.is_schedule,
                send_voicemeassageStringFile.schedule_date : user_inputs.schedule_date,
                send_voicemeassageStringFile.start_time : user_inputs.start_time,
                send_voicemeassageStringFile.end_time :user_inputs.end_time,
                send_voicemeassageStringFile.file_name : user_inputs.file_name,
                send_voicemeassageStringFile.circular_type : circular_types ?? ""
                
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
