//
//  SenderEventsVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 22/11/24.
//

import UIKit
import FSCalendar

class SenderEventsVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet weak var calenderview: FSCalendar!
    
    @IBOutlet weak var Dateview: UIView!
    
    @IBOutlet weak var selectTime: UIDatePicker!
    @IBOutlet weak var DayLabel: UILabel!
    
    @IBOutlet weak var selectDateLabel: UILabel!
    
    @IBOutlet weak var Yearlabel: UILabel!
    @IBOutlet weak var Datelabel: UILabel!
    @IBOutlet weak var Monthlabel: UILabel!
    @IBOutlet weak var TopicTextfield: UITextField!
    @IBOutlet weak var ContentTextfield: UITextField!
    
    @IBOutlet weak var selectDateview: UIView!
    
    @IBOutlet weak var selectTimeView: UIView!
    
    var selecteddate : Date = Date()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let yeartap = UITapGestureRecognizer(target: self, action: #selector(selectyear))
        Yearlabel.addGestureRecognizer(yeartap)
        Yearlabel.isUserInteractionEnabled = true
        
        let dateTap = UITapGestureRecognizer(target: self, action: #selector(Selectdate))
        selectDateview.addGestureRecognizer(dateTap)
        
        
        Dateview.isHidden = true
        calenderview.delegate = self
        calenderview.dataSource = self
        calenderview.scrollDirection = .vertical
        selectTime.layer.backgroundColor = UIColor.button.cgColor
       
        
        if #available(iOS 15.0, *) {
            calenderview.appearance.weekdayTextColor = .systemMint
            calenderview.appearance.selectionColor = .systemMint
            calenderview.appearance.headerTitleColor = .gray
           // calenderview.appearance.
        }
        
        
    }
    
    @objc func selectyear(){
        
        print("fgfgfghfgff")
        calenderview.scope = .month
        calenderview.appearance.weekdayFont = UIFont.systemFont(ofSize: 0)
        calenderview.appearance.titleFont = UIFont.systemFont(ofSize: 0)
        calenderview.appearance.headerDateFormat = "yyyy"
        calenderview.appearance.headerTitleFont = UIFont.systemFont(ofSize: 16)
    }

    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
           if position != .current {
               cell.isHidden = true // Hide dates from the previous or next month
           } else {
               cell.isHidden = false
           }
       }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date() // Set the minimum date to today
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
       

               // Set formats for each label
               dateFormatter.dateFormat = "EEEE" // Day of the week
             DayLabel.text = dateFormatter.string(from: date)

               dateFormatter.dateFormat = "MMM" //  month name
        Monthlabel.text = dateFormatter.string(from: date)

               dateFormatter.dateFormat = "yyyy" // Year
               Yearlabel.text = dateFormatter.string(from: date)

               dateFormatter.dateFormat = "d" // Date of the month
               Datelabel.text = dateFormatter.string(from: date)
        
              dateFormatter.dateFormat = "d MMM yyyy"
              selecteddate = date
    }

    
    @IBAction func Selectdate(_ sender: Any) {
        
        Dateview.isHidden = false
        
        
    }
    
    @IBAction func SelectTime(_ sender: UIDatePicker) {
        
               let selectedTime = sender.date
               let formatter = DateFormatter()
               formatter.timeStyle = .short
               let timeString = formatter.string(from: selectedTime)
               print("Selected time: \(timeString)")
        
               //self.dismiss(animated: true, completion: nil)
      
    }
    
    
    @IBAction func CancelAct(_ sender: Any) {
        
        Dateview.isHidden = true
    }
    
    
    @IBAction func OkAct(_ sender: Any) {
        
        Dateview.isHidden = true
        selectDateLabel.text = dateFormatter.string(from: selecteddate)
    }
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}
