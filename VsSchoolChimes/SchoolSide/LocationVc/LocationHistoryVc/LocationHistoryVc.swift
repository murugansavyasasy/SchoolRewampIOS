//
//  LocationHistoryVc.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 04/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import ObjectMapper
import DropDown
class LocationHistoryVc: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
   
    @IBOutlet weak var seachHeight: NSLayoutConstraint!
    @IBOutlet weak var todayDefaultLbl: UILabel!
    @IBOutlet weak var staffWiseDefaultLbl: UILabel!
    @IBOutlet weak var selectYrHeight: NSLayoutConstraint!
    @IBOutlet weak var selctStaffHeight: NSLayoutConstraint!
    @IBOutlet weak var noRecordLbl: UILabel!
    
    @IBOutlet weak var backView: UIView!
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
    var stafflistdata : [ModaldataDetails] = []
    var display_date : String!
    var dropDown  = DropDown()
    var getHistorydata  : [GetHirstorydatadetails] = []
    var searchtodayHistiry  : [GetHirstorydatadetails] = []
    var filtered_list  : [GetHirstorydatadetails] = []
    
    
    var years: [String] = []
   
    var monthNames: [String] = []
    let currentYear = Calendar.current.component(.year, from: Date())
    // DateFormatter to get the month names
    let dateFormatter = DateFormatter()
    var RefId = 1
    var url_date : String!
    var TvIdentfier = "LocationTableViewCell"
    var dateAndMoth : String!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        noRecordLbl.isHidden = true
        yearsView.isHidden = true
        monthView.isHidden = true
        searchbar.delegate = self
        staffDropViewHeight.constant = 0
        selectYrHeight.constant = 0
        selctStaffHeight.constant = 0
        staffDefaultsLbl.isHidden = true
        
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM d, yyyy"
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
            
            
            instituteId = userDefaults.integer(forKey: DefaultsKeys.SchoolD)
            staffId = userDefaults.integer(forKey: DefaultsKeys.StaffID)        }
       
        
        
        staffList()
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
        
   
        let rowNib = UINib(nibName: TvIdentfier, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: TvIdentfier)
        
       
        let today = UITapGestureRecognizer(target: self, action: #selector(todayView))
        todayStaffView.addGestureRecognizer(today) 
        let back = UITapGestureRecognizer(target: self, action: #selector(backClick))
        backView.addGestureRecognizer(back)
        let allStaff = UITapGestureRecognizer(target: self, action: #selector(allStaffVIew))
        allsatffView.addGestureRecognizer(allStaff)
         let seletYrs = UITapGestureRecognizer(target: self, action: #selector(selectYearsViewClick))
        yearsView.addGestureRecognizer(seletYrs)
         let selectMonth = UITapGestureRecognizer(target: self, action: #selector(selectMonthViewClick))
        monthView.addGestureRecognizer(selectMonth)
        
        let StaffDrop = UITapGestureRecognizer(target: self, action: #selector(staffDropDownList))
       staffDropView.addGestureRecognizer(StaffDrop)
       
        AttendaceHistory()
        
        
    }

    @IBAction func backClick(){
        dismiss(animated: true)
    }
    @IBAction func todayView(){
        
        seachHeight.constant = 56
        tv.isHidden = true
            
            todayStaffView.backgroundColor = UIColor(named: "CustomOrange")
       
        allsatffView.backgroundColor = .white
        staffWiseDefaultLbl.textColor = .black
        todayDefaultLbl.textColor = .white
        
        monthView.isHidden = true
        yearsView.isHidden = true
        staffDropViewHeight.constant = 0
        selectYrHeight.constant = 0
        selctStaffHeight.constant = 0
        staffDefaultsLbl.isHidden = true
        
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: currentDate)
        print(formattedDate) // Example output: "Mo
        display_date = formattedDate
        noRecordLbl.isHidden = true
        AttendaceHistory()
        RefId = 1
        
     
    }
    
    @IBAction func allStaffVIew(){
        seachHeight.constant = 0
        noRecordLbl.isHidden = true
        allsatffView.backgroundColor = UIColor(named: "CustomOrange")
      
      
        
        todayStaffView.backgroundColor = .white
        staffWiseDefaultLbl.textColor = .white
        todayDefaultLbl.textColor = .black
        RefId = 2
        monthView.isHidden = false
        yearsView.isHidden = false
        staffDropViewHeight.constant = 137
        selectYrHeight.constant = 30
        selctStaffHeight.constant = 38
        staffDefaultsLbl.isHidden = false
        tv.isHidden = true
        dateAndMoth = ""
        
       
     AttendaceHistory()
        
        
        
    }
    
    
    @IBAction func selectYearsViewClick(){
        
        
        if RefId == 1{
            
            RPicker.selectDate(title: "Select Date", cancelText: "Cancel", datePickerMode: .date, style: .Inline, didSelectDate: {[weak self] (today_date) in
                
                
                
                self?.display_date = today_date.dateString("dd/MM/yyyy")
                
                self?.url_date = today_date.dateString("yyyy/MM/dd")
                
                self?.yearLbl.text = self!.display_date
                
            })
            
        }else{
            
            let myArray = years
            
            dropDown.dataSource = myArray//4
            dropDown.anchorView = yearsView //5
            
            dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
            
            dropDown.direction = .bottom
            DropDown.appearance().backgroundColor = UIColor.white
            dropDown.show() //7
            
            
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                
                yearLbl.text = item
                
              
                
                AttendaceHistory()
                
            }
            
        }
        
    }
    
    @IBAction func selectMonthViewClick(){
        
        
        let myArray = monthNames
        
        dropDown.dataSource = myArray//4
        dropDown.anchorView = monthView //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
          
            
            selectMthLbl.text = item
            
            AttendaceHistory()
        }
        
        
    }

    @IBAction func staffDropDownList(){
        
        var StaffId: [Int] = []
        var staffName: [String] = []
        
        
        stafflistdata.forEach {(arrType)  in
            StaffId.append((arrType.staffId))
            staffName.append(arrType.staffName)
            
        }
//        let myArray = stafflistdata[1].staffName
        
        dropDown.dataSource = staffName//4
        dropDown.anchorView = staffDropView //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
          
              staffId = StaffId[index]
            
            
            stafNameLbl.text = item
            
            AttendaceHistory()
            
        }
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return getHistorydata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TvIdentfier, for: indexPath) as!
        LocationTableViewCell
        
        cell.selectionStyle = .none
        let data : GetHirstorydatadetails = getHistorydata[indexPath.row]
        
        
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
       
        
        cell.namelbl.text = data.staffName
        
        cell.workingHrsLbl.text = "Working Hours - \(data.working_hours ?? "0")"
        
        let eventDate = data.date
        
        cell.StatusLbl.layer.cornerRadius = 5
        cell.StatusLbl.layer.masksToBounds = true
        
        let dateFormatter = DateFormatter()
        // Input format
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if let date = dateFormatter.date(from: eventDate!) {
            
            dateFormatter.dateFormat = "EEEE"
            let formattedDate1 = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "MMM"
            let formattedDate2 = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "d"
            let formattedDate = dateFormatter.string(from: date)
            
            cell.dayLbl.text =  formattedDate1
            cell.datelbl.text = formattedDate
            cell.mnthLbl.text =  formattedDate2
            
            print(formattedDate)
        } else {
            print("Invalid date format")
        } // date converstion End
        
        
        
        
        if data.leave_type == "Absent"{
            
            cell.StatusLbl.text = data.leave_type
            cell.StatusLbl.backgroundColor = .red
            
            cell.attendanceTypeLbl.text = data.attendance_type
            
            
        }else{
            cell.namelbl.text = data.staffName
            
            cell.StatusLbl.backgroundColor  = UIColor(named: "presentGreen")
            cell.attendanceTypeLbl.text = data.attendance_type
            cell.StatusLbl.text = data.leave_type
            
            
        }
        
        cell.firstInLbl.text =  "First in - \(data.in_time ?? "0")"
        if data.in_time ?? "" == "" {
            cell.firstInLbl.isHidden = true
        }
        
        cell.namelbl.text = data.staffName
        if data.working_hours ?? "" == "" {
            cell.workingHrsLbl.isHidden = true
        }
        cell.toDateLbl.text = "Last out - \(data.out_time ?? "0")"
        if data.out_time ?? "" == "" {
            cell.toDateLbl.isHidden = true
        }
        cell.attendanceTypeLbl.text = data.attendance_type
        cell.namelbl.text =
            data.staffName
    
        
        let click = ShowPunchHistiryClick(target: self, action: #selector(ShowHistory))
        click.date = data.date
        click.staffId = data.staffId
       
        cell.fullView.addGestureRecognizer(click)
        
        
        return cell
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
    
    
    func AttendaceHistory(){
        
        
        
        var YearLbl = ""
        
        
        if RefId == 1 {
            
            YearLbl = display_date
        }else if RefId == 2 {
            let year = yearLbl.text!
            let monthName = selectMthLbl.text!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM" // Full month name format

            if let date = dateFormatter.date(from: monthName) {
                let calendar = Calendar.current
                let monthNumber = calendar.component(.month, from: date)
                print("The month number for \(monthName) is \(monthNumber).")
                if  monthNumber == 1 || monthNumber == 2 || monthNumber == 3 || monthNumber == 4 || monthNumber == 5 || monthNumber == 6 || monthNumber == 7 || monthNumber == 8 || monthNumber == 9 {
                    YearLbl = year +  "-" + "0" + String(monthNumber)
                }else{
                    YearLbl = year +  "-"  + String(monthNumber)
                    
                }
            } else {
                print("Invalid month name.")
            }
            
        }
       

        
        
       
        
        let param : [String : Any] =
        [

            "institiuteId": instituteId!,
            "attendance_month" : YearLbl,
            "userId"    : staffId!
            

        ]
        
        
        
       
        let param1 : [String : Any] =
        [

            "institiuteId": instituteId!,
            "attendance_dt" : YearLbl,
           
            

        ]
        
 
        
        
        if RefId == 1{
            
            print("paramparam1",param1)
            
            GetAttendanceHistroyReq.call_request(param: param1){ [self]
                (res) in
                
                print("resres",res)
                let getattendace : GethistoryModal = Mapper<GethistoryModal>().map(JSONString: res)!
                
                
                if getattendace.status == 1  {
                    tv.isHidden = false
                    
                    getHistorydata = getattendace.data
                    searchtodayHistiry = getattendace.data
                    noRecordLbl.isHidden = true
                    tv.dataSource = self
                    tv.delegate = self
                    tv.reloadData()
                    
                    
                    
                }else{
                    tv.isHidden = true
                    noRecordLbl.isHidden = false
                    
                    noRecordLbl.text = getattendace.message
                    
                    
                }
            }
        }
        
        else if RefId == 2 {
            print("paramparam",param)
            GetAttendanceHistroyReq.call_request(param: param){ [self]
                (res) in
                
                print("resres",res)
                let getattendace : GethistoryModal = Mapper<GethistoryModal>().map(JSONString: res)!
                
                
                if getattendace.status == 1  {
                    tv.isHidden = false
                    
                    getHistorydata = getattendace.data
                    noRecordLbl.isHidden = true
                    tv.dataSource = self
                    tv.delegate = self
                    tv.reloadData()
                    
                    
                    
                }else{
                    tv.isHidden = true
                    noRecordLbl.isHidden = false
                    
                    noRecordLbl.text = getattendace.message
                    
                    
                }
            }
        }
        
    }
    
    func staffList(){
        
       
        
        let param : [String : Any] =
        [

            "instituteId": instituteId!
            
            

        ]

        print("paramparam",param)

        staffListRequests.call_request(param: param){ [self]
            (res) in

            print("resres",res)
            let getattendace : staffListModal = Mapper<staffListModal>().map(JSONString: res)!


            if getattendace.status == 1  {
                stafflistdata = getattendace.data
                stafNameLbl.text = stafflistdata[0].staffName
                staffId = stafflistdata[0].staffId
                
            }else{


            }
        }
        
        
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        
        
            
            
            filtered_list = Mapper<GetHirstorydatadetails>().mapArray(JSONString: searchtodayHistiry.toJSONString()!)!
            
            
            
            
            
            
            if !searchText.isEmpty{
                
                getHistorydata = filtered_list.filter {
                    
                    
                    
                    $0.staffName.lowercased().contains(searchText.lowercased())
                    //
                }
                
                
                
            }else{
                
               
                getHistorydata = filtered_list
                
                print("pendingOrder")
                
            }
            
            
            
            if getHistorydata.count > 0{
                
                print ("searchListPendigCount",getHistorydata.count)
                
                noRecordLbl.isHidden = true
                
                tv.alpha = 1
                
            }else{
                noRecordLbl.isHidden = false
                noRecordLbl.text = "No record found"
                tv.alpha = 0
                
            }
            
            
            
            tv.reloadData()
            
            
            
      
        
        
        
        
        
        
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        print("scrollViewWillBeginDragging")
        searchbar.endEditing(true)
        
    }



    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        searchbar.resignFirstResponder()
        
    }





    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        
      
            
            
            searchBar.resignFirstResponder()
            
            
            
            tv.alpha = 1
            
            AttendaceHistory()
            
            self.tv.reloadData()
       
        
      
    }
    
    
    
}

class ShowPunchHistiryClick : UITapGestureRecognizer{
    
    
    var  date : String!
    var staffId : Int!
}
