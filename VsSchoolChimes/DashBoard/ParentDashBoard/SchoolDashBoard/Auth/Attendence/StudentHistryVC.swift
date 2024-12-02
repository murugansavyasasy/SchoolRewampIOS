//
//  StudentHistryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 20/11/24.
//

import UIKit

class StudentHistryVC: UIViewController, UISearchBarDelegate, Attendence {
    func statusUpdate(status: Bool,index:Int) {
        print("\(status) \(index)")
    }
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var rollNoLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var historyTable: UITableView!
    var studentData:[Student] = [Student(name: "viswah", isAbsent: true, rollnumber: "76979871", phoneNo: "9087654321"),
                                 Student(name: "chandhru", isAbsent: true, rollnumber: "76979871", phoneNo: "9597296160"),
                                 Student(name: "kothai", isAbsent: true, rollnumber: "76979872", phoneNo: "9360183031"),
                                 Student(name: "shiyam", isAbsent: true, rollnumber: "76979873", phoneNo: "98762356335"),
                                 Student(name: "Navin", isAbsent: true, rollnumber: "76979874", phoneNo: "7456792347"),
                                 Student(name: "Nicolash", isAbsent: true, rollnumber: "76979875", phoneNo: "9835546472"),
                                 Student(name: "sharmila", isAbsent: true, rollnumber: "76979876", phoneNo: "89873456543"),
                                 Student(name: "sharmila", isAbsent: true, rollnumber: "76979877", phoneNo: "89873456543"),
                                 Student(name: "Navin", isAbsent: true, rollnumber: "76979878", phoneNo: "7456792347"),
                                 Student(name: "kothai", isAbsent: true, rollnumber: "76979879", phoneNo: "9360183031"),
                                 Student(name: "kothai", isAbsent: true, rollnumber: "769798710", phoneNo: "9360183031")]
    var img = ["shiyam","stuentimg 1"]
    var totalcount = 0
    var filterData : [Student]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HeaderLabel.setFont(style: .header, size: FontSize.HeaderSize)
        selectAllBtn.setTitleFont(style: .body, size: FontSize.BodySize)

        registerCell()
        filterData = studentData
        search.delegate = self
        headerView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    func registerCell(){
        historyTable.register(UINib(nibName: "AttendenceTVC", bundle: nil), forCellReuseIdentifier: "AttendenceTVC")
    }
    @IBAction func selectAllStd(_ sender: UIButton) {
        sender.isSelected.toggle()
        for i in 0..<studentData.count {
            studentData[i].isAbsent = !sender.isSelected// Update your data model appropriately
          }
        if !sender.isSelected{
            selectAllBtn.setImage(UIImage(systemName: "square"), for: .normal)
            totalcount = 0
        }else{
            totalcount = studentData.count
            selectAllBtn.setImage(UIImage(systemName: "checkmark.rectangle.portrait.fill"), for: .normal)
        }
        
          // Reload the entire table view to reflect the changes
        historyTable.reloadData()
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
extension StudentHistryVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttendenceTVC", for: indexPath) as! AttendenceTVC
        cell.nameLbl.text = filterData?[indexPath.row].name
        cell.rollNo.setTitle(filterData?[indexPath.row].rollnumber, for: .normal)
        if let student = filterData?[indexPath.row] {
               cell.configure(with: student, index: indexPath.row)
           }
        cell.delegate = self
//        let student = studentData[indexPath.row]
//
//        cell.outerView.layer.borderColor = student.isAbsent ? UIColor.clear.cgColor : UIColor.red.cgColor
//        cell.outerView.layer.borderWidth = student.isAbsent ? 0 : 1
//        let statusImage = student.isAbsent ? UIImage(named: "p") : UIImage(named: "a")
////        if indexPath.row % 2 == 0 {
////            cell.stdImage.image = UIImage(named: img[0])
////        } else {
////            cell.stdImage.image = UIImage(named: img[1])
////        }
//        cell.statusBtn.setImage(statusImage, for: .normal)
//        cell.nameLbl.text = studentData[indexPath.row].name
//        cell.rollNomber.text = studentData[indexPath.row].rollnumber
//        let title = studentData[indexPath.row].phoneNo
//        let attributedTitle = NSAttributedString(string: title, attributes: [
//            .underlineStyle: NSUnderlineStyle.single.rawValue
//        ])
//
//        // Use `setAttributedTitle` to set the attributed text on the button
//        cell.phnBtn.setAttributedTitle(attributedTitle, for: .normal)

        return cell
    }

    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? StudentHistryTVC
        studentData[indexPath.row].isAbsent.toggle()
        // Ensure the cell exists before performing animation
        guard let cell = cell else { return }
        if studentData[indexPath.row].isAbsent == false{
            // Create the flip animation
            UIView.transition(with: cell.outerView,
                              duration: 0.3,
                              options: [.transitionFlipFromTop],  // Change direction as needed
                              animations: {
                // Change background color to red
                cell.outerView.layer.borderColor = UIColor.red.cgColor
                cell.outerView.layer.borderWidth = 1
              
                
                cell.statusBtn.setImage(UIImage(named: "a"), for: .normal)
            },
                              completion: nil)
            totalcount += 1
        }else{
            UIView.transition(with: cell.outerView,
                              duration: 0.3,
                              options: [.transitionFlipFromBottom],  // Change direction as needed
                              animations: {
                // Change background color to red
                cell.outerView.layer.borderColor = UIColor.clear.cgColor
                cell.statusBtn.setImage(UIImage(named: "p"), for: .normal)
            },
                              completion: nil)
            totalcount -= 1
        }
        
        let img = totalcount == studentData.count ? UIImage(systemName: "checkmark.rectangle.portrait.fill") : UIImage(systemName: "square")
        selectAllBtn.setImage(img, for: .normal)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Reset to full data when the search text is cleared
            filterData = studentData
        } else {
            // Filter data based on the search text
            filterData = studentData.filter { student in
                student.name.lowercased().contains(searchText.lowercased())
            }
        }
        historyTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss the keyboard
    }
}
struct Student {
    var name: String
    var isAbsent: Bool
    var rollnumber:String
    var phoneNo:String
}
