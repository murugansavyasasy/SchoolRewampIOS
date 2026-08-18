//
//  anaylizesVc.swift
//  School Chimes
//
//  Created by apple on 08/08/26.
//

import UIKit

class anaylizesVc: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var topBackBtnName: UIButton!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var noRecordStackView: UIStackView!
    @IBOutlet weak var subjectBreakDownView: UIView!
    @IBOutlet weak var preformView: UIView!
    @IBOutlet weak var summaryStackView: UIStackView!
    @IBOutlet weak var studentInfoView: UIView!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var selectedStudentAvatarView: UIView!
    @IBOutlet weak var selectedStudentInitialsLabel: UILabel!
    @IBOutlet weak var standardSecLbl: UILabel!
    @IBOutlet weak var admissinNumberLbl: UILabel!
    @IBOutlet weak var rollNumberLbl: UILabel!
    @IBOutlet weak var StudentLbl: UILabel!
    // Stats Cards (Hidden)
    @IBOutlet weak var averageScoreValueLabel: UILabel!
    @IBOutlet weak var averageScorePercentageLabel: UILabel!

    @IBOutlet weak var bestExamValueLabel: UILabel!
    @IBOutlet weak var bestExamPercentageLabel: UILabel!
    @IBOutlet weak var lowestExamValueLabel: UILabel!
    @IBOutlet weak var lowestExamPercentageLabel: UILabel!
    @IBOutlet weak var examsTakenValueLabel: UILabel!
    @IBOutlet weak var subjectsValueLabel: UILabel!
    
    // Custom Charts (Visible)
    @IBOutlet weak var barChartView: BarChartViews!
    @IBOutlet weak var barChartViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var barLegendStack: UIStackView!
    @IBOutlet weak var lineChartView: LineChartViews!
    
    // Dynamic Stack Views (Hidden)
    @IBOutlet weak var breakdownTableStackView: UIStackView!
    @IBOutlet weak var breakdownTableWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var subjectProgressStackView: UIStackView!
    
    // MARK: - Injected Properties
    var student: StudentDetails?
    var loginType: Int?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var childDetails = UserDefaultFileManager.get_child_Details()
    var selectedExamIds: [String] = [] // lowercased list of selected exam IDs e.g. ["midtermtest", "final", "testing"]
