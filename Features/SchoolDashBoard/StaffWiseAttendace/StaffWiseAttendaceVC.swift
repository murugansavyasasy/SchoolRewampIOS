//
//  StaffWiseAttendaceVC.swift
//  School Chimes
//
//  Created by apple on 26/03/26.
//

import UIKit

class StaffWiseAttendaceVC: UIViewController, Datepicker {

    @IBOutlet weak var selectstaffDefaultLbl: UILabel!
    @IBOutlet weak var todateDefaultLbl: UILabel!
    @IBOutlet weak var fromdateDefaultLbl: UILabel!
    @IBOutlet weak var noRecrodImg: UIImageView!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var norecordStack: UIStackView!
    @IBOutlet weak var menuNameLbl: UILabel!
    @IBOutlet weak var stafNameLbl: UILabel!
    @IBOutlet weak var staffListDropDownView: UIView!
    @IBOutlet weak var todateView: UIView!
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var tabelview: UITableView!
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    
    var responseData: StaffAttendanceResponseSuc?
    var sortedDates: [String] = []
    let fromDatePicker = UIDatePicker()
    let toDatePicker = UIDatePicker()
    var staffdetails = UserDefaultFileManager.get_staff_Details()
    let dateFormatter = DateFormatter()
    var dropDown  = DropDown()
    var staffDetails: [GetStaffDetails]?
    var staffId : String = ""
    var is_selectAllStaff : Bool = true
    var isFromDate : Bool = true
    var from_date : Date?
    var To_date : Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fromdateDefaultLbl.setRequiredText(fromdateDefaultLbl.text ?? "")
        todateDefaultLbl.setRequiredText(todateDefaultLbl.text ?? "")
        selectstaffDefaultLbl.setRequiredText(selectstaffDefaultLbl.text ?? "")
        setupTableView()
        SelectFromDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        toDateTextField.text = formatter.string(from: Date())
        fromDateTextField.text = formatter.string(from: Date())
        let staffDropDownClick =  UITapGestureRecognizer(target: self, action: #selector(staffDropDownList))
        staffListDropDownView.addGestureRecognizer(staffDropDownClick)

        menuNameLbl.setFont(style: .title, size: FontSize.TitleSize)
        menuNameLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName,secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        
        let fromTap = UITapGestureRecognizer(target: self, action: #selector(SelectFromDate))
        fromDateView.addGestureRecognizer(fromTap)
        
        let toTap = UITapGestureRecognizer(target: self, action: #selector(SelectToDate))
        todateView.addGestureRecognizer(toTap)
    }
    func setupTableView() {
        tabelview.delegate = self
        tabelview.dataSource = self
        tabelview.separatorStyle = .none
        tabelview.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
        
        tabelview.register(UINib(nibName: "OverallSummaryCell", bundle: nil), forCellReuseIdentifier: "OverallSummaryCell")
        tabelview.register(UINib(nibName: "AttendanceHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "AttendanceHeaderView")
        tabelview.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        
        if #available(iOS 15.0, *) {
            tabelview.sectionHeaderTopPadding = 0
        }
        
        getStaffListAPI()
        
    }

    @IBAction func SelectFromDate(){
        isFromDate = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.date = fromDateTextField.text
        if let maxDate = To_date{
            vc.maximumDate = maxDate
        }else{
            vc.maximumDate = Date()
        }
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func SelectToDate(){
        isFromDate = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.date = toDateTextField.text
        vc.maximumDate = Date()
        if let minDate = from_date{
            vc.minimumDate = minDate
        }
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    func date(date: String) {
        let savedCode = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        let normalizedCode = normalizedLocaleIdentifier(for: savedCode)
        let locale = Locale(identifier: normalizedCode)
        
        let inputFormatter = DateFormatter()
        inputFormatter.locale = locale
        inputFormatter.dateFormat = "dd MMM yyyy" // correct format
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = locale
        outputFormatter.dateFormat = "dd MMM yyyy"
        
        guard let parsedDate = inputFormatter.date(from: date) else {
            print("❌ Could not parse: \(date)")
            return
        }
        
        let finalDateString = outputFormatter.string(from: parsedDate)
        
        if isFromDate {
            fromDateTextField.text = finalDateString
            from_date = parsedDate
        } else {
            toDateTextField.text = finalDateString
            To_date = parsedDate
        }
        
        getStaffWiseAttendace(fromDate: convertDate(fromDateTextField.text ?? "") ?? "", toDate: convertDate(toDateTextField.text ?? "") ?? "", staffId: staffId == "" ? "0" : staffId, select_staffAll:is_selectAllStaff)
    }
    
    @IBAction func BackBtnAct(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    
}
extension StaffWiseAttendaceVC : UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        if is_selectAllStaff == true {
            return 1 + sortedDates.count   // with summary
        } else {
            return sortedDates.count       // without summary
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if is_selectAllStaff == true {
            if section == 0 {
                return 1
            }
            let dateKey = sortedDates[section - 1]
            let details = responseData?.data?.first?.all_attd?[dateKey]?.attd_details ?? []
            return details.count
            
        } else {
            let dateKey = sortedDates[section]
            let details = responseData?.data?.first?.all_attd?[dateKey]?.attd_details ?? []
            return details.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if is_selectAllStaff == true {
            if section == 0 { return nil }
            let dateKey = sortedDates[section - 1]
            let stat = responseData?.data?.first?.all_attd?[dateKey]?.stat
            
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AttendanceHeaderView") as? AttendanceHeaderView
            header?.configure(dateString: dateKey, stat: stat)
            header?.summaryLabel.isHidden = false
            return header
            
        } else {
            let dateKey = sortedDates[section]
            let stat = responseData?.data?.first?.all_attd?[dateKey]?.stat
            
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AttendanceHeaderView") as? AttendanceHeaderView
            header?.configure(dateString: dateKey, stat: stat)
            header?.summaryLabel.isHidden = true
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if is_selectAllStaff == true {
            return section == 0 ? 0 : 90
        } else {
            return 90
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // ✅ CASE 1: Show Overall Summary (only when is_selectAllStaff == true)
        if is_selectAllStaff == true && indexPath.section == 0 {
            
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "OverallSummaryCell",
                for: indexPath
            ) as? OverallSummaryCell else {
                return UITableViewCell()
            }
            
            if let stat = responseData?.data?.first?.overall_stat {
                cell.configure(with: stat)
            }
            
            return cell
        }
        
        // ✅ CASE 2: Normal attendance cells
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "LocationTableViewCell",
            for: indexPath
        ) as? LocationTableViewCell else {
            return UITableViewCell()
        }
        
        cell.dateViewWidthCon.constant = 0
        cell.dateViewHeightCon.constant = 0
        
        // 🔥 Correct date index handling
        let dateIndex = (is_selectAllStaff == true) ? indexPath.section - 1 : indexPath.section
        let dateKey = sortedDates[dateIndex]
        
        let details = responseData?.data?.first?.all_attd?[dateKey]?.attd_details ?? []
        let attendanceData = details[indexPath.row]
        
        // UI setup
        cell.fullView.setShadow()
        cell.selectionStyle = .none
        
        // Name
        cell.namelbl.text = attendanceData.name
        
        // Role / Designation
        if let role = attendanceData.designation, !role.isEmpty {
            cell.rollLable.text = role
        } else {
            cell.rollLable.text = attendanceData.role ?? "Not Mentioned"
        }
        
        // Attendance Status Button
        if let attendanceDict = attendanceData.attendance_type,
           let first = attendanceDict.first {
            
            let key = first.key
            let value = first.value
            
            let statusText = "\(key.uppercased()) | \(value)"
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
        
        // Check-in / Check-out
        cell.checkoutLbl.text = (attendanceData.out_time?.isEmpty == false) ? attendanceData.out_time : "-"
        cell.checkinLbl.text = (attendanceData.in_time?.isEmpty == false) ? attendanceData.in_time : "-"
        
        // Working Hours
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
            cell.dateLbl.text = components.day
            cell.dayLbl.text = components.weekday
        } else {
            cell.dateLbl.text = "-"
            cell.dayLbl.text = "-"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ❌ Ignore summary cell
        if is_selectAllStaff == true && indexPath.section == 0 {
            return
        }
        // ✅ Correct section handling
        let dateIndex = (is_selectAllStaff == true) ? indexPath.section - 1 : indexPath.section
        let dateKey = sortedDates[dateIndex]
        
        let details = responseData?.data?.first?.all_attd?[dateKey]?.attd_details ?? []
        
        guard indexPath.row < details.count else { return }
        
        let attendanceData = details[indexPath.row]
        
        // ✅ Open next screen ONLY for LocationTableViewCell
        let vc = PunchHistoryListVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        
        vc.selectedDate = attendanceData.date ?? ""
        vc.selected_staff_id = attendanceData.staff_id ?? ""
        vc.comeFromStaffWiseAttendaceReportMenu = true
        vc.date = attendanceData.date ?? ""
        vc.roll = attendanceData.role ?? ""
        vc.user = attendanceData.name
        
        present(vc, animated: true)
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180
        }
        return UITableView.automaticDimension
    }
    
    

    func getStaffWiseAttendace(fromDate: String, toDate: String, staffId: String, select_staffAll: Bool) {
        showActivityLoader()
        APIService.shared.makeApi(
            url: ServiceUrl.staff_attd_geometric_remove_attendance_report_date_wise,
            parameters: [
                "from_date": fromDate,
                "to_date": toDate,
                "staff_id": staffId,
                "is_all": select_staffAll
            ],
            type: ApitTypeSringFile.GET,
            token: staffdetails?.access_token ?? "",
            isBaseUrl: false
        ) { [weak self] (result: Result<StaffAttendanceResponseSuc, Error>) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                DispatchQueue.main.async { [self] in
                    if success.status == true {
                      
                        self.norecordStack.isHidden = true
                        self.tabelview.isHidden = false
                        self.handleAttendanceResponse(success)
                    } else {
                        print("API status false")
                        self.hideActivityLoader()
                            self.noRecordLbl.text = success.message ?? ""
                        self.norecordStack.isHidden = false
                         self.noRecrodImg.isHidden = false
                        self.noRecordLbl.isHidden = false
                        
                        self.tabelview.isHidden = true
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.hideActivityLoader()
                    print("Error:", error.localizedDescription)
                }
            }
        }
    }
    
    private func handleAttendanceResponse(_ response: StaffAttendanceResponseSuc) {
        
        responseData = response
        
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        
        if let allAttd = response.data?.first?.all_attd {
            sortedDates = allAttd.keys.sorted(by: {
                let d1 = df.date(from: $0) ?? Date()
                let d2 = df.date(from: $1) ?? Date()
                return d1 > d2
            })
        }
        
        if let firstDateKey = sortedDates.first,
           let d = df.date(from: firstDateKey) {
            
            fromDatePicker.date = d
            toDatePicker.date = d
            
//            fromDateTextField.text = dateFormatter.string(from: d)
//            toDateTextField.text = dateFormatter.string(from: d)
        }
        
        hideActivityLoader()
        tabelview.reloadData()
    }
    
    func getStaffListAPI() {
        APIService.shared.makeApi(
            url: ServiceUrl.recipient_get_staff_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { (result: Result<GetStafflistSuc, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let successMessage):
                    if successMessage.status ?? false{
                        self.staffDetails = successMessage.data ?? []
                        self.getStaffWiseAttendace(fromDate: convertDate(self.fromDateTextField.text ?? "") ?? "", toDate: convertDate(self.toDateTextField.text ?? "") ?? "", staffId: "0", select_staffAll:true)
                    }
                case .failure(let error):
                    
                    DispatchQueue.main.async {
                        
                    }
                }
            }
        }
        
    }
    
    @IBAction func staffDropDownList() {
        var staffName = ["View All Staff"]
        staffName += (staffDetails ?? []).compactMap {
            guard let name = $0.name, !name.isEmpty else { return nil }
            return name
        }
        dropDown.dataSource = staffName
        dropDown.anchorView = staffListDropDownView
       
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) in
            if index == 0 {
                cell.optionLabel.textColor = .systemBlue
                cell.optionLabel.font = UIFont.boldSystemFont(ofSize: 17)
            } else {
                cell.optionLabel.textColor = .black
                cell.optionLabel.font = UIFont.systemFont(ofSize: 15)
            }
        }

        dropDown.show()
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDown.anchorView!.plainView.bounds.height)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0 {
                is_selectAllStaff = true
                staffId = ""
            } else {
                is_selectAllStaff = false
                staffId = staffDetails?[index - 1].id ?? ""
            }
            stafNameLbl.text = item
            is_selectAllStaff = item == "View All Staff"
            getStaffWiseAttendace(fromDate: convertDate(fromDateTextField.text ?? "") ?? "", toDate: convertDate(toDateTextField.text ?? "") ?? "", staffId: item == "View All Staff" ? "0" : staffId, select_staffAll:is_selectAllStaff)
        }
    }
    
}
