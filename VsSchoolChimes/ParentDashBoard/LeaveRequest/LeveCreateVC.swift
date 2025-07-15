//
//  LeveCreateVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
@available(iOS 14.0, *)
class LeveCreateVC: UIViewController,UITextViewDelegate, Datepicker{
    func date(date: String) {
        
        dateFormatter.dateFormat = dateFormat1
        if let selectedDate = dateFormatter.date(from: date) {
            if dateSelection {
                FromDateLbl.setFormattedDate(from: selectedDate)

                // Check if To Date is set and valid
                if let toText = ToDateLbl.text?.replacingOccurrences(of: "\n", with: " ") {
                    let labelFormatter = DateFormatter()
                    labelFormatter.dateFormat = DateFormatString.Date_Day_month_year

                    if let toDate = labelFormatter.date(from: toText) {
                        if selectedDate > toDate {
                            // Auto-adjust To Date if From Date is later
                            ToDateLbl.setFormattedDate(from: selectedDate)
                        }
                    }
                }

            } else {
                // Set To Date
                ToDateLbl.setFormattedDate(from: selectedDate)
            }
            
            updateDayCountLabel(startDateStr: FromDateLbl.text ?? "", endDateStr: ToDateLbl.text ?? "", dayCount: dayCount)
        } else {
            print("Error: Invalid date format or nil value")
        }

    }
    
    @IBOutlet weak var ToDateLbl: UILabel!
    @IBOutlet weak var FromDateLbl: UILabel!
    @IBOutlet weak var TodateTop: UIView!
    @IBOutlet weak var FromDateTop: UIView!
    @IBOutlet weak var ToDateView: UIView!
    @IBOutlet weak var FromDateView: UIView!
    @IBOutlet weak var dayCount: UILabel!
    @IBOutlet weak var ReasonLbl: UILabel!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var ToLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var contentCount: UILabel!
    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var SubmitBtn: UIButton!
    
   
    let dateFormatter = DateFormatter()
    var placeholderLabel: UILabel!
    var dateSelection = false
    let photoPickManager = PhotoPickerManager.shared
    var selectedImages: [UIImage] = []
    var url : URL?
    var dateFormat1 = DateFormatString.StandardFormat
    var isKeyboardVisible = false
    var childDetails = UserDefaultFileManager.get_child_Details()
    let alert = CustomAlert()
    var leave:editLeave?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiConfic()
        setInitialDate()
        contentTxtView.delegate = self
        contentTxtView.addDoneButton()
       
        setupPlaceholder()
        
