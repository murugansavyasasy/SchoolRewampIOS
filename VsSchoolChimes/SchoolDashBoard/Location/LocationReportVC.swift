
//

import UIKit

class LocationReportVC: UIViewController{
    
    @IBOutlet weak var agandaStack: UIStackView!
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
                        agandaStack.isHidden = false
                        Tv.reloadData()
                    }
                    
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        AttendanceDetails = successMessage.data
                        NoDataLbl.text = successMessage.message
                        noRecdStackView.isHidden = false
                        NoDataLbl.isHidden = false
                        agandaStack.isHidden = true
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
        let savedCode = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        let localeID = normalizedLocaleIdentifier(for: savedCode)
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: localeID)
        monthFormatter.dateFormat = "MMMM"

        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())

        let selectedYearInt = Int(selectedYear) ?? 0
        let maxMonth = (selectedYearInt == currentYear) ? currentMonth : 12

        return (1...maxMonth).compactMap { month in
            var components = DateComponents()
            components.year = 2000
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
        guard let attendanceData = AttendanceDetails?[indexPath.row] else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.LocationTableViewCell,
            for: indexPath
        ) as! LocationTableViewCell
        
        cell.fullView.setShadow()
        cell.selectionStyle = .none
        
        // Name
        cell.namelbl.text = attendanceData.name
        
        // Role
        if let role = attendanceData.designation, !role.isEmpty {
            cell.rollLable.text = role
        } else {
            cell.rollLable.text = attendanceData.role ?? "Not Mentioned"
        }
        
        // Status Button
        if let attendanceDict = attendanceData.attendance_type,
           let first = attendanceDict.first {
            
            let key = first.key  // FD / HD
            let value = first.value
            var statusText = ""
            statusText = "\(key.uppercased()) |\(value)"
            cell.statusBtn.setTitle(statusText, for: .normal)
            
            if value.lowercased() == "absent" {
                cell.statusBtn.setTitleColor(.systemRed, for: .normal)
                cell.statusBtn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            } else {
                cell.statusBtn.setTitleColor(.systemGreen, for: .normal)
                cell.statusBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            }
        } else {
            cell.statusBtn.setTitle("N/A", for: .normal)
            cell.statusBtn.setTitleColor(.systemGray, for: .normal)
            cell.statusBtn.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
        }
        
        if let out = attendanceData.out_time{
            cell.checkoutLbl.text = out !=  "" ? out : "-"
        }
        if let chekin = attendanceData.in_time{
            cell.checkinLbl.text = chekin !=  "" ? chekin : "-"
        }
        // ✅ Working Hours (minutes < 60 -> show in min)
        if let workingHours = attendanceData.working_hours,
           let totalMinutes = Int(workingHours) {
            
            if totalMinutes < 60 {
                cell.hoursLbl.text = "\(totalMinutes) min"
            } else {
                let hours = totalMinutes / 60
                let minutes = totalMinutes % 60
                if minutes == 0 {
                    cell.hoursLbl.text = "\(hours) hr"
                } else {
                    cell.hoursLbl.text = "\(hours) hr \(minutes) min"
                }
            }
        } else {
            cell.hoursLbl.text = "-"
        }
        
        // Date + Weekday
        if let components = convertDateComponents(from: attendanceData.date ?? "") {
            cell.dateLbl.text = components.day       // e.g. "03"
            cell.dayLbl.text = components.weekday    // e.g. "Thu"
        } else {
            cell.dateLbl.text = "-"
            cell.dayLbl.text = "-"
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let attendanceData = AttendanceDetails?[indexPath.row],
              let attendanceDict = attendanceData.attendance_type,
              let first = attendanceDict.first else { return }
        
        let key = first.key.uppercased()  // FD / HD
        let value = first.value
        let statusText = "\(key) | \(value)"
        
        if value.lowercased() != "absent", let inTime = attendanceData.in_time, !inTime.isEmpty {
            let vc = PunchHistoryListVC(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            vc.selectedDate = attendanceData.date ?? ""
            vc.selected_staff_id = attendanceData.staff_id ?? ""
            vc.date = attendanceData.date ?? ""
            vc.roll = attendanceData.role ?? ""
            vc.user = attendanceData.name
            
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
        weekdayFormatter.dateFormat = "EEE" // Full day name: Monday, Tuesday...
        
        let day = dayFormatter.string(from: date)
        let month = monthFormatter.string(from: date)
        let weekday = weekdayFormatter.string(from: date)
        
        return (day, month, weekday)
    }
    
}
