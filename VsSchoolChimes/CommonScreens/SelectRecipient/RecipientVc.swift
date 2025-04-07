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
    @IBOutlet weak var selectSectionDropdown: UIView!
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
    var array_selectedId : [Int] = []
    var communicatio_textDetails :[String] = []
    var target_type : Int?
    let alert = CustomAlert()
    override func viewDidLoad() {
        super.viewDidLoad()

        backbtnMName
            .setTitle(
                UserDefaultFileManager.get_staff_Details()?.school_name,
                for: .normal
            )
        if staff_role == PriorityType.is_staff{
            contentLbl.isHidden = true
            cv_itemsarry = ["Standard","Section/Student","Group"]
            segmentName.removeAllSegments()
                // Add new segments from array
                for (index, title) in cv_itemsarry.enumerated() {
                    segmentName.insertSegment(withTitle: title, at: index, animated: false)
                }
                // Set default selected index (optional)
                segmentName.selectedSegmentIndex = 0
        }else if staff_role == PriorityType.is_admin || staff_role == PriorityType.is_principal || staff_role == PriorityType.is_grouphead{
            speficBtnName.isHidden = true
            cv_itemsarry = ["Entier School","Standard","Group"]
            segmentName.removeAllSegments()
                for (index, title) in cv_itemsarry.enumerated() { // Add new segments from array
                    segmentName.insertSegment(withTitle: title, at: index, animated: false)
                }
                // Set default selected index (optional)
                segmentName.selectedSegmentIndex = 0
        }
        tableHeight.constant = 0
        sendbtnName.layer.cornerRadius = 10
        speficBtnName.layer.cornerRadius = 10
        if ScreenType == screenType.isAssaignment || ScreenType == screenType.isHomeWork{
            speficBtnName.isHidden = true
        }else{
            speficBtnName.isEnabled = false
        }
        applyShadowAndCornerRadius(to: selectStandardDropDown)
        applyShadowAndCornerRadius(to: selectSectionDropdown)
        selectSectionDropdown.isHidden = true
        selectStandardDropDown.isHidden = true
        selectGroupsDropDown.isHidden = true
        speficBtnName.backgroundColor = UIColor.gray
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(selectStd))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(selectSubject))
        selectStandardDropDown.addGestureRecognizer(tap2)
        selectSectionDropdown.addGestureRecognizer(tap3)
        
        let nib = UINib(nibName: CellConfingName.RecipientTvCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.RecipientTvCell)
        
        tv.register(UINib(nibName:CellConfingName.Std_Grp_header, bundle: nil),forHeaderFooterViewReuseIdentifier: CellConfingName.Std_Grp_header)
        
        tv.delegate = self
        tv.dataSource = self
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
                            sendtextmessage_communication(
                                message : communicatio_textDetails.first ?? "",
                                description: communicatio_textDetails.last ?? "",
                                target_type :target_type ?? 0
                            )
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
        if selectedTitle == "Entier School"{ // Entier
            target_type = TargetTypes.school
            contentLbl.isHidden = false
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = true
        }else if selectedTitle == "Group"{ // group
            target_type = TargetTypes.group
            getGrouplistAPI()
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            
        }else if selectedTitle ==  "Standard"{ // standard
            target_type = TargetTypes.standard
            getStandardsAPI()
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
        }else if selectedTitle  ==  "Section/Student"{
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
        
    }
   
    @IBAction func selectStd(){
        setupStdDropdown ()
    }
    @IBAction func selectSubject(){
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
        StdDropdown.anchorView = selectSectionDropdown
        StdDropdown.dataSource = subjectList
        StdDropdown.bottomOffset = CGPoint(x: 0, y: selectSectionDropdown.bounds.height)
        StdDropdown.direction = .bottom
        StdDropdown.show()
        
        StdDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            if let label = self.selectSectionDropdown.subviews.first(where: { $0 is UILabel }) as? UILabel {
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
        case "Group":
            head.HeaderLabel.text = "Group"
        case "Standard":
            head.HeaderLabel.text = "Standard"
        case "Section":
            head.HeaderLabel.text = "Section/Student"
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
        case "Group":
            return groupDetails?.count ?? 0
        case "Standard":
            return standardDetails?.count ?? 0
        case "Section/Student":
            return sectionsDetails?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.RecipientTvCell, for: indexPath) as! RecipientTvCell
        
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case "Group":
            cell.checkboxImg.isUserInteractionEnabled = true
            cell.cellLabel.text = groupDetails?[indexPath.row].name
            if let select = groupDetails?[indexPath.row].isSelect {
                cell.checkboxImg.image = select ? UIImage(named: "checkedSquare") : UIImage(named: "uncheckedSquare")
            }
            
        case "Standard":
            cell.cellLabel.text = standardDetails?[indexPath.row].name
            if let select = standardDetails?[indexPath.row].isSelect {
                cell.checkboxImg.image = select ? UIImage(named: "checkedSquare") : UIImage(named: "uncheckedSquare")
            }
        case "Section/Student":
            cell.cellLabel.text = sectionsDetails?[indexPath.row].name
            if let select = sectionsDetails?[indexPath.row].isSelect {
                cell.checkboxImg.image = select ? UIImage(named: "checkedSquare") : UIImage(named: "uncheckedSquare")
            }
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case "Group":
            if indexPath.row < (groupDetails?.count ?? 0) {
                groupDetails?[indexPath.row].isSelect?.toggle()
                
                if let id =  groupDetails?[indexPath.row].id {
                    if  groupDetails?[indexPath.row].isSelect == true {
                        if !array_selectedId.contains(Int(id) ?? 0) {
                            array_selectedId.append(Int(id) ?? 0)
                        }
                    } else {
                        array_selectedId.removeAll(where: { $0 == Int(id) ?? 0 })
                    }
                }
            }
        case "Standard":
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
        case "Section/Student":
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
                       getSubjectListAPI(section.id ?? 0)
                       selectSectionDropdown.isHidden = false
                       
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
                            selectSectionDropdown.isHidden = true
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
                        selectSectionDropdown.isHidden = true
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
    
    func getSubjectListAPI(_ id:Int){
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
                        selectSectionDropdown.isHidden = true
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
    
    
    func sendtextmessage_communication(message : String,description:String,target_type :Int){
        
        APIService.shared
            .makeApi(url: ServiceUrl.comm_text_message_send_text, parameters:[
                
                send_textmessageStringFile.target_type : target_type,
                send_textmessageStringFile.target_code : array_selectedId,
                send_textmessageStringFile.message : message,
                send_textmessageStringFile.description : description
                 
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
