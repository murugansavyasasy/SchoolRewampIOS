//
//  PunchHistoryListVC.swift
//  School Chimes
//
//  Created by Chandhru on 05/09/25.
//

import UIKit

class PunchHistoryListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var backView: UIButton!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    
    var selected_staff_id: String?
    var staffdetails = UserDefaultFileManager.get_staff_Details()
    var PunchDetails: [puchHistoryList]? = []
    var selectedDate = ""
    var user: String?
    var roll: String?
    var date: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyView.layer.cornerRadius = 10
        historyView.layer.borderColor = UIColor.systemGray5.cgColor
        historyView.layer.borderWidth = 1
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        // Register cells
        let rowNib = UINib(nibName: CellConfingName.PunchHistTableViewCell, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: CellConfingName.PunchHistTableViewCell)
        tv.register(UINib(nibName: "PunchUserDetailsTVC", bundle: nil),
                    forCellReuseIdentifier: "PunchUserDetailsTVC")
        
        noRecordLbl.isHidden = true
        
        // Back tap
        let back = UITapGestureRecognizer(target: self, action: #selector(backClick))
        backView.addGestureRecognizer(back)
        
        tv.delegate = self
        tv.dataSource = self
        
        Geometric_Punch_History()
    }
    
    @IBAction func backClick() {
        dismiss(animated: true)
    }
    
    // MARK: - API Call
    func Geometric_Punch_History() {
        APIService.shared.makeApi(
            url: ServiceUrl.staff_attd_geometric_geometric_punch_history,
            parameters: [
                punchHistoryStringFile.from_date : selectedDate,
                punchHistoryStringFile.to_date : selectedDate,
                punchHistoryStringFile.staff_id : selected_staff_id ?? ""
            ],
            type: ApitTypeSringFile.GET,
            token: staffdetails?.access_token ?? ""
        ) { [weak self] (result: Result<PunchHistoryResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    if response.status == true {
                        self.noRecordLbl.isHidden = true
                        self.tv.isHidden = false
                        self.PunchDetails = response.data?.first?.timings
                        self.tv.reloadData()
                    } else {
                        self.noRecordLbl.isHidden = false
                        self.noRecordLbl.text = response.message
                        self.tv.isHidden = true
                        self.PunchDetails = response.data?.first?.timings
                        self.tv.reloadData()
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - TableView Setup
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : (PunchDetails?.count ?? 0)
    }
    
    // ✅ Only section 1 has header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 1 ? makeAttendanceHeaderView() : nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 70 : 0
    }
    
    // ❌ No footer anywhere
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PunchUserDetailsTVC", for: indexPath) as! PunchUserDetailsTVC
            cell.configureWithDetails(
                institutionName: staffdetails?.school_name ?? "",
                staffName: staffdetails?.name ?? "",
                designation: staffdetails?.role ?? "",
                date: selectedDate
            )
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.PunchHistTableViewCell, for: indexPath) as! PunchHistTableViewCell
            if let punch = PunchDetails?[indexPath.row] {
//                cell.timing.text = punch.time
//                cell.punchType.text = punch.punch_type?.value
//                cell.phoneModel.text = punch.device_model
                cell.configure(with: punch)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Helper (Custom Header View)
    private func makeAttendanceHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "History"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        
        let dateLabel = UILabel()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMM yyyy"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"

        if let date = inputFormatter.date(from: selectedDate) {
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = formatter.string(from: Date())
        }

        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .darkGray
        
//        // Status
//        let statusView = UIView()
//        statusView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
//        statusView.layer.cornerRadius = 8
//        
//        let dot = UIView()
//        dot.backgroundColor = .systemGreen
//        dot.layer.cornerRadius = 4
        
//        let statusLabel = UILabel()
//        statusLabel.text = "Active"
//        statusLabel.font = UIFont.boldSystemFont(ofSize: 14)
//        statusLabel.textColor = .systemGreen
        
        // Add subviews
        headerView.addSubview(titleLabel)
        headerView.addSubview(dateLabel)
//        headerView.addSubview(statusView)
//        statusView.addSubview(dot)
//        statusView.addSubview(statusLabel)
        
        // Constraints
        [titleLabel, dateLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            
//            statusView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
//            statusView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
//            statusView.heightAnchor.constraint(equalToConstant: 30),
//            statusView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
//            
//            dot.leadingAnchor.constraint(equalTo: statusView.leadingAnchor, constant: 8),
//            dot.centerYAnchor.constraint(equalTo: statusView.centerYAnchor),
//            dot.widthAnchor.constraint(equalToConstant: 8),
//            dot.heightAnchor.constraint(equalToConstant: 8),
//            
//            statusLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 6),
//            statusLabel.centerYAnchor.constraint(equalTo: dot.centerYAnchor),
//            statusLabel.trailingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: -8),
        ])
        
        return headerView
    }
}
