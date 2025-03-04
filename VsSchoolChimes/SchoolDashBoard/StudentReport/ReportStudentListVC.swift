//
//  ReportStudentListVC.swift
//  VsSchoolChimes
//
//  Created by admin on 09/12/24.
//

import UIKit
import DropDown

class ReportStudentListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var classView: UIView!
    @IBOutlet weak var reportTable: UITableView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var selectedType: UIButton!
    @IBOutlet weak var sectionBtn: UIButton!
    @IBOutlet weak var clsBtn: UIButton!
    var sectionDropdown = DropDown()
    var classDropdown = DropDown()
    @IBOutlet weak var sectionSelection: UIStackView!
    @IBOutlet weak var classSelection: UIStackView!
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    var selectStudentType = ""
    var studentList = [
        StudentList(name: "chandhru", AdmissionId: "sd123", PhoneNumber: "9597286160", EmailId: "chandhru@gmail.com", DOB: "15/06/2000", fatherName: "Veramalai", teacherName: "janu", gender: "Male",sectionName: "'A'",classname: "8th", img: "shiyam"),
        StudentList(name: "kothai", AdmissionId: "sd124", PhoneNumber: "9597234555", EmailId: "kothai@gmail.com", DOB: "02/08/2000", fatherName: "Mariyappan", teacherName: "janu", gender: "Female",sectionName: "'A'",classname: "8th", img: "StudImg"),
        StudentList(name: "Navin", AdmissionId: "sd125", PhoneNumber: "9597286160", EmailId: "navin@gmail.com", DOB: "14/12/2000", fatherName: "dhdbehr", teacherName: "janu", gender: "Male",sectionName: "'B'",classname: "9th", img:"stuentimg 1"),
        StudentList(name: "Shiyam", AdmissionId: "sd126", PhoneNumber: "9597286160", EmailId: "shiyam@gmail.com", DOB: "15/06/2000", fatherName: "Shiyamksjedhfn", teacherName: "janu", gender: "Male",sectionName: "'A'",classname: "8th", img: "shiyam"),
        StudentList(name: "Nicolash", AdmissionId: "sd127", PhoneNumber: "9597286160", EmailId: "nicolash@gmail.com", DOB: "15/06/2000", fatherName: "Nicolash", teacherName: "janu", gender: "Male",sectionName: "'C'",classname: "9th", img: "shiyam"),
        StudentList(name: "SpRaj", AdmissionId: "sd128", PhoneNumber: "9597286160", EmailId: "spraj@gmail.com", DOB: "15/06/2000", fatherName: "Sivakumar", teacherName: "janu", gender: "Male",sectionName: "'A'",classname: "8th", img: "stuentimg 1"),
        StudentList(name: "Sharmila", AdmissionId: "sd129", PhoneNumber: "9597286160", EmailId: "sharmila@gmail.com", DOB: "15/06/2000", fatherName: "Veramalai", teacherName: "janu", gender: "Female",sectionName: "'C'",classname: "8th", img: "StudImg"),
        StudentList(name: "Kailash", AdmissionId: "sd1210", PhoneNumber: "9597286160", EmailId: "kailash@gmail.com", DOB: "15/06/2000", fatherName: "KailashaNathan", teacherName: "janu", gender: "Male",sectionName: "'A'",classname: "8th", img: "shiyam"),
    ]
    var imgs = ["shiyam","StudImg","stuentimg 1"]
    var filterStudent : [StudentList]?
    var sortedStudent : [StudentList]?
    let menuName = MenuStringFile()
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        searchBar.applyRightTxt()
        filterStudent = studentList
        sortedStudent = studentList
        uiConfic()
        if #available(iOS 14.0, *) {
            addDoneButton()
            searchBar.delegate = self
        }
        classSelection.alpha = 0
        classSelection.transform = CGAffineTransform(translationX: 0, y: -classSelection.bounds.height)
        sectionSelection.alpha = 0
        sectionSelection.transform = CGAffineTransform(translationX: 0, y: -sectionSelection.bounds.height)
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    private func showStackView() {
        classSelection.isHidden = false
        sectionSelection.isHidden = false
        classSelection.alpha = 0
        classSelection.transform = CGAffineTransform(translationX: 0, y: -classSelection.bounds.height)
        sectionSelection.alpha = 0
        sectionSelection.transform = CGAffineTransform(translationX: 0, y: -sectionSelection.bounds.height)
        // Prepare table for animation
        let originalContentOffset = reportTable.contentOffset // Save current offset
        reportTable.contentOffset = CGPoint(x: 0, y: sectionSelection.bounds.height) // Adjust for the animation start position
        
        UIView.animate(withDuration: 0.5, animations: {
            self.classSelection.transform = .identity // Reset transform
            self.classSelection.alpha = 1 // Fully visible
            self.sectionSelection.transform = .identity // Reset transform
            self.sectionSelection.alpha = 1 // Fully visible
            self.reportTable.transform = .identity
            self.reportTable.contentOffset = .zero
        })
        
    }
    
    private func hideStackView() {
        UIView.animate(withDuration: 0.5, animations: {
            // Slide down off the screen and fade out
            self.classSelection.transform = CGAffineTransform(translationX: 0, y: -self.classSelection.bounds.height)
            self.classSelection.alpha = 0
            
        }) { _ in
            // Set isHidden AFTER the animation completes
            self.classSelection.isHidden = true
            self.classSelection.transform = .identity
            self.reportTable.isHidden = false
        }
    }
    
    func hideSectionView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.sectionSelection.transform = CGAffineTransform(translationX: 0, y: -self.sectionSelection.bounds.height)
            self.sectionSelection.alpha = 0
        }) { [self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Delay of 0.2 seconds
                self.hideStackView()
                self.sectionSelection.isHidden = true
                self.sectionSelection.transform = .identity
            }
            
        }
    }
    func uiConfic(){
        reportTable.register(UINib(nibName: CellConfingName.ReportStudentTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.ReportStudentTVC)
        sectionView.layer.cornerRadius = 10
        sectionView.layer.shadowColor = UIColor.black.cgColor
        sectionView.layer.shadowOffset = CGSize(width: 4, height: 4)
        sectionView.layer.shadowOpacity = 0.5
        sectionView.layer.shadowRadius = 4
        classView.layer.cornerRadius = 10
        classView.layer.shadowColor = UIColor.black.cgColor
        classView.layer.shadowOffset = CGSize(width: 4, height: 4)
        filterBtn.layer.cornerRadius = 10
        filterBtn.layer.shadowColor = UIColor.black.cgColor
        filterBtn.layer.shadowOffset = CGSize(width: 4, height: 4)
        filterBtn.layer.shadowOpacity = 0.5
        filterBtn.layer.shadowRadius = 4
        filterBtn.backgroundColor = .white
        
        
        selectedType.layer.cornerRadius = 10
        selectedType.layer.shadowColor = UIColor.black.cgColor
        selectedType.layer.shadowOffset = CGSize(width: 4, height: 4)
        selectedType.layer.shadowOpacity = 0.5
        selectedType.layer.shadowRadius = 4
        selectedType.backgroundColor = .white
        
        
        classView.layer.shadowOpacity = 0.5
        classView.layer.shadowRadius = 4
        sectionSelection.isHidden = true
        classSelection.isHidden = true
        
        //MARK: Label Font
     
        sectionBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        clsBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        selectedType.setTitleFont(style: .body, size: FontSize.BodySize)
        searchBar.placeholder = CommonStringFile.Search.translated()
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func filterStudent(_ sender: UIButton) {
        
        classDropdown.dataSource = [CommonStringFile.RollNoDESC.translated(),CommonStringFile.RollNoASC.translated(),CommonStringFile.NameASC.translated(),CommonStringFile.NameDESC.translated(), CommonStringFile.getAllStudent.translated()]
        classDropdown.anchorView = filterView
        classDropdown.bottomOffset = CGPoint(x:0, y: (filterBtn.bounds.height))
        
        classDropdown.direction = .bottom
        
        classDropdown.show()
        classDropdown.selectionAction = { [self] (index: Int, item: String) in
            self.filterBtn.setTitle(item.translated(), for: .normal)
            
            switch item.translated(){
            case CommonStringFile.RollNoASC.translated():
                let sortedByRollNumber = sortedStudent!.sorted { $0.AdmissionId < $1.AdmissionId }
                filterStudent = sortedByRollNumber
            case CommonStringFile.RollNoDESC.translated():
                let sortedByName = sortedStudent?.sorted { $0.AdmissionId > $1.AdmissionId }
                filterStudent = sortedByName
            case CommonStringFile.NameASC.translated():
                let sortedByName = sortedStudent!.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
                filterStudent = sortedByName
            case CommonStringFile.NameDESC.translated():
                let sortedByName = sortedStudent!.sorted { $0.name > $1.name }
                filterStudent = sortedByName
                
            default:
                filterStudent = sortedStudent
                
            }
            reportTable.reloadData()
            // Update the label inside the UIView
            if let label = self.filterView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self.filterBtn.setTitle(item.translated(), for: .normal)
            }
        }
    }
    @IBAction func selectCatagory(_ sender: UIButton) {
        
        if classSelection.isHidden {
            showStackView()
        } else {
            //            hideStackView()
            hideSectionView()
        }
    }
    
    @IBAction func section(_ sender: UIButton) {
        sectionDropdown.dataSource = ["'A'","'B'","'C'","'D'"]
        
        sectionDropdown.anchorView = sectionView
        sectionDropdown.bottomOffset = CGPoint(x: 0, y: sectionView.bounds.height)
        sectionDropdown.direction = .bottom
        sectionDropdown.width = sectionView.bounds.width
        sectionDropdown.show()
        sectionDropdown.selectionAction = { [self] (index: Int, item: String) in
            let filteredStudents = studentList.filter { $0.classname == selectStudentType && $0.sectionName == item }
            filterStudent = filteredStudents
            sortedStudent = filteredStudents
            reportTable.isHidden = true
            reportTable.reloadData()
            selectedType.setTitle("\(selectStudentType) \(item)", for: .normal)
            self.sectionBtn.setTitle(item, for: .normal)
            hideSectionView()
            if let label = self.sectionDropdown.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self.sectionBtn.setTitle(item.translated(), for: .normal)
            }
        }
    }
    @IBAction func classSelection(_ sender: UIButton) {
        // Configuring the dropdown
        sectionDropdown.dataSource = ["8th","9th","10th", "11th", "12th"]
        
        // Set the position for dropdown relative to sectionView
        sectionDropdown.anchorView = sectionView
        sectionDropdown.bottomOffset = CGPoint(x: 0, y: sectionView.bounds.height - 70)
        sectionDropdown.direction = .bottom
        sectionDropdown.width = sectionView.bounds.width
        // Show the dropdown
        sectionDropdown.show()
        
        // Handling the selection action
        sectionDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            let filteredStudents = studentList.filter { $0.classname == item }
            filterStudent = filteredStudents
            sortedStudent = filteredStudents
            reportTable.reloadData()
            //            selectStudentType += item
            selectStudentType = item
            selectedType.setTitle(item, for: .normal)
            
            // Update the button title
            self.clsBtn.setTitle(item, for: .normal)
            
            // Optionally, set a localized or transformed title
            self.clsBtn.setTitle(item.translated(), for: .normal)
            
            
            // Update the label inside the UIView
            if let label = self.sectionDropdown.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self.clsBtn.setTitle(item.translated(), for: .normal)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterStudent?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reportTable.dequeueReusableCell(withIdentifier: CellConfingName.ReportStudentTVC, for: indexPath) as! ReportStudentTVC
        cell.smsBtn.tag = indexPath.row
        cell.mobleNo.tag = indexPath.row
        cell.emailBtn.tag = indexPath.row
        
        if let studentDetail = filterStudent?[indexPath.row]{
            cell.smsNumber = studentDetail.PhoneNumber
            cell.confic(student: studentDetail)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}


class GradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [
            UIColor(red: 147/255, green: 112/255, blue: 219/255, alpha: 1.0).cgColor, // Purple
            UIColor.white.cgColor // White
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Top-center
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0) // Bottom-center
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 10 // Add corner radius to gradient layer
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = self.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = self.bounds // Ensure gradient resizes with view
            gradientLayer.cornerRadius = 10 // Reapply corner radius on resize
        }
        self.layer.cornerRadius = 10 // Add corner radius to the view itself
        self.clipsToBounds = true // Ensure corners are clipped
    }
}

@available(iOS 14.0, *)
extension ReportStudentListVC: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Reset to full data when the search text is cleared
            filterStudent = studentList
        } else {
            // Filter data based on the search text
            filterStudent = studentList.filter { student in
                student.name.lowercased().contains(searchText.lowercased())
            }
        }
        reportTable.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func addDoneButton(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(DoneBtnAct))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        searchBar.inputAccessoryView = toolbar
    }
    
    @IBAction func DoneBtnAct(){
        
        searchBar.resignFirstResponder()
    }
}
struct StudentList{
    let name:String
    let AdmissionId:String
    let PhoneNumber:String
    let EmailId:String
    let DOB:String
    let fatherName:String
    let teacherName:String
    let gender:String
    let sectionName:String
    let classname:String
    let img : String
}


