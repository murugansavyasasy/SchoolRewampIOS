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
    var dateSelection = 1
    var minimumDate: Date?
    var maximumDate: Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let savedCode = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        let normalizedCode = normalizedLocaleIdentifier(for: savedCode)
        let locale = Locale(identifier: normalizedCode)
        
        datepicker.locale = locale
        
        if let date = minimumDate {
            datepicker.minimumDate = date
        }
        
        if let date = maximumDate {
            
            datepicker.maximumDate = date
        }
        
        bgView.layer.cornerRadius = 10
        outerView.layer.cornerRadius = 10
       // datepicker.locale = .current
        
        // Set picker mode and style
        if dateSelection == 2 {
            datepicker.datePickerMode = .date
            datepicker.preferredDatePickerStyle = .inline
        } else {
            datepicker.datePickerMode = .time
            datepicker.preferredDatePickerStyle = .wheels
        }
        
        // Set initial selected date if provided
        if let inputDate = dateConvert(date ?? "") {
            datepicker.date = inputDate
        } else {
            datepicker.date = Date()
        }
        updateFormattedDate()
        datepicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    func dateConvert(_ dateString: String) -> Date? {
        let formats = [
            "EEE d MMM yyyy",
            "EEEE d MMMM yyyy",
            "d/M/yyyy",
            "yyyy-MM-dd",
            "MMM d, yyyy",
            "dd MMM yy",
            "hh:mm a"
        ]
        
        let savedCode = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        let normalizedCode = normalizedLocaleIdentifier(for: savedCode)
        let locale = Locale(identifier: normalizedCode)
    
        let formatter = DateFormatter()
        formatter.locale = locale
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
    
    @objc func dateChanged() {
        updateFormattedDate()
    }
    
    func updateFormattedDate() {
        let savedCode = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        let normalizedCode = normalizedLocaleIdentifier(for: savedCode)
        let locale = Locale(identifier: normalizedCode)
        
        let formatter = DateFormatter()
        formatter.locale = locale
        
        if dateSelection == 2 {
            formatter.dateFormat = "dd MMM yyy"
        } else {
            formatter.dateFormat = "hh:mm a"
        }
        
        date = formatter.string(from: datepicker.date)
    }
    
    @IBAction func done(_ sender: UIButton) {
        delegate?.date(date: self.date ?? "")
        dismiss(animated: false)
    }
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: false)
    }
    
}

