//
//  NewAbsenteesViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 23/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
//import ObjectMapper

class NewAbsenteesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var Tv: UITableView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var cvIcon: UICollectionView!
    
    // Data for classDetails
    let classDetailsData = [
        classDetails(Standard: "10th Grade", date: "21 Jan 2024", AbsentCount: "3"),
        classDetails(Standard: "9th Grade", date: "20 Jan 2024", AbsentCount: "2"),
        classDetails(Standard: "8th Grade", date: "19 Jan 2024", AbsentCount: "5"),
        classDetails(Standard: "7th Grade", date: "18 Jan 2024", AbsentCount: "1"),
        classDetails(Standard: "6th Grade", date: "17 Jan 2024", AbsentCount: "0")
    ]

    // Data for studentData
    let studentDataList = [
        studentData(Name: "John Doe", StandandAndSection: "10th A", AdmissionNo: "AD1234"),
        studentData(Name: "Jane Smith", StandandAndSection: "9th B", AdmissionNo: "AD1235"),
        studentData(Name: "Emily Johnson", StandandAndSection: "8th C", AdmissionNo: "AD1236"),
        studentData(Name: "Michael Brown", StandandAndSection: "7th A", AdmissionNo: "AD1237"),
        studentData(Name: "Sarah Davis", StandandAndSection: "6th D", AdmissionNo: "AD1238")
    ]
    
    var days = ["Monday","Tuesday","Wednesday","Thrusday","Friday","Saturday"]

   
    var DateRef = ""
    var absenton = ""
    var Id = ""
    var ClickID  = 0
    var SchoolId  = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
        
        Id = "1"
        cvIcon.register(UINib(nibName: CellConfingName.CVIconCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.CVIconCollectionViewCell)
//        let back = UITapGestureRecognizer(target: self, action: #selector(BackVc))
//        backView.addGestureRecognizer(back)
        let rowNib = UINib(nibName: CellConfingName.ClassTableViewCell, bundle: nil)
        Tv.register(rowNib, forCellReuseIdentifier: CellConfingName.ClassTableViewCell)
        
        cvIcon.dataSource = self
        cvIcon.delegate = self
        cvIcon.reloadData()
        
        Tv.dataSource = self
        Tv.delegate = self
    }
    
    @IBAction func BackAct() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if Id == "1"{
//            return 2
//        }else{
//            return 2
//        }
        
        classDetailsData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ClassTableViewCell, for: indexPath) as!
        ClassTableViewCell
        cell.classNameLbl.text = classDetailsData[indexPath.row].Standard
        cell.absentCountlbl.text = classDetailsData[indexPath.row].AbsentCount
        cell.dateLbl.text = classDetailsData[indexPath.row].date
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.CVIconCollectionViewCell, for: indexPath) as! CVIconCollectionViewCell
        
        cell.MnthLbl.text = "January"
        
        if ClickID == indexPath.row {
            cell.dateLbl.text = String (20 + indexPath.row)
            cell.dayLbl.text = days[indexPath.row]
            cell.dateFulView.backgroundColor = .systemOrange
            cell.dayLbl.textColor = .white
            cell.dateLbl.textColor = .white
        }
        else{
            cell.dateFulView.backgroundColor = .white
            cell.dayLbl.textColor = .black
            cell.dateLbl.textColor = .black
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = Tv.cellForRow(at: indexPath) as! ClassTableViewCell
        
        let vc = SectionViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func clikVc(ges:DateClik){
        let vc = SectionViewController(nibName: nil, bundle: nil)
        vc.DateRef = ges.date
        vc.classNAme = ges.ClassName
        vc.SchoolId = SchoolId
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true,completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ClickID = indexPath.row
        cvIcon.dataSource = self
        cvIcon.delegate = self
        cvIcon.reloadData()
        Tv.dataSource = self
        Tv.delegate = self
        Tv.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 130 )
    }
    
}

class  DateClik : UITapGestureRecognizer{
    var date : String!
    var ClassName  = ""
    var viewss : UIView!
}



