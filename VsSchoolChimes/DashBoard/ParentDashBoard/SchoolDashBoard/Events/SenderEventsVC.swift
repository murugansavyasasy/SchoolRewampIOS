//
//  SenderEventsVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 22/11/24.
//

import UIKit
import FSCalendar

class SenderEventsVC: UIViewController{
    
  
    
    
    @IBOutlet weak var selectDate: UIDatePicker!
    @IBOutlet weak var selectTime: UIDatePicker!
    @IBOutlet weak var TopicTextfield: UITextField!
    @IBOutlet weak var ContentTextview: UITextView!
    
    @IBOutlet weak var SubmitBtn: UIButton!
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectDate.minimumDate = Date()
       // selectTime.layer.backgroundColor = UIColor.button.cgColor
       
        ContentTextview.text = "Type content"
        ContentTextview.textColor = UIColor.lightGray
        
        TopicTextfield.delegate = self
        ContentTextview.delegate = self
        
        SubmitBtn.backgroundColor = UIColor.systemGray4
        SubmitBtn.layer.cornerRadius = Colornames.CORadius10
    }
    
   
   
    @IBAction func SelectDate(_ sender: Any) {
       
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SelectTime(_ sender: UIDatePicker) {
        
               let selectedTime = sender.date
              
        dateFormatter.timeStyle = .short
               let timeString = dateFormatter.string(from: selectedTime)
               print("Selected time: \(timeString)")
        
               //self.dismiss(animated: true, completion: nil)
      
    }
    
    
    @IBAction func SubmitBtnAct(_ sender: Any) {
        
        if SubmitBtn.backgroundColor == UIColor.button{
            print("submited successfully")
        }
        else{
            print("Not submited")
        }
    }
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}

extension SenderEventsVC : UITextFieldDelegate,UITextViewDelegate{
    
    func updateButtonColor() {
        let textFieldIsNotEmpty = !(TopicTextfield.text?.isEmpty ?? true)
        let textViewIsNotEmpty = !(ContentTextview.text?.isEmpty ?? true)
            let textViewHasPlaceholder = ContentTextview.text == "Type content"
            
            if textFieldIsNotEmpty && textViewIsNotEmpty && !textViewHasPlaceholder {
                SubmitBtn.backgroundColor = .button
            } else {
                SubmitBtn.backgroundColor = .systemGray4
            }
        }
        
        // UITextField Delegate method to detect changes
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            updateButtonColor()
            return true
        }
        
        // UITextView Delegate method to detect changes
        func textViewDidChange(_ textView: UITextView) {
            updateButtonColor()
        }
        
        // Optional: UITextView Delegate to handle editing did begin (e.g., clear placeholder if needed)
        func textViewDidBeginEditing(_ textView: UITextView) {
            if ContentTextview.text == "Type content" {
                ContentTextview.text = ""
                ContentTextview.textColor = .black
            }
            updateButtonColor()
        }
        
        // Optional: UITextView Delegate to handle editing did end (e.g., restore placeholder if needed)
        func textViewDidEndEditing(_ textView: UITextView) {
            if ContentTextview.text.isEmpty {
                ContentTextview.text = "Type content" // Restore placeholder
                ContentTextview.textColor = .lightGray // Placeholder color
            }
            updateButtonColor()
        }
    }
