//
//  AttendanceMarkingVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 19/09/25.
//

import UIKit

class AttendanceMarkingVC: UIViewController, UISearchBarDelegate, markeAsAbsent, viewLeaveApplied {
    func didTapViewAppliedLeave(index: Int) {

            if expandedIndex == index {
                expandedIndex = nil
            } else {
                expandedIndex = index
            }

        tv.reloadData()
        }
    
    
    func markAsAbsent(AbsentStudent: [AttendanceStudentListDetails], CallAttendaceApi: Bool) {
        
        searchBar.searchTextField.text = ""
        searchQuery = ""
        noDataLbl.isHidden = true
        noDataImage.isHidden = true
        
        student_List = AbsentStudent
        applyFilterAndSort()
        getAttendanceCounts()
        updateSelectAllCheckbox()
        
        if CallAttendaceApi {
            user_inputs.all_present = areAllStudentsPresent() ? "T" : "F"
            self.markAttendaceApi()
        }
    }
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var rollNoLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var PresentCountView: UIView!
    @IBOutlet weak var AbsentCountView: UIView!
    @IBOutlet weak var OdCountView: UIView!
    @IBOutlet weak var PresentCountLbl: UILabel!
    @IBOutlet weak var AbsentCountLbl: UILabel!
    @IBOutlet weak var OdCountLbl: UILabel!
    @IBOutlet weak var PresentDefLbl: UILabel!
    @IBOutlet weak var OdDefLbl: UILabel!
    @IBOutlet weak var AbsentDefLbl: UILabel!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchStack: UIStackView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var selected_sectionID = ""
    var selectedAcadimicYearId : Int?
    var StandardString = ""
    var SectionString = ""
    let staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    let staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var dropDown = DropDown()
    var student_List: [AttendanceStudentListDetails]?
    var Filtered_stuent_Listt: [AttendanceStudentListDetails]?
    var searchQuery: String = ""
    var selectedSort = CommonStringFile.NameASC
    var isAllAbsent = false
    var MARK_ATTENDANCE = "MARK_ATTENDANCE"
    var expandedIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StyleAndTranslater()
        let standard = StandardString + " - " + SectionString
        TitleLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName, secondLine: standard)
        
        confirmBtn.layer.cornerRadius = 10
        
        PresentCountView.layer.cornerRadius = 5
        PresentCountView.layer.borderWidth = 0.3
        PresentCountView.layer.borderColor = UIColor.systemGray4.cgColor
        
        AbsentCountView.layer.cornerRadius = 5
        AbsentCountView.layer.borderWidth = 0.3
        AbsentCountView.layer.borderColor = UIColor.systemGray4.cgColor
        
        OdCountView.layer.cornerRadius = 5
        OdCountView.layer.borderWidth = 0.3
        OdCountView.layer.borderColor = UIColor.systemGray4.cgColor
        
        PresentCountLbl.setFont(style: .title, size: 25)
        AbsentCountLbl.setFont(style: .title, size: 25)
        OdCountLbl.setFont(style: .title, size: 25)
        PresentDefLbl.setFont(style: .body, size: FontSize.BodySize)
        AbsentDefLbl.setFont(style: .body, size: FontSize.BodySize)
        OdDefLbl.setFont(style: .body, size: FontSize.BodySize)
        noDataLbl.setFont(style: .body, size: 20)
        
        filterBtn.setTitle(CommonStringFile.NameASC, for: .normal)
        filterBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        confirmBtn.setTitleFont(style: .body, size: FontSize.TitleSize)
        
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        searchBar.backgroundImage = UIImage()
        searchStack.isHidden = true
        
        noDataImage.isHidden = true
        noDataLbl.isHidden = true
        noDataLbl.text = "No Student Found!"
        
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
        
        tv.register(UINib(nibName: CellConfingName.AttendenceTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AttendenceTVC)
        tv.delegate = self
        tv.dataSource = self
        Get_student_List_Api()
    }
    
    func StyleAndTranslater() {
        
        //MARK: Label And Button Font Style
        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        rollNoLbl.setFont(style: .title, size: FontSize.TitleSize)
        statusLbl.setFont(style: .title, size: FontSize.TitleSize)
        filterBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Translation
        rollNoLbl.text = CommonStringFile.RollNo.translated()
        nameLbl.text = CommonStringFile.Name.translated()
        statusLbl.text = CommonStringFile.Status.translated()
        searchBar.placeholder = CommonStringFile.Search.translated()
    }
    
    func Get_student_List_Api(){
        
        showActivityLoader()
        
        let param: [String:Any] = [
            MarkAttendenceStringFile.section_id: user_inputs.section_id,
            MarkAttendenceStringFile.class_id: user_inputs.class_id,
            MarkAttendenceStringFile.date: user_inputs.attendance_date,
            MarkAttendenceStringFile.attendance_type: user_inputs.attendance_type,
            MarkAttendenceStringFile.academic_year_id : String(selectedAcadimicYearId ?? 0 )
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_api_attendance_student_list, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (result: Result<AttendanceStudentListResponse, Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        
                        if success.data?.first?.is_edit == true{
                            self.confirmBtn.setTitle("Confirm & Edit Attendance".translated(), for: .normal)
                        }else{
                            self.confirmBtn.setTitle("Confirm & Submit Attendance".translated(), for: .normal)
                        }
                        
                        self.student_List = success.data?.first?.attd_details
                        self.applyFilterAndSort()
                        self.getAttendanceCounts()
                        self.updateSelectAllCheckbox()
                        
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self) {
                            self.dismiss(animated: true)
                        }
                    }
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self) {
                        self.dismiss(animated: true)
                    }
                }
                
                self.hideActivityLoader()
            }
        }
    }
    
    
    
    func markAttendaceApi(){
        
        showActivityLoader()
        
        let payload = student_List?.map {
            getSpecialAttendanceType(for: $0)
        } ?? []
        APIService.shared
            .makeApi(url: ServiceUrl.attendance_send_absentees_sms_with_session_type, parameters:[
                MarkAttendenceStringFile.class_id: user_inputs.class_id,
                MarkAttendenceStringFile.section_id: user_inputs.section_id,
                MarkAttendenceStringFile.all_present: user_inputs.all_present,
                MarkAttendenceStringFile.attendance_type: user_inputs.attendance_type,
                MarkAttendenceStringFile.session_type: user_inputs.session_type,
                MarkAttendenceStringFile.attendance_date: user_inputs.attendance_date,
                MarkAttendenceStringFile.student_details: payload
            ] , type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true ){ [self] (
                result : Result<CommonApiSuc,
                Error>
            ) in
                switch result {
                case.success(let succesmessage) :
                    if succesmessage.status == true {
                        DispatchQueue.main.async { [self] in
                            if user_inputs.clearTempData(){
                                let parms = [ AttendanceAPIKeys.mobile_number: UserDefaultFileManager.get_staff_Details()?.mobile_no ?? "",
                                              AttendanceAPIKeys.activity: MARK_ATTENDANCE,
                                              AttendanceAPIKeys.user_type: 2,
                                              AttendanceAPIKeys.menu_id: Menu_id.staffSelectedMenuId] as [String : Any]
                                self.paketApiCall(params:parms)
                            }
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) {
                                    //                                    self.attendaceGoBackDashBoard()
                                    self.dismiss(animated: true)
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
                                    //                                    self.attendaceGoBackDashBoard()
                                    self.dismiss(animated: true)
                                }
                        }
                    }
                    
                case.failure(let error) :
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
                
                hideActivityLoader()
            }
    }
    
    func paketApiCall(params:[String:Any]){
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(response.message, duration: 2.0, position: .bottom)
                    }
                case .failure(let error):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                    }
                }
            }
        }
    }
    
    func getAttendanceCounts() {
        guard let students = student_List else { return }
        
        var present = 0, absent = 0, od = 0
        
        students.forEach {
            switch attendanceValue(for: $0) {
            case "A": absent += 1
            case "OD": od += 1
            default: present += 1
            }
        }
        
        PresentCountLbl.text = formatCount(present)
        AbsentCountLbl.text = formatCount(absent)
        OdCountLbl.text = formatCount(od)
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
    
    func formatCount(_ count: Int) -> String {
        if count == 0 {
            return "0"
        } else if count < 10 {
            return String(format: "0%d", count)
        } else {
            return String(count)
        }
    }
    @IBAction func selectAllAct(_ sender: UIButton) {
        
        let makeAbsent = !areAllstuentsAbsent()
        
        student_List = student_List?.map { student in
            
            var s = student
            
            var componets = s.att_status?.split(separator: "/").map(String.init) ?? ["P","P"]
            
            if componets.count < 2 {
                componets = [componets.first ?? "P", componets.first ?? "P"]
            }
            
            if user_inputs.attendance_type == "H" {
                
                let index = user_inputs.session_type == "SH" ? 1 : 0
                componets[index] = makeAbsent ? "A" : "P"
            }else{
                let value = makeAbsent ? "A" : "P"
                componets = [value,value]
            }
            
            s.att_status = componets.joined(separator: "/")
            return s
        }
        
        applyFilterAndSort()
        getAttendanceCounts()
        updateSelectAllCheckbox()
    }
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func submitAttendanceAct(_ sender: Any) {
        
        if areAllStudentsPresent(){
            user_inputs.all_present = "T"
            let alert = CustomAlert()
            alert.showAlertCancel(title:AlertstringFile.Mark_All_as_Presents, message: AlertstringFile.submitAttendanceConfirmation, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self) {
                self.markAttendaceApi()
            } onNo: {}
            
        }else{
            user_inputs.all_present = "F"
            let vc = absentPrivewVC(nibName: nil, bundle: nil)
            vc.StudentList = self.student_List
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            vc.isModalInPresentation = true
            present(vc, animated: true)
        }
        
    }
    
    func areAllStudentsPresent() -> Bool {
        guard let students = student_List else { return false }
        return students.allSatisfy {
            let value = attendanceValue(for: $0)
            return value == "P" || value == "P~"
        }
    }
    
    func getSpecialAttendanceType(for student: AttendanceStudentListDetails) -> [String: String] {
        
        let value = attendanceValue(for: student)
        let splType: String
        
        switch value {
        case "OD":
            splType = "OD"
        case "A":
            splType = "ABSENT"
        case "P~":
            splType = "LATECOMER"
        default:
            splType = "PRESENT"
        }
        return [
            "id": student.id ?? "",
            "spl_attendance_type": splType
        ]
    }
    
    
    func applyFilterAndSort() {
        var result = student_List ?? []
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter { student in
                (student.name?.lowercased().contains(query) ?? false) ||
                (student.roll_no?.lowercased().contains(query) ?? false) ||
                (student.admission_no?.lowercased().contains(query) ?? false)
            }
        }
        switch selectedSort {
        case CommonStringFile.RollNoASC:
            result.sort { ($0.roll_no ?? "").lowercased() < ($1.roll_no ?? "").lowercased() }
        case CommonStringFile.RollNoDESC:
            result.sort { ($0.roll_no ?? "").lowercased() > ($1.roll_no ?? "").lowercased() }
        case CommonStringFile.NameASC:
            result.sort { ($0.name ?? "").lowercased() < ($1.name ?? "").lowercased() }
        case CommonStringFile.NameDESC:
            result.sort { ($0.name ?? "").lowercased() > ($1.name ?? "").lowercased() }
        case CommonStringFile.AdmissionNoASC:
            result.sort { ($0.admission_no ?? "").lowercased() < ($1.admission_no ?? "").lowercased() }
        case CommonStringFile.AdmissionNoDESC:
            result.sort { ($0.admission_no ?? "").lowercased() > ($1.admission_no ?? "").lowercased() }
        default:
            break
        }
        Filtered_stuent_Listt = result
        noDataLbl.isHidden = !(Filtered_stuent_Listt?.isEmpty ?? false)
        noDataImage.isHidden = !(Filtered_stuent_Listt?.isEmpty ?? false)
        tv.reloadData()
    }
    
    
    @IBAction func searchBtnCilck(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected{
            searchBtn.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
            searchStack.isHidden = false
            searchBar.becomeFirstResponder()
        }else{
            searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            searchStack.isHidden = true
            searchBar.resignFirstResponder()
            searchBar.searchTextField.text = ""
            searchQuery = ""
            applyFilterAndSort()
        }
    }
    
    @IBAction func fliter(_ sender: UIButton) {
        dropDown.dataSource = [CommonStringFile.NameASC.translated(),CommonStringFile.NameDESC.translated(),CommonStringFile.RollNoASC.translated(),CommonStringFile.RollNoDESC.translated(),CommonStringFile.AdmissionNoASC,CommonStringFile.AdmissionNoDESC]
        dropDown.anchorView = filterBtn
        dropDown.bottomOffset = CGPoint(x: 0, y: (filterBtn.bounds.height))
        dropDown.direction = .bottom
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.filterBtn.setTitle(item.translated(), for: .normal)
            self.selectedSort =  item
            applyFilterAndSort()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        applyFilterAndSort()
        selectAllBtn.isHidden = !searchText.isEmpty
    }
    
    // MARK: - Attendance Logic Helpers
    
    func attendanceValue(for student: AttendanceStudentListDetails) -> String {
        
        let components = student.att_status?.split(separator: "/").map(String.init) ?? ["P", "P"]
        
        if user_inputs.attendance_type == "H" {
            
            return (user_inputs.session_type == "SH" && components.count > 1) ? components[1] : components[0]
        }else{
            return components.first ?? "P"
        }
    }
    
    func updateAttendance(for studentId:String, to newValue:String) {
        
        guard let index = student_List?.firstIndex(where: {$0.id == studentId}) else { return }
        
        var components = student_List?[index].att_status?.split(separator: "/").map(String.init) ?? ["P", "P"]
        
        if user_inputs.attendance_type == "H" {
            let sessionIndex = (user_inputs.session_type == "SH" && components.count>1) ? 1 : 0
            components[sessionIndex] = newValue
        }else{
            components = [newValue, newValue]
        }
        
        student_List?[index].att_status = components.joined(separator: "/")
        applyFilterAndSort()
    }
    
    func areAllstuentsAbsent() -> Bool {
        guard let studentList = student_List, !studentList.isEmpty else { return false }
        return studentList.allSatisfy{ attendanceValue(for: $0) == "A" }
    }
    
    func updateSelectAllCheckbox() {
        let allAbsent = areAllstuentsAbsent()
        selectAllBtn.setImage(
            UIImage(systemName: allAbsent ? "checkmark.square.fill" : "square"),
            for: .normal
        )
    }
}