/*
 
 //MARK: DateClik
 //    var SectionWiseDatadetailsss : [SectionWiseDatadetails] = []
 
 //MARK: variable
 //    var abesentApidataRef : [abesentResponce] = []
 //    var classwiseRefs : [ClassWisDataDetails] = []
 //    var classwiseRef1 : [ClassWisDataDetails] = []
 
 //MARK: viewDidload
 
 //        abestApi()
 
 //MARK: numberOfRowsinSec
 //            print("classwiseRefsclasswiseRefs",classwiseRef1.count)
 //            print("kfedkwfkmelkrfmkceafkmd.",classwiseRef1.count)
 
 //MARK: Tv cellForRow
 
 //        if Id == "1"{
 
 
 
 //            let classwise  : ClassWisDataDetails = classwiseRef1[indexPath.row]
 //            cell.classNameLbl.text = classwise.ClassName
 //            cell.absentCountlbl.text = classwise.TotalAbsentees
 //            cell.dateLbl.text = abesentApidataRef[0].Date
 //            absenton = abesentApidataRef[0].absentdateonly
 //            let clik = DateClik(target: self, action: #selector(clikVc))
 //            clik.SectionWiseDatadetailsss = classwise.SectionWise
 //            clik.date = absenton
 //            clik.ClassName = classwise.ClassName
 //            cell.fullView.addGestureRecognizer(clik)
 //        }
 //
 //        else{
 //            Id = "0"
 //            let classwise  : ClassWisDataDetails = classwiseRefs[indexPath.row]
 //            cell.classNameLbl.text = classwise.ClassName
 //            cell.absentCountlbl.text = classwise.TotalAbsentees
 //            cell.dateLbl.text = DateRef
 //            let clik = DateClik(target: self, action: #selector(clikVc))
 //            clik.SectionWiseDatadetailsss = classwise.SectionWise
 //            clik.date = absenton
 //            clik.ClassName = classwise.ClassName
 //            cell.fullView.addGestureRecognizer(clik)
 //        }
 
 
 
 //MARK: Cv cellForRow
 
 
 //        let abesents  : abesentResponce = abesentApidataRef[indexPath.row]
 //        let dateString = abesents.Date
 //        let dateFormatter = DateFormatter()
 //        dateFormatter.dateFormat = "dd/MM/yyyy"
 //        if let date = dateFormatter.date(from: dateString!) {
 //            let monthFormatter = DateFormatter()
 //            monthFormatter.dateFormat = "MMMM"
 //            let monthName = monthFormatter.string(from: date)
 //            print(monthName)  // Output: March
 //            cell.MnthLbl.text = monthName
 //        } else {
 //            print("Invalid date format")
 //        }
 //
 //        let dateString1 = abesents.Date
 //        let dateFormatter1 = DateFormatter()
 //        dateFormatter1.dateFormat = "dd/MM/yyyy"
 //        if let date1 = dateFormatter1.date(from: dateString1!) {
 //            let calendar = Calendar.current
 //            let day = calendar.component(.day, from: date1)
 //            print(day)  // Output: 16
 //            cell.dateLbl.text = String(day)
 //        } else {
 //            print("Invalid date format")
 //        }
 //
 //        cell.dayLbl.text = abesents.Day
 //        if abesents.TotalAbsentees == "0"{
 //
 //            cell.countView.isHidden = true
 //
 //
 //
 //        }else{
 //
 //            cell.countView.isHidden = false
 //            cell.countLbl.text = abesents.TotalAbsentees
 //
 //        }
 //
 //        if Id == "1"{
 //            DateRef = abesents.Date
 //            classwiseRefs = abesentApidataRef[0].ClassWise
 //            Tv.dataSource = self
 //            Tv.delegate = self
 //            Tv.reloadData()
 //        }else{
 //        }
 //
 
 //MARK: clikVc Func
 
 //        vc.SectionWiseDatadetailsss = ges.SectionWiseDatadetailsss
 
 
 //MARK: cv didSelectItemAt
 
 //        let abesents  : abesentResponce = abesentApidataRef[indexPath.row]
 //        DateRef = abesents.Date
 //        Id = "0"
 //        classwiseRefs = abesents.ClassWise
 //        absenton = abesents.absentdateonly
 
 
 //MARK: Func
 
 //    func abestApi(){
 //        let absent = abesentModal()
 //        absent.SchoolId = SchoolId
 //        let absentStr = absent.toJSONString()
 //        AbesentReqst .call_request(param: absentStr!){ [self]
 //            (res) in
 //            let overallResp : [abesentResponce] =
 //            Mapper<abesentResponce>().mapArray(JSONString: res)!
 //            abesentApidataRef = overallResp
 //            classwiseRef1 = abesentApidataRef[0].ClassWise
 //            Tv.dataSource = self
 //            Tv.delegate = self
 //            Tv.reloadData()
 //
 //            cvIcon.dataSource = self
 //            cvIcon.delegate = self
 //            cvIcon.reloadData()
 //
 //        }
 //    }
 
 */

struct classDetails {
    
    var Standard : String
    var date : String
    var AbsentCount : String
}

struct studentData {
    
    var Name : String
    var StandandAndSection : String
    var AdmissionNo : String
}
struct studentData2 {
    
    var Name : String
    var StandandAndSection : String
    var AdmissionNo : String
    var MobileNo : String
}
