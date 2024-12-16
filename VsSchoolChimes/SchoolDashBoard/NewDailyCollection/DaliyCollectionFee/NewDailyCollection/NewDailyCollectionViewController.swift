//
//  NewDailyCollectionViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 22/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import DropDown
//import ObjectMapper

class NewDailyCollectionViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var caleView: UIView!
    @IBOutlet weak var dateViewHeight: NSLayoutConstraint!
    @IBOutlet weak var todateLbl: UILabel!
    @IBOutlet weak var dropDownLbl: UILabel!
    @IBOutlet weak var AcadamidropDown: UIViewX!
    @IBOutlet weak var TodateView: UIViewX!
    @IBOutlet weak var categoryWiseView: UIView!
    @IBOutlet weak var norecordLbl: UILabel!
    @IBOutlet weak var classWiseView: UIView!
    @IBOutlet weak var calendarView: UIViewX!
    @IBOutlet weak var modeView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var fromLbl: UILabel!
    
    var url_time : String!
    var url_hours : String!
    var url_minutes : String!
    var display_date : String!
    var url_date : String!
    let dropDown = DropDown()
    var indexList : Int!
    var ClickId = "1"
    let currentDateTime = Date()
    var currentdate : String!
    var SchoolId : String!
    var type : Int!
    var DropDownStr : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        norecordLbl.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        let formattedDateTime = dateFormatter.string(from: currentDateTime)
        currentdate = formattedDateTime
        fromLbl.text = formattedDateTime
        todateLbl.text = formattedDateTime
        tv.isHidden = true
        dropDownLbl.textColor = .lightGray
        tv.dataSource = self
        tv.delegate = self
        tv.register(UINib(nibName: CellConfingName.PendingFeeReportTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.PendingFeeReportTableViewCell)
        tv.register(UINib(nibName: CellConfingName.PaymentListTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.PaymentListTableViewCell)
        tv.register(UINib(nibName: "DataCollectionTvHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "DataCollectionTvHeaderView")
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVC))
        backView.addGestureRecognizer(backGesture)
        caleView.isHidden = true
        
        let classWiseGuesture = UITapGestureRecognizer(target: self, action: #selector(classAction))
        classWiseView.addGestureRecognizer(classWiseGuesture)
        
        AcadamidropDown.isHidden = true
        
        let dropdown = UITapGestureRecognizer(target: self, action: #selector( DropDownVc))
        AcadamidropDown.addGestureRecognizer(dropdown)
        
        let modeGuesture = UITapGestureRecognizer(target: self, action: #selector(modeAction))
        modeView.addGestureRecognizer(modeGuesture)
        
        let categoryGuesture = UITapGestureRecognizer(target: self, action: #selector(categoryAction))
        categoryWiseView.addGestureRecognizer(categoryGuesture)
        
        dashBoardList()
        
    }
    
    @IBAction func DropDownVc(){
        let acadamicYear = DropDownStr
        dropDown.dataSource = acadamicYear //4
        dropDown.anchorView = AcadamidropDown //5
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        dropDown.selectionAction = { [unowned self] (index:Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.dropDownLbl.text = item
            dropDownLbl.textColor = .black
            
        }
    }
    
    func dashBoardList() {
        
        var todate : String!
        var fromdate : String!
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "MMM dd,yyyy"
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = fromLbl.text
        if let date = inputDateFormatter.date(from: dateString!) {
            let outputDateString = outputDateFormatter.string(from: date)
            fromdate = outputDateString
            print(outputDateString)
        } else {
            print("Invalid date format")
        }
        let inputDateFormatter1 = DateFormatter()
        inputDateFormatter1.dateFormat = "MMM dd,yyyy"
        let outputDateFormatter1 = DateFormatter()
        outputDateFormatter1.dateFormat = "yyyy-MM-dd"
        let dateString1 = todateLbl.text
        if let date1 = inputDateFormatter.date(from: dateString1!) {
            let outputDateString1 = outputDateFormatter1.string(from: date1)
            print(outputDateString1)
            todate = outputDateString1
        } else {
            print("Invalid date format")
        }
        
    }
    
    func SectionWise () {
        
        var todate : String!
        var fromdate : String!
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "MMM dd,yyyy"
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateString = fromLbl.text
        
        if let date = inputDateFormatter.date(from: dateString!) {
            let outputDateString = outputDateFormatter.string(from: date)
            fromdate = outputDateString
            print(outputDateString)
        } else {
            print("Invalid date format")
        }
        
        let inputDateFormatter1 = DateFormatter()
        inputDateFormatter1.dateFormat = "MMM dd,yyyy"
        
        let outputDateFormatter1 = DateFormatter()
        outputDateFormatter1.dateFormat = "yyyy-MM-dd"
        
        let dateString1 = todateLbl.text
        
        if let date1 = inputDateFormatter.date(from: dateString1!) {
            let outputDateString1 = outputDateFormatter1.string(from: date1)
            print(outputDateString1)
            todate = outputDateString1
        } else {
            print("Invalid date format")
        }
    }
    
    @IBAction func categoryAction() {
        ClickId = "1"
        dateViewHeight.constant = 70
        calendarView.isHidden = false
        TodateView.isHidden = false
        tv.isHidden = true
        classWiseView.backgroundColor = .lightGray
        modeView.backgroundColor = .lightGray
        categoryWiseView.backgroundColor = UIColor(named: "CustomOrange")
        ClickId = "1"
        dashBoardList()
    }
    
    @IBAction func classAction() {
        ClickId = "2"
        dateViewHeight.constant = 70
        calendarView.isHidden = false
        TodateView.isHidden = false
        tv.isHidden = true
        categoryWiseView.backgroundColor = .lightGray
        modeView.backgroundColor = .lightGray
        categoryWiseView.backgroundColor = .lightGray
        classWiseView.backgroundColor = UIColor(named: "CustomOrange")
    }
    
    @IBAction func modeAction() {
        dateViewHeight.constant = 70
        calendarView.isHidden = false
        TodateView.isHidden = false
        ClickId = "0"
        PaymentMode()
        tv.isHidden = true
        categoryWiseView.backgroundColor = .lightGray
        modeView.backgroundColor = UIColor(named: "CustomOrange")
        classWiseView.backgroundColor = .lightGray
    }
    
    @IBAction func backVC() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ClickId == "1" || ClickId == "2"{
            return 5
        }
        else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ClickId == "1" || ClickId == "2"{
            let cell =  tableView.dequeueReusableCell(withIdentifier: CellConfingName.PendingFeeReportTableViewCell, for: indexPath) as!   PendingFeeReportTableViewCell
            cell.numberLbl.text = String(indexPath.row+1)
            return cell
        }else{
            let cell =  tableView.dequeueReusableCell(withIdentifier: CellConfingName.PendingFeeReportTableViewCell, for: indexPath) as!   PendingFeeReportTableViewCell
            return cell
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if ClickId == "1" || ClickId == "2"{
            return 3
        }
        else{
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DataCollectionTvHeaderView") as! DataCollectionTvHeaderView
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func toDateAction(){
        caleView.isHidden = false
        let dateFormater: DateFormatter = DateFormatter()
        dateFormater.dateFormat = "MMM dd,yyyy"
        let currentDate = fromLbl.text
        let date = dateFormater.date(from:currentDate!)!
        var dt : Date!
        dt = date
        datePicker.maximumDate = Date()
        datePicker.minimumDate = dt
        let selectedDate = dateFormater.string(from: datePicker.date)
        print("selectedDate",selectedDate)
        todateLbl.text = selectedDate
    }
    
    @IBAction func dateAct(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        let somedateString = dateFormatter.string(from: sender.date)
        datePicker.maximumDate = Date()
        todateLbl.text = somedateString
        print(somedateString)
    }
    
    func PaymentMode () {
        print("homePagedashBoardList")
        var todate : String!
        var fromdate : String!
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "MMM dd,yyyy"
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = fromLbl.text
        if let date = inputDateFormatter.date(from: dateString!) {
            let outputDateString = outputDateFormatter.string(from: date)
            fromdate = outputDateString
            print(outputDateString)
        } else {
            print("Invalid date format")
        }
        let inputDateFormatter1 = DateFormatter()
        inputDateFormatter1.dateFormat = "MMM dd,yyyy"
        let outputDateFormatter1 = DateFormatter()
        outputDateFormatter1.dateFormat = "yyyy-MM-dd"
        let dateString1 = todateLbl.text
        if let date1 = inputDateFormatter.date(from: dateString1!) {
            let outputDateString1 = outputDateFormatter1.string(from: date1)
            print(outputDateString1)
            todate = outputDateString1
        } else {
            print("Invalid date format")
        }
    }
    
    @IBAction func doneAction(_ sender: UIButton) {
        if  ClickId == "1"{
            dashBoardList()
        }
        else if ClickId == "2"{
            SectionWise()
        }
        else if ClickId == "0"{
            PaymentMode()
        }
    }
    
    @IBAction func doneActionCale(_ sender: Any) {
        caleView.isHidden = true
        if  ClickId == "1"{
            dashBoardList()
        }
        else if ClickId == "2"{
            SectionWise()
        }
        else if ClickId == "0"{
            PaymentMode()
        }
        
    }
    
}



/*
 
 
 
 //MARK: var declared
 
 //    var PaidFeesRes : paidFeeResp!
 //    var paymentmodHeader : [PaiddataDetails] = []
 //    var pendingdata : [PendiRespdatadetails] = []
 //    var paymentMode : [CategoryDataList] = []
 //    var subpendingdata  : [pendingDataDetails] = []
 
 //    var acdmicYearRef : [AcdmicYrDataDetails] = []
 
 
 
 //MARK: viewdidLoad
 
 
 let userDefaults = UserDefaults.standard
 print("Schooltype",type)
 if type == 1 {
 
 
 print("SchoolId",SchoolId)
 }else{
 //        StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)
 //            SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
 }
 
 
 //        dropDownLbl.text = "--Select academy year--"
 
 
 let FromDateGuesture = UITapGestureRecognizer(target: self, action: #selector(FromDateAction))
 //        calendarView.addGestureRecognizer(FromDateGuesture)
 //        let toDateGuesture = UITapGestureRecognizer(target: self, action: #selector(toDateAction))
 //        TodateView.addGestureRecognizer(toDateGuesture)
 //
 
 
 
 //MARK: DropDownVc
 
 
 
 //            for i in acdmicYearRef{
 //
 //                if i.yearName == dropDownLbl.text{
 //                    if  ClickId == "1"{
 //
 //                        dashBoardList()
 //                    }
 //                    else if ClickId == "2"{
 //
 //                        SectionWise()
 //
 //
 //                    }
 //                    else if ClickId == "0"{
 //
 //                        PaymentMode()
 //                    }
 //                }
 //            }
 
 
 //MARK: SectionWise
 
 
 //
 //        let pending = DailypendingModal()
 //        pending.instituteId = SchoolId
 //        pending.type = 2
 //        pending.fromDate = fromdate
 //        pending.toDate = todate
 //
 //
 //
 //        let pendingStr = pending.toJSONString()
 //
 //        print("dashBoarddashBoard",pending.toJSON())
 //
 //        StanderedReqsts.call_request(param: pendingStr!) {
 //            [self]
 //            (res) in
 //
 //
 //            print("PendingReqsts",PendingReqsts.self)
 //
 //
 //            let pendingResponse : pendingResp = Mapper<pendingResp>().map(JSONString: res)!
 //
 //
 //
 //            if pendingResponse.Status == 1 {
 //
 //                pendingdata = pendingResponse.data
 //
 //
 //                norecordLbl.isHidden = true
 //                tv.isHidden = false
 //                tv.dataSource = self
 //                tv.delegate = self
 //                tv.reloadData()
 //            }else{
 //
 //
 //                norecordLbl.isHidden = false
 //
 //                tv.isHidden = true
 //                norecordLbl.text = pendingResponse.Message
 //
 //
 //
 //            }
 //
 //
 //
 //
 //        }
 //
 
 
 //MARK: dashBoardList
 
 
 //        let pending = DailypendingModal()
 //        pending.instituteId = SchoolId
 //        pending.type = 1
 //
 //        pending.fromDate = fromdate
 //        pending.toDate = todate
 //
 //
 //
 //        let pendingStr = pending.toJSONString()
 //
 //        print("dashBoarddashBoard",pending.toJSON())
 //
 //        DailyReqsts.call_request(param: pendingStr!) {
 //            [self]
 //            (res) in
 //
 //
 //            print("PendingReqsts",PendingReqsts.self)
 //
 //
 //            let pendingResponse : pendingResp = Mapper<pendingResp>().map(JSONString: res)!
 //
 //
 //
 //            if pendingResponse.Status == 1 {
 //
 //                pendingdata = pendingResponse.data
 //
 //
 //
 //                norecordLbl.isHidden = true
 //
 //                tv.isHidden = false
 //                tv.dataSource = self
 //                tv.delegate = self
 //                tv.reloadData()
 //            }else{
 //
 //
 //                norecordLbl.isHidden = false
 //
 //                tv.isHidden = true
 //                norecordLbl.text = pendingResponse.Message
 //
 //
 //            }
 //
 //
 //
 //
 //        }
 
 //MARK: cellForRowAt
 
 //        let datas : pendingDataDetails = subpendingdata[indexPath.row]
 
 
 //            if ClickId == "1"{
 //                cell.classLbl.text = pendingdata[indexPath.section].data[indexPath.row].TypeName
 //            }
 //            else if ClickId == "2"{
 //
 //                cell.classLbl.text = pendingdata[indexPath.section].data[indexPath.row].TypeName
 //            }
 //
 //
 //            if pendingdata[indexPath.section].data[indexPath.row].amount == nil{
 //                cell.amountLbl.text = "0.0"
 //
 //            }else{
 //                cell.amountLbl.text = "₹" + pendingdata[indexPath.section].data[indexPath.row].amount
 //            }
 //
 
 
 
 
 //MARK: Inside else
 
 let payment : CategoryDataList = paymentMode[indexPath.row]
 //            if payment.amount == nil{
 //                cell.amountLbl.text = "0.0"
 //            }else{
 //
 //
 //                cell.amountLbl.text = "₹" + payment.amount
 //
 //            }
 //            //            cell.amountLbl.text = String(payment.Amount)
 //
 //            cell.classLbl.text = payment.TypeName
 //
 
 
 
 //MARK:viewForHeaderInSection
 
 if ClickId == "1" ||  ClickId == "2"{
 //            let datas : PendiRespdatadetails = pendingdata[section]
 //
 //            if ClickId == "1"{
 //                headerView.isHidden = false
 //                headerView.classLbl.text = datas.Category
 //            }
 //            else if ClickId == "2"{
 //                headerView.isHidden = false
 //                headerView.classLbl.text = datas.Category
 //
 //            }
 //
 //
 //
 //            if datas.total == nil{
 //                headerView.amountLbl.text = "0.0"
 //
 //            }else{
 //                headerView.amountLbl.text = "₹" + datas.total
 //            }
 //
 //
 
 }
 
 else{
 //            let datas : PaiddataDetails = paymentmodHeader[section]
 
 //            headerView.classLbl.text = datas.Category
 //            if datas.total == nil{
 //                headerView.amountLbl.text = "0.0"
 //
 //            }else{
 //                headerView.amountLbl.text = "₹" + datas.total
 //            }
 //
 
 //MARK: FromDateAction
 
 
 //    @IBAction func FromDateAction(){
 //
 //        var todaysDate = NSDate()
 //
 //
 //        RPicker.selectDate(title: "Select Date", cancelText: "Cancel", datePickerMode: .date,style: .Inline, didSelectDate: {[weak self] (today_date) in
 //
 //            self?.display_date = today_date.dateString("MMM dd,yyyy")
 //            self?.url_date = today_date.dateString("yyyy-MM-dd")
 //            self?.fromLbl.text = self!.display_date
 //
 //            if  self!.ClickId == "1"{
 //
 //                self!.dashBoardList()
 //            }
 //            else if self!.ClickId == "2"{
 //
 //                self!.SectionWise()
 //
 //
 //            }
 //            else if self!.ClickId == "0"{
 //
 //                self!.PaymentMode()
 //            }
 //        })
 //    }
 
 
 
 //MARK: PaymentMode
 
 
 //        let pending = paidFeeModal()
 //        pending.instituteId = SchoolId
 //        pending.type = 3
 //        pending.fromDate = fromdate
 //        pending.toDate = todate
 //
 //        let pendingStr = pending.toJSONString()
 //
 //        print("dashBoarddashBoard",pending.toJSON())
 //
 //
 //
 //        PayentModeReq.call_request(param: pendingStr!) {
 //            [self]
 //            (res) in
 //
 //
 //            print("PendingReqsts",PendingReqsts.self)
 //
 //
 //            let pendingResponse : paidFeeResp = Mapper<paidFeeResp>().map(JSONString: res)!
 //
 //
 //
 //            if pendingResponse.Status == 1 {
 //                for i in pendingResponse.data {
 //                    paymentMode = i.CategoryData
 //                }
 //                paymentmodHeader = pendingResponse.data
 //
 //
 //                norecordLbl.isHidden = true
 
 //                tv.isHidden = false
 //                tv.dataSource = self
 //                tv.delegate = self
 //                tv.reloadData()
 //            }else{
 //
 //
 //                tv.isHidden = true
 //                norecordLbl.isHidden = false
 //                norecordLbl.text = pendingResponse.Message
 //
 //            }
 //
 //
 //
 //
 //
 //        }
 
 
 
 //    func  AcdimyYear(){
 //
 //
 //        let param : [String : Any] =
 //
 //
 //
 //        [
 //
 //            "institute_id" : Int(SchoolId!)
 //
 //
 //
 //        ]
 //
 //
 //        print("param",param)
 //
 //
 //
 //        AcdmicYearRequest.call_request(param: param)  {
 //
 //
 //
 //
 //            [self] (res) in
 //
 //
 //            let acdmy : acidmicYrResponce = Mapper<acidmicYrResponce>().map(JSONString: res)!
 //
 //
 //            if acdmy.Status == 1{
 //
 //                for i in acdmy.data{
 //
 //
 //                    if i.currentAcademicYear == 1{
 //
 //                        dropDownLbl.text = i.yearName
 //
 //
 //                        if  ClickId == "1"{
 //
 //                            dashBoardList()
 //                        }
 //                        else if ClickId == "2"{
 //
 //                            SectionWise()
 //
 //
 //                        }
 //
 //
 //
 //
 //                        if let index = acdmy.data.firstIndex(where: { $0.currentAcademicYear == 1 }) {
 //                            // Remove the item from its current position
 //                            let item = acdmy.data.remove(at: index)
 //                            // Insert the item at the first position
 //                            acdmy.data.insert(item, at: 0)
 //
 //                            acdmicYearRef = acdmy.data
 //                        }
 //
 //
 //                    }
 //
 //
 //                }
 //
 //
 //                for i in acdmicYearRef{
 //
 //                    DropDownStr.append(i.yearName)
 //                }
 //
 //
 //            }
 //
 //            else {
 //
 //
 //
 //
 //            }
 //
 //        }
 //
 //
 //    }
 
 
 */
