//
//  absentPrivewVC.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 08/10/25.
//

import UIKit
protocol markeAsAbsent : AnyObject {
    func markAsAbsent(AbsentStudent:[AttendanceStudentListDetails],CallAttendaceApi : Bool)
}
class absentPrivewVC: UIViewController, call {
    func callMobileNumber(indexPath: Int) {
        removeAbsentStudent(index: indexPath)
    }
    func removeAbsentStudent(index: Int) {
        guard index < Filtered_StudentList?.count ?? 0 else {return}
        let removeStudent = Filtered_StudentList?[index]
        if let mainIndex = StudentList?.firstIndex(where: {$0.id == removeStudent?.id}) {
            var components = StudentList?[mainIndex].att_status?.split(separator: "/").map(String.init) ?? ["P", "P"]
            if user_inputs.attendance_type == "H"{
                if user_inputs.session_type == "FH"{
                    components[0] = "P"
                }else{
                    if components.count>1 {
                        components[1] = "P"
                    }
                }
            }else{
                components[0] = "P"
            }
            StudentList?[mainIndex].att_status = components.joined(separator: "/")
            Filtered_StudentList?.remove(at: index)
            tableview.reloadData()
            if Filtered_StudentList?.isEmpty == true{
                if Filter_Value == "A"{
                    noAbsLbl.text = "No Absent Students"
                }else if Filter_Value == "P~"{
                    noAbsLbl.text = "No Late Students"
                }else{
                    noAbsLbl.text = "No OD Students"
                }
                noAbsImage.isHidden = false
                noAbsLbl.isHidden = false
            }else{
                noAbsImage.isHidden = true
                noAbsLbl.isHidden = true
            }
            getAttendanceCounts()
        }
    }
    
    @IBOutlet weak var noAbsLbl: UILabel!
    @IBOutlet weak var noAbsImage: UIImageView!
    @IBOutlet weak var absentStudentLbl: UILabel!
    @IBOutlet weak var markBtnName: UIButton!
    @IBOutlet weak var cancelBtnName: UIButton!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var AbsentBtn: UIButton!
    @IBOutlet weak var LateBtn: UIButton!
    @IBOutlet weak var ODBtn: UIButton!
    
    var delegate:markeAsAbsent?
    var StudentList:[AttendanceStudentListDetails]?
    var Filtered_StudentList:[AttendanceStudentListDetails]?
    var Filter_Value = "A"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullview.layer.cornerRadius = 10
        notesView.layer.cornerRadius = 10
        notesView.layer.borderWidth = 1
        notesView.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        tableview.register(UINib(nibName: CellConfingName.ClassTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.ClassTableViewCell)
        addUnderline(to: AbsentBtn, unSelectedBtn: [LateBtn,ODBtn])
        getAttendanceCounts()
        Apply_filter()
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
        markBtnName.setTitleFont(style: .body, size: FontSize.BodySize)
        cancelBtnName.setTitleFont(style: .body, size: FontSize.BodySize)
    }
    
