//
//  RecipientVc.swift
//  VsSchoolChimes
//
//  Created by admin on 31/03/25.
//

import UIKit
import DropDown

class RecipientVc: UIViewController{
    
    @IBOutlet weak var segmentName: UISegmentedControl!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var speficBtnName: UIButton!
    @IBOutlet weak var sendbtnName: UIButton!
    @IBOutlet weak var selectGroupsDropDown: UIView!
    @IBOutlet weak var selectStandardDropDown: UIView!
    @IBOutlet weak var selectSectionDropdown: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var noRecordLbl: UILabel!
    
    var cv_itemsarry : [String] = ["Entier School","Group","Standard","Section/Student"]
    var dropDownArray = [String]()
    var subjectDetails: [GetSubjectDetails]?
    var studentsDetails: [StudentDetails]?
    var sectionsDetails: [sectionsDetail]?
    var standardDetails: [StandardDetail]?
    var groupDetails: [GroupDetail]?
    var lastSelectedButton: UIButton?
    let dropDown = DropDown()
    let StdDropdown = DropDown()
    var selectedId : IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        sendbtnName.layer.cornerRadius = 10
        speficBtnName.layer.cornerRadius = 10
        
        selectStandardDropDown.layer.cornerRadius = 10
        selectStandardDropDown.layer.shadowColor = UIColor.black.cgColor
        selectStandardDropDown.layer.shadowOffset = CGSize(width: 4, height: 4)
        selectStandardDropDown.layer.shadowOpacity = 0.5
        selectStandardDropDown.layer.shadowRadius = 4
        selectStandardDropDown.backgroundColor = .white
        selectSectionDropdown.isHidden = true
        selectStandardDropDown.isHidden = true
        selectGroupsDropDown.isHidden = true
        speficBtnName.isEnabled = false
        speficBtnName.backgroundColor = UIColor.gray
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(selectStd))
        selectStandardDropDown.addGestureRecognizer(tap2)
        
        let nib = UINib(nibName: CellConfingName.RecipientTvCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.RecipientTvCell)
        
        tv
            .register(
                UINib(nibName:CellConfingName.Std_Grp_header, bundle: nil),
                forHeaderFooterViewReuseIdentifier: CellConfingName.Std_Grp_header
            )
        tv.delegate = self
        tv.dataSource = self
    }
    
    
    @IBAction func backbtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    @IBAction func send(_ sender: UIButton) {
        var selectedIds: [Int] = []

            switch segmentName.selectedSegmentIndex {
            case 1:
                selectedIds = groupDetails?.compactMap {
                    if let id = $0.id as? Int {
                        return id
                    } else if let idStr = $0.id as? String, let id = Int(idStr) {
                        return id
                    }
                    return nil
                } ?? []
                
            case 2:
                selectedIds = standardDetails?.compactMap {
                    if let id = $0.id as? Int {
                        return id
                    } else if let idStr = $0.id as? String, let id = Int(idStr) {
                        return id
                    }
                    return nil
                } ?? []
                
            case 3:
                selectedIds = sectionsDetails?.compactMap {
                    if let id = $0.id as? Int {
                        return id
                    } else if let idStr = $0.id as? String, let id = Int(idStr) {
                        return id
                    }
                    return nil
                } ?? []
                
            default:
                selectedIds = []
            }

            print("Selected IDs: \(selectedIds)")
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        
        
        if segmentName.selectedSegmentIndex == 0{ // Entier
            contentLbl.isHidden = false
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = true
        }else if segmentName.selectedSegmentIndex == 1{ // group
            getGrouplistAPI()
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
            
        }else if segmentName.selectedSegmentIndex == 2{ // standard
            getStandardsAPI()
            contentLbl.isHidden = true
            speficBtnName.isHidden = true
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
        }else if segmentName.selectedSegmentIndex == 3{ // section / spefic student
            //            getStudentListAPI()
            getStandardsAPI()
            speficBtnName.isHidden = false
            contentLbl.isHidden = true
            tv.isHidden = false
            selectStandardDropDown.isHidden = false
        }
    }
    
    @IBAction func selectStd(){
        setupStdDropdown ()
    }
    
    func setupStdDropdown() {
        StdDropdown.anchorView = selectStandardDropDown
        StdDropdown.dataSource = dropDownArray
        StdDropdown.bottomOffset = CGPoint(x: 0, y: selectStandardDropDown.bounds.height)
        StdDropdown.show()
        
        StdDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return } // Prevents strong reference cycles
            
            print("Selected item: \(item) at index: \(index)")
            
            // Filter standardDetails based on the selected item
            self.sectionsDetails = self.standardDetails?.first(where: { $0.name == item })?.sections
            // Update the label inside the UIView
            if let label = self.selectStandardDropDown.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
            }
            
            self.tv.isHidden = false
            self.tv.reloadData() // Reload data AFTER updating sectionsDetails
        }
    }
    
}


