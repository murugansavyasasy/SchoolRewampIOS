//
//  LSRWSubmissionVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/07/25.
//

import UIKit

class LSRWSubmissionVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var backStack: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var submitionList: UITableView!
    @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    // MARK: - Properties
    var dueDate: String?
    var report: [LSRWTask]?
    var filterReport: [LSRWTask]?
    var btnTitle: String?
    
    enum ReportFilterType {
        case all
        case submitted
        case pending
    }
    
    var selectedFilter: ReportFilterType = .all
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - UI Setup
    private func configureUI() {
        filterReport = report
        backBtn.setTitle(btnTitle ?? "", for: .normal)
        submitionList.delegate = self
        submitionList.dataSource = self
        submitionList.register(UINib(nibName: "LSRWTaskTVC", bundle: nil), forCellReuseIdentifier: "LSRWTaskTVC")
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.delegate = self
        searchBar.layer.borderWidth = 0
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.addDoneButton()
        
        updateNoDataView()
    }
    
    // MARK: - Actions
    @IBAction func searchBtn(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        
        UIView.animate(withDuration: 0.25) {
            self.searchView.isHidden = !sender.isSelected
        }
        
        if sender.isSelected {
            self.searchBar.becomeFirstResponder()
        } else {
            self.searchBar.text = ""
            self.searchBar.resignFirstResponder()
            self.filterReport = self.report
            self.submitionList.reloadData()
            self.updateNoDataView()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    private func applyFilter() {
        guard let data = report else { return }
        
        switch selectedFilter {
        case .all:
            filterReport = data
        case .submitted:
            filterReport = data.filter { $0.is_submitted == true }
        case .pending:
            filterReport = data.filter { $0.is_submitted == false }
        }
        
        submitionList.reloadData()
        updateNoDataView()
    }
    
    // MARK: - No Data Handling
    private func updateNoDataView() {
        let hasData = !(filterReport?.isEmpty ?? true)
        noDataImg.isHidden = hasData
        noDataLbl.isHidden = hasData
        noDataLbl.text = "No Data Found!".translated()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension LSRWSubmissionVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateNoDataView()
        return filterReport?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWTaskTVC",
                                                       for: indexPath) as? LSRWTaskTVC else {
            return UITableViewCell()
        }
        
        if let task = filterReport?[indexPath.row] {
            cell.configure(with: task)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedTask = filterReport?[indexPath.row] else { return }
        navigateToTaskDetail(task: selectedTask)
    }
    
    private func navigateToTaskDetail(task: LSRWTask) {
        let vc = LSRWPreviewVC()
        vc.modalPresentationStyle = .fullScreen
        vc.report = task
        present(vc, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension LSRWSubmissionVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let report = report else { return }
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        var filteredData = report
        switch selectedFilter {
        case .all:
            break
        case .submitted:
            filteredData = filteredData.filter { $0.is_submitted == true }
        case .pending:
            filteredData = filteredData.filter { $0.is_submitted == false }
        }
        
        if !trimmed.isEmpty {
            filteredData = filteredData.filter {
                ($0.title?.lowercased().contains(trimmed) ?? false) ||
                ($0.subject?.lowercased().contains(trimmed) ?? false)
            }
        }
        
        filterReport = filteredData
        submitionList.reloadData()
        updateNoDataView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Helper
extension LSRWSubmissionVC {
    func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .topMostViewController()
    }
}
