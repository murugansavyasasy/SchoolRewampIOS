//
//  AssignmentReport.swift
//  School Chimes
//
//  Created by Chandhru on 18/06/25.
//

import UIKit
import DropDown
import Kingfisher

class AssignmentReport: UIViewController, SelectedId {
    func selectId(id: String?, edit: Bool?) {
        if edit ?? false{
            if let selectedNotice = self.filteredData.first(where: { $0.id == id }) {
                delegate?.editDta(edit: selectedNotice)
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.deleteEvent(id: id)
            }
        }
    }
    
    
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
    var delegate:EditObjectDelegate?
    var academicId: Int?
    var academicYearDataList: [AcadimicYearData] = []
    var academicYears: [String] = []
    var shouldShowFooter = true
    let transitionDelegate = TransitioningDelegate()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getacadmicYr()
    }
    func getacadmicYr() {
        academicYears = localData.accidamic_year_data?.data?.compactMap { $0.year } ?? []
        academicYearDataList = localData.accidamic_year_data?.data ?? []
        academicYearLabel.text = academicYears.last ?? ""
        academicId = localData.accidamic_year_data?.data?.last?.id ?? 0
        getAssigment()
    }
    func deleteEvent(id: String?) {
        guard let targetID = id, !targetID.isEmpty else {
            print("Invalid notice ID")
            return
        }
        alert.showAlertCancel(
            title: AlertstringFile.Confirm,
            message: AlertstringFile.deletemessage,
            actionLbl1: AlertstringFile.delete,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                APIService.shared.makeApi(
                    url: ServiceUrl.comm_api_assignment_delete,
                    parameters: ["id": targetID],
                    type: ApitTypeSringFile.PUT,
                    token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
                ) { [weak self] (result: Result<ResetPasswordSuc, Error>) in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let successResponse):
                            if successResponse.status == true {
                                CustomAlert.showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: successResponse.message ?? "",
                                    on: self
                                ) {
                                    self.filteredData.removeAll { $0.id == targetID }
                                    self.data.removeAll { $0.id == targetID }
                                    self.reportTable.reloadData()
                                }
                            } else {
                                self.alert.showAlert(
                                    title: AlertstringFile.Failed,
                                    message: successResponse.message ?? "",
                                    on: self
                                )
                            }
                            
                        case .failure(let error):
                            print("Error deleting notice: \(error.localizedDescription)")
                            self.alert.showAlert(title: "Error", message: error.localizedDescription, on: self)
                        }
                    }
                }
            },
            onNo: {
                print("User canceled deletion")
            }
        )
    }
    
    func getAssigment() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_report,
            parameters: ["academic_year_id":academicId ?? 0],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<AssignmentReportResponse, Error>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.data = response.data ?? []
                    self?.filteredData = self?.data ?? []
                    let isEmpty = self?.data.isEmpty ?? true
                    self?.noDataLabel.isHidden = !isEmpty
                    self?.noDataLabel.text = isEmpty ? response.message : ""
                    self?.noRecordImage.isHidden = !isEmpty
                    self?.reportTable.isHidden = isEmpty
                    self?.reportTable.reloadData()
                    
                }
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
            }
        }
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
    func searchHide(hide: Bool) {
        searchBar?.isHidden = !hide
        if hide {
            searchBar?.becomeFirstResponder()
        } else {
            searchBar?.resignFirstResponder()
        }
    }
    @objc func deletedTapped(_ sender: UIButton) {
        let index = sender.tag
        
        let title = AlertstringFile.Confirm_title
        alert.showAlertCancel(
            title: title,
            message: AlertstringFile.deletemessage,
            actionLbl1: AlertstringFile.delete,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: { [weak self] in
                guard let self = self,
                      let idToRemove = self.filteredData[index].id else { return }
                
                APIService.shared.makeApi(
                    url: ServiceUrl.comm_api_assignment_delete,
                    parameters: ["id": idToRemove],
                    type: ApitTypeSringFile.PUT,
                    token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
                ) { (result: Result<Send_AttachmentResponse, Error>) in
                    switch result {
                    case .success(let response):
                        if response.status {
                            DispatchQueue.main.async {
                                self.data.removeAll { $0.id == idToRemove }
                                self.filteredData.removeAll { $0.id == idToRemove }
                                self.reportTable.reloadData()
                            }
                        }
                    case .failure(let error):
                        print("API Error: \(error.localizedDescription)")
                    }
                }
            }, onNo: {
                print("User canceled.")
            }
        )
    }
    // MARK: - File Handling
    
    
    // MARK: - Actions
    @IBAction func selectAcademicYear(_ sender: UIButton) {
        academicDropDown.anchorView = academicDropView
        academicDropDown.dataSource = academicYears
        academicDropDown.bottomOffset = CGPoint(x: 0, y: academicDropView.bounds.height)
        academicDropDown.show()
        
        academicDropDown.selectionAction = { [weak self] index, item in
            self?.academicYearLabel.text = item
            self?.academicId = self?.academicYearDataList[index].id
            self?.getAssigment()
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
        cell.loadFiles(into: cell, files: report.file_path ?? [])
        cell.edit(edit: report.can_edit ?? false, delete:  report.can_delete ?? false, selectedId: report.id ?? "")
        cell.delegate = self
        cell.submittedProgressStack.isHidden = false
        cell.submitBtnStack.isHidden = true
        cell.layoutIfNeeded()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath),
              indexPath.row < filteredData.count else { return }
        
        let cellFrameInSuperview = tableView.convert(cell.frame, to: view)
        
        let detailVC = AssignmentPriview()
        let selectedItem = filteredData[indexPath.row]
        detailVC.data = selectedItem
        detailVC.userNameValue = UserDefaultFileManager.get_staff_Details()?.name
        detailVC.sectionValue = UserDefaultFileManager.get_staff_Details()?.school_name
        detailVC.modalPresentationStyle = .custom
        transitionDelegate.originFrame = cellFrameInSuperview
        detailVC.transitioningDelegate = transitionDelegate
        
        present(detailVC, animated: true)
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
