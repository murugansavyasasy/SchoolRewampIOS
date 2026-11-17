//
//  StudentFeeDetailsVC.swift
//  School Chimes
//
//  Staff side: Student Report → tap a student → this screen.
//  Shows the student's fee summary (total, paid, discount, pending) and every fee
//  by category (term, other, transport, hostel, carryover, quantity) from
//  fee/api/fee-details/student-fee-details. Rows with months, carried-over items
//  or payments expand to show them.
//  Layout: StudentFeeDetailsVC.xib, StudentFeeSummaryCell.xib, StudentFeeRowCell.xib
//

import UIKit

final class StudentFeeDetailsVC: UIViewController {

    // MARK: - Input (set before presenting)
    var studentId = ""
    var studentName = ""
    var classSection = ""

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    // MARK: - State
    private var details: StudentFeeDetails?
    private var expanded = Set<IndexPath>()
    private let refresh = UIRefreshControl()
    var accidmaicYrId = ""

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = studentName
        subtitleLabel.text = studentId.isEmpty ? classSection : "\(classSection)  ·  ID \(studentId)"

        tableView.register(UINib(nibName: StudentFeeSummaryCell.id, bundle: nil), forCellReuseIdentifier: StudentFeeSummaryCell.id)
        tableView.register(UINib(nibName: StudentFeeRowCell.id, bundle: nil), forCellReuseIdentifier: StudentFeeRowCell.id)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        refresh.addTarget(self, action: #selector(loadFeeDetails), for: .valueChanged)
        tableView.refreshControl = refresh

        loadFeeDetails()
    }

    @IBAction func backAct(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - Data
    private func show(_ response: StudentFeeDetailsResponse?, errorMessage: String? = nil) {
        spinner.stopAnimating()
        refresh.endRefreshing()
        expanded.removeAll()

        if response?.status == true, let d = response?.details {
            details = d
            emptyLabel.isHidden = true
        } else {
            details = nil
            emptyLabel.text = errorMessage ?? response?.message ?? "No fee details found for this student.".translated()
            emptyLabel.isHidden = false
        }
        tableView.reloadData()
    }

    @objc private func loadFeeDetails() {
        if !refresh.isRefreshing { spinner.startAnimating() }
        emptyLabel.isHidden = true

        let params: [String: Any] = [
            "student_id": studentId,
            "country_id": UserDefaultFileManager.getCountryDetails()?.id ?? 0,
            "academic_year_id": accidmaicYrId
        ]
        let token = UserDefaultFileManager.get_staff_Details()?.access_token ?? ""

        APIService.shared.makeApi(
            url: ServiceUrl.fee_api_fee_details_student_fee_details,
            parameters: params,
            type: ApitTypeSringFile.GET,
            token: token,
            isBaseUrl: false
        ) { [weak self] (result: Result<StudentFeeDetailsResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.show(response)
                case .failure(let error):
                    self.show(nil, errorMessage: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - Table
// Section 0 = summary; sections 1... = fee categories.

extension StudentFeeDetailsVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let d = details else { return 0 }
        return 1 + d.categories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let d = details else { return 0 }
        return section == 0 ? 1 : d.categories[section - 1].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let d = details else { return nil }
        if section == 0 { return "Fee summary".translated() }
        let c = d.categories[section - 1]
        
        return "\(c.title)  ·  \("Pending".translated()) \(c.totalPending)"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let d = details else { return UITableViewCell() }
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: StudentFeeSummaryCell.id, for: indexPath) as! StudentFeeSummaryCell
            cell.configure(d.summary)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: StudentFeeRowCell.id, for: indexPath) as! StudentFeeRowCell
        cell.configure(d.categories[indexPath.section - 1].rows[indexPath.row], expanded: expanded.contains(indexPath))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section > 0, let d = details,
              !d.categories[indexPath.section - 1].rows[indexPath.row].breakdown.isEmpty else { return }
        if expanded.contains(indexPath) { expanded.remove(indexPath) } else { expanded.insert(indexPath) }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
