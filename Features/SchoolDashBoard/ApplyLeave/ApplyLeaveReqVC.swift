
//
//  ApplyLeaveReqVC.swift
//  School Chimes
//
//  Created by apple on 03/03/26.
//

import UIKit


struct editLeaves{
    let id :String?
    var fromDate:String
    var toDate:String
    var reson:String
    var fromSession:String
    var Tosession:String
    var NoOfDays:String
    var LeaveType:String
    var LeaveTypeId:Int
}


import UIKit
import FSCalendar
@available(iOS 14.0, *)
class ApplyLeaveReqVC: UIViewController{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var OutlineView: UIView!
    @IBOutlet weak var TypeImage: UIImageView!
    @IBOutlet weak var CauseImage: UIImageView!
    @IBOutlet weak var FromImage: UIImageView!
    @IBOutlet weak var ToImage: UIImageView!
    @IBOutlet weak var ApplyLeaveBtn: UIButton!
    @IBOutlet weak var CauseTextviewHeight: NSLayoutConstraint!
    @IBOutlet weak var SessionDefLbl: UILabel!
    @IBOutlet weak var FromDefLbl: UILabel!
    @IBOutlet weak var CauseDefLbl: UILabel!
    @IBOutlet weak var LeaveTypeBtn: UIButton!
    @IBOutlet weak var TypeDefLbl: UILabel!
    @IBOutlet weak var ToDefLbl: UILabel!
    @IBOutlet weak var ToSessionDefLbl: UILabel!
    @IBOutlet weak var FromDoneBtn: UIButton!
    @IBOutlet weak var ToDoneBtn: UIButton!
    @IBOutlet weak var SelectFromDateDefLbl: UILabel!
    @IBOutlet weak var SelectToDateDefLbl: UILabel!
    @IBOutlet weak var CauseTextView: UITextView!
    @IBOutlet weak var FromDateBtn: UIButton!
    @IBOutlet weak var ToDateBtn: UIButton!
    @IBOutlet weak var ToDatePickerView: UIView!
    @IBOutlet weak var FromDatePickerView: UIView!
    @IBOutlet weak var ToSessionBtn: UIButton!
    @IBOutlet weak var FromSessionBtn: UIButton!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    @IBOutlet weak var FromDatePicker: UIDatePicker!
    @IBOutlet weak var errorLbl: UILabel!

    
    @IBAction func ShowFromDate() {
        FromDatePickerView.isHidden = false
        ToDatePickerView.isHidden = true
    }
    
    @IBAction func ShowToDate() {
        FromDatePickerView.isHidden = true
        ToDatePickerView.isHidden = false
    }
    
    var fromDate: Date?
    var toDate: Date?
    let today = Date()
    var tapCount = 0
    let dateFormatter = DateFormatter()
    var placeholderLabel: UILabel!
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let alert = CustomAlert()
    var editLeaveData:editLeaves?
    let dropDown = DropDown()
    let dropDown2 = DropDown()
    let options = [AttendanceString.firstHalf.translated(), AttendanceString.secondHalf.translated()]
    var leaveTypes : [LeaveType] = []
    var selectedLeaveType : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Setup_UI()
        Set_FontStyle()
        Translate_text()
        Get_Leave_Categories()
        
        LeaveTypeBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShowTypeDropdown)))
        LeaveTypeBtn.isUserInteractionEnabled = true
        
        dropDown.dataSource = options
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let anchorButton = self?.dropDown.anchorView as? UIButton else { return }
            anchorButton.setTitle(item, for: .normal)
            self?.calculateDays()
        }
        
        CauseTextView.delegate = self
        
        let currentDate = Date()
        
        // Calculate past month date (subtract 1 month)
        if let pastMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            FromDatePicker.minimumDate = pastMonthDate  // 👈 Minimum selectable date
            toDatePicker.minimumDate = pastMonthDate  // 👈 Minimum selectable date
        }
        
        FromDatePicker.locale = LocaleManager.shared.apiLocale
        toDatePicker.locale = LocaleManager.shared.apiLocale
        
        setupPlaceholder()
        
        if let leave = editLeaveData{
            
            dateFormatter.dateFormat = "dd MMM yyyy"
            dateFormatter.locale = LocaleManager.shared.displayLocale
            placeholderLabel.isHidden = !leave.reson.isEmpty
            LeaveTypeBtn.setTitle(leave.LeaveType, for: .normal)
            FromDateBtn.setTitle(leave.fromDate.convertToTargetDateFormat(), for: .normal)
            ToDateBtn.setTitle(leave.toDate.convertToTargetDateFormat(), for: .normal)
            CauseTextView.text = leave.reson
            let size = CGSize(width: CauseTextView.frame.width, height: .infinity)
            let estimatedSize = CauseTextView.sizeThatFits(size)
            CauseTextviewHeight.constant = estimatedSize.height
            FromDatePickerView.isHidden = true
            FromSessionBtn.setTitle(leave.fromSession, for: .normal)
            ToSessionBtn.setTitle(leave.Tosession, for: .normal)
            let daysText = "\(AttendanceString.updateFor) \(leave.NoOfDays) \(AttendanceString.daysLeave)"
            ApplyLeaveBtn.setTitle(daysText, for: .normal)
            FromDatePicker.date = dateFormatter.date(from: leave.fromDate.convertToTargetDateFormat() ?? "") ?? Date()
            toDatePicker.date = dateFormatter.date(from: leave.toDate.convertToTargetDateFormat() ?? "") ?? Date()
            selectedLeaveType = leave.LeaveTypeId
        }
        
        ApplyLeaveBtn.backgroundColor = validateInputs() ? .backGroundClr : .systemGray4
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func HistoryBtnAct(_ sender: UIButton) {
        let vc = SenderLeaveRqstVC(nibName: nil, bundle: nil)
        vc.isStaff = true
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    func Setup_UI(){
        
        
        OutlineView.layer.cornerRadius = 12
        OutlineView.layer.borderWidth = 1
        OutlineView.layer.borderColor = UIColor.systemGray4.cgColor
        
        LeaveTypeBtn.semanticContentAttribute = .forceRightToLeft
        FromDateBtn.semanticContentAttribute = .forceRightToLeft
        ToDateBtn.semanticContentAttribute = .forceRightToLeft
        FromSessionBtn.semanticContentAttribute = .forceRightToLeft
        ToSessionBtn.semanticContentAttribute = .forceRightToLeft
        
        FromDateBtn.titleLabel?.numberOfLines = 0
        ToDateBtn.titleLabel?.numberOfLines = 0
        ToSessionBtn.titleLabel?.numberOfLines = 0
        FromSessionBtn.titleLabel?.numberOfLines = 0
        
        CauseTextView.addDoneButton()
        
        TypeImage.layer.cornerRadius = 8
        CauseImage.layer.cornerRadius = 8
        FromImage.layer.cornerRadius = 8
        ToImage.layer.cornerRadius = 8
        
        FromDoneBtn.layer.cornerRadius = 8
        ToDoneBtn.layer.cornerRadius = 8
        
        ApplyLeaveBtn.layer.cornerRadius = 10
        
        if #available(iOS 16.0, *) {
            TypeImage.image = UIImage(systemName: "window.ceiling.closed")
            CauseImage.image = UIImage(systemName: "pencil.line")
        } else {
            TypeImage.image = UIImage(systemName: "rectangle.split.2x2")
            CauseImage.image = UIImage(systemName: "pencil")
        }
        
        FromDatePickerView.isHidden = true
        ToDatePickerView.isHidden = true
    }
    
    func Set_FontStyle(){

        TypeDefLbl.setFont(style: .body, size: FontSize.BodySize)
        CauseDefLbl.setFont(style: .body, size: FontSize.BodySize)
        FromDefLbl.setFont(style: .body, size: FontSize.BodySize)
        SessionDefLbl.setFont(style: .body, size: FontSize.BodySize)
        ToDefLbl.setFont(style: .body, size: FontSize.BodySize)
        ToSessionDefLbl.setFont(style: .body, size: FontSize.BodySize)
        errorLbl.setFont(style: .body, size: FontSize.BodySize)
        ApplyLeaveBtn.setTitleFont(style: .secondary, size: FontSize.HeaderSize)
        
        LeaveTypeBtn.setTitleFont(style: .body, size: 14)
        
        FromDateBtn.setTitleFont(style: .secondary, size: 14)
        ToDateBtn.setTitleFont(style: .secondary, size: 14)
        FromSessionBtn.setTitleFont(style: .secondary, size: 12)
        ToSessionBtn.setTitleFont(style: .secondary, size: 12)
        
        FromDoneBtn.setTitle(AlertstringFile.Done, for: .normal)
        ToDoneBtn.setTitle(AlertstringFile.Done, for: .normal)
        
        CauseTextView.font = UIFont(name: "Poppins-Medium", size: 14)
    }
    
    func Translate_text(){
        
        TypeDefLbl.text = AttendanceString.type.translated()
        LeaveTypeBtn.setTitle(AttendanceString.selectLeaveType.translated(), for: .normal)
        CauseDefLbl.text = AttendanceString.cause.translated()
        FromDefLbl.text = CommonStringFile.From.translated()
        ToDefLbl.text = CommonStringFile.To.translated()
        SessionDefLbl.text = AttendanceString.session.translated()
        ToSessionDefLbl.text = AttendanceString.session.translated()
        
        FromDateBtn.setTitle("Select Date".translated(), for: .normal)
        ToDateBtn.setTitle("Select Date".translated(), for: .normal)
        FromSessionBtn.setTitle(AttendanceString.firstHalf, for: .normal)
        ToSessionBtn.setTitle(AttendanceString.secondHalf, for: .normal)
        
        SelectFromDateDefLbl.text = AttendanceString.selectFromDate
        SelectToDateDefLbl.text = AttendanceString.selectToDate
        
        ApplyLeaveBtn.setTitle(AttendanceString.applyLeave, for: .normal)
        
        FromDoneBtn.setTitle(AlertstringFile.Done, for: .normal)
        ToDoneBtn.setTitle(AlertstringFile.Done, for: .normal)
    }
    
    func setupDropDowns() {
        // DropDown for Label One
        dropDown2.dataSource = leaveTypes.compactMap{$0.leave_name}
        dropDown2.anchorView = LeaveTypeBtn
        dropDown2.bottomOffset = CGPoint(x: -20, y: LeaveTypeBtn.bounds.height - 10)
        dropDown2.width = LeaveTypeBtn.bounds.width
        dropDown2.selectionAction = { [weak self] index, item in
            self?.LeaveTypeBtn.setTitleColor(.black, for: .normal)
            self?.LeaveTypeBtn.setTitle(item, for: .normal)
            self?.selectedLeaveType = self?.leaveTypes[index].id
            self?.calculateDays()
        }
    }
    
    
    @IBAction func ToDateDoneBtn(_ sender: Any) {
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = LocaleManager.shared.displayLocale
        // NewToDateLbl.text = dateFormatter.string(from: toDatePicker.date)
        toDate = toDatePicker.date
        let formattedDate = dateFormatter.string(from: toDate!)
        ToDateBtn.setTitle(formattedDate, for: .normal)
        //NewToDateLbl.setTitle(dateFormatter.string(from: toDatePicker.date), for: .normal)
        ToDatePickerView.isHidden = true
        calculateDays()
    }
    
    @IBAction func FromDateDoneBtn(_ sender: Any) {
        
        fromDate = FromDatePicker.date
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = LocaleManager.shared.displayLocale
        let formattedDate = dateFormatter.string(from: fromDate!)
        FromDateBtn.setTitle(formattedDate, for: .normal)
        FromDatePickerView.isHidden = true
        calculateDays()
    }
    
    @IBAction func ShowTypeDropdown(){
        
        dropDown2.show()
    }
    
    @IBAction func SubmitAct(_ sender: Any) {
        
        if validateInputs(){
            if let leave = editLeaveData{
                updateLeave()
            }else{
                ApplyLeave()
            }
        }else {
            alert.showAlert(title: AlertstringFile.Missing_Information.translated(), message: AlertstringFile.Fill_All_Required_Fields.translated(), on: self)
        }
    }
    
    func validateInputs() -> Bool {
        
        if LeaveTypeBtn.title(for: .normal) == AttendanceString.selectLeaveType {
            showError("Please select a Leave Type.")
            return false
        }
        
        if CauseTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            showError("Cause should not be empty.")
            return false
        }
        
        if let fromDate = FromDateBtn.title(for: .normal),
           fromDate.isEmpty || fromDate == "Select Date" {
            showError("Please select a From Date.")
            return false
        }
        
        if let toDate = ToDateBtn.title(for: .normal),
           toDate.isEmpty || toDate == "Select Date" {
            showError("Please select a To Date.")
            return false
        }
        
        // ✅ No errors → proceed
        return true
    }
    
    
    
    //MARK: Leave Request API call
    
    func Get_Leave_Categories(){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_for_staff_leave_categories, parameters: [:], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (result: Result<LeaveTypesResponse,Error>) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else {return}
                
                switch result {
                    
                case .success(let success):
                    
                    self.leaveTypes = success.data ?? []
                    setupDropDowns()
                    
                case .failure(let error):
                    print("Error: ",error.localizedDescription)
                }
                
            }
        }
    }
    
    func ApplyLeave(){
        
        let LeaveFrom = ConvertDateStringSmart(FromDateBtn.titleLabel?.text)
        let LeaveTo = ConvertDateStringSmart(ToDateBtn.titleLabel?.text)
        var fromSessionCode = ""
        var toSessionCode = ""
        
        if let fromTitle = FromSessionBtn.title(for: .normal) {
            if fromTitle == options.first {
                fromSessionCode = "FH"
            } else if fromTitle == options.last {
                fromSessionCode = "SH"
            }
        }
        
        if let toTitle = ToSessionBtn.title(for: .normal) {
            if toTitle.contains("First") {
                toSessionCode = "FH"
            } else if toTitle.contains("Second") {
                toSessionCode = "SH"
            }
        }
        
        print("LeaveFrom",LeaveFrom)
        print("LeaveTo",LeaveTo)
        let param: [String:Any] = [LeaveRequestStringFile.leave_from: LeaveFrom, LeaveRequestStringFile.leave_to:LeaveTo,LeaveRequestStringFile.reason:CauseTextView.text ?? "",LeaveRequestStringFile.f_session:fromSessionCode,LeaveRequestStringFile.t_session:toSessionCode, LeaveRequestStringFile.leave_type: selectedLeaveType ?? 0]
        
        alert.showAlertCancel(title: AlertstringFile.Confirm.translated(), message: AlertstringFile.Are_you_sure_you_want_to_submit_leave_request.translated(), actionLbl1: AlertstringFile.Yes_Send.translated(), actionLbl2: AlertstringFile.Cancel.translated(), on: self,
            onOk: {
            
            APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_for_staff_apply, parameters: param, type: ApitTypeSringFile.POST, token: self.staffDetails?.access_token ?? "", isBaseUrl: true) {[weak self] (result: Result<CommonApiSuc,Error>) in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    switch result{
                    case .success(let success):
                        if success.status == true{
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: success.message ?? "", on: self) {
                                if user_inputs.clearTempData(){
                                    let parms = [ "mobile_number": UserDefaultFileManager.get_child_Details()?.whatsapp_number ?? "",
                                                  "activity": "APPLY_LEAVE",
                                                  "user_type": 1,
                                                  "menu_id": Menu_id.staffSelectedMenuId] as [String : Any]
                                    self.paketApiCall(params:parms)
                                }
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
    func paketApiCall(params:[String:Any]){
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? "", isBaseUrl: true
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.dismiss(animated: true)
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(response.message, duration: 2.0, position: .bottom)
                    }
                case .failure(let error):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                    }
                    self.dismiss(animated: true)
                }
            }
        }
    }
    func updateLeave(){
        
        let LeaveFrom = ConvertDateStringSmart(FromDateBtn.titleLabel?.text)
        let LeaveTo = ConvertDateStringSmart(ToDateBtn.titleLabel?.text)
        var fromSessionCode = ""
        var toSessionCode = ""
        
        if let fromTitle = FromSessionBtn.title(for: .normal) {
            if fromTitle == options.first {
                fromSessionCode = "FH"
            } else if fromTitle == options.last {
                fromSessionCode = "SH"
            }
        }
        
        if let toTitle = ToSessionBtn.title(for: .normal) {
            if toTitle == options.first {
                toSessionCode = "FH"
            } else if toTitle == options.last {
                toSessionCode = "SH"
            }
        }
        
        let param: [String:Any] = [
            LeaveRequestStringFile.id:editLeaveData?.id ?? "",
            LeaveRequestStringFile.leave_from: LeaveFrom,
            LeaveRequestStringFile.leave_to:LeaveTo,
            LeaveRequestStringFile.reason:CauseTextView.text ?? "",
            LeaveRequestStringFile.f_session:fromSessionCode,
            LeaveRequestStringFile.t_session: toSessionCode,
            LeaveRequestStringFile.leave_type: selectedLeaveType ?? 0
        ]
        
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.Are_you_sure_you_want_to_submit_leave_request, actionLbl1: AlertstringFile.Yes_Send, actionLbl2: AlertstringFile.Cancel, on: self,
                              
                              onOk: {
            
            APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_for_staff_update, parameters: param, type: ApitTypeSringFile.PUT, token: self.staffDetails?.access_token ?? "", isBaseUrl: true) {[weak self] (result: Result<CommonApiSuc,Error>) in
                
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
    
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.EnterReason.translated()
        placeholderLabel.font = CauseTextView.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        CauseTextView.addSubview(placeholderLabel)
        
        // Use constraints to align the placeholder with the text view's text
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: CauseTextView.topAnchor, constant: CauseTextView.textContainerInset.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: CauseTextView.leadingAnchor, constant: CauseTextView.textContainer.lineFragmentPadding),
            placeholderLabel.trailingAnchor.constraint(equalTo: CauseTextView.trailingAnchor, constant: -CauseTextView.textContainer.lineFragmentPadding)
        ])
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = CauseTextView.sizeThatFits(size)
        CauseTextviewHeight.constant = estimatedSize.height
        placeholderLabel.isHidden = CauseTextView.text.count == 0 ? false : true
        CauseTextView.isScrollEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        calculateDays()
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
            dayCount.text = "No of Days - ".translated() + " \(totalDays)"
        } else {
            dayCount.text = "Error calculating"
        }
    }
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func showDropdown(for button: UIButton) {
        dropDown.anchorView = button
        dropDown.bottomOffset = CGPoint(x: 0, y: button.bounds.height + 10) // Adjust '10' as needed
        dropDown.show()
    }
    
    @IBAction func FromSessionAct(_ sender: UIButton) {
        showDropdown(for: sender)
    }
    @IBAction func ToSessionAct(_ sender: UIButton) {
        showDropdown(for: sender)
    }
    
    func calculateDays() {
        errorLbl.isHidden = true // Hide error by default
        
        // Always take dates directly from pickers
        let fromDate = FromDatePicker.date
        let toDate = toDatePicker.date
        
        guard let fromSession = FromSessionBtn.title(for: .normal),
              let toSession = ToSessionBtn.title(for: .normal) else {
            // Not all inputs selected yet — silently return
            return
        }
        
        // ❌ Validation 1: from date > to date
        if fromDate > toDate {
            showError("To date should be greater than from date".translated())
            return
        }
        
        // ❌ Validation 2: same date but invalid session order
        if Calendar.current.isDate(fromDate, inSameDayAs: toDate) {
            if isSecondHalf(session: fromSession) && isFirstHalf(session: toSession) {
                showError("From session cannot be after To session on the same day.".translated())
                return
            }
        }
        
        // Enable / disable Apply button
        ApplyLeaveBtn.backgroundColor = validateInputs() ? .backGroundClr : .systemGray4
        
        // ✅ Calculate total days
        let totalDays = calculateDays(
            from: fromDate,
            fromSession: fromSession,
            to: toDate,
            toSession: toSession
        )
        
        // Format day count (int vs half-day decimal)
        let formattedDays: String
        if floor(totalDays) == totalDays {
            formattedDays = String(Int(totalDays)) // e.g. "7"
        } else {
            formattedDays = String(totalDays)      // e.g. "7.5"
        }
        
        // Update button title
        if let leave = editLeaveData {
            ApplyLeaveBtn.setTitle("Update for \(formattedDays) Days Leave", for: .normal)
        } else {
            ApplyLeaveBtn.setTitle("Apply for \(formattedDays) Days Leave".translated(), for: .normal)
        }
    }
    
    
    func showError(_ message: String) {
        let fullMessage = "* \(message.translated())"
        errorLbl.text = fullMessage
        errorLbl.textColor = .systemRed
        errorLbl.isHidden = false
        ApplyLeaveBtn.setTitle("Apply Leave".translated(), for: .normal)
    }
    
    
    
    // MARK: - Core Logic
    func calculateDays(from fromDate: Date, fromSession: String, to toDate: Date, toSession: String) -> Double {
        let calendar = Calendar.current
        let startOfFromDate = calendar.startOfDay(for: fromDate)
        let startOfToDate = calendar.startOfDay(for: toDate)
        
        let daysBetween = calendar.dateComponents([.day], from: startOfFromDate, to: startOfToDate).day ?? 0
        
        let fromIsFirstHalf = isFirstHalf(session: fromSession)
        let toIsSecondHalf = isSecondHalf(session: toSession)
        
        if daysBetween == 0 {
            if fromIsFirstHalf && toIsSecondHalf {
                return 1.0
            } else {
                return 0.5
            }
        }
        
        var totalDays = 0.0
        totalDays += fromIsFirstHalf ? 1.0 : 0.5
        totalDays += toIsSecondHalf ? 1.0 : 0.5
        
        if daysBetween > 1 {
            totalDays += Double(daysBetween - 1)
        }
        
        return totalDays
    }
    
    func isFirstHalf(session: String) -> Bool {
        return session.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == "first half".translated()
    }
    
    func isSecondHalf(session: String) -> Bool {
        return session.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == "second half".translated()
    }
}


