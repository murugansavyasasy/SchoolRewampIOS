//
//  LSRWVC.swift
//  School Chimes
//
//  Created by Chandhru on 13/08/25.
//

import UIKit

protocol FilterDelegate {
    func selectedIndex(index: Int?)
    func navigate(index: Int?)
}

enum LsrwDisplaySection {
    case overview([Overview])
    case filterArray([String])
    case active([LSRWTask])
    case completed([LSRWTask])
}

class LSRWVC: UIViewController, FilterDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var lsrwTable: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var nodataImg: UIImageView!
    // MARK: - Data
    var dashboardData: [Overview] = []
    var recentTasks: [LsrwDisplaySection] = []
    var filterTask: [LsrwDisplaySection] = []
    var allTask: LSRWData?
    var activeTask: [LSRWTask] = []
    var completedTask: [LSRWTask] = []
    var selectedIndex = 0
    
    // Filters
    let filterArray = [
        "All",
        "Listening",
        "Speaking",
        "Reading",
        "Writing",
        "Completed",
        "Pending"
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            lsrwTable.sectionHeaderTopPadding = 0
        }
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        lsrwTable.dataSource = self
        lsrwTable.delegate = self
        
        // Register custom cells
        lsrwTable.register(UINib(nibName: "LSRWTaskTVC", bundle: nil), forCellReuseIdentifier: "LSRWTaskTVC")
        lsrwTable.register(UINib(nibName: "LSRWProgressTVC", bundle: nil), forCellReuseIdentifier: "LSRWProgressTVC")
        
        lsrwTable.separatorStyle = .none
        lsrwTable.showsVerticalScrollIndicator = false
        
        BackBtn.configureAsBackButton(firstLine: "LSRW", secondLine:"Listening, Speaking, Reading, Writing")
        
        getLSRW()
    }
    
    // MARK: - API
    func getLSRW() {
        APIService.shared.makeApi(
            url: ServiceUrl.lms_api_lsrw_skills_report,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<LSRWReportResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status ?? false,
                   let firstData = response.data?.first {
                    
                    DispatchQueue.main.async {
                        self?.dashboardData = firstData.overview ?? []
                        self?.activeTask = firstData.active ?? []
                        self?.completedTask = firstData.completed ?? []
                        self?.recentTasks = []
                        
                        if !(firstData.overview?.isEmpty ?? true) {
                            self?.recentTasks.append(.overview(firstData.overview ?? []))
                        }
                        self?.recentTasks.append(.filterArray(self?.filterArray ?? []))
                        
                        if !(firstData.active?.isEmpty ?? true) {
                            self?.recentTasks.append(.active(firstData.active ?? []))
                        }
                        if !(firstData.completed?.isEmpty ?? true) {
                            self?.recentTasks.append(.completed(firstData.completed ?? []))
                        }
                        
                        self?.filterTask = self?.recentTasks ?? []
                        self?.allTask = firstData
                        self?.nodataImg.isHidden = !(self?.filterTask.isEmpty ?? true)
                        self?.lsrwTable.reloadData()
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self?.lsrwTable.reloadData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                    self?.lsrwTable.reloadData()
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
        case "All":
            // Restore all tasks (reset)
            filterTask = recentTasks
            
        case "Completed":
            updateSection(.completed(completedTask))
            
        case "Pending":
            let pending = activeTask.filter { $0.is_submitted == false }
            updateSection(.active(pending))
            
        default:
            let filtered = activeTask.filter { $0.activity_type?.displayName == selectedFilter }
            updateSection(.active(filtered))
        }
        
        lsrwTable.reloadData()
    }
    
    // MARK: - Helper (replace only matching section)
    private func updateSection(_ newSection: LsrwDisplaySection) {
        filterTask = filterTask.map { section in
            switch (section, newSection) {
            case (.active, .active(let tasks)):
                return .active(tasks)
            case (.completed, .completed(let tasks)):
                return .completed(tasks)
            default:
                return section
            }
        }
    }
    
    func navigate(index: Int?) {
        guard let index = index else { return }
        
        switch index {
        case 0:
            let vc = LSRWSubmissionVC()
            vc.modalPresentationStyle = .fullScreen
            vc.report = activeTask
            vc.btnTitle = "Active Task"
            present(vc, animated: true)
        case 1:
            let vc = SelectedLSRWSubmissionVC()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        case 2:
            let vc = LSRWSubmissionVC()
            vc.modalPresentationStyle = .fullScreen
            vc.report = completedTask
            vc.btnTitle = "Completed Task"
            present(vc, animated: true)
        default:
            print("Navigate index: \(index)")
        }
    }
}

// MARK: - UITableViewDataSource
extension LSRWVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterTask.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch filterTask[section] {
        case .overview:
            return 1
        case .filterArray:
            return 1
        case .active(let tasks), .completed(let tasks):
            return tasks.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch filterTask[indexPath.section] {
        case .overview(let overview):
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWProgressTVC", for: indexPath) as! LSRWProgressTVC
            cell.configure(with: overview)
            cell.delegate = self
            return cell
            
        case .filterArray:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWProgressTVC", for: indexPath) as! LSRWProgressTVC
            cell.configure(with: nil, selectedIndex: selectedIndex)
            cell.delegate = self
            return cell
            
        case .active(let tasks):
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWTaskTVC", for: indexPath) as! LSRWTaskTVC
            cell.configure(with: tasks[indexPath.row])
            return cell
            
        case .completed(let tasks):
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWTaskTVC", for: indexPath) as! LSRWTaskTVC
            cell.configure(with: tasks[indexPath.row])
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
            let selectedTask = tasks[indexPath.row]
            navigateToTaskDetail(task: selectedTask)
        default:
            break
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
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        switch filterTask[section] {
        case .overview: titleLabel.text = "Dashboard Overview"
        case .filterArray: titleLabel.text = ""
        case .active: titleLabel.text = "Active Tasks"
        case .completed: titleLabel.text = "Completed Tasks"
        }
        
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        if case .overview = filterTask[section] {
            let newTaskButton = UIButton(type: .system)
            newTaskButton.setImage(UIImage(systemName: "plus"), for: .normal)
            newTaskButton.tintColor = .white
            newTaskButton.setTitle("New Task", for: .normal)
            newTaskButton.setTitleColor(.white, for: .normal)
            newTaskButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            newTaskButton.backgroundColor = .systemBlue
            newTaskButton.layer.cornerRadius = 8
            newTaskButton.addTarget(self, action: #selector(newTaskTapped), for: .touchUpInside)
            
            headerView.addSubview(newTaskButton)
            newTaskButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                newTaskButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
                newTaskButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                newTaskButton.widthAnchor.constraint(equalToConstant: 100),
                newTaskButton.heightAnchor.constraint(equalToConstant: 34)
            ])
        }
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch filterTask[section] {
        case .overview:
            return 50
        case .active,.completed:
            return 40
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
