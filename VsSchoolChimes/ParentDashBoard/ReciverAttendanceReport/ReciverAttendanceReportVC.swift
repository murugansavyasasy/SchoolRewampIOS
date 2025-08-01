//
//  ReciverAttendanceReportVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 19/12/24.
//

import UIKit
import Charts

class ReciverAttendanceReportVC: UIViewController {
    
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var noResordStack: UIStackView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var TV: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var Topview: UIView!
    
    
    @IBOutlet weak var WeeklyView: UIView!
    
    @IBOutlet weak var percentagesBaseView: UIView!
    
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var DayAndMonthLbl: UILabel!
    @IBOutlet weak var WeekStatusDefLbl: UILabel!
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
    
    
    var childDetails = UserDefaultFileManager.get_child_Details()
    var attendanceReportData : [StudentAttendance]?
    let dateFormatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        
        searchBar.applyRightTxt()
        let name = childDetails?.name ?? ""
        let standard = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        BackBtn.configureAsBackButton(firstLine: name, secondLine: standard, colour: .white)
        searchBar.placeholder = CommonStringFile.Search.translated()
        Topview.layer.cornerRadius = 25
        Topview.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        StyleAndTranslate()
        CellRigister()
        TV.delegate = self
        TV.dataSource = self
       
        Get_attendaceReport()
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientgreen,Colornames.gradientBlue], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
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
        
        percentagesBaseView.layer.cornerRadius = 10
        percentagesBaseView.layer.borderWidth = 0.2
        percentagesBaseView.layer.borderColor = UIColor.systemGray4.cgColor
        percentagesBaseView.layer.shadowColor = UIColor.black.cgColor
        percentagesBaseView.layer.shadowOpacity = 0.2
        percentagesBaseView.layer.shadowOffset = CGSize(width: 0, height: 2)
        percentagesBaseView.layer.shadowRadius = 4
        percentagesBaseView.layer.masksToBounds = false