@available(iOS 14.0, *)
extension ApplyLeaveReqVC: UITextViewDelegate{
    
    @objc func keyboardWillShow(notification: NSNotification){
        
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
            CGRect {
            
            let keyboardHeight = keyboardFrame.height
            
            var contentInset = scrollView.contentInset
            contentInset.bottom = keyboardHeight + 20
            
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            
            if let textView = CauseTextView{
                
                let visibleRect = view.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0))
                
                if !visibleRect.contains(textView.frame.origin) {
                    
                    scrollView.scrollRectToVisible(textView.frame, animated: true)
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        var contentInset = scrollView.contentInset
        contentInset.bottom = 0
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
}

@available(iOS 14.0, *)
extension ApplyLeaveReqVC: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    //    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    //            tapCount += 1
    //
    //            if tapCount == 1 {
    //                // Initial tap
    //                if let from = fromDate {
    //                    if date < from {
    //                        toDate = fromDate
    //                        fromDate = date
    //                    }else {
    //
    //                        fromDate = from
    //                        toDate = date
    //                    }
    //                }
    //            } else if tapCount == 2 {
    //                // Second tap → make a range
    //
    //                fromDate = date
    //                toDate = date
    //                tapCount = 1
    //
    //                // Deselect all previously selected dates (optional visual)
    //                calendar.selectedDates.forEach { calendar.deselect($0) }
    //                calendar.select(date)
    //
    //            } else {
    //                // Third tap or more → reset
    //                if let first = fromDate {
    //                    if date < first {
    //                        toDate = first
    //                        fromDate = date
    //                    } else {
    //                        fromDate = first
    //                        toDate = date
    //                    }
    //                }
    //            }
    //
    //            updateLabels()
    //            calendar.reloadData()
    //        }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if fromDate == nil && toDate == nil {
            // First tap: set both
            fromDate = date
            toDate = date
        } else if fromDate != nil && toDate != nil && fromDate == toDate {
            // Second tap: form a range
            if date < fromDate! {
                fromDate = date
            } else {
                toDate = date
            }
        } else {
            // Third or more: reset and start again
            fromDate = date
            toDate = date
            
            // Clear previous selections visually
            calendar.selectedDates.forEach { calendar.deselect($0) }
            calendar.select(date)
        }
        
        updateLabels()
        calendar.reloadData()
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        guard let from = fromDate, let to = toDate else { return nil }
        
        if date >= from && date <= to {
            return .systemBlue
        }
        return nil
    }
    
    func updateLabels() {
        let formatter = DateFormatter()
        formatter.locale = LocaleManager.shared.displayLocale
        formatter.dateFormat = "dd MMM yyyy"
        
        if let from = fromDate {
            FromDateBtn.titleLabel?.text = "From: \(formatter.string(from: from))"
        } else {
            FromDateBtn.titleLabel?.text = "From: -"
        }
        
        if let to = toDate {
            ToDateBtn.titleLabel?.text = "To: \(formatter.string(from: to))"
        } else {
            ToDateBtn.titleLabel?.text = "To: -"
        }
    }
}


