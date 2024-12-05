//
//  SenderSideOnlineMeetingViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/30/24.
//

import UIKit
import DropDown

class SenderSideOnlineMeetingViewController: UIViewController {
    
    @IBOutlet weak var selectMeetingDropDownLbl: UILabel!
    @IBOutlet weak var selectMeetingDropDownView: UIView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var selectTimeView: UIView!
    
    @IBOutlet weak var selectDateView: UIView!
    @IBOutlet weak var selectMeetingLinkView: UIView!
    
    let dropDown = DropDown()
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
 
        
        
        timePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        timePicker.datePickerMode = .time
        timePicker.minimumDate = Date()
 
        
        let selectMeetingGesture = UITapGestureRecognizer(target: self, action: #selector(categoryDropdown))
        selectMeetingDropDownView.addGestureRecognizer(selectMeetingGesture)
        let backGest = UITapGestureRecognizer(target: self, action: #selector(backVc))
        backView.addGestureRecognizer(backGest)
        
        // Do any additional setup after loading the view.
    }

    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
       
        self.dismiss(animated: true, completion: nil)
        let selectedDate = sender.date
        print("Selected Date: \(selectedDate)")
      
        }
    
    
    
    @IBAction func backVc() {
        dismiss(animated: true)
    }

    
    @IBAction  func categoryDropdown (){
        
       
        dropDown.dataSource = ["GOOGLE MEET", "ZOOM MEETING", "MICROSOFT TEAM", "OTHERS"]
        dropDown.bottomOffset = CGPoint(x: 0, y:(selectMeetingDropDownView.bounds.height))
        
        dropDown.direction = .bottom
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
               print("Selected item: \(item) at index: \(index)")
               
               // Update the label inside the UIView
            if let label = self?.selectMeetingDropDownView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self!.selectMeetingDropDownLbl.text = item
               }
               
           
            
           }
      
    }
}
