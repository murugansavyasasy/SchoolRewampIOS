////
////  AssignmentReport.swift
////  School Chimes
////
////  Created by Chandhru on 18/06/25.
////
//
//import UIKit
//import DropDown
//
//class AssignmentReport: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
//    @IBOutlet weak var noDataStack: UIStackView!
//    @IBOutlet weak var acodemicView: UIView!
//    @IBOutlet weak var acodemicdropView: UIView!
//    @IBOutlet weak var acodomicYearLbl: UILabel!
//    @IBOutlet weak var searchview: UISearchBar!
//    @IBOutlet weak var reportTable: UITableView!
//    @IBOutlet weak var nodataLbl: UILabel!
//    @IBOutlet weak var noRecordImg: UIImageView!
//    var data : [Report]?
//    var filteredData :[Report]?
//    let acidamicdrops = DropDown()
//    let alert = CustomAlert()
//    var acodemicId: Int?
//    var AcadimicYearDatas: [AcadimicYearData] = []
//    var accadimYr: [String] = []
//    var shouldShowFooter = true
//    var tapGesture: UITapGestureRecognizer?
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        getacadmicYr()
//        reportTable.register(UINib(nibName: CellConfingName.AssignmentListCTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AssignmentListCTVC)
//        reportTable.delegate = self
//        reportTable.dataSource = self
//        searchview.placeholder = CommonStringFile.Search.translated()
//        searchview.delegate = self
//        searchview.layer.borderWidth = 0
//        searchview.backgroundImage = UIImage()
//        searchview.searchTextField.addDoneButton()
//        getAssigment()
//        applyShadowAndCornerRadius(to: acodemicView)
//        acodemicView.layer.borderColor = UIColor.lightGray.cgColor
//        acodemicView.layer.borderWidth = 0.5
//    }
//    func getacadmicYr() {
//        accadimYr = localData.accidamic_year_data?.data?.compactMap { $0.year } ?? []
//        AcadimicYearDatas = localData.accidamic_year_data?.data ?? []
//        acodomicYearLbl.text = accadimYr.last ?? ""
//        acodemicId = localData.accidamic_year_data?.data?.last?.id ?? 0
//    }
//    func getAssigment() {
//        APIService.shared.makeApi(
//            url: ServiceUrl.comm_api_assignment_report,
//            parameters: ["academic_year_id":acodemicId ?? 0],
//            type: ApitTypeSringFile.GET,
//            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
//        ) { [weak self] (result: Result<AssignmentReportResponse, Error>) in
//            switch result {
//            case .success(let response):
//                    DispatchQueue.main.async {
//                        self?.data = response.data ?? []
//                        self?.filteredData = self?.data
//                        let isEmpty = self?.data?.isEmpty ?? true
//                        self?.nodataLbl.isHidden = !isEmpty
//                        self?.nodataLbl.text = isEmpty ? response.message : ""
//                        self?.noRecordImg.isHidden = !isEmpty
//                        self?.reportTable.isHidden = isEmpty
//                        self?.reportTable.reloadData()
//
//                }
//            case .failure(let error):
//                print("API Error: \(error.localizedDescription)")
//            }
//        }
//    }
//   
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredData?.count ?? 0 // Adjust this based on your data
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = reportTable.dequeueReusableCell(withIdentifier: CellConfingName.AssignmentListCTVC, for: indexPath) as! AssignmentListCTVC
//        cell.tittleLbl.text = filteredData?[indexPath.row].title
//        if !isDueDatePassed(dueDate: filteredData?[indexPath.row].end_date ?? "") {
//            cell.dueDateLbl.textColor = UIColor.black
//        } else {
//            cell.dueDateLbl.textColor = UIColor.black
//        }
//        cell.staff = true
//        cell.submitBtn.setTitle("Submited : \(filteredData?[indexPath.row].submitted_count ?? 0)", for: .normal)
//        let unsubmitted = (filteredData?[indexPath.row].total_count ?? 0) - (filteredData?[indexPath.row].submitted_count ?? 0)
//        cell.unsubmitcount = unsubmitted
//        cell.submitcount = filteredData?[indexPath.row].submitted_count ?? 0
//        cell.NotSubmitedBtn.setTitle("Unsubmitted : \(unsubmitted)", for: .normal)
//        cell.DescriptionLbl.setupExpandable(text: filteredData?[indexPath.row].description ?? "")
//        cell.DescriptionLbl.onExpandableTap = {
//            cell.DescriptionLbl.isExpanded.toggle()
//            tableView.beginUpdates()
//            tableView.endUpdates()
//        }
//        cell.id = filteredData?[indexPath.row].id
//        cell.assignmentId = filteredData?[indexPath.row].id
//        cell.FilesUrl = filteredData?[indexPath.row].file_path
//        cell.dueDateLbl.text = filteredData?[indexPath.row].end_date
//        cell.CreaterdDate.text = filteredData?[indexPath.row].created_date
//        cell.deleteBtn.tag = indexPath.row
//        cell.deleteBtn.addTarget(self, action: #selector(deletedTapped(_:)), for: .touchUpInside)
//
//        return cell
//    }
//    @objc func deletedTapped(_ sender: UIButton) {
//        let index = sender.tag
//
//        let title = AlertstringFile.Confirm_title
//        alert.showAlertCancel(
//            title: title,
//            message: AlertstringFile.deletemessage,
//            actionLbl1: AlertstringFile.delete,
//            actionLbl2: AlertstringFile.Cancel,
//            on: self,
//            onOk: { [weak self] in
//                guard let self = self,
//                      let idToRemove = self.filteredData?[index].id else { return }
//
//                APIService.shared.makeApi(
//                    url: ServiceUrl.comm_api_assignment_delete,
//                    parameters: ["id": idToRemove],
//                    type: ApitTypeSringFile.PUT,
//                    token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
//                ) { (result: Result<Send_AttachmentResponse, Error>) in
//                    switch result {
//                    case .success(let response):
//                        if response.status {
//                            DispatchQueue.main.async {
//                                self.data?.removeAll { $0.id == idToRemove }
//                                self.filteredData?.removeAll { $0.id == idToRemove }
//                                self.reportTable.reloadData()
//                            }
//                        }
//                    case .failure(let error):
//                        print("API Error: \(error.localizedDescription)")
//                    }
//                }
//            }, onNo: {
//                print("User canceled.")
//            }
//        )
//    }
//
//
//    // MARK: - Dropdown Selections
//    @IBAction func selectAcademicYear(_ sender: UIButton) {
//        acidamicdrops.anchorView = acodemicdropView
//        acidamicdrops.dataSource = accadimYr
//        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acodemicdropView.bounds.height)
//        acidamicdrops.show()
//        acidamicdrops.selectionAction = { [weak self] index, item in
//            self?.acodomicYearLbl.text = item
//            self?.acodemicId = self?.AcadimicYearDatas[index].id
//            self?.getAssigment()
//        }
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.becomeFirstResponder()
//    }
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard let data = data else { return }
//        
//        let lowercasedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//        
//        if lowercasedQuery.isEmpty {
//            filteredData = data
//        } else {
//            filteredData = data.filter { item in
//                let title = item.title?.lowercased() ?? ""
//                let subject = item.subject?.lowercased() ?? ""
//                let endDate = item.end_date?.lowercased() ?? ""
//                let category = item.category?.lowercased() ?? ""
//                let submittedCount = "\(item.submitted_count ?? 0)"
//                
//                return title.contains(lowercasedQuery) ||
//                subject.contains(lowercasedQuery) ||
//                endDate.contains(lowercasedQuery) ||
//                category.contains(lowercasedQuery) ||
//                submittedCount.contains(lowercasedQuery)
//            }
//        }
//        
//        // Update No Data UI
//        let isEmpty = filteredData?.isEmpty ?? true
//        nodataLbl.isHidden = !isEmpty
//        nodataLbl.text = isEmpty ? "No Records Found" : ""
//        noRecordImg.isHidden = !isEmpty
//        
//        reportTable.reloadData()
//    }
//    func loadFiles(into cell: AssignmentTVC, files: [FilePath]) {
//        [cell.img1, cell.img2, cell.img3].forEach { $0?.isHidden = true }
//        cell.imgCount.isHidden = true
//        
//        for (index, item) in files.enumerated() {
//            // Only process first 3 files for display
//            guard index < 3 else { break }
//            
//            guard let urlString = item.url, let url = URL(string: urlString) else { continue }
//            
//            // Safe array access
//            let imageViews = [cell.img1, cell.img2, cell.img3]
//            guard index < imageViews.count, let imageView = imageViews[index] else { continue }
//            
//            imageView.isHidden = false
//            
//            if item.type?.lowercased() != "image" {
//                let iconName = getFileIconName(for: url)
//                imageView.image = UIImage(named: iconName)
//            } else {
//                imageView.kf.setImage(with: url)
//            }
//        }
//        
//        // Handle extra files count display
//        if files.count > 3 {
//            let extraCount = files.count - 3
//            if let button = cell.imgCount as? UIButton {
//                button.setTitle("+\(extraCount)", for: .normal)
//                cell.imgCount.isHidden = false
//            }
//        }
//    }
//}
//
//  AssignmentReport.swift
//  School Chimes
//
//  Created by Chandhru on 18/06/25.
//

