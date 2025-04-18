//
//  RecipientVc.swift
//  VsSchoolChimes
//
//  Created by admin on 31/03/25.
//

import UIKit
import DropDown

class RecipientVc: UIViewController{
    
    @IBOutlet weak var acidmicYrLbl: UILabel!
    @IBOutlet weak var stackView: UIStackView!
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
    var standard_sectionlabel : String?
    var subjectId : String?
    var AcadimicYearDatas : [AcadimicYearData] = []
    var accadimYr :[String] = []
    let acidamicdrops = DropDown()
    var  selectedAcadimicYearId: Int?
    var accadimYrIDs :[Int] = []
    var accadmicDefaultYrName : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speficBtnName.isHidden = true
        backbtnMName
            .setTitle(
                UserDefaultFileManager.get_staff_Details()?.school_name,
                for: .normal
            )
        backbtnMName.setTitleFont(style: .secondary, size: 18.0)
        
        getacadmicYr()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            configureRecipientTabs()
            
            if ScreenType == screenType.isAssaignment || ScreenType == Menu_id.homeWorkMenuId{
                segmentName.isHidden = true
                
                target_type = TargetTypes.section
                circular_types =  circular_type.section
                getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
                speficBtnName.isHidden = ScreenType == screenType.isAssaignment || ScreenType == Menu_id.homeWorkMenuId
                speficBtnName.isEnabled = !(ScreenType == screenType.isAssaignment || ScreenType == Menu_id.homeWorkMenuId)
                contentLbl.isHidden = true
                tv.isHidden = false
                selectStandardDropDown.isHidden = false

                cv_itemsarry = [
                    recipeint_tabBarName.Section_Student
                ]
            }else{
                speficBtnName.isEnabled = true
                selectStandardDropDown.isHidden = true
            }
        }
        sendbtnName.layer.cornerRadius = 10
        speficBtnName.layer.cornerRadius = 10
        applyShadowAndCornerRadius(to: selectStandardDropDown)
        applyShadowAndCornerRadius(to: selectSubject)
        applyShadowAndCornerRadius(to: acidamicYrDropView)
        selectSubject.isHidden = true
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
        
        configureRecipientTabs()
    
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
            getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            
        case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
            
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
                getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            } else {
                cv_itemsarry = [
                    recipeint_tabBarName.Entier_School,
                    recipeint_tabBarName.Standard,
                    recipeint_tabBarName.Section_Student,
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
        
        if cv_itemsarry[segmentName.selectedSegmentIndex] == recipeint_tabBarName.Entier_School{
            
        }else{
            
            guard !array_selectedId.isEmpty else {
                alert.showAlert(
                    title: AlertstringFile.Alert_title,
                    message: AlertstringFile.Choose_any_target,
                    on: self)
                return
            }
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
        let file: Any = user_inputs.selectedFileType == "pdf" ? user_inputs.docUrl : user_inputs.selectedImg
        uploadAndSendVoiceMessage(file: file) { [self] in
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
                                        self.gotoDashboard()
                                    }
                            }
                        }else {
                            
                            DispatchQueue.main.async {
                                
                                CustomAlert
                                    .showAlertWithOkAction(
                                        title: "Success",
                                        message: succesmessage.message ?? "",
                                        on: self
                                    ) {
                                        self.gotoDashboard()
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
    
    private func SendingCommunicationFlow() {
        
        var message : String?
        if accadmicDefaultYrName == acidmicYrLbl.text{
            message = AlertstringFile.Selected_target + "\(array_selectedId.count)" + "\n" + AlertstringFile.AreYouSureYouWantToProceed
        }else{
            
          message = AlertstringFile.Selected_target + "\(array_selectedId.count)" + "\n" + AlertstringFile.Change_academic_year + " " + (
                acidmicYrLbl.text ?? "") + AlertstringFile.Change_academic_year1 +   "\n" + AlertstringFile.Change_academic_year2
        }
        
        let title = AlertstringFile.Confirm_title
        
        alert.showAlertCancel(
            title: title,
            message: message ?? "",
            actionLbl1: AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: { [self] in
                switch ScreenType {
                case screenType.communication_text:
                    sendtextmessage_communication()
                case screenType.is_emergencyvoice, screenType.non_emergencyvoice:
                    
                    if user_inputs.voice_link.contains("https:") { // MARK: FORWARD VOICE
                        sendVoiceMessage_communication()
                    } else {
                        uploadAndSendVoiceMessage(file: user_inputs.voice_link) {
                            self.sendVoiceMessage_communication()
                        }
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




    @IBAction func spefic_student_actionBtn(_ sender: UIButton) {
        
        let vc = StudentHistryVC(nibName: nil, bundle: nil)
        vc.selected_sectionID = array_selectedId.first
        vc.ScreenType = ScreenType
        vc.selectedAcadimicYearId = self.selectedAcadimicYearId
        vc.standard_sectionlabel = self.standard_sectionlabel
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    @IBAction func segment_action(_ sender: UISegmentedControl) {
        array_selectedId.removeAll()
        speficBtnName.isHidden = true
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
            selectStandardDropDown.isHidden = true
            tv.isHidden = true
            
            
        case recipeint_tabBarName.Group:
            target_type = TargetTypes.group
            circular_types =  circular_type.group
            getGrouplistAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            contentLbl.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            
        case recipeint_tabBarName.Standard:
            target_type = TargetTypes.standard
            circular_types =  circular_type.standard
            getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            contentLbl.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            
        case recipeint_tabBarName.Section_Student:
            target_type = TargetTypes.section
            circular_types =  circular_type.section
            getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            
//            speficBtnName.isHidden = ScreenType == screenType.isAssaignment || ScreenType == Menu_id.homeWorkMenuId
            
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
            accadimYrIDs.append(AcadimicYearDatas[i].id ?? 0)
        }
        acidamicdrops.anchorView = acidamicYrDropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acidamicYrDropView.bounds.height)
        acidamicdrops.show()
        
        acidamicdrops.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            selectedAcadimicYearId =  AcadimicYearDatas[index].id
            
            acidmicYrLbl.text = item
            
            if cv_itemsarry[segmentName.selectedSegmentIndex] ==   recipeint_tabBarName.Standard {
            
                getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            }
            else if cv_itemsarry[segmentName.selectedSegmentIndex] ==   recipeint_tabBarName.Section_Student {
            
                getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            }
        
            else if cv_itemsarry[segmentName.selectedSegmentIndex] ==   recipeint_tabBarName.Group {
                getGrouplistAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            }
//            else if cv_itemsarry[segmentName.selectedSegmentIndex] ==   recipeint_tabBarName.Entier_School {
//    
//            }
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
        let baseCount: Int
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            baseCount = groupDetails?.count ?? 0
        case recipeint_tabBarName.Standard:
            baseCount = standardDetails?.count ?? 0
        case recipeint_tabBarName.Section_Student:
            baseCount = sectionsDetails?.count ?? 0
        case recipeint_tabBarName.Staff:
            baseCount = staffDetails?.count ?? 0
        default:
            baseCount = 0
        }
        
        return baseCount + 1 // +1 for "Select All"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.RecipientTvCell, for: indexPath) as! RecipientTvCell
        
        if indexPath.row == 0 {
            cell.cellLabel.text = "Select All"
            cell.createdOnlbl.isHidden = true
            let allSelected = isAllSelected()
            cell.checkboxImg.image = allSelected ? ImageName.checkedSquares : ImageName.uncheckedSquares
            return cell
        }
        
        let dataIndex = indexPath.row - 1
        
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            if let item = groupDetails?[dataIndex] {
                cell.cellLabel.text = item.name
                cell.createdOnlbl.isHidden = false
                cell.createdOnlbl.text =  "Created On: \(item.created_on ?? "")"
                cell.checkboxImg.image = (item.isSelect ?? false) ? ImageName.checkedSquares : ImageName.uncheckedSquares
            }
        case recipeint_tabBarName.Standard:
            if let item = standardDetails?[dataIndex] {
                cell.cellLabel.text = item.name
                cell.createdOnlbl.isHidden = true
                cell.checkboxImg.image = (item.isSelect ?? false) ? ImageName.checkedSquares : ImageName.uncheckedSquares
            }
        case recipeint_tabBarName.Section_Student:
            if let item = sectionsDetails?[dataIndex] {
                cell.cellLabel.text = item.name
                cell.createdOnlbl.isHidden = true
                cell.checkboxImg.image = (item.isSelect ?? false) ? ImageName.checkedSquares : ImageName.uncheckedSquares
            }
        case recipeint_tabBarName.Staff:
            if let item = staffDetails?[dataIndex] {
                cell.cellLabel.text = item.name
                cell.createdOnlbl.isHidden = true
                cell.checkboxImg.image = (item.isSelect ?? false) ? ImageName.checkedSquares : ImageName.uncheckedSquares
            }
        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            handleSelectAllToggle()
            tableView.reloadData()
            return
        }

        let dataIndex = indexPath.row - 1
        
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            if var item = groupDetails?[dataIndex] {
                item.isSelect?.toggle()
                groupDetails?[dataIndex].isSelect = item.isSelect
                updateSelectionArray(id: item.id, isSelected: item.isSelect)
            }
            
        case recipeint_tabBarName.Standard:
            if var item = standardDetails?[dataIndex] {
                item.isSelect?.toggle()
                standardDetails?[dataIndex].isSelect = item.isSelect
                updateSelectionArray(id: item.id, isSelected: item.isSelect)
            }
            
        case recipeint_tabBarName.Section_Student:
            if var item = sectionsDetails?[dataIndex] {
                item.isSelect?.toggle()
                sectionsDetails?[dataIndex].isSelect = item.isSelect
                updateSelectionArray(id: item.id, isSelected: item.isSelect)
                
                let selectedSections = sectionsDetails?.filter { $0.isSelect == true } ?? []
                let selectedIds = selectedSections.compactMap { $0.id }
                sectionIds = selectedIds.joined(separator: ",")
                
                if Menu_id.homeWorkMenuId == screenType.staffSelectedMenuId || Menu_id.isAssaignment == screenType.staffSelectedMenuId {
                    if let finalSectionIds = sectionIds, !finalSectionIds.isEmpty {
                        getSubjectListAPI(finalSectionIds)
                    }
                    selectSubject.isHidden = false
                }
                
                speficBtnName.isEnabled = selectedSections.count == 1
                speficBtnName.isHidden = !(selectedSections.count == 1)
            }
            
        case recipeint_tabBarName.Staff:
            if var item = staffDetails?[dataIndex] {
                item.isSelect?.toggle()
                staffDetails?[dataIndex].isSelect = item.isSelect
                updateSelectionArray(id: item.id, isSelected: item.isSelect)
            }

        default:
            break
        }

        tableView.reloadData()
    }

    // MARK: - Helper Function to update selection array
    func updateSelectionArray(id: String?, isSelected: Bool?) {
        guard let id = id else { return }
        
        if isSelected == true {
            if !array_selectedId.contains(id) {
                array_selectedId.append(id)
            }
        } else {
            array_selectedId.removeAll(where: { $0 == id })
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func isAllSelected() -> Bool {
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            return groupDetails?.allSatisfy { $0.isSelect == true } ?? false
        case recipeint_tabBarName.Standard:
            return standardDetails?.allSatisfy { $0.isSelect == true } ?? false
        case recipeint_tabBarName.Section_Student:
            return sectionsDetails?.allSatisfy { $0.isSelect == true } ?? false
        case recipeint_tabBarName.Staff:
            return staffDetails?.allSatisfy { $0.isSelect == true } ?? false
        default:
            return false
        }
    }
    
    func handleSelectAllToggle() {
        let selecting = !isAllSelected()

        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            groupDetails = groupDetails?.map {
                var item = $0
                item.isSelect = selecting
                return item
            }
            array_selectedId = selecting ? groupDetails?.compactMap { $0.id } ?? [] : []

        case recipeint_tabBarName.Standard:
            standardDetails = standardDetails?.map {
                var item = $0
                item.isSelect = selecting
                return item
            }
            array_selectedId = selecting ? standardDetails?.compactMap { $0.id } ?? [] : []

        case recipeint_tabBarName.Section_Student:
            sectionsDetails = sectionsDetails?.map {
                var item = $0
                item.isSelect = selecting
                return item
            }
            array_selectedId = selecting ? sectionsDetails?.compactMap { $0.id } ?? [] : []
            sectionIds = array_selectedId.joined(separator: ",")
            
            if Menu_id.homeWorkMenuId == screenType.staffSelectedMenuId || Menu_id.isAssaignment == screenType.staffSelectedMenuId {
                if selecting, let finalSectionIds = sectionIds, !finalSectionIds.isEmpty {
                    getSubjectListAPI(finalSectionIds)
                }
                selectSubject.isHidden = !selecting
                speficBtnName.isEnabled = selecting && array_selectedId.count == 1
                speficBtnName.isHidden = !(selecting && array_selectedId.count == 1)
            }

        case recipeint_tabBarName.Staff:
            staffDetails = staffDetails?.map {
                var item = $0
                item.isSelect = selecting
                return item
            }
            array_selectedId = selecting ? staffDetails?.compactMap { $0.id } ?? [] : []

        default:
            break
        }
    }

    
    // MARK:  This api for  Listing Stars ============================
    
    func getGrouplistAPI(academic_year_id:Int){
        APIService.shared
            .makeApi(
                url: ServiceUrl.recipient_get_group_list,
                parameters: [COMMON_PARAMETER.academic_year_id:academic_year_id],
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
                            noRecordLbl.isHidden = true
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
                            noRecordLbl.isHidden = false
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
    
    func getStandardsAPI(academic_year_id:Int){
        dropDownArray.removeAll()
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: [COMMON_PARAMETER.academic_year_id : academic_year_id], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [self] (result:Result <GetStandardsSuc,Error>) in
            switch result {
            case .success(let successMessage):
                print("successsuccess",successMessage.data)
                
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        selectSubject.isHidden = true
                        tv.isHidden = false
                        noRecordLbl.isHidden = true
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
                        selectStandardDropDown.isHidden = true
                        tv.isHidden = true
                        noRecordLbl.isHidden = false
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
                            
                            DispatchQueue.main.async {
                                self.tableHeight.constant = self.tv.contentSize.height
                                self.view.layoutIfNeeded()
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
                                        acidmicYrLbl.text = AcadimicYearDatas[i].year
                                    accadmicDefaultYrName = AcadimicYearDatas[i].year
                                        selectedAcadimicYearId = AcadimicYearDatas[i].id ?? 0
                                        break
                                }
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
        
    } // MARK:   Listing  API END ===========================
    
    
    
    
    
    
    
    
    //MARK: ALL Sending API START ===========================
    
    
    func sendtextmessage_communication(){
        APIService.shared
            .makeApi(url: ServiceUrl.comm_text_message_send_text, parameters:[
                
                send_textmessageStringFile.description : user_inputs.title,
                send_textmessageStringFile.message : user_inputs.description,
                send_textmessageStringFile.target_code: array_selectedId,
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
                                    title: "Success",
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) {
                                    self.gotoDashboard()
                                    
                                }
                            
                        }
                    }else {
                        
                        DispatchQueue.main.async {
                            self.alert
                                .showAlert(
                                    title: "Error",
                                    message: succesmessage.message ?? "" ,
                                    on: self
                                )
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
                send_voicemeassageStringFile.circular_type : circular_types ?? "",
                send_voicemeassageStringFile.academic_year_id: selectedAcadimicYearId ?? 0
                
            ] , type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "" ){ [self] (
                result : Result<CommonApiSuc,
                Error>
            ) in
                
                switch result {
                    
                case.success(let succesmessage) :
                    
                    if succesmessage.status == true {
                        
                        
                        DispatchQueue.main.async { [self] in
                            CircularProgressLoader.shared.hide()
                            
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: "Success",
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) { [self] in
                                    gotoDashboard()
                                }
                            
                        }
                    }else {
                        
                        DispatchQueue.main.async {
                            CircularProgressLoader.shared.hide()
                            self.alert
                                .showAlert(
                                    title: "Error",
                                    message: succesmessage.message ?? "" ,
                                    on: self
                                )
                            
                        }
                    }
                    
                case.failure(let error) :
                    
                    DispatchQueue.main.async {
                        CircularProgressLoader.shared.hide()
                        print(error.localizedDescription)
                    }
                }
                
            }
        
    }
    
    
    func gotoDashboard(){
        
        switch staff_role {
        case PriorityType.is_staff:
            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
           
        case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
            speficBtnName.isHidden = true
            
            if (staffDetailsCount?.count ?? 0) > 1 {
                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                
            } else {
                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
            }
            
        default:
            print("Unhandled staff role")
        }
        
        // Add segments from updated array
        
    }
}
