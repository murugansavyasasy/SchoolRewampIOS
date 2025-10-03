//
//  OTPVc.swift
//  VsSchoolChimes
//
//  Created by admin on 23/10/24.
//

import UIKit
import LocalAuthentication
@available(iOS 14.0, *)
class OTPVc: UIViewController {
    
    @IBOutlet weak var OtpContentLbl: UILabel!
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var otpTextField5: UITextField!
    @IBOutlet weak var otpTextField6: UITextField!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var ResendLbl: UILabel!
    @IBOutlet weak var DidnotReciveOtpLbl: UILabel!
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var callUsLbl: UILabel!
    
    var countdownTimer: Timer?
    var remainingTime = 30
    var forgetType  = false
    var otpFields: [UITextField] = []
    var mobile_number:String?
    var validateMobileData : [UserData] = []
    var forgotpasswordData : [ForgotPasswordData] = []
    var AlertModal = CustomAlert()
    var pageType : Int?
    var otpContent:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BottomView.layer.cornerRadius = 40
        BottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        
        BackBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        OtpContentLbl.setFont(style: .body, size: FontSize.BodySize)
        ResendLbl.setFont(style: .body, size: FontSize.BodySize)
        DidnotReciveOtpLbl.setFont(style: .body, size: FontSize.BodySize)
        
        ResendLbl.isUserInteractionEnabled = true
        setupLabel()
        startTimer()
        
        if pageType == screenType.isSplash {
            BackBtn.isHidden = true
        }
        
