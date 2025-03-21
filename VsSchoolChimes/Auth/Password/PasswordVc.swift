//
//  PasswordVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

@available(iOS 14.0, *)
class PasswordVc: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var validateBtnName: UIButton!
    @IBOutlet weak var eyeImage: UIImageView!
    @IBOutlet weak var forgetLbl: UILabel!
    var AlertModal = CustomAlert()
    var mobile_number:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let eyeImageTap = UITapGestureRecognizer(target: self, action: #selector(togglePasswordVisibility))
        eyeImage.addGestureRecognizer(eyeImageTap)
        
        
        let forgetTap = UITapGestureRecognizer(target: self, action: #selector(forgetClick))
        forgetLbl.addGestureRecognizer(forgetTap)
        
        
    }
    
    
    @IBAction func forgetClick() {
        if mobile_number != ""  {
            
            //call forgot api and then navigate to the OTP screen
            
            let vc = OTPVc(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            vc.pageType = screenType.isForgotPassword
            present(vc, animated: true)
            
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
                            
                            
                            let data : UserData = (
                                response.data?.first
                            )!
                            localData.user_data = data
                            
                            
                            if(data.is_number_exists == true){
                                if(data.otp_sent == true){
                                    otp_Vc(valdiateResponse: response.data ?? [])
                                }
                                else {
                                    
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
                                    }
                                    else if(data.user_details?.is_staff == true){
                                        let vc = HomePageVc(nibName: nil,bundle: nil)
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                        
                                    }
                                    else if(data.user_details?.is_parent == true){
                                        let vc = ParentHomePageVc(nibName: nil,bundle: nil)
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
                                            let vc = PriorityViewController1(nibName: nil, bundle: nil)
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                        else if(data.user_details?.is_staff == true){
                                            let vc = HomePageVc(nibName: nil,bundle: nil)
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                            
                                        }
                                        else if(data.user_details?.is_parent == true){
                                            let vc = ParentHomePageVc(nibName: nil,bundle: nil)
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                        
                                    }
                                }
                                
                            }
                            else {
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
    
    
    
    
}
