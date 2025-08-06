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
        getacadmicYr()
    }
    func getacadmicYr() {
        academicYears = localData.accidamic_year_data?.data?.compactMap { $0.year } ?? []
        academicYearDataList = localData.accidamic_year_data?.data ?? []
        academicYearLabel.text = academicYears.last ?? ""
        academicId = localData.accidamic_year_data?.data?.last?.id ?? 0
        getAssigment()
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
        loadFiles(into: cell, files: report.file_path ?? [])
        cell.layoutIfNeeded()
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
