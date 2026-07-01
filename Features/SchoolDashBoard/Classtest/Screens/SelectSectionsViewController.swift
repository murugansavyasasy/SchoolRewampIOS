import UIKit

public final class SelectSectionsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet public weak var tableView: UITableView!
    
    // MARK: - Properties
    public var viewModel: CreateTestViewModel?
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        
        // Register Cell Nibs
        tableView.register(UINib(nibName: "SectionTableViewCell", bundle: nil), forCellReuseIdentifier: "SectionTableViewCell")
        tableView.register(UINib(nibName: "SummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "SummaryTableViewCell")
    }
}

// MARK: - UITableViewDataSource & Delegate
extension SelectSectionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let standard = viewModel?.selectedStandard else { return 0 }
        // Section card rows + 1 selection summary row
        return standard.sections.count + 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel, let standard = viewModel.selectedStandard else {
            return UITableViewCell()
        }
        
        let sectionsCount = standard.sections.count
        
        // Render summary banner at the bottom
        if indexPath.row == sectionsCount {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryTableViewCell", for: indexPath) as? SummaryTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(withCount: viewModel.selectedSections.count)
            return cell
        }
        
        // Render section item cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTableViewCell", for: indexPath) as? SectionTableViewCell else {
            return UITableViewCell()
        }
        
        let section = standard.sections[indexPath.row]
        let isSelected = viewModel.isSectionSelected(section)
        cell.configure(with: section, standardName: standard.name, isSelected: isSelected)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel, let standard = viewModel.selectedStandard else { return }
        
        let sectionsCount = standard.sections.count
        if indexPath.row < sectionsCount {
            let section = standard.sections[indexPath.row]
            viewModel.toggleSection(section)
            tableView.reloadData()
        }
    }
}
