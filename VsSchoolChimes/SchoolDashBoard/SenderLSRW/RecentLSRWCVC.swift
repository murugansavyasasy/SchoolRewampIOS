//
//  RecentLSRWCVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/06/25.
//

import UIKit

class RecentLSRWCVC: UICollectionViewCell, UITableViewDataSource {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var titleLbl: UILabel!

    // MARK: - Activities Data
    let activitiesArray: [ActivityModel] = [
        ActivityModel(title: "Pronunciation Practice", subtitle: "Completed 2 hours ago", icon: UIImage(systemName: "target")!, iconColor: UIColor.systemPurple),
        ActivityModel(title: "Story Reading Challenge", subtitle: "Completed yesterday", icon: UIImage(systemName: "book")!, iconColor: UIColor.systemIndigo),
        ActivityModel(title: "Weekly Quiz Champion", subtitle: "Completed 3 days ago", icon: UIImage(systemName: "trophy")!, iconColor: UIColor.systemPurple)
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        tableview.dataSource = self
        tableview.register(UINib(nibName: "RecentTaskTVC", bundle: nil), forCellReuseIdentifier: "RecentTaskTVC")
        tableview.isScrollEnabled = false // disable scroll if used inside scrollable parent
        tableview.separatorStyle = .none
        titleLbl.text = "Recent Activities"
        applyShadowAndCornerRadius(to: outerView)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activitiesArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentTaskTVC", for: indexPath) as? RecentTaskTVC else {
            return UITableViewCell()
        }

        let model = activitiesArray[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}
