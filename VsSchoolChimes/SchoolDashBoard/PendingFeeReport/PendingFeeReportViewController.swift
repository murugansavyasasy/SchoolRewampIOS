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
    
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var noRecordsView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var AcadamidropDown: UIViewX!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var dropDownTextLbl: UILabel!
    @IBOutlet weak var classWiseView: UIView!
    @IBOutlet weak var categoryWiseView: UIView!
    
    
    let dropDown = DropDown()
    var url_time : String!
    var url_hours : String!
    var url_minutes : String!
    var display_date : String!
    var url_date : String!
    var indexList : Int!
    var ClickId  = "1"
    var SchoolId  = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var DropDownStr : [String] = []
    var type : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults.standard
        
        nodataLbl.isHidden = true
        noRecordsView.isHidden = true
        if type == 1 {
        }else{
        }
        tv.isHidden = true
        tv.register(UINib(nibName: CellConfingName.PendingFeeReportTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.PendingFeeReportTableViewCell)
        tv.register(UINib(nibName: "DataCollectionTvHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "DataCollectionTvHeaderView")
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVC))
        backView.addGestureRecognizer(backGesture)
        let dropDown = UITapGestureRecognizer(target: self, action: #selector(DropDownVc))
        AcadamidropDown.addGestureRecognizer(dropDown)
        let classWiseGuesture = UITapGestureRecognizer(target: self, action: #selector(classAction))
        classWiseView.addGestureRecognizer(classWiseGuesture)
        let categoryGuesture = UITapGestureRecognizer(target: self, action: #selector(categoryAction))
        categoryWiseView.addGestureRecognizer(categoryGuesture)

    }
    
    
    @IBAction func DropDownVc(){
        let acadamicYear = DropDownStr
        dropDown.dataSource = acadamicYear
        dropDown.anchorView = AcadamidropDown
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index:Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.dropDownTextLbl.text = item
            dropDownTextLbl.textColor = .black
        }
    }
    
    
    @IBAction func categoryAction() {
        tv.isHidden = true
        ClickId = "1"
        classWiseView.backgroundColor = .lightGray
        categoryWiseView.backgroundColor = Colornames.CustomOrange
    }
    
    @IBAction func classAction() {
        ClickId = "2"
        tv.isHidden = true
        categoryWiseView.backgroundColor = .lightGray
        classWiseView.backgroundColor = Colornames.CheckBoxSelectColor
    }
    
    @IBAction func backVC() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: rowIdentifier, for: indexPath) as!   PendingFeeReportTableViewCell
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    

}