    func addUnderline(to selectedButton: UIButton, unSelectedBtn: [UIButton]) {
        ([selectedButton] + unSelectedBtn).forEach { button in
            button.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
            button.tintColor = .black
        }
        selectedButton.tintColor = .systemBlue
        let underline = UIView()
        underline.tag = 999
        underline.backgroundColor = .systemBlue
        underline.translatesAutoresizingMaskIntoConstraints = false
        selectedButton.addSubview(underline)
        
        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: selectedButton.bottomAnchor)
        ])
    }
    func Apply_filter(){
        Filtered_StudentList = StudentList?.filter{ student in
            let components = student.att_status?.split(separator: "/").map(String.init) ?? []
            var value = ""
            if user_inputs.attendance_type == "H" {
                if user_inputs.session_type == "FH"{
                    value = components.first ?? ""
                }else{
                    value = (components.count > 1 ? components[1] : components.first) ?? ""
                    print("Value",value)
                }
            }else{
                value = components.first ?? ""
            }
            return value == Filter_Value
        }
        if Filtered_StudentList?.isEmpty == true{
            if Filter_Value == "A"{
                noAbsLbl.text = "No Absent Students"
            }else if Filter_Value == "P~"{
                noAbsLbl.text = "No Late Students"
            }else{
                noAbsLbl.text = "No OD Students"
            }
            DispatchQueue.main.async {
                self.noAbsImage.isHidden = false
                self.noAbsLbl.isHidden = false
            }
        }else{
            noAbsImage.isHidden = true
            noAbsLbl.isHidden = true
        }
        tableview.reloadData()
    }
    
    func getAttendanceCounts() /*-> (present: Int, absent: Int, od: Int)*/ {
        // Safely unwrap your global array
        guard let students = StudentList else {
            return //(0, 0, 0)
        }
        // Transform each student into their spl_attendance_type
        let statuses: [String] = students.map { student in
            let components = student.att_status?.split(separator: "/").map(String.init) ?? []
            var value = ""
            if user_inputs.attendance_type == "H" {
                if user_inputs.session_type == "FH" {
                    value = components.first ?? ""
                } else if user_inputs.session_type == "SH" {
                    value = components.count > 1 ? components[1] : (components.first ?? "")
                }
            }else {
                value = components.first ?? ""
            }
            // Normalize to one of: PRESENT, ABSENT, OD
            switch value {
            case "OD":
                return "OD"
            case "A":
                return "ABSENT"
            case "P~":
                return "Late"
            default:
                return "PRESENT"
            }
        }
        // Count occurrences
        let LateCount = statuses.filter { $0 == "Late" }.count
        let absentCount = statuses.filter { $0 == "ABSENT" }.count
        let odCount = statuses.filter { $0 == "OD" }.count
        let absentTitle = "\("Absent") (\(String(absentCount)))"
        let OdTitle = "\("OD") (\(String(odCount)))"
        let LateTitle = "\("Late") (\(String(LateCount)))"
        AbsentBtn.setTitle(absentTitle, for: .normal)
        LateBtn.setTitle(LateTitle, for: .normal)
        ODBtn.setTitle(OdTitle, for: .normal)
        
    }
    
    @IBAction func AbsentBtnAct(_ sender: UIButton) {
        addUnderline(to: AbsentBtn, unSelectedBtn: [LateBtn,ODBtn])
        Filter_Value = "A"
        Apply_filter()
    }
    
    @IBAction func OdBtnAct(_ sender: UIButton) {
        addUnderline(to: ODBtn, unSelectedBtn: [LateBtn,AbsentBtn])
        Filter_Value = "OD"
        Apply_filter()
    }
    
    @IBAction func LateBtnAct(_ sender: UIButton) {
        addUnderline(to: LateBtn, unSelectedBtn: [AbsentBtn,ODBtn])
        Filter_Value = "P~"
        Apply_filter()
    }
    
    @IBAction func canselBtnAct(_ sender: UIButton) {
        delegate?
            .markAsAbsent(
                AbsentStudent: StudentList ?? [],
                CallAttendaceApi: false)
        dismiss(animated: true)
    }
    
    @IBAction func markAbscentAct(_ sender: UIButton) {
        delegate?
            .markAsAbsent(
                AbsentStudent: StudentList ?? [],
                CallAttendaceApi: true)
        dismiss(animated: true)
    }
}

extension absentPrivewVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Filtered_StudentList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ClassTableViewCell, for: indexPath) as? QuizSubmisionTvCell else {
            return UITableViewCell()
        }
        let data = Filtered_StudentList?[indexPath.row]
        cell.imageViewWith.constant = 0
        cell.cellView.setShadow()
        cell.StatusBtn.tag = indexPath.row
        cell.StatusBtn.isUserInteractionEnabled = true
        cell.delegate  = self
        cell.nameLbl.text = data?.name
        cell.classLbl.isHidden = data?.roll_no ==  "" ? true : false
        cell.classLbl.text = MenuStringFile.Roll_No + (data?.roll_no ?? "")
        cell.StatusBtn.setTitle(MenuStringFile.Remove, for: .normal)
        cell.StatusBtn.backgroundColor = .red1
        cell.addmissionLbl.isHidden = data?.admission_no ==  "" ? true : false
        cell.addmissionLbl.text =  MenuStringFile.admission_no + (data?.admission_no ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
