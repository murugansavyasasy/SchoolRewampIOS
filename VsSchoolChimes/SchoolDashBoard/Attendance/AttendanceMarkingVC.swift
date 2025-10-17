//
//  AttendanceMarkingVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 19/09/25.
//

import UIKit
import DropDown

class AttendanceMarkingVC: UIViewController, Attendence, UISearchBarDelegate, markeAsAbsent {
    
    func markAsAbsent(AbsentStudent: [StudentDetails], CallAttendaceApi: Bool) {
        if CallAttendaceApi{
            user_inputs.all_present = "T"
            filterData = AbsentStudent
            studentsDetails = AbsentStudent
            MakeAbsentId = studentsDetails?.filter{ $0.isAbsent == false }.compactMap{ Student in
                print("Absent Studets: ", Student.name ?? "")
                if let id =  Student.id{
                    user_inputs.all_present = "F"
                    return ["ID":id]
                }
                return nil
            } ?? []
            
            self.markAttendaceApi()
            
        }else{
            filterData = AbsentStudent
            studentsDetails = AbsentStudent
            tv.reloadData()
        }
        
    }
    
    func markStudentAsAbsent(studentId: String) {
        filterData = filterData?.map { student in
            var mutableStudent = student
            if student.id == studentId {
                mutableStudent.isAbsent = true
            }
            return mutableStudent
        }
        
        tv.reloadData()
    }
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var rollNoLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var PresentCountView: UIView!
    @IBOutlet weak var AbsentCountView: UIView!
    @IBOutlet weak var PresentCountLbl: UILabel!
    @IBOutlet weak var AbsentCountLbl: UILabel!
    @IBOutlet weak var PresentDefLbl: UILabel!
    @IBOutlet weak var AbsentDefLbl: UILabel!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchStack: UIStackView!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var filterData : [StudentDetails]?
    var abseentessData : [StudentDetails]?
    var studentsDetails: [StudentDetails]?
    var totalcount = 0
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var selected_sectionID = ""
    var selectedAcadimicYearId : Int?
    var StandardString = ""
    var SectionString = ""
    let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    let staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var dropDown = DropDown()
    var  MakeAbsentId: [[String: String]] = []
    
