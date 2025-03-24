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
    
    
    @IBOutlet weak var callUsLbl: UILabel!
    var secondsRemaining = 30 //5 minutes
    var myTimer : Timer?
    var timer: Timer?
    var timeRemaining = 30
    var forgetType  = false
    var otpFields: [UITextField] = []
    var mobile_number:String?
    var validateMobileData : [UserData] = []
    var AlertModal = CustomAlert()
    var pageType : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BottomView.layer.cornerRadius = 30
        BottomView.backgroundColor = Colornames.auth_screen_color
        BottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        
        BackBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        OtpContentLbl.setFont(style: .title, size: FontSize.TitleSize)
        ResendLbl.setFont(style: .body, size: FontSize.BodySize)
        DidnotReciveOtpLbl.setFont(style: .body, size: FontSize.BodySize)

        ResendLbl.isUserInteractionEnabled = true
        OtpContentLbl.text = "  " + (validateMobileData.first?.more_info ?? "") + (
            mobile_number ?? "") + "  "
        
       
        
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
        
        let resendGesture = UITapGestureRecognizer(target: self, action: #selector(controlTimer))
        ResendLbl.addGestureRecognizer(resendGesture)
        
        let callUsGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(showDialOptions)
        )
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
        let dialNumbersString = validateMobileData.first?.dial_numbers ?? ""  // Example numbers
        let dialNumbers = dialNumbersString.components(separatedBy: ",")
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
        }
        otpTextField1.becomeFirstResponder()
    }
    
    // Optionally, collect the entire OTP when needed (for submission)
    func collectOTP() -> String {
        let otpFields = [otpTextField1, otpTextField2, otpTextField3, otpTextField4, otpTextField5, otpTextField6]
        return otpFields.compactMap { $0?.text }.joined()
    }
    
    //    MARK: Resend Timer Set
    @IBAction func controlTimer() {
        myTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            if self?.secondsRemaining ?? 0 > 0 {
                let minutes = Int(self?.secondsRemaining ?? 0) / 60
                let seconds = Int(self?.secondsRemaining ?? 0) % 60
                //VerificationTimeVal is a UI element to display the time
                let timerResults = String(format: "%02d:%02d", minutes, seconds)
                self?.ResendLbl.text = "\(timerResults)"
                self?.secondsRemaining -= 1
            } else {
                timer.invalidate()
                //VerificationTimeVal is a UI element to display the time
                self?.ResendLbl.text = OTPScreenStringFile.Resend
            }
        }
        
        // Add the timer to the current RunLoop
        RunLoop.current.add(myTimer!, forMode: .common)
        
    }
    
    func priotyScreenVC(){
        let vc = PriorityVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func CreatePasswordScreenVC(
        createPassword : String ,
        confirmPassword : String,
        CreatePasswordValue : Bool
    ){
        

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
                    if successMessage.status == true {
                        DispatchQueue.main.async { [self] in
                            
                            
                            if(pageType == screenType.isForgotPassword){
                                
                                let vc = CreatePasswordVc(
                                    nibName: nil,
                                    bundle: nil
                                )
                                vc.modalPresentationStyle = .fullScreen
                                vc.createNewPassword = false
                                vc.mobile_number = mobileNumber
                                present(vc, animated: true)
                                
                            }
                           
                            else if(localData.user_data?.is_password_updated == false){
                               
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
                                if(localData.user_data?.user_details?.is_staff == true) &&  (
                                    localData.user_data?.user_details?.is_parent == true
                                ){
                                    let vc = PriorityVC(
                                        nibName: nil,
                                        bundle: nil
                                    )
                                    vc.modalPresentationStyle = .fullScreen
                                    present(vc, animated: true)
                                    
                                }
                                else if(localData.user_data?.user_details?.is_staff == true){
                                    let vc = TapBarVC(
                                        nibName: nil,
                                        bundle: nil
                                    )
                                    vc.passedValue = 1
                                    vc.modalPresentationStyle = .fullScreen
                                    present(vc, animated: true)
                                    
                                }
                                else if(localData.user_data?.user_details?.is_parent == true){
                                    
                                    let vc = TapBarVC(
                                        nibName: nil,
                                        bundle: nil
                                    )
                                    vc.passedValue = 2
                                    vc.modalPresentationStyle = .fullScreen
                                    present(vc, animated: true)
                                }
                                
                            }
                            
                                                
                         }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.priotyScreenVC()
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        
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

    @objc func keyboardWillShow(notification: NSNotification) { // -----> to set key board set height


    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
    if self.view.frame.origin.y == 0 {
    self.view.frame.origin.y -= keyboardSize.height-91
    print("keyboardSize.height",keyboardSize.height)
    }
    }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
    if self.view.frame.origin.y != 0 {
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
