//
//  RecipientVc.swift
//  VsSchoolChimes
//
//  Created by admin on 31/03/25.
//

import UIKit
import DropDown

class RecipientVc: UIViewController{
    
    @IBOutlet weak var chooseDefaultLbl: UILabel!
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
    
    @IBOutlet weak var heightSegment: NSLayoutConstraint!
    @IBOutlet weak var nodataFound: UIImageView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var spaceView: UIView!
    @IBOutlet weak var getSubject: UIButton!
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
    var accadimYr :[String] = []
    let acidamicdrops = DropDown()
    var  selectedAcadimicYearId: Int?
    var accadimYrIDs :[Int] = []
    var accadmicDefaultYrName : String?
    var accedmicYrEligible = false
    let YOUR_VIMEO_TOKEN = "8d74d8bf6b5742d39971cc7d3ffbb51a"
    var vimeoUploader: VimeoUploader?
    var Common_request_params: [String:Any] = [:]
    var sectionName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        nodataFound.isHidden = true
        noRecordLbl.isHidden = true
        speficBtnName.isHidden = true
        tv.isHidden = true
        backbtnMName
            .setTitle(
                UserDefaultFileManager.get_staff_Details()?.school_name,
                for: .normal)
        backbtnMName.setTitleFont(style: .secondary, size: 18.0)
        
        getacadmicYr()
        