//        MenusStack.layer.cornerRadius = 10
//        MenusStack.layer.borderWidth = 0.2
//        MenusStack.layer.borderColor = UIColor.systemGray4.cgColor
//        MenusStack.layer.shadowColor = UIColor.black.cgColor
//        MenusStack.layer.shadowOpacity = 0.2
//        MenusStack.layer.shadowOffset = CGSize(width: 0, height: 2)
//        MenusStack.layer.shadowRadius = 4
//        MenusStack.layer.masksToBounds = false
        
        MenusView.layer.cornerRadius = 10
        MenusView.layer.borderWidth = 0.2
        MenusView.layer.borderColor = UIColor.systemGray4.cgColor
        MenusView.layer.shadowColor = UIColor.black.cgColor
        MenusView.layer.shadowOpacity = 0.2
        MenusView.layer.shadowOffset = CGSize(width: 0, height: 2)
        MenusView.layer.shadowRadius = 4
        MenusView.layer.masksToBounds = false
        
        DateLbl.setFont(style: .header, size: 28)
        WeekStatusDefLbl.setFont(style: .body, size: FontSize.BodySize)
        
        let today = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let date = dateFormatter.string(from: today)
        
        DateLbl.text = date

        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE" // Full day name, e.g. "Wednesday"
        let dayName = dayFormatter.string(from: today)

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL yyyy" // Full month + year, e.g. "July 2025"
        let monthYear = monthFormatter.string(from: today)

        let fullText = "\(dayName)\n\(monthYear)"
        let attributedString = NSMutableAttributedString(string: fullText)

        // Apply bold font to day name
        attributedString.addAttributes([
            .font: UIFont(name: "Poppins-Medium", size: 15)!
        ], range: (fullText as NSString).range(of: dayName))

        // Apply medium font to month + year
        attributedString.addAttributes([
            .font: UIFont(name: "Poppins-Medium", size: 10)!
        ], range: (fullText as NSString).range(of: monthYear))

        DayAndMonthLbl.numberOfLines = 0 // Allow line break
        DayAndMonthLbl.attributedText = attributedString
        
        setupDayButtons()
        
        setupPieChart(AttendencePercentage)
        setProgress(on: AttendencePercentage, to: 75)
        
        setupPieChart(LeaveTakenview)
        setProgress(on: LeaveTakenview, to: 50)
        
        setupPieChart(OngoingDaysView)
        setProgress(on: OngoingDaysView, to: 90)
        
        
        AskLeaveView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AskLeaveAct)))
        LeaveHistoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LeaveHistoryAct)))
        AttendanceReportView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AttendanceReportAct)))
        HolidaysView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(HolidaysAct)))
    }
    
    func setupDayButtons() {
        
        Stackview.arrangedSubviews.forEach { view in
            Stackview.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        let dayInitials = ["M", "T", "W", "T", "F", "S"] // Add "S" for Sunday if needed
        
        for initial in dayInitials {
            // Create a vertical stack: [Label, ImageView]
            let verticalStack = UIStackView()
            verticalStack.axis = .vertical
            verticalStack.alignment = .center
            verticalStack.spacing = 4

            // Create the day label
            let label = UILabel()
            label.text = initial
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 13)

            // Create the image view
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "checkmark.circle.fill")
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemIndigo
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 20),
                imageView.heightAnchor.constraint(equalToConstant: 20)
            ])

            // Add label and imageView to the vertical stack
            verticalStack.addArrangedSubview(label)
            verticalStack.addArrangedSubview(imageView)

            // Add vertical stack to the horizontal stack
            Stackview.addArrangedSubview(verticalStack)
        }
    }
    
    private func setupPieChart(_ pieChart: PieChartView) {
        pieChart.holeRadiusPercent = 0.8
        pieChart.transparentCircleRadiusPercent = 0.2
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.enabled = false
        pieChart.chartDescription.enabled = false
        pieChart.holeColor = .white
    }

    func setProgress(on pieChart: PieChartView, to percentage: Double) {
        let progressEntry = PieChartDataEntry(value: percentage)
        let emptyEntry = PieChartDataEntry(value: 100 - percentage)

        let progressColor = colorForPercentage(percentage)

        let progressDataSet = PieChartDataSet(entries: [progressEntry, emptyEntry], label: "")
        progressDataSet.colors = [progressColor, .lightGray]
        progressDataSet.drawValuesEnabled = false

        let pieData = PieChartData(dataSet: progressDataSet)
        pieChart.data = pieData

        // Center label
        let percentageText = "\(Int(percentage))%"
        let attributedString = NSAttributedString(
            string: percentageText,
            attributes: [
                .font: UIFont(name: "Poppins-Bold", size: 11)!,
                .foregroundColor: UIColor.homeWorkClr
            ]
        )
        pieChart.centerAttributedText = attributedString
        pieChart.centerTextRadiusPercent = 0.9
    }

    func colorForPercentage(_ percentage: Double) -> UIColor {
        switch percentage {
            //        case 0...20:
            //            return UIColor.systemRed.withAlphaComponent(0.8)
            //        case 21...40:
            //            return UIColor.systemOrange.withAlphaComponent(0.8)
            //        case 41...60:
            //            return UIColor.systemYellow.withAlphaComponent(0.8)
            //        case 61...100:
            //            return UIColor.systemGreen.withAlphaComponent(0.8)
        case 1...99:
            return UIColor.systemIndigo.withAlphaComponent(0.8)
        case 100:
            return UIColor.systemGreen.withAlphaComponent(0.8)
        default:
            return UIColor.lightGray // Default color (0% or invalid input)
        }
    }
    
    //MARK: Cell Registeration
    func CellRigister(){
        let nib = UINib(nibName: CellConfingName.ReciverAttendReportTV, bundle: nil)
        TV.register(nib, forCellReuseIdentifier: CellConfingName.ReciverAttendReportTV)
        
        TV.register(UINib(nibName: "WeeklyReportTV", bundle: nil), forCellReuseIdentifier: "WeeklyReportTV")
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
            let vc = LeveHistoryVC(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
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

//MARK: Tableview Functions
extension ReciverAttendanceReportVC : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            let headerview = UIView()
//            headerview.backgroundColor = .clear
//            
//            let label = UILabel()
//            label.translatesAutoresizingMaskIntoConstraints = false
//            label.textColor = .label
//            label.setFont(style: .title, size: 20)
//            label.text = " My Attendance"
//            
//            headerview.addSubview(label)
//            
//            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: headerview.leadingAnchor, constant: 15),label.trailingAnchor.constraint(equalTo: headerview.trailingAnchor, constant: -15),label.topAnchor.constraint(equalTo: headerview.topAnchor, constant: 5),label.bottomAnchor.constraint(equalTo: headerview.bottomAnchor, constant: -5)])
//            
//            return headerview
//        }else{
//            return nil
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section{
            
        case 0:
            return 0
            
        case 1:
            return attendanceReportData?.count ?? 0
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            
            let cell = TV.dequeueReusableCell(withIdentifier: "WeeklyReportTV", for: indexPath) as! WeeklyReportTV
            
            return cell
            
            
        }else {
            
            let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.ReciverAttendReportTV, for: indexPath) as! attendanceRepTv
            
            let dateStr = attendanceReportData?[indexPath.row].date ?? ""
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "dd-MM-yyyy"
            
            if let date = inputFormatter.date(from: dateStr) {
                let outputFormatter = DateFormatter()
                
                // Get full month name
                outputFormatter.dateFormat = "MMMM"
                let monthName = outputFormatter.string(from: date)
                
                
                // Get day only
                let calendar = Calendar.current
                let day = calendar.component(.day, from: date)
                //            cell.dayLbl.text = "\(day)"
                cell.datelbl.text = "\(monthName) \n \(day)"
            }
            
            let formattedDateString = dateFormatter.convertDate(
                attendanceReportData?[indexPath.row].date ?? ""
            ) ?? ""
            cell.dateYrLbl.text = formattedDateString
            cell.dayLbl.text = attendanceReportData?[indexPath.row].day
            //        cell.statusLbl.textColor = .white
            //
            //        if attendanceReportData?[indexPath.row].type == "present" {
            //            cell.statusLbl.text = CommonStringFile.Present.translated()
            //            cell.StatusView.backgroundColor = .systemGreen
            //        }else{
            //            cell.statusLbl.text = CommonStringFile.Absent.translated()
            //            cell.StatusView.backgroundColor = .systemRed
            //            cell.MonthView.backgroundColor =  UIColor.red1
            //            cell.DateView.backgroundColor =  .white
            //            cell.DateView.layer.borderWidth = 0.5
            //        }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 0.001
    }
    
    
    func Get_attendaceReport() {
        
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_attendance_get_absent_dates_for_child, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") {[self] (result: Result<StudentAttendanceResponse,Error>) in
            
            switch result {
                
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        //noResordStack.isHidden = true
                        attendanceReportData = SuccessMessage.data ?? []
                        TV.reloadData()
                    }
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        
                       // noResordStack.isHidden = false
                        noRecordLbl.text = SuccessMessage.message ?? ""
                    }
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