extension AttendanceMarkingVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Filtered_stuent_Listt?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.AttendenceTVC, for: indexPath) as! AttendenceTVC
        
        guard let student_data = Filtered_stuent_Listt?[indexPath.row] else {return cell}
        cell.nameLbl.text = student_data.name
        cell.admissionlbl.text = MenuStringFile.ADMIS_No + (student_data.admission_no ?? "")
        cell.rollNoLbl.text = MenuStringFile.Roll_No + (student_data.roll_no ?? "")
        cell.rollNoLbl.isHidden = student_data.roll_no?.isEmpty ?? false
        
        let value = attendanceValue(for: student_data)
        
        switch value{
            
        case "P":
            cell.AttendanceBtn.backgroundColor = .systemGreen
            cell.AttendanceBtn.setTitle("P", for: .normal)
            cell.OnLateBtn.isHidden = false
            cell.OnLateBtn.setImage(UIImage(systemName: "square"), for: .normal)
            cell.ODSwitch.isOn = false
            
        case "A":
            cell.AttendanceBtn.backgroundColor = .systemRed
            cell.AttendanceBtn.setTitle("A", for: .normal)
            cell.OnLateBtn.isHidden = true
            cell.ODSwitch.isOn = false
            
        case "P~":
            cell.AttendanceBtn.backgroundColor = .systemGreen
            cell.AttendanceBtn.setTitle("P", for: .normal)
            cell.OnLateBtn.isHidden = false
            cell.OnLateBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            cell.ODSwitch.isOn = false
            
        case "OD":
            cell.AttendanceBtn.backgroundColor = .systemYellow
            cell.AttendanceBtn.setTitle("OD", for: .normal)
            cell.OnLateBtn.isHidden = true
            cell.ODSwitch.isOn = true
            
        default:
            cell.AttendanceBtn.backgroundColor = .systemGreen
            cell.AttendanceBtn.setTitle("P", for: .normal)
            cell.OnLateBtn.isHidden = false
            cell.OnLateBtn.setImage(UIImage(systemName: "square"), for: .normal)
            cell.ODSwitch.isOn = false
            
        }
        cell.studentId = student_data.id
        cell.delegate = self
        if student_data.is_leave_approved{
            cell.leaveAppliedHeightConst.constant = 25
            cell.LeaveAppliedBtnName.isHidden = false
            cell.LeaveAppliedFullView.backgroundColor = .clear
            cell.reasonLbl.text = student_data.reason
            cell.fromDateLbl.text = student_data.leave_from?.convertToTargetDateFormat() ?? ""
            cell.ToDateLbl.text = student_data.leave_to?.convertToTargetDateFormat() ?? ""
        }else{
            cell.leaveAppliedHeightConst.constant = 0
            cell.LeaveAppliedBtnName.isHidden = true
        }
        cell.leaveApplied = self
        cell.LeaveAppliedBtnName.tag = indexPath.row
        
        if expandedIndex == indexPath.row {
            cell.reasonView.isHidden = false
            cell.fromdateAndTodateStack.isHidden = false
            cell.LeaveAppliedFullView.backgroundColor = .expandAttendaceClr
        } else {
            cell.reasonView.isHidden = true
            cell.fromdateAndTodateStack.isHidden = true
            cell.LeaveAppliedFullView.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension AttendanceMarkingVC: studentAttenance {
    
    func didTapPresentAbsent(for id: String) {
        guard let student = student_List?.first(where: {$0.id == id}) else { return }
        let current = attendanceValue(for: student)
        let newValue = (current == "P" || current == "P~") ? "A" : "P"
        updateAttendance(for: id, to: newValue)
        getAttendanceCounts()
        updateSelectAllCheckbox()
    }
    
    
    func didTapLate(for id: String) {
        guard let student = student_List?.first(where: {$0.id == id}) else { return }
        let current = attendanceValue(for: student)
        let newValue = (current == "P~") ? "P" : "P~"
        updateAttendance(for: id, to: newValue)
        getAttendanceCounts()
        updateSelectAllCheckbox()
    }
    
    func didToggleOD(for id: String, isOn: Bool) {
        let newType = isOn ? "OD" : "P"
        updateAttendance(for: id, to: newType)
        getAttendanceCounts()
        updateSelectAllCheckbox()
    }
}
