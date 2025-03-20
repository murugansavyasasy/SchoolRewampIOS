
//  LoginVc.swift
//  VsSchoolChimes
//
//  Created by admin on 23/10/24.
//

import UIKit

@available(iOS 14.0, *)
class LoginVc: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var passwordStack: UIStackView!
    @IBOutlet weak var mobileNumberStack: UIStackView!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var MobilenumLabel: UILabel!
    @IBOutlet weak var forgetLbl: UILabel!
    @IBOutlet weak var passTextFld: UITextField!
    @IBOutlet weak var MobilTextFld: UITextField!
    @IBOutlet weak var loginBtnNm: UIButton!
    
    @IBOutlet weak var eyeImage: UIImageView!
    var activeTextField: UITextField?
    var AlertModal = CustomAlert()
    var pageType : Int?
    var mobile_number_length : Int?
    var mobile_no_hint : String?
    var country_data : CountryData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        passTextFld.addDoneButton()
        MobilTextFld.addDoneButton()
        country_data =   UserDefaultFileManager.getCountryDetails()
        mobile_no_hint = country_data?.mobile_no_hint
        mobile_number_length = country_data?.mobile_number_length
        hiddenShowView()
        MobilTextFld.placeholder = mobile_no_hint
        
        let forgetTap = UITapGestureRecognizer(target: self, action: #selector(forgetClick))
        forgetLbl.addGestureRecognizer(forgetTap)
        
        let eyeImageTap = UITapGestureRecognizer(target: self, action: #selector(togglePasswordVisibility))
        eyeImage.addGestureRecognizer(eyeImageTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MobilTextFld.becomeFirstResponder() // ✅ Forces keyboard to appear faster
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func hiddenShowView()
    {
        if pageType == screenType.isMobileNumber {
            passwordStack.isHidden = true
            forgetLbl.isHidden = true
        }else if pageType == screenType.isPassword {
            mobileNumberStack.isHidden = true
            forgetLbl.isHidden = false
        }else{
            mobileNumberStack.isHidden = false
            passwordStack.isHidden = false
            forgetLbl.isHidden = false
        }
        
    }
    
    func setupUI() {
        loginBtnNm.backgroundColor = Colornames.ButtonColor
        loginBtnNm.layer.cornerRadius = CGFloat(Colornames.ButtoncornerRadius)
        
        MobilTextFld.delegate = self
        MobilTextFld.keyboardType = .numberPad
        
        passTextFld.delegate = self
        passTextFld.keyboardType = .default
        passTextFld.isSecureTextEntry = true
    }
    
    @IBAction func forgetClick() {
        if MobilTextFld.text != "" && MobilTextFld.text?.count == 10 {
            let vc = OTPVc(nibName: nil, bundle: nil)
            vc.forgetType = true
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        } else {
            view.makeToast(AlertstringFile.Enter_the_10_digit)
        }
    }
    
    @IBAction func togglePasswordVisibility() {
        passTextFld.isSecureTextEntry.toggle()
        let imageName = passTextFld.isSecureTextEntry ? "eye.fill" : "eye.slash.fill"
        eyeImage.image = UIImage(systemName: imageName)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField // ✅ Now dynamically tracks the active field
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
 
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === MobilTextFld {
            let newLength = (textField.text?.count ?? 0) + string.count - range.length
            return newLength <= mobile_number_length ?? 0 // ✅ Ensures mobile number is max 10 digits
        }
        return true
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        if pageType == screenType.isMobileNumber {
            validateMobileNumber()
        }else if pageType == screenType.isPassword {
            validatePassword()
        }else{
            validateMobileAndPassword()
            
        }
    }
    
    func validateMobileNumber() {
        guard let mobile = MobilTextFld.text, !mobile.isEmpty else {
            return AlertModal.showAlert(title: "", message: AlertstringFile.Enter_valid_Mobile, on: self)
        }
        guard mobile.count == mobile_number_length else {
            return AlertModal.showAlert(title: "", message: AlertstringFile.Enter_valid_Mobile, on: self)
        }
        validate_user(page_value : pageType ?? 0)
    }
    
    func validatePassword() {
        guard let password = passTextFld.text, !password.isEmpty else {
            return AlertModal.showAlert(title: "", message: AlertstringFile.Invalid, on: self)
        }
        validate_user(page_value : pageType ?? 0)
    }
    
    func validateMobileAndPassword() {
        guard let mobile = MobilTextFld.text, !mobile.isEmpty else {
            return AlertModal.showAlert(title: "", message: AlertstringFile.Enter_valid_Mobile, on: self)
        }
        guard mobile.count == mobile_number_length else {
            return AlertModal.showAlert(title: "", message: AlertstringFile.Enter_valid_Mobile, on: self)
        }
        guard let password = passTextFld.text, !password.isEmpty else {
            return AlertModal.showAlert(title: "", message: AlertstringFile.Invalid, on: self)
        }
        
        validate_user(page_value : pageType ?? 0)
    }
    
    func otp_Vc(valdiateResponse : [UserData]){
        let vc = OTPVc(nibName: nil, bundle: nil)
        vc.validateMobileData = valdiateResponse
        vc.mobile_number = MobilTextFld.text ?? ""
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func validate_user(page_value : Int) {
        
        let secureID = SecureIDManager.getSecureID()
        var parameters: [String: Any] = [
            mobileNumber.mobile_number: MobilTextFld.text ?? "",
            mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
            mobileNumber.secure_id: secureID
        ]
        if page_value == screenType.isLoginPage {
            parameters[mobileNumber.password] = passTextFld.text ?? ""
        }
        
        APIService.shared.makeApi(url: ServiceUrl.validate_validate_user, parameters:parameters
                                  , type: ApitTypeSringFile.POST, token: ServiceUrl.token) { [self] (
                                    result: Result<UserValidationResponseSuc,
                                    Error>
                                  ) in
            switch result {
            case .success(let response):
                if response.status == true {
                    DispatchQueue.main.async { [self] in
                        
                        UserDefaultFileManager.saveLoginCredentials(mobile_number : MobilTextFld.text ?? "",pwd:passTextFld.text ?? "")
                        
                        if let data = response.data?.first{
                            
                            if(data.is_number_exists == true){
                                
                                if(data.otp_sent == true){
                                    
                                    otp_Vc(valdiateResponse: response.data ?? [])
                                }else {
                                    if(page_value == screenType.isMobileNumber){
                                        pageType = screenType.isPassword
                                        hiddenShowView()
                                    }else if(page_value == screenType.isLoginPage){
                                        
                                    }else if(page_value == screenType.isPassword){
                                        
                                    }
                                }
                            }else{
                                AlertModal.showAlert(
                                    title: "",
                                    message: response.message ?? "",
                                    on: self)
                            }
                        }
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        AlertModal.showAlert(
                            title: "",
                            message: response.message ?? "",
                            on: self)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func getUserDetails() {
        
    }
    
}

