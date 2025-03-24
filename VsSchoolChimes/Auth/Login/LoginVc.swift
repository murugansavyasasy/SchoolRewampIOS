
//  LoginVc.swift
//  VsSchoolChimes
//
//  Created by admin on 23/10/24.
//

import UIKit

@available(iOS 14.0, *)
class LoginVc: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var BottomView: UIView!
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
      
        
        let forgetTap = UITapGestureRecognizer(target: self, action: #selector(forgetClick))
        forgetLbl.addGestureRecognizer(forgetTap)
        let eyeImageTap = UITapGestureRecognizer(target: self, action: #selector(togglePasswordVisibility))
        eyeImage.addGestureRecognizer(eyeImageTap)
        
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
     NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MobilTextFld.becomeFirstResponder() // ✅ Forces keyboard to appear faster
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupUI() {
        
        MobilTextFld.placeholder = mobile_no_hint
               
    BottomView.layer.cornerRadius = 30
    BottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        BottomView.backgroundColor = Colornames.auth_screen_color
        loginBtnNm.layer.cornerRadius = 15
        loginBtnNm.layer.masksToBounds = false
        loginBtnNm.backgroundColor = Colornames.auth_screen_color
                // Adding shadow for a popped-up effect
        loginBtnNm.layer.shadowColor = UIColor.black.cgColor
        loginBtnNm.layer.shadowOffset = CGSize(width: 0, height: 5)
        loginBtnNm.layer.shadowOpacity = 0.3
        loginBtnNm.layer.shadowRadius = 6
        MobilTextFld.delegate = self
        MobilTextFld.keyboardType = .numberPad
        passTextFld.delegate = self
        passTextFld.keyboardType = .default
        passTextFld.isSecureTextEntry = true
    }
    
    @IBAction func forgetClick() {
        if MobilTextFld.text != "" && MobilTextFld.text?.count == country_data?.mobile_number_length {
            
            //call forgot api and then navigate to the OTP screen
            
            let vc = OTPVc(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            vc.pageType = screenType.isForgotPassword
            present(vc, animated: true)
            
        } else {
            view.makeToast(AlertstringFile.Enter_the_10_digit)
        }
    }
    
    @IBAction func togglePasswordVisibility() {
        passTextFld.isSecureTextEntry.toggle()
        let imageName = passTextFld.isSecureTextEntry ? ImageName.eye_fill : ImageName.eye_slash
        eyeImage.image = imageName
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
        validateMobileAndPassword()
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
        validate_user()
    }
    
    
    
    func otp_Vc(valdiateResponse : [UserData]){
        let vc = OTPVc(nibName: nil, bundle: nil)
        vc.validateMobileData = valdiateResponse
        vc.mobile_number = MobilTextFld.text ?? ""
        vc.pageType = screenType.isLoginPage
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func validate_user() {
        
        let secureID = SecureIDManager.getSecureID()
        var parameters: [String: Any] = [
            
            mobileNumber.mobile_number: MobilTextFld.text ?? "",
            mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
            mobileNumber.secure_id: secureID,
            mobileNumber.password:passTextFld.text ?? ""
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
                        DispatchQueue.main.async { [self] in
                            
                            let data : UserData = (
                                response.data?.first
                            )!
                            localData.user_data = data
                            
                            
                            if(data.is_number_exists == true){
                                
                                if(data.otp_sent == true){
                                    
                                    otp_Vc(valdiateResponse: response.data ?? [])
                                }
                                else {
                                    
                                    if data.is_password_updated == true {
                                        
                                        UserDefaultFileManager
                                            .saveLoginCredentials(
                                                mobile_number:MobilTextFld.text ?? "",
                                                pwd:passTextFld.text ?? ""
                                            )
                                        
                                        localData.user_details = data.user_details
                                        
                                        if(data.user_details?.is_staff == true) &&  (
                                            data.user_details?.is_parent == true
                                        ){
                                            let vc = PriorityVC(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                            
                                        }
                                        else if(data.user_details?.is_staff == true){
                                            let vc = HomePageVc(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                            
                                        }
                                        else if(data.user_details?.is_parent == true){
                                            
                                            let vc = ParentHomePageVc(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                        
                                    }
                                    else{
                                        
                                    }
                                    
                                }
                                
                            }
                            else {
                                AlertModal
                                    .showAlert(
                                        title: "",
                                        message: response.message ?? "",
                                        on: self
                                    )
                            }
                            
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            AlertModal
                                .showAlert(
                                    title: "",
                                    message: response.message ?? "",
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
    