import UIKit
import DropDown
import Kingfisher

class AssignmentReport: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var noDataStack: UIStackView!
    @IBOutlet weak var academicView: UIView!
    @IBOutlet weak var academicDropView: UIView!
    @IBOutlet weak var academicYearLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var reportTable: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var noRecordImage: UIImageView!

    // MARK: - Properties
    var data: [Report] = []
    var filteredData: [Report] = []
    let academicDropDown = DropDown()
    let alert = CustomAlert()
    var academicId: Int?
    var academicYearDataList: [AcadimicYearData] = []
    var academicYears: [String] = []
    var shouldShowFooter = true

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAcademicYears()
        setupDummyData()
    }

    // MARK: - UI Setup
    func setupUI() {
        reportTable.register(UINib(nibName: "AssignmentTVC", bundle: nil), forCellReuseIdentifier: "AssignmentTVC")
        reportTable.delegate = self
        reportTable.dataSource = self

        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.layer.borderWidth = 0
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.addDoneButton()

        applyShadowAndCornerRadius(to: academicView)
        academicView.layer.borderColor = UIColor.lightGray.cgColor
        academicView.layer.borderWidth = 0.5
    }

    func loadAcademicYears() {
        academicYears = ["2022-2023", "2023-2024", "2024-2025"]
        academicYearLabel.text = academicYears.last
        academicId = 1 // Dummy ID
    }

    // MARK: - Dummy Data
    func setupDummyData() {
        let dummyFiles: [FilePath] = [
            FilePath(url: "https://via.placeholder.com/100", type: "image"),
            FilePath(url: "https://example.com/sample.pdf", type: "pdf"),
            FilePath(url: "https://example.com/sample.docx", type: "docx"),
            FilePath(url: "https://via.placeholder.com/100", type: "image")
        ]

        data = [
            Report(
                id: "1",
                title: "Math Assignment",
                description: "Solve all questions from chapter 3",
                category: "Homework",
                subject: "Math",
                created_date: "05/08/2025",
                created_time: "10:30 AM",
                progress: 0.7,
                submitted_count: 15,
                total_count: 20,
                end_date: "10/08/2025",
                file_path: dummyFiles
            ),
            Report(
                id: "2",
                title: "Science Project",
                description: "Build a working volcano model",
                category: "Project",
                subject: "Science",
                created_date: "01/08/2025",
                created_time: "9:00 AM",
                progress: 0.3,
                submitted_count: 10,
                total_count: 25,
                end_date: "15/08/2025",
                file_path: dummyFiles
            )
        ]

        filteredData = data
        reportTable.reloadData()
    }

    // MARK: - File Handling
    func loadFiles(into cell: AssignmentTVC, files: [FilePath]) {
        [cell.img1, cell.img2, cell.img3].forEach { $0?.isHidden = true }
        cell.imgCount.isHidden = true

        for (index, file) in files.enumerated() where index < 3 {
            guard let urlString = file.url, let url = URL(string: urlString) else { continue }

            let imageViews = [cell.img1, cell.img2, cell.img3]
            guard index < imageViews.count, let imageView = imageViews[index] else { continue }

            imageView.isHidden = false

            if file.type?.lowercased() != "image" {
                let iconName = getFileIconName(for: url) // Ensure this function exists
                imageView.image = UIImage(named: iconName) ?? UIImage(systemName: "doc.fill")
            } else {
                imageView.kf.setImage(with: url)
            }
        }

        if files.count > 3 {
            let extraCount = files.count - 3
            cell.imgCount.setTitle("+\(extraCount)", for: .normal)
            cell.imgCount.isHidden = false
        }
    }

    // MARK: - Actions
    @IBAction func selectAcademicYear(_ sender: UIButton) {
        academicDropDown.anchorView = academicDropView
        academicDropDown.dataSource = academicYears
        academicDropDown.bottomOffset = CGPoint(x: 0, y: academicDropView.bounds.height)
        academicDropDown.show()

        academicDropDown.selectionAction = { [weak self] index, item in
            self?.academicYearLabel.text = item
            self?.academicId = index
        }
    }
}

// MARK: - TableView Delegate/DataSource
extension AssignmentReport: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentTVC", for: indexPath) as? AssignmentTVC else {
            return UITableViewCell()
        }

        let report = filteredData[indexPath.row]
        cell.configure(with: report)
        loadFiles(into: cell, files: report.file_path ?? [])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - SearchBar
extension AssignmentReport: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if query.isEmpty {
            filteredData = data
        } else {
            filteredData = data.filter { item in
                let values = [
                    item.title?.lowercased(),
                    item.subject?.lowercased(),
                    item.end_date?.lowercased(),
                    item.category?.lowercased(),
                    "\(item.submitted_count ?? 0)"
                ]

                return values.contains { $0?.contains(query) == true }
            }
        }

        let noResults = filteredData.isEmpty
        noDataLabel.text = noResults ? "No Records Found" : ""
        noDataLabel.isHidden = !noResults
        noRecordImage.isHidden = !noResults

        reportTable.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
}