extension RecipientVc: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Std_Grp_header") as! Std_Grp_header
        
        switch segmentName.selectedSegmentIndex {
        case 1:
            head.HeaderLabel.text = "Group"
        case 2:
            head.HeaderLabel.text = "Standard"
        case 3:
            head.HeaderLabel.text = "Section"
        default:
            head.HeaderLabel.text = ""
        }
        return head
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentName.selectedSegmentIndex {
        case 1:
            return groupDetails?.count ?? 0
        case 2:
            return standardDetails?.count ?? 0
        case 3:
            return sectionsDetails?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.RecipientTvCell, for: indexPath) as! RecipientTvCell
        
        switch segmentName.selectedSegmentIndex {
        case 1:
            cell.checkboxImg.isUserInteractionEnabled = true
            cell.cellLabel.text = groupDetails?[indexPath.row].name
            if let select = groupDetails?[indexPath.row].isSelect {
                cell.checkboxImg.image = select ? UIImage(named: "checkedSquare") : UIImage(named: "uncheckedSquare")
            }
        case 2:
            cell.cellLabel.text = standardDetails?[indexPath.row].name
            if let select = standardDetails?[indexPath.row].isSelect {
                cell.checkboxImg.image = select ? UIImage(named: "checkedSquare") : UIImage(named: "uncheckedSquare")
            }
        case 3:
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
        switch segmentName.selectedSegmentIndex {
        case 1:
            if indexPath.row < (groupDetails?.count ?? 0) {
                groupDetails?[indexPath.row].isSelect?.toggle()
            }
        case 2:
            if indexPath.row < (standardDetails?.count ?? 0) {
                standardDetails?[indexPath.row].isSelect?.toggle()
            }
        case 3:
            if indexPath.row < (sectionsDetails?.count ?? 0) {
                sectionsDetails?[indexPath.row].isSelect?.toggle()
                let selectedSections = sectionsDetails?.filter { $0.isSelect == true } ?? []
                speficBtnName.isEnabled =  selectedSections.count != 1 ? false : true
                speficBtnName.backgroundColor =  selectedSections.count != 1 ? UIColor.gray:.button
            }
        default:
            break
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func getGrouplistAPI(){
        
        APIService.shared
            .makeApi(
                url: ServiceUrl.recipient_get_group_list,
                parameters: [:],
                type: ApitTypeSringFile.GET ,
                token: ServiceUrl.token
            ) {
                [self] (result: Result<GrouplistSuc,Error>) in
                switch result {
                case .success(let successmessage):
                    
                    if successmessage.status == true{
                        
                        DispatchQueue.main.async {[self] in
                            tv.isHidden = false
                            groupDetails = successmessage.data
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
                        sectionsDetails = standardDetails?.first?.sections // Assign sections directly
                        tv.reloadData()
                    }
                }else{
                    tv.isHidden = true
                    noRecordLbl.text = successMessage.message
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    func getStudentListAPI(){
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_student_list, parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (result:Result <GetStudentlistSuc,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        tv.isHidden = false
                        studentsDetails = successMessage.data
                        if var students = studentsDetails {
                            for i in students.indices {
                                students[i].isSelect = false
                            }
                            studentsDetails = students
                        }
                        tv.reloadData()
                    }
                }else{
                    tv.isHidden = true
                    noRecordLbl.text = successMessage.message
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    
    func getSubjectListAPI(){
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_subject_list, parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (result:Result <GetSubjectlistSuc,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        tv.isHidden = false
                        subjectDetails = successMessage.data
                        tv.reloadData()
                    }
                    
                }else{
                    tv.isHidden = true
                    noRecordLbl.text = successMessage.message
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    
}