        let DateGesture = UITapGestureRecognizer(target: self, action: #selector(datepicker))
        FromDateView.addGestureRecognizer(DateGesture)
        
        let ToDateGesture = UITapGestureRecognizer(target: self, action: #selector(toDate))
        ToDateView.addGestureRecognizer(ToDateGesture)
       
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        
        if let leave = leave{
            ToDateLbl.setFormattedDate(from: leave.toDate)
                FromDateLbl.setFormattedDate(from: leave.fromDate)
            contentTxtView.text = leave.reson
            updateDayCountLabel(startDateStr: FromDateLbl.text ?? "", endDateStr: ToDateLbl.text ?? "", dayCount: dayCount)
            placeholderLabel.isHidden = !leave.reson.isEmpty
            contentCount.text = "\(leave.reson.count) / 500"
        }
           
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    func uiConfic(){
        
        FromDateView.layer.cornerRadius = 8
        ToDateView.layer.cornerRadius = 8
        FromDateTop.layer.cornerRadius = 8
        TodateTop.layer.cornerRadius = 8
        FromDateTop.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        TodateTop.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
        FromDateView.layer.cornerRadius = 10
        FromDateView.layer.shadowColor = UIColor.black.cgColor
        FromDateView.layer.shadowOffset = CGSize(width: 0, height: 2)
        FromDateView.layer.shadowRadius = 5
        FromDateView.layer.shadowOpacity = 0.3
        
        ToDateView.layer.cornerRadius = 10
        ToDateView.layer.shadowColor = UIColor.black.cgColor
        ToDateView.layer.shadowOffset = CGSize(width: 0, height: 2)
        ToDateView.layer.shadowRadius = 5
        ToDateView.layer.shadowOpacity = 0.3
        
        contentTxtView.layer.cornerRadius = 10
        contentTxtView.layer.borderWidth = 0.5
        contentTxtView.layer.borderColor = UIColor.black.cgColor
        contentTxtView.font = UIFont(name: "Poppins-Medium", size: 13)
        
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        
        SubmitBtn.layer.cornerRadius = 10
        SubmitBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        ToLbl.setFont(style:.title, size: FontSize.TitleSize)
        headerTitle.setFont(style:.title, size: FontSize.TitleSize)
        fromLbl.setFont(style:.title, size: FontSize.TitleSize)
        dayCount.setFont(style:.header, size: FontSize.BodySize)
        contentCount.setFont(style: .body, size: FontSize.BodySize)
        
        fromLbl.text = CommonStringFile.From.translated()
        headerTitle.text = CommonStringFile.CreateLeaveRequest.translated()
        ReasonLbl.setRequiredText(CommonStringFile.Reason)
    }

    @IBAction func SubmitAct(_ sender: Any) {
       
        if contentTxtView.text != ""{
            if let leave = leave{
                updateLeave()
            }else{
                ApplyLeave()
            }
        }else{
            alert.showAlert(title: "", message: AlertstringFile.Enter_reason, on: self)
        }
    }
    
    
    //MARK: Leave Request API call
    
    func ApplyLeave(){
        
        let LeaveFrom = ConvertDateStringSmart(FromDateLbl.text)
        let LeaveTo = ConvertDateStringSmart(ToDateLbl.text)
        
        print("LeaveFrom",LeaveFrom)
        print("LeaveTo",LeaveTo)
        let param: [String:Any] = [LeaveRequestStringFile.leave_from: LeaveFrom, LeaveRequestStringFile.leave_to:LeaveTo,LeaveRequestStringFile.reason:contentTxtView.text ?? ""]
        
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.Are_you_sure_you_want_to_submit_leave_request, actionLbl1: AlertstringFile.Yes_Send, actionLbl2: AlertstringFile.Cancel, on: self,
                              
            onOk: {
                  
            APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_apply, parameters: param, type: ApitTypeSringFile.POST, token: self.childDetails?.access_token ?? "") {[weak self] (result: Result<CommonApiSuc,Error>) in
                
                DispatchQueue.main.async { [weak self] in
                    
                    guard let self = self else {return}
                    
                    switch result{
                        
                    case .success(let success):
                        
                        if success.status == true{
                            
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: success.message ?? "", on: self) {
                                self.dismiss(animated: true)
                            }
                        }else {
                            
                            alert.showAlert(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                        }
                        
                    case .failure(let error):
                        
                        alert.showAlert(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                    }
                }
            }
            
        }, onNo: {
            
            print("user Canceled Action")
        }
        )
    }
    
    func updateLeave(){
        
        let LeaveFrom = ConvertDateStringSmart(FromDateLbl.text)
        let LeaveTo = ConvertDateStringSmart(ToDateLbl.text)
        let param: [String:Any] = [LeaveRequestStringFile.leave_from:leave?.id ?? "",LeaveRequestStringFile.leave_from: LeaveFrom, LeaveRequestStringFile.leave_to:LeaveTo,LeaveRequestStringFile.reason:contentTxtView.text ?? ""]
        
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.Are_you_sure_you_want_to_submit_leave_request, actionLbl1: AlertstringFile.Yes_Send, actionLbl2: AlertstringFile.Cancel, on: self,
                              
            onOk: {
                  
            APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_update, parameters: param, type: ApitTypeSringFile.POST, token: self.childDetails?.access_token ?? "") {[weak self] (result: Result<CommonApiSuc,Error>) in
                
                DispatchQueue.main.async { [weak self] in
                    
                    guard let self = self else {return}
                    
                    switch result{
                        
                    case .success(let success):
                        
                        if success.status == true{
                            
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: success.message ?? "", on: self) {
                                self.dismiss(animated: true)
                            }
                        }else {
                            
                            alert.showAlert(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                        }
                        
                    case .failure(let error):
                        
                        alert.showAlert(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                    }
                }
            }
            
        }, onNo: {
            
            print("user Canceled Action")
        }
        )
    }
    
   
    
    //MARK: BUTTON TITLE CURRENT TIME
    func setInitialDate() {
        
        let currentDate = Date() // Current date and time
        
        dateFormatter.dateFormat = dateFormat1
        let date = dateFormatter.string(from: currentDate)
        
        FromDateLbl.setFormattedDate(from: currentDate)
        ToDateLbl.setFormattedDate(from: currentDate)
        
    }
   
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.Reason.translated()
        contentTxtView.applyRightTxt()
        contentCount.applyRightTxt()

        // Placeholder styling
        placeholderLabel.font = contentTxtView.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        contentTxtView.applyRightTxt(with: placeholderLabel)

