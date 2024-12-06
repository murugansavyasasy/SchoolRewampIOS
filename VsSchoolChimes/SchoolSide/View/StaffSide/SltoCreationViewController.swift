//
//  SltoCreationViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 23/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import ObjectMapper
import DropDown
import FSCalendar
class SltoCreationViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, FSCalendarDelegate, FSCalendarDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var enterDuratonTextFld: UITextField!
    @IBOutlet weak var linkTextFiledHeight: NSLayoutConstraint!
    
    @IBOutlet weak var eventLinkTextField: UITextField!
    
    @IBOutlet weak var norecord: UILabel!
    
    @IBOutlet weak var purposeTextFld: UITextField!
    @IBOutlet weak var tapToviewLbl: UILabel!
    @IBOutlet weak var selectDateLbl: UILabel!
    @IBOutlet weak var eventModeLbl: UILabel!
    @IBOutlet weak var slotEachLbl: UILabel!
    @IBOutlet weak var breakMinsLbl: UILabel!
    @IBOutlet weak var fullViewSlots: UIView!
    @IBOutlet weak var warningHeight: NSLayoutConstraint!
    @IBOutlet weak var slotBreakSwitch: UISwitch!
    @IBOutlet weak var slotBetweenHeight: NSLayoutConstraint!
    
    @IBOutlet weak var backview: UIView!
    @IBOutlet weak var holeFsCalandeView: UIView!
    
    @IBOutlet weak var FscalanderView: FSCalendar!
    @IBOutlet weak var slotDurationLbl: UILabel!
    @IBOutlet weak var selectDateView: UIViewX!
    @IBOutlet weak var slotDurationView: UIViewX!
    @IBOutlet weak var toTimeView: UIViewX!
    @IBOutlet weak var fromTimeView: UIViewX!
    @IBOutlet weak var warningLabl: UILabel!
    @IBOutlet weak var cvHeigth: NSLayoutConstraint!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var selectModeView: UIViewX!
    
    @IBOutlet weak var slotDefaultlbl: UILabel!
    @IBOutlet weak var selectSlotEachView: UIViewX!
    @IBOutlet weak var btweenDefaultLbl: UILabel!
    @IBOutlet weak var minitsDrop: UIViewX!
    @IBOutlet weak var toTimeLbl: UILabel!
    @IBOutlet weak var fromTime: UILabel!
    var url_time: String!
    var standerdata        : [StandardSectionDetailsForStaffData] = []
    var dat : [DateEntry] = []
    var dateArry : [String] = []
    var  time = ""
  let cvIdentifer = "SlotsCollectionViewCell"
    
    
    var display_date : String!
    
    var timeArry : [String] = []
    let dropDown = DropDown()
    let screenId = 0
    var Id = 0
    var dropDownId : Int!
    var dropDownId1 : Int!
    var classAnsStander : [String] = []
    var instute : Int!
    var staffId : Int!
    var TextStr : Int!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextFiledHeight.constant = 0
        timeArry.removeAll()
        holeFsCalandeView.isHidden = true
        FscalanderView.delegate = self
        FscalanderView.dataSource = self
        purposeTextFld.delegate = self
        FscalanderView.allowsMultipleSelection = true
        slotBetweenHeight.constant = 0
        warningHeight.constant = 0
        slotDefaultlbl.isHidden = true
        selectSlotEachView.isHidden = true
        minitsDrop.isHidden = true
        btweenDefaultLbl.isHidden = true
        tapToviewLbl.isHidden = true
        cv.allowsMultipleSelection = true
        enterDuratonTextFld.isHidden = true
        norecord.isHidden = true
        enterDuratonTextFld.delegate = self
        eventLinkTextField.delegate = self
        eventLinkTextField.inputView = UIView()
        eventLinkTextField.clearButtonMode = .whileEditing
        enterDuratonTextFld.keyboardType = .numberPad
        
        addDoneButtonOnKeyboard()
        let fromTime = UITapGestureRecognizer(target: self, action: #selector(Fromtime))
        fromTimeView.addGestureRecognizer(fromTime) 
        let toTime = UITapGestureRecognizer(target: self, action: #selector(Totime))
        toTimeView.addGestureRecognizer(toTime)    
        let backViess = UITapGestureRecognizer(target: self, action: #selector(BackVC))
        backview.addGestureRecognizer(backViess)
        let selectDate = UITapGestureRecognizer(target: self, action: #selector(DateSelectionVc))
        selectDateView.addGestureRecognizer(selectDate)   
        
        let SlotDur = UITapGestureRecognizer(target: self, action: #selector(slotDurationVC))
        slotDurationView.addGestureRecognizer(SlotDur)  
        let mins = UITapGestureRecognizer(target: self, action: #selector(minsVC))
        minitsDrop.addGestureRecognizer(mins) 
        let modeClick = UITapGestureRecognizer(target: self, action: #selector(modeClicks))
        selectModeView.addGestureRecognizer(modeClick)
        let slotEach = UITapGestureRecognizer(target: self, action: #selector(slotEachvc))
        selectSlotEachView.addGestureRecognizer(slotEach)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapToView))
        tapToviewLbl.addGestureRecognizer(tap)
        
       cv.register(UINib(nibName: cvIdentifer, bundle: nil), forCellWithReuseIdentifier: cvIdentifer)
        slotBreakSwitch.addTarget(self, action: #selector(switchIsChanged), for: UIControl.Event.valueChanged)
        standerAndSec()
    }
    
    
    
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
           if action == #selector(UIResponderStandardEditActions.paste(_:)) {
               if let pastedText = UIPasteboard.general.string, isValidURL(pastedText) {
                   return true
               } else {
                   // Handle invalid URL paste (optional: show an alert)
                   print("Invalid URL pasted")
                   return false
               }
           }
           return false // Disable all other actions
       }
       
       // Helper method to validate if the pasted content is a valid URL
       private func isValidURL(_ urlString: String) -> Bool {
           if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
               return true
           }
           return false
       }
    func addDoneButtonOnKeyboard(){
    let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
    doneToolbar.barStyle = .default

    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

    let items = [flexSpace, done]
    doneToolbar.items = items
    doneToolbar.sizeToFit()

        enterDuratonTextFld.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        enterDuratonTextFld.resignFirstResponder()
        
        if enterDuratonTextFld.text == ""{
            
            
            
        }else{
            
            Id = 0
            TextStr = Int(enterDuratonTextFld.text!)
            dropDownId = Int(enterDuratonTextFld.text!)
            dateVarious()
        }
   
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
            
            for i in DefaultsKeys.dateArr{
                if let index = dateArry.firstIndex(of: i) {
                    dateArry.remove(at: index)
                }
                let dateString = i
                       let dateFormat = "dd-MM-yyyy"
               
                       let dateFormatter = DateFormatter()
                       dateFormatter.dateFormat = dateFormat
               
                       // Convert string to date
                       if let dates = dateFormatter.date(from: dateString) {
                           print("Converted Date:", dates)
                           self.FscalanderView.deselect(dates)
                       } else {
                           print("Failed to convert string to date.")
                       }

        }
        
    }
    

    func calculateHeightForText(_ text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        
        return ceil(boundingBox.height)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder() // Dismiss the keyboard
           return true
       }
    @IBAction func switchIsChanged(mySwitch: UISwitch) {
        
        
        
        if slotBreakSwitch.isOn == true {
            
            slotBetweenHeight.constant = 70
            slotDefaultlbl.isHidden = false
            selectSlotEachView.isHidden = false
            minitsDrop.isHidden = false
            btweenDefaultLbl.isHidden = false
            
        }else{
         
            slotBetweenHeight.constant = 0
            
            slotDefaultlbl.isHidden = true
            selectSlotEachView.isHidden = true
            minitsDrop.isHidden = true
            btweenDefaultLbl.isHidden = true
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return standerdata.count
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cvIdentifer, for: indexPath) as! SlotsCollectionViewCell
        
        
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
            
            print("IFFFFF")
                cell.sectionFullView.backgroundColor = UIColor(named: "AppDark") // Change to your selected color
                cell.sectionLbl.textColor = UIColor.white // Change to your selected text color
            } else {
                
                print("ELSEEEEe")
                cell.sectionFullView.backgroundColor = .lightGray // Change to your deselected color
                cell.sectionLbl.textColor = UIColor.black // Change to your deselected text color
            }
        
        let data : StandardSectionDetailsForStaffData = standerdata[indexPath.row]
        
        
    
        cell.sectionLbl.text = data.class_name + " - " + data.section_name
      
        return cell
    }
    
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SlotsCollectionViewCell {
            // Update cell appearance for selection
            print("didSelectItemAt")
            let data : StandardSectionDetailsForStaffData = standerdata[indexPath.row]
            
            cell.sectionFullView.backgroundColor = UIColor(named: "AppDark")
            cell.sectionLbl.textColor = UIColor.white
            let classid = String(data.class_id)
            let sectionid = String(data.section_id)
            classAnsStander.append(classid + " - " + sectionid)
        }
  
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SlotsCollectionViewCell {
            // Update cell appearance for deselection
            
           print("didDeselectItemAt")
            
            
            let data : StandardSectionDetailsForStaffData = standerdata[indexPath.row]
            
            
            let classid = String(data.class_id)
            let sectionid = String(data.section_id)
           
            
            print("helloo",classAnsStander)
            if classAnsStander.contains(classid + " - " + sectionid){
                
                if let index = classAnsStander.firstIndex(of: classid + " - " + sectionid) {
                    classAnsStander.remove(at: index)
                }
//                classAnsStander.remove(at: indexPath.row)
                
                print("classAnsStander",classAnsStander)
            }
            
            cell.sectionFullView.backgroundColor = .lightGray

            cell.sectionLbl.textColor = UIColor.black
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let data : StandardSectionDetailsForStaffData = standerdata[indexPath.item]
        
        let text = data.class_name + " - " + data.section_name
           let font = UIFont.systemFont(ofSize: 16) // Set your preferred font size
           let width = collectionView.frame.width - 20 // Adjust based on your padding
           
        let height = calculateHeightForText(text, width: width, font: font) + 40// Add padding for margins
           
           return CGSize(width: collectionView.frame.width/3, height: height)
        
//        return CGSize(width: collectionView.frame.width/3, height: 50) // Adjust item size as needed
        }
//    

    @IBAction func cancel(_ sender: Any) {
        
        holeFsCalandeView.isHidden = true
        
        
        
        
    }
    
    @IBAction  func BackVC(){
        dismiss(animated: true)
    }
    
    
    @IBAction func modeClicks(){
        
        let myArray = ["In Person","Online","Phone"]
        
        dropDown.dataSource = myArray//4
        dropDown.anchorView = selectModeView //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            if item == "Online"{
                
                linkTextFiledHeight.constant = 30
            }else{
                
                linkTextFiledHeight.constant = 0
            }
            
        
                
                
            eventModeLbl.text = item
          
            
        }
        
    }
    @IBAction  func slotDurationVC(){
        
       
        if fromTime.text == "Select from time"{
            
            let refreshAlert = UIAlertController(title: "", message: "Select time", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
        }else if toTimeLbl.text == "Select to time"{
            
            
            let refreshAlert = UIAlertController(title: "", message: "Select time", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
        }
 
        else if fromTime.text == toTimeLbl.text {
            
           
             let refreshAlert = UIAlertController(title: "", message: "Invalid time formate", preferredStyle: UIAlertController.Style.alert)
            
                                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
            
                                        toTimeLbl.text = "Select time"
                                }))
                                present(refreshAlert, animated: true, completion: nil)
        }
        else{
            
            Id = 0
            let myArray = [ "10","15","20","30","Custom"]
            
            dropDown.dataSource = myArray//4
            dropDown.anchorView = slotDurationView //5
            
            dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
            
            dropDown.direction = .bottom
            DropDown.appearance().backgroundColor = UIColor.white
            dropDown.show() //7
            
            
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                slotDurationLbl.text = item
                
                if item == "Custom"{
                    
                    enterDuratonTextFld.isHidden = false
                   
                }else{
                    
                    enterDuratonTextFld.isHidden = true
                    dropDownId = Int(item)
                    dateVarious()
                }
               
            }
        }
        
     }
    
    @IBAction  func minsVC(){
        
        
        if fromTime.text == "Select from time" {
            
            let refreshAlert = UIAlertController(title: "", message: "Select time", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
        }
            
            else if  toTimeLbl.text == "Select to time"{
            
                let refreshAlert = UIAlertController(title: "", message: "Select time", preferredStyle: UIAlertController.Style.alert)
               
                                   refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
               
                                       
                                   }))
                               present(refreshAlert, animated: true, completion: nil)
            
        }
            
        else if slotDurationLbl.text == "select duration"{
            
            
            let refreshAlert = UIAlertController(title: "", message: "Select duration", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
            
        }
            
 
        else{
            
            Id = 1
            let myArray = [ "5 Mins","10 Mins","15 Mins"]
            
            dropDown.dataSource = myArray//4
            dropDown.anchorView = minitsDrop //5
            
            dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
            
            dropDown.direction = .bottom
            DropDown.appearance().backgroundColor = UIColor.white
            dropDown.show() //7
            
            
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                breakMinsLbl.text = item
                
                let name = item

                // Split the string by space
                let components = name.components(separatedBy: " ")

                // Extract the first part (e.g., "5")
                let number = components.first ?? ""

                print(number)
                
                dropDownId1 = Int(number)
                dateVarious()
            }
        }
     }
    
    
    
    @IBAction  func slotEachvc(){
        
        
        if fromTime.text == "Select from time" {
            
            let refreshAlert = UIAlertController(title: "", message: "Select time", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
        }
            
            else if  toTimeLbl.text == "Select to time"{
            
                let refreshAlert = UIAlertController(title: "", message: "Select time", preferredStyle: UIAlertController.Style.alert)
               
                                   refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
               
                                       
                                   }))
                               present(refreshAlert, animated: true, completion: nil)
            
        }
            
        else if slotDurationLbl.text == "select duration"{
            
            
            let refreshAlert = UIAlertController(title: "", message: "Select duration", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
            
        }
            
           
       
 
        else{
            
            Id = 1
            let myArray = [ "1","2","3","4"]
            
            dropDown.dataSource = myArray//4
            dropDown.anchorView = selectSlotEachView //5
            
            dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
            
            dropDown.direction = .bottom
            DropDown.appearance().backgroundColor = UIColor.white
            dropDown.show() //7
            
            
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
               slotEachLbl.text = item
                
                let startTime = fromTime.text!
                let endTime = toTimeLbl.text!
                let number = Int(item)
                let intervalMinutes = Int(slotDurationLbl.text!)
                
                let name = breakMinsLbl.text!

                // Split the string by space
                let components = name.components(separatedBy: " ")

                // Extract the first part (e.g., "5")
                let clickNumer = components.first ?? ""

                print(clickNumer)
                let breakMinutes = Int(clickNumer)

                let timeSlots = createTimeSlots(startTime: startTime, endTime: endTime, number: number!, intervalMinutes: intervalMinutes!, breakMinutes: breakMinutes!)

            }
        }
     }
   @IBAction  func Fromtime(){
        
        RPickerTwo.selectDate(title: "Select time", cancelText: "Cancel", datePickerMode: .time, style: .Wheel, didSelectDate: {[weak self] (today_date) in
            
            
            self?.display_date = today_date.dateString("h:mm a")
//            self?.url_time = today_date.dateString("a:mm:hh")
            
            self?.fromTime.text = self!.display_date
            
            
        })
        
    }
    @IBAction  func Totime(){
            
            RPickerTwo.selectDate(title: "Select time", cancelText: "Cancel", datePickerMode: .time, style: .Wheel, didSelectDate: {[weak self] (today_date) in
                
                
                self?.display_date = today_date.dateString("h:mm a")
//                self?.url_time = today_date.dateString("a:mm:hh")
                
                self?.toTimeLbl.text = self!.display_date
                
                   
                print("fromTime.text",self!.fromTime.text)
                print("toTimeLbl.text",self!.toTimeLbl.text)
              
            })
        
        
      
            
        }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let result = formatter.string(from: date)
        selectDateLbl.text = result
        
       
        if !dateArry.contains(result) {
            dateArry.append(result)
        }
      
        
        if dateArry.count == 0{
            
            tapToviewLbl.isHidden = true
            dateSeletedViewClickIntraction()
        }else{
            dateSeletedViewClickIntraction()
            tapToviewLbl.isHidden = false
            
        }
       
      
        // Example print
      
        
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let result = formatter.string(from: date)
        
       
        if let index = dateArry.firstIndex(of: result) {
            dateArry.remove(at: index)
        }
        
        if dateArry.count == 0{
            
            tapToviewLbl.isHidden = true
            dateSeletedViewClickIntraction()
        }else{
            
            tapToviewLbl.isHidden = false
        }
    }
    
    
    @IBAction  func DateSelectionVc(){
        if slotDurationLbl.text == "select duration"{
            let refreshAlert = UIAlertController(title: "", message: "Select duration", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
            
        }else if fromTime.text == "Select from time"{
            let refreshAlert = UIAlertController(title: "", message: "Select time", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
        }else if toTimeLbl.text == "Select to time"{
            
            let refreshAlert = UIAlertController(title: "", message: "Select time", preferredStyle: UIAlertController.Style.alert)
           
                               refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
           
                                   
                               }))
                           present(refreshAlert, animated: true, completion: nil)
        }
        else if classAnsStander.count == 0 {
            
            let refreshAlert = UIAlertController(title: "", message: "Select class", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                
                
            }))
            present(refreshAlert, animated: true, completion: nil)
        }


