import UIKit
extension NewOutpassRequestVC: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == reasonPlaceholder {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            setReasonPlaceholder()
        }
    }
}
class NewOutpassRequestVC: UIViewController, UITextFieldDelegate {

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
    @IBOutlet weak var scrollView: UIScrollView!
    
    // date and time views
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var toDateView: UIView!
    @IBOutlet weak var fromTimeView: UIView!
    @IBOutlet weak var toTimeView: UIView!
    @IBOutlet weak var destinationView: UIView!
    @IBOutlet weak var contactView: UIView!
  
    @IBOutlet weak var reasonDefLbl: UILabel!
    @IBOutlet weak var fromDateDefLbl: UILabel!
    @IBOutlet weak var toDateDefLbl: UILabel!
    @IBOutlet weak var fromTimeDefLbl: UILabel!
    @IBOutlet weak var toTimeDefLbl: UILabel!
    @IBOutlet weak var emergencyDefLbl: UILabel!
    

    
    private let fromDatePicker = UIDatePicker()
    private let toDatePicker = UIDatePicker()
    private let fromTimePicker = UIDatePicker()
    private let toTimePicker = UIDatePicker()
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var studentHostelInfo  : HostelDetailsData?
    let alert = CustomAlert()
    var activeField: UIView?
    private let reasonPlaceholder = "Enter reason...".translated()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPickers()
        setDefaultDateTime()
        setupTapGestures()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

//    func textViewDidBeginEditing(_ textView: UITextView) {
//        activeField = textView
//        if textView.text == "Enter reason..." {
//            textView.text = ""
//            textView.textColor = .black
//        }
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "Enter reason..."
//            textView.textColor = .lightGray
//        }
//    }
    
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
        
        fromDateView.layer.borderWidth = 1
        toDateView.layer.borderWidth = 1
        fromDateView.layer.borderColor = UIColor.gray.cgColor
        toDateView.layer.borderColor = UIColor.gray.cgColor
        
        // UITextView inward padding
        reasonTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        // Back Button action
        backBtn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        reasonTextView.text = "Enter reason...".translated()
        reasonTextView.textColor = .lightGray
        reasonTextView.delegate = self
        
        emergencyContactTextField.delegate = self
        
        reasonTextView.addDoneButton()
        emergencyContactTextField.addDoneButton()
        emergencyContactTextField.placeholder = "Enter contact number".translated()
        submitBtn.setTitle("Submit Request".translated(), for: .normal)
        reasonDefLbl.setRequiredText("Reason for Outpass")
        fromDateDefLbl.setRequiredText("From Date")
        toDateDefLbl.setRequiredText("To Date")
        fromTimeDefLbl.setRequiredText("From Time")
        toTimeDefLbl.setRequiredText("To Time")
        emergencyDefLbl.setRequiredText("Emergency Contact Number")
        reasonTextView.delegate = self
          setReasonPlaceholder()
    }
    private func setReasonPlaceholder() {
        reasonTextView.text = reasonPlaceholder
        reasonTextView.textColor = .placeholderText
    }
    func setupTapGestures() {
        fromDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openFromDate)))
        toDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openToDate)))
        fromTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openFromTime)))
        toTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openToTime)))

        fromDateView.isUserInteractionEnabled = true
        toDateView.isUserInteractionEnabled = true
        fromTimeView.isUserInteractionEnabled = true
        toTimeView.isUserInteractionEnabled = true
    }
    
    @objc func openFromDate() {
        fromDateTextField.becomeFirstResponder()
    }

    @objc func openToDate() {
        toDateTextField.becomeFirstResponder()
    }

    @objc func openFromTime() {
        fromTimeTextField.becomeFirstResponder()
    }

    @objc func openToTime() {
        toTimeTextField.becomeFirstResponder()
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

        // Always English
        picker.locale = LocaleManager.shared.displayLocale
        picker.calendar = Calendar(identifier: .gregorian)

        textField.inputView = picker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneBtn = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(donePicker)
        )

        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )

        toolbar.setItems([space, doneBtn], animated: false)
        textField.inputAccessoryView = toolbar

        picker.addTarget(self,
                         action: #selector(datePickerChanged(_:)),
                         for: .valueChanged)
    }

    @objc func datePickerChanged(_ sender: UIDatePicker) {

        let formatter = DateFormatter()
        formatter.locale = LocaleManager.shared.displayLocale
        formatter.calendar = Calendar(identifier: .gregorian)

        if sender == fromDatePicker {

            formatter.dateFormat = "MMMM d, yyyy"
            fromDateTextField.text = formatter.string(from: sender.date)

            toDatePicker.minimumDate = sender.date

            if toDatePicker.date < sender.date {
                toDatePicker.date = sender.date
                toDateTextField.text = formatter.string(from: sender.date)
            }

        } else if sender == toDatePicker {

            formatter.dateFormat = "MMMM d, yyyy"
            toDateTextField.text = formatter.string(from: sender.date)

        } else if sender == fromTimePicker {

            formatter.dateFormat = "hh:mm a"
            fromTimeTextField.text = formatter.string(from: sender.date)

        } else if sender == toTimePicker {

            formatter.dateFormat = "hh:mm a"
            toTimeTextField.text = formatter.string(from: sender.date)
        }
    }

    @objc func donePicker() {
        if fromDateTextField.isFirstResponder {
            datePickerChanged(fromDatePicker)
        } else if toDateTextField.isFirstResponder {
            datePickerChanged(toDatePicker)
        } else if fromTimeTextField.isFirstResponder {
            datePickerChanged(fromTimePicker)
        } else if toTimeTextField.isFirstResponder {
            datePickerChanged(toTimePicker)
        }
        
        view.endEditing(true)
    }
    
    func setDefaultDateTime() {
        let now = Date()
        
        // +1 hour
        let oneHourLater = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now
        
        // Assign picker values
        fromDatePicker.date = now
        toDatePicker.date = now
        fromTimePicker.date = now
        toTimePicker.date = oneHourLater
        
        // Update UI (textfields)
        updateTextFields()
    }
    
    func updateTextFields() {

        let dateFormatter = DateFormatter()
        dateFormatter.locale = LocaleManager.shared.displayLocale
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "MMMM d, yyyy"

        let timeFormatter = DateFormatter()
        timeFormatter.locale = LocaleManager.shared.displayLocale
        timeFormatter.calendar = Calendar(identifier: .gregorian)
        timeFormatter.dateFormat = "hh:mm a"

        fromDateTextField.text = dateFormatter.string(from: fromDatePicker.date)
        toDateTextField.text = dateFormatter.string(from: toDatePicker.date)

        fromTimeTextField.text = timeFormatter.string(from: fromTimePicker.date)
        toTimeTextField.text = timeFormatter.string(from: toTimePicker.date)
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
                            message: "Enter emergency contact".translated(),
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
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let keyboardHeight = keyboardFrame.height

        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight

        if let activeField = activeField {
            let fieldFrame = activeField.convert(activeField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(fieldFrame, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
        
}
