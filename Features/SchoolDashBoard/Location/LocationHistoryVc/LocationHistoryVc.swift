
//

import UIKit
//import DropDown
class LocationHistoryVc: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    
    
    @IBOutlet weak var nodataRecStack: UIStackView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var seachHeight: NSLayoutConstraint!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var staffDefaultsLbl: UILabel!
    @IBOutlet weak var selectMthLbl: UILabel!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var stafNameLbl: UILabel!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var staffDropView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var yearsView: UIView!
    @IBOutlet weak var yearAndmonthStack: UIStackView!
    @IBOutlet weak var SegmentControl: UISegmentedControl!
    
    
    var type : Int!
    var instituteId : Int!
    var staffId : Int!
    var DropDownstaffId : Int!
    var display_date : String!
    var dropDown  = DropDown()
    var years: [String] = []
    var Months: [String] = []
    let currentYear = Calendar.current.component(.year, from: Date())
    let dateFormatter = DateFormatter()
    var RefId = 1
    var url_date : String!
    var dateAndMoth : String!
    var staffDetails: [GetStaffDetails]?
    var staffAttendanceDetails: [StaffAttendance]?
    var SearchResults: [StaffAttendance]?
    var SelectedMonthCode = ""
    var currentMonth = Calendar.current.component(.month, from: Date())
    var AcadimicYearDatas : [AcadimicYearData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        setupInitialData()
        setupGestureRecognizers()
        
        SegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        SegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        SegmentControl.selectedSegmentTintColor = .primery
    }
    
    // MARK: - UI Setup
    func setupUI() {
        
        BackBtn
            .configureAsBackButton(
                firstLine: MenuStringFile.selectedMenuName,
                secondLine: UserDefaultFileManager
                    .get_staff_Details()?.school_name ?? ""
            )
        let segments = ["Today's Report".translated(), "Historical Data".translated()]
        SegmentControl.removeAllSegments()
        segments.enumerated().forEach {
            SegmentControl.insertSegment(withTitle: $1, at: $0, animated: false)
        }
        SegmentControl.selectedSegmentIndex = 0
        applyShadowAndCornerRadius(to: yearsView)
        applyShadowAndCornerRadius(to: staffDropView)
        applyShadowAndCornerRadius(to: monthView)
        yearAndmonthStack.isHidden = true
        staffDropView.isHidden = true
        staffDefaultsLbl.isHidden = true
    }
    
    
    func setupSearchBar() {
        searchbar.searchTextField.addDoneButton()
        searchbar.delegate = self
    }
    
    func setupInitialData() {
        let currentDate = Date()
        dateFormatter.locale = LocaleManager.shared.apiLocale
        dateFormatter.dateFormat = "yyyy-MM-dd"
        display_date = dateFormatter.string(from: currentDate)
        
        let monthName = DateFormatter.localizedString(from: currentDate, dateStyle: .none, timeStyle: .none)
        selectMthLbl.text = monthName
        
        if type == 1 {
            // Handle special case for type 1 if needed
        } else {
            getAcademicYr()
        }
    }
    func getAcademicYr() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_recipient_get_academic_year_list,
            parameters: [:],
            type: ApitTypeSringFile.GET, // make sure this is not a typo
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<get_academic_yearSuc, Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        self.AcadimicYearDatas = successMessage.data ?? []
                        self.years.removeAll()

                        var yearSet = Set<String>()
                        var currentAcademicYearEnd: String?

                        for yearData in self.AcadimicYearDatas {
                            guard let yearRange = yearData.year else { continue }
                            
                            let parts = yearRange
                                .components(separatedBy: "-")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                            
                            // Add both years to Set (ensures uniqueness)
                            if parts.count == 2 {
                                yearSet.insert(parts[0])
                                yearSet.insert(parts[1])
                                
                                // Capture END year of current academic year
                                if yearData.current_academic_year == true {
                                    currentAcademicYearEnd = parts[1]
                                }
                            }
                        }

                        // Convert Set → Sorted Array
                        self.years = Array(yearSet).sorted()

                        // Set label and dependent data
                        if let currentYear = currentAcademicYearEnd {
                            self.yearLbl.text = currentYear
                            self.Months = self.getMonthNames(for: currentYear)
                            self.selectMthLbl.text = self.Months[self.currentMonth - 1]
                            self.SelectedMonthCode = String(format: "%02d", self.currentMonth)
                            self.geometric_principal_attendance_report()
                            self.setupTableView()
                        }

                        print("Unique Years:", self.years)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    func setupTableView() {
        let rowNib = UINib(nibName: CellConfingName.LocationTableViewCell, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: CellConfingName.LocationTableViewCell)
        tv.delegate = self
        tv.dataSource = self
    }
    
    func setupGestureRecognizers() {
        let seletYrs = UITapGestureRecognizer(target: self, action: #selector(selectYearsViewClick))
        yearsView.addGestureRecognizer(seletYrs)
        
        let selectMonth = UITapGestureRecognizer(target: self, action: #selector(selectMonthViewClick))
        monthView.addGestureRecognizer(selectMonth)
        
        let StaffDrop = UITapGestureRecognizer(target: self, action: #selector(staffDropDownList))
        staffDropView.addGestureRecognizer(StaffDrop)
    }
    
    // MARK: - Action Methods
    @IBAction func backClick() {
        dismiss(animated: true)
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        if SegmentControl.selectedSegmentIndex == 0 {
            // Handle segment 0
            RefId = 1
            ViewAnimator.hideFade(yearAndmonthStack)
            ViewAnimator.hideFade(staffDropView)
            ViewAnimator.hideFade(staffDefaultsLbl)
            geometric_principal_attendance_report()
        } else {
            // Handle segment 1
            RefId = 2
            
            ViewAnimator.showFade(yearAndmonthStack)
            ViewAnimator.showFade(staffDropView)
            ViewAnimator.showFade(staffDefaultsLbl)
            dateAndMoth = ""
            
            getStaffListAPI { [self] result in
                switch result {
                case .success(let staffListResponse):
                    let staffDetails = staffListResponse.data
                    self.staffDetails = staffDetails
                    staffId = Int(staffDetails?.first?.id ?? "0")
                    let staffName = staffDetails?.first?.name
                    self.stafNameLbl.text = staffName
                    geometric_principal_attendance_report()
                case .failure(let error):
                    print("Failed to fetch staff list:", error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func selectYearsViewClick() {
        dropDown.dataSource = years
        dropDown.anchorView = yearsView
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDown.anchorView!.plainView.bounds.height)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            yearLbl.text = item
            Months = getMonthNames(for: item)
            self.selectMthLbl.text = self.Months[self.currentMonth - 1]
            self.SelectedMonthCode = String(format: "%02d", self.currentMonth)
            geometric_principal_attendance_report()
        }
    }
    
    @IBAction func selectMonthViewClick() {
        dropDown.dataSource = Months
        dropDown.anchorView = monthView
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDown.anchorView!.plainView.bounds.height)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            selectMthLbl.text = item
            SelectedMonthCode = String(format: "%02d", index + 1)
            geometric_principal_attendance_report()
        }
    }
    
    @IBAction func staffDropDownList() {
        var staffName: [String] = []
        for staff in staffDetails ?? [] {
            staffName.append(staff.name ?? "")
        }
        dropDown.dataSource = staffName
        dropDown.anchorView = staffDropView
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDown.anchorView!.plainView.bounds.height)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            staffId = Int(staffDetails?[index].id ?? "")
            stafNameLbl.text = item
            geometric_principal_attendance_report()
        }
    }
    
    //    @IBAction func ShowHistory(ges: ShowPunchHistiryClick) {
    //        let vc = PunchHistoryListVC(nibName: nil, bundle: nil)
    //        vc.date = ges.date
    //        vc.instituteId = instituteId
    //        vc.staffId = ges.staffId
    //        vc.modalPresentationStyle = .formSheet
    //        present(vc, animated: true)
    //    }
    
    // MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchResults?.count ?? 0
    }
    
    // MARK: - TableView cellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let attendanceData = SearchResults?[indexPath.row] else {
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
    
    
    
    func updateStatus(label: UILabel, typeLabel: UILabel, statusView: UIView, key: String, value: String) {
        typeLabel.text = key
        let isPresent = value == "Present"
        label.text = isPresent ? "Present" : "Absent"
        statusView.backgroundColor = isPresent ? .systemGreen : .systemRed
        statusView.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if SearchResults?[indexPath.row].in_time != ""{
            let selectedDate = SearchResults?[indexPath.row].date
            let vc = PunchHistoryListVC(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            vc.selectedDate = selectedDate ?? ""
            vc.selected_staff_id = SearchResults?[indexPath.row].staff_id ?? ""
            vc.date = SearchResults?[indexPath.row].date ?? ""
            vc.roll = SearchResults?[indexPath.row].role ?? ""
            vc.user = SearchResults?[indexPath.row].name
            present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Helper Methods
    func getMonthNames(for selectedYear: String) -> [String] {
        
        let monthFormatter = DateFormatter()
        monthFormatter.locale = LocaleManager.shared.displayLocale
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
    
    func convertDateComponents(from dateString: String) -> (day: String, month: String, weekday: String)? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX") // safe
        
        guard let date = inputFormatter.date(from: dateString) else { return nil }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        outputFormatter.dateFormat = "dd"
        let day = outputFormatter.string(from: date)
        
        outputFormatter.dateFormat = "MMM"
        let month = outputFormatter.string(from: date)
        
        outputFormatter.dateFormat = "EEE"
        let weekday = outputFormatter.string(from: date)
        
        return (day, month, weekday)
    }
    
    
    func geometric_principal_attendance_report() {
        var param: [String: Any]
        let todaydate = getCurrentDateString()
        let year_Lbl = (yearLbl.text ?? "") + "-" + SelectedMonthCode
        
        print("todaydatetodaydate",todaydate)
        if RefId == 1 {
            param = [principalAttendenceReportStringFile.attendance_dt: todaydate]
        } else {
            param = [
                principalAttendenceReportStringFile.attendance_month: year_Lbl,
                principalAttendenceReportStringFile.staff_id: staffId ?? ""
            ]
        }
        
        APIService.shared.makeApi(url: ServiceUrl.geometric_principal_attendance_report, parameters: param, type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false) { [self] (result: Result<StaffAttendanceResponse, Error>) in
            switch result {
            case .success(let successMessage):
                DispatchQueue.main.async { [self] in
                    if successMessage.status == true {
                        staffAttendanceDetails = successMessage.data
                        SearchResults = staffAttendanceDetails
                        seachHeight.constant = 0
                        if SearchResults?.count ?? 0 > 1 {
                            seachHeight.constant = 56
                        }
                        
                        tv.isHidden = false
                        nodataRecStack.isHidden = true
                        tv.reloadData()
                    } else {
                        tv.isHidden = true
                        nodataRecStack.isHidden = false
                        seachHeight.constant = 0
                        staffAttendanceDetails = successMessage.data
                        noRecordLbl.text = successMessage.message
                        tv.reloadData()
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getStaffListAPI(completion: @escaping (Result<GetStafflistSuc, Error>) -> Void) {
        APIService.shared.makeApi(
            url: ServiceUrl.recipient_get_staff_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { (result: Result<GetStafflistSuc, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true {
                        completion(.success(successMessage))
                    } else {
                        // If needed, you can create a custom error here
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid status"])
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard let Details = staffAttendanceDetails else {
            staffAttendanceDetails = []
            
            tv.reloadData()
            return
        }
        
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            SearchResults = staffAttendanceDetails
            
        } else {
            
            let keyword = searchText.lowercased()
            SearchResults = staffAttendanceDetails?.filter { attendance in
                return
                (attendance.name?.localizedCaseInsensitiveContains(keyword) ?? false) ||
                (attendance.date?.localizedCaseInsensitiveContains(keyword) ?? false) ||
                (attendance.leave_type?.localizedCaseInsensitiveContains(keyword) ?? false) ||
                //                /*(attendance.attendance_type?.localizedCaseInsensitiveContains(keyword) ?? false)*/ ||
                (attendance.in_time?.localizedCaseInsensitiveContains(keyword) ?? false) ||
                (attendance.out_time?.localizedCaseInsensitiveContains(keyword) ?? false) ||
                (attendance.working_hours?.localizedCaseInsensitiveContains(keyword) ?? false)
            }
            
            if SearchResults?.count ?? 0 > 0{
                noRecordLbl.isHidden = true
            }else{
                noRecordLbl.isHidden = false
                noRecordLbl.text = "No search result"
            }
        }
        tv.reloadData()
    }
}


class ShowPunchHistiryClick : UITapGestureRecognizer{
    var date : String!
    var staffId : Int!
}

struct Attendance {
    var staffName: String
    var dayType: String // "Half Day" or "Full Day"
    var status: String // "Present" or "Absent"
    var firstIn: String // Time format "HH:mm"
    var lastOut: String // Time format "HH:mm"
    var workingHours: String // Total working hours
    
}