    var student_List: [AttendanceStudentListData]?
    var Filtered_stuent_Listt: [AttendanceStudentListData]?
    var searchQuery: String = ""
    var selectedSort = CommonStringFile.NameASC

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StyleAndTranslater()
        let standard = StandardString + " - " + SectionString
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: standard)
        
        confirmBtn.layer.cornerRadius = 10

        PresentCountView.layer.cornerRadius = 5
        PresentCountView.layer.borderWidth = 0.3
        PresentCountView.layer.borderColor = UIColor.systemGray4.cgColor
        
        AbsentCountView.layer.cornerRadius = 5
        AbsentCountView.layer.borderWidth = 0.3
        AbsentCountView.layer.borderColor = UIColor.systemGray4.cgColor
        
        PresentCountLbl.setFont(style: .title, size: 25)
        AbsentCountLbl.setFont(style: .title, size: 25)
        PresentDefLbl.setFont(style: .body, size: FontSize.BodySize)
        AbsentDefLbl.setFont(style: .body, size: FontSize.BodySize)
        
        filterBtn.setTitle(CommonStringFile.NameASC, for: .normal)
        filterBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        confirmBtn.setTitleFont(style: .body, size: FontSize.TitleSize)
        
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        searchBar.backgroundImage = UIImage()
        searchStack.isHidden = true
        
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
        
        tv.register(UINib(nibName: CellConfingName.AttendenceTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AttendenceTVC)
        tv.delegate = self
        tv.dataSource = self
        Get_student_List_Api()
        recipient_get_student_list(selected_sectionId: Int(selected_sectionID) ?? 0, academic_year_id: selectedAcadimicYearId ?? 0)
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
        //filterBtn.setTitle(CommonStringFile.Filter, for: .normal)
    }
    
    func Get_student_List_Api(){
        
        let param: [String:Any] = [
            MarkAttendenceStringFile.section_id: user_inputs.section_id,
            MarkAttendenceStringFile.attendance_date: user_inputs.attendance_date,
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_api_attendance_student_list, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (result: Result<AttendanceStudentListResponse, Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        self.student_List = success.data
                        self.Filtered_stuent_Listt = self.student_List
                        self.tv.reloadData()
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
            }
        }
    }
    
    
    func recipient_get_student_list(selected_sectionId: Int,academic_year_id:Int){
        
        let param: [String:Any] = [
            speficStudentStringFile.section_id : selected_sectionId,
            speficStudentStringFile.academic_year_id : academic_year_id
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_student_list, parameters:param , type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (result:Result <GetStudentlistSuc,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let successMessage):
                    
                    if successMessage.status == true {
                        self.studentsDetails = successMessage.data?.map { student in
                            var s = student
                            s.isAbsent = true   // 👈 everyone present by default
                            return s
                        }
                        self.filterData = self.studentsDetails
                        self.abseentessData = self.studentsDetails
                        self.PresentCountLbl.text = String(self.studentsDetails?.count ?? 0)
                        self.AbsentCountLbl.text = "0"   // 👈 none absent initially
                        self.tv.reloadData()
                    }else{
                        
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: successMessage.message ?? "", on: self) {
                            self.dismiss(animated: true)
                        }
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: error.localizedDescription, on: self) {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    func markAttendaceApi(){

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
    
    func statusUpdate(status: Bool, index: Int) {
        guard let studentId = filterData?[index].id else { return }
        if let originalIndex = studentsDetails?.firstIndex(where: { $0.id == studentId }) {
            studentsDetails?[originalIndex].isAbsent = status
            filterData?[index].isAbsent = status
//            abseentessData?[index].isAbsent = status
            // Count of students marked as absent
            totalcount = studentsDetails?.filter { $0.isAbsent == false }.count ?? 0
            let PresenrCount = studentsDetails?.filter { $0.isAbsent == true }.count ?? 0
            PresentCountLbl.text = String(PresenrCount)
            AbsentCountLbl.text = String(totalcount)
            let image = totalcount == studentsDetails?.count ?? 0  ? ImageName.checkmark:ImageName.square
            selectAllBtn.setImage(image, for: .normal)
        }
    }
    
    @IBAction func selectAllAct(_ sender: UIButton) {
        
//        sender.isSelected.toggle()
//        
//        // Update data model to mark all students as present/absent
//        let isSelectingAll = sender.isSelected
//            for i in 0..<(studentsDetails?.count ?? 0) {
//                studentsDetails?[i].isAbsent = !isSelectingAll
//                filterData?[i].isAbsent = !isSelectingAll
//                abseentessData?[i].isAbsent = !isSelectingAll
//                let indexPath = IndexPath(row: i, section: 0)
//                if let customCell = tv.cellForRow(at: indexPath) as? AttendenceTVC {
//                    customCell.custSwitch.isOn = !isSelectingAll
//                    customCell.hideLbl(isAbsent: !isSelectingAll)
//                }
//            }
//            // Update select all button image and total count
//            if isSelectingAll {
//                selectAllBtn.setImage(ImageName.checkmark, for: .normal)
//                totalcount = studentsDetails?.count ?? 0
//                AbsentCountLbl.text = String(totalcount)
//                PresentCountLbl.text = "0"
//            } else {
//                selectAllBtn.setImage(ImageName.square, for: .normal)
//                totalcount = 0
//                PresentCountLbl.text = String(studentsDetails?.count ?? 0 )
//                AbsentCountLbl.text = String(totalcount)
//            }
        
        let isAllAbsent = student_List?.allSatisfy {
                ($0.att_type?.uppercased() ?? "") == "ABSENT"
            }
            
           if isAllAbsent == true {
                print("✅ All Absent")
               selectAllBtn.setImage(ImageName.checkmark, for: .normal)
            } else {
                print("⚠️ Some Present or OD/late")
            }
        }
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func submitAttendanceAct(_ sender: Any) {
        
        let isAllPresent = student_List?.allSatisfy {
                ($0.att_type?.uppercased() ?? "") == "PRESENT"
            }
            
           if isAllPresent == true {
                print("✅ All present")
            } else {
                print("⚠️ Some absent or OD/late")
            }
        
        user_inputs.all_present = "T"
        MakeAbsentId = studentsDetails?.filter{ $0.isAbsent == false }.compactMap{ Student in
            print("Absent Studets: ", Student.name ?? "")
            if let id =  Student.id{
                user_inputs.all_present = "F"
                return ["ID":id]
            }
            return nil
        } ?? []
        
        if MakeAbsentId.count == 0{
            
            let alert = CustomAlert()
            alert.showAlertCancel(title:AlertstringFile.Mark_All_as_Presents, message: AlertstringFile.submitAttendanceConfirmation, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self) {
                self.markAttendaceApi()
            } onNo: {
                
            }
        }else{
            
            let vc = absentPrivewVC(nibName: nil, bundle: nil)
            vc.studentsDetails = studentsDetails
            vc.delegate = self
            vc.modalPresentationStyle = .formSheet
            // ✅ Prevent drag-down dismiss
            vc.isModalInPresentation = true
            present(vc, animated: true)
            
        }
        
        

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
                result.sort { ($0.roll_no ?? "") < ($1.roll_no ?? "") }
            case CommonStringFile.RollNoDESC:
                result.sort { ($0.roll_no ?? "") > ($1.roll_no ?? "") }
            case CommonStringFile.NameASC:
                result.sort { ($0.name ?? "") < ($1.name ?? "") }
            case CommonStringFile.NameDESC:
                result.sort { ($0.name ?? "") > ($1.name ?? "") }
            case CommonStringFile.AdmissionNoASC:
                result.sort { ($0.admission_no ?? "") < ($1.admission_no ?? "") }
            case CommonStringFile.AdmissionNoDESC:
                result.sort { ($0.admission_no ?? "") > ($1.admission_no ?? "") }
            default:
                break
            }
        
        // 4️⃣ Update the filtered data source
        Filtered_stuent_Listt = result
        tv.reloadData()
    }

    
    @IBAction func searchBtnCilck(_ sender: UIButton) {
        sender.isSelected.toggle()
        searchStack.isHidden = !sender.isSelected
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        searchBtn.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    @IBAction func fliter(_ sender: UIButton) {
        dropDown.dataSource = [CommonStringFile.NameASC.translated(),CommonStringFile.NameDESC.translated(), CommonStringFile.Absent.translated(),CommonStringFile.Present.translated(),CommonStringFile.RollNoASC.translated(),CommonStringFile.RollNoDESC.translated(),CommonStringFile.AdmissionNoASC,CommonStringFile.AdmissionNoDESC]
        dropDown.anchorView = filterBtn
        dropDown.bottomOffset = CGPoint(x: 0, y: (filterBtn.bounds.height))
        
        dropDown.direction = .bottom
        
        dropDown.show()
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.filterBtn.setTitle(item.translated(), for: .normal)
            
            // Save selected sort
            self.selectedSort =  item
            
            applyFilterAndSort()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText
        applyFilterAndSort()
        
        selectAllBtn.isHidden = !searchText.isEmpty
    }

}

extension AttendanceMarkingVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Filtered_stuent_Listt?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.AttendenceTVC, for: indexPath) as! AttendenceTVC
        
        let student_data = Filtered_stuent_Listt?[indexPath.row]
        
        cell.nameLbl.text = student_data?.name
        cell.admissionlbl.text = "ADMIS No: " + (student_data?.admission_no ?? "")
        cell.rollNoLbl.text = "Roll No: " + (student_data?.roll_no ?? "")
        
        switch student_data?.att_type{
            
        case "PRESENT":
            cell.AttendanceBtn.backgroundColor = .systemGreen
            cell.AttendanceBtn.setTitle("P", for: .normal)
            cell.OnLateBtn.isHidden = false
            cell.OnLateBtn.setImage(UIImage(systemName: "square"), for: .normal)
            cell.ODSwitch.isOn = false
            
        case "ABSENT":
            cell.AttendanceBtn.backgroundColor = .systemRed
            cell.AttendanceBtn.setTitle("A", for: .normal)
            cell.OnLateBtn.isHidden = true
            cell.ODSwitch.isOn = false
            
        case "LATECOMER":
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
        
//        cell.hideLbl(isAbsent: filterData?[indexPath.row].isAbsent ?? true)
//        cell.custSwitch.isOn = filterData?[indexPath.row].isAbsent ?? true
//        cell.phnBtn.tag = indexPath.row
//        cell.phnBtn.isHidden = true
//        cell.custSwitch.index = indexPath.row
        cell.studentId = student_data?.id
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
    
extension AttendanceMarkingVC: studentAttenance {

    func didTapPresentAbsent(for id: String) {
        
        guard let filteredList = Filtered_stuent_Listt,
              let filterIndex = filteredList.firstIndex(where: { $0.id == id }) else { return }
        
        let currentType = filteredList[filterIndex].att_type

            let newType: String
            if currentType == "ABSENT" || currentType == "OD" {
                newType = "PRESENT"
            } else if currentType == "PRESENT" || currentType == "LATECOMER" {
                newType = "ABSENT"
            } else {
                newType = "PRESENT"
            }
        
        Filtered_stuent_Listt?[filterIndex].att_type = newType
        
        if let mainList = student_List,
           let index = mainList.firstIndex(where: { $0.id == id }) {
            student_List?[index].att_type = newType
        }
        
        tv.reloadRows(at: [IndexPath(row: filterIndex, section: 0)], with: .automatic)
    }
    

    func didTapLate(for id: String) {
        
        guard let filteredList = Filtered_stuent_Listt,
              let filterIndex = filteredList.firstIndex(where: { $0.id == id }) else { return }

        let currentType = filteredList[filterIndex].att_type
        let newType: String
        
        if currentType == "LATECOMER"{
             newType = "PRESENT"
        }else{
            newType = "LATECOMER"
        }

        Filtered_stuent_Listt?[filterIndex].att_type = newType
       
        if let mainList = student_List,
           let index = mainList.firstIndex(where: { $0.id == id }) {
            student_List?[index].att_type = newType
        }

        tv.reloadRows(at: [IndexPath(row: filterIndex, section: 0)], with: .automatic)
    }

    func didToggleOD(for id: String, isOn: Bool) {
        
        guard let filteredList = Filtered_stuent_Listt,
              let filterIndex = filteredList.firstIndex(where: { $0.id == id }) else { return }

        let newType = isOn ? "OD" : "PRESENT"
        
        Filtered_stuent_Listt?[filterIndex].att_type = newType

        if let mainList = student_List,
           let index = mainList.firstIndex(where: { $0.id == id }) {
            student_List?[index].att_type = newType
        }

        tv.reloadRows(at: [IndexPath(row: filterIndex, section: 0)], with: .automatic)
    }
}
