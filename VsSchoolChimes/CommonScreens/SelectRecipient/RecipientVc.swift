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
    @IBOutlet weak var selectGroupsDropDown: UIView!
    @IBOutlet weak var selectStandardDropDown: UIView!
    @IBOutlet weak var selectSubject: UIView!
   
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var noRecordLbl: UILabel!
    
    var cv_itemsarry : [String] = []
    var dropDownArray = [String]()
    var subjectList = [String]()
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
    let staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var segment_selected_index:Int?
    var array_selectedId : [String] = []
    var communicatio_textDetails :[String] = []
    var requestCommonDataDetails : [String:Any] = [:]
    var target_type : Int?
    let alert = CustomAlert()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backbtnMName
            .setTitle(
                UserDefaultFileManager.get_staff_Details()?.school_name,
                for: .normal
            )
       
        userAcces_check()
        
        if ScreenType == screenType.isAssaignment || ScreenType == screenType.isHomeWork{
            speficBtnName.isHidden = true
        }else{
            speficBtnName.isEnabled = false
        }
        sendbtnName.layer.cornerRadius = 10
        speficBtnName.layer.cornerRadius = 10
        
       
        applyShadowAndCornerRadius(to: selectStandardDropDown)
        applyShadowAndCornerRadius(to: selectSubject)
        selectSubject.isHidden = true
        selectStandardDropDown.isHidden = true
        selectGroupsDropDown.isHidden = true
        speficBtnName.backgroundColor = UIColor.gray
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(selectStd))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(selectedSubject))
        selectStandardDropDown.addGestureRecognizer(tap2)
        selectSubject.addGestureRecognizer(tap3)
        
        let nib = UINib(nibName: CellConfingName.RecipientTvCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.RecipientTvCell)
        
        tv.register(UINib(nibName:CellConfingName.Std_Grp_header, bundle: nil),forHeaderFooterViewReuseIdentifier: CellConfingName.Std_Grp_header)
        
        tv.delegate = self
        tv.dataSource = self
    }
    
    
    func userAcces_check(){
        
        if staff_role == PriorityType.is_staff{
            contentLbl.isHidden = true
            cv_itemsarry = [
                recipeint_tabBarName.Standard,
                recipeint_tabBarName.Section_Student,
                recipeint_tabBarName.Group
            ]
            segmentName.removeAllSegments()
            for (index, title) in cv_itemsarry.enumerated() {
                segmentName.insertSegment(withTitle: title, at: index, animated: false)
            }
            segmentName.selectedSegmentIndex = 0
            getStandardsAPI()
            
        }else if staff_role == PriorityType.is_admin || staff_role == PriorityType.is_principal || staff_role == PriorityType.is_grouphead{
            speficBtnName.isHidden = true
            if staffDetailsCount?.count ?? 0 > 1{
                cv_itemsarry = [
                    recipeint_tabBarName.Standard,
                    recipeint_tabBarName.Section_Student,
                    recipeint_tabBarName.Group,
                    recipeint_tabBarName.Staff
                ]
                contentLbl.isHidden = true
                getStandardsAPI()
            }else{
                cv_itemsarry = [
                    recipeint_tabBarName.Entier_School,
                    recipeint_tabBarName.Standard,
                    recipeint_tabBarName.Group]
                tableHeight.constant = 0
            }
            segmentName.removeAllSegments()
            for (index, title) in cv_itemsarry.enumerated() { // Add new segments from array
                segmentName.insertSegment(withTitle: title, at: index, animated: false)
            }
            segmentName.selectedSegmentIndex = 0
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
    
    
    @IBAction func backbtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func send(_ sender: UIButton) {
        
        print("selectedId : \(array_selectedId)")
        if array_selectedId.count != 0 {
            
            if screenType.communication_text == ScreenType{
                
                alert
                    .showAlertCancel(
                        title: AlertstringFile.Alert_title,
                        message: AlertstringFile.AreYouSureYouWantToProceed + String(
                            array_selectedId.count) ,
                        actionLbl1: AlertstringFile.OK,
                        actionLbl2: AlertstringFile.Cancel,
                        on: self,
                        onOk: { [self] in
                            
                            sendtextmessage_communication()
                            
                        } ,
                        onNo: {print("Canceled")})
            }else if screenType.is_emergencyvoice == ScreenType{
                let today = getCurrentDateString()
                alert
                    .showAlertCancel(
                        title: AlertstringFile.Alert_title,
                        message: AlertstringFile.AreYouSureYouWantToProceed + String(
                            array_selectedId.count) ,
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
    
    @IBAction func spefic_student_actionBtn(_ sender: UIButton) {
        
        let vc = StudentHistryVC(nibName: nil, bundle: nil)
        vc.selected_sectionID = array_selectedId.first
        vc.communicatio_textDetails = communicatio_textDetails
        vc.ScreenType = ScreenType
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
        if selectedTitle == recipeint_tabBarName.Entier_School{ // Entier
            target_type = TargetTypes.school
            contentLbl.isHidden = false
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = true
        }else if selectedTitle == recipeint_tabBarName.Group{ // group
            target_type = TargetTypes.group
            getGrouplistAPI()
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            
        }else if selectedTitle ==  recipeint_tabBarName.Standard{ // standard
            target_type = TargetTypes.standard
            getStandardsAPI()
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
        }else if selectedTitle  == recipeint_tabBarName.Section_Student{
            target_type = TargetTypes.section
            getStandardsAPI()
            if ScreenType == screenType.isAssaignment || ScreenType == screenType.isHomeWork{
                speficBtnName.isHidden = true
            }else{
                speficBtnName.isHidden = false
                speficBtnName.isEnabled = false
            }
            contentLbl.isHidden = true
            tv.isHidden = false
            selectStandardDropDown.isHidden = false
        }
        
        else if selectedTitle  == recipeint_tabBarName.Staff{
            target_type = TargetTypes.staff
            getStaffListAPI()
            
            contentLbl.isHidden = true
            tv.isHidden = false
            selectStandardDropDown.isHidden = true
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
                speficBtnName.isHidden = true
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
                
                if ScreenType == screenType.isAssaignment || ScreenType == screenType.isHomeWork {
                    for i in 0..<(sectionsDetails?.count ?? 0) {
                        if i != indexPath.row {
                            sectionsDetails?[i].isSelect = false
                        } else {
                            sectionsDetails?[i].isSelect?.toggle()
                        }
                    }
                    getSubjectListAPI(section.id ?? "")
                    selectSubject.isHidden = false
                    
                    if let id = section.id {
                        if section.isSelect == true {
                            if !array_selectedId.contains(id) {
                                array_selectedId.append(id)
                            }
                        } else {
                            array_selectedId.removeAll(where: { $0 == id })
                        }
                    }
                } else {
                    section.isSelect?.toggle()
                    sectionsDetails?[indexPath.row].isSelect = section.isSelect // update back to array
                    
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
                    speficBtnName.isEnabled = selectedSections.count == 1
                    speficBtnName.backgroundColor = selectedSections.count == 1 ? .button : .gray
                }
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
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_subject_list + "?section_id=\(id)", parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (result:Result <GetSubjectlistSuc,Error>) in
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
        
    }   // MARK:   Listing  API END ===========================
    
    
    
    
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
