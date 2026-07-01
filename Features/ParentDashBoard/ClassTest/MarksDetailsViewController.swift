//
//  MarksDetailsViewController.swift
//  parentScreenVc
//
//  Created by apple on 01/07/26.
//

import UIKit

class MarksDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var classTest: ClassTest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizeHeaderView()
    }
    
    private func setupNavigationBar() {
        navigationBarView.backgroundColor = UIColor(red: 242/255, green: 245/255, blue: 252/255, alpha: 1.0)
        
        backButton.layer.cornerRadius = 16
        backButton.backgroundColor = .white
        backButton.layer.borderWidth = 1.0
        backButton.layer.borderColor = UIColor(red: 234/255, green: 240/255, blue: 246/255, alpha: 1.0).cgColor
        
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        // Register Cell
        let cellNib = UINib(nibName: "SubjectMarksCardCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "SubjectMarksCardCell")
        
        // Setup Header View
        if let exam = classTest {
            let header = MarksHeaderView.loadFromNib()
            header.configure(with: exam)
            tableView.tableHeaderView = header
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220
    }
    
    private func resizeHeaderView() {
        guard let header = tableView.tableHeaderView else { return }
        
        let width = tableView.bounds.size.width
        let fittingSize = header.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        if header.frame.size.height != fittingSize.height {
            header.frame.size.height = fittingSize.height
            tableView.tableHeaderView = header
        }
    }
    
    @objc private func didTapBack() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classTest?.subjects.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectMarksCardCell", for: indexPath) as? SubjectMarksCardCell,
              let subject = classTest?.subjects[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: subject)
        return cell
    }
}
