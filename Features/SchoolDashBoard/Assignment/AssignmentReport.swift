//
//  AssignmentReport.swift
//  School Chimes
//
//  Created by Chandhru on 18/06/25.
//

import UIKit
//import DropDown
import Kingfisher

class AssignmentReport: UIViewController, SelectedId {
    func selectId(id: String?, edit: Bool?) {
        if edit ?? false{
            if let selectedNotice = self.filteredData.first(where: { $0.id == id }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if #available(iOS 14.0, *) {
                        let vc = SenderAssignmentTextViewController()
                        vc.editReport = selectedNotice
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.deleteEvent(id: id)
            }
        }
    }
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var noDataStack: UIStackView!
    @IBOutlet weak var academicView: UIView!
    @IBOutlet weak var academicDropView: UIView!
    @IBOutlet weak var academicYearLabel: UILabel!
    @IBOutlet weak var seachBtn: UIButton!
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
    var pushNotiMsg_id : String?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getacadmicYr()
    }
    func getacadmicYr() {
        academicYears = localData.accidamic_year_data?.data?.compactMap { $0.year } ?? []
        academicYearDataList = localData.accidamic_year_data?.data ?? []
        let currentYear = academicYearDataList.first(where: {$0.current_academic_year == true})
        academicYearLabel.text = currentYear?.year
        academicId = currentYear?.id
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
                    token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true
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
                                    let isEmpty = self.data.isEmpty
                                    self.noDataLabel.isHidden = !isEmpty
                                    self.noRecordImage.isHidden = !isEmpty
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
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func getAssigment() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_report,
            parameters: ["academic_year_id":academicId ?? 0],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<AssignmentReportResponse, Error>) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.data = response.data ?? []
                    self?.filteredData = self?.data ?? []
                    let isEmpty = self?.data.isEmpty ?? true
                    self?.seachBtn.isHidden = isEmpty
                    self?.noDataLabel.isHidden = !isEmpty
                    self?.noDataLabel.text = isEmpty ? response.message : ""
                    self?.noRecordImage.isHidden = !isEmpty
                    self?.reportTable.reloadData()
                    if self?.pushNotiMsg_id != ""{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self?.scrollToClickedMessage()
                        }
                        
                    }
                }
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func scrollToClickedMessage() {
        guard let id = pushNotiMsg_id,
              let index = filteredData.firstIndex(where: { $0.id == id }) else {
            return
        }
        let indexPath = IndexPath(row: index, section: 0)
        reportTable.scrollToRow(at: indexPath, at: .middle, animated: true)
        if let cell = reportTable.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                cell.contentView.backgroundColor = UIColor.lightGray
                    .withAlphaComponent(0.3)
            }) { _ in
                UIView.animate(withDuration: 0.5, delay: 1.0, options: []) {
                    cell.contentView.backgroundColor = .white
                }
            }
        }
    }
    
    // MARK: - UI Setup
    func setupUI() {
        reportTable.register(UINib(nibName: "AssignmentTVC", bundle: nil), forCellReuseIdentifier: "AssignmentTVC")
        reportTable.delegate = self
        reportTable.dataSource = self
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = .clear
        searchBar.isTranslucent = true
        let textField = searchBar.searchTextField
        textField.backgroundColor = .systemGray5
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.addDoneButton()
//        let language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        backLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName, secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        applyShadowAndCornerRadius(to: academicView)
        academicView.layer.borderColor = UIColor.lightGray.cgColor
        academicView.layer.borderWidth = 0.5
        academicDropView.layer.cornerRadius = 10
        academicDropView.layer.borderWidth = 1
        academicDropView.layer.borderColor = UIColor.white.cgColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(academicDropViewTapped))
        academicDropView.isUserInteractionEnabled = true
        academicDropView.addGestureRecognizer(tap)
    }
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        searchBar?.isHidden = !sender.isSelected
        if sender.isSelected {
            searchBar?.becomeFirstResponder()
        } else {
            searchBar?.resignFirstResponder()
            filteredData = data
            let noResults = filteredData.isEmpty
            noDataLabel.text = noResults ? "No Records Found" : ""
            noDataLabel.isHidden = !noResults
            noRecordImage.isHidden = !noResults
            searchBar.searchTextField.text = ""
            reportTable.reloadData()
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
                    token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true
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
    @IBAction func createAssignment(_ sender: UIButton) {
        if #available(iOS 14.0, *) {
            let vc = SenderAssignmentTextViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    // MARK: - Actions
    @objc func academicDropViewTapped() {
        academicDropDown.anchorView = academicDropView
        academicDropDown.dataSource = academicYears
        academicDropDown.bottomOffset = CGPoint(x: 0, y: academicDropView.bounds.height)
        academicDropDown.show()
        
        academicDropDown.selectionAction = { [weak self] index, item in
            self?.academicYearLabel.text = item
            self?.searchBar.text = ""
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
        detailVC.userNameValue = MenuStringFile.selectedMenuName
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
