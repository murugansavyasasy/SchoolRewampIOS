//
//  OTPVc.swift
//  VsSchoolChimes
//
//  Created by admin on 23/10/24.
//

import UIKit

@available(iOS 14.0, *)
class OTPVc: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var otpTextField5: UITextField!
    @IBOutlet weak var otpTextField6: UITextField!
    
    
    @IBOutlet weak var validationBtnNm: UIButton!
    
    @IBOutlet weak var ResendLbl: UILabel!
    var secondsRemaining = 30 //5 minutes
    var myTimer : Timer?
    var timer: Timer?
    var timeRemaining = 30
    var forgetType  = false
    var otpFields: [UITextField] = []
    var mobile_number:String?
    var validateMobileData : [MobileNumberValidationData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ResendLbl.isUserInteractionEnabled = true
        validationBtnNm.layer.cornerRadius = CGFloat(Colornames.ButtoncornerRadius)
        validationBtnNm.backgroundColor = Colornames.ButtonColor
        
        setupOTPTextFields()
        
        let MobileNumber : String = UserDefaults.standard.object(
            forKey: UserDefault_FILE
                .Mobile_number) as? String ?? ""
        
        mobile_number = MobileNumber
    
        let resendGesture = UITapGestureRecognizer(target: self, action: #selector(controlTimer))
        ResendLbl.addGestureRecognizer(resendGesture)
        
        
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
            textField.delegate = self
            textField.tag = index // Assign a tag to each text field
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.font = UIFont.systemFont(ofSize: 24)
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        // Ensure only 1 character per field
        if text.count > 1 {
            textField.text = String(text.prefix(1))
        }
        
        // Move to the next text field if current text field has 1 character
        if text.count == 1 {
            let nextTag = textField.tag + 1
            if nextTag < otpFields.count {
                otpFields[nextTag].becomeFirstResponder()
            } else {
                textField.resignFirstResponder() // Hide keyboard if last field
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow backspace for first two fields and move focus to the previous field
        if string.isEmpty {
            if textField.tag == 0 || textField.tag == 1 {
                return true // Allow backspace on first two fields
            } else {
                // Move focus to the previous text field if it's not the first field
                if let previousTextField = view.viewWithTag(textField.tag - 1) as? UITextField {
                    DispatchQueue.main.async {
                        previousTextField.becomeFirstResponder()
                    }
                }
                return true
            }
        }
        
        // Allow only one character per field
        return textField.text?.count == 0
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
        
        let vc = PasswordVc(nibName: nil, bundle: nil)
      
        vc.createPassText  = createPassword
        vc.confirmPassText = confirmPassword
        vc.forgetType = CreatePasswordValue
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
