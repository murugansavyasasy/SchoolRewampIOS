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
            selectAllBtn.setImage(UIImage(systemName: "checkmark.square.portrait.fill"), for: .normal)
        } else {
            // At least one student is present
            selectAllBtn.setImage(UIImage(systemName: "square"), for: .normal)
        }
    }
    
    @IBOutlet weak var HeaderviewHeight: NSLayoutConstraint!
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
    
    var isSelectAllEnabled = false
    var id = 1
    var dataVisibility: [Bool] = []
    var selectedRows: [Bool] = []
    //    var specificdata:[SpecificStudent] = [SpecificStudent(name: "Lakshmanan", rollnumber: "Roll no : 173", admissionNo: "Admission no: 863533"),SpecificStudent(name: "Saranraj shanmugammmmmmmmmmmmmmmmmm", rollnumber: "Roll no : 173", admissionNo: "Admission no: 863533"),SpecificStudent(name: "Murugan", rollnumber: "Roll no : 173", admissionNo: "Admission no: 863533"),SpecificStudent(name: "Chandru", rollnumber: "Roll no : 173", admissionNo: "Admission no: 863533"),SpecificStudent(name: "Sathish", rollnumber: "Roll no : 173", admissionNo: "Admission no: 863533")]
    var specificdata: [SpecificStudent] = [
        SpecificStudent(name: "Aarav", rollnumber: "Roll no: 101", admissionNo: "Admission no: 100001"),
        SpecificStudent(name: "Bhavana", rollnumber: "Roll no: 102", admissionNo: "Admission no: 100002"),
        SpecificStudent(name: "Chirag", rollnumber: "Roll no: 103", admissionNo: "Admission no: 100003"),
        SpecificStudent(name: "Dhruv", rollnumber: "Roll no: 104", admissionNo: "Admission no: 100004"),
        SpecificStudent(name: "Eshwar", rollnumber: "Roll no: 105", admissionNo: "Admission no: 100005"),
        SpecificStudent(name: "Farhan", rollnumber: "Roll no: 106", admissionNo: "Admission no: 100006"),
        SpecificStudent(name: "Gopal", rollnumber: "Roll no: 107", admissionNo: "Admission no: 100007"),
        SpecificStudent(name: "Harini", rollnumber: "Roll no: 108", admissionNo: "Admission no: 100008"),
        SpecificStudent(name: "Ishaan", rollnumber: "Roll no: 109", admissionNo: "Admission no: 100009"),
        SpecificStudent(name: "Jeevan", rollnumber: "Roll no: 110", admissionNo: "Admission no: 100010"),
        SpecificStudent(name: "Karthik", rollnumber: "Roll no: 111", admissionNo: "Admission no: 100011"),
        SpecificStudent(name: "Lakshmanan", rollnumber: "Roll no: 112", admissionNo: "Admission no: 100012"),
        SpecificStudent(name: "Meera", rollnumber: "Roll no: 113", admissionNo: "Admission no: 100013"),
        SpecificStudent(name: "Neha", rollnumber: "Roll no: 114", admissionNo: "Admission no: 100014"),
        SpecificStudent(name: "Omkar", rollnumber: "Roll no: 115", admissionNo: "Admission no: 100015"),
        SpecificStudent(name: "Pranav", rollnumber: "Roll no: 116", admissionNo: "Admission no: 100016"),
        SpecificStudent(name: "Qadir", rollnumber: "Roll no: 117", admissionNo: "Admission no: 100017"),
        SpecificStudent(name: "Rajesh", rollnumber: "Roll no: 118", admissionNo: "Admission no: 100018"),
        SpecificStudent(name: "Saranraj", rollnumber: "Roll no: 119", admissionNo: "Admission no: 100019"),
        SpecificStudent(name: "Tarun", rollnumber: "Roll no: 120", admissionNo: "Admission no: 100020"),
        SpecificStudent(name: "Umesh", rollnumber: "Roll no: 121", admissionNo: "Admission no: 100021"),
        SpecificStudent(name: "Varun", rollnumber: "Roll no: 122", admissionNo: "Admission no: 100022"),
        SpecificStudent(name: "Waseem", rollnumber: "Roll no: 123", admissionNo: "Admission no: 100023"),
        SpecificStudent(name: "Xavier", rollnumber: "Roll no: 124", admissionNo: "Admission no: 100024"),
        SpecificStudent(name: "Yash", rollnumber: "Roll no: 125", admissionNo: "Admission no: 100025"),
        SpecificStudent(name: "Zara", rollnumber: "Roll no: 126", admissionNo: "Admission no: 100026")
    ]
    
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
        
        StyleAndTranslater()
        
        dataVisibility = Array(repeating: false, count: specificdata.count)
        selectedRows = Array(repeating: false, count: specificdata.count)
        if id == 1{
            HeaderviewHeight.constant = 0
            headerView.isHidden = true
        }
        
        registerCell()
        filterData = studentData
        search.delegate = self
        headerView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
        let categoryGesture = UITapGestureRecognizer(target: self, action: #selector(fliter))
        categoryDropDownView.addGestureRecognizer(categoryGesture)
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    func StyleAndTranslater() {
        
        //MARK: Label And Button Font Style
        HeaderLabel.setFont(style: .header, size: FontSize.HeaderSize)
        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        rollNoLbl.setFont(style: .title, size: FontSize.TitleSize)
        statusLbl.setFont(style: .title, size: FontSize.TitleSize)
        filterBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Translation
        rollNoLbl.text = CommonStringFile.RollNo.translated()
        nameLbl.text = CommonStringFile.Name.translated()
        statusLbl.text = CommonStringFile.Status.translated()
        HeaderLabel.text = CommonStringFile.Section.translated()
        search.placeholder = CommonStringFile.Search.translated()
        filterBtn.setTitle(CommonStringFile.Filter, for: .normal)
        
    }
    
    func registerCell(){
        historyTable.register(UINib(nibName: CellConfingName.SpecificStudentTvcell, bundle: nil), forCellReuseIdentifier: CellConfingName.SpecificStudentTvcell)
        historyTable.register(UINib(nibName: CellConfingName.AttendenceTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AttendenceTVC)
        historyTable.register(UINib(nibName: CellConfingName.StudentHistryTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.StudentHistryTVC)
        historyTable.register(UINib(nibName: "MarkAtendenceTV", bundle: nil), forCellReuseIdentifier: "MarkAtendenceTV")
        studentCollection.register(UINib(nibName: "MarkAttendenceCV", bundle: nil), forCellWithReuseIdentifier: "MarkAttendenceCV")
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
    
    @IBAction func selectAllStd(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        // Update data model to mark all students as present/absent
        let isSelectingAll = sender.isSelected
        if id == 2{
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
        }
        else{
            //            for i in 0..<specificdata.count{
            //                let indexPath = IndexPath(row: i, section: 0)
            //                if let customCell = historyTable.cellForRow(at: indexPath) as? SpecificStudentTvcell {
            //                    customCell.CheckBoxImgview.image = UIImage(named: "checked_Tick")
            //                }
            //            }
            isSelectAllEnabled.toggle()
            for i in 0..<specificdata.count {
                let indexPath = IndexPath(row: i, section: 0)
                if let customCell = historyTable.cellForRow(at: indexPath) as? SpecificStudentTvcell {
                    if isSelectAllEnabled {
                        customCell.CheckBoxImgview.image = UIImage(named: "checked_Tick")
                    } else {
                        customCell.CheckBoxImgview.image = UIImage(named: "CheckCircle")
                    }
                }
                
                // Update `selectedRows` to match the state
                selectedRows[i] = isSelectAllEnabled
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
    
    // MARK: Function to get color for a given name
    func colorForName(_ name: String) -> UIColor {
        let firstLetter = name.uppercased().first!
        let color = ColorManager.shared.letterColors[firstLetter]
        return color ?? .gradient1
    }
    
}

extension StudentHistryVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if id == 2{
            return filterData?.count ?? 0
        }else{
            return specificdata.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if id == 1{
            let cell = historyTable.dequeueReusableCell(withIdentifier: CellConfingName.SpecificStudentTvcell, for: indexPath) as! SpecificStudentTvcell
            let backgroundColor = colorForName(specificdata[indexPath.row].name)
            
            cell.NameLbl.text = specificdata[indexPath.row].name
            cell.AdmisionNoLbl.text = specificdata[indexPath.row].admissionNo
            cell.RollNoLbl.text = specificdata[indexPath.row].rollnumber
            if let firstChar = specificdata[indexPath.row].name.first {
                cell.alphabetLbl.text = String(firstChar)
            } else {
                cell.alphabetLbl.text = "" // Fallback for empty string
            }
            cell.AlphabetView.backgroundColor = backgroundColor
            let isSelected = selectedRows[indexPath.row]
            cell.CheckBoxImgview.image = isSelected ? UIImage(named: "checked_Tick") : UIImage(named: "CheckCircle")
            cell.DropdownImg.image = dataVisibility[indexPath.row] ? UIImage(named: "arrow_up") : UIImage(named: "arrow_down")
            
            // Set visibility state
            cell.RollNoLbl.isHidden = !dataVisibility[indexPath.row]
            cell.AdmisionNoLbl.isHidden = !dataVisibility[indexPath.row]
            
            // Configure tap action
            cell.tapAction = { [weak self] in
                self?.handleImageTap(at: indexPath)
            }
            
            return cell
        }
        else{
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
        
    }
    
    
    //            func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    //                return UITableView.automaticDimension
    //            }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if id == 2{
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
        
        else{
            // Toggle the state
            selectedRows[indexPath.row] = !selectedRows[indexPath.row]
            
            // Reload the specific row to update the checkbox image
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func handleImageTap(at indexPath: IndexPath) {
        dataVisibility[indexPath.row].toggle() // Toggle the visibility state
        
        // Reload the specific row
        historyTable.reloadRows(at: [indexPath], with: .automatic)
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
struct SpecificStudent{
    
    var name : String
    var rollnumber : String
    var admissionNo : String
}