        contentTxtView.addSubview(placeholderLabel)
    }

    
    @IBAction func datepicker(_ sender: Any) {
         dateSelection = true
         let vc = DatePickerVC(nibName: nil, bundle: nil)
         vc.dateSelection = 2
         vc.delegate = self
         vc.modalPresentationStyle = .overCurrentContext
         vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
         self.present(vc, animated: false)
    }
    
    @IBAction func toDate(_ sender: Any) {
        dateSelection = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self

        // Extract and parse from FromDateLbl
        if let fromDateString = FromDateLbl.text {
            let components = fromDateString.components(separatedBy: "\n")
            if components.count == 2,
               let day = components.first,
               let rest = components.last {
                let fullDateString = "\(day) \(rest)" // e.g., "18 Wed, Jun 2025"

                let formatter = DateFormatter()
                formatter.dateFormat = DateFormatString.Date_Day_month_year
                if let fromDate = formatter.date(from: fullDateString) {
                    vc.minimumDate = fromDate
                }
            }
        }

        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }

    func updateDayCountLabel(startDateStr: String, endDateStr: String, dayCount: UILabel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  DateFormatString.Date_Day_month_year
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let startDate = dateFormatter.date(from: startDateStr),
              let endDate = dateFormatter.date(from: endDateStr) else {
            dayCount.text = "Invalid date"
            return
        }

        let calendar = Calendar.current
        if let days = calendar.dateComponents([.day], from: startDate, to: endDate).day {
            let totalDays = days + 1  // Include the end date
            //dayCount.text = "No of Days - " + " \(totalDays) Day" + (totalDays > 1 ? "s" : "")
            dayCount.text = "No of Days - " + " \(totalDays)"
        } else {
            dayCount.text = "Error calculating"
        }
    }
}

@available(iOS 14.0, *)
extension LeveCreateVC: UITextViewDelegate,UITextFieldDelegate {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard !isKeyboardVisible else { return } // Prevent unnecessary animations
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            isKeyboardVisible = true
            UIView.animate(withDuration: 0.3) {
                // Move outerView 20 points from the top
                self.outerView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height + 200)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard isKeyboardVisible else { return } // Ensure this logic runs only if the keyboard is open
        isKeyboardVisible = false
        UIView.animate(withDuration: 0.3) {
            self.outerView.transform = .identity // Reset position
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeightWithConstraint(textView)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Calculate the new length of the text
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        if updatedText.count <= 500 {
            placeholderLabel.isHidden = updatedText.count == 0 ? false : true
            contentCount.text = "\(updatedText.count) / 500" // Update the character count label
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            //            contentTxtView.isEditable = false // Optionally disable editing
            return false // Reject the change
        }
    }
    func adjustTextViewHeightWithConstraint(_ textView: UITextView) {
        // Calculate the size needed for the text
        if textView.text.isEmpty {
            // Set default height to 60
            textViewHeightConstraint.constant = 100
        } else {
            // Calculate the size needed for the text
            let sizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            if sizeThatFits.height > 80{
                textViewHeightConstraint.constant = sizeThatFits.height
            }
        }
        textView.layoutIfNeeded() // Refresh the layout
    }
}

extension UILabel {
    func setFormattedDate(from date: Date) {
        
        let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd" // Ensures 2-digit day format
            
            let dayString = dayFormatter.string(from: date)
        
        let calendar = Calendar.current
        let dayNumber = calendar.component(.day, from: date)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM yyyy" // e.g., "Wed, Jun 2025"
        let dayText = dateFormatter.string(from: date)

        let fullString = "\(dayString)\n\(dayText)"
        let attributedText = NSMutableAttributedString(string: fullString)

        // Day number style: Poppins-SemiBold
        if let boldFont = UIFont(name: "Poppins-SemiBold", size: 15) {
            let dayNumberRange = (fullString as NSString).range(of: "\(dayNumber)")
            attributedText.addAttributes([
                .font: boldFont,
                .foregroundColor: UIColor.label
            ], range: dayNumberRange)
        }

        // Date text style: Poppins-Medium
        if let mediumFont = UIFont(name: "Poppins-Medium", size: 10) {
            let dayTextRange = (fullString as NSString).range(of: dayText)
            attributedText.addAttributes([
                .font: mediumFont,
                .foregroundColor: UIColor.secondaryLabel
            ], range: dayTextRange)
        }

        self.attributedText = attributedText
        self.numberOfLines = 0
        self.textAlignment = .center
    }
    func setFormattedDate(from dateString: String) {
        let formats = ["dd MMM yyyy", "dd-MM-yyyy"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        var date: Date? = nil
        
        for format in formats {
            formatter.dateFormat = format
            if let parsedDate = formatter.date(from: dateString) {
                date = parsedDate
                break
            }
        }
        
        guard let validDate = date else {
            self.text = dateString // fallback
            return
        }
        
        setFormattedDate(from: validDate)
    }
}
