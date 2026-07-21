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
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var passwordDefLbl: UILabel!
    @IBOutlet weak var backbtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var PasswordBaseview: UIView!
    
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
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let textFieldBottom = passwordTxtFld.convert(passwordTxtFld.bounds, to: self.view).maxY
        let keyboardTop = self.view.frame.height - keyboardFrame.height
        if textFieldBottom > keyboardTop {
            let overlap = textFieldBottom - keyboardTop + 120
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
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        PasswordBaseview.backgroundColor = .white
        PasswordBaseview.layer.borderColor = UIColor.backGroundClr.cgColor
        PasswordBaseview.layer.borderWidth = 1
        PasswordBaseview.layer.cornerRadius = 20
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        PasswordBaseview.layer.borderColor = UIColor.clear.cgColor
        PasswordBaseview.layer.borderWidth = 0
        PasswordBaseview.backgroundColor = .systemGray5
    }
    
    func SetpUI(){
        backbtn.layer.cornerRadius = backbtn.frame.width / 2
        PasswordBaseview.layer.borderWidth = 1
        PasswordBaseview.layer.borderColor = UIColor.clear.cgColor
        PasswordBaseview.layer.cornerRadius = 20
        passwordTxtFld.addDoneButton()
        passwordTxtFld.delegate = self
        scrollView.layer.cornerRadius = 40
        scrollView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        passwordDefLbl.setFont(style: .body, size: FontSize.BodySize)
        forgetLbl.setFont(style: .body, size: FontSize.TitleSize)
        validateBtnName.setTitleFont(style: .primary, size: FontSize.TitleSize)
        validateBtnName.layer.cornerRadius = 15
        validateBtnName.layer.masksToBounds = false
        validateBtnName.layer.shadowColor = UIColor.black.cgColor
        validateBtnName.layer.shadowOffset = CGSize(width: 0, height: 2)
        validateBtnName.layer.shadowOpacity = 0.2
        validateBtnName.layer.shadowRadius = 2
    }
    @IBAction func forgetClick() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        if mobile_number != ""  {
            ForgotPasswordAPIcall()
        } else {
            AlertModal.showAlert(title: AlertstringFile.Oops,message: AlertstringFile.Enter_valid_Mobile ,on: self)
        }
    }
    
    @IBAction func togglePasswordVisibility() {
        passwordTxtFld.isSecureTextEntry.toggle()
        let imageName = passwordTxtFld.isSecureTextEntry ? ImageName.eye_slash : ImageName.eye_fill
        eyeImage.image = imageName
        
    }
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    func setupUI() {
        validateBtnName.layer.cornerRadius = CGFloat(Colornames.ButtoncornerRadius)
        passwordTxtFld.delegate = self
        passwordTxtFld.keyboardType = .default
        passwordTxtFld.isSecureTextEntry = true
    }
    
    @IBAction func ValidatePassBtn(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        if passwordTxtFld.text == nil{
            AlertModal.showAlert(title: AlertstringFile.Oops,message: AlertstringFile.enter_valid_password ,on: self)
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
            ], type: ApitTypeSringFile.POST, token: "", isBaseUrl: true) { [self] (result: Result<UserValidationResponseSuc,Error>) in
                switch result {
                case .success(let response):
                    if response.status == true {
                        DispatchQueue.main.async { [self] in
                            guard let data = response.data?.first else {
                                print("No data available")
                                return
                            }
                            
                            UserDefaultFileManager.saveUserDetails(data: (data))
                            if(data.is_number_exists == true){
                                UserDefaultFileManager.saveLoginCredentials( mobile_number:mobile_number ?? "",pwd:passwordTxtFld.text ?? "")
                                if(data.otp_sent == true){
                                    otp_Vc(valdiateResponse: response.data ?? [])
                                }else {
                                    UserDefaultFileManager.saveLoginCredentials(mobile_number:mobile_number ?? "",pwd:passwordTxtFld.text ?? "")
                                    
                                    if(data.user_details?.is_staff == true) &&  (data.user_details?.is_parent == true){
                                        let vc = PriorityVC(nibName: nil,bundle: nil)
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                        
                                    }else if(data.user_details?.is_staff == true){
                                        
                                        if(data.user_details?.staff_role == PriorityType.is_staff) || (data.user_details?.staff_role == PriorityType.is_principal) || (
                                            data.user_details?.staff_role == PriorityType.is_grouphead){
                                            
                                            if(data.user_details?.staff_details?.count ?? 0 > 1){
                                                let vc = PriorityVC(nibName: nil,bundle: nil)
                                                vc.modalPresentationStyle = .fullScreen
                                                present(vc, animated: true)
                                            }else{
                                                if let data = data.user_details?.staff_details?.first{
                                                    UserDefaultFileManager.saveStaffDetails(data: data)}
                                                
                                                let vc = TapBarVC(nibName: nil,bundle: nil)
                                                vc.login_astype = 1
                                                vc.modalPresentationStyle = .fullScreen
                                                present(vc, animated: true)
                                            }
                                        }else{
                                            
                                            if let data = data.user_details?.staff_details?.first{
                                                UserDefaultFileManager.saveStaffDetails(data: data)}
                                            
                                            let vc = TapBarVC(nibName: nil,bundle: nil)
                                            vc.login_astype = 1
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                        
                                    } else if(data.user_details?.is_parent == true){
                                        
                                        if(data.user_details?.child_details?.count ?? 0 > 1){
                                            let vc = PriorityVC(nibName: nil,bundle: nil)
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }else{
                                            
                                            if let data = data.user_details?.child_details?.first{
                                                UserDefaultFileManager.saveChildDetails(data: data)
                                            }
                                            if UserDefaultFileManager.get_child_Details()?.is_not_allow ?? false{
                                                showCustomAlertNoDismiss(message: UserDefaultFileManager.get_child_Details()?.display_message ?? "", from: self )
                                            }else{
                                                let vc = TapBarVC(nibName: nil,bundle: nil)
                                                vc.login_astype = 2
                                                vc.modalPresentationStyle = .fullScreen
                                                present(vc, animated: true)
                                            }
                                        }
                                    }
                                    
                                }
                                
                                
                            } else {
                                AlertModal.showAlert(
                                    title: AlertstringFile.Oops,
                                    message: response.message ?? "",
                                    on: self)
                            }
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            AlertModal.showAlert(
                                title: AlertstringFile.Oops,
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
    
    func ForgotPasswordAPIcall() {
        
        APIService.shared.makeApi(url: ServiceUrl.cred_forgot_password, parameters: [COMMON_PARAMETER.mobile_number : mobile_number ?? ""], type: ApitTypeSringFile.POST, token: "", isBaseUrl: true){[self] (result : Result<ForgotPasswordResponeSuc,Error>) in
            
            switch result {
            case.success(let successmessage):
                
                if successmessage.status == true {
                    DispatchQueue.main.async { [self] in
                        let vc = OTPVc(nibName: nil, bundle: nil)
                        vc.modalPresentationStyle = .fullScreen
                        vc.mobile_number = mobile_number
                        vc.otpContent = successmessage.data?.first?.forgot_otp_message ?? ""
                        vc.didnotReciveMessage = successmessage.data?.first?.more_info ?? ""
                        vc.pageType = screenType.isForgotPassword
                        vc.forgotpasswordData = successmessage.data ?? []
                        present(vc, animated: true)
                        
                    }
                    
                }else {
                    DispatchQueue.main.async { [self] in
                        AlertModal.showAlert(
                            title: AlertstringFile.Oops,
                            message: successmessage.message ?? "",
                            on: self)
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
