import UIKit

class NewOutpassRequestVC: UIViewController,UITextViewDelegate {

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
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var studentHostelInfo  : HostelDetailsData?
    let alert = CustomAlert()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPickers()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter reason..." {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter reason..."
            textView.textColor = .lightGray
        }
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
        reasonTextView.text = "Enter reason..."
        reasonTextView.textColor = .lightGray
        reasonTextView.delegate = self
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
    
    func OutpassRequest() {
        let outDate = "\(convertDate(fromDateTextField.text ?? "") ?? "") \(fromTimeTextField.text ?? "")".trimmingCharacters(in: .whitespaces)

        let inDate = "\(convertDate(toDateTextField.text ?? "") ?? "") \(toTimeTextField.text ?? "")".trimmingCharacters(in: .whitespaces)
        
        APIService.shared.makeApi(url: ServiceUrl.hostel_attendance_apply_outpass, parameters: ["hostel_id" : studentHostelInfo?.hostel_id ?? "" , "room_id" : studentHostelInfo?.room_id ?? "","out_date" : outDate, "in_date" :inDate,"emergency_contact" : emergencyContactTextField.text ?? "" ,"reason" : reasonTextView.text ?? "",], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "", isBaseUrl: true) {[self] (result: Result<CommonApiSuc,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    if Success.status ?? false{
                        self.alert
                            .showAlert(
                                title: AlertstringFile.Success,
                                message: Success.message ?? "" ,
                                on: self
                            )
                        
                    }else{
                        self.alert
                            .showAlert(
                                title: AlertstringFile.Oops,
                                message: Success.message ?? "" ,
                                on: self
                            )
                        
                    }
                    
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    self.alert
                        .showAlert(
                            title: AlertstringFile.Oops,
                            message: error.localizedDescription ,
                            on: self
                        )
                   
                }
            }
        }
    }
    
    func formatDateTime(date: String?, time: String?) -> String {
        let d = convertDate(date ?? "") ?? ""
        let t = time ?? ""
        return "\(d) \(t)".trimmingCharacters(in: .whitespaces)
    }
    
    func validateFields() -> Bool {
        
        if !isValid(reasonTextView.text) {
            alert.showAlert(title: AlertstringFile.Oops,
                            message: "Enter reason",
                            on: self)
            return false
        }
        
        
        if !isValid(fromDateTextField.text) {
            alert.showAlert(title: AlertstringFile.Oops,
                            message: "Select from date",
                            on: self)
            return false
        }
        
        if !isValid(toDateTextField.text) {
            alert.showAlert(title: AlertstringFile.Oops,
                            message: "Select to date",
                            on: self)
            return false
        }
        
        if !isValid(fromTimeTextField.text) {
            alert.showAlert(title: AlertstringFile.Oops,
                            message: "Select from time",
                            on: self)
            return false
        }
        
        if !isValid(toTimeTextField.text) {
            alert.showAlert(title: AlertstringFile.Oops,
                            message: "Select to time",
                            on: self)
            return false
        }
        
        if !isValid(emergencyContactTextField.text) {
            alert.showAlert(title: AlertstringFile.Oops,
                            message: "Enter emergency contact",
                            on: self)
            return false
        }
        
        return true
    }
    
    func isValid(_ text: String?) -> Bool {
        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return false
        }
        return true
    }
    @IBAction func submitActBtn(_ sender: UIButton) {
        if validateFields() {
            alert.showAlertCancel(
                title: AlertstringFile.Confirm_title,
                message: AlertstringFile.Are_you_sure_want_to_submit,
                actionLbl1:  AlertstringFile.Yes_Send,
                actionLbl2: AlertstringFile.Cancel,
                on: self,
                onOk: {
                    self.OutpassRequest()
                },
                onNo: {
                    
                }
            )
        }
        }
        
}
