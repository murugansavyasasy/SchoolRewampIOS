//
//  ExamReportsVC.swift
//  School Chimes
//
//  Created by Chandhru on 01/07/26.
//

import UIKit

class ExamReportsVC: UIViewController {

    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var examCountLbl: UIButton!
    @IBOutlet weak var examListTV: UITableView!

    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var class_test_details: [StaffClassTest] = []

    private let accentColors: [UIColor] = [
        UIColor(red: 0.42, green: 0.36, blue: 0.90, alpha: 1),
        UIColor(red: 0.25, green: 0.55, blue: 0.95, alpha: 1),
        UIColor(red: 0.60, green: 0.40, blue: 0.90, alpha: 1)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        getExamReports()
    }

    private func setupUI() {
        tittleLbl.text = "Exams"
        tittleLbl.font = .systemFont(ofSize: 30, weight: .heavy)

        examCountLbl.layer.cornerRadius = examCountLbl.frame.height / 2
        examCountLbl.clipsToBounds = true
        examCountLbl.backgroundColor = UIColor(red: 0.42, green: 0.36, blue: 0.90, alpha: 1)
        examCountLbl.setTitleColor(.white, for: .normal)
        examCountLbl.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        examCountLbl.isUserInteractionEnabled = false

        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
    }

    private func setupTableView() {
        examListTV.dataSource = self
        examListTV.delegate = self
        examListTV.separatorStyle = .none
        examListTV.backgroundColor = .clear
        examListTV.showsVerticalScrollIndicator = false
        examListTV.rowHeight = UITableView.automaticDimension
        examListTV.estimatedRowHeight = 70
        examListTV.sectionHeaderTopPadding = 0
        examListTV.register(UINib(nibName: "ExamReportsTVC", bundle: nil), forCellReuseIdentifier: "ExamReportsTVC")
        examListTV.register(ExamHeaderView.self, forHeaderFooterViewReuseIdentifier: "ExamHeaderView")
    }

    private func updateExamCount() {
        examCountLbl.setTitle("\(class_test_details.count) EXAMS", for: .normal)
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    func getExamReports() {
        APIService.shared.makeApi(
            url: ServiceUrl.exam_class_test_details,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "",
            isBaseUrl: true
        ) { [weak self] (result: Result<StaffClassTestResponse, Error>) in

            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.class_test_details = response.data ?? []
                    self.updateExamCount()
                    self.examListTV.reloadData()

                case .failure(let error):
                    print("❌ Error:", error.localizedDescription)
                }
            }
        }
    }

    // exam_date: "29-06-2026" -> "29 Jun"
    func formatDate(_ raw: String) -> String {
        guard !raw.isEmpty else { return "" }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        guard let dateObj = inputFormatter.date(from: raw) else { return raw }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM"
        return outputFormatter.string(from: dateObj)
    }
}

// MARK: - TableView DataSource & Delegate
extension ExamReportsVC: UITableViewDataSource, UITableViewDelegate {

    // 🔑 Each exam (StaffClassTest) = one section
    func numberOfSections(in tableView: UITableView) -> Int {
        return class_test_details.count
    }

    // 🔑 Each section (StaffSection) inside the exam = one row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return class_test_details[section].sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ExamReportsTVC",
            for: indexPath
        ) as? ExamReportsTVC else {
            return UITableViewCell()
        }

        let exam = class_test_details[indexPath.section]
        guard let staffSection = exam.sections?[indexPath.row] else { return cell }

        // First subject's first activity used for date/session/status display
        let firstActivity = staffSection.subjects?.first?.activities?.first

        cell.selectionStyle = .none
        cell.configure(
            sectionName: staffSection.section_name ?? "",
            dateText: formatDate(firstActivity?.exam_date ?? ""),
            session: firstActivity?.session ?? "",
            status: firstActivity?.status ?? "",
            iconTint: accentColors[indexPath.section % accentColors.count]
        )

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "ExamHeaderView"
        ) as? ExamHeaderView else {
            return nil
        }

        let exam = class_test_details[section]
        header.configure(
            title: exam.exam_name ?? "",
            sentBy: exam.sent_by ?? "",
            iconTint: accentColors[section % accentColors.count]
        )
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = .clear
        return footer
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let exam = class_test_details[indexPath.section]
        guard let staffSection = exam.sections?[indexPath.row] else { return }

        print("Selected exam:", exam.exam_name ?? "", "- section:", staffSection.section_name ?? "")
        // navigate using exam.class_test_id and staffSection.section_id
    }
}
import UIKit

class ExamHeaderView: UITableViewHeaderFooterView {

    private let iconView = UIView()
    private let iconImageView = UIImageView()
    private let titleLbl = UILabel()
    private let sentByLbl = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        contentView.backgroundColor = .clear
        backgroundView = UIView()
        backgroundView?.backgroundColor = .clear

        iconView.layer.cornerRadius = 12
        iconView.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.image = UIImage(systemName: "doc.text.fill")
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        titleLbl.font = .systemFont(ofSize: 17, weight: .bold)
        titleLbl.textColor = .black
        titleLbl.translatesAutoresizingMaskIntoConstraints = false

        sentByLbl.font = .systemFont(ofSize: 12, weight: .regular)
        sentByLbl.textColor = .systemGray
        sentByLbl.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconView)
        iconView.addSubview(iconImageView)
        contentView.addSubview(titleLbl)
        contentView.addSubview(sentByLbl)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),

            titleLbl.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLbl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            sentByLbl.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            sentByLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 2),
            sentByLbl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    func configure(title: String, sentBy: String, iconTint: UIColor) {
        titleLbl.text = title
        sentByLbl.text = "Sent by \(sentBy)"
        iconView.backgroundColor = iconTint
    }
}
