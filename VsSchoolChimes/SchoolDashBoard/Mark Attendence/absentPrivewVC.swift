//
//  absentPrivewVC.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 08/10/25.
//

import UIKit
protocol markeAsAbsent : AnyObject {
    func markAsAbsent(AbsentStudent:[StudentDetails],CallAttendaceApi : Bool)
}

class absentPrivewVC: UIViewController, call {
    func callMobileNumber(indexPath: Int) {
        
        let student = abseentessData?[indexPath]
            if let id = student?.id {
                removeAbsentStudent(studentId: id)
            }
    }

    func removeAbsentStudent(studentId: String) {
        // 1️⃣ absenteesData la irundhu remove pannu
        if let index = abseentessData?.firstIndex(where: { $0.id == studentId }) {
            abseentessData?.remove(at: index)
        }
        
        // 2️⃣ studentsDetails la isAbsent = false update pannu
        if let index = studentsDetails?.firstIndex(where: { $0.id == studentId }) {
            studentsDetails?[index].isAbsent = true
        }

        absentStudentLbl.text = "👨🏻‍🎓 Absent Students (\(abseentessData?.count ?? 0))"
        if abseentessData?.count == 0{
            noAbsLbl.isHidden  = false
            noAbsImage.isHidden  = false
            absentPreviewTableView.isHidden = true
            
        }else{
            noAbsLbl.isHidden  = true
            noAbsImage.isHidden  = true
            absentPreviewTableView.isHidden = false
            
            absentPreviewTableView.reloadData()
        }
     
        
    }

    @IBOutlet weak var noAbsLbl: UILabel!
    @IBOutlet weak var noAbsImage: UIImageView!
    @IBOutlet weak var absentStudentLbl: UILabel!
    @IBOutlet weak var markBtnName: UIButton!
    @IBOutlet weak var cancelBtnName: UIButton!
    @IBOutlet weak var notesView: UIView!
    @IBOutlet var absentPreviewTableView: UITableView!
    var abseentessData: [StudentDetails]?
    var studentsDetails: [StudentDetails]?
    @IBOutlet weak var fullview: UIView!
    var delegate:markeAsAbsent?
    override func viewDidLoad() {
        super.viewDidLoad()

        fullview.layer.cornerRadius = 10
        notesView.layer.cornerRadius = 10
        notesView.layer.borderWidth = 1
        notesView.layer.borderColor = UIColor.black
            .withAlphaComponent(0.5).cgColor
        absentPreviewTableView.register(UINib(nibName: CellConfingName.ClassTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.ClassTableViewCell)
        abseentessData = studentsDetails?.filter { $0.isAbsent == false }
        
        
        absentStudentLbl.text = "👨🏻‍🎓 Absent Students (\(abseentessData?.count ?? 0))"
        absentPreviewTableView.delegate = self
        absentPreviewTableView.dataSource = self
        absentPreviewTableView.reloadData()
        markBtnName.setTitleFont(style: .body, size: FontSize.BodySize)
        cancelBtnName.setTitleFont(style: .body, size: FontSize.BodySize)
    }


    @IBAction func canselBtnAct(_ sender: UIButton) {
        delegate?
            .markAsAbsent(
                AbsentStudent: studentsDetails ?? [],
                CallAttendaceApi: false
            )
        dismiss(animated: true)
    }

    @IBAction func markAbscentAct(_ sender: UIButton) {
        
        delegate?
            .markAsAbsent(
                AbsentStudent: studentsDetails ?? [],
                CallAttendaceApi: true
            )
        
        dismiss(animated: true)
        
    }
    
//    func removestudent(withId studentId: String) {
//        // Remove from filtered list
//        studentsDetails = studentsDetails?.filter { $0.id != studentId }
//        abseentessData = studentsDetails
//       
//        print("filteredStudentfilteredStudent",abseentessData)
//        if studentsDetails?.count == 0{
//            delegate?.markAsAbsent(AbsentStudent: abseentessData ?? [])
//            dismiss(animated: true)
//        }
//        absentPreviewTableView.reloadData()
//    }

}
extension absentPrivewVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return abseentessData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ClassTableViewCell, for: indexPath) as? QuizSubmisionTvCell else {
            return UITableViewCell()
        }
        
        let data = abseentessData?[indexPath.row]
//        cell.cellView.layer.cornerRadius = 10
        cell.imageViewWith.constant = 0
        cell.cellView.setShadow()
//        cell.cellView.layer.borderWidth = 1
//        cell.cellView.layer.borderColor = UIColor.red1.cgColor
        cell.StatusBtn.tag = indexPath.row
        cell.StatusBtn.isUserInteractionEnabled = true
        cell.delegate  = self
        cell.nameLbl.text = data?.name
        cell.classLbl.isHidden = data?.roll_no ==  "" ? true : false
        cell.classLbl.text = "Roll no: " + (data?.roll_no ?? "")
        cell.StatusBtn.setTitle("Remove", for: .normal)
        cell.StatusBtn.backgroundColor = .red1
        cell.addmissionLbl.isHidden = data?.admission_no ==  "" ? true : false
        cell.addmissionLbl.text =  "admission no: " + (data?.admission_no ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
