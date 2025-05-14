//
//  PendingFeeReportViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 22/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
//import ObjectMapper
import DropDown

class PendingFeeReportViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var switchReport: UISegmentedControl!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var noRecordsView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var acodemicView: UIView!
    @IBOutlet weak var acodemicdropView: UIView!
    @IBOutlet weak var acodomicYearLbl: UILabel!
    let dropDown = DropDown()
    var url_time : String!
    var url_hours : String!
    var url_minutes : String!
    var display_date : String!
    var url_date : String!
    var indexList : Int!
    var ClickId  = "1"
    var academicId:Int?
    var SchoolId  = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var DropDownStr : [String] = []
    var type : Int!
    let acidamicdrops = DropDown()
    var AcadimicYearDatas : [AcadimicYearData] = []
    var accadimYr :[String] = []
    var PendingReports :[PendingReportData]?
    var classWiseReport :[PendingReportData]?
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        getacadmicYr()
        DropDownStr = ["2012 - 2013","2014 - 2015","2016 - 2017","2018 - 2019"]
        applyShadowAndCornerRadius(to: acodemicView)
        let userDefaults = UserDefaults.standard
        
        nodataLbl.isHidden = true
        noRecordsView.isHidden = true
        if type == 1 {
        }else{
        }
//        tv.isHidden = true
        tv.register(UINib(nibName: CellConfingName.PendingFeeReportTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.PendingFeeReportTableViewCell)
        tv.register(UINib(nibName: CellConfingName.DataCollectionTvHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.DataCollectionTvHeaderView)
        tv.delegate = self
        tv.dataSource = self

    }
    func getacadmicYr(){
        APIService.shared
            .makeApi(url: ServiceUrl.comm_recipient_get_academic_year_list , parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <get_academic_yearSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            AcadimicYearDatas = successMessage.data ?? []
                            for i in 0..<(AcadimicYearDatas.count){
                                if AcadimicYearDatas[i].current_academic_year ?? false == true{
                                    acodomicYearLbl.text = AcadimicYearDatas[i].year
                                    academicId = AcadimicYearDatas[i].id
                                    
                                    getPendingReportAPI(academicId ?? 0)
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    func getPendingReportAPI(_ academic_year_id:Int){
        APIService.shared
            .makeApi(url: ServiceUrl.api_fee_report_detailed_pending_report , parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <PendingReportsResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            PendingReports = successMessage.data
                            tv.reloadData()
                        }
                    }else{
                        PendingReports = []
                        tv.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    func classPendingReportAPI(_ academic_year_id:Int){
        APIService.shared
            .makeApi(url: ServiceUrl.api_fee_report_detailed_class_wise_pending_report , parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <PendingReportsResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            PendingReports = successMessage.data
                            tv.reloadData()
                        }
                    }else{
                        PendingReports = []
                        tv.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    
    @IBAction func selectAcodemic(_ sender: UIButton) {
        accadimYr.removeAll()
        for i in 0..<(AcadimicYearDatas.count) {
            accadimYr.append(AcadimicYearDatas[i].year ?? "")
        }
        acidamicdrops.anchorView = acodemicdropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acodemicdropView.bounds.height)
        acidamicdrops.show()
        
        acidamicdrops.selectionAction = { [self] (index: Int, item: String) in
            acodomicYearLbl.text = item
            academicId = AcadimicYearDatas[index].id
            if switchReport.selectedSegmentIndex == 0{
                getPendingReportAPI(academicId ?? 0)
            }else{
                classPendingReportAPI(academicId ?? 0)
            }
        }
    }
    
    @IBAction func switchTab(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            getPendingReportAPI(academicId ?? 0)
        }else{
            classPendingReportAPI(academicId ?? 0)
        }
    }

    @IBAction func backAct() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ClickId == "1"{
            return 5
        }
        else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ClickId == "1"{
            let cell =  tableView.dequeueReusableCell(withIdentifier: CellConfingName.PendingFeeReportTableViewCell, for: indexPath) as!   PendingFeeReportTableViewCell
            cell.classLbl.text = feesCategories[indexPath.row].category
            cell.amountLbl.text = feesCategories[indexPath.row].amount
            return cell
        }else{
            let cell =  tableView.dequeueReusableCell(withIdentifier: CellConfingName.PendingFeeReportTableViewCell, for: indexPath) as!   PendingFeeReportTableViewCell
            cell.classLbl.text = feeModes[indexPath.row].paymentMode
            cell.amountLbl.text = feeModes[indexPath.row].amount
            return cell
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if ClickId == "1"{
            return 4
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DataCollectionTvHeaderView") as! DataCollectionTvHeaderView
        if ClickId == "1"{
            headerView.classLbl.text = "Total"
            headerView.amountLbl.text = "37,515"
        }else{
            headerView.classLbl.text = "Total"
            headerView.amountLbl.text = "37,515"
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    

}
