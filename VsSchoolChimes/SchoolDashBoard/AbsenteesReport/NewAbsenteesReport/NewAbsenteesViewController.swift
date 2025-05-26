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
    
   
    var DateRef = ""
    var absenton = ""
    var Id = ""
    var ClickID  = 0
    var SchoolId  = String()
    var absentData : [AbsenteeDate]?
    var  class_wiseData: [ClassWise]?
    let StaffDetails = UserDefaultFileManager.get_staff_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        Id = "1"
        cvIcon.register(UINib(nibName: CellConfingName.CVIconCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.CVIconCollectionViewCell)
        let rowNib = UINib(nibName: CellConfingName.ClassTableViewCell, bundle: nil)
        Tv.register(rowNib, forCellReuseIdentifier: CellConfingName.ClassTableViewCell)
        
        cvIcon.dataSource = self
        cvIcon.delegate = self
        
        Tv.dataSource = self
        Tv.delegate = self
        
        Absentees_Response()
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    @IBAction func BackAct() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  class_wiseData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.ClassTableViewCell,
            for: indexPath) as? ClassTableViewCell else{
            return UITableViewCell()}
//        cell.classNameLbl.text = class_wiseData?[indexPath.row].
//        cell.absentCountlbl.text = classDetailsData[indexPath.row].AbsentCount
//        cell.dateLbl.text = classDetailsData[indexPath.row].date
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return absentData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellConfingName.CVIconCollectionViewCell ,
            for: indexPath) as? CVIconCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        
        
        let dateStr = absentData?[indexPath.row].date ?? ""
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"

        if let date = inputFormatter.date(from: dateStr) {
            let outputFormatter = DateFormatter()
            
            // Get full month name
            outputFormatter.dateFormat = "MMM"
            let monthName = outputFormatter.string(from: date)
            cell.MnthLbl.text = monthName

            // Get day only
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            cell.dateLbl.text = "\(day)"
            
            
        }
        
    
        
        if ClickID == indexPath.row {
            cell.dateLbl.text = String (20 + indexPath.row)
//            cell.dayLbl.text = days[indexPath.row]
            cell.dateFulView.backgroundColor = .attendence
            cell.dayLbl.textColor = .black
            cell.dateLbl.textColor = .black
        }
        else{
            cell.dateFulView.backgroundColor = .white
            cell.dayLbl.textColor = .gray
            cell.dateLbl.textColor = .gray
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = Tv.cellForRow(at: indexPath) as! ClassTableViewCell
//        
//        let vc = SectionViewController(nibName: nil, bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
//    }
    
    @IBAction func clikVc(ges:DateClik){
        let vc = SectionViewController(nibName: nil, bundle: nil)
        vc.DateRef = ges.date
        vc.classNAme = ges.ClassName
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
    
    
    func Absentees_Response() {
        
        APIService.shared
            .makeApi(url: ServiceUrl.recipient_get_standards, parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "") { [self] (
                result:Result <AbsenteesResponse,
                Error>
            ) in
            
            switch result {
            case .success(let successMessage):
                DispatchQueue.main.async { [self] in
                    if successMessage.status == true{
                        
                        absentData = successMessage.data
                        class_wiseData = absentData?.first?.class_wise ?? []
                                   Tv.dataSource = self
                                   Tv.delegate = self
                                   Tv.reloadData()
                       
                                   cvIcon.dataSource = self
                                   cvIcon.delegate = self
                                   cvIcon.reloadData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    print(error.localizedDescription)
                   
                }
            }
        }
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
