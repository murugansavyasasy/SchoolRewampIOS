//
//  StaffPtmViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 14/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import ObjectMapper
class StaffPtmViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nodatalabl: UILabel!
    @IBOutlet weak var slotView: UIView!
    @IBOutlet weak var todaSlotView: UIView!
    @IBOutlet weak var datePickerView: UIViewX!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    
    let cvRowIdentifier = "SlotsCollectionViewCell"
//    var sectiondeatils : [sectionDetails] = []
    var tvcellIdentifier = "StaffPtmTableViewCell"
    var dateWiseData : [DateWiseModalDataDetails] = []
    var StaffData : [SlotDetailsForStaffData] = []
    var slotdetails : [SlotLists] = []
    var sectiondeatils : [sectionDetails] = []
    var detailss : [SlotDetails] = []
    var instituteId  = Int()
    var sectionId = Int()
    var staffId  = Int()
    var studentId  = Int()
    var classId  = Int()
    var display_date : String!
    var url_date : String!
    var HeaderTv = "SlotHeader"
    var CustomOrange = "AppDark"
    var type : Int!
    var SchoolId : String!
    var lastContentOffset: CGFloat = 0
    var isButtonHidden: Bool = false
    var collectionViewCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM d, yyyy"
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        print(formattedDate) // Example output: "Mo
        display_date = formattedDate
        
        let eventDate = formattedDate
        let dateFormatter1 = DateFormatter()
        // Input format
        dateFormatter1.dateFormat = "dd/MM/yyyy"
        
        if let date1 = dateFormatter1.date(from: formattedDate) {
            
            dateFormatter1.dateFormat = "E, MMM d, yyyy"
            let formattedDate1 = dateFormatter1.string(from: date1)
            dateLbl.text = formattedDate1
            
        }
            
        let userDefaults = UserDefaults.standard
        sectionId = userDefaults.integer(forKey: DefaultsKeys.SectionId)
