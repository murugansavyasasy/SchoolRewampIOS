//
//  SelectSubjectVc.swift
//  School Chimes
//
//  Created by apple on 24/06/26.
//

import UIKit

class SelectSubjectVc: UIViewController {

    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var subtitleLabel: UILabel!
    
    // MARK: - Properties
    public var viewModel: CreateTestViewModel?
    
    private var displayedSections: [TestSectionSubjects] {
        guard let viewModel = viewModel else { return [] }
        
        // Find the names of selected sections
        let selectedSectionNames = Set(
            viewModel.selectedStandard?.sections
                .filter { viewModel.isSectionSelected($0) }
                .map { $0.name.uppercased() } ?? []
        )
        
        // Filter subjects based on selected section names
        let filtered = viewModel.sectionSubjects.filter {
            selectedSectionNames.contains($0.sectionName.uppercased())
        }
        
        // Fallback to all mock subjects if no intersection (for demo safety)
        return filtered.isEmpty ? viewModel.sectionSubjects : filtered
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        loadData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateSummaryText()
    }
 
    private func setupUI() {
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.adjustsFontForContentSizeCategory = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableView.automaticDimension
        
        // Register Cell
        tableView.register(
            UINib(nibName: "SectionSubjectsTableViewCell", bundle: nil),
            forCellReuseIdentifier: "SectionSubjectsTableViewCell"
        )
    }
    
    private func loadData() {
        // Fetch subjects JSON asynchronously
        viewModel?.getSubject()
        viewModel?.onDataLoaded = { [weak self] in
            self?.tableView.reloadData()
        }
        updateSummaryText()
    }
    
    private func updateSummaryText() {
        guard let viewModel = viewModel else { return }
        let selected = viewModel.selectedSubjects.count
        let total = viewModel.totalSubjectsCount()
        let text = "✓ " + String(
            format: "%d of %d subjects selected".translated(),
            selected,
            total
        )

        summaryLabel.text = text
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SelectSubjectVc: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(displayedSections.count)
        return displayedSections.count
      
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SectionSubjectsTableViewCell",
            for: indexPath
        ) as? SectionSubjectsTableViewCell,
              let viewModel = viewModel else {
            return UITableViewCell()
        }
        
        let sectionData = displayedSections[indexPath.row]
        cell.configure(with: sectionData, viewModel: viewModel)
        
        // Subject toggle callback
        cell.onSubjectToggled = { [weak self] sectionId,subjectId in
            viewModel.toggleSubjectSelection(sectionId: sectionId, subjectId: subjectId)
            self?.tableView.reloadRows(at: [indexPath], with: .none)
            self?.updateSummaryText()
        }
        
        // Select all callback
        cell.onSelectAllTapped = { [weak self] in
            let total = sectionData.subjects.count
            let currentlySelected = viewModel.selectedSubjectsCount(in: sectionData.sectionId)
            
            if currentlySelected == total {
                viewModel.deselectAllSubjects(in: sectionData.sectionId)
            } else {
                viewModel.selectAllSubjects(in: sectionData.sectionId)
            }
            
            self?.tableView.reloadRows(at: [indexPath], with: .none)
            self?.updateSummaryText()
        }
        
        return cell
    }
}
