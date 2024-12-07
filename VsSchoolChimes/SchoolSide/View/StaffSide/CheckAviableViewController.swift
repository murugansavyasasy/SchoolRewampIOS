//
//  CheckAviableViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 23/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import ObjectMapper



class CheckAviableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var checkAvilbDefltLbl: UILabel!
    @IBOutlet weak var checkAviablityView: UIViewX!
    @IBOutlet weak var tv: UITableView!
    var dat : [DateEntry] = []

    var timeStr : [String] = []
    var datStr : [String] = []
    var header = "CheckAviableTvHeader"
    var tvcellIdentifier = "CheckAviableTv"
    var screenId : Int!
    var StdAryy : [String] = []
    var ApiID = 0
    var slots : [slotDataDetails] = []
    var validatedata : [RespDataDetails] = []
    var break_time  = 0
  
    var duration :  Int!
    var event_name = ""
    var from_time = ""
    var to_time = ""
    var meeting_mode = ""
    var event_link = ""
    var datesShow = ""
  var ApiCallDate : [String] = []
    var staffId  : Int!
    var instuteId : Int!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ApiID = 0
        
        screenId = 1
        
        DefaultsKeys.dateArr.removeAll()
        
        checkAvilbDefltLbl.text = "Check slot avilibality"
        tv.register(UINib(nibName: tvcellIdentifier, bundle: nil), forCellReuseIdentifier: tvcellIdentifier)
        
        let rownib2 = UINib(nibName: header, bundle: nil)
        tv.register(rownib2, forHeaderFooterViewReuseIdentifier: header)
        let checkAvibale = UITapGestureRecognizer(target: self, action: #selector(chechVc))
        checkAviablityView.addGestureRecognizer(checkAvibale)
        let back = UITapGestureRecognizer(target: self, action: #selector(backVC))
        backView.addGestureRecognizer(back)
        
        
        
        tv.dataSource = self
        tv.delegate = self
        tv.reloadData()
        
    }
    
    
    @IBAction func backVC(){
        
        dismiss(animated: true)
    }
    
    func checkAviable(){
        
        ApiID = 1
        var AviableModal1 : [ValidationforStaffModal] = []
        
        for i in dat{
            
            let AviableModal = ValidationforStaffModal()
            
            AviableModal.institute_id = instuteId
            AviableModal.break_time = break_time
            AviableModal.date = i.date
            AviableModal.duration = duration
            AviableModal.event_name = event_name
            AviableModal.from_time = from_time
            AviableModal.to_time = to_time
            AviableModal.meeting_mode = meeting_mode
            AviableModal.event_link = event_link
            var aviablemodel : [slotDataDetails] = []
            var stdModal : [sectionDataDetails] = []
            for zi in i.slots {
                let times = zi.from.components(separatedBy: " - ")
                //                aviablemodel[0].
                
                let slotmodalss  = slotDataDetails()
                
                slotmodalss.from_time = times[0]
                slotmodalss.to_time = times[1]
                
                
                aviablemodel.append(slotmodalss)
                
                
            }
            AviableModal.slots = aviablemodel
            for std in StdAryy{
                let example = std.components(separatedBy: " - ")
                
                let stdmodals  = sectionDataDetails()
                stdmodals.class_id = Int(example[0])
                stdmodals.section_id = Int(example[1])
                
                stdModal.append(stdmodals)
                
                
                
            }
            AviableModal.std_sec_details = stdModal
            AviableModal.staff_id = staffId
            
            AviableModal1.append(AviableModal)
            
        }
            var  AviableModalStr = AviableModal1.toJSONString()
            
            
            ValidateSlotStaffRequest.call_request(param: AviableModalStr!) {
                
                [self] (res) in
                print("aviablLity",res)
                
                let cancelSlotsForStudRes : aviableSlotResponce = Mapper<aviableSlotResponce>().map(JSONString: res)!
                
                if cancelSlotsForStudRes.Status == 1 {
                    
                    
                        validatedata = cancelSlotsForStudRes.data

                        checkAvilbDefltLbl.text = "Submit"
                        tv.dataSource = self
                        tv.delegate = self
                        tv.reloadData()
                  
                }else{
                    
                    
                    
                    
                }
                
                
                
            }
            
        
        
    }
    
    @IBAction func chechVc(){
        
        
        if  checkAvilbDefltLbl.text == "Check slot avilibality"{
            checkAviable()
            
        }else{
            
            
            let refreshAlert = UIAlertController(title: "", message: "Are you sure do you want to Submit?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in


          
                submit()
          
            }))


            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
            }))

            present(refreshAlert, animated: true, completion: nil)
            
            
           
        }
      
    }
    
    
    
    @IBAction func submit(){
       
        var AviableModal1 : [ValidationforStaffModal] = []
        
        for i in validatedata{
            
            let AviableModal = ValidationforStaffModal()
            
            AviableModal.institute_id = instuteId
            AviableModal.break_time = break_time
            AviableModal.date = i.date
            AviableModal.duration = duration
            AviableModal.event_name = event_name
            AviableModal.from_time = from_time
            AviableModal.to_time = to_time
            AviableModal.meeting_mode = meeting_mode
            AviableModal.event_link = event_link
            var aviablemodel : [slotDataDetails] = []
            var stdModal : [sectionDataDetails] = []
            
            
            
            for zi in i.slots {
                
                if ApiCallDate.contains(zi.from_time + "-" + zi.to_time){
                    
                    
                }
//
                let slotmodalss  = slotDataDetails()
                
                slotmodalss.from_time = zi.from_time
                slotmodalss.to_time = zi.to_time
               
                aviablemodel.append(slotmodalss)
           
            }
            AviableModal.slots = aviablemodel
            for std in i.std_sec_details{
                
                let stdmodals  = sectionDataDetails()
                stdmodals.class_id = std.class_id
                stdmodals.section_id = std.section_id
                
                stdModal.append(stdmodals)
          
            }
            AviableModal.std_sec_details = stdModal
            AviableModal.staff_id = staffId
            
            AviableModal1.append(AviableModal)
            
        }
            var  AviableModalStr = AviableModal1.toJSONString()
           
        print("cancelSlotsForStudModalStr",AviableModal1.toJSON())
            CreateSlotByStaffRequest.call_request(param: AviableModalStr!) {
                
                [self] (res) in
                
                print("cancelSlotsForStudModalStr",res)
                
                
                let cancelSlotsForStudRes : aviableSlotResponce = Mapper<aviableSlotResponce>().map(JSONString: res)!
                
                if cancelSlotsForStudRes.Status == 1 {
                    
                    let refreshAlert = UIAlertController(title: "", message: cancelSlotsForStudRes.Message, preferredStyle: UIAlertController.Style.alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                       
//                        dismiss(animated: true)
                        self.presentingViewController!.presentingViewController!.dismiss(animated: false, completion: nil)
                    }))
                    present(refreshAlert, animated: true, completion: nil)
                }else{
                    
                }
            
            }

     
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if ApiID == 0 {
            
            return dat[section].date
            
        }else{
            
            
            return validatedata[section].date
        }
           
        }

    func numberOfSections(in tableView: UITableView) -> Int {
        if ApiID == 0 {
            return dat.count
        }else{
            
            return validatedata.count
        }
        
       
      }
    
    
            func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: header) as! CheckAviableTvHeader
                
                if ApiID == 0{
                    let eventDate = dat[section].date
                    
                    let dateFormatter = DateFormatter()
                    // Input format
                    dateFormatter.dateFormat = "dd/MM/yyyy"

                    if let date = dateFormatter.date(from: eventDate) {

                        dateFormatter.dateFormat = "E, MMM d, yyyy"
                        let formattedDate = dateFormatter.string(from: date)

                        headerView.dateLbl.text = formattedDate

                        print(formattedDate)
                    } else {
                        print("Invalid date format")
                    } // date converstion End
                
                    
                    
                }else{
                    
                    let eventDate = validatedata[section].date
                    
                    let dateFormatter = DateFormatter()
                    // Input format
                    dateFormatter.dateFormat = "dd/MM/yyyy"

                    if let date = dateFormatter.date(from: eventDate!) {

                        dateFormatter.dateFormat = "E, MMM d, yyyy"
                        let formattedDate = dateFormatter.string(from: date)

                        headerView.dateLbl.text = formattedDate

                        print(formattedDate)
                    } else {
                        print("Invalid date format")
                    } // date converstion End
                
                    
                }
              
                return headerView
            }
    
         
           
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if ApiID == 0 {
            
            return dat[section].slots.count
        }else{
            
            return validatedata[section].slots.count
        }
      
      
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: tvcellIdentifier, for: indexPath) as! CheckAviableTv
        
        if ApiID == 0 {
           
            cell.statusLbl.isEnabled = true
         
            cell.timeLbl.text = dat[indexPath.section].slots[indexPath.row].from
            
            cell.indexPath = indexPath
                   
                   // Set the delete action closure
                   cell.deleteAction = { [weak self] indexPath in
                       self?.deleteTimeSlot(at: indexPath)
                   }
                   
        
        }else{
            
            

            
            cell.statusLbl.isHidden = false
            cell.timeLbl.text = validatedata[indexPath.section].slots[indexPath.row].from_time + "-" + validatedata[indexPath.section].slots[indexPath.row].to_time
            
            
            cell.statusLbl.text = validatedata[indexPath.section].slots[indexPath.row].slot_Availablity
           
            if validatedata[indexPath.section].slots[indexPath.row].slot_Availablity == "Not Available"{
                
                cell.deleteView.isHidden = true
                checkAviablityView.isHidden = true
                 
                cell.statusLbl.textColor = .red
                
                
            }else{
                
                cell.statusLbl.textColor = UIColor(named: "checkColor")
                cell.deleteView.isHidden = false
                checkAviablityView.isHidden = false
                cell.indexPath = indexPath
                       
                       // Set the delete action closure
                       cell.deleteAction = { [weak self] indexPath in
                           self?.deleteTimeSlot(at: indexPath)
                       }
                
            }
                
            
            
           
        }
       
        
      
        return cell


    }
    
    

   
    func deleteTimeSlot(at indexPath: IndexPath) {
        // Safety check: ensure the section and row exist before attempting deletion
        
        if ApiID == 0 {
            
            guard indexPath.section < dat.count else { return }
            guard indexPath.row < dat[indexPath.section].slots.count else { return }
            print("datReoveguard")
            // Remove the time slot at the given indexPath
            dat[indexPath.section].slots.remove(at: indexPath.row)
            
            // If the section has no more slots, remove the section
            if dat[indexPath.section].slots.isEmpty {
                print("datReoveIFF", dat[indexPath.section].date)
                DefaultsKeys.dateArr.append(dat[indexPath.section].date)
                dat.remove(at: indexPath.section)
               
                tv.performBatchUpdates({
                    tv.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                }, completion: nil)
            } else {
                
                print("datReoveELSE")
                tv.performBatchUpdates({
                    tv.deleteRows(at: [indexPath], with: .automatic)
                }, completion: nil)
            }
            
        }else{
            guard indexPath.section < validatedata.count else { return }
            guard indexPath.row < validatedata[indexPath.section].slots.count else { return }
            
            // Remove the time slot at the given indexPath
            validatedata[indexPath.section].slots.remove(at: indexPath.row)
            
            // If the section has no more slots, remove the section
            if validatedata[indexPath.section].slots.isEmpty {
                validatedata.remove(at: indexPath.section)
                tv.performBatchUpdates({
                    tv.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                }, completion: nil)
            } else {
                tv.performBatchUpdates({
                    tv.deleteRows(at: [indexPath], with: .automatic)
                }, completion: nil)
            }
            
            
        }
           }
       
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
      
    }
}


class deletes : UITapGestureRecognizer{
    
    var time  : String!
    var deleteId  : Int!
    
}
