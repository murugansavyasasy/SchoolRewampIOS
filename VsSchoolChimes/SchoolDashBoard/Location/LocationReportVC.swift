
//

import UIKit
import DropDown

class LocationReportVC: UIViewController{
    
    @IBOutlet weak var noRecdStackView: UIStackView!
    @IBOutlet weak var Tv: UITableView!
    @IBOutlet weak var SelectYearDropdownView: UIViewX!
    @IBOutlet weak var SelectMonthDropdownView: UIViewX!
    @IBOutlet weak var MonthLbl: UILabel!
    @IBOutlet weak var YearLbl: UILabel!
    @IBOutlet weak var NoDataLbl: UILabel!
    
    var staffdetails = UserDefaultFileManager.get_staff_Details()
    var AttendanceDetails: [StaffAttendance]?
    let currentYear = Calendar.current.component(.year, from: Date())
    let dateFormatter = DateFormatter()
    var currentMonth = Calendar.current.component(.month, from: Date())
    var years: [String] = []
    var Months: [String] = []
    var dropDown = DropDown()
    var SelectedMonthCode = ""
    var SendDate = ""
    var AcadimicYearDatas : [AcadimicYearData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StyleAndTranslate()
        NoDataLbl.isHidden = true
        noRecdStackView.isHidden = true
        getAcademicYr()
        
        let YearTap = UITapGestureRecognizer(target: self, action: #selector(YearSelection))
        SelectYearDropdownView.addGestureRecognizer(YearTap)
        SelectYearDropdownView.isUserInteractionEnabled = true
        
        let MonthTap = UITapGestureRecognizer(target: self, action: #selector(MonthSelection))
        SelectMonthDropdownView.addGestureRecognizer(MonthTap)
        SelectMonthDropdownView.isUserInteractionEnabled = true
        
        let rowNib = UINib(nibName: CellConfingName.LocationTableViewCell, bundle: nil)
        Tv.register(rowNib, forCellReuseIdentifier: CellConfingName.LocationTableViewCell)
        
        let rowNib1 = UINib(nibName: "punchIntTvcellTableViewCell", bundle: nil)
        Tv.register(rowNib1, forCellReuseIdentifier: "punchIntTvcellTableViewCell")
        Tv.delegate = self
        Tv.dataSource = self
    }
    func getAcademicYr() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_recipient_get_academic_year_list,
            parameters: [:],
            type: ApitTypeSringFile.GET, // make sure this is not a typo
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<get_academic_yearSuc, Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.AcadimicYearDatas = successMessage.data ?? []
                        self.years.removeAll()
                        
                        var currentAcademicYear: String?
                        
                        for yearData in self.AcadimicYearDatas {
                            // Append all first years
                            if let year = yearData.year,
                                   let firstYear = year.components(separatedBy: "-").first?.trimmingCharacters(in: .whitespaces) {
                                    self.years.append(firstYear)
                                }
                            if yearData.current_academic_year == true {
                                if let year = yearData.year,
                                       let firstYear = year.components(separatedBy: "-").first?.trimmingCharacters(in: .whitespaces) {
                                        currentAcademicYear = firstYear
                                    }
                            }
                        }

                        // Once data is loaded
                        if let year = currentAcademicYear {
                            self.YearLbl.text = year

                            if let firstYear = year.components(separatedBy: " - ").first {
                                if !self.years.isEmpty {
                                    self.Months = self.getMonthNames(for: firstYear)
                                    self.MonthLbl.text = self.Months[self.currentMonth - 1]
                                    self.SelectedMonthCode = String(format: "%02d", self.currentMonth)
                                }
                            }

                            self.Geometric_Staff_Attendance_Report()
                        }

                        print("First Years: \(self.years)")
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    func StyleAndTranslate(){
        
        applyShadowAndCornerRadius(to:SelectYearDropdownView)
        applyShadowAndCornerRadius(to:SelectMonthDropdownView)
        
        MonthLbl.setFont(style: .body, size: FontSize.BodySize)
        YearLbl.setFont(style: .body, size: FontSize.BodySize)
        NoDataLbl.setFont(style: .title, size: 16)
    }
    
    @IBAction func YearSelection(){
        
        dropDown.dataSource = years
        dropDown.anchorView = SelectYearDropdownView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            YearLbl.text = item
            Months = getMonthNames(for: item)
            self.MonthLbl.text = self.Months[self.currentMonth - 1]
            self.SelectedMonthCode = String(format: "%02d", self.currentMonth)
            Geometric_Staff_Attendance_Report()
        }
    }
    
    @IBAction func MonthSelection() {
        
        dropDown.dataSource = Months
        dropDown.anchorView = SelectMonthDropdownView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            MonthLbl.text = item
            
            // Convert index to two-digit month string
            SelectedMonthCode = String(format: "%02d", index + 1)
            Geometric_Staff_Attendance_Report()
        }
    }
    
    
    func Geometric_Staff_Attendance_Report() {
        
        let date = (YearLbl.text ?? "") + "-" + SelectedMonthCode
        
        let param = [StaffAttendanceReportStringFile.attendance_dt: date] //"2025-04"
        APIService.shared.makeApi(url: ServiceUrl.staff_attd_geometric_geometric_staff_attendance_report, parameters: param, type: ApitTypeSringFile.GET, token: staffdetails?.access_token ?? "") { [self] (reult: Result<StaffAttendanceResponse,Error>) in
            
            switch reult {
                
            case .success(let successMessage):
                
                if successMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        AttendanceDetails = successMessage.data
                        noRecdStackView.isHidden = true
                        NoDataLbl.isHidden = true
                        Tv.reloadData()
                    }
                    
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        AttendanceDetails = successMessage.data
                        NoDataLbl.text = successMessage.message
                        noRecdStackView.isHidden = false
                        NoDataLbl.isHidden = false
                        Tv.reloadData()
                    }
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getMonthNames(for selectedYear: String) -> [String] {
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale.current
        monthFormatter.dateFormat = "MMMM" // Use "LLL" for short month names
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        let selectedYearInt = Int(selectedYear) ?? 0
        let maxMonth = (selectedYearInt == currentYear) ? currentMonth : 12
        
        return (1...maxMonth).compactMap { month in
            var components = DateComponents()
            components.year = 2000 // dummy year
            components.month = month
            if let date = Calendar.current.date(from: components) {
                return monthFormatter.string(from: date)
            }
            return nil
        }
    }
    
    
}


extension LocationReportVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return AttendanceDetails?.count ?? 0
        
    }
    
    // MARK: - TableView cellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = Tv.dequeueReusableCell(
            withIdentifier: CellConfingName.LocationTableViewCell,
            for: indexPath
        ) as! LocationTableViewCell

        cell.selectionStyle = .none
        
        // Shadow + corner radius to fullView (container)
        cell.fullView.layer.cornerRadius = 16
        cell.fullView.layer.masksToBounds = false
        cell.fullView.layer.shadowColor = UIColor.black.cgColor
        cell.fullView.layer.shadowOpacity = 0.1
        cell.fullView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.fullView.layer.shadowRadius = 6

        // Calendar view round
        cell.dateView.layer.cornerRadius = cell.dateView.frame.height / 2
        cell.dateView.clipsToBounds = true
        cell.dateView.backgroundColor = UIColor.systemPurple

        // Status pill
        cell.statusBtn.layer.cornerRadius = 8
        cell.statusBtn.clipsToBounds = true
        
        let detail = AttendanceDetails?[indexPath.row]

        // Name + Role
        cell.namelbl.text = detail?.name
        if let role = detail?.designation, !role.isEmpty {
            cell.rollLable.text = role
        } else {
            cell.rollLable.text = detail?.role ?? "Not Mentioned"
        }

        // Attendance type
        if let attendanceDict = detail?.attendance_type {
            if attendanceDict.count > 1 {
                for (index, item) in attendanceDict.enumerated() {
                    let key = item.key
                    let status = (item.value == "P") ? "Present" : "Absent"
                    if index == 0 {
                        cell.statusBtn.setTitle(status.uppercased(), for: .normal)
                        cell.statusBtn.backgroundColor = (status == "Present")
                            ? UIColor.systemGreen.withAlphaComponent(0.2)
                            : UIColor.systemRed.withAlphaComponent(0.2)
                        cell.statusBtn.setTitleColor(
                            (status == "Present") ? .systemGreen : .systemRed,
                            for: .normal
                        )
                    }
                }
            } else if let firstItem = attendanceDict.first {
                let status = (firstItem.value == "P") ? "Present" : "Absent"
                cell.statusBtn.setTitle(status.uppercased(), for: .normal)
                cell.statusBtn.backgroundColor = (status == "Present")
                    ? UIColor.systemGreen.withAlphaComponent(0.2)
                    : UIColor.systemRed.withAlphaComponent(0.2)
                cell.statusBtn.setTitleColor(
                    (status == "Present") ? .systemGreen : .systemRed,
                    for: .normal
                )
            }
        }

        // In/Out time
        if let inTime = detail?.in_time, !inTime.isEmpty {
            cell.checkinLbl.isHidden = false
            cell.checkinLbl.text = "Check-in: \(inTime)"
        } else {
            cell.checkinLbl.isHidden = true
        }
        
        if let outTime = detail?.out_time, !outTime.isEmpty {
            cell.checkoutLbl.isHidden = false
            cell.checkoutLbl.text = "Checkout: \(outTime)"
        } else {
            cell.checkoutLbl.isHidden = true
        }

        // Hours
        if let hours = detail?.working_hours, !hours.isEmpty {
            cell.hoursLbl.isHidden = false
            cell.hoursLbl.text = "Hours: \(hours)"
        } else {
            cell.hoursLbl.isHidden = true
        }

        // Date components
        if let components = convertDateComponents(from: detail?.date ?? "") {
            cell.dateLbl.text = components.day
            cell.dayLbl.text = components.weekday
        }

        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if AttendanceDetails?[indexPath.row].in_time != ""{
            let selectedDate = AttendanceDetails?[indexPath.row].date
            let vc = PunchHistoryListVC(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            vc.selectedDate = selectedDate ?? ""
            vc.selected_staff_id = AttendanceDetails?[indexPath.row].staff_id ?? ""
            vc.date = AttendanceDetails?[indexPath.row].date ?? ""
            vc.roll = AttendanceDetails?[indexPath.row].role ?? ""
            vc.user = AttendanceDetails?[indexPath.row].name
            //        vc.roll = AttendanceDetails?[indexPath.row].
            present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func convertDateComponents(from dateString: String) -> (day: String, month: String, weekday: String)? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: dateString) else {
            return nil
        }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM" // Short month format: Jan, Feb, Mar...
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE" // Full day name: Monday, Tuesday...
        
        let day = dayFormatter.string(from: date)
        let month = monthFormatter.string(from: date)
        let weekday = weekdayFormatter.string(from: date)
        
        return (day, month, weekday)
    }
    
}
