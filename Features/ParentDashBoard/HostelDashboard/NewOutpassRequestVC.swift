import UIKit

class NewOutpassRequestVC: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    @IBOutlet weak var fromTimeTextField: UITextField!
    @IBOutlet weak var toTimeTextField: UITextField!
    @IBOutlet weak var emergencyContactTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var firstCardView: UIView!
    @IBOutlet weak var secondCardView: UIView!
    
    // date and time views
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var toDateView: UIView!
    @IBOutlet weak var fromTimeView: UIView!
    @IBOutlet weak var toTimeView: UIView!
    @IBOutlet weak var destinationView: UIView!
    @IBOutlet weak var contactView: UIView!

    private let fromDatePicker = UIDatePicker()
    private let toDatePicker = UIDatePicker()
    private let fromTimePicker = UIDatePicker()
    private let toTimePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPickers()
    }

    func setupUI() {
        // Corner Radii
        firstCardView.layer.cornerRadius = 16
        secondCardView.layer.cornerRadius = 16
        
        reasonTextView.layer.cornerRadius = 8
        destinationView.layer.cornerRadius = 8
        fromDateView.layer.cornerRadius = 8
        toDateView.layer.cornerRadius = 8
        fromTimeView.layer.cornerRadius = 8
        toTimeView.layer.cornerRadius = 8
        contactView.layer.cornerRadius = 8
        
        submitBtn.layer.cornerRadius = 8
        
        // UITextView inward padding
        reasonTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        // Back Button action
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    @objc func backTapped() {
       dismiss(animated: true)
    }
    
    // MARK: - Picker Setup
    func setupPickers() {
        // Prevent selecting dates in the past
        let today = Date()
        fromDatePicker.minimumDate = today
        toDatePicker.minimumDate = today
        
        setupDatePicker(for: fromDateTextField, picker: fromDatePicker, mode: .date)
        setupDatePicker(for: toDateTextField, picker: toDatePicker, mode: .date)
        setupDatePicker(for: fromTimeTextField, picker: fromTimePicker, mode: .time)
        setupDatePicker(for: toTimeTextField, picker: toTimePicker, mode: .time)
    }

    func setupDatePicker(for textField: UITextField, picker: UIDatePicker, mode: UIDatePicker.Mode) {
        picker.datePickerMode = mode
        if #available(iOS 14.0, *) {
            picker.preferredDatePickerStyle = mode == .date ? .inline : .wheels
        }

        textField.inputView = picker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneBtn], animated: false)
        textField.inputAccessoryView = toolbar

        picker.addTarget(self, action: #selector(datePickerChanged(_:)), for: .valueChanged)
    }

    @objc func datePickerChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        if sender == fromDatePicker {
            formatter.dateFormat = "MMMM d, yyyy"
            fromDateTextField.text = formatter.string(from: sender.date)
            
            // "toDate" cannot be before the newly selected "fromDate"
            toDatePicker.minimumDate = sender.date
            if toDatePicker.date < sender.date {
                toDatePicker.date = sender.date
                toDateTextField.text = formatter.string(from: sender.date)
            }
            
            print("Selected From Date: \(fromDateTextField.text ?? "")")
        } else if sender == toDatePicker {
            formatter.dateFormat = "MMMM d, yyyy"
            toDateTextField.text = formatter.string(from: sender.date)
            print("Selected To Date: \(toDateTextField.text ?? "")")
        } else if sender == fromTimePicker {
            formatter.dateFormat = "hh:mm a"
            fromTimeTextField.text = formatter.string(from: sender.date)
            print("Selected From Time: \(fromTimeTextField.text ?? "")")
        } else if sender == toTimePicker {
            formatter.dateFormat = "hh:mm a"
            toTimeTextField.text = formatter.string(from: sender.date)
            print("Selected To Time: \(toTimeTextField.text ?? "")")
        }
    }

    @objc func donePicker() {
        view.endEditing(true)
    }
}
