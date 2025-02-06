//
//  DatePickerVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 29/01/25.
//

import UIKit

protocol Datepicker{
    func date(date:String)
}

@available(iOS 14.0, *)
class DatePickerVC: UIViewController {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var datepicker: UIDatePicker!
    var delegate : Datepicker?
    var date : String?
    var dateSelection:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        datepicker.locale = .current
        datepicker.date = Date()
        bgView.layer.cornerRadius = 10
        outerView.layer.cornerRadius = 10
        if dateSelection != 2{
            datepicker.datePickerMode = .time
            datepicker.preferredDatePickerStyle = .wheels
        }else{
            datepicker.datePickerMode = .date
            datepicker.preferredDatePickerStyle = .inline
        }
        dateformate()
        datepicker.addTarget(self, action: #selector(dateselect), for: .valueChanged)
    }
    @objc func dateselect(){
        dateformate()
    }
    func dateformate() {
         let dateFormatter = DateFormatter()
         if dateSelection == 2 {
             dateFormatter.dateFormat = "dd MMM yy" //"dd-MM-yyyy"// Date format
         } else {
             dateFormatter.dateFormat =  "hh:mm a" // Time format
         }
         date = dateFormatter.string(from: datepicker.date)
     }
    @IBAction func done(_ sender: UIButton) {
        delegate?.date(date: self.date ?? "")
        dismiss(animated: false)
    }
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
}