        if  pageType == screenType.isForgotPassword{
            
            OtpContentLbl.text =  otpContent
            
        }else{
            OtpContentLbl.text = (validateMobileData.first?.more_info ?? "") + (
                mobile_number ?? "") + "  "
        }
        
        
        
        
        // Add observers for keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        setupOTPTextFields()
        
        
        let callUsGesture = UITapGestureRecognizer(target: self,action: #selector(showDialOptions))
        callUsLbl.addGestureRecognizer(callUsGesture)
        
        checkAutoFillPermission()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func BackBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
     @objc func showDialOptions() {
        doneButtonAction()
        
         var dialNumbersString = validateMobileData.first?.dial_numbers ?? ""
         
         if pageType == screenType.isForgotPassword {
          dialNumbersString = forgotpasswordData.first?.dial_numbers ?? ""
         }
         
        let dialNumbers = dialNumbersString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard !dialNumbers.isEmpty else {
            print("No numbers available")
            return
        }

        let alertController = UIAlertController(title: "Choose a Number", message: nil, preferredStyle: .actionSheet)

        for number in dialNumbers {
            let action = UIAlertAction(title: number, style: .default) { _ in
                self.callNumber(phoneNumber: number)
            }
            alertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }


     // Function to dial the selected number
     func callNumber(phoneNumber: String) {
     if let url = URL(string: "tel://\(phoneNumber)"),
     UIApplication.shared.canOpenURL(url) {
     UIApplication.shared.open(url)
     } else {
     print("Cannot open dial pad")
     }
     }
    
   
    
    
    
    
    
    @IBAction func validationBtn(_ sender: Any) {
        if otpTextField1.text != "" && otpTextField2.text != "" && otpTextField3.text != "" && otpTextField4.text != "" && otpTextField5.text != "" && otpTextField6.text != ""  {
            if #available(iOS 15.0, *) {
                showActivityLoader()
            }
            Validate_OTP(mobileNumber: mobile_number ?? "" , otp: otpTextField1.text! + otpTextField2.text! + otpTextField3.text! + otpTextField4.text! + otpTextField5.text! + otpTextField6.text!)
        }else{
            view.makeToast(AlertstringFile.Enter_Otp)
        }
        
    }
    
    func setupOTPTextFields() {
        otpFields = [otpTextField1, otpTextField2, otpTextField3, otpTextField4, otpTextField5, otpTextField6]
        
        for (index, textField) in otpFields.enumerated() {
            textField.textContentType = .oneTimeCode // Enables OTP Auto-Fill from SMS
            textField.isSecureTextEntry = false // Ensure OTP is visible
            textField.delegate = self
            textField.tag = index // Assign a tag to each text field
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.font = UIFont.systemFont(ofSize: 24)
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            textField.layer.borderColor = UIColor.systemGray4.cgColor
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 5
        }
        otpTextField1.becomeFirstResponder()
    }
    
    // Optionally, collect the entire OTP when needed (for submission)
    func collectOTP() -> String {
        let otpFields = [otpTextField1, otpTextField2, otpTextField3, otpTextField4, otpTextField5, otpTextField6]
        return otpFields.compactMap { $0?.text }.joined()
    }
    
    
    func setupLabel() {
        ResendLbl.frame = CGRect(x: 18, y: 100, width: view.frame.width - 60, height: 40)
        ResendLbl.textAlignment = .left
        ResendLbl.setFont(style: .body, size: FontSize.BodySize)
        ResendLbl.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:)))
        ResendLbl.addGestureRecognizer(tapGesture)
        
        updateLabelWithTime()
    }
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.remainingTime -= 1
            if self.remainingTime <= 0 {
                self.countdownTimer?.invalidate()
                self.showResend()
            } else {
                self.updateLabelWithTime()
            }
        }
    }
    
    func updateLabelWithTime() {
        let text = "Didn't receive a verification code? 00:\(String(format: "%02d", remainingTime))"
        let attributedText = NSMutableAttributedString(string: text)
        ResendLbl.attributedText = attributedText
    }
    
    func showResend() {
        let text = "Didn't receive a verification code? Resend"
        let attributed = NSMutableAttributedString(string: text)
        
        let resendRange = (text as NSString).range(of: "Resend")
        attributed.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: resendRange)
        attributed.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: resendRange)
        
        ResendLbl.attributedText = attributed
    }
    
    @objc func labelTapped(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              let text = label.attributedText?.string else { return }
        
        let resendRange = (text as NSString).range(of: "Resend")
        if resendRange.location == NSNotFound { return }
        
        let tapLocation = gesture.location(in: label)
        
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let index = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if NSLocationInRange(index, resendRange) {
            validate_user()
            self.remainingTime = 30
            self.startTimer()
        }
    }
    func priotyScreenVC(){
        let vc = PriorityVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    func Validate_OTP(mobileNumber : String , otp : String) {
        
        APIService.shared
            .makeApi(url: ServiceUrl.validate_validate_otp, parameters: [
                COMMON_PARAMETER.mobile_number :  mobileNumber,
                OTP_PARAMETER.otp :  otp
                
            ], type: ApitTypeSringFile.POST, token: ServiceUrl.token) { [self] (
                result: Result<ValidateOTPSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    DispatchQueue.main.async { [weak self] in
                        
                        guard let self = self else {return}
                        if #available(iOS 15.0, *) {
                            self.hideActivityLoader()
                        }
                        if successMessage.status == true {
                            
                            self.remainingTime = 0
                            self.startTimer()
                            
                            if(pageType == screenType.isForgotPassword){
                                
                                let vc = CreatePasswordVc(nibName: nil, bundle: nil)
                                vc.modalPresentationStyle = .fullScreen
                                vc.createNewPassword = false
                                vc.mobile_number = mobileNumber
                                present(vc, animated: true)
                                
                            }
                            
                            else if(UserDefaultFileManager
                                .getUserDetails()?.is_password_updated == false){
                                
                                let vc = CreatePasswordVc(
                                    nibName: nil,
                                    bundle: nil
                                )
                                vc.modalPresentationStyle = .fullScreen
                                vc.createNewPassword = true
                                vc.mobile_number = mobileNumber
                                present(vc, animated: true)
                            }
                            else {
                                
                                let password = UserDefaultFileManager.getLoginCredentials()?.pwd
                                UserDefaultFileManager
                                    .saveLoginCredentials(
                                        mobile_number:mobile_number ?? "", pwd: password ?? ""
                                    )
                                
                                if(UserDefaultFileManager
                                    .getUserDetails()?.user_details?.is_staff == true) &&  (
                                        UserDefaultFileManager
                                            .getUserDetails()?.user_details?.is_parent == true
                                    ){
                                    let vc = PriorityVC(
                                        nibName: nil,
                                        bundle: nil
                                    )
                                    vc.modalPresentationStyle = .fullScreen
                                    present(vc, animated: true)
                                }
                                else if(UserDefaultFileManager
                                    .getUserDetails()?.user_details?.is_staff == true){
                                    
                                    if(UserDefaultFileManager
                                        .getUserDetails()?.user_details?.staff_role == PriorityType.is_staff) || (UserDefaultFileManager.getUserDetails()?.user_details?.staff_role == PriorityType.is_grouphead
                                        ) || (UserDefaultFileManager
                                            .getUserDetails()?.user_details?.staff_role == PriorityType.is_principal){
                                        if(UserDefaultFileManager.getUserDetails()?.user_details?.staff_details?.count ?? 0 > 1)
                                        {
                                            let vc = PriorityVC(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                        else{
                                            if let data = UserDefaultFileManager
                                                .getUserDetails()?.user_details?.staff_details?.first{
                                                UserDefaultFileManager.saveStaffDetails(data: data)
                                            }
                                            
                                            let vc = TapBarVC(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.login_astype = 1
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                        
                                    }
                                    else{
                                        
                                        //
                                        if let data = UserDefaultFileManager
                                            .getUserDetails()?.user_details?.staff_details?.first{
                                            UserDefaultFileManager.saveStaffDetails(data: data)
                                        }
                                        
                                        
                                        let vc = TapBarVC(
                                            nibName: nil,
                                            bundle: nil
                                        )
                                        vc.login_astype = 1
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                    }
                                    
                                }
                                else if(UserDefaultFileManager
                                    .getUserDetails()?.user_details?.is_parent == true){
                                    
                                    if(
                                        UserDefaultFileManager
                                            .getUserDetails()?.user_details?.child_details?.count ?? 0 > 1
                                    ){
                                        let vc = PriorityVC(
                                            nibName: nil,
                                            bundle: nil
                                        )
                                        
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                    }
                                    else{
                                        
                                        if let data = UserDefaultFileManager
                                            .getUserDetails()?.user_details?.child_details?.first{
                                            UserDefaultFileManager.saveChildDetails(data: data)
                                        }
                                        
                                        let vc = TapBarVC(
                                            nibName: nil,
                                            bundle: nil
                                        )
                                        vc.login_astype = 2
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                    }
                                }
                                
                            }
                            
                            
                        }else{
                            DispatchQueue.main.async {
                                
                                self.AlertModal.showAlert(title: "", message: successMessage.message ?? "", on: self)
                            }
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        if #available(iOS 15.0, *) {
                            self.hideActivityLoader()
                        }
                    }
                }
            }
    }
    
    
    func validate_user() {
        guard let credentials = UserDefaultFileManager.getLoginCredentials() else { return }
        let secureID = SecureIDManager.getSecureID()
        
        let parameters: [String: Any] = [
            mobileNumber.mobile_number: credentials.mobile_number ?? "",
            mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
            mobileNumber.secure_id: secureID,
            mobileNumber.password: credentials.pwd ?? ""
        ]
        
        APIService.shared
            .makeApi(url: ServiceUrl.validate_validate_user, parameters:parameters
                     , type: ApitTypeSringFile.POST, token: ServiceUrl.token) { [self] (
                        result: Result<UserValidationResponseSuc,
                        Error>
                     ) in
                switch result {
                case .success(let response):
                    if response.status == true {
                        DispatchQueue.main.async {
                            // ✅ Handle successful validation here
                            // Example:
                            print("User validated successfully")
                        }
                    } else {
                        DispatchQueue.main.async {
                            AlertModal.showAlert(
                                title: "",
                                message: response.message ?? "Something went wrong.",
                                on: self
                            )
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        AlertModal.showAlert(
                            title: "Error",
                            message: error.localizedDescription,
                            on: self
                        )
                    }
                }
            }
    }
    
    
}

// MARK: - ✅ Text Field Delegate Functions
@available(iOS 14.0, *)
extension OTPVc : UITextFieldDelegate{
    
    
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        if text.count == 1 {
            let nextTag = textField.tag + 1
            if nextTag < otpFields.count {
                otpFields[nextTag].becomeFirstResponder() // Move to next field
            } else {
                textField.resignFirstResponder() // Hide keyboard if last digit entered
            }
        } else if text.count == 0 {
            let prevTag = textField.tag - 1
            if prevTag >= 0 {
                otpFields[prevTag].becomeFirstResponder() // Move back if deleted
            }
        }
        
        if otpTextField1.text != "" && otpTextField2.text != "" && otpTextField3.text != "" && otpTextField4.text != "" && otpTextField5.text != "" && otpTextField6.text != ""  {
            
            Validate_OTP(mobileNumber: mobile_number ?? "" , otp: otpTextField1.text! + otpTextField2.text! + otpTextField3.text! + otpTextField4.text! + otpTextField5.text! + otpTextField6.text!)
            
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow backspace for first two fields and move focus to the previous field
        
        print("rrrrr")
        if string.isEmpty {
            if textField.tag == 0 /*|| textField.tag == 1*/ {
                return true // Allow backspace on first two fields
            } else {
                let previousTextField = otpFields[textField.tag - 1]
                
                DispatchQueue.main.async {
                    previousTextField.becomeFirstResponder()
                }
                
                return true
            }
        }
        
        // Allow only one character per field
        return textField.text?.count == 0
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        // Find the lowest point among your text field, labels, and button
        let elements: [UIView] = [otpTextField1, ResendLbl, DidnotReciveOtpLbl, callUsLbl] // Add all relevant elements
        let bottomMost = elements.map {
            $0.convert($0.bounds, to: self.view).maxY
        }.max() ?? 0

        let keyboardTop = self.view.frame.height - keyboardFrame.height

        // Only move up if the bottom-most element is hidden by the keyboard
        if bottomMost > keyboardTop {
            let overlap = bottomMost - keyboardTop + 20 // padding
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -overlap
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }

    
    @objc func doneButtonAction() {
        view.endEditing(true)
    }
    
    
    func checkAutoFillPermission() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            print("🔹 Auto-Fill is enabled.")
        } else {
            print("❌ Auto-Fill is disabled.")
            showAutoFillAlert()
        }
    }
    func showAutoFillAlert() {
        let alert = UIAlertController(
            title: "Enable Auto-Fill",
            message: "To automatically fill your OTP, please enable Auto-Fill in Settings:\n\nSettings → Passwords & Accounts → AutoFill Passwords",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