/*
 
 
 //MARK: Var 
 var acdmicYearRef : [AcdmicYrDataDetails] = []
 var pendingdata : [PendiRespdatadetails] = []
//    var subpendingdata  : [pendingDataDetails] = []
 
 //MARK: DropDown
 
 for i in acdmicYearRef {
//
//                if dropDownTextLbl.text == i.yearName{
//
//
//                    if  ClickId == "1"{
//
////                        dashBoardList(AcadmiYerId : i.id, instuteId : SchoolId )
//                    }
//                    else if ClickId == "2"{
//
////                        SectionWise(AcadmiYerId : i.id, instuteId : SchoolId)
//
//
//                    }
//
//                }
//
//
//            }
 
 //MARK: categoryAction
 
 
 
//        for i in acdmicYearRef {
//
//
//            if i.currentAcademicYear == 1{
//
//                dropDownTextLbl.text = i.yearName
//
//                dashBoardList(AcadmiYerId : i.id, instuteId : SchoolId )
//            }
//
//
//        }
 
 //MARK: classAction
 
 
//        for i in acdmicYearRef {
//
//
//            if i.currentAcademicYear == 1{
//
//                dropDownTextLbl.text = i.yearName
//
//                SectionWise(AcadmiYerId : i.id, instuteId : SchoolId)
//            }
//
//
//        }
 //MARK: viewForHeaderInSection
 
 
 //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
 //        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DataCollectionTvHeaderView") as! DataCollectionTvHeaderView
 //
 //
 ////        let datas : PendiRespdatadetails = pendingdata[section]
 ////
 ////
 ////        headerView.classLbl.text = datas.Category
 ////
 ////
 ////
 ////        if datas.total == nil{
 ////            headerView.amountLbl.text = "0.0"
 ////
 ////        }else{
 ////            headerView.amountLbl.text = "₹" + datas.total
 ////        }
 ////
 //
 //
 //        return headerView
 //    }
     
 //MARK: cellForRowAt
 
 cell.numberLbl.text = String(indexPath.row+1)
//        if pendingdata[indexPath.section].data[indexPath.row].amount == nil{
//            cell.amountLbl.text = "0.0"
//
//        }else{
//            cell.amountLbl.text = "₹" + pendingdata[indexPath.section].data[indexPath.row].amount
//        }
//
//        cell.classLbl.text = pendingdata[indexPath.section].data[indexPath.row].TypeName
//
//
//
 
 //MARK: Func
 
 
//    func dashBoardList(AcadmiYerId : Int!, instuteId : String!) {
//
//        print("homePagedashBoardList")
//
//
//        let pending = pendingModal()
//        pending.instituteId = instuteId
//        pending.acadamicYearId = String(AcadmiYerId)
//
//
//        let pendingStr = pending.toJSONString()
//
//        print("dashBoarddashBoard",pending.toJSON())
//
//        NewPendingReqs.call_request(param: pendingStr!) {
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
//                if pendingdata.count == 0 {
//                    nodataLbl.isHidden = false
//                    noRecordsView.isHidden = false
//                    print("ttgtgtgtgdef")
//                    nodataLbl.text = "No Records"
//                }else{
//                    nodataLbl.isHidden = true
//                    noRecordsView.isHidden = true
//                }
//
//                tv.isHidden = false
//                tv.dataSource = self
//                tv.delegate = self
//                tv.reloadData()
//            }else{
//                print("nodataLbl")
//                tv.isHidden = true
//
//                nodataLbl.isHidden = false
//
//                noRecordsView.isHidden = false
//                nodataLbl.text = "No Records"
//
//
//            }
//
//
//
//
//        }
//
//
//
//    }
 
 
//    func SectionWise(AcadmiYerId : Int!, instuteId : String!) {
//
//        print("homePagedashBoardList")
//
//
//        let pending = pendingModal()
//        pending.instituteId = instuteId
//        pending.acadamicYearId = String(AcadmiYerId)
//
//
//        let pendingStr = pending.toJSONString()
//
//        print("dashBoarddashBoard",pending.toJSON())
//
//        classNewPendingReqs.call_request(param: pendingStr!) {
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
//                if pendingdata.count == 0 {
//                    nodataLbl.isHidden = false
//                    noRecordsView.isHidden = false
//                    print("ttgtgtgt45678g")
//                    nodataLbl.text = "No Records"
//                }else{
//                    noRecordsView.isHidden = true
//                    nodataLbl.isHidden = true
//                }
//                tv.isHidden = false
//                tv.dataSource = self
//                tv.delegate = self
//                tv.reloadData()
//            }else{
//                print("ttgtgtgtg")
//                tv.isHidden = true
//                nodataLbl.isHidden = false
//
//                noRecordsView.isHidden = false
//                nodataLbl.text = "No Records"
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
//
//
//    }
 
 
//    func  AcdimyYear(){
//
//
//        let param : [String : Any] =
//
//
//
//        [
//
//            "institute_id" : SchoolId
//
//
//
//        ]
//
//
//
//
//
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
//            [self] (res) in
//
//
//
//            let acdmy : acidmicYrResponce = Mapper<acidmicYrResponce>().map(JSONString: res)!
//
//
//
//
//            if acdmy.Status == 1{
//
//                for i in acdmy.data{
//
//
//                    if i.currentAcademicYear == 1{
//
//                        dropDownTextLbl.text = i.yearName
//
//
//                        if  ClickId == "1"{
//
//                            dashBoardList(AcadmiYerId : i.id, instuteId : SchoolId )
//                        }
//                        else if ClickId == "2"{
//
//                            SectionWise(AcadmiYerId : i.id, instuteId : SchoolId)
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
//
//
//
//                    }
//
//
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
