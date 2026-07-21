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
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    var delegate : Datepicker?
    var date : String?
    var dateSelection = 1
    var minimumDate: Date?
    var maximumDate: Date?
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = LocaleManager.shared.displayLocale
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUi()
        configurePicker()
        updateFormattedDate()
        datepicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    private func configureUi(){
        
        cancelBtn.setTitle("Cancel".translated(), for: .normal)
        doneBtn.setTitle("Done".translated(), for: .normal)
        
        bgView.layer.cornerRadius = 10
        outerView.layer.cornerRadius = 10
        
        datepicker.tintColor = UIColor.primery
    }
    
    private func configurePicker(){
        
        datepicker.locale = LocaleManager.shared.displayLocale
        
        datepicker.minimumDate = minimumDate
        datepicker.maximumDate = maximumDate
        
        if dateSelection == 2 {
            datepicker.datePickerMode = .date
            datepicker.preferredDatePickerStyle = .inline
        } else {
            datepicker.datePickerMode = .time
            datepicker.preferredDatePickerStyle = .wheels
        }
        
        if let inputDate = dateConvert(date ?? "") {
            datepicker.date = inputDate
        } else {
            datepicker.date = Date()
        }
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

