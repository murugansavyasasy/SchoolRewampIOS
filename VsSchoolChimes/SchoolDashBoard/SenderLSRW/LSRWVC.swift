//
//  LSRWVC.swift
//  School Chimes
//
//  Created by Chandhru on 13/08/25.
//

import UIKit
protocol FilterDelegate{
    func selectedIndex(index:Int?)
}
class LSRWVC: UIViewController, FilterDelegate {
    func selectedIndex(index: Int?) {
        guard let idx = index, idx >= 0, idx < filtterArray.count else {
            filterTask = recentTasks
            return
        }
        selectedIndex = idx
        let selectedFilter = filtterArray[idx]
        
        if selectedFilter == "All" {
            filterTask = recentTasks
        } else {
            filterTask = recentTasks.filter { $0.activity_type.rawValue == selectedFilter }
        }
        lsrwTable.reloadData()
    }

    @IBOutlet weak var lsrwTable: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    // Dashboard overview data
    var dashboardData: [DashboardItem] = []
    private var filtterArray = [
        "All",
        "Listening",
        "Speaking",
        "Reading",
        "Writing",
        "Completed",
        "Pending"
    ]
    // Recent tasks list
    var recentTasks: [LSRWTask] = []
    var filterTask: [LSRWTask] = []
    var selectedIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
                lsrwTable.sectionHeaderTopPadding = 0
            }
        setupTableView()
        loadData()
    }
    
    private func setupTableView() {
        lsrwTable.dataSource = self
        lsrwTable.delegate = self
        
        // Register custom cells
        lsrwTable.register(UINib(nibName: "LSRWTaskTVC", bundle: nil), forCellReuseIdentifier: "LSRWTaskTVC")
        lsrwTable.register(UINib(nibName: "LSRWProgressTVC", bundle: nil), forCellReuseIdentifier: "LSRWProgressTVC")
        
        lsrwTable.separatorStyle = .none
        lsrwTable.showsVerticalScrollIndicator = false
        BackBtn.configureAsBackButton(firstLine: "LSRW",secondLine:"Listening, Speaking, Reading,Writing")
        getLSRW()
    }
    
    private func loadData() {
        // Dashboard stats
        dashboardData = [
            DashboardItem(
                title: "Active Tasks",
                value: "3",
                subtitle: "1 overdue",
                icon: "📋"
            ),
            DashboardItem(
                title: "Total Students",
                value: "248",
                subtitle: "Across 8 classes",
                icon: "👥"
            ),
            DashboardItem(
                title: "Avg. Performance",
                value: "87%",
                subtitle: "↑ 5% from last month",
                icon: "📈"
            ),
            DashboardItem(
                title: "Completed Today",
                value: "156",
                subtitle: "Great progress!",
                icon: "✅"
            )
        ]

        
        // Date formatter for sample data
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        lsrwTable.reloadData()
    }
    func getLSRW() {
        APIService.shared.makeApi(
            url: ServiceUrl.lms_api_lsrw_skills_report,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<LSRWResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        self?.recentTasks = response.data ?? []
                        self?.filterTask = response.data ?? []
                        self?.lsrwTable.reloadData()
//                        self?.updateCountLabels()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.lsrwTable.reloadData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
//                    self?.showAlert(message: "Network error occurred. Please try again.")
                    self?.lsrwTable.reloadData()
                }
            }
        }
    }
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

// MARK: - UITableViewDataSource
extension LSRWVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // Dashboard + Recent Tasks
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 2) ? filterTask.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWProgressTVC", for: indexPath) as! LSRWProgressTVC
            cell.configure(with: dashboardData)
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWProgressTVC", for: indexPath) as! LSRWProgressTVC
            cell.configure(with: nil,selectedIndex: selectedIndex)
            cell.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWTaskTVC", for: indexPath) as! LSRWTaskTVC
            let task = filterTask[indexPath.row]
            cell.configure(with: task)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension LSRWVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 120
        case 1:
            return 60
        case 2:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 50
        case 2:
            return 40
        default:
            return 0
        }
        
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return "Dashboard Overview"
//        case 2:
//            return "Recent Tasks"
//        default:
//            return nil
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 {
            let selectedTask = filterTask[indexPath.row]
            navigateToTaskDetail(task: selectedTask)
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        // Set section title
        switch section {
        case 0:
            titleLabel.text = "Dashboard Overview"
        case 2:
            titleLabel.text = "Recent Tasks"
        default:
            titleLabel.text = nil
        }
        
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // Add button only for section 0
        if section == 0 {
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

    
    @objc private func newTaskTapped() {
        // Navigate to Create Task screen
        if #available(iOS 15.0, *) {
            let vc = SenderLSRWVC()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        
    }
}


// MARK: - Data Models
struct DashboardItem {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
}
