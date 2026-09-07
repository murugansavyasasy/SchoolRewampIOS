//
//  ReciverAttendanceReportVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 19/12/24.
//

enum AttendanceImage {
    case system(String)
    case asset(String)
}

import UIKit
import DGCharts

class ReciverAttendanceReportVC: UIViewController {
    
    @IBOutlet weak var noResordStack: UIStackView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var Topview: UIView!
    @IBOutlet weak var WeeklyView: UIView!
    @IBOutlet weak var percentagesBaseView: UIView!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var DayAndMonthLbl: UILabel!
    @IBOutlet weak var WeekStatusDefBtn: UIButton!
    @IBOutlet weak var AttendencePercentage: PieChartView!
    @IBOutlet weak var OngoingDaysView: PieChartView!
    @IBOutlet weak var LeaveTakenview: PieChartView!
    @IBOutlet weak var Stackview: UIStackView!
    @IBOutlet weak var MenusView: UIView!
    @IBOutlet weak var MenusStack: UIStackView!
    @IBOutlet weak var AskLeaveView: UIView!
    @IBOutlet weak var LeaveHistoryView: UIView!
    @IBOutlet weak var AttendanceReportView: UIView!
    @IBOutlet weak var HolidaysView: UIView!
    @IBOutlet weak var AttendanceDefLbl: UILabel!
    @IBOutlet weak var LeaveTakenDefLbl: UILabel!
    @IBOutlet weak var OngoingdaysDefLbl: UILabel!
    @IBOutlet weak var askLeavesDefLbl: UILabel!
    @IBOutlet weak var requestHistoryDefLbl: UILabel!
    @IBOutlet weak var attendanceReportDefLbl: UILabel!
    @IBOutlet weak var holidaysDefLbl: UILabel!
    @IBOutlet weak var MenuTitleLbl: UILabel!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var noStatsLbl: UILabel!
    
    
    var childDetails = UserDefaultFileManager.get_child_Details()
    var attendanceReportData : [StudentAttendance]?
    var studentStats: [StudentStatistics]?
    var pushNotiMsg_id : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = childDetails?.name ?? ""
        let standard = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        studentNameLbl.configureAsBackTitle(firstLine: name, secondLine: standard)
        MenuTitleLbl.text = MenuStringFile.selectedMenuName
        MenuTitleLbl.setFont(style: .header, size: FontSize.HeaderSize)
        Topview.layer.cornerRadius = 25
        Topview.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        StyleAndTranslate()
        get_student_stats()
        if pushNotiMsg_id != ""{
            LeaveHistoryAct()
        }
    }
    
    
    //MARK: UI Changes
    func StyleAndTranslate(){
        WeeklyView.layer.cornerRadius = 10
        WeeklyView.layer.borderWidth = 0.5
        WeeklyView.layer.borderColor = UIColor.systemGray4.cgColor
        WeeklyView.layer.shadowColor = UIColor.black.cgColor
        WeeklyView.layer.shadowOpacity = 0.2
        WeeklyView.layer.shadowOffset = CGSize(width: 0, height: 2)
        WeeklyView.layer.shadowRadius = 4
        WeeklyView.layer.masksToBounds = false
        noStatsLbl.isHidden = true
        noStatsLbl.setFont(style: .body, size: 10)
        noStatsLbl.textColor = .systemRed
        percentagesBaseView.layer.cornerRadius = 10
        percentagesBaseView.layer.borderWidth = 0.2
        percentagesBaseView.layer.borderColor = UIColor.systemGray4.cgColor
        percentagesBaseView.layer.shadowColor = UIColor.black.cgColor
        percentagesBaseView.layer.shadowOpacity = 0.2
        percentagesBaseView.layer.shadowOffset = CGSize(width: 0, height: 2)
        percentagesBaseView.layer.shadowRadius = 4
        percentagesBaseView.layer.masksToBounds = false
        WeekStatusDefBtn.setTitle(AttendanceString.thisWeekStatus.translated(), for: .normal)
        AttendanceDefLbl.text = AttendanceString.attendance.translated()
        LeaveTakenDefLbl.text = AttendanceString.leaveTaken.translated()
        OngoingdaysDefLbl.text = AttendanceString.ongoingDays.translated()
        askLeavesDefLbl.text = AttendanceString.askLeave.translated()
        requestHistoryDefLbl.text = AttendanceString.leaveRequests.translated()
        attendanceReportDefLbl.text = AttendanceString.LeaveHistory.translated()
        holidaysDefLbl.text = AttendanceString.holidays.translated()
        
        AttendanceDefLbl.setFont(style: .body, size: 10)
        LeaveTakenDefLbl.setFont(style: .body, size: 10)
        OngoingdaysDefLbl.setFont(style: .body, size: 10)
        askLeavesDefLbl.setFont(style: .body, size: 10)
        requestHistoryDefLbl.setFont(style: .body, size: 10)
        attendanceReportDefLbl.setFont(style: .body, size: 10)
        holidaysDefLbl.setFont(style: .body, size: 10)
        MenusView.layer.cornerRadius = 10
        MenusView.layer.borderWidth = 0.2
        MenusView.layer.borderColor = UIColor.systemGray4.cgColor
        MenusView.layer.shadowColor = UIColor.black.cgColor
        MenusView.layer.shadowOpacity = 0.2
        MenusView.layer.shadowOffset = CGSize(width: 0, height: 2)
        MenusView.layer.shadowRadius = 4
        MenusView.layer.masksToBounds = false
        
        DateLbl.setFont(style: .header, size: 40)
        WeekStatusDefBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        WeekStatusDefBtn.setTitleColor(.black.withAlphaComponent(0.7), for: .normal)
        WeekStatusDefBtn.semanticContentAttribute = .forceRightToLeft
        let spacing: CGFloat = 2
        var config = UIButton.Configuration.plain()
           config.imagePadding = spacing
           WeekStatusDefBtn.configuration = config
        
        let today = Date()
        
        DateLbl.attributedText = getDayWithSuffix(from: today)
        
        let dayFormatter = DateFormatter()
        dayFormatter.locale = LocaleManager.shared.displayLocale
        dayFormatter.dateFormat = "EEEE"
        let dayName = dayFormatter.string(from: today)
        let monthFormatter = DateFormatter()
        monthFormatter.locale = LocaleManager.shared.displayLocale
        monthFormatter.dateFormat = "LLLL yyyy"
        let monthYear = monthFormatter.string(from: today)
        let fullText = "\(dayName)\n\(monthYear)"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttributes([
            .font: UIFont(name: "Poppins-Medium", size: 15)!
        ], range: (fullText as NSString).range(of: dayName))
        
        attributedString.addAttributes([
            .font: UIFont(name: "Poppins-Medium", size: 10)!
        ], range: (fullText as NSString).range(of: monthYear))
        DayAndMonthLbl.numberOfLines = 0
        DayAndMonthLbl.attributedText = attributedString
        
        setupPieChart(AttendencePercentage)
        setupPieChart(LeaveTakenview)
        setupPieChart(OngoingDaysView)
        AskLeaveView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AskLeaveAct)))
        LeaveHistoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LeaveHistoryAct)))
        AttendanceReportView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AttendanceReportAct)))
        HolidaysView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HolidaysAct)))
    }
    
    //MARK: Api call
    func get_student_stats() {
        
        showActivityLoader()
        
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_api_attendance_student_stats, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "", isBaseUrl: false) {[weak self] (result: Result<StudentStatisticsResponse,Error>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                switch result{
                case .success(let success):
                    
                    if success.status == true {
                        self.studentStats = success.data
                        setupDayButtons()
                        Set_Piechart_data()
                        noStatsLbl.isHidden = true
                        Stackview.isHidden = false
                        WeekStatusDefBtn.isHidden = false
                    }else{
                        noStatsLbl.isHidden = false
                        noStatsLbl.text = success.message
                        Set_Piechart_data()
                        Stackview.isHidden = true
                        WeekStatusDefBtn.isHidden = true
                    }
                    
                case .failure(let error):
                    noStatsLbl.isHidden = false
                    noStatsLbl.text = error.localizedDescription
                    Stackview.isHidden = true
                    WeekStatusDefBtn.isHidden = true
                }
                
                hideActivityLoader()
            }
        }
    }
    
    func getDayWithSuffix(from date: Date) -> NSAttributedString {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let suffix: String
        switch day {
        case 11, 12, 13:
            suffix = "th"
        default:
            switch day % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        let dayString = String(format: "%02d", day)
        let fullString = "\(dayString)\(suffix)"
        let attributed = NSMutableAttributedString(string: fullString)
        let suffixFont = UIFont(name: "Poppins-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
        attributed.setAttributes([
            .font: suffixFont,
            .baselineOffset: 20
        ], range: NSRange(location: dayString.count, length: suffix.count))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 30
        attributed.addAttributes([
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: fullString.count))
        
        return attributed
    }
    
    func setupDayButtons() {
        Stackview.arrangedSubviews.forEach {
            Stackview.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let dayInitials = ["M", "T", "W", "T", "F", "S", "S"]
        let attList = studentStats?.first?.weekly_status?.att_list ?? []

        for (index, initial) in dayInitials.enumerated() {

            let verticalStack = UIStackView()
            verticalStack.axis = .vertical
            verticalStack.alignment = .center
            verticalStack.spacing = 4

            let label = UILabel()
            label.text = initial
            label.font = UIFont.systemFont(ofSize: 13)
            label.textAlignment = .center
            label.textColor = .black.withAlphaComponent(0.8)

            let imageView = UIImageView()
            let status = attList.indices.contains(index) ? attList[index] : nil

            let appearance = attendanceAppearance(for: status)

            switch appearance.image {
            case .system(let name):
                imageView.image = UIImage(systemName: name)

            case .asset(let name):
                imageView.image = UIImage(named: name)
            }

            imageView.tintColor = appearance.color

            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 20),
                imageView.heightAnchor.constraint(equalToConstant: 20)
            ])

            verticalStack.addArrangedSubview(label)
            verticalStack.addArrangedSubview(imageView)
            Stackview.addArrangedSubview(verticalStack)
        }
    }
    
    
    private func attendanceAppearance(
        for status: String?
    ) -> (image: AttendanceImage, color: UIColor) {

        guard let status = status else {
            return (.system("minus.circle.fill"), .systemRed)
        }

        switch status {

        // MARK: - Single / Base statuses (WITH COLORS)

        case "-/-", "-":
            return (.system("minus.circle.fill"), .systemRed)

        case "P", "P/P":
            return (.system("checkmark.circle.fill"), .systemBlue)

        case "A", "A/A":
            return (.system("a.circle.fill"), .systemRed)

        case "P~", "P~/P~":
            return (.asset("Late"), .systemBlue)

        case "OD", "OD/OD":
            return (.asset("Od"), .systemOrange)

        case "H", "H/H":
            return (.system("h.circle.fill"), .systemPink)

        // MARK: - FN / AN combinations

        case "P/A":
            return (.asset("present_absent"), .systemBlue)
        case "P/P~":
            return (.asset("present_late"), .systemBlue)
        case "P/OD":
            return (.asset("present_OD"), .systemBlue)
        case "P/-":
            return (.asset("presnt_notTaken"), .systemBlue)

        case "A/P":
            return (.asset("absent_present"), .systemBlue)
        case "A/P~":
            return (.asset("absent_Late"), .systemBlue)
        case "A/OD":
            return (.asset("absent_Od"), .systemBlue)
        case "A/-":
            return (.asset("absent_notTaken"), .systemBlue)

        case "P~/P":
            return (.asset("Late_Present"), .systemBlue)
        case "P~/A":
            return (.asset("Late_Absent"), .systemBlue)
        case "P~/OD":
            return (.asset("Late_Od"), .systemBlue)
        case "P~/-":
            return (.asset("Late_notTaken"), .systemBlue)

        case "OD/P":
            return (.asset("Od_Present"), .systemBlue)
        case "OD/A":
            return (.asset("Od_Absent"), .systemBlue)
        case "OD/P~":
            return (.asset("Od_Late"), .systemBlue)
        case "OD/-":
            return (.asset("Od_notTaken"), .systemBlue)

        default:
            return (.system("minus.circle.fill"), .systemRed)
        }
    }
    
    func Set_Piechart_data(){
        let stats = studentStats?.first
        let attendancePercent = Double(stats?.attendance_percentage?.replacingOccurrences(of: "%", with: "") ?? "0") ?? 0
        let absentDays = Double(stats?.absent_days ?? 0)
        let completedDays = Double(stats?.completed_working_days ?? 0)
        let totalDays = Double(stats?.total_working_days ?? 0)
        let onGoingPercentage: Int
        if totalDays > 0 {
            onGoingPercentage = Int((completedDays / totalDays) * 100)
        } else {
            onGoingPercentage = 0
        }

        setProgress(
            on: AttendencePercentage,
            value: attendancePercent,
            total: 100,
            unit: "%",
            fillColor: .backGroundClr,
            labelColor: .backGroundClr
        )
        
        setProgress(
            on: LeaveTakenview,
            value: absentDays,
            total: totalDays,
            unit: "",
            fillColor: .backGroundClr,
            labelColor: .backGroundClr
        )
        
        setProgress(
            on: OngoingDaysView,
            value: Double(onGoingPercentage),
            total: 100,
            unit: "%",
            fillColor: .backGroundClr,
            labelColor: .backGroundClr
        )
    }
    
    private func setupPieChart(_ pieChart: PieChartView) {
        pieChart.holeRadiusPercent = 0.8
        pieChart.transparentCircleRadiusPercent = 0.2
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.enabled = false
        pieChart.chartDescription.enabled = false
        pieChart.holeColor = .white
    }
    
    func setProgress(
        on pieChart: PieChartView,
        value: Double,
        total: Double,
        unit: String,
        fillColor: UIColor,
        labelColor: UIColor
    ) {
        let filledEntry = PieChartDataEntry(value: value)
        let emptyEntry = PieChartDataEntry(value: max(0, total - value))
        
        let dataSet = PieChartDataSet(entries: [filledEntry, emptyEntry], label: "")
        dataSet.colors = [fillColor, .systemGray6]
        dataSet.drawValuesEnabled = false
        
        let pieData = PieChartData(dataSet: dataSet)
        pieChart.data = pieData
        pieChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInExpo)
        let valueText = "\(Int(value))"
        let unitText = unit
        let fullText = valueText + unitText
        let attributedText = NSMutableAttributedString(string: fullText)
        
        attributedText.addAttributes([
            .font: UIFont(name: "Poppins-Medium", size: 17) ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: labelColor
        ], range: NSRange(location: 0, length: valueText.count))
        
        attributedText.addAttributes([
            .font: UIFont(name: "Poppins-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12),
            .foregroundColor: labelColor
        ], range: NSRange(location: valueText.count, length: unitText.count))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: fullText.count))
        
        pieChart.centerAttributedText = attributedText
        pieChart.centerTextRadiusPercent = 0.9
    }
    
    func colorForPercentage(_ percentage: Double) -> UIColor {
        switch percentage {
        case 1...99:
            return UIColor.systemIndigo.withAlphaComponent(0.8)
        case 100:
            return UIColor.systemGreen.withAlphaComponent(0.8)
        default:
            return UIColor.lightGray
        }
    }
    
    @IBAction func InfoBtnAct(_ sender: UIButton) {
        let popoverVC = PopoverViewVC(nibName: nil, bundle: nil)
        
        popoverVC.configureButtons(with: [
            ("minus.circle.fill", "Not Taken", .systemRed),
            ("checkmark.circle.fill", "Present", .systemBlue),
            ("a.circle.fill", "Absent", .systemRed),
            ("Late", "Late Comer", .systemPink),
            ("Od", "OD", .systemOrange),
            ("h.circle.fill", "Holiday", .systemPink),
            ("present_absent", "FN Present - AN Absent", .systemBlue),
            ("present_late", "FN Present - AN Late comer", .systemBlue),
            ("present_OD", "FN Present - AN OD", .systemBlue),
            ("presnt_notTaken", "FN Present - AN Not Taken", .systemBlue),
            ("absent_present", "FN Absent - AN Present", .systemBlue),
            ("absent_Late", "FN Absent - AN Late comer", .systemBlue),
            ("absent_Od", "FN Absent - AN OD", .systemBlue),
            ("absent_notTaken", "FN Absent - AN Not Taken", .systemBlue),
            ("Late_Present", "FN Late comer - AN Present", .systemBlue),
            ("Late_Absent", "FN Late comer - AN Absent", .systemBlue),
            ("Late_Od", "FN Late comer - AN OD", .systemBlue),
            ("Late_notTaken", "FN Late comer - AN Not Taken", .systemBlue),
            ("Od_Present", "FN OD - AN Present", .systemBlue),
            ("Od_Absent", "FN OD - AN Absent", .systemBlue),
            ("Od_Late", "FN OD - AN Late comer", .systemBlue),
            ("Od_notTaken", "FN OD - AN Not Taken", .systemBlue),
            
        ], type: .symbol)
        
        showPopover(from: sender, contentVC: popoverVC)
    }
    
    
    
    @IBAction func AskLeaveAct(){
        if #available(iOS 14.0, *) {
            let vc = LeveCreateVC(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    @IBAction func LeaveHistoryAct(){
        if #available(iOS 14.0, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let vc = LeveHistoryVC(nibName: nil, bundle: nil)
                vc.PushnotiMsg_id = self.pushNotiMsg_id
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
    
    @IBAction func AttendanceReportAct(){
        let vc = NewAttendanceReportVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func HolidaysAct(){
        if #available(iOS 13.4, *) {
            let vc = HolidayVC(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        dismiss(animated: true)
    }
}
extension ReciverAttendanceReportVC: UIPopoverPresentationControllerDelegate {
    func showPopover(from sender: UIView, contentVC: PopoverViewVC) {
        contentVC.modalPresentationStyle = .popover
        if let popover = contentVC.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            popover.delegate = self
            popover.backgroundColor = .white
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            contentVC.modalPresentationStyle = .overFullScreen
            contentVC.view.backgroundColor = .white
        }
        present(contentVC, animated: true)
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
