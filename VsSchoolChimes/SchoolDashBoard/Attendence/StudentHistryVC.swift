//
//  StudentHistryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 20/11/24.
//

import UIKit
import DropDown

class StudentHistryVC: UIViewController, UISearchBarDelegate, Attendence {
    func statusUpdate(status: Bool,index:Int) {
        studentData[index].isAbsent = status
        // Calculate the total count of present students
        totalcount = studentData.filter { $0.isAbsent }.count
        if totalcount == 0 {
            // All students are absent
            selectAllBtn.setImage(UIImage(systemName: "checkmark.rectangle.portrait.fill"), for: .normal)
        } else {
            // At least one student is present
            selectAllBtn.setImage(UIImage(systemName: "square"), for: .normal)
        }
    }
    
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var rollNoLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var categoryDropDownView: UIView!
    @IBOutlet weak var historyTable: UITableView!
    
    var dropDown = DropDown()
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
        rollNoLbl.text = CommonStringFile.RollNo.translated()
        nameLbl.text = CommonStringFile.Name.translated()
        statusLbl.text = CommonStringFile.Status.translated()
        HeaderLabel.text = CommonStringFile.Section.translated()
        search.placeholder = CommonStringFile.Search.translated()
        filterBtn.setTitle(CommonStringFile.Filter, for: .normal)
        HeaderLabel.setFont(style: .header, size: FontSize.HeaderSize)
        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        rollNoLbl.setFont(style: .title, size: FontSize.TitleSize)
        statusLbl.setFont(style: .title, size: FontSize.TitleSize)
        filterBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        registerCell()
        filterData = studentData
        search.delegate = self
        headerView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        let categoryGesture = UITapGestureRecognizer(target: self, action: #selector(fliter))
        categoryDropDownView.addGestureRecognizer(categoryGesture)
        
        
        
    }
    @IBAction func fliter(_ sender: UIButton) {
        dropDown.dataSource = [CommonStringFile.RollNoDESC.translated(),CommonStringFile.RollNoASC.translated(),CommonStringFile.NameASC.translated(),CommonStringFile.NameDESC.translated(), CommonStringFile.Absent.translated(),CommonStringFile.Present.translated()]
        dropDown.bottomOffset = CGPoint(x: -90, y: (filterBtn.bounds.height - 110))
        
        dropDown.direction = .bottom
        
        dropDown.show()
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            self.filterBtn.setTitle(item.translated(), for: .normal)
            
            switch item{
            case CommonStringFile.RollNoASC:
                let sortedByRollNumber = studentData.sorted { $0.rollnumber < $1.rollnumber }
                filterData = sortedByRollNumber
            case CommonStringFile.RollNoDESC:
                let sortedByName = studentData.sorted { $0.rollnumber > $1.rollnumber }
                filterData = sortedByName
            case CommonStringFile.NameASC:
                let sortedByName = studentData.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
                filterData = sortedByName
            case CommonStringFile.NameDESC:
                let sortedByName = studentData.sorted { $0.name > $1.name }
                filterData = sortedByName
            case CommonStringFile.Absent:
                
                filterData = studentData.sorted {
                    !$0.isAbsent && $1.isAbsent
                }
            case CommonStringFile.Present:
                filterData = studentData.sorted {
                    $0.isAbsent && !$1.isAbsent // Absent students first
                }
            default:
                filterData = studentData
                
            }
            historyTable.reloadData()
            // Update the label inside the UIView
            if let label = self.categoryDropDownView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self.filterBtn.setTitle(item.translated(), for: .normal)
            }
        }
        
    }
    func registerCell(){
        historyTable.register(UINib(nibName: CellConfingName.AttendenceTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AttendenceTVC)
    }
    @IBAction func selectAllStd(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        // Update data model to mark all students as present/absent
        let isSelectingAll = sender.isSelected
        for i in 0..<studentData.count {
            studentData[i].isAbsent = !isSelectingAll // If selecting all, students are not absent
            
            // Properly access the cell using indexPath, not historyTable.cell
            let indexPath = IndexPath(row: i, section: 0)
            if let customCell = historyTable.cellForRow(at: indexPath) as? AttendenceTVC {
                customCell.custSwitch.isOn = !isSelectingAll // Correct logic for switch
                print(i)
            }
            
        }
        
        // Update select all button image and total count
        if isSelectingAll {
            selectAllBtn.setImage(ImageName.checkmark, for: .normal)
            totalcount = studentData.count
        } else {
            selectAllBtn.setImage(ImageName.square, for: .normal)
            totalcount = 0
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
extension StudentHistryVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.AttendenceTVC, for: indexPath) as! AttendenceTVC
        cell.nameLbl.text = filterData?[indexPath.row].name
        cell.rollNo.setTitle(filterData?[indexPath.row].rollnumber, for: .normal)
        cell.index = indexPath.row
        cell.isAbsent = filterData?[indexPath.row].isAbsent ?? true
        
        cell.delegate = self
        
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
                
                
                cell.statusBtn.setImage(ImageName.apsent, for: .normal)
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
                cell.statusBtn.setImage(ImageName.present, for: .normal)
            },
                              completion: nil)
            totalcount -= 1
        }
        
        let img = totalcount == studentData.count ? ImageName.checkmark : ImageName.square
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
