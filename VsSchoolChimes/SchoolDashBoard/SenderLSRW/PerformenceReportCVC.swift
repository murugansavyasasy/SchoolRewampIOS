//
//  PerformenceReportCVC.swift
//  School Chimes
//
//  Created by Chandhru on 22/08/25.
//

import UIKit

class PerformenceReportCVC: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var weeklyReport: [PerformanceReport] = []
    private var topPerformance: [TopReport] = []
    private var isWeekly: Bool = true   // To know which section we are loading
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LSRWPerformenceTVC", bundle: nil),
                           forCellReuseIdentifier: "LSRWPerformenceTVC")
        outerView.setShadow()
    }

    /// Configure cell with weekly OR topPerformance data
    func config(title: String, weeklyReport: [PerformanceReport]?, topPerformance: [TopReport]?) {
        titleLbl.text = title
        if let weekly = weeklyReport {
            self.weeklyReport = weekly
            self.isWeekly = true
        } else if let top = topPerformance {
            self.topPerformance = top
            self.isWeekly = false
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PerformenceReportCVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isWeekly ? weeklyReport.count : topPerformance.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWPerformenceTVC",
                                                       for: indexPath) as? LSRWPerformenceTVC else {
            return UITableViewCell()
        }

        if isWeekly {
            let report = weeklyReport[indexPath.row]
            cell.persantageLbl.text = "\(report.percentage)%"
            cell.pesantageProgress.progress = Float(report.percentage) / 100.0
            cell.classLbl.isHidden = true
            cell.nameLbl.text = report.title
            cell.initialBtn.isHidden = true
        } else {
            let top = topPerformance[indexPath.row]
            cell.persantageLbl.text = "\(top.percentage)%"
            cell.persantageLbl.textColor = .systemGreen
            cell.pesantageProgress.isHidden = true
            cell.classLbl.isHidden = false
            cell.classLbl.text = "Class \(top.studentClass) - \(top.section)"
            cell.nameLbl.text = top.name
            cell.initialBtn.isHidden = false
            let initials = top.name.split(separator: " ").compactMap { $0.first }.map { String($0) }.joined()
            cell.initialBtn.setTitle(initials, for: .normal)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
