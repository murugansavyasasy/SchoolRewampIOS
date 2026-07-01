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

    var exams: [ExamListItem] = []

    // Rotating accent colors — matches screenshot pattern (purple, blue, purple...)
    private let accentColors: [UIColor] = [
        UIColor(red: 0.42, green: 0.36, blue: 0.90, alpha: 1),   // purple
        UIColor(red: 0.25, green: 0.55, blue: 0.95, alpha: 1),   // blue
        UIColor(red: 0.60, green: 0.40, blue: 0.90, alpha: 1)    // violet
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
        examListTV.estimatedRowHeight = 160
        examListTV.register(UINib(nibName: "ExamReportsTVC", bundle: nil), forCellReuseIdentifier: "ExamReportsTVC")
    }

    private func updateExamCount() {
        examCountLbl.setTitle("\(exams.count) EXAMS", for: .normal)
    }

    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        // or: dismiss(animated: true)
    }

    func getExamReports() {
        // showActivityLoader()

        APIService.shared.makeApi(
            url: ServiceUrl.exam_reports,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "",
            isBaseUrl: true
        ) { [weak self] (result: Result<ExamReportResponse, Error>) in

            guard let self = self else { return }

            DispatchQueue.main.async {
                // self.hideActivityLoader()

                switch result {
                case .success(let response):
                    guard let items = response.data else { return }

                    self.exams = items.enumerated().map { index, item in
                        item.toExamListItem(iconTint: self.accentColors[index % self.accentColors.count])
                    }

                    self.updateExamCount()
                    self.examListTV.reloadData()

                case .failure(let error):
                    print("❌ Error:", error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension ExamReportsVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ExamReportsTVC",
            for: indexPath
        ) as? ExamReportsTVC else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none
        cell.configure(with: exams[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedExam = exams[indexPath.row]
        print("Selected exam:", selectedExam.title)
        // navigate to exam details screen here
    }
}
