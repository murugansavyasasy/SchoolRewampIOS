//
//  LocationReportVC.swift
//  SchoolChimes
//
//  Created by Lakshmanan on 24/04/25.
//

import UIKit
import DropDown

class LocationReportVC: UIViewController{

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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        StyleAndTranslate()
        
        NoDataLbl.isHidden = true
        
        for i in 0..<21 {
            let year = currentYear - i
            years.append(String(year))
        }
        
        YearLbl.text = years[0]
        
        Months = getMonthNames(for: years[0])
        
        MonthLbl.text = Months[currentMonth-1]
        
        SelectedMonthCode = String(format: "%02d",currentMonth)
        
        Geometric_Staff_Attendance_Report()
        
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
                        
                        NoDataLbl.isHidden = true
                        
                        Tv.reloadData()
                    }
                    
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        
                        AttendanceDetails = successMessage.data
                        NoDataLbl.text = successMessage.message
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Tv.dequeueReusableCell(withIdentifier: CellConfingName.LocationTableViewCell, for: indexPath) as! LocationTableViewCell
        
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
        
        cell.namelbl.text = AttendanceDetails?[indexPath.row].name
        cell.attendanceTypeLbl.text = AttendanceDetails?[indexPath.row].attendance_type
        cell.firstInLbl.text = "First in - " + (
            AttendanceDetails?[indexPath.row].in_time ?? ""
        )
        cell.toDateLbl.text = "Last out - " + (
            AttendanceDetails?[indexPath.row].out_time ?? ""
        )
        cell.workingHrsLbl.text = "Working Hours - " +  (
            AttendanceDetails?[indexPath.row].working_hours ?? ""
        )
        cell.StatusLbl.text = AttendanceDetails?[indexPath.row].leave_type
        if cell.StatusLbl.text == "Absent" {
            cell.StatusLbl.backgroundColor = .systemRed
        }else{
            cell.StatusLbl.backgroundColor = .systemGreen
        }
        
        if let components = convertDateComponents(from: AttendanceDetails?[indexPath.row].date ?? "") {
           
            cell.datelbl.text = components.day
            cell.mnthLbl.text = components.month
            cell.dayLbl.text = components.weekday
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedDate = AttendanceDetails?[indexPath.row].date
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

    
    @objc func GoTOHISTORY(_ sender: UITapGestureRecognizer) {
        guard let row = sender.view?.tag else { return }
       
        let selectedDate = AttendanceDetails?[row].date// Assuming you have a date property
        
        let vc = PunchHistoryListVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        
        // Now pass the date to vc
        vc.selectedDate = selectedDate ?? ""
        
        present(vc, animated: true)
    }

}