//    var student: StudentDetails?
    var SetId = ""
    // MARK: - Properties
    private var performance: StudentAnalysisData?
    var classAndSectionText: String = ""
    private var lineChartViewWidthConstraint: NSLayoutConstraint!
       private var lineScrollView: UIScrollView!
    var age = 20
    override func viewDidLoad() {
        super.viewDidLoad()
        studentInfoView.isHidden = loginType == 2 ? true : false
//        topBackBtnName.setTitle(MenuStringFile.selectedMenuName, for: .normal)
        setupLineChartScroll()
        setupBarTapCallback()
        getAnaylisExam(setId: SetId)
      
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
   
    private func setupLineChartScroll() {
        guard let cardLineChart = lineChartView.superview else { return }
        
        // Remove lineChartView from its current constraints
        lineChartView.removeFromSuperview()
        
        // Create Scroll View
        lineScrollView = UIScrollView()
        lineScrollView.translatesAutoresizingMaskIntoConstraints = false
        lineScrollView.showsHorizontalScrollIndicator = false
        lineScrollView.showsVerticalScrollIndicator = false
        
        cardLineChart.addSubview(lineScrollView)
        
        // Bind scroll view to cardLineChart layout margins exactly where lineChartView was
        NSLayoutConstraint.activate([
            lineScrollView.topAnchor.constraint(equalTo: cardLineChart.topAnchor, constant: 62),
            lineScrollView.leadingAnchor.constraint(equalTo: cardLineChart.leadingAnchor, constant: 12),
            lineScrollView.trailingAnchor.constraint(equalTo: cardLineChart.trailingAnchor, constant: -12),
            lineScrollView.bottomAnchor.constraint(equalTo: cardLineChart.bottomAnchor, constant: -18),
            lineScrollView.heightAnchor.constraint(equalToConstant: 240)
        ])
        
        // Add lineChartView inside scroll view
        lineScrollView.addSubview(lineChartView)
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.contentMode = .redraw
        
        lineChartViewWidthConstraint = lineChartView.widthAnchor.constraint(equalToConstant: 319)
        
        NSLayoutConstraint.activate([
            lineChartView.topAnchor.constraint(equalTo: lineScrollView.topAnchor),
            lineChartView.bottomAnchor.constraint(equalTo: lineScrollView.bottomAnchor),
            lineChartView.leadingAnchor.constraint(equalTo: lineScrollView.leadingAnchor),
            lineChartView.trailingAnchor.constraint(equalTo: lineScrollView.trailingAnchor),
            lineChartView.heightAnchor.constraint(equalTo: lineScrollView.heightAnchor),
            lineChartViewWidthConstraint
        ])
    }
    
   

    private func setupBarTapCallback() {
        barChartView.onBarTap = { [weak self] subjectName, examName, mark in
            self?.showExamDetailsAlert(subjectName: subjectName, examName: examName, mark: mark)
        }
    }
    
    private func showExamDetailsAlert(subjectName: String, examName: String, mark: AnalysisSubjectMark) {
        let subject = subjectName.replacingOccurrences(of: "_", with: " ")
        let obtained = mark.obtainedMark.isEmpty ? "N/A" : mark.obtainedMark
        let maxMark = mark.maxMark.isEmpty ? "N/A" : mark.maxMark
        let attendance = mark.attendance.isEmpty ? "P" : mark.attendance
        let remarks = mark.remarks.isEmpty ? "None" : mark.remarks
        let date = mark.examDate.isEmpty ? "N/A" : mark.examDate
        let session = mark.session.isEmpty ? "N/A" : mark.session
        
        let message = """
        • Subject: \(subject)
        • Exam: \(examName)
        • Marks: \(obtained) / \(maxMark)
        • Status: \(attendance == "AB" ? "Absent (AB)" : "Present (P)")
        • Exam Date: \(date) (\(session))
        • Remarks: \(remarks)
        """
        
        let alert = UIAlertController(
            title: "Exam Details",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    func getAnaylisExam(setId : String){
        
        APIService.shared.makeApi(url: ServiceUrl.exam_api_exam_test_student_analysis, parameters: ["student_id" : loginType == 2 ? "" : student?.id ?? "" ,"analysis_set_id" :  setId ], type: ApitTypeSringFile.GET, token: loginType == 2 ? childDetails?.access_token ?? "" : staffDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (result: Result<AnalysisResponse , Error>) in
            
            DispatchQueue.main.sync { [weak self] in
                
                guard let self = self else {return}
                
                switch result {
                case .success(let success):
                    if success.status{
                        
                        summaryUiUpdate(success : success)
                        performance =  success.data.first
                        bindUI()
                        ExamNoRecord(isShow: false)
    
                    }else{
                        noRecordLbl.text = success.message
                        ExamNoRecord(isShow: true)
                    }
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                    noRecordLbl.text = failure.localizedDescription
                    ExamNoRecord(isShow: true)
                }
            }
            
        }
    }
    
    
    private func ExamNoRecord(isShow:Bool){
        
        noRecordStackView.isHidden = !isShow
        subjectBreakDownView.isHidden = isShow
        if loginType == 2 {
            studentInfoView.isHidden = true
        }else{
            studentInfoView.isHidden = isShow
        }
            
       
        preformView.isHidden = isShow
        summaryStackView.isHidden = isShow
        
    }
    func summaryUiUpdate(success: AnalysisResponse) {

        guard let summary  = success.data.first?.summary else { return }
        examsTakenValueLabel.text = summary.examsAnalysed
        averageScorePercentageLabel.text = summary.averagePercentage
        averageScoreValueLabel.text = summary.averageTotal
        bestExamValueLabel.text = summary.bestExam.total
        bestExamPercentageLabel.text = summary.bestExam.percentage  + " " + "(\(summary.bestExam.label))"
        lowestExamValueLabel.text = summary.worstExam.total
        lowestExamPercentageLabel.text = summary.worstExam.percentage + " " + "(\(summary.worstExam.label))"

        guard let student = student else { return }

        StudentLbl.text = student.name

        let rollText = (student.roll_no?.isEmpty ?? true) ? "--" : student.roll_no!
        rollNumberLbl.text = "Roll No: \(rollText)"
        admissinNumberLbl.text = "Admin No: \(student.admission_no ?? "--")"
        standardSecLbl.text = classAndSectionText
        selectedStudentInitialsLabel.text = getInitials(from: student.name ?? "")
        selectedStudentAvatarView.backgroundColor = getAvatarColor(from: student.name ?? "")
    }
    
    // MARK: - Helper Formatting
    private func getInitials(from name: String) -> String {
        let components = name.components(separatedBy: " ")
        if components.count > 1, let first = components.first?.first, let last = components.last?.first {
            return "\(first)\(last)".uppercased()
        } else if let first = name.first {
            if name.count > 1 {
                let secondIndex = name.index(name.startIndex, offsetBy: 1)
                return "\(first)\(name[secondIndex])".uppercased()
            }
            return "\(first)".uppercased()
        }
        return "ST"
    }
    
    private func getAvatarColor(from name: String) -> UIColor {
        let colors: [UIColor] = [
            UIColor(red: 0.62, green: 0.38, blue: 0.93, alpha: 1.0), // AV purple
            UIColor(red: 0.0, green: 0.69, blue: 0.81, alpha: 1.0),
            UIColor(red: 0.0, green: 0.74, blue: 0.83, alpha: 1.0),
            UIColor(red: 0.18, green: 0.49, blue: 0.96, alpha: 1.0)
        ]
        let hash = abs(name.hashValue)
        return colors[hash % colors.count]
    }
    
    private func bindUI() {
        guard let perf = performance else { return }
        
        selectedStudentAvatarView.layer.cornerRadius = 20
        selectedStudentAvatarView.clipsToBounds = true
        
        changeButton.layer.cornerRadius = 15
        changeButton.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.96, alpha: 1.0)
        changeButton.setTitleColor(UIColor(red: 0.35, green: 0.45, blue: 0.56, alpha: 1.0), for: .normal)
      
        // Build dynamic color map for the exams
        var colorMap: [String: UIColor] = [:]
        let colorPalette: [UIColor] = [
            UIColor(red: 29/255, green: 112/255, blue: 243/255, alpha: 1.0),   // Blue
            UIColor(red: 247/255, green: 158/255, blue: 27/255, alpha: 1.0),   // Orange
            UIColor(red: 18/255, green: 183/255, blue: 106/255, alpha: 1.0),   // Green
            UIColor(red: 240/255, green: 68/255, blue: 56/255, alpha: 1.0),    // Red
            UIColor(red: 158/255, green: 105/255, blue: 235/255, alpha: 1.0),  // Purple
            UIColor(red: 0/255, green: 188/255, blue: 212/255, alpha: 1.0),    // Cyan
            UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1.0),    // Pink
            UIColor(red: 139/255, green: 195/255, blue: 74/255, alpha: 1.0),   // Light Green
            UIColor(red: 255/255, green: 152/255, blue: 0/255, alpha: 1.0),    // Amber
            UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),   // Deep Purple

            UIColor(red: 3/255, green: 169/255, blue: 244/255, alpha: 1.0),    // Light Blue
            UIColor(red: 255/255, green: 87/255, blue: 34/255, alpha: 1.0),    // Deep Orange
            UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0),    // Green
            UIColor(red: 121/255, green: 85/255, blue: 72/255, alpha: 1.0),    // Brown
            UIColor(red: 96/255, green: 125/255, blue: 139/255, alpha: 1.0),   // Blue Grey
            UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0),    // Yellow
            UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 1.0),    // Indigo
            UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1.0),    // Teal
            UIColor(red: 205/255, green: 220/255, blue: 57/255, alpha: 1.0),   // Lime
            UIColor(red: 255/255, green: 111/255, blue: 97/255, alpha: 1.0),   // Coral

            UIColor(red: 103/255, green: 58/255, blue: 183/255, alpha: 1.0),   // Violet
            UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),   // Emerald
            UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0),   // Sky Blue
            UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1.0),   // Carrot
            UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),    // Alizarin
            UIColor(red: 155/255, green: 89/255, blue: 182/255, alpha: 1.0),   // Amethyst
            UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 1.0),   // Turquoise
            UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0),   // Sunflower
            UIColor(red: 127/255, green: 140/255, blue: 141/255, alpha: 1.0),  // Grey
            UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)      // Navy
        ]
        for (index, examName) in perf.examSeries.enumerated() {
            colorMap[examName.lowercased()] = colorPalette[index % colorPalette.count]
        }
        
        // 3. Bind Scrollable Bar Chart
        let subjectCount = perf.subjects.count
        let activeExamsCount = perf.trend.count
        let groupWidth = CGFloat(activeExamsCount) * 12.0 + 35.0
        let paddingLeftRight: CGFloat = 40.0
        let totalChartWidth = max(319.0, CGFloat(subjectCount) * groupWidth + paddingLeftRight)
        
        barChartViewWidthConstraint.constant = totalChartWidth
        barChartView.configure(with: perf.subjects, selectedExamIds: selectedExamIds, examColorMap: colorMap)
        
        // 4. Build Dynamic Bar Chart Legend
        buildChartLegend(activeExams: perf.trend, performance: perf, colorMap: colorMap)
        

        
        // 5. Bind Scrollable Line Chart Trend
        let targetSegmentWidth: CGFloat = 110.0
        let linePaddingLeftRight: CGFloat = 35.0 + 20.0
        let totalLineWidth = max(319.0, CGFloat(max(1, activeExamsCount - 1)) * targetSegmentWidth + linePaddingLeftRight)
        
        lineChartViewWidthConstraint.constant = totalLineWidth
        lineScrollView.layoutIfNeeded()
        
        // Map trend points (using percentage score as the vertical point value)
        let lineTrendData =  perf.trend.map { (label: $0.examName, total: CGFloat(Double($0.percentage) ?? 0.0)) }
        lineChartView.configure(with: lineTrendData)
    }
    
    private func buildChartLegend(activeExams: [AnalysisTrendPoint], performance: StudentAnalysisData, colorMap: [String: UIColor]) {

        barLegendStack.arrangedSubviews.forEach {
            barLegendStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        // Parent stack is HORIZONTAL
        barLegendStack.axis = .horizontal
        barLegendStack.spacing = 20
        barLegendStack.distribution = .fillEqually
        barLegendStack.alignment = .fill
        
        // Two VERTICAL columns inside the horizontal parent stack
        let column1 = UIStackView()
        column1.axis = .vertical
        column1.spacing = 8
        column1.alignment = .leading
        column1.distribution = .fill
        
        let column2 = UIStackView()
        column2.axis = .vertical
        column2.spacing = 8
        column2.alignment = .leading
        column2.distribution = .fill
        
        barLegendStack.addArrangedSubview(column1)
        barLegendStack.addArrangedSubview(column2)

        let defaultBarColor = UIColor(red: 0.11, green: 0.44, blue: 0.95, alpha: 1.0)

        for (index, exam) in activeExams.enumerated() {
            var color = colorMap[exam.examName.lowercased()] ?? defaultBarColor

            if let matchedMark = performance.subjects
                .flatMap({ $0.marks })
                .first(where: {
                    $0.examName.lowercased().replacingOccurrences(of: " ", with: "") ==
                    exam.examName.lowercased().replacingOccurrences(of: " ", with: "")
                }),
               let colorHex = matchedMark.colorCode {
                color = UIColor(hexString: colorHex) ?? color
            }

            // Legend Item
            let itemStack = UIStackView()
            itemStack.axis = .horizontal
            itemStack.spacing = 8
            itemStack.alignment = .center

            let square = UIView()
            square.backgroundColor = color
            square.translatesAutoresizingMaskIntoConstraints = false
            square.widthAnchor.constraint(equalToConstant: 10).isActive = true
            square.heightAnchor.constraint(equalToConstant: 10).isActive = true
            square.layer.cornerRadius = 2

            let label = UILabel()
            label.text = exam.examName
            label.font = .systemFont(ofSize: 11, weight: .bold)
            label.textColor = color // Set label text color to match the exam color!
            label.numberOfLines = 1

            itemStack.addArrangedSubview(square)
            itemStack.addArrangedSubview(label)

            // Alternate items into the two vertical columns
            if index % 2 == 0 {
                column1.addArrangedSubview(itemStack)
            } else {
                column2.addArrangedSubview(itemStack)
            }
        }
    }
    // MARK: - Actions
    @IBAction func didTapClose(_ sender: UIButton) {
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}


