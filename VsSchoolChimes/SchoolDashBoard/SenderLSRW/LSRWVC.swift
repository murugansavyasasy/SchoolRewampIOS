//
//  LSRWVC.swift
//  School Chimes
//
//  Created by Chandhru on 13/08/25.
//

import UIKit

protocol FilterDelegate: AnyObject {
    func selectedIndex(index: Int?)
    func navigate(index: Int?)
}

enum LsrwDisplaySection {
    case overview([Overview])
    case filterArray([String])
    case active([LSRWTask])
    case completed([LSRWTask])
}

class LSRWVC: UIViewController, FilterDelegate, SelectedId {
    func selectId(id: String?, edit: Bool?) {
        
        if !(edit ?? false){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.deleteEvent(id: id)
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if #available(iOS 15.0, *) {
                    let vc = SenderLSRWVC()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        }
    }
    

    @IBOutlet weak var lsrwTable: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var nodataImg: UIImageView!
    @IBOutlet weak var nodataLbl: UILabel!

    // MARK: - Data
    private var dashboardData: [Overview] = []
    private var recentTasks: [LsrwDisplaySection] = []
    private var filterTask: [LsrwDisplaySection] = []
    private var allTask: LSRWData?
    private var activeTask: [LSRWTask] = []
    private var completedTask: [LSRWTask] = []
    private var selectedIndex = 0
    let alert = CustomAlert()
    private let filterArray = ["All".translated(), "Listening".translated(), "Speaking".translated(), "Reading".translated(), "Writing".translated(), "Completed".translated(), "Active".translated()]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            lsrwTable.sectionHeaderTopPadding = 0
        }
        setupTableView()
        getLSRW()
    }

    deinit {
        dashboardData.removeAll()
        activeTask.removeAll()
        completedTask.removeAll()
        recentTasks.removeAll()
        filterTask.removeAll()
    }

    // MARK: - Table Setup
    private func setupTableView() {
        lsrwTable.dataSource = self
        lsrwTable.delegate = self
        lsrwTable.register(UINib(nibName: CellConfingName.LSRWTaskTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.LSRWTaskTVC)
        lsrwTable.register(UINib(nibName: CellConfingName.LSRWProgressTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.LSRWProgressTVC)
        lsrwTable.separatorStyle = .none
        lsrwTable.showsVerticalScrollIndicator = false

        BackBtn.configureAsBackButton(firstLine: "LSRW", secondLine: "Listening, Speaking, Reading, Writing")
    }
    func deleteEvent(id: String?) {
        guard let targetID = id, !targetID.isEmpty else {
            print("Invalid task ID")
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
                    url: ServiceUrl.lms_api_lsrw_delete,
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
                                    self.activeTask.removeAll { $0.id == targetID }
                                    self.completedTask.removeAll { $0.id == targetID }
                                    self.recentTasks = []
                                    self.recentTasks.append(.overview(self.dashboardData))

                                    if !self.activeTask.isEmpty {
                                        self.recentTasks.append(.active(self.activeTask))
                                    }
                                    if !self.completedTask.isEmpty {
                                        self.recentTasks.append(.completed(self.completedTask))
                                    }
                                    if !self.activeTask.isEmpty || !self.completedTask.isEmpty {
                                        self.recentTasks.insert(.filterArray(self.filterArray), at: 1)
                                    }
                                    self.filterTask = self.recentTasks
                                    let hasData = !self.activeTask.isEmpty || !self.completedTask.isEmpty
                                    self.nodataImg.isHidden = hasData
                                    self.nodataLbl.isHidden = hasData

                                    if !hasData {
                                        self.nodataLbl.text = "No tasks available"
                                    }
                                    self.lsrwTable.reloadData()
                                }
                            } else {
                                self.alert.showAlert(
                                    title: AlertstringFile.Failed,
                                    message: successResponse.message ?? "",
                                    on: self
                                )
                            }

                        case .failure(let error):
                            print("Delete Error: \(error.localizedDescription)")
                            self.alert.showAlert(title: "Error", message: error.localizedDescription, on: self)
                        }
                    }
                }

            },
            onNo: {
                print("User cancelled delete")
            }
        )
    }


    // MARK: - API
    func getLSRW() {
        APIService.shared.makeApi(
            url: ServiceUrl.lms_api_lsrw_skills_report,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<LSRWReportResponse, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                let firstData = response.data?.first
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.dashboardData = firstData?.overview ?? []
                    self.activeTask = firstData?.active ?? []
                    self.completedTask = firstData?.completed ?? []
                    self.recentTasks = []
                    self.recentTasks.append(.overview(self.dashboardData))
                    if !self.activeTask.isEmpty {
                        self.recentTasks.append(.active(self.activeTask))
                    }
                    if !self.completedTask.isEmpty {
                        self.recentTasks.append(.completed(self.completedTask))
                    }
                    if !self.activeTask.isEmpty || !self.completedTask.isEmpty {
                        self.recentTasks.insert(.filterArray(self.filterArray), at: 1)
                    }
                    self.filterTask = self.recentTasks
                    self.allTask = firstData
                    self.nodataImg.isHidden = !self.filterTask.isEmpty
                    self.nodataLbl.isHidden = !self.filterTask.isEmpty
                    self.lsrwTable.reloadData()
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                    self.nodataImg.isHidden = false
                    self.nodataLbl.isHidden = false
                    self.lsrwTable.reloadData()
                }
            }
        }
    }

    // MARK: - Actions
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - FilterDelegate
    func selectedIndex(index: Int?) {
        guard let idx = index, idx >= 0, idx < filterArray.count else { return }
        selectedIndex = idx
        let selectedFilter = filterArray[idx]

        switch selectedFilter {
        case "All".translated():
            filterTask = recentTasks

        case "Active".translated():
            filterTask = filterTask.map { section in
                switch section {
                case .active: return .active(activeTask)
                case .completed: return .completed([])
                default: return section
                }
            }

        case "Completed".translated():
            filterTask = filterTask.map { section in
                switch section {
                case .active: return .active([])
                case .completed: return .completed(completedTask)
                default: return section
                }
            }

        default:
            let filteredActive = activeTask.filter { $0.activity_type?.displayName.translated() == selectedFilter }
            let filteredCompleted = completedTask.filter { $0.activity_type?.displayName == selectedFilter }

            filterTask = filterTask.map { section in
                switch section {
                case .active: return .active(filteredActive)
                case .completed: return .completed(filteredCompleted)
                default: return section
                }
            }
        }
        let hasData = filterTask.contains { section in
            switch section {
            case .active(let list), .completed(let list):
                return !list.isEmpty
            case .overview, .filterArray:
                return true
            }
        }

        nodataImg.isHidden = hasData
        nodataLbl.isHidden = hasData
        if !hasData {
            nodataLbl.text = "No data available for this filter"
        }

        lsrwTable.reloadData()
    }

    func navigate(index: Int?) {
        guard let index = index else { return }

        switch index {
        case 0 where !activeTask.isEmpty:
            let vc = LSRWSubmissionVC()
            vc.modalPresentationStyle = .fullScreen
            vc.report = activeTask
            vc.btnTitle = "Active Tasks".translated()
            present(vc, animated: true)
        case 1:
            let vc = SelectedLSRWSubmissionVC()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        case 2 where !completedTask.isEmpty:
            let vc = LSRWSubmissionVC()
            vc.modalPresentationStyle = .fullScreen
            vc.report = completedTask
            vc.btnTitle = "Completed Tasks".translated()
            present(vc, animated: true)
        default:
            print("Navigate index: \(index)")
        }
    }
}