//        else if  eventModeLbl.text == "Online"{
//            
//            
//            if eventLinkTextField.text == "Paste your Link"{
//                let refreshAlert = UIAlertController(title: "", message: "Event link is must", preferredStyle: UIAlertController.Style.alert)
//                
//                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
//                    
//                    
//                }))
//                present(refreshAlert, animated: true, completion: nil)
//                
//            }else if eventLinkTextField.text == "" {
//                
//                let refreshAlert = UIAlertController(title: "", message: "Event link is must", preferredStyle: UIAlertController.Style.alert)
//                
//                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
//                    
//                    
//                }))
//                present(refreshAlert, animated: true, completion: nil)
//            }
//        }
        
        
        else if  ((purposeTextFld.text?.isEmpty) == nil) {
            
            
            let refreshAlert = UIAlertController(title: "", message: "Enter Purpose", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                
                
            }))
            present(refreshAlert, animated: true, completion: nil)
            
        }

        else{
            holeFsCalandeView.isHidden = false
        }
        }
    
    
    
    @IBAction func datedone(_ sender: Any) {
        
        holeFsCalandeView.isHidden = true
        
        
        print("eventMode",eventModeLbl.text)
        print("EventLibnk",eventLinkTextField.text)
        
        var dateEntries: [DateEntry] = []
        
        for date in dateArry {
           
            var slots: [TimeSlot] = []
          
            for timeIndex in timeArry {
                
                let timeSlot = TimeSlot(from: timeIndex)
                    slots.append(timeSlot)
            
            }
           
            let dateEntry = DateEntry(date: date, slots: slots)
            dateEntries.append(dateEntry)
        }

        // Example print
        var slots1: [TimeSlot] = []
        for entry in dateEntries {
            print("Date: \(entry.date)")
            for slot in entry.slots {
                print("  Slot: From \(slot.from) ")
                slots1.append(slot)
            }
        }
        
        
        
        let vc = CheckAviableViewController(nibName: nil, bundle: nil)
        vc.screenId = 1
        vc.dat = dateEntries
        vc.StdAryy = classAnsStander
        vc.datStr = dateArry
        vc.timeStr = timeArry
        vc.staffId = staffId
        vc.instuteId = instute
        
        let name = breakMinsLbl.text!

        // Split the string by space
        let components = name.components(separatedBy: " ")

        // Extract the first part (e.g., "5")
        let clickNumer = components.first ?? ""

        print(clickNumer)
        let breakMinutes = Int(clickNumer)
        vc.break_time = Int(clickNumer)!
        vc.duration =   Int(slotDurationLbl.text!)
        vc.event_name = purposeTextFld.text!
        vc.from_time = fromTime.text!
        vc.to_time = toTimeLbl.text!
        vc.meeting_mode = eventModeLbl.text!
        vc.event_link = eventLinkTextField.text!
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    @IBAction func tapToView(){
        
        
        var dateEntries: [DateEntry] = []
        
        for date in dateArry {
           
            var slots: [TimeSlot] = []
          
            for timeIndex in timeArry {
                
                let timeSlot = TimeSlot(from: timeIndex)
                    slots.append(timeSlot)
            
            }
           
            let dateEntry = DateEntry(date: date, slots: slots)
            dateEntries.append(dateEntry)
        }

        // Example print
        var slots1: [TimeSlot] = []
        for entry in dateEntries {
            print("Date: \(entry.date)")
            for slot in entry.slots {
                print("  Slot: From \(slot.from) ")
                slots1.append(slot)
            }
        }
        
        
        if dateArry.count == 0{
            
            
            
        }else{
            let vc = CheckAviableViewController(nibName: nil, bundle: nil)
            vc.screenId = 1
            vc.dat = dateEntries
            vc.StdAryy = classAnsStander
            vc.datStr = dateArry
            vc.timeStr = timeArry
            vc.staffId = staffId
            vc.instuteId = instute
            let name = breakMinsLbl.text!

            // Split the string by space
            let components = name.components(separatedBy: " ")

            // Extract the first part (e.g., "5")
            let clickNumer = components.first ?? ""

            print(clickNumer)
            vc.break_time = Int(clickNumer)!
            vc.duration =   Int(slotDurationLbl.text!)
            vc.event_name = purposeTextFld.text!
            vc.from_time = fromTime.text!
            vc.to_time = toTimeLbl.text!
            vc.meeting_mode = eventModeLbl.text!
            vc.event_link = eventLinkTextField.text!
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    func dateVarious(){
        
        if Id == 0{
            
            
        }else{
            
            timeArry.removeAll()
            
        }
        
        
       
        if Id == 0{
            if slotDurationLbl.text == "Custom"{
                
                }
            
            else{
                
                TextStr = Int(slotDurationLbl.text!)
            }
        }else{
            
            TextStr =  dropDownId + dropDownId1

        }
        let durtation = TextStr
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // 12-hour format with AM/PM
      
        let startTimeString = fromTime.text
        let endTimeString = toTimeLbl.text

        // Convert the start and end times to Date objects
        if let startTime = dateFormatter.date(from: startTimeString!), let endTime = dateFormatter.date(from: endTimeString!) {
            
            var currentTime = startTime
            
            // Loop to add 10 minutes until the end time is reached
            while currentTime < endTime {
                let nextTime = Calendar.current.date(byAdding: .minute, value: durtation!, to: currentTime)!
                
                // Print the current time interval
                print("\(dateFormatter.string(from: currentTime)) to \(dateFormatter.string(from: nextTime))")
                
                
                
                timeArry.append(dateFormatter.string(from: currentTime) + " - " + dateFormatter.string(from: nextTime))
                

                currentTime = nextTime
            }
        }
        
        
    }
    
    func createTimeSlots(startTime: String, endTime: String, number: Int, intervalMinutes: Int, breakMinutes: Int) -> [TimeSlot] {
        
        timeArry.removeAll()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        guard let start = dateFormatter.date(from: startTime),
              let end = dateFormatter.date(from: endTime) else {
            print("Invalid start or end time format")
            return []
        }
        
        var timeSlots: [TimeSlot] = []
        var currentTime = start
        var slotCount = 0
        
        while currentTime < end {
            let nextTime = Calendar.current.date(byAdding: .minute, value: intervalMinutes, to: currentTime)!
            
            if nextTime > end {
                break
            }
          
            
            timeArry.append(dateFormatter.string(from: currentTime) + " - " + dateFormatter.string(from: nextTime))
            currentTime = nextTime
            slotCount += 1
            
            // After every 'number' slots, add a break
            if slotCount % number == 0 {
                currentTime = Calendar.current.date(byAdding: .minute, value: breakMinutes, to: currentTime)!
            }
        }
        
        return timeSlots
    }

    
    
    func dateSeletedViewClickIntraction(){
       
        if dateArry.count == 0 {
            
          
          
            
            warningHeight.constant = 0
            minitsDrop.isUserInteractionEnabled = true
            fromTimeView.isUserInteractionEnabled = true
            toTimeView.isUserInteractionEnabled = true
            slotDurationView.isUserInteractionEnabled = true
            selectSlotEachView.isUserInteractionEnabled = true
            fullViewSlots.backgroundColor  = .white
        }else{
            print("ELSEEEEE.countdateArry.count",dateArry.count)
            warningHeight.constant = 41
            minitsDrop.isUserInteractionEnabled = false
            fromTimeView.isUserInteractionEnabled = false
            toTimeView.isUserInteractionEnabled = false
            slotDurationView.isUserInteractionEnabled = false
            selectSlotEachView.isUserInteractionEnabled = false
            fullViewSlots.backgroundColor  = .white
            
        }
        
        
    }
    @IBAction  func ChechAviabel(){
            

            
        }
    
    
    
    func standerAndSec(){
        
       
        
        let param : [String : Any] =
        [

            "staff_id": staffId!,

            "institute_id": instute!


        ]

        print("paramparam",param)

        StandardSectionDetailsStaffRequest.call_request(param: param){ [self]
            (res) in

            print("resres",res)
            let slotHistoryResponse : StandardSectionDetailsForStaffResponse = Mapper<StandardSectionDetailsForStaffResponse>().map(JSONString: res)!


            if slotHistoryResponse.Status == 1  {
                norecord.isHidden = true
                
                cv.isHidden = false
                standerdata = slotHistoryResponse.data
                
                let itemCount = standerdata.count
                adjustCollectionViewHeight(for: itemCount)
                cv.dataSource = self
                cv.delegate = self
                cv.reloadData()
                
                

            }else{
                norecord.isHidden = false
                
                let refreshAlert = UIAlertController(title: "", message: slotHistoryResponse.Message, preferredStyle: UIAlertController.Style.alert)

                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in

                    dismiss(animated: true)
                }))
            present(refreshAlert, animated: true, completion: nil)
                norecord.text = slotHistoryResponse.Message
                
                
                
                cv.isHidden = true
            }
        }
        
        
    }
    
    func adjustCollectionViewHeight(for itemCount: Int) {
        var height: CGFloat = 55  // Default height for 1 to 3 items
        
        if itemCount > 3 {
            let extraRows = (itemCount - 1) / 3  // Calculate additional rows beyond the first row
            height += CGFloat(extraRows) * 60  // Increase height for each additional row
        }
        
        
        
        
        // Update the collection view's height constraint
        cvHeigth.constant = height
        cv.layoutIfNeeded()  // Apply the changes
    }
   
   
    
    
    }




struct DateEntry {
    var date: String
    var slots: [TimeSlot]
}
struct TimeSlot {
    var from: String
   
}
