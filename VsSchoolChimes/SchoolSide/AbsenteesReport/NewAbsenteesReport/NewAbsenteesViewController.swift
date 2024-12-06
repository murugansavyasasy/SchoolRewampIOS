//
//  NewAbsenteesViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 23/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import ObjectMapper

class NewAbsenteesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var Tv: UITableView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var cvIcon: UICollectionView!
    
    let cvIconRowId = "CVIconCollectionViewCell"
    let cvBottomRowId = "CVIconCollectionViewCell"
    let TvIdentfier = "ClassTableViewCell"
    var abesentApidataRef : [abesentResponce] = []
    var DateRef = ""
    var classwiseRefs : [ClassWisDataDetails] = []
    var classwiseRef1 : [ClassWisDataDetails] = []
    var absenton = ""
    var Id = ""
    var ClickID  = 0
    var SchoolId  = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Id = "1"
        cvIcon.register(UINib(nibName: cvIconRowId, bundle: nil), forCellWithReuseIdentifier: cvIconRowId)
        abestApi()
        let back = UITapGestureRecognizer(target: self, action: #selector(BackVc))
        backView.addGestureRecognizer(back)
        let rowNib = UINib(nibName: TvIdentfier, bundle: nil)
        Tv.register(rowNib, forCellReuseIdentifier: TvIdentfier)
    }
    
    @IBAction func BackVc() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Id == "1"{
            print("classwiseRefsclasswiseRefs",classwiseRef1.count)
            return classwiseRef1.count
        }else{
            print("kfedkwfkmelkrfmkceafkmd.",classwiseRef1.count)
            return classwiseRefs.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TvIdentfier, for: indexPath) as!
        ClassTableViewCell
        
        if Id == "1"{
            let classwise  : ClassWisDataDetails = classwiseRef1[indexPath.row]
            cell.classNameLbl.text = classwise.ClassName
            cell.absentCountlbl.text = classwise.TotalAbsentees
            cell.dateLbl.text = abesentApidataRef[0].Date
            absenton = abesentApidataRef[0].absentdateonly
            let clik = DateClik(target: self, action: #selector(clikVc))
            clik.SectionWiseDatadetailsss = classwise.SectionWise
            clik.date = absenton
            clik.ClassName = classwise.ClassName
            cell.fullView.addGestureRecognizer(clik)
        }
        
        else{
            Id = "0"
            let classwise  : ClassWisDataDetails = classwiseRefs[indexPath.row]
            cell.classNameLbl.text = classwise.ClassName
            cell.absentCountlbl.text = classwise.TotalAbsentees
            cell.dateLbl.text = DateRef
            let clik = DateClik(target: self, action: #selector(clikVc))
            clik.SectionWiseDatadetailsss = classwise.SectionWise
            clik.date = absenton
            clik.ClassName = classwise.ClassName
            cell.fullView.addGestureRecognizer(clik)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return abesentApidataRef.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cvIconRowId, for: indexPath) as! CVIconCollectionViewCell
        if ClickID == indexPath.row {
            cell.dateFulView.backgroundColor = .systemOrange
            cell.dayLbl.textColor = .white
            cell.dateLbl.textColor = .white
        }
        else{
            cell.dateFulView.backgroundColor = .white
            cell.dayLbl.textColor = .black
            cell.dateLbl.textColor = .black
        }
        
        let abesents  : abesentResponce = abesentApidataRef[indexPath.row]
        let dateString = abesents.Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let date = dateFormatter.date(from: dateString!) {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            let monthName = monthFormatter.string(from: date)
            print(monthName)  // Output: March
            cell.MnthLbl.text = monthName
        } else {
            print("Invalid date format")
        }
        
        let dateString1 = abesents.Date
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd/MM/yyyy"
        if let date1 = dateFormatter1.date(from: dateString1!) {
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date1)
            print(day)  // Output: 16
            cell.dateLbl.text = String(day)
        } else {
            print("Invalid date format")
        }
        
        cell.dayLbl.text = abesents.Day
        if abesents.TotalAbsentees == "0"{
            
            cell.countView.isHidden = true
            
            
            
        }else{
            
            cell.countView.isHidden = false
            cell.countLbl.text = abesents.TotalAbsentees
            
        }
        
        if Id == "1"{
            DateRef = abesents.Date
            classwiseRefs = abesentApidataRef[0].ClassWise
            Tv.dataSource = self
            Tv.delegate = self
            Tv.reloadData()
        }else{
        }
        
        return cell
    }
    
    @IBAction func clikVc(ges:DateClik){
        let vc = SectionViewController(nibName: nil, bundle: nil)
        vc.SectionWiseDatadetailsss = ges.SectionWiseDatadetailsss
        vc.DateRef = ges.date
        vc.classNAme = ges.ClassName
        vc.SchoolId = SchoolId
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true,completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ClickID = indexPath.row
        let abesents  : abesentResponce = abesentApidataRef[indexPath.row]
        DateRef = abesents.Date
        Id = "0"
        classwiseRefs = abesents.ClassWise
        absenton = abesents.absentdateonly
        cvIcon.dataSource = self
        cvIcon.delegate = self
        cvIcon.reloadData()
        Tv.dataSource = self
        Tv.delegate = self
        Tv.reloadData()
        print("heloooo")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 130 )
    }
    
    func abestApi(){
        let absent = abesentModal()
        absent.SchoolId = SchoolId
        let absentStr = absent.toJSONString()
        AbesentReqst .call_request(param: absentStr!){ [self]
            (res) in
            let overallResp : [abesentResponce] =
            Mapper<abesentResponce>().mapArray(JSONString: res)!
            abesentApidataRef = overallResp
            classwiseRef1 = abesentApidataRef[0].ClassWise
            Tv.dataSource = self
            Tv.delegate = self
            Tv.reloadData()
            
            cvIcon.dataSource = self
            cvIcon.delegate = self
            cvIcon.reloadData()
            
        }
    }
    
}

class  DateClik : UITapGestureRecognizer{
    var date : String!
    var SectionWiseDatadetailsss : [SectionWiseDatadetails] = []
    var ClassName  = ""
    var viewss : UIView!
}