        let nib = UINib(nibName: CellConfingName.RecipientTvCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.RecipientTvCell)
        tv.register(UINib(nibName:CellConfingName.Std_Grp_header, bundle: nil),forHeaderFooterViewReuseIdentifier: CellConfingName.Std_Grp_header)
        
        
        sendbtnName.layer.cornerRadius = 10
        speficBtnName.layer.cornerRadius = 10
        getSubject.layer.cornerRadius = 10
        applyShadowAndCornerRadius(to: selectStandardDropDown)
        applyShadowAndCornerRadius(to: selectSubject)
        applyShadowAndCornerRadius(to: getSubject)
        applyShadowAndCornerRadius(to: acidamicYrDropView)
        selectSubject.isHidden = true
        spaceView.isHidden = false
        getSubject.isHidden = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(selectStd))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(selectedSubject))
        let acidmaciyrClick = UITapGestureRecognizer(target: self, action:
                                                        #selector(academicYearDrop_action))
        selectStandardDropDown.addGestureRecognizer(tap2)
        selectSubject.addGestureRecognizer(tap3)
        acidamicYrDropView.addGestureRecognizer(acidmaciyrClick)
        tv.delegate = self
        tv.dataSource = self
        configureRecipientTabs()
        
    }
    
    
    func configureRecipientTabs() {
        segmentName.removeAllSegments()
        cv_itemsarry.removeAll()
        segmentName
            .setTitleTextAttributes(
                [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.black
                ],
                for: .normal
            )
        switch staff_role {
        case PriorityType.is_staff:
            cv_itemsarry = [
                recipeint_tabBarName.Standard,
                recipeint_tabBarName.Section_Student,
                recipeint_tabBarName.Group
            ]
            target_type = TargetTypes.standard
            circular_types =  circular_type.standard
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            }
        case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
            if Menu_id.event == Menu_id.staffSelectedMenuId {
                cv_itemsarry = [
                    recipeint_tabBarName.Entier_School,
                    recipeint_tabBarName.Standard,
                    recipeint_tabBarName.Group
                ]
            }else{
                cv_itemsarry = [
                    recipeint_tabBarName.Entier_School,
                    recipeint_tabBarName.Standard,
                    recipeint_tabBarName.Section_Student,
                    recipeint_tabBarName.Group,
                    recipeint_tabBarName.Staff
                ]
            }
            circular_types = circular_type.school
            target_type = TargetTypes.school
            noRecordLbl.text = CommonStringFile.Tap_SEND_to_share_this
            array_selectedId
                .append(
                    UserDefaultFileManager.get_staff_Details()?.school_id ?? ""
                )
            nodataFound.isHidden = false
            nodataFound.image = ImageName.girl_and_boy_are
            noRecordLbl.isHidden = false
        default:
            print("Unhandled staff role")
        }
        
        // Add segments from updated array
        for (index, title) in cv_itemsarry.enumerated() {
            segmentName.insertSegment(withTitle: title, at: index, animated: false)
        }
        
        segmentName.selectedSegmentIndex = 0
        
        
    }
    func homeWorkShowProps() {
        guard accedmicYrEligible else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            let isAssignmentOrHomework = Menu_id.staffSelectedMenuId == Menu_id.isAssaignment || Menu_id.staffSelectedMenuId == Menu_id.homeWorkMenuId
            
            if isAssignmentOrHomework {
                segmentName.isHidden = true
                target_type = TargetTypes.section
                circular_types = circular_type.section
                getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
                
                speficBtnName.isHidden = true
                speficBtnName.isEnabled = false
                
                tv.isHidden = false
                selectStandardDropDown.isHidden = false
                heightSegment.constant = 0
                
                cv_itemsarry = [recipeint_tabBarName.Section_Student]
            } else {
                speficBtnName.isEnabled = true
                selectStandardDropDown.isHidden = true
            }
        }
    }
    
    
    
    @IBAction func backbtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func send(_ sender: UIButton) {
        print("selectedId : \(array_selectedId)")
        let isEntireSchool = (cv_itemsarry[segmentName.selectedSegmentIndex] == recipeint_tabBarName.Entier_School)
        
        // Validate selection
        guard isEntireSchool || !array_selectedId.isEmpty else {
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
            
        case Menu_id.homeWorkMenuId, Menu_id.isAssaignment:
            guard let subjectId = subjectId, !subjectId.isEmpty else {
                alert.showAlert(
                    title: AlertstringFile.Alert_title,
                    message: AlertstringFile.Choose_any_section,
                    on: self
                )
                return
            }
            let baseURL = (Menu_id.staffSelectedMenuId == Menu_id.homeWorkMenuId)
            ? ServiceUrl.comm_homework_sendhomework
            : ServiceUrl.comm_assignment_send_assignment
            
            sendAttachmentFlow(
                via: comm,
                url: baseURL,
                subjectId: subjectId
            )
            
        case Menu_id.AttachmentMenuId:
            sendAttachmentFlow(
                via: comm,
                url: ServiceUrl.comm_attachment_send_attachment,
                subjectId: subjectId ?? ""
            )
            
        case Menu_id.event:
            sendAttachmentFlow(
                via: comm,
                url: ServiceUrl.api_school_event_send_event,
                subjectId: subjectId ?? ""
            )
            
        default:
            print("⚠️ Unhandled menu ID: \(Menu_id.staffSelectedMenuId)")
        }
    }
    
    
    private func sendAttachmentFlow(
        via comm: commonApi_forSending,
        url baseURL: String,
        subjectId: String
    ) {
        comm.SendingAttachmentFlow(
            selectedAcadimicYearId: selectedAcadimicYearId ?? 0,
            target_type: target_type ?? 0,
            selectedId: array_selectedId,
            baseURL: baseURL,
            subjectId: subjectId,
            message: acidmicYearOrNotAlertMessage(),
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
                    
                    Common_request_params.removeAll()
                    
                    if user_inputs.clearTempData(){
                        gotoDashboard()
                    }
                    
                }
            }
        }
    }
    
    func acidmicYearOrNotAlertMessage() -> String{
        var selectedTabItem = cv_itemsarry[segmentName.selectedSegmentIndex]
        
        if cv_itemsarry[segmentName.selectedSegmentIndex] == recipeint_tabBarName.Section_Student{
            
            selectedTabItem = "Section"
        }
        var message : String?
        if accadmicDefaultYrName == acidmicYrLbl.text{
            message = AlertstringFile.Selected_target + "\(array_selectedId.count) " + "\(selectedTabItem) (s)" + "\n" + AlertstringFile.AreYouSureYouWantToProceed
        }else{
            
            message = AlertstringFile.Selected_target + "\(array_selectedId.count) " + "\(cv_itemsarry[segmentName.selectedSegmentIndex]) (s)" + "\n" + AlertstringFile.Change_academic_year + " " + (
                acidmicYrLbl.text ?? "") + AlertstringFile.Change_academic_year1 +   "\n" + AlertstringFile.Change_academic_year2
        }
        
        return message ?? ""
    }
    
    @IBAction func getSubject(_ sender: UIButton) {
        let selectedSections = sectionsDetails?.filter { $0.isSelect == true } ?? []
        if Menu_id.homeWorkMenuId == Menu_id.staffSelectedMenuId || Menu_id.isAssaignment == Menu_id.staffSelectedMenuId {
            if let finalSectionIds = sectionIds, !finalSectionIds.isEmpty {
                getSubjectListAPI(finalSectionIds)
            }
            
        }
        selectSubject.isHidden = !(selectedSections.count >= 1)
        getSubject.isHidden = true
        selectSubject.isHidden = false
        spaceView.isHidden = true
    }
    
    private func SendingCommunicationFlow() {
        
        let title = AlertstringFile.Confirm_title
        alert.showAlertCancel(
            title: title,
            message: acidmicYearOrNotAlertMessage(),
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
                        let com = commonApi_forSending()
                        com.uploadAWSMedia(file: user_inputs.voice_link) {
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
    
    
    
    
    @IBAction func spefic_student_actionBtn(_ sender: UIButton) {
        
        print("array_selectedIdarray_selectedId",array_selectedId)
        guard  array_selectedId.count > 0 else {
            self.alert
                .showAlert(
                    title: AlertstringFile.Alert_title,
                    message: AlertstringFile.Choose_any_standard_section ,
                    on: self
                )
            
            return
        }
        var message : Bool?
        if accadmicDefaultYrName == acidmicYrLbl.text{
            message = true
        }else{
            message = false
        }
        
        let selectedSectionName = sectionsDetails?
            .first(where: {$0.isSelect == true })?
            .name
        
        
        let vc = StudentHistryVC(nibName: nil, bundle: nil)
        vc.selected_sectionID = array_selectedId.first
        vc.ScreenType = ScreenType
        vc.AlertMessageContent = message
        vc.accidmaticNAme = acidmicYrLbl.text
        vc.selectedAcadimicYearId = self.selectedAcadimicYearId
        vc.StandardString = drpodonLbl.text
        vc.SectionString = selectedSectionName
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
            array_selectedId.append( UserDefaultFileManager.get_staff_Details()?.school_id ?? "")
            target_type = TargetTypes.school
            circular_types =  circular_type.school
            nodataFound.isHidden = false
            noRecordLbl.isHidden = false
            noRecordLbl.text = CommonStringFile.Tap_SEND_to_share_this
            sendbtnName.isHidden = false
            nodataFound.image = ImageName.girl_and_boy_are
            selectStandardDropDown.isHidden = true
            tv.isHidden = true
            
            
        case recipeint_tabBarName.Group:
            target_type = TargetTypes.group
            circular_types =  circular_type.group
            getGrouplistAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            
        case recipeint_tabBarName.Standard:
            target_type = TargetTypes.standard
            circular_types =  circular_type.standard
            getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            
        case recipeint_tabBarName.Section_Student:
            target_type = TargetTypes.section
            circular_types =  circular_type.section
            getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            speficBtnName.isEnabled = !(
                Menu_id.staffSelectedMenuId == Menu_id.isAssaignment ||  Menu_id.staffSelectedMenuId == Menu_id.homeWorkMenuId
            )
            tv.isHidden = false
            selectStandardDropDown.isHidden = false
            
        case recipeint_tabBarName.Staff:
            target_type = TargetTypes.staff
            circular_types =  circular_type.staff
            getStaffListAPI()
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
        StdDropdown.direction = .bottom
        StdDropdown.show()
        StdDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            array_selectedId.removeAll()
            selectSubject.isHidden = true
            subjectId = ""
            self.sectionsDetails = self.standardDetails?.first(where: { $0.name == item })?.sections
            if let label = self.selectStandardDropDown.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
            }
            speficBtnName.isHidden = true
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
        StdDropdown.show()
        let tableView = self.StdDropdown.tableView
        let visibleCellCount = tableView.visibleCells.count
        let visibleHeight = CGFloat(visibleCellCount) * 44.0
        if visibleHeight < 200 {
            self.StdDropdown.direction = .top
        } else {
            self.StdDropdown.direction = .bottom
        }
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
        accadimYrIDs.removeAll()
        let yearname = localData.accidamic_year_data?.data?.compactMap{ $0.year}
        let yeardId = localData.accidamic_year_data?.data?.compactMap{ $0.id}
        accadimYr = yearname ?? []
        accadimYrIDs = yeardId ?? []
       
        acidamicdrops.anchorView = acidamicYrDropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acidamicYrDropView.bounds.height)
        acidamicdrops.show()
        acidamicdrops.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            selectedAcadimicYearId =  localData.accidamic_year_data?.data?[index].id
            array_selectedId.removeAll()
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
        }
        
        
    }
}


