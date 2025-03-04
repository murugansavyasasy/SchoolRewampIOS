//
//  SectionViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 26/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class SectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var noRecordView: UIView!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    var classNAme = ""
    var SchoolId  = String()
    var SectionName = ""
    var ClickID = 0
    var DateRef : String!
    
    var section = ["8th A","8th B","8th C","8th D","8th E"]
    var absentcount = ["3","8","2","6","3"]
    // Data for studentData
    let studentDataList = [
        studentData2(Name: "John Doe", StandandAndSection: "10th A", AdmissionNo: "AD1234", MobileNo: "9876543210"),
        studentData2(Name: "Jane Smith", StandandAndSection: "9th B", AdmissionNo: "AD1235", MobileNo: "8765432109"),
        studentData2(Name: "Emily Johnson", StandandAndSection: "8th C", AdmissionNo: "AD1236", MobileNo: "7654321098"),
        studentData2(Name: "Michael Brown", StandandAndSection: "7th A", AdmissionNo: "AD1237", MobileNo: "6543210987"),
        studentData2(Name: "Sarah Davis", StandandAndSection: "6th D", AdmissionNo: "AD1238", MobileNo: "5432109876")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        cv.register(UINib(nibName: CellConfingName.SectionCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.SectionCollectionViewCell)
        cv.dataSource = self
        cv.delegate = self
        noRecordView.isHidden = true
        noRecordLbl.isHidden = true
//        let backViews = UITapGestureRecognizer(target: self, action: #selector(BackVc))
//        backView.addGestureRecognizer(backViews)
        let rowNib = UINib(nibName: CellConfingName.SectionTvTableViewCell, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: CellConfingName.SectionTvTableViewCell)
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    @IBAction func BackAct(){
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        studentDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SectionTvTableViewCell, for: indexPath) as!
        SectionTvTableViewCell
        cell.selectionStyle = .none
        cell.nameLbl.text = studentDataList[indexPath.row].Name
        cell.mobileNumberLbl.text = studentDataList[indexPath.row].MobileNo
        cell.SectionLbl.text = studentDataList[indexPath.row].StandandAndSection
        cell.AddmisionLbl.text = studentDataList[indexPath.row].AdmissionNo
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.SectionCollectionViewCell, for: indexPath) as! SectionCollectionViewCell
        if ClickID == indexPath.row {
            
            cell.sectionClick.backgroundColor = .gradient1
            cell.sectionNameLbl.textColor = .black
            cell.absentcountLbl.textColor = .black
        }
        else{
            cell.sectionClick.backgroundColor = .systemGray6
            cell.sectionNameLbl.textColor = .gray
            cell.absentcountLbl.textColor = .gray
        }
        return cell
    }
    
    @IBAction func SectionclikVc(ges : SectionClick){
        SectionName = ges.SectionName
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ClickID = indexPath.row
        cv.dataSource = self
        cv.delegate = self
        cv.reloadData()
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 157, height: 58)
    }
    
}
class SectionClick : UITapGestureRecognizer{
    var sectionId = ""
    var SchoolId = ""
    var SectionName = ""
}


class PhnNumber : UITapGestureRecognizer{
    var MobileNumber = ""
}




/*
 //MARK: Variable declared
 //    var SectionWiseDatadetailsss : [SectionWiseDatadetails] = []
 
 //    var studetDataRef : [StudentDataDetails] = []
 
 //MARK: viewdidload
 //        sectionApiList(SectionId : SectionWiseDatadetailsss[0].SectionId, SchoolId: SchoolId)
 
 
 //MARK: CellForRowAt
 
 //        let studentList :  StudentDataDetails = studetDataRef[indexPath.row]
 //
 //
 //
 //        cell.nameLbl.text = studentList.studentName
 //        cell.SectionLbl.text = SectionName
 //        cell.AddmisionLbl.text =  "AdmissionNo" +  "  "  + " - " + "  " + studentList.admissionNo
 //
 //        let rectShape = CAShapeLayer()
 //        rectShape.bounds =  cell.profileImageView.frame
 //        rectShape.position =  cell.profileImageView.center
 //        rectShape.path = UIBezierPath(roundedRect:  cell.profileImageView.bounds, byRoundingCorners: [.topLeft,.bottomLeft], cornerRadii: CGSize(width: 6, height: 25)).cgPath
 //
 //
 //        cell.profileImageView.layer.mask = rectShape
 //
 //
 //        if studentList.photoPath == "" || studentList.photoPath == nil {
 //
 //
 //            cell.profileImageView.image = UIImage(named: "profile")
 //
 //
 //        }else{
 //
 //
 //
 //            cell.profileImageView.sd_setImage(with: URL(string:  studentList.photoPath), placeholderImage: UIImage(named: "profile"))
 //
 //        }
 //
 
 
 //        let abesents  : SectionWiseDatadetails = SectionWiseDatadetailsss[indexPath.row]
 //
 //
 //        SectionName =  classNAme + " " + "-" + " " + abesents.SectionName
 //        cell.sectionNameLbl.text = classNAme + " " + "-" + " " + abesents.SectionName
 //        cell.absentcountLbl.text = abesents.TotalAbsentees
 
 
 //MARK: didSelect
 let abesents  : SectionWiseDatadetails = SectionWiseDatadetailsss[indexPath.row]
 
 SectionName =  classNAme + " " + "-" + " " + abesents.SectionName
 
 //        sectionApiList(SectionId : abesents.SectionId, SchoolId: SchoolId)
 
 //MARK: func
 func sectionApiList(SectionId : String!,SchoolId : String!){
 //
 //
 //        let section = studentListModal()
 //
 //        section.schoolId = SchoolId
 //        section.sectionId = SectionId
 //        section.absentOn = DateRef
 //
 //        let sectionStr = section.toJSONString()
 //
 //        print("sectionStrsectionStr",section.toJSON())
 //
 //        StudentListReqst .call_request(param: sectionStr!){ [self]
 //
 //            (res) in
 //
 //
 //            let overallResp : studentListResponce =
 //            Mapper<studentListResponce>().map(JSONString: res)!
 //
 //            if overallResp.Status == 1{
 //
 //
 //                studetDataRef = overallResp.data
 //
 //                noRecordView.isHidden = true
 //                noRecordLbl.isHidden = true
 //
 //                tv.delegate = self
 //                tv.dataSource = self
 //                tv.reloadData()
 //
 //            }else{
 //
 //
 //                noRecordView.isHidden = false
 //                noRecordLbl.isHidden = false
 //                noRecordLbl.text = overallResp.Message
 //
 //            }
 //
 //
 //
 //
 //
 //        }
 //
 //
 //
 //    }
 
 */
