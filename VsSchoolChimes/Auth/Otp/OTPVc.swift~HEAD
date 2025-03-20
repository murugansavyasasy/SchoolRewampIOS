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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var OtpContentLbl: UILabel!
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var otpTextField5: UITextField!
    @IBOutlet weak var otpTextField6: UITextField!
    @IBOutlet weak var validationBtnNm: UIButton!
    @IBOutlet weak var ResendLbl: UILabel!
    @IBOutlet weak var DidnotReciveOtpLbl: UILabel!
    @IBOutlet weak var PhoneNoStack: UIStackView!
    @IBOutlet weak var PhoneBtn1: UIButton!
    @IBOutlet weak var PhoneBtn2: UIButton!
    
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
        
        
        ResendLbl.isUserInteractionEnabled = true
        validationBtnNm.layer.cornerRadius = CGFloat(Colornames.ButtoncornerRadius)
        validationBtnNm.backgroundColor = Colornames.ButtonColor
        
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
        
        //OtpContentLbl.text = validateMobileData.first?.message
        setupOTPTextFields()
        
        let defaults = UserDefaults.standard
        mobile_number = defaults.string(forKey:DefaultsKeys.mobileNumber) ?? ""
        
        let resendGesture = UITapGestureRecognizer(target: self, action: #selector(controlTimer))
        ResendLbl.addGestureRecognizer(resendGesture)
        checkAutoFillPermission()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        otpTextField1.becomeFirstResponder() // Auto-focus on the first OTP field
    }
    
    // Optionally, collect the entire OTP when needed (for submission)
    func collectOTP() -> String {
        let otpFields = [otpTextField1, otpTextField2, otpTextField3, otpTextField4, otpTextField5, otpTextField6]
        return otpFields.compactMap { $0?.text }.joined()
    }
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
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
    
    @IBAction func PhoneNo1BtnAct(_ sender: Any) {
        
    }
    
    @IBAction func PhoneNo2BtnAct(_ sender: Any) {
        
    }
    
    func priotyScreenVC(){
        let vc = PriorityViewController1(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func CreatePasswordScreenVC(
        createPassword : String ,
        confirmPassword : String,
        CreatePasswordValue : Bool
    ){
        
//        let vc = PasswordVc(nibName: nil, bundle: nil)
//        vc.createPassText  = createPassword
//        vc.confirmPassText = confirmPassword
//        vc.forgetType = CreatePasswordValue
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
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
                           
                            
                            validateMobileData.first?.is_password_updated == false
                            ? CreatePasswordScreenVC(
                                createPassword: "Create Password",
                                confirmPassword: "Confirm Password",
                                CreatePasswordValue: true
                            )
                                : priotyScreenVC()
                           
                        }
                    }else{
                        DispatchQueue.main.async {
                            
                            self.AlertModal
                                .showAlert(
                                    title: "",
                                    message: successMessage.message ?? "",
                                    on: self
                                )
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
    
   func addDoneButtonOnKeyboard() {
       let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
       doneToolbar.barStyle = .black
       doneToolbar.isTranslucent = true
       
       let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
       let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
       
       doneToolbar.items = [flexSpace, doneButton]
       doneToolbar.sizeToFit()
       
       for textfield in otpFields{
           textfield.inputAccessoryView = doneToolbar
       }
   }
   
   @objc func doneButtonAction() {
       view.endEditing(true)
   }
   

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
               // Move focus to the previous text field if it's not the first field
//                if let previousTextField = view.viewWithTag(textField.tag - 1) as? UITextField {
//                    DispatchQueue.main.async {
//                        previousTextField.becomeFirstResponder()
//                    }
//                }
               
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
       
       let screenHeight = UIScreen.main.bounds.height
       
       if screenHeight <= 667{
           scrollView.setContentOffset(CGPoint(x: 0, y: 150), animated: true)
       }else if screenHeight > 667 && screenHeight <= 812{
           scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
       }else{
           scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
       }

       let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
       scrollView.contentInset = contentInsets
       scrollView.scrollIndicatorInsets = contentInsets
   }
    
   @objc func keyboardWillHide(notification: NSNotification) {
       
       scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
       scrollView.contentInset = .zero
       scrollView.scrollIndicatorInsets = .zero
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
