//
//  DaliyCollectionFeeViewController.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 15/03/23.
//  Copyright © 2023 Shenll-Mac-04. All rights reserved.
//

import UIKit
//import ObjectMapper

class DaliyCollectionFeeViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    
    
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var totalCollectedNameLbl: UILabel!
    @IBOutlet weak var totalCollectedPainAmountLbl: UILabel!
    @IBOutlet weak var getView: UIViewX!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var toDateView: UIViewX!
    @IBOutlet weak var fromDateView: UIViewX!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var toLbl: UILabel!
    
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//    var dailyCollectData : DailyCollectionData!
//    var paymentType : [PaymentTypeWise] = []
//    var previousYearFee : [PreviousYearFee] = []
//    var currentYearFee : [CurrentYearFee] = []
//    
    
    
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    var SchoolId  = String()
    var staffRole  = String()
    var display_time : String!
    var display_hours : String!
    var display_minutes : String!
    var url_time : String!
    var url_hours : String!
    var url_minutes : String!
    var display_date : String!
    var url_date : String!
    var indexList : Int!
    var getClickType : Int!
    var schoolType : String!
    let rowIdentifier = "DailyCollectionTableViewCell"
    let CurrentrowIdentifier = "DailyCollectionFeeCurrentTableViewCell"
    let paymentrowIdentifier = "DailyCollectionFeePaymentTypeTableViewCell"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let userDefaults = UserDefaults.standard
        if schoolType == "1" {
            
//            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
        }else{
//            SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
        }
        
        //
//        staffRole = userDefaults.string(forKey: DefaultsKeys.StaffRole)!
//        print("DefaultsKeys.staffRole",staffRole)
//        getDataList()
        
        let rowNib = UINib(nibName: rowIdentifier, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: rowIdentifier)
        
        
        let CurrentrowNib = UINib(nibName: CurrentrowIdentifier, bundle: nil)
        tv.register(CurrentrowNib, forCellReuseIdentifier: CurrentrowIdentifier)
        
        
        let paymentrowNib = UINib(nibName: paymentrowIdentifier, bundle: nil)
        tv.register(paymentrowNib, forCellReuseIdentifier: paymentrowIdentifier)
        
        tv.register(UINib(nibName: "DataCollectionTvHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "DataCollectionTvHeaderView")
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVC))
        backView.addGestureRecognizer(backGesture)
        
        let getListGesture = UITapGestureRecognizer(target: self, action: #selector(getClick))
        getView.addGestureRecognizer(getListGesture)
        
//        let FromDateGuesture = UITapGestureRecognizer(target: self, action: #selector(FromDateAction))
//        self.fromDateView.addGestureRecognizer(FromDateGuesture)
//        
//        
//        let ToDateGuesture = UITapGestureRecognizer(target: self, action: #selector(ToDateAction))
//        self.toDateView.addGestureRecognizer(ToDateGuesture)
        
        
    }
    
    
    
    @IBAction func backVC() {
        dismiss(animated: true)
    }
    
    @IBAction func getClick() {
        getClickType = 1
//        getDataList()
    }
    
    
    
