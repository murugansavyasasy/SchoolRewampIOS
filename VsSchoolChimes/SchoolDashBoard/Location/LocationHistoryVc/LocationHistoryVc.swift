//
//  LocationHistoryVc.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 04/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import DropDown
class LocationHistoryVc: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var seachHeight: NSLayoutConstraint!
    @IBOutlet weak var selectYrHeight: NSLayoutConstraint!
    @IBOutlet weak var selctStaffHeight: NSLayoutConstraint!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var staffDefaultsLbl: UILabel!
    @IBOutlet weak var selectMthLbl: UILabel!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var stafNameLbl: UILabel!
    @IBOutlet weak var staffDropViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var staffDropView: UIViewX!
    @IBOutlet weak var monthView: UIViewX!
    @IBOutlet weak var yearsView: UIViewX!
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
    var SelectedMonthCode = ""
    var currentMonth = Calendar.current.component(.month, from: Date())
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyShadowAndCornerRadius(to:yearsView)
        applyShadowAndCornerRadius(to:staffDropView)
        applyShadowAndCornerRadius(to:monthView)
       
        noRecordLbl.isHidden = true
        yearsView.isHidden = true
        monthView.isHidden = true
        staffDropViewHeight.constant = 0
        selectYrHeight.constant = 0
        selctStaffHeight.constant = 0
        staffDefaultsLbl.isHidden = true
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: currentDate)
        print(formattedDate) // Example output: "Mo
        display_date = formattedDate
        let date = Date()
        let dateFormatters = DateFormatter()
        dateFormatters.dateFormat = "MMMM"
        let monthName = dateFormatters.string(from: date)
        print("Current Month: \(monthName)")
        selectMthLbl.text! = monthName
       
        if  type  == 1{
        }else{
            for i in 0..<21 {
                let year = currentYear - i
                years.append(String(year))
            }
            
            yearLbl.text = years[0]
            
            Months = getMonthNames(for: years[0])
            
            selectMthLbl.text = Months[currentMonth-1]
            
            SelectedMonthCode = String(format: "%02d",currentMonth)
            
            geometric_principal_attendance_report()
            
            let rowNib = UINib(nibName: CellConfingName.LocationTableViewCell, bundle: nil)
            tv.register(rowNib, forCellReuseIdentifier: CellConfingName.LocationTableViewCell)
            tv.delegate = self
            tv.dataSource = self
           
            let seletYrs = UITapGestureRecognizer(target: self, action: #selector(selectYearsViewClick))
            yearsView.addGestureRecognizer(seletYrs)
            let selectMonth = UITapGestureRecognizer(target: self, action: #selector(selectMonthViewClick))
            monthView.addGestureRecognizer(selectMonth)
            let StaffDrop = UITapGestureRecognizer(target: self, action: #selector(staffDropDownList))
            staffDropView.addGestureRecognizer(StaffDrop)
        }
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
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
    @IBAction func backClick(){
        dismiss(animated: true)
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        
        if SegmentControl.selectedSegmentIndex == 0{
            
            monthView.isHidden = true
            yearsView.isHidden = true
            staffDropViewHeight.constant = 0
            selectYrHeight.constant = 0
            selctStaffHeight.constant = 0
            staffDefaultsLbl.isHidden = true
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = dateFormatter.string(from: currentDate)
            print(formattedDate) // Example output: "Mo
            display_date = formattedDate
            noRecordLbl.isHidden = true
            RefId = 1
            geometric_principal_attendance_report()
            
        }else{
            
            RefId = 2
            monthView.isHidden = false
            yearsView.isHidden = false
            staffDropViewHeight.constant = 137
            selectYrHeight.constant = 30
            selctStaffHeight.constant = 38
            staffDefaultsLbl.isHidden = false
            tv.isHidden = false
            dateAndMoth = ""
            getStaffListAPI()
        }
    }
    
    
    @IBAction func selectYearsViewClick(){
       
            let myArray = years
            dropDown.dataSource = myArray
            dropDown.anchorView = yearsView
            dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
            dropDown.direction = .bottom
            DropDown.appearance().backgroundColor = UIColor.white
            dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            yearLbl.text = item
            Months = getMonthNames(for: item)
            geometric_principal_attendance_report()
        }
    }
    
    @IBAction func selectMonthViewClick(){
        let myArray = Months
        dropDown.dataSource = myArray
        dropDown.anchorView = monthView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            selectMthLbl.text = item
            SelectedMonthCode = String(format: "%02d", index + 1)
            geometric_principal_attendance_report()
        }
    }
    
    @IBAction func staffDropDownList(){
        var staffName: [String] = []
        for i in 0..<(staffDetails?.count ?? 0) {
            staffName.append(staffDetails?[i].name ?? "")
        }
        dropDown.dataSource = staffName
        dropDown.anchorView = staffDropView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            staffId = Int(staffDetails?[index].id ?? "")
            stafNameLbl.text = item
            
            geometric_principal_attendance_report()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staffAttendanceDetails?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LocationTableViewCell, for: indexPath) as!
        LocationTableViewCell
        cell.selectionStyle = .none
        cell.fullView.layer.cornerRadius = 20
        cell.calanderView.layer.cornerRadius = 10
        cell.calanderView.layer.masksToBounds = true
        cell.fullView.layer.masksToBounds = true
        cell.fullView.layer.shadowColor = UIColor.black.cgColor
        cell.fullView.layer.shadowOpacity = 0.5
        cell.fullView.layer.shadowOffset = CGSize(width: 4, height: 4)
        cell.fullView.layer.shadowRadius = 5
        cell.fullView.layer.masksToBounds = false
        cell.firstInLbl.isHidden = false
        cell.workingHrsLbl.isHidden = false
        cell.toDateLbl.isHidden = false
        cell.StatusLbl.layer.cornerRadius = 5
        cell.StatusLbl.layer.masksToBounds = true
        
        cell.namelbl.text = staffAttendanceDetails?[indexPath.row].name
        cell.attendanceTypeLbl.text = staffAttendanceDetails?[indexPath.row].attendance_type
        cell.firstInLbl.text = "First in - " + (
            staffAttendanceDetails?[indexPath.row].in_time ?? ""
        )
        cell.toDateLbl.text = "Last out - " + (
            staffAttendanceDetails?[indexPath.row].out_time ?? ""
        )
        cell.workingHrsLbl.text = "Working Hours - " +  (
            staffAttendanceDetails?[indexPath.row].working_hours ?? ""
        )
        cell.StatusLbl.text = staffAttendanceDetails?[indexPath.row].leave_type
        
        if cell.StatusLbl.text == "Absent" {
            cell.StatusLbl.backgroundColor = .systemRed
        }else{
            cell.StatusLbl.backgroundColor = .systemGreen
        }
        
        if let components = convertDateComponents(from: staffAttendanceDetails?[indexPath.row].date ?? "") {
           
            cell.datelbl.text = components.day
            cell.mnthLbl.text = components.month
            cell.dayLbl.text = components.weekday
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedDate = staffAttendanceDetails?[indexPath.row].date
        let vc = PunchHistoryListVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.selectedDate = selectedDate ?? ""
        present(vc, animated: true)
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

    
    @IBAction func ShowHistory(ges : ShowPunchHistiryClick){
        let vc = PunchHistoryListVC(nibName: nil, bundle: nil)
        vc.date = ges.date
        vc.instituteId = instituteId
        vc.staffId = ges.staffId
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchbar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        tv.alpha = 1
        self.tv.reloadData()
    }
    
    
    func getStaffListAPI(){
        APIService.shared
            .makeApi(url: ServiceUrl.recipient_get_staff_list, parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <GetStafflistSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            staffDetails = successMessage.data
                            staffId = Int((staffDetails?.first?.id ?? ""))
                            stafNameLbl.text = staffDetails?.first?.name ?? ""
                            geometric_principal_attendance_report()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            
                            
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
    func geometric_principal_attendance_report(){
        var param: [String: Any]
        let todaydate = getCurrentDateString()
        let year_Lbl = (yearLbl.text ?? "") + "-" + SelectedMonthCode
            
            if RefId == 1{
                param = [principalAttendenceReportStringFile.attendance_dt: todaydate ]
            }else{
                param = [ principalAttendenceReportStringFile.attendance_month: year_Lbl,
                          principalAttendenceReportStringFile.staff_id: staffId ?? ""]
            }
            
            APIService.shared
                .makeApi(url: ServiceUrl.geometric_principal_attendance_report,parameters:param, type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                    result:Result <StaffAttendanceResponse,
                    Error>
                ) in
                    switch result {
                    case .success(let successMessage):
                        if successMessage.status == true{
                            DispatchQueue.main.async { [self] in
                                noRecordLbl.isHidden = true
                                staffAttendanceDetails = successMessage.data
                                tv.isHidden = false
                                tv.reloadData()
                            }
                        }else{
                            DispatchQueue.main.async { [self] in
                                noRecordLbl.isHidden = false
                                noRecordLbl.text = successMessage.message
                                tv.isHidden = true
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        
                    }
                }
            
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