//        instituteId = userDefaults.integer(forKey: DefaultsKeys.SchoolD)
//        staffId = userDefaults.integer(forKey: DefaultsKeys.StaffID)
        classId = userDefaults.integer(forKey: DefaultsKeys.ClassID)
        studentId = userDefaults.integer(forKey: DefaultsKeys.chilId)
        todaSlotView.backgroundColor = UIColor(named: CustomOrange)
        if type == 1 {
            
            
//            staffId = userDefaults.integer(forKey: DefaultsKeys.StaffID)
//            SchoolId = userDefaults.string(forKey: (DefaultsKeys.SchoolD))!
        }else{
            //        StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)
            SchoolId = userDefaults.string(forKey: (DefaultsKeys.SchoolD))!
            staffId = userDefaults.integer(forKey: DefaultsKeys.StaffID)
        }
        
        print("SchoolId",SchoolId)
        print("staffIdstaffId",staffId)
        tv.register(UINib(nibName: tvcellIdentifier, bundle: nil), forCellReuseIdentifier: tvcellIdentifier)
        
        let rownib2 = UINib(nibName: HeaderTv, bundle: nil)
        tv.register(rownib2, forHeaderFooterViewReuseIdentifier: HeaderTv)
        
        nodatalabl.isHidden = true
        dateWiseSlot()
        
       
        let calander  = UITapGestureRecognizer(target: self , action:#selector(datePick) )
        datePickerView.addGestureRecognizer(calander)
        
        let back = UITapGestureRecognizer(target: self , action:#selector(backVC) )
        backView.addGestureRecognizer(back)
        
        let todaySlot  = UITapGestureRecognizer(target: self , action:#selector(TodaySlotVC) )
        todaSlotView.addGestureRecognizer(todaySlot)
        let Slot  = UITapGestureRecognizer(target: self , action:#selector(SlotVC) )
        slotView.addGestureRecognizer(Slot) 
        let create  = UITapGestureRecognizer(target: self , action:#selector(cretaeVC) )
        createView.addGestureRecognizer(create)
    }
    
    
    
    @IBAction func backVC(){
        
        
        dismiss(animated: true)
        
    }
    
    
    
    @IBAction func cretaeVC(){
        
        
      let vc = SltoCreationViewController(nibName: nil, bundle: nil)
        vc.instute = Int(instituteId)
        vc.staffId = staffId
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        
    }
    @IBAction func btn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func  datePick (){
        
        RPickerTwo.selectDate(title: "Select Date", cancelText: "Cancel", datePickerMode: .date, style: .Inline, didSelectDate: {[weak self] (today_date) in
            
            
            
            self?.display_date = today_date.dateString("dd/MM/yyyy")
            
            self?.url_date = today_date.dateString("yyyy/MM/dd")
            
            self?.dateLbl.text = self!.display_date
            
            
            let eventDate = self!.dateLbl.text
            let dateFormatter1 = DateFormatter()
            // Input format
            dateFormatter1.dateFormat = "dd/MM/yyyy"
            
            if let date1 = dateFormatter1.date(from: self!.dateLbl.text!) {
                
                dateFormatter1.dateFormat = "E, MMM d, yyyy"
                let formattedDate1 = dateFormatter1.string(from: date1)
                self!.dateLbl.text = formattedDate1
                
            }
            
            
          
            if  self!.slotView.backgroundColor == UIColor(named: self!.CustomOrange){
                self!.StaffDetailsForStaff()
            }else{
                
                self!.dateWiseSlot()
            }
            
        })
        
    }
    @IBAction func  TodaySlotVC (){
        
        createView.isHidden = false
        dateLbl.text = "--- Select Date ---"
        slotView.backgroundColor = .lightGray
        todaSlotView.backgroundColor = UIColor(named: CustomOrange)
        dateWiseSlot()
    }
    @IBAction func  SlotVC (){
        createView.isHidden = true
        todaSlotView.backgroundColor = .lightGray
        slotView.backgroundColor = UIColor(named: CustomOrange)
        dateLbl.text = "--- Select Date ---"
        display_date = "ALL"
        StaffDetailsForStaff()
        
       
        
    }  
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if  slotView.backgroundColor == UIColor(named: CustomOrange){
              
            return StaffData.count
        }else if todaSlotView.backgroundColor == UIColor(named: CustomOrange){
            
           
            return 1
        }
       
          return 0
      }
    
    
            func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
              
                if slotView.backgroundColor == UIColor(named: CustomOrange){
                    
                    
                    print("SlotTabelVIEWHEADER")
                    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderTv) as! SlotHeader

                    let dateFormatter1 = DateFormatter()
                    // Input format
                    dateFormatter1.dateFormat = "dd/MM/yyyy"
                    print("detailss[section].std_sec_details.count",detailss[section].std_sec_details.count)
                    collectionViewCount = detailss[section].std_sec_details.count
                    if let date1 = dateFormatter1.date(from: StaffData[section].date) {
                        
                        dateFormatter1.dateFormat = "E, MMM d, yyyy"
                        let formattedDate1 = dateFormatter1.string(from: date1)
                        headerView.dateLabl.text = formattedDate1
                        
                    }
                   
                    headerView.stdSecDetails = detailss[section].std_sec_details
                   
                    let itemCount = detailss[section].std_sec_details.count
                    headerView.adjustCollectionViewHeight(for: itemCount )
                    return headerView
                    
                }else{
                    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderTv) as! SlotHeader
                    headerView.isHidden = true
                    return headerView
                }
                
    
                
            }
    
         
           
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  slotView.backgroundColor == UIColor(named: CustomOrange){
            return UITableView.automaticDimension
        }else  if  todaSlotView.backgroundColor == UIColor(named: CustomOrange){
            
            return 0
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  slotView.backgroundColor == UIColor(named: CustomOrange){
            
            return detailss[section].slots.count
        }else{
            
            
            return dateWiseData.count
        }
        
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {




        if  slotView.backgroundColor == UIColor(named: CustomOrange){

            let cell = tableView.dequeueReusableCell(withIdentifier: tvcellIdentifier, for: indexPath) as! StaffPtmTableViewCell

            cell.selectionStyle = .none
            
            cell.backView.layer.cornerRadius = 20
            cell.backView.layer.masksToBounds = true
            cell.backView.layer.shadowColor = UIColor.black.cgColor
            cell.backView.layer.shadowOpacity = 0.5
            cell.backView.layer.shadowOffset = CGSize(width: 4, height: 4)
            cell.backView.layer.shadowRadius = 1
            cell.backView.layer.masksToBounds = false
            
            cell.statusview.layer.masksToBounds = true
            cell.statusview.layer.shadowColor = UIColor.white.cgColor
            cell.statusview.layer.shadowOpacity = 0.5
            cell.statusview.layer.shadowOffset = CGSize(width: 4, height: 4)
            cell.statusview.layer.shadowRadius = 5
            cell.statusview.layer.masksToBounds = false
            
            if detailss[indexPath.section].slots[indexPath.row].event_name == ""{
                
                cell.studentName.isHidden = true
                
                
            }else{
                
                cell.studentName.isHidden = false
                
                cell.studentName.text  = detailss[indexPath.section].slots[indexPath.row].event_name
            }
           
            cell.zoomLbl.text = "Mode - " +   detailss[indexPath.section].slots[indexPath.row].event_mode

           
           
            

//            if data.eventLink == ""{
//
                cell.eventLink.isHidden = true
//
//            }else{
//
//                cell.eventLink.isHidden = false
//
//            }


            if detailss[indexPath.section].slots[indexPath.row].booked_by == ""{

                
                cell.eventName.isHidden = true
              
            }else{

                
                cell.eventName.isHidden = false
              
                cell.eventName.text  = detailss[indexPath.section].slots[indexPath.row].booked_by
            }


            if detailss[indexPath.section].slots[indexPath.row].profile_url == ""{


            }else{

            cell.profileImage.sd_setImage(with: URL(string: detailss[indexPath.section].slots[indexPath.row].profile_url), placeholderImage: UIImage(named: "profile"))
            }

            
            
            if detailss[indexPath.section].slots[indexPath.row].my_class == "" || detailss[indexPath.section].slots[indexPath.row].my_section == ""{
                
                cell.classSectionLbl.isHidden = true
                
                
            }else{
                
                cell.classSectionLbl.isHidden = false
                cell.classSectionLbl.text = detailss[indexPath.section].slots[indexPath.row].my_class + " - " + detailss[indexPath.section].slots[indexPath.row].my_section
            }
            if detailss[indexPath.section].slots[indexPath.row].status == "Completed" {

                cell.statusLbl.textColor = UIColor(named: "completed")
                cell.statusLbl.text = detailss[indexPath.section].slots[indexPath.row].status
                cell.cancelView.isHidden = true
                cell.cancelAndReponeView.isHidden = true

            } else if detailss[indexPath.section].slots[indexPath.row].status == "Available" {

                cell.statusLbl.textColor  = .systemCyan
                cell.statusLbl.text = detailss[indexPath.section].slots[indexPath.row].status
                
             
                if (detailss[indexPath.section].slots[indexPath.row].is_booked == 0) && (detailss[indexPath.section].slots[indexPath.row].is_cancelled == 0){
                 
                    print("cell.cancelView.isHidden",cell.cancelView.isHidden)
//                    cell.cancelView.isHidden = false
                    print("nkjnjknkjnknafterrr",cell.cancelView.isHidden)
                    print("cell.cancelViewHeight",cell.cancelHeight)
                    
                    
                    let cancel = linkClick(target: self, action: #selector(CancelVc))
                    cancel.slotid = Int(detailss[indexPath.section].slots[indexPath.row].slot_id)
                    cell.cancelView.addGestureRecognizer(cancel)


                    cell.cancelAndReponeView.isHidden = true
//                    cell.cancelHeight.constant = 32
//                    cell.cancelReopenHeight.constant = 0
                }

            } else if detailss[indexPath.section].slots[indexPath.row].status == "Upcoming" {

                cell.statusLbl.textColor = .systemCyan
                cell.statusLbl.text = detailss[indexPath.section].slots[indexPath.row].status
                if detailss[indexPath.section].slots[indexPath.row].is_booked == 1 && detailss[indexPath.section].slots[indexPath.row].is_cancelled == 0{


                    cell.cancelView.isHidden = false

                    let cancel = linkClick(target: self, action: #selector(CancelVc))
                    cancel.slotid = Int(detailss[indexPath.section].slots[indexPath.row].slot_id)
                    cell.cancelView.addGestureRecognizer(cancel)



                    cell.cancelAndReponeView.isHidden = false


                    let cancelAndRepone = linkClick(target: self, action: #selector(CancelAndReopenVc))
                    cancelAndRepone.slotid = Int(detailss[indexPath.section].slots[indexPath.row].slot_id)
                    cell.cancelAndReponeView.addGestureRecognizer(cancelAndRepone)

                    cell.cancelHeight.constant = 32
                    cell.cancelReopenHeight.constant = 32
                }

            }else if detailss[indexPath.section].slots[indexPath.row].status == "Expired" {

                cell.statusLbl.textColor = UIColor(named: "Expried")

                cell.statusLbl.text = detailss[indexPath.section].slots[indexPath.row].status
                cell.cancelView.isHidden = true
                cell.cancelAndReponeView.isHidden = true
                cell.cancelHeight.constant = 0
                cell.cancelReopenHeight.constant = 0

            }else if detailss[indexPath.section].slots[indexPath.row].status == "Cancelled" {

                cell.statusLbl.textColor = UIColor(named: "Expried")
                cell.statusLbl.text = detailss[indexPath.section].slots[indexPath.row].status
                cell.cancelView.isHidden = true
                cell.cancelAndReponeView.isHidden = true
                cell.cancelHeight.constant = 0
                cell.cancelReopenHeight.constant = 0
            }else{

                cell.statusLbl.textColor = UIColor(named: "Expried")
                cell.statusLbl.text = detailss[indexPath.section].slots[indexPath.row].status
                cell.cancelView.isHidden = true
                cell.cancelAndReponeView.isHidden = true
                cell.cancelHeight.constant = 0
                cell.cancelReopenHeight.constant = 0
            }




            // date converstion start

            let eventDate = detailss[indexPath.section].slots[indexPath.row].date
            let dateFormatter = DateFormatter()
            // Input format
            dateFormatter.dateFormat = "dd/MM/yyyy"

            if let date = dateFormatter.date(from: eventDate!) {

                dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
                let formattedDate = dateFormatter.string(from: date)

                cell.dateAndTimeLbl.text = formattedDate + "," + detailss[indexPath.section].slots[indexPath.row].from_time + " - " + detailss[indexPath.section].slots[indexPath.row].to_time
                
                print(formattedDate)
            } else {
                print("Invalid date format")
            } // date converstion End
            return cell

        }else{

            let cell = tableView.dequeueReusableCell(withIdentifier: tvcellIdentifier, for: indexPath) as! StaffPtmTableViewCell

            cell.selectionStyle = .none
            cell.backView.layer.cornerRadius = 20
           
            cell.backView.layer.masksToBounds = true
            cell.backView.layer.shadowColor = UIColor.black.cgColor
            cell.backView.layer.shadowOpacity = 0.5
            cell.backView.layer.shadowOffset = CGSize(width: 4, height: 4)
            cell.backView.layer.shadowRadius = 1
            cell.backView.layer.masksToBounds = false
            cell.statusview.layer.masksToBounds = true
            cell.statusview.layer.shadowColor = UIColor.white.cgColor
            cell.statusview.layer.shadowOpacity = 0.5
            cell.statusview.layer.shadowOffset = CGSize(width: 4, height: 4)
            cell.statusview.layer.shadowRadius = 5
            cell.statusview.layer.masksToBounds = false
            let data  : DateWiseModalDataDetails = dateWiseData[indexPath.row]

            cell.studentName.text  = data.eventName

//            cell.studentName.text  = data.studentName

            cell.classSectionLbl.text = data.className + " - " + data.sectionName

            cell.zoomLbl.text = " Mode - " + data.eventMode

            if data.isBooked == 1 && data.slotStatus == "Upcoming"{

                cell.cancelView.isHidden = false
                cell.cancelAndReponeView.isHidden = false

                cell.cancelHeight.constant = 32
                cell.cancelReopenHeight.constant = 32

                let cancel = linkClick(target: self, action: #selector(CancelVc))
                cancel.slotid = data.slotId
                cell.cancelView.addGestureRecognizer(cancel)

                let cancelAndRepone = linkClick(target: self, action: #selector(CancelAndReopenVc))
                cancelAndRepone.slotid = data.slotId
                cell.cancelAndReponeView.addGestureRecognizer(cancelAndRepone)
            }else{

                cell.cancelView.isHidden = true
                cell.cancelAndReponeView.isHidden = true
                cell.cancelHeight.constant = 0
                cell.cancelReopenHeight.constant = 0
            }

            if data.eventLink == ""{

                cell.eventLink.isHidden = true

            }else{

                cell.eventLink.isHidden = false
               
                cell.eventLink.isUserInteractionEnabled = true
                let click = linkClick(target: self, action: #selector(linkClickVC))
                click.link = data.eventLink
                cell.eventLink.addGestureRecognizer(click)


            }


            if data.studentName == ""{

               
                cell.studentName.isHidden = true
            }else{

               
                cell.eventName.text  = data.studentName
            }


            if data.slotStatus == "Completed" {

                cell.statusLbl.textColor = UIColor(named: "completed")
                cell.statusLbl.text = data.slotStatus
                cell.cancelView.isHidden = true
                cell.cancelAndReponeView.isHidden = true
                cell.cancelHeight.constant = 0
                cell.cancelReopenHeight.constant = 0
             

            } else if data.slotStatus == "Available" {

                cell.statusLbl.textColor = UIColor(named: "completed")
                cell.statusLbl.text = data.slotStatus
                cell.cancelView.isHidden = true
                cell.cancelAndReponeView.isHidden = true
                cell.cancelHeight.constant = 0
                cell.cancelReopenHeight.constant = 0
              
            } else if data.slotStatus == "Upcoming" {

                cell.statusLbl.textColor = .systemCyan
                cell.statusLbl.text = data.slotStatus
             

            }else if data.slotStatus == "Expired" {

                cell.statusLbl.textColor = UIColor(named: "Expried")

                cell.statusLbl.text = data.slotStatus
                cell.cancelView.isHidden = true
                cell.cancelAndReponeView.isHidden = true
                cell.cancelHeight.constant = 0
                cell.cancelReopenHeight.constant = 0
               
            }else if data.slotStatus == "Cancelled" {

                cell.statusLbl.textColor = UIColor(named: "Expried")
                cell.statusLbl.text = data.slotStatus
                cell.cancelView.isHidden = true
                cell.cancelAndReponeView.isHidden = true
                cell.cancelHeight.constant = 0
                cell.cancelReopenHeight.constant = 0
               
            }else{

                cell.statusLbl.textColor = UIColor(named: "Expried")
                cell.statusLbl.text = data.slotStatus
                cell.cancelView.isHidden = true
                cell.cancelAndReponeView.isHidden = true
                cell.cancelHeight.constant = 0
                cell.cancelReopenHeight.constant = 0
                
            }




            // date converstion start

            let eventDate = data.eventDate
            let dateFormatter = DateFormatter()
            // Input format
            dateFormatter.dateFormat = "dd/MM/yyyy"

            if let date = dateFormatter.date(from: eventDate!) {

                dateFormatter.dateFormat = "E, MMM d, yyyy"
                let formattedDate = dateFormatter.string(from: date)

                cell.dateAndTimeLbl.text = formattedDate + "," + data.slotFrom + " - " + data.slotTo

                print(formattedDate)
            } else {
                print("Invalid date format")
            } // date converstion End
            return cell
        }

    }


    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
      
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
       
       
        return sectiondeatils.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cvRowIdentifier, for: indexPath) as! SlotsCollectionViewCell
        print("SlotcellForItemAt")
        


        return cell
    }



    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3, height: 50) // Adjust item size as needed
        }
    
    
    
    
    
    
    @IBAction func linkClickVC(ges: linkClick){
        print("linkClickVC")
        openZoomLink(eventLink: ges.link)
    }

       @IBAction func CancelVc(ges: linkClick){
       
           let refreshAlert = UIAlertController(title: "", message: "Are you sure  want to cancel the meeting.", preferredStyle: UIAlertController.Style.alert)

           refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [self] (action: UIAlertAction!) in

               cancelSlot(slotID : ges.slotid)

           }))

           refreshAlert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action: UIAlertAction!) in
               print("Handle Cancel Logic here")
           }))

           present(refreshAlert, animated: true, completion: nil)

    }
     @IBAction func CancelAndReopenVc(ges: linkClick){
       
           let refreshAlert = UIAlertController(title: "", message: "Are you sure  want to CancelAndReopen the meeting.", preferredStyle: UIAlertController.Style.alert)

           refreshAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [self] (action: UIAlertAction!) in

               cancelAndReopenSlot(slotID : ges.slotid)

           }))


           refreshAlert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action: UIAlertAction!) in
               print("Handle Cancel Logic here")
           }))

           present(refreshAlert, animated: true, completion: nil)

    }




    func openZoomLink(eventLink: String) {
        // Encode the URL string to handle spaces and special characters
        guard let encodedLink = eventLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedLink) else {
            print("Invalid URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            // The app is installed, open the link in the app
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // The app is not installed, redirect to the App Store
            let appStoreLink = "https://apps.apple.com/us/app/zoom-cloud-meetings/id546505307" // Zoom's App Store URL
            if let appStoreURL = URL(string: appStoreLink) {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        }
    }

   
    
   
    func dateWiseSlot(){
       
        if  dateLbl.text == "--- Select Date ---"{
            
            nodatalabl.text = "Select date to start"
            nodatalabl.isHidden = false
            tv.isHidden = true
            
            
        }else{
            
            let param : [String : Any] =
            
            
            [
                "staff_id" : staffId ,
                "event_date" :display_date!,
                "institute_id" : instituteId
            ]
            
            
            print("param",param)
            
            
            
            DateWiseSlotDetailsStaffRequest.call_request(param: param)  {
                
                
                [self] (res) in
                
                print("res",res)
                let DateWise : DateWiseModals = Mapper<DateWiseModals>().map(JSONString: res)!
                
                if DateWise.Status == 1 {
                    
                    
                    print("helooo")
                    dateWiseData = DateWise.data
                    nodatalabl.isHidden = true
                    tv.isHidden = false
                    tv.dataSource = self
                    tv.delegate = self
                    tv.reloadData()
                }else{
                    tv.isHidden = true
                    nodatalabl.isHidden = false
                    nodatalabl.text = DateWise.Message
                    
                }
            }
            
        }
        }
        
        
    func StaffDetailsForStaff(){
       
        detailss.removeAll()

            let param : [String : Any] =
            
            
            [
                "staff_id" : staffId,
                "event_date" : display_date!,
                "institute_id" : instituteId
            ]
            
            
            print("param",param)
            
            
            
        SlotDetailsForStaffRequest.call_request(param: param)  {
                
                
                [self] (res) in
                
                print("res",res)
                let DateWise : SlotDetailsForStaffResponse = Mapper<SlotDetailsForStaffResponse>().map(JSONString: res)!
                
                if DateWise.Status == 1 {
                 
                    StaffData = DateWise.data
                    
             
              
                    for i in DateWise.data{
                        detailss.append(contentsOf: i.details)
                       
                    }
                   
                    
                  
                    let firstDetail = DateWise.data.first?.details.first
                    
                    sectiondeatils = (firstDetail?.std_sec_details)!
                    nodatalabl.isHidden = true
                    tv.isHidden = false
                    tv.dataSource = self
                    tv.delegate = self
                    tv.reloadData()
                    
                   
                }else{
                    tv.isHidden = true
                    nodatalabl.isHidden = false
                    nodatalabl.text = DateWise.Message
                    
                }
            }
        
                        
        }








    func cancelSlot(slotID : Int) {

        

            let cancelSlotsForStudModal = CancelSlotsForStudModal()

            cancelSlotsForStudModal.staff_id = staffId
            cancelSlotsForStudModal.slot_id = slotID

            cancelSlotsForStudModal.institute_id = instituteId


            var  cancelSlotsForStudModalStr = cancelSlotsForStudModal.toJSONString()
            print("cancelSlotsForStudModalStr",cancelSlotsForStudModal.toJSON())


            CancelAndCloseSlotStaffRequest.call_request(param: cancelSlotsForStudModalStr!) {

                [self] (res) in

                let cancelSlotsForStudRes : CancelSlotsForStudentsResponse = Mapper<CancelSlotsForStudentsResponse>().map(JSONString: res)!

                if cancelSlotsForStudRes.Status == 1 {

                    let refreshAlert = UIAlertController(title: "", message: cancelSlotsForStudRes.Message, preferredStyle: UIAlertController.Style.alert)

                    refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in

                        if  slotView.backgroundColor == UIColor(named: CustomOrange){
                            
                            StaffDetailsForStaff()
                        }else{
                            
                            
                            dateWiseSlot()
                        }
                    }))
                present(refreshAlert, animated: true, completion: nil)
                }else{

                }



            }

        }

   
        
        func cancelAndReopenSlot(slotID:Int) {

            let cancelSlotsForStudModal = CancelSlotsForStudModal()

            cancelSlotsForStudModal.staff_id = staffId
            cancelSlotsForStudModal.slot_id = slotID
            cancelSlotsForStudModal.institute_id = instituteId


            var  cancelSlotsForStudModalStr = cancelSlotsForStudModal.toJSONString()
            print("cancelSlotsForStudModalStr",cancelSlotsForStudModal.toJSON())

           
            CancelAndReopenSlotStaffRequest.call_request(param: cancelSlotsForStudModalStr!) {

                [self] (res) in

                let cancelSlotsForStudRes : CancelSlotsForStudentsResponse = Mapper<CancelSlotsForStudentsResponse>().map(JSONString: res)!

                if cancelSlotsForStudRes.Status == 1 {

                    
                        let refreshAlert = UIAlertController(title: "", message: cancelSlotsForStudRes.Message, preferredStyle: UIAlertController.Style.alert)

                        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in

                            
                            if  slotView.backgroundColor == UIColor(named: CustomOrange){
                                
                                StaffDetailsForStaff()
                            }else{
                                
                                
                                dateWiseSlot()
                            }
                        
                        }))   
                    present(refreshAlert, animated: true, completion: nil)

                 

                }else{
                    //

                }



            }

        }


        }


    class linkClick : UITapGestureRecognizer{

        var link  : String!
        var slotid : Int!

    }