// MARK: - UITableViewDataSource
extension LSRWVC: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return max(1, filterTask.count)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !filterTask.isEmpty else { return 0 }
        switch filterTask[section] {
        case .overview, .filterArray: return 1
        case .active(let tasks), .completed(let tasks): return tasks.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !filterTask.isEmpty else { return UITableViewCell() }

        switch filterTask[indexPath.section] {
        case .overview(let overview):
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LSRWProgressTVC, for: indexPath) as! LSRWProgressTVC
            cell.configure(with: overview)
            cell.delegate = self
            return cell
        case .filterArray:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LSRWProgressTVC, for: indexPath) as! LSRWProgressTVC
            cell.configure(with: nil, selectedIndex: selectedIndex)
            cell.delegate = self
            return cell
        case .active(let tasks), .completed(let tasks):
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LSRWTaskTVC, for: indexPath) as! LSRWTaskTVC
            cell.configure(with: tasks[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension LSRWVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch filterTask[indexPath.section] {
        case .overview: return 120
        case .filterArray: return 60
        case .active, .completed: return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch filterTask[indexPath.section] {
        case .active(let tasks), .completed(let tasks):
            navigateToTaskDetail(task: tasks[indexPath.row])
        default: break
        }
    }

    private func navigateToTaskDetail(task: LSRWTask) {
        let vc = LSRWPreviewVC()
        vc.modalPresentationStyle = .fullScreen
        vc.report = task
        present(vc, animated: true)
    }
}

// MARK: - Custom Section Header with Button
extension LSRWVC {

    private func createNewTaskButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.setTitle("New Task".translated(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(newTaskTapped), for: .touchUpInside)
        return button
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // ✅ Always show Dashboard Overview header when filterTask is empty
        if filterTask.isEmpty && section == 0 {
            return overviewHeaderView()
        }

        let sectionData = filterTask[section]
        let headerView = UIView()
        headerView.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        switch sectionData {
        case .overview:
            titleLabel.text = "Dashboard Overview".translated()
            let newTaskButton = createNewTaskButton()
            headerView.addSubview(newTaskButton)
            newTaskButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                newTaskButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
                newTaskButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                newTaskButton.widthAnchor.constraint(equalToConstant: 100),
                newTaskButton.heightAnchor.constraint(equalToConstant: 34)
            ])
        case .filterArray:
            titleLabel.text = ""
        case .active:
            titleLabel.text = "Active Tasks".translated()
        case .completed:
            titleLabel.text = "Completed Tasks".translated()
        }

        return headerView
    }

    private func overviewHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.text = "Dashboard Overview"
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        let newTaskButton = createNewTaskButton()
        headerView.addSubview(newTaskButton)
        newTaskButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newTaskButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            newTaskButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            newTaskButton.widthAnchor.constraint(equalToConstant: 100),
            newTaskButton.heightAnchor.constraint(equalToConstant: 34)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if filterTask.isEmpty && section == 0 {
            return 50
        }

        switch filterTask[section] {
        case .overview:
            return 50
        case .active(let activeData):
            return activeData.isEmpty ? 0 : 40
        case .completed(let completedData):
            return completedData.isEmpty ? 0 : 40
        default:
            return 0
        }
    }

    @objc private func newTaskTapped() {
        if #available(iOS 15.0, *) {
            let vc = SenderLSRWVC()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
}

// MARK: - String to Date Helper
extension String {
    func toDate(format: String = "dd-MM-yyyy") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
}
