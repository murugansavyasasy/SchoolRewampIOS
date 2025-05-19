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

@available(iOS 14.0, *)
class NewDailyCollectionViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, Datepicker {
   
    func date(date: String) {
        
        if dateSelection == true{
            fromLbl.text = date
        }else{
            todateLbl.text = date
        }
    }
    
    
    @IBOutlet weak var Backbtn: UIButton!
   
    @IBOutlet weak var dateViewHeight: NSLayoutConstraint!
    @IBOutlet weak var todateLbl: UILabel!
    @IBOutlet weak var TodateView: UIViewX!
   
    @IBOutlet weak var norecordLbl: UILabel!
   
    @IBOutlet weak var calendarView: UIViewX!
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
    var dateSelection = false
    
    // Example data for Feescategory
    let feesCategories = [
        Feescategory(category: "Tuition", amount: "5000"),
        Feescategory(category: "Library", amount: "300"),
        Feescategory(category: "Laboratory", amount: "700"),
        Feescategory(category: "Sports", amount: "400"),
        Feescategory(category: "Transportation", amount: "1000")
    ]

    // Example data for FeeMode
    let feeModes = [
        FeeMode(paymentMode: "Cash", amount: "2000"),
        FeeMode(paymentMode: "Credit Card", amount: "3000"),
        FeeMode(paymentMode: "Bank Transfer", amount: "1500"),
        FeeMode(paymentMode: "Online Payment", amount: "2500"),
        FeeMode(paymentMode: "Check", amount: "1200")
    ]

    var DailyCollectionData: [DailyCollectionData]?
    override func viewDidLoad() {
        super.viewDidLoad()
        Backbtn.applyBackButton()
  
//        categoryWiseView.applyGradient(
//            colors: [UIColor.blue,UIColor.systemTeal],
//            startPoint: CGPoint(x: 0, y: 0.5),
//            endPoint: CGPoint(x: 0.8, y: 0.5)
//        )
        
        norecordLbl.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"
        let formattedDateTime = dateFormatter.string(from: currentDateTime)
        currentdate = formattedDateTime
        fromLbl.text = formattedDateTime
        todateLbl.text = formattedDateTime
      
        tv.dataSource = self
        tv.delegate = self
        tv.register(UINib(nibName: CellConfingName.PendingFeeReportTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.PendingFeeReportTableViewCell)
        tv.register(UINib(nibName: CellConfingName.PaymentListTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.PaymentListTableViewCell)
        tv.register(UINib(nibName:CellConfingName.DataCollectionTvHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.DataCollectionTvHeaderView)

        let fromdateTap = UITapGestureRecognizer(target: self, action: #selector(SelectFromDate))
        calendarView.addGestureRecognizer(fromdateTap)
        
        let todateTap = UITapGestureRecognizer(target: self, action: #selector(SelectToDate))
        TodateView.addGestureRecognizer(todateTap)
        
        daily_collectionApi()
    
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    
   
    
    //MARK: Date Picker
    
    @IBAction func SelectFromDate(){
        dateSelection = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func SelectToDate(){
        dateSelection = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func backAct() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ClickId == "1" || ClickId == "2"{
            return DailyCollectionData?[section].fee_data?.count ?? 0
        }
        else{
            return DailyCollectionData?[section].fee_data?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ClickId == "1" || ClickId == "2"{
            let cell =  tableView.dequeueReusableCell(withIdentifier: CellConfingName.PendingFeeReportTableViewCell, for: indexPath) as!   PendingFeeReportTableViewCell
            cell.classLbl.text = DailyCollectionData?[indexPath.section]
                .fee_data?[indexPath.row].type_name
            cell.amountLbl.text = DailyCollectionData?[indexPath.section]
                .fee_data?[indexPath.row].amount
            return cell
        }else{
            let cell =  tableView.dequeueReusableCell(withIdentifier: CellConfingName.PendingFeeReportTableViewCell, for: indexPath) as!   PendingFeeReportTableViewCell
            cell.classLbl.text = feeModes[indexPath.row].paymentMode
            cell.amountLbl.text = feeModes[indexPath.row].amount
            return cell
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if ClickId == "1" || ClickId == "2"{
            return DailyCollectionData?.count ?? 0
        }
        else{
            return DailyCollectionData?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DataCollectionTvHeaderView") as! DataCollectionTvHeaderView
        
        if ClickId == "0"{
            headerView.classLbl.text = DailyCollectionData?[section].category
            headerView.amountLbl.text = DailyCollectionData?[section].total
        }else{
            headerView.classLbl.text = DailyCollectionData?[section].category
            headerView.amountLbl.text = DailyCollectionData?[section].total
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func daily_collectionApi(){
        
        let fromdate = ConvertDateStringSmart(fromLbl.text)
        let todate = ConvertDateStringSmart(todateLbl.text)
        APIService.shared
            .makeApi(url: ServiceUrl.api_fee_report_daily_collection , parameters: [
                
                Daily_collectionStringFile.from_date :fromdate,
                Daily_collectionStringFile.to_date : todate,
                Daily_collectionStringFile.type : ClickId
                
            ], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <DailyCollectionResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                           
                            DailyCollectionData = successMessage.data ?? []
                        }
                    }else{
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
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

struct Feescategory {
    
    var category : String
    var amount : String
}
struct FeeMode {
    var paymentMode : String
    var amount : String
}
