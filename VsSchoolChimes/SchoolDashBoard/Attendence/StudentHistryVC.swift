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
        filterData?[index].isAbsent = status
        // Calculate the total count of present students
        totalcount = studentData.filter { $0.isAbsent == true }.count
        if totalcount == 0 {
            // All students are absent
            selectAllBtn.setImage(UIImage(systemName: "checkmark.rectangle.portrait.fill"), for: .normal)
        } else {
            // At least one student is present
            selectAllBtn.setImage(UIImage(systemName: "square"), for: .normal)
        }
    }
    
    @IBOutlet weak var studentCollection: UICollectionView!
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
    var switchCell = 1
    var dropDown = DropDown()
    var studentData:[Student] = [Student(name: "viswahSGDFHWEEAHGSVVDVFWYDSfcwgsadcdg2cwqgascdg", isAbsent: false, rollnumber: "76979871", phoneNo: "9087654321"),
                                 Student(name: "chandhru", isAbsent: false, rollnumber: "76979871", phoneNo: "9597296160"),
                                 Student(name: "kothai", isAbsent: false, rollnumber: "76979872", phoneNo: "9360183031"),
                                 Student(name: "shiyam", isAbsent: false, rollnumber: "76979873", phoneNo: "98762356335"),
                                 Student(name: "Navin", isAbsent: false, rollnumber: "76979874", phoneNo: "7456792347"),
                                 Student(name: "Nicolash", isAbsent: false, rollnumber: "76979875", phoneNo: "9835546472"),
                                 Student(name: "sharmila", isAbsent: false, rollnumber: "76979876", phoneNo: "89873456543"),
                                 Student(name: "sharmila", isAbsent: false, rollnumber: "76979877", phoneNo: "89873456543"),
                                 Student(name: "Navin", isAbsent: false, rollnumber: "76979878", phoneNo: "7456792347"),
                                 Student(name: "kothai", isAbsent: false, rollnumber: "76979879", phoneNo: "9360183031"),
                                 Student(name: "kothai", isAbsent: false, rollnumber: "769798710", phoneNo: "9360183031")]
    var img = ["shiyam","stuentimg 1"]
    var totalcount = 0
    var filterData : [Student]?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
        
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
        dropDown.anchorView = filterBtn
        dropDown.bottomOffset = CGPoint(x: 0, y: (filterBtn.bounds.height))
        
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
        historyTable.register(UINib(nibName: CellConfingName.StudentHistryTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.StudentHistryTVC)
        historyTable.register(UINib(nibName: "MarkAtendenceTV", bundle: nil), forCellReuseIdentifier: "MarkAtendenceTV")
        studentCollection.register(UINib(nibName: "MarkAttendenceCV", bundle: nil), forCellWithReuseIdentifier: "MarkAttendenceCV")
    }
    @IBAction func selectAllStd(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        // Update data model to mark all students as present/absent
        let isSelectingAll = sender.isSelected
        for i in 0..<studentData.count {
            studentData[i].isAbsent = !isSelectingAll // If selecting all, students are not absent
            filterData?[i].isAbsent = !isSelectingAll
            
            // Properly access the cell using indexPath, not historyTable.cell
            let indexPath = IndexPath(row: i, section: 0)
            if let customCell = historyTable.cellForRow(at: indexPath) as? AttendenceTVC {
                customCell.custSwitch.isOn = isSelectingAll
                customCell.hideLbl(isAbsent: isSelectingAll)
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
        if switchCell == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.StudentHistryTVC, for: indexPath) as! StudentHistryTVC
            cell.nameLbl.text = filterData?[indexPath.row].name
            cell.AdmisNomber.text = filterData?[indexPath.row].phoneNo
            cell.rollNomber.text = filterData?[indexPath.row].rollnumber
            let img = filterData?[indexPath.row].isAbsent  ?? false ? ImageName.apsent : ImageName.present
            cell.statusBtn.setImage(img, for: .normal)
            cell.outerView.layer.borderColor = filterData?[indexPath.row].isAbsent ?? false ? UIColor.red.cgColor : Colornames.AprovedClr?.cgColor
            cell.outerView.layer.borderWidth = 1
            
            return cell
        }else if switchCell == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.AttendenceTVC, for: indexPath) as! AttendenceTVC
            cell.nameLbl.text = filterData?[indexPath.row].name
            cell.rollNo.setTitle(filterData?[indexPath.row].rollnumber, for: .normal)
            cell.hideLbl(isAbsent: filterData?[indexPath.row].isAbsent ?? true)
            cell.custSwitch.isOn = filterData?[indexPath.row].isAbsent ?? true
            cell.phnBtn.tag = indexPath.row
            cell.phnBtn.setTitle(filterData?[indexPath.row].phoneNo, for: .normal)
            cell.custSwitch.index = indexPath.row
            cell.delegate = self
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MarkAtendenceTV", for: indexPath) as! MarkAtendenceTV
            cell.nameLbl.text = filterData?[indexPath.row].name
            cell.addmisionLbl.text = filterData?[indexPath.row].phoneNo
            cell.rollNoLbl.text = filterData?[indexPath.row].rollnumber
            let img = filterData?[indexPath.row].isAbsent  ?? false ? ImageName.apsent : ImageName.present
            cell.btnView.backgroundColor = filterData?[indexPath.row].isAbsent  ?? false ? UIColor.red : Colornames.AprovedClr
            let name = filterData?[indexPath.row].isAbsent  ?? false ? "Absent" : "Present"
            cell.btnView.layer.cornerRadius = 20
           
            cell.stsBtn.setTitle(name, for: .normal)
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? StudentHistryTVC
        //        studentData[indexPath.row].isAbsent.toggle()
        // Ensure the cell exists before performing animation
        guard let cell = cell else { return }
        if studentData[indexPath.row].isAbsent == true{
            // Create the flip animation
            UIView.transition(with: cell.outerView,
                              duration: 0.3,
                              options: [.transitionFlipFromTop],  // Change direction as needed
                              animations: {
                // Change background color to red
                cell.outerView.layer.borderColor = Colornames.AprovedClr?.cgColor
                cell.outerView.layer.borderWidth = 1
                self.studentData[indexPath.row].isAbsent = false
                cell.statusBtn.setImage(ImageName.present, for: .normal)
            },
                              completion: nil)
            totalcount += 1
        }else{
            UIView.transition(with: cell.outerView,
                              duration: 0.3,
                              options: [.transitionFlipFromBottom],  // Change direction as needed
                              animations: {
                // Change background color to red
                cell.outerView.layer.borderColor = UIColor.red.cgColor
                cell.statusBtn.setImage(ImageName.apsent, for: .normal)
                self.studentData[indexPath.row].isAbsent = true
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
extension StudentHistryVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = studentCollection.dequeueReusableCell(withReuseIdentifier: "MarkAttendenceCV", for: indexPath) as! MarkAttendenceCV
        cell.nameLbl.text = "Name :\(filterData?[indexPath.item].name ?? "")"
        cell.admissionLbl.text = "ADMIS No :\(filterData?[indexPath.item].phoneNo ?? "")"
        cell.rollNoLbl.text = "Roll No:\(filterData?[indexPath.item].rollnumber ?? "")"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = (studentCollection.frame.width - 40) / 2
        return CGSize(width: cellWidth, height: 220)
    }
    func calculateLabelHeight(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        return ceil(boundingBox.height)
    }
}

struct Student {
    var name: String
    var isAbsent: Bool
    var rollnumber:String
    var phoneNo:String
}
