//
//  PasswordVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

@available(iOS 14.0, *)
class PasswordVc: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var validateBtnName: UIButton!
    @IBOutlet weak var eyeImage: UIImageView!
    @IBOutlet weak var forgetLbl: UILabel!
    var AlertModal = CustomAlert()
    var mobile_number:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SetpUI()
        
        
        let eyeImageTap = UITapGestureRecognizer(target: self, action: #selector(togglePasswordVisibility))
        eyeImage.addGestureRecognizer(eyeImageTap)
        
        
        let forgetTap = UITapGestureRecognizer(target: self, action: #selector(forgetClick))
        forgetLbl.addGestureRecognizer(forgetTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3) { // Smooth animation
                self.BottomView.frame.origin.y = self.view.frame.height - keyboardFrame.height - self.BottomView.frame.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) { // Smooth animation
            self.BottomView.frame.origin.y = self.view.frame.height - self.BottomView.frame.height
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func SetpUI(){
        passwordTxtFld.addDoneButton()
        BottomView.layer.cornerRadius = 30
        BottomView.backgroundColor = Colornames.auth_screen_color
        BottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        validateBtnName.layer.cornerRadius = 15
        validateBtnName.layer.masksToBounds = false
        validateBtnName.backgroundColor = Colornames.auth_screen_color
        // Adding shadow for a popped-up effect
        validateBtnName.layer.shadowColor = UIColor.black.cgColor
        validateBtnName.layer.shadowOffset = CGSize(width: 0, height: 5)
        validateBtnName.layer.shadowOpacity = 0.3
        validateBtnName.layer.shadowRadius = 6
    }
    @IBAction func forgetClick() {
        if mobile_number != ""  {
            //call forgot api and then navigate to the OTP screen
            ForgotPasswordAPIcall()
        } else {
            AlertModal
                .showAlert(
                    title: "",
                    message: AlertstringFile.Enter_valid_Mobile ,
                    on: self)
        }
    }
    
    @IBAction func togglePasswordVisibility() {
        
        passwordTxtFld.isSecureTextEntry.toggle()
        let imageName = passwordTxtFld.isSecureTextEntry ? ImageName.eye_fill : ImageName.eye_slash
        eyeImage.image = imageName
    }
    
    func setupUI() {
        validateBtnName.backgroundColor = Colornames.ButtonColor
        validateBtnName.layer.cornerRadius = CGFloat(Colornames.ButtoncornerRadius)
        
        passwordTxtFld.delegate = self
        passwordTxtFld.keyboardType = .default
        passwordTxtFld.isSecureTextEntry = true
    }
    
    @IBAction func ValidatePassBtn(_ sender: Any) {
        
        if passwordTxtFld.text == nil{
            AlertModal
                .showAlert(
                    title: "",
                    message: AlertstringFile.enter_valid_password ,
                    on: self)
        }else{
            validate_user()
        }
        
    }
    
    
    func otp_Vc(valdiateResponse : [UserData]){
        let vc = OTPVc(nibName: nil, bundle: nil)
        vc.validateMobileData = valdiateResponse
        vc.mobile_number = mobile_number ?? ""
        vc.pageType = screenType.isPassword
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func validate_user() {
        
        let secureID = SecureIDManager.getSecureID()
        APIService.shared
            .makeApi(url: ServiceUrl.validate_validate_user, parameters:[
                
                mobileNumber.mobile_number: mobile_number ?? "",
                mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
                mobileNumber.secure_id: secureID,
                mobileNumber.password : passwordTxtFld.text ?? ""
            ]
                     , type: ApitTypeSringFile.POST, token: ServiceUrl.token) { [self] (
                        result: Result<UserValidationResponseSuc,
                        Error>
                     ) in
                switch result {
                case .success(let response):
                    if response.status == true {
                        DispatchQueue.main.async { [self] in
                            guard let data = response.data?.first else {
                                print("No data available")
                                return
                            }
                            
                            UserDefaultFileManager
                                .saveUserDetails(
                                    data: (data))
                            
                            if(data.is_number_exists == true){
                                if(data.otp_sent == true){
                                    otp_Vc(valdiateResponse: response.data ?? [])
                                } else {
                                    UserDefaultFileManager
                                        .saveLoginCredentials(
                                            mobile_number:mobile_number ?? "",
                                            pwd:passwordTxtFld.text ?? ""
                                        )
                                   
                                   
                                    if(data.user_details?.is_staff == true) &&  (
                                        data.user_details?.is_parent == true
                                    ){
                                        let vc = PriorityVC(nibName: nil, bundle: nil)
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                    } else if(data.user_details?.is_staff == true){
                                        let vc = TapBarVC(nibName: nil,bundle: nil)
                                        vc.passedValue = 1
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                        
                                    } else if(data.user_details?.is_parent == true){
                                        let vc = TapBarVC(nibName: nil,bundle: nil)
                                        vc.passedValue = 2
                                        vc.childDetail = localData.user_data?.user_details?.child_details?.first
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                    }
                                    
                                    if(data.is_password_updated == true){
                                        UserDefaultFileManager
                                            .saveLoginCredentials(
                                                mobile_number:mobile_number ?? "",
                                                pwd:passwordTxtFld.text ?? ""
                                            )
                                        localData.user_details = data.user_details
                                        if(data.user_details?.is_staff == true) &&  (
                                            data.user_details?.is_parent == true
                                        ){
                                            let vc = PriorityVC(nibName: nil, bundle: nil)
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        } else if(data.user_details?.is_staff == true){
                                            let vc = TapBarVC(nibName: nil,bundle: nil)
                                            vc.passedValue = 1
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                            
                                        } else if(data.user_details?.is_parent == true){
                                            let vc = TapBarVC(nibName: nil,bundle: nil)
                                            vc.passedValue = 2
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                    }
                                }
                            } else {
                                AlertModal.showAlert(
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
    
    func ForgotPasswordAPIcall() {
        
        APIService.shared
            .makeApi(url: ServiceUrl.cred_forgot_password, parameters: [COMMON_PARAMETER.mobile_number : mobile_number ?? ""], type: ApitTypeSringFile.POST, token: ServiceUrl.token){[self] (
                result : Result<ForgotPasswordResponeSuc,
                Error>
            ) in
                
                switch result {
                    
                case.success(let successmessage):
                    
                    if successmessage.status == true {
                        
                        DispatchQueue.main.async { [self] in
                            
                            print("Success,Success")
                            
                            let vc = OTPVc(nibName: nil, bundle: nil)
                            vc.modalPresentationStyle = .fullScreen
                            vc.mobile_number = mobile_number
                            vc.pageType = screenType.isForgotPassword
                            present(vc, animated: true)
                            
                        }
                        
                    }else {
                        
                        DispatchQueue.main.async { [self] in
                            AlertModal
                                .showAlert(
                                    title: "",
                                    message: successmessage.message ?? "",
                                    on: self
                                )
                        }
                    }
                    
                case.failure(let error):
                    
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
            }
    }
}
