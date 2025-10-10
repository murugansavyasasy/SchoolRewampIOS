//
//  absentPrivewVC.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 08/10/25.
//

import UIKit
protocol markeAsAbsent : AnyObject {
    func markAsAbsent(AbsentStudent:[StudentDetails])
}
class absentPrivewVC: UIViewController, call {
    func callMobileNumber(indexPath: Int) {
        
        removestudent(withId: studentsDetails?[indexPath].id ?? "")
        
    }

    @IBOutlet var absentPreviewTableView: UITableView!
    var studentsDetails: [StudentDetails]?
    var filteredStudent: [StudentDetails]?
    @IBOutlet weak var fullview: UIView!
    var delegate:markeAsAbsent?
    override func viewDidLoad() {
        super.viewDidLoad()

        fullview.layer.cornerRadius = 10
        
        absentPreviewTableView.register(UINib(nibName: CellConfingName.ClassTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.ClassTableViewCell)
        absentPreviewTableView.delegate = self
        absentPreviewTableView.dataSource = self
        absentPreviewTableView.reloadData()
    }


    @IBAction func canselBtnAct(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func markAbscentAct(_ sender: UIButton) {
        
        delegate?.markAsAbsent(AbsentStudent: filteredStudent ?? [])
        
    }
    
    func removestudent(withId studentId: String) {
        // Remove from filtered list
        studentsDetails = studentsDetails?.filter { $0.id != studentId }
        filteredStudent = studentsDetails
       
        if studentsDetails?.count == 0{
            delegate?.markAsAbsent(AbsentStudent: filteredStudent ?? [])
            dismiss(animated: true)
        }
        absentPreviewTableView.reloadData()
    }

}
extension absentPrivewVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ClassTableViewCell, for: indexPath) as? QuizSubmisionTvCell else {
            return UITableViewCell()
        }
        
        let data = studentsDetails?[indexPath.row]
        cell.cellView.layer.cornerRadius = 10
        cell.imageViewWith.constant = 0
        cell.cellView.layer.borderWidth = 1
        cell.cellView.layer.borderColor = UIColor.red1.cgColor
        cell.StatusBtn.tag = indexPath.row
        cell.StatusBtn.isUserInteractionEnabled = true
        cell.delegate  = self
        cell.nameLbl.text = data?.name
        cell.classLbl.text = data?.roll_no
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