//    func getDataList () {
//        let dataCollectionModal = DailyCollectionFeeModal()
//        
//        
//        var todaysDate = NSDate()
//        var dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        var DateInFormat = dateFormatter.string(from: todaysDate as Date)
//        
//        
//        var getToday = DateInFormat
//        
//        dataCollectionModal.schoolId = SchoolId
//        
//        
//        
//        if getClickType == 1 {
//            dataCollectionModal.toDate = toLbl.text
//            dataCollectionModal.fromDate = fromLbl.text
//            
//            fromLbl.text = fromLbl.text
//            toLbl.text = toLbl.text
//        }else {
//            dataCollectionModal.toDate = getToday
//            dataCollectionModal.fromDate =  getToday
//            
//            fromLbl.text = getToday
//            toLbl.text = getToday
//        }
//        
//        
//        print("toDate",toLbl.text!)
//        print("fromDate",fromLbl.text!)
//        
//        
//        let dataCollectionStr = dataCollectionModal.toJSONString()
//        
//        
//        print("dataCollectionStr",dataCollectionStr!)
//        
//        DailyCollectionFeeRequest.call_request(param: dataCollectionStr!) {
//            
//            [self] (res) in
//            
//            
//            
//            
//            let dataCollectionResponse : [DailyCollectionFeeResponse] = Mapper<DailyCollectionFeeResponse>().mapArray(JSONString : res)!
//            
//            
//            for i in dataCollectionResponse {
//                
//                if i.Status.elementsEqual("1") {
//                    
//                    
//                    dailyCollectData = i.collectioData
//                    totalCollectedNameLbl.text = dailyCollectData.totalCollected.name
//                    totalCollectedPainAmountLbl.text = dailyCollectData.totalCollected.paid_amount
//                    
//                    paymentType = dailyCollectData.paymentTypeWise
//                    previousYearFee = dailyCollectData.previousYearFee
//                    currentYearFee = dailyCollectData.currentYearFee
//                    
//                    print("paymentType.count1",paymentType.count)
//                    print("previousYearFee.count1",previousYearFee.count)
//                    print("currentYearFee.count1",currentYearFee.count)
//                    
//                    tv.dataSource = self
//                    tv.delegate = self
//                    
//                    alertView.isHidden = true
//                    alertLbl.isHidden = true
//                    tv.reloadData()
//                }else {
//                    
//                    alertView.isHidden = false
//                    alertLbl.isHidden = false
//                    alertLbl.text = i.Message
//                    
//                    
//                }
//                
//            }
//            
//            
//        }
//        
//        
//        
//        
//    }
    
    
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
        
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("paymentType.count",paymentType.count)
//        print("previousYearFee.count",previousYearFee.count)
//        print("currentYearFee.count",currentYearFee.count)
        
        
        if section == 0 {
            return 4
        }
        else if section == 1 {
            return 5
        }
        else{
            return 6
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        
        
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: rowIdentifier, for: indexPath) as!   DailyCollectionTableViewCell
        
        
        
        
//        if indexPath.section == 0{
//            
//            let payment : PaymentTypeWise = paymentType[indexPath.row]
//            print("payment.name",payment.name)
//            cell.amountLbl.text = payment.paid_amount
//            cell.nameLbl.text = payment.name
//        }
//        if indexPath.section == 1{
//            
//            let currentYear : CurrentYearFee = currentYearFee[indexPath.row]
//            cell.amountLbl.text = currentYear.paid_amount
//            cell.nameLbl.text = currentYear.name
//        }
//        if indexPath.section == 2{
//            
//            let previousyear : PreviousYearFee = previousYearFee[indexPath.row]
//            cell.amountLbl.text = previousyear.paid_amount
//            cell.nameLbl.text = previousyear.name
//            
//        }
        return cell
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DataCollectionTvHeaderView") as! DataCollectionTvHeaderView
        
        
        if section == 0 {
            indexList = 0
            headerView.dataTypeNameLbl.text =  "Payment Type"
        }
        else if section == 1 {
            indexList = 1
            headerView.dataTypeNameLbl.text =  "Current Year Fee"
        }
        else if section == 2{
//            print("previousYearFee.countHe",previousYearFee.count)
//            if previousYearFee.count == 0 {
//                headerView.isHidden = true
//            }else{
//                headerView.dataTypeNameLbl.text =  "Previous Year Fee"
//            }
        }
        
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 50
        }else if indexPath.row == 1{
            return 50
        }else if indexPath.row == 2{
            return 50
        }else{
            return 40
            
        }
    }
    
//    @IBAction func FromDateAction(){
//        
//        RPicker.selectDate(title: "Select Date", cancelText: "Cancel", datePickerMode: .date, style: .Inline, didSelectDate: {[weak self] (today_date) in
//            
//            self?.display_date = today_date.dateString("yyyy-M-dd")
//            self?.url_date = today_date.dateString("yyyy-M-dd")
//            self?.fromLbl.text = self!.display_date
//            
//        })
//    }
//    
//    
//    @IBAction func ToDateAction(){
//        RPicker.selectDate(title: "Select Date", cancelText: "Cancel", datePickerMode: .date, style: .Inline, didSelectDate: {[weak self] (today_date) in
//            
//            //            self.RPicker.m
//            
//            self?.display_date = today_date.dateString("yyyy-M-dd")
//            self?.url_date = today_date.dateString("yyyy-M-dd")
//            self?.toLbl.text = self!.display_date
//            
//        })
//        
//    }
}
