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
    
    @IBOutlet weak var HeaderLbl: UILabel!
    
    @IBOutlet weak var seachHeight: NSLayoutConstraint!
    @IBOutlet weak var todayDefaultLbl: UILabel!
    @IBOutlet weak var staffWiseDefaultLbl: UILabel!
    @IBOutlet weak var selectYrHeight: NSLayoutConstraint!
    @IBOutlet weak var selctStaffHeight: NSLayoutConstraint!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var staffDefaultsLbl: UILabel!
    @IBOutlet weak var selectMthLbl: UILabel!
    @IBOutlet weak var yearLbl: UILabel!
    @IBOutlet weak var stafNameLbl: UILabel!
    @IBOutlet weak var allsatffView: UIViewX!
    @IBOutlet weak var todayStaffView: UIViewX!
    @IBOutlet weak var staffDropViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var staffDropView: UIViewX!
    @IBOutlet weak var monthView: UIViewX!
    @IBOutlet weak var yearsView: UIViewX!
    
    var type : Int!
    var instituteId : Int!
    var staffId : Int!
    var DropDownstaffId : Int!
    var display_date : String!
    var dropDown  = DropDown()
    var years: [String] = []
    var monthNames: [String] = []
    let currentYear = Calendar.current.component(.year, from: Date())
    let dateFormatter = DateFormatter()
    var RefId = 1
    var url_date : String!
    var dateAndMoth : String!
    
    let attendanceRecords: [Attendance] = [
        Attendance(staffName: "Alice Johnson", dayType: "Full Day", status: "Present", firstIn: "08:45", lastOut: "17:30", workingHours: "8.75"),
        Attendance(staffName: "Bob Smith", dayType: "Half Day", status: "Present", firstIn: "09:00", lastOut: "13:00", workingHours: "4.0"),
        Attendance(staffName: "Charlie Brown", dayType: "Full Day", status: "Absent", firstIn: "--", lastOut: "--", workingHours: "0.0"),
        Attendance(staffName: "Diana Ross", dayType: "Full Day", status: "Present", firstIn: "09:15", lastOut: "18:00", workingHours: "8.75"),
        Attendance(staffName: "Ethan Hunt", dayType: "Half Day", status: "Present", firstIn: "10:00", lastOut: "14:00", workingHours: "4.0"),
        Attendance(staffName: "Fiona Green", dayType: "Full Day", status: "Present", firstIn: "08:30", lastOut: "17:45", workingHours: "9.25"),
        Attendance(staffName: "George White", dayType: "Full Day", status: "Absent", firstIn: "--", lastOut: "--", workingHours: "0.0"),
        Attendance(staffName: "Hannah Blue", dayType: "Full Day", status: "Present", firstIn: "09:00", lastOut: "18:30", workingHours: "9.5"),
        Attendance(staffName: "Ian Black", dayType: "Half Day", status: "Present", firstIn: "12:00", lastOut: "16:00", workingHours: "4.0"),
        Attendance(staffName: "Julia Red", dayType: "Full Day", status: "Present", firstIn: "09:30", lastOut: "18:15", workingHours: "8.75")
    ]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayStaffView.applyGradient(
            colors: [UIColor.blue,UIColor.systemTeal],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 0.8, y: 0.5)
        )
        todayDefaultLbl.textColor = .white
        staffWiseDefaultLbl.textColor = .gray
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
        let userDefaults = UserDefaults.standard
        if  type  == 1{
        }else{
            for i in 0..<21 {
                let year = currentYear - i
                years.append(String(year))
            }
            yearLbl.text! = years[0]
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "MMMM"
            for month in 1...12 {
                var components = DateComponents()
                components.month = month
                if let date = Calendar.current.date(from: components) {
                    let monthName = dateFormatter.string(from: date)
                    monthNames.append(monthName)
                }
            }
            let rowNib = UINib(nibName: CellConfingName.LocationTableViewCell, bundle: nil)
            tv.register(rowNib, forCellReuseIdentifier: CellConfingName.LocationTableViewCell)
            tv.delegate = self
            tv.dataSource = self
            tv.reloadData()
            
            let today = UITapGestureRecognizer(target: self, action: #selector(todayView))
            todayStaffView.addGestureRecognizer(today)
            let allStaff = UITapGestureRecognizer(target: self, action: #selector(allStaffVIew))
            allsatffView.addGestureRecognizer(allStaff)
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
    
    @IBAction func backClick(){
        dismiss(animated: true)
    }
    
    @IBAction func todayView(){
        seachHeight.constant = 56
        tv.isHidden = false
        
        todayStaffView.applyGradient(
            colors: [UIColor.blue,UIColor.systemTeal],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 0.8, y: 0.5)
        )
        allsatffView.applyGradient(
            colors: [UIColor.systemGray6,UIColor.systemGray6],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 0.8, y: 0.5)
        )
        todayDefaultLbl.textColor = .white
        staffWiseDefaultLbl.textColor = .gray
        
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
        tv.reloadData()
    }
    
    @IBAction func allStaffVIew(){
        seachHeight.constant = 0
        noRecordLbl.isHidden = true
        allsatffView.applyGradient(
            colors: [UIColor.blue,UIColor.systemTeal],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 0.8, y: 0.5)
        )
        todayStaffView.applyGradient(
            colors: [UIColor.systemGray6,UIColor.systemGray6],
            startPoint: CGPoint(x: 0, y: 0.5),
            endPoint: CGPoint(x: 0.8, y: 0.5)
        )
        todayDefaultLbl.textColor = .gray
        staffWiseDefaultLbl.textColor = .white
        
        RefId = 2
        monthView.isHidden = false
        yearsView.isHidden = false
        staffDropViewHeight.constant = 137
        selectYrHeight.constant = 30
        selctStaffHeight.constant = 38
        staffDefaultsLbl.isHidden = false
        tv.isHidden = false
        tv.reloadData()
        dateAndMoth = ""
    }
    
    @IBAction func selectYearsViewClick(){
        if RefId == 1{
        }else{
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
            }
        }
    }
    
    @IBAction func selectMonthViewClick(){
        let myArray = monthNames
        dropDown.dataSource = myArray
        dropDown.anchorView = monthView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            selectMthLbl.text = item
        }
    }
    
    @IBAction func staffDropDownList(){
        var StaffId: [Int] = []
        var staffName: [String] = []
        dropDown.dataSource = staffName
        dropDown.anchorView = staffDropView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            staffId = StaffId[index]
            stafNameLbl.text = item
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendanceRecords.count
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
        
        cell.namelbl.text = attendanceRecords[indexPath.row].staffName
        cell.attendanceTypeLbl.text = attendanceRecords[indexPath.row].dayType
        cell.firstInLbl.text = "First in - " + attendanceRecords[indexPath.row].firstIn
        cell.toDateLbl.text = "Last out - " + attendanceRecords[indexPath.row].lastOut
        cell.workingHrsLbl.text = "Working Hours - " + attendanceRecords[indexPath.row].workingHours
        cell.StatusLbl.text = attendanceRecords[indexPath.row].status
        if cell.StatusLbl.text == "Absent" {
            cell.StatusLbl.backgroundColor = .systemRed
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let historyTap = UITapGestureRecognizer(target: self, action: #selector(GoTOHISTORY))
        cell.historyTimImage.addGestureRecognizer(historyTap)
        cell.historyTimImage.isUserInteractionEnabled = true
        return cell
    }
    
    @objc func GoTOHISTORY(){
        let vc = PunchHistoryListVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
}

class ShowPunchHistiryClick : UITapGestureRecognizer{
    var date : String!
    var staffId : Int!
}




/*
 //MARK: searchBarCancelButtonClicked
 
 AttendaceHistory()
 
 
 //MARK: viewDidload
 dateFormatter.dateFormat = "MMM d, yyyy"
 searchbar.delegate = self
 
 //MARK: Func
 
 
 //    func AttendaceHistory(){
 //
 //
 //
 //        var YearLbl = ""
 //
 //
 //        if RefId == 1 {
 //
 //            YearLbl = display_date
 //        }else if RefId == 2 {
 //            let year = yearLbl.text!
 //            let monthName = selectMthLbl.text!
 //            let dateFormatter = DateFormatter()
 //            dateFormatter.dateFormat = "MMMM" // Full month name format
 //
 //            if let date = dateFormatter.date(from: monthName) {
 //                let calendar = Calendar.current
 //                let monthNumber = calendar.component(.month, from: date)
 //                print("The month number for \(monthName) is \(monthNumber).")
 //                if  monthNumber == 1 || monthNumber == 2 || monthNumber == 3 || monthNumber == 4 || monthNumber == 5 || monthNumber == 6 || monthNumber == 7 || monthNumber == 8 || monthNumber == 9 {
 //                    YearLbl = year +  "-" + "0" + String(monthNumber)
 //                }else{
 //                    YearLbl = year +  "-"  + String(monthNumber)
 //
 //                }
 //            } else {
 //                print("Invalid month name.")
 //            }
 //
 //        }
 //
 //
 //
 //
 //
 //
 //        let param : [String : Any] =
 //        [
 //
 //            "institiuteId": instituteId!,
 //            "attendance_month" : YearLbl,
 //            "userId"    : staffId!
 //
 //
 //        ]
 //
 //
 //
 //
 //        let param1 : [String : Any] =
 //        [
 //
 //            "institiuteId": instituteId!,
 //            "attendance_dt" : YearLbl,
 //
 //
 //
 //        ]
 //
 //
 //
 //
 //        if RefId == 1{
 //
 //            print("paramparam1",param1)
 //
 //            GetAttendanceHistroyReq.call_request(param: param1){ [self]
 //                (res) in
 //
 //                print("resres",res)
 //                let getattendace : GethistoryModal = Mapper<GethistoryModal>().map(JSONString: res)!
 //
 //
 //                if getattendace.status == 1  {
 //                    tv.isHidden = false
 //
 //                    getHistorydata = getattendace.data
 //                    searchtodayHistiry = getattendace.data
 //                    noRecordLbl.isHidden = true
 //                    tv.dataSource = self
 //                    tv.delegate = self
 //                    tv.reloadData()
 //
 //
 //
 //                }else{
 //                    tv.isHidden = true
 //                    noRecordLbl.isHidden = false
 //
 //                    noRecordLbl.text = getattendace.message
 //
 //
 //                }
 //            }
 //        }
 //
 //        else if RefId == 2 {
 //            print("paramparam",param)
 //            GetAttendanceHistroyReq.call_request(param: param){ [self]
 //                (res) in
 //
 //                print("resres",res)
 //                let getattendace : GethistoryModal = Mapper<GethistoryModal>().map(JSONString: res)!
 
 //
 //
 //                if getattendace.status == 1  {
 //                    tv.isHidden = false
 //
 //                    getHistorydata = getattendace.data
 //                    noRecordLbl.isHidden = true
 //                    tv.dataSource = self
 //                    tv.delegate = self
 //                    tv.reloadData()
 //
 //
 //
 //                }else{
 //                    tv.isHidden = true
 //                    noRecordLbl.isHidden = false
 //
 //                    noRecordLbl.text = getattendace.message
 //
 //
 //                }
 //            }
 //        }
 //
 //    }
 
 
 //    func staffList(){
 //
 //
 //
 //        let param : [String : Any] =
 //        [
 //
 //            "instituteId": instituteId!
 //
 //
 //
 //        ]
 //
 //        print("paramparam",param)
 //
 //        staffListRequests.call_request(param: param){ [self]
 //            (res) in
 //
 //            print("resres",res)
 //            let getattendace : staffListModal = Mapper<staffListModal>().map(JSONString: res)!
 //
 //
 //            if getattendace.status == 1  {
 //                stafflistdata = getattendace.data
 //                stafNameLbl.text = stafflistdata[0].staffName
 //                staffId = stafflistdata[0].staffId
 //
 //            }else{
 //
 //
 //            }
 //        }
 //
 //
 //    }
 
 
 
 
 //    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
 //
 //
 //
 //
 //
 //
 //            filtered_list = Mapper<GetHirstorydatadetails>().mapArray(JSONString: searchtodayHistiry.toJSONString()!)!
 //
 //
 //
 //
 //
 //
 //            if !searchText.isEmpty{
 //
 //                getHistorydata = filtered_list.filter {
 //
 //
 //
 //                    $0.staffName.lowercased().contains(searchText.lowercased())
 //                    //
 //                }
 //
 //
 //
 //            }else{
 //
 //
 //                getHistorydata = filtered_list
 //
 //                print("pendingOrder")
 //
 //            }
 //
 //
 //
 //            if getHistorydata.count > 0{
 //
 //                print ("searchListPendigCount",getHistorydata.count)
 //
 //                noRecordLbl.isHidden = true
 //
 //                tv.alpha = 1
 //
 //            }else{
 //                noRecordLbl.isHidden = false
 //                noRecordLbl.text = "No record found"
 //                tv.alpha = 0
 //
 //            }
 //
 //
 //
 //            tv.reloadData()
 //
 //
 //
 //
 //
 //
 //
 //
 //
 //
 //    }
 
 
 //MARK: Variable
 
 var getHistorydata  : [GetHirstorydatadetails] = []
 //    var searchtodayHistiry  : [GetHirstorydatadetails] = []
 //    var filtered_list  : [GetHirstorydatadetails] = []
 
 
 var stafflistdata : [ModaldataDetails] = []
 //MARK: CellFor
 
 let data : GetHirstorydatadetails = getHistorydata[indexPath.row]
 
 
 
 //        cell.namelbl.text = data.staffName
 
 //        cell.workingHrsLbl.text = "Working Hours - \(data.working_hours ?? "0")"
 
 //        let eventDate = data.date
 
 if let date = dateFormatter.date(from: eventDate!) {
 //
 //            dateFormatter.dateFormat = "EEEE"
 //            let formattedDate1 = dateFormatter.string(from: date)
 //
 //            dateFormatter.dateFormat = "MMM"
 //            let formattedDate2 = dateFormatter.string(from: date)
 //
 //            dateFormatter.dateFormat = "d"
 //            let formattedDate = dateFormatter.string(from: date)
 //
 //            cell.dayLbl.text =  formattedDate1
 //            cell.datelbl.text = formattedDate
 //            cell.mnthLbl.text =  formattedDate2
 //
 //            print(formattedDate)
 //        } else {
 //            print("Invalid date format")
 //        } // date converstion End
 
 
 //        if data.leave_type == "Absent"{
 //
 //            cell.StatusLbl.text = data.leave_type
 //            cell.StatusLbl.backgroundColor = .red
 //
 //            cell.attendanceTypeLbl.text = data.attendance_type
 //
 //
 //        }else{
 //            cell.namelbl.text = data.staffName
 //
 //            cell.StatusLbl.backgroundColor  = UIColor(named: "presentGreen")
 //            cell.attendanceTypeLbl.text = data.attendance_type
 //            cell.StatusLbl.text = data.leave_type
 //
 //
 //        }
 
 
 cell.firstInLbl.text =  "First in - \(data.in_time ?? "0")"
 //        if data.in_time ?? "" == "" {
 //            cell.firstInLbl.isHidden = true
 //        }
 //
 //        cell.namelbl.text = data.staffName
 //        if data.working_hours ?? "" == "" {
 //            cell.workingHrsLbl.isHidden = true
 //        }
 //        cell.toDateLbl.text = "Last out - \(data.out_time ?? "0")"
 //        if data.out_time ?? "" == "" {
 //            cell.toDateLbl.isHidden = true
 //        }
 //        cell.attendanceTypeLbl.text = data.attendance_type
 //        cell.namelbl.text =
 //            data.staffName
 //
 //
 //        let click = ShowPunchHistiryClick(target: self, action: #selector(ShowHistory))
 //        click.date = data.date
 //        click.staffId = data.staffId
 //
 //        cell.fullView.addGestureRecognizer(click)
 
 
 
 
 //MARK: Func staffDropDownList
 stafflistdata.forEach {(arrType)  in
 ////            StaffId.append((arrType.staffId))
 //            staffName.append(arrType.staffName)
 //
 //        }
 //        let myArray = stafflistdata[1].staffName
 
 AttendaceHistory()
 
 
 //MARK: selectMonthViewClick
 
 AttendaceHistory()
 
 
 //MARK: allStaffVIew
 AttendaceHistory()
 
 
 //MARK: todayView
 dateFormatter.dateFormat = "MMM d, yyyy"
 
 AttendaceHistory()
 
 //MARK: selectYearsViewClick inside if condition
 
 
 //            RPicker.selectDate(title: "Select Date", cancelText: "Cancel", datePickerMode: .date, style: .Inline, didSelectDate: {[weak self] (today_date) in
 
 
 
 //                self?.display_date = today_date.dateString("dd/MM/yyyy")
 //
 //                self?.url_date = today_date.dateString("yyyy/MM/dd")
 //
 //                self?.yearLbl.text = self!.display_date
 //
 //            })
 
 
 inside else{
 AttendaceHistory()
 
 */

struct Attendance {
    var staffName: String
    var dayType: String // "Half Day" or "Full Day"
    var status: String // "Present" or "Absent"
    var firstIn: String // Time format "HH:mm"
    var lastOut: String // Time format "HH:mm"
    var workingHours: String // Total working hours
    
}
