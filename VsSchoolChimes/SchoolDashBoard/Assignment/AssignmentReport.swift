//
//  AssignmentReport.swift
//  School Chimes
//
//  Created by Chandhru on 18/06/25.
//

import UIKit
import DropDown

class AssignmentReport: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    @IBOutlet weak var noDataStack: UIStackView!
    @IBOutlet weak var acodemicView: UIView!
    @IBOutlet weak var acodemicdropView: UIView!
    @IBOutlet weak var acodomicYearLbl: UILabel!
    @IBOutlet weak var searchview: UISearchBar!
    @IBOutlet weak var reportTable: UITableView!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var noRecordImg: UIImageView!
    var data : [Report]?
    var filteredData :[Report]?
    let acidamicdrops = DropDown()
    var acodemicId: Int?
    var AcadimicYearDatas: [AcadimicYearData] = []
    var accadimYr: [String] = []
    var shouldShowFooter = true
    var tapGesture: UITapGestureRecognizer?
    override func viewDidLoad() {
        super.viewDidLoad()
        reportTable.register(UINib(nibName: CellConfingName.AssignmentListCTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AssignmentListCTVC)
        reportTable.delegate = self
        reportTable.dataSource = self
        searchview.placeholder = CommonStringFile.Search.translated()
        searchview.delegate = self
        searchview.layer.borderWidth = 0
        searchview.backgroundImage = UIImage()
        searchview.addDoneButton()
        getAssigment()
        applyShadowAndCornerRadius(to: acodemicView)
        acodemicView.layer.borderColor = UIColor.lightGray.cgColor
        acodemicView.layer.borderWidth = 0.5
    }
    func getAssigment() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_report,
            parameters: ["academic_year_id":7],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<AssignmentReportResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status == true {
                    DispatchQueue.main.async {
                        self?.data = response.data ?? []
                        self?.filteredData = self?.data
                        let isEmpty = self?.data?.isEmpty ?? true
                        self?.nodataLbl.isHidden = !isEmpty
                        self?.nodataLbl.text = isEmpty ? response.message : ""
                        self?.noRecordImg.isHidden = !isEmpty
                        self?.noDataStack.isHidden = true
                        self?.reportTable.reloadData()
                    }
                }
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
            }
        }
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData?.count ?? 0 // Adjust this based on your data
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reportTable.dequeueReusableCell(withIdentifier: CellConfingName.AssignmentListCTVC, for: indexPath) as! AssignmentListCTVC
        cell.tittleLbl.text = filteredData?[indexPath.row].title
        if !isDueDatePassed(dueDate: filteredData?[indexPath.row].end_date ?? "") {
            cell.dueDateLbl.textColor = UIColor.black
        } else {
            cell.dueDateLbl.textColor = UIColor.black
        }
        cell.staff = true
        cell.submitBtn.setTitle("Submited : \(filteredData?[indexPath.row].submitted_count ?? 0)", for: .normal)
        let unsubmitted = (filteredData?[indexPath.row].total_count ?? 0) - (filteredData?[indexPath.row].submitted_count ?? 0)

        cell.NotSubmitedBtn.setTitle("Unsubmitted : \(unsubmitted)", for: .normal)
        cell.id = filteredData?[indexPath.row].id
        cell.assignmentId = filteredData?[indexPath.row].id
        cell.FilesUrl = filteredData?[indexPath.row].file_path
        cell.dueDateLbl.text = filteredData?[indexPath.row].end_date
        cell.CreaterdDate.text = filteredData?[indexPath.row].created_date
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deletedTapped(_:)), for: .touchUpInside)

        return cell
    }
    @objc func deletedTapped(_ sender: UIButton) {
        let index = sender.tag
        print("Button tapped at index: \(index)")
        // Use index to get data from your array
    }

    // MARK: - Dropdown Selections
    @IBAction func selectAcademicYear(_ sender: UIButton) {
        acidamicdrops.anchorView = acodemicdropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acodemicdropView.bounds.height)
        acidamicdrops.show()
        acidamicdrops.selectionAction = { [weak self] index, item in
            self?.acodomicYearLbl.text = item
            self?.acodemicId = self?.AcadimicYearDatas[index].id
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let data = data else { return }
        
        let lowercasedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if lowercasedQuery.isEmpty {
            filteredData = data
        } else {
            filteredData = data.filter { item in
                let title = item.title?.lowercased() ?? ""
                let subject = item.subject?.lowercased() ?? ""
                let endDate = item.end_date?.lowercased() ?? ""
                let category = item.category?.lowercased() ?? ""
                let submittedCount = "\(item.submitted_count ?? 0)"
                
                return title.contains(lowercasedQuery) ||
                subject.contains(lowercasedQuery) ||
                endDate.contains(lowercasedQuery) ||
                category.contains(lowercasedQuery) ||
                submittedCount.contains(lowercasedQuery)
            }
        }
        
        // Update No Data UI
        let isEmpty = filteredData?.isEmpty ?? true
        nodataLbl.isHidden = !isEmpty
        nodataLbl.text = isEmpty ? "No Records Found" : ""
        noRecordImg.isHidden = !isEmpty
        
        reportTable.reloadData()
    }
    
}
