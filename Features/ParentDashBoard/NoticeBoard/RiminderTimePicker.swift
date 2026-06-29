//
//  RiminderTimePicker.swift
//  School Chimes
//
//  Created by Chandhru on 25/07/25.
//

import UIKit

// MARK: - Protocol
protocol TimePicker: AnyObject {
    func timepicker(dateTime: String?)
}

class RiminderTimePicker: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - Variables
    var maximumDate: String?  // e.g., "31-07-2025"
    weak var delegate: TimePicker?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        datePicker.locale = LocaleManager.shared.apiLocale
        
        // Set maximum date if provided
        if let maxDateStr = maximumDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let maxDate = formatter.date(from: maxDateStr) {
                datePicker.maximumDate = maxDate
            }
        }
        
        // Use wheels style for picker
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    // MARK: - Actions
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func selectTime(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.locale = LocaleManager.shared.apiLocale
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        let selectedDate = formatter.string(from: datePicker.date)
        delegate?.timepicker(dateTime: selectedDate)
        dismiss(animated: true)
    }
}
