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
    
    @IBOutlet weak var totalfeeLbl: UILabel!
    @IBOutlet weak var switchReport: UISegmentedControl!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var noRecordsView: UIImageView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        getacadmicYr()
        DropDownStr = ["2012 - 2013","2014 - 2015","2016 - 2017","2018 - 2019"]
        applyShadowAndCornerRadius(to: acodemicView)
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
                            nodata(true)
                            for i in 0..<(AcadimicYearDatas.count){
                                if AcadimicYearDatas[i].current_academic_year ?? false == true{
                                    acodomicYearLbl.text = AcadimicYearDatas[i].year
                                    academicId = AcadimicYearDatas[i].id
                                    
                                    getPendingReportAPI(academicId ?? 0)
                                }
                            }
                        }
                    }else{
                        nodata(false)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    func nodata(_ hide:Bool){
        nodataLbl.isHidden = hide
        noRecordsView.isHidden = hide
    }
    func getPendingReportAPI(_ academic_year_id:Int){
        APIService.shared
            .makeApi(url: ServiceUrl.api_fee_report_detailed_pending_report , parameters: ["academic_year_id":academic_year_id], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <PendingReportsResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            PendingReports = successMessage.data
                            for i in 0..<(PendingReports?.count ?? 0) {
                                totalfeeLbl.text = "Total Pending: " + (
                                    PendingReports?[i].total_pending ?? ""
                                )
                            }
                            
                            tv.reloadData()
                            nodata(true)
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            totalfeeLbl.text = ""
                            PendingReports = []
                            tv.reloadData()
                            nodata(false)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [self] in
                        print(error.localizedDescription)
                    }
                    
                }
            }
    }
    func classPendingReportAPI(_ academic_year_id:Int){
        APIService.shared
            .makeApi(url: ServiceUrl.api_fee_report_detailed_class_wise_pending_report , parameters: ["academic_year_id":academic_year_id], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <PendingReportsResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            PendingReports = successMessage.data
                            for i in 0..<(PendingReports?.count ?? 0) {
                                totalfeeLbl.text = "Total Pending: " + (
                                    PendingReports?[i].total_pending ?? ""
                                )
                            }
                            tv.reloadData()
                            nodata(true)
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            PendingReports = []
                            totalfeeLbl.text = ""
                            tv.reloadData()
                            nodata(false)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [self] in
                        print(error.localizedDescription)
                        nodata(false)
                    }
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
        return PendingReports?[section].pending_data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell =  tableView.dequeueReusableCell(withIdentifier: CellConfingName.PendingFeeReportTableViewCell, for: indexPath) as!   PendingFeeReportTableViewCell
        let data = PendingReports?[indexPath.section].pending_data
        cell.classLbl.text = data?[indexPath.row].type_name
        cell.amountLbl.text = data?[indexPath.row].amount
        
            return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return PendingReports?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DataCollectionTvHeaderView") as? DataCollectionTvHeaderView else {
            return nil
        }
        headerView.headerFullview.backgroundColor = UIColor.gradient1
        headerView.classLbl.isHidden = false
        headerView.classLbl.text = PendingReports?[section].category ?? ""
        headerView.amountLbl.textColor = .black
        headerView.amountLbl.text = PendingReports?[section].total ?? "0"

        return headerView
    }

//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let isLastSection = section == (PendingReports?.count ?? 0) - 1
//        guard isLastSection else { return nil }
//
//        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DataCollectionTvHeaderView") as? DataCollectionTvHeaderView else {
//            return nil
//        }
//
//        footerView.classLbl.isHidden = true // Hide class label
////        footerView.amountLbl.text =
//        
//
////        footerView.amountLbl.textColor = .button
////        footerView.headerFullview.backgroundColor = .clear
//        return footerView
//    }

//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        let isLastSection = section == (PendingReports?.count ?? 0) - 1
//        return isLastSection ? 50 : 0.01
//    }
//    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    

}
