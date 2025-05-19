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
            daily_collectionApi(type: String(segmentName.selectedSegmentIndex+1))
        }else{
            todateLbl.text = date
            daily_collectionApi(type: String(segmentName.selectedSegmentIndex+1))
        }
    }
    
    @IBOutlet weak var segmentName: UISegmentedControl!
    @IBOutlet weak var Backbtn: UIButton!
    @IBOutlet weak var dateViewHeight: NSLayoutConstraint!
    @IBOutlet weak var todateLbl: UILabel!
    @IBOutlet weak var TodateView: UIView!
    @IBOutlet weak var norecordLbl: UILabel!
    @IBOutlet weak var calendarView: UIView!
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
    var DailyCollectionData: [DailyCollectionData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyShadowAndCornerRadius(to: calendarView)
        applyShadowAndCornerRadius(to: TodateView)
        Backbtn.applyBackButton()
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
        
        daily_collectionApi(type: "1")
        
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    
    
    @IBAction func segmentActBtn(_ sender: Any) {
        
        daily_collectionApi(type: String(segmentName.selectedSegmentIndex+1))
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
         return DailyCollectionData?.count ?? 0
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         let feeCount = DailyCollectionData?[section].fee_data?.count ?? 0
         if section == (DailyCollectionData?.count ?? 0) - 1, DailyCollectionData?[section].total_collection != nil {
             return feeCount + 1 // Add one for Total Collection
         }
         return feeCount
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let sectionData = DailyCollectionData?[indexPath.section]
         let feeData = sectionData?.fee_data ?? []

         if indexPath.section == (DailyCollectionData?.count ?? 0) - 1,
            indexPath.row == feeData.count,
            let total = sectionData?.total_collection {

             let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.PendingFeeReportTableViewCell, for: indexPath) as! PendingFeeReportTableViewCell
             cell.classLbl.isHidden = true
             cell.amountLbl.textAlignment = .right
             cell.amountLbl.text = "Total Collection : \(total)"
             cell.amountLbl.textColor = .button
             cell.amountLbl.font = UIFont.systemFont(ofSize: 14, weight: .bold)
             return cell
         }

         let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.PendingFeeReportTableViewCell, for: indexPath) as! PendingFeeReportTableViewCell
         cell.classLbl.isHidden = false
         cell.amountLbl.textColor = .black
         cell.amountLbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
         cell.classLbl.text = feeData[indexPath.row].type_name
         cell.amountLbl.text = feeData[indexPath.row].amount
         return cell
     }

     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         if DailyCollectionData?[section].category == nil,
            DailyCollectionData?[section].fee_data == nil,
            DailyCollectionData?[section].total_collection != nil {
             return nil
         }

         let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellConfingName.DataCollectionTvHeaderView) as! DataCollectionTvHeaderView
         headerView.classLbl.text = DailyCollectionData?[section].category
         headerView.amountLbl.text = DailyCollectionData?[section].total
         return headerView
     }

     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         if DailyCollectionData?[section].category == nil {
             return .leastNormalMagnitude // hides header completely
         }
         return UITableView.automaticDimension
     }

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableView.automaticDimension
     }

    
    func daily_collectionApi(type:String){
        
        let fromdate = ConvertDateStringSmart(fromLbl.text)
        let todate = ConvertDateStringSmart(todateLbl.text)
        APIService.shared
            .makeApi(url: ServiceUrl.api_fee_report_daily_collection , parameters: [
                
                Daily_collectionStringFile.from_date : fromdate,
                Daily_collectionStringFile.to_date : todate,
                Daily_collectionStringFile.type : type
                
            ], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <DailyCollectionResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            tv.isHidden = false
                            norecordLbl.isHidden = true
                            DailyCollectionData = successMessage.data ?? []
                            tv.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            tv.isHidden = true
                            norecordLbl.isHidden = false
                            norecordLbl.text = successMessage.message
                            DailyCollectionData = successMessage.data ?? []
                            tv.reloadData()
                        }
                       
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [self] in
                        tv.isHidden = true
                        norecordLbl.isHidden = false
                        norecordLbl.text = error.localizedDescription
                        print(error.localizedDescription)
                    }
                }
            }
    }
    
}

