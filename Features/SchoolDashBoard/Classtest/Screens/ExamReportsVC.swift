//
//  ExamReportsVC.swift
//  School Chimes
//
//  Created by Chandhru on 01/07/26.
//

import UIKit

class ExamReportsVC: UIViewController, Datepicker {
    func date(date: String) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = DateInputs.dd_MMM_yyyy
        outputFormatter.locale = LocaleManager.shared.displayLocale
        var selectedDate = Date()
        if !date.isEmpty {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = DateInputs.dd_MMM_yy
            inputFormatter.locale = LocaleManager.shared.displayLocale
            selectedDate = inputFormatter.date(from: date) ?? Date()
        }
        let comparison = Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day)
        if comparison == .orderedSame {
            todayLbl.text = Today
        } else if comparison == .orderedAscending {
            let dayFormatter = DateFormatter()
            dayFormatter.locale = LocaleManager.shared.displayLocale
            dayFormatter.dateFormat = DateOutPut.EEEE 
            todayLbl.text = dayFormatter.string(from: selectedDate)
        } else {
            todayLbl.text = FutureDate
        }
        dateLbl.text = outputFormatter.string(from: selectedDate)
        getExamReports()
    }
    

    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var examCountLbl: UIButton!
    @IBOutlet weak var examListTV: UITableView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dateStack: UIStackView!
    @IBOutlet weak var acodomicYearLbl: UILabel!
    @IBOutlet weak var acodomicdropDown: UIView!
    @IBOutlet weak var todayLbl: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var nodataImg: UIImageView!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var datestackView: UIView!

    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var class_test_details: [StaffClassTest] = []
    var AcadimicYearDatas: [AcadimicYearData] = []
    let Today = "All"
    let FutureDate = "Select a Date"
    var accadimYr: [String] = []
    var acodemicId: Int?
    let acidamicdrops = DropDown()
    var viewModel : CreateTestViewModel?
    let alert = CustomAlert()
    private let accentColors: [UIColor] = [UIColor.backGroundClr]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        getAcademicYearList()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getExamReports()
    }
    private func setupUI() {
        tittleLbl.text = "Exams"
        acodomicdropDown.setShadow()
        dateView.setShadow()
        examCountLbl.layer.cornerRadius = examCountLbl.frame.height / 2
        dateBtn.layer.cornerRadius = 8
        examCountLbl.clipsToBounds = true
        examCountLbl.isUserInteractionEnabled = false
        dateStack.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateStackTapped))
        dateStack.addGestureRecognizer(tapGesture)
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
        examListTV.register(
            UINib(nibName: "ExamReportsTVC", bundle: nil),
            forCellReuseIdentifier: "ExamReportsTVC"
        )
    }

    private func updateExamCount() {
        examCountLbl.setTitle("\(class_test_details.count) EXAMS", for: .normal)
    }

    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func selectDate(_ sender: UIButton) {
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.date = dateLbl.text
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        present(vc, animated: false)
    }


    @objc private func dateStackTapped() {
        selectDate(dateBtn)
    }

    func getExamReports() {
        let date = dateLbl.text == "Select a Date" ? "0" : ConvertDateStringSmart(dateLbl.text)
        APIService.shared.makeApi(
            url: ServiceUrl.exam_class_test_details,
            parameters: ["class_test_id":"0", "exam_date":date,"academic_year_id":"\(acodemicId ?? 0)"],
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
                    self.nodataImg.isHidden = !self.class_test_details.isEmpty
                    self.nodataLbl.isHidden = !self.class_test_details.isEmpty
                    self.self.nodataLbl.text = response.message
                    self.examListTV.reloadData()

                case .failure(let error):
                    print("❌ Error:", error.localizedDescription)
                    self.nodataImg.isHidden = !self.class_test_details.isEmpty
                    self.nodataLbl.isHidden = !self.class_test_details.isEmpty
                    self.self.nodataLbl.text = error.localizedDescription
                }
            }
        }
    }
    @IBAction func selectAcademicYear(_ sender: UIButton) {
        acidamicdrops.anchorView = acodomicdropDown
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acodomicdropDown.bounds.height)
        acidamicdrops.show()
        acidamicdrops.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            self.acodomicYearLbl.text = item
            self.acodemicId = self.AcadimicYearDatas[index].id
            self.getExamReports()
        }
    }
 
    func formatDate(_ raw: String) -> String {
        guard !raw.isEmpty else { return "" }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        guard let dateObj = inputFormatter.date(from: raw) else { return raw }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM"
        return outputFormatter.string(from: dateObj)
    }


    // MARK: - API Calls (moved here from ExamHeaderView)
    func getAcademicYearList() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_recipient_get_academic_year_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? "",
            isBaseUrl: false
        ) { [weak self] (result: Result<get_academic_yearSuc, Error>) in

            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {

                case .success(let res):
                    guard res.status == true else { return }

                    self.AcadimicYearDatas = res.data ?? []
                    self.accadimYr = self.AcadimicYearDatas.compactMap { $0.year }
                    if let currentYear = self.AcadimicYearDatas.first(
                        where: { $0.current_academic_year == true }
                    ) {

                        self.acodemicId = currentYear.id
                        self.acodomicYearLbl.text = currentYear.year
                        self.getExamReports()
                    }

                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension ExamReportsVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return class_test_details.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ExamReportsTVC",
            for: indexPath
        ) as? ExamReportsTVC else {
            return UITableViewCell()
        }

        let exam = class_test_details[indexPath.row]
        let sections = exam.sections ?? []
        let tint = accentColors[indexPath.row % accentColors.count]
        cell.deleteBtn.tag = indexPath.row
        cell.selectionStyle = .none
        cell.configure(
            examName: exam.exam_name ?? "",
            sentBy: exam.sent_by ?? "",
            sections: sections,
            iconTint: tint
        )

        cell.onSectionTap = { [weak self] tappedSection in
            self?.handleSectionTap(exam: exam, section: tappedSection)
        }
        cell.ontestDeletTap = { [weak self] index in
            guard let self = self else { return }

            let examId = self.class_test_details[index].class_test_id

            alert.showAlertCancel(
                title: "Delete Exam",
                message: "Are you sure you want to delete this exam?",
                actionLbl1: "Delete",
                actionLbl2: "Cancel",
                on: self,
                onOk: {
                    self.deleteExam(exam_id: examId)
                },
                onNo: {
                    print("Cancelled")
                }
            )
        }

        return cell
    }

    func deleteExam(exam_id: String?) {
        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_exam_test_delete,
            parameters: ["class_test_id": exam_id ?? ""],
            type: ApitTypeSringFile.PUT,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "",
            isBaseUrl: true
        ) { [weak self] (result: Result<TestMarkDetailsResponse<TestMarkData>, Error>) in

            guard let self = self else { return }

            DispatchQueue.main.async {

                switch result {

                case .success(_):

                    self.class_test_details.removeAll {
                        $0.class_test_id == exam_id
                    }

                    self.updateExamCount()
                    self.nodataImg.isHidden = !self.class_test_details.isEmpty
                    self.nodataLbl.isHidden = !self.class_test_details.isEmpty
                    self.self.nodataLbl.text = " Class Test not available"
                    self.examListTV.reloadData()

                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func handleSectionTap(exam: StaffClassTest, section: StaffSection) {
        viewModel?.class_test_id = exam.class_test_id ?? ""
        viewModel?.section_id = section.section_id ?? ""
         let vc = ExamRecordsVC(nibName: nil, bundle: nil)
        vc.class_test_details = section
        vc.viewModel = viewModel
        vc.ExamNameString = exam.exam_name ?? ""
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}