extension RecipientVc: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: CellConfingName.Std_Grp_header
        ) as! Std_Grp_header
        
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            head.HeaderLabel.text = recipeint_tabBarName.Group
            head.createdOnDefaultLbl.isHidden = false
        case recipeint_tabBarName.Standard:
            head.HeaderLabel.text = recipeint_tabBarName.Standard
            head.createdOnDefaultLbl.isHidden = true
        case recipeint_tabBarName.Section_Student:
            head.HeaderLabel.text = recipeint_tabBarName.Section_Student
            head.createdOnDefaultLbl.isHidden = true
        case recipeint_tabBarName.Staff:
            head.HeaderLabel.text = recipeint_tabBarName.Staff
            head.createdOnDefaultLbl.isHidden = true
        default:
            head.HeaderLabel.text = ""
        }
        return head
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
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
                cell.createdOnlbl.text =  item.created_on
                cell.createdOnlbl.textAlignment = .right
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
                cell.createdOnlbl.isHidden = false
                cell.createdOnlbl.textAlignment = .left
                if ((item.designation?.isEmpty) != nil) && (
                    (item.emp_id?.isEmpty) != nil
                ){
                    
                    cell.createdOnlbl.isHidden = true
                }else{
                    cell.isHidden = false
                    cell.createdOnlbl.text = "\(item.designation ?? "") - \(item.emp_id ?? "")"
                }
                
                cell.checkboxImg.image = (item.isSelect ?? false) ? ImageName.checkedSquares : ImageName.uncheckedSquares
            }
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.tableHeight.constant = self.tv.contentSize.height
            self.view.layoutIfNeeded()
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
                array_selectedId = selectedIds
                sectionIds = selectedIds.joined(separator: ",")
                if Menu_id.homeWorkMenuId == Menu_id.staffSelectedMenuId || Menu_id.isAssaignment == Menu_id.staffSelectedMenuId {
                    getSubject.isHidden = (selectedSections.count == 0) || !selectSubject.isHidden
                    if (selectedSections.count >= 1){
                        selectSubject.isHidden =  !getSubject.isHidden
                    }else{
                        selectSubject.isHidden = true
                        subjectId = ""
                    }
                }else{
                    speficBtnName.isHidden = !(selectedSections.count == 1)
                }
                spaceView.isHidden = !selectSubject.isHidden
                
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
            
            if Menu_id.homeWorkMenuId == Menu_id.staffSelectedMenuId || Menu_id.isAssaignment == Menu_id.staffSelectedMenuId {
                sectionIds = ""
                let selectedSections = sectionsDetails?.filter { $0.isSelect == true } ?? []
                let selectedIds = selectedSections.compactMap { $0.id }
                array_selectedId = selectedIds
                sectionIds = selectedIds.joined(separator: ",")
                spaceView.isHidden = !selectSubject.isHidden
                subjectId = selectedSections.count == 0 ? "" : subjectId
                selectSubject.isHidden = subjectId == "" || subjectId == nil
                getSubject.isHidden = (selectedSections.count == 0) || !selectSubject.isHidden
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
                            spaceView.isHidden = false
                            groupDetails = successmessage.data
                            nodata(true, message: "")
                            if var students = groupDetails {
                                for i in students.indices {
                                    students[i].isSelect = false
                                }
                                groupDetails = students
                            }
                            tv.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            nodata(false, message: successmessage.message ?? "" )
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        self.nodata(false, message: error.localizedDescription)
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
                        spaceView.isHidden = false
                        tv.isHidden = false
                        noRecordLbl.isHidden = true
                        nodata(true, message: "")
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
                        selectStandardDropDown.isHidden = cv_itemsarry[segmentName.selectedSegmentIndex] == recipeint_tabBarName.Standard
                        
                        getSubject.isHidden = true
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
                        nodata(false, message: successMessage.message ?? "")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    print(error.localizedDescription)
                    nodata(false, message: error.localizedDescription)
                }
                
            }
        }
        
    }
    func nodata(_ ishide:Bool,message:String){
        nodataFound.image = ImageName.missing_file
        nodataFound.isHidden = ishide
        sendbtnName.isHidden = !ishide
        tv.isHidden = !ishide
        noRecordLbl.isHidden = ishide
        noRecordLbl.text = message
        if Menu_id.homeWorkMenuId == Menu_id.staffSelectedMenuId || Menu_id.isAssaignment == Menu_id.staffSelectedMenuId {
            getSubject.isHidden = !ishide
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
                            nodata(true, message: "")
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
                            spaceView.isHidden = false
                            sendbtnName.isHidden = true
                            tv.isHidden = true
                            
                            nodata(false, message: successMessage.message ?? "")
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    nodata(false, message: "Something went wrong")
                }
            }
        
    }
    func getSubjectListAPI(_ id:String){
        subjectList.removeAll()
        
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_subject_list , parameters: [
            COMMON_PARAMETER.section_ids: id
        ], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (result:Result <GetSubjectlistSuc,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        tv.isHidden = false
                        subjectDetails = successMessage.data
                        subjectDetails?.enumerated().forEach { index, student in
                            subjectList.append(student.name ?? "")
                        }
                        
                        if let label = self.selectSubject.subviews.first(where: { $0 is UILabel }) as? UILabel {
                            label.text = subjectDetails?.first?.name
                            subjectId =  subjectDetails?.first?.id ?? ""
                        }
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        selectSubject.isHidden = true
                        spaceView.isHidden = false
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    
   
    
    func getacadmicYr(){
        
        if localData.accidamic_year_data?.status == true{
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
                        accedmicYrEligible = true
                        segmentName.isUserInteractionEnabled = hasCurrentYear
                        break
                    }
                }
                
                if !hasCurrentYear {
                    segmentName.isUserInteractionEnabled = false
                    nodata(false, message: "")
                    
                    nodataFound.isHidden = false
                    nodataFound.image = ImageName.customer_support
                    acidamicYrDropView.isUserInteractionEnabled = false
                    heightSegment.constant = 0
                    chooseDefaultLbl.isHidden = true
                    segmentName.isHidden = true
                    acidamicYrDropView.isHidden = true
                    selectStandardDropDown.isHidden = true
                    let fullText = CommonStringFile.Your_academic_year_configuration
                    let attributedString = NSMutableAttributedString(string: fullText)
                    
                    let email = CommonStringFile.support_savyasasy_com
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
                homeWorkShowProps()
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
        let email = CommonStringFile.support_savyasasy_com
        
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
                let subject = "Request to configure communication academic year"
                let body = "Dear School Chimes Team,\n\n Please configure communication academic year  as 20xx - 20xx for any queries contact .\n\n Your name,\nMobile No"
                
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
    }// MARK:   Listing  API END ===========================
    
    
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
                                    title: AlertstringFile.Success,
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
                                    title: AlertstringFile.Alert_title,
                                    message: succesmessage.message ?? "" ,
                                    on: self)
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
        
        print("user_inputs.duration",user_inputs.duration)
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
                                    title: AlertstringFile.Success,
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
                                    title: AlertstringFile.Alert_title,
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
        DispatchQueue.main.async { [self] in
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
            
            // Add segments from updated array
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
