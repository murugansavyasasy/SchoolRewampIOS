//
//  ViewDetailsVc.swift
//  School Chimes
//
//  Created by apple on 21/07/26.
//

import UIKit

class ViewDetailsVc: UIViewController {


    @IBOutlet public weak var btnBack: UIButton!
   
    @IBOutlet public weak var tableView: UITableView!
    
    public var examResponse: NewExamResponseSuc?
    public var currentSubject: NewSubject?
    public var activities: [NewActivity] = []

    override public func viewDidLoad() {
        super.viewDidLoad()
       
        setupTableView()
        loadData()
    }
    
  
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        let nib = UINib(nibName: "ActivityTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ActivityTableViewCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 350
    }
    
    private func loadData() {

        self.tableView.reloadData()
    }
    
    @IBAction public func didTapBack(_ sender: UIButton) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ViewDetailsVc: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as? ActivityTableViewCell else {
            return UITableViewCell()
        }
        
        let activity = activities[indexPath.row]
        cell.configure(with: activity, delegate: self)
        return cell
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.text = "ACTIVITIES (\(activities.count))"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = UIColor(red: 100/255, green: 110/255, blue: 125/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
}

// MARK: - ActivityCellDelegate

extension ViewDetailsVc: NewActivityCellDelegate {
    public func didSelectRubric(_ rubric: Rubric) {
        let detailVC = RubricDetailViewController(nibName: "RubricDetailViewController", bundle: nil)
        detailVC.rubric = rubric
        present(detailVC, animated: true)
    }
}
