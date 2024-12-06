//
//  SectionViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 26/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import ObjectMapper

class SectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var noRecordView: UIView!
    
    @IBOutlet weak var noRecordLbl: UILabel!
    
    @IBOutlet weak var cv: UICollectionView!
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backView: UIView!
    var SectionWiseDatadetailsss : [SectionWiseDatadetails] = []
    var classNAme = ""
    var SchoolId  = String()
    let cvIconRowId = "SectionCollectionViewCell"
    let TVIdenfier = "SectionTvTableViewCell"
    var studetDataRef : [StudentDataDetails] = []
    var SectionName = ""
    var ClickID = 0
    var DateRef : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        cv.register(UINib(nibName: cvIconRowId, bundle: nil), forCellWithReuseIdentifier: cvIconRowId)
        cv.dataSource = self
        cv.delegate = self
        
        noRecordView.isHidden = true
        noRecordLbl.isHidden = true
        sectionApiList(SectionId : SectionWiseDatadetailsss[0].SectionId, SchoolId: SchoolId)
        let backViews = UITapGestureRecognizer(target: self, action: #selector(BackVc))
        backView.addGestureRecognizer(backViews)
        
        let rowNib = UINib(nibName: TVIdenfier, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: TVIdenfier)
        
    }
    
    @IBAction func BackVc(){
        
        dismiss(animated: true)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studetDataRef.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TVIdenfier, for: indexPath) as!
        
        SectionTvTableViewCell
        
        cell.selectionStyle = .none
        
        let studentList :  StudentDataDetails = studetDataRef[indexPath.row]
        
        
        
        cell.nameLbl.text = studentList.studentName
        cell.SectionLbl.text = SectionName
        cell.AddmisionLbl.text =  "AdmissionNo" +  "  "  + " - " + "  " + studentList.admissionNo
        
        let rectShape = CAShapeLayer()
        rectShape.bounds =  cell.profileImageView.frame
        rectShape.position =  cell.profileImageView.center
        rectShape.path = UIBezierPath(roundedRect:  cell.profileImageView.bounds, byRoundingCorners: [.topLeft,.bottomLeft], cornerRadii: CGSize(width: 6, height: 25)).cgPath
        
        
        cell.profileImageView.layer.mask = rectShape
        
        
        if studentList.photoPath == "" || studentList.photoPath == nil {
            
            
            cell.profileImageView.image = UIImage(named: "profile")
            
            
        }else{
            
            
            
            cell.profileImageView.sd_setImage(with: URL(string:  studentList.photoPath), placeholderImage: UIImage(named: "profile"))
            
        }
        
        
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return SectionWiseDatadetailsss.count
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cvIconRowId, for: indexPath) as! SectionCollectionViewCell
        
        if ClickID == indexPath.row {
            
            
            
            cell.sectionClick.backgroundColor = UIColor(named: "CustomOrange")
            cell.sectionNameLbl.textColor = .white
            cell.sectionNameLbl.textColor = .white
            
        }
        else{
            
            
            
            cell.sectionClick.backgroundColor = UIColor(named: "LightOrange")
            cell.sectionNameLbl.textColor = .black
            cell.sectionNameLbl.textColor = .black
            
            
        }
        
        
        
        let abesents  : SectionWiseDatadetails = SectionWiseDatadetailsss[indexPath.row]
        
        
        SectionName =  classNAme + " " + "-" + " " + abesents.SectionName
        cell.sectionNameLbl.text = classNAme + " " + "-" + " " + abesents.SectionName
        cell.absentcountLbl.text = abesents.TotalAbsentees
        
        return cell
        
        
    }
    
    
    
    @IBAction func SectionclikVc(ges : SectionClick){
        SectionName = ges.SectionName
        
        
        
        
    }
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let abesents  : SectionWiseDatadetails = SectionWiseDatadetailsss[indexPath.row]
        
        ClickID = indexPath.row
        
        SectionName =  classNAme + " " + "-" + " " + abesents.SectionName
        
        sectionApiList(SectionId : abesents.SectionId, SchoolId: SchoolId)
        
        cv.dataSource = self
        cv.delegate = self
        cv.reloadData()
        
        print("heloooo")
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 157, height: 58)
        
        
        
    }
    
    
    
    
    
    
    func sectionApiList(SectionId : String!,SchoolId : String!){
        
        
        let section = studentListModal()
        
        section.schoolId = SchoolId
        section.sectionId = SectionId
        section.absentOn = DateRef
        
        let sectionStr = section.toJSONString()
        
        print("sectionStrsectionStr",section.toJSON())
        
        StudentListReqst .call_request(param: sectionStr!){ [self]
            
            (res) in
            
            
            let overallResp : studentListResponce =
            Mapper<studentListResponce>().map(JSONString: res)!
            
            if overallResp.Status == 1{
                
                
                studetDataRef = overallResp.data
                
                noRecordView.isHidden = true
                noRecordLbl.isHidden = true
                
                tv.delegate = self
                tv.dataSource = self
                tv.reloadData()
                
            }else{
                
                
                noRecordView.isHidden = false
                noRecordLbl.isHidden = false
                noRecordLbl.text = overallResp.Message
                
            }
            
            
            
            
            
        }
        
        
        
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
