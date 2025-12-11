
//  LoginVc.swift
//  VsSchoolChimes
//
//  Created by admin on 23/10/24.
//

import UIKit
import Contacts

@available(iOS 14.0, *)
class LoginVc: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var MobilenumLabel: UILabel!
    @IBOutlet weak var forgetLbl: UILabel!
    @IBOutlet weak var passTextFld: UITextField!
    @IBOutlet weak var MobilTextFld: UITextField!
    @IBOutlet weak var loginBtnNm: UIButton!
    @IBOutlet weak var eyeImage: UIImageView!
    @IBOutlet weak var BannerImgview: UIImageView!
    @IBOutlet weak var WelcomeLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var PasswordBaseview: UIView!
    
    var activeTextField: UITextField?
    var AlertModal = CustomAlert()
    var country_data : CountryData?
    private var originalContentInset: UIEdgeInsets = .zero
    private var originalScrollIndicatorInsets: UIEdgeInsets = .zero
    private var hasShownKeyboard = false
    var menuname = SettingStringFile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        country_data =   UserDefaultFileManager.getCountryDetails()
        setupUI()
        passTextFld.addDoneButton()
        MobilTextFld.addDoneButton()
        
        MobilTextFld.placeholder = country_data?.mobile_no_hint
        passTextFld.placeholder = menuname.Password.translated()
        let forgetTap = UITapGestureRecognizer(target: self, action: #selector(forgetClick))
        forgetLbl.addGestureRecognizer(forgetTap)
        let eyeImageTap = UITapGestureRecognizer(target: self, action: #selector(togglePasswordVisibility))
        eyeImage.addGestureRecognizer(eyeImageTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded() // ✅ Make sure layout is up-to-date
        DispatchQueue.main.async {
            self.MobilTextFld.becomeFirstResponder()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupUI() {
        
        MobilTextFld.layer.cornerRadius = 20
        MobilTextFld.layer.borderWidth = 0.5
        MobilTextFld.backgroundColor = .systemGray5.withAlphaComponent(0.8)
        MobilTextFld.layer.borderColor = UIColor.clear.cgColor
        MobilTextFld.placeholder = country_data?.mobile_no_hint
        MobilTextFld.delegate = self
        MobilTextFld.keyboardType = .phonePad
        MobilTextFld.textContentType = .telephoneNumber
        MobilTextFld.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20)) // Adjust width for padding
        MobilTextFld.leftView = paddingView
        MobilTextFld.leftViewMode = .always
        
        PasswordBaseview.layer.cornerRadius = 20
        PasswordBaseview.backgroundColor = .systemGray5.withAlphaComponent(0.8)
        PasswordBaseview.layer.borderWidth = 1
        PasswordBaseview.layer.borderColor = UIColor.clear.cgColor
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20)) // Adjust width for padding
        passTextFld.leftView = paddingView2
        passTextFld.leftViewMode = .always
        
        BottomView.layer.cornerRadius = 40
        BottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        loginBtnNm.layer.cornerRadius = 15
        loginBtnNm.layer.masksToBounds = false
        loginBtnNm.layer.shadowColor = UIColor.black.cgColor
        loginBtnNm.layer.shadowOffset = CGSize(width: 0, height: 2)
        loginBtnNm.layer.shadowOpacity = 0.2
        loginBtnNm.layer.shadowRadius = 2
        passTextFld.delegate = self
        passTextFld.keyboardType = .default
        passTextFld.isSecureTextEntry = true
        BackBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        loginBtnNm.setTitleFont(style: .primary, size: FontSize.TitleSize)
        WelcomeLbl.setFont(style: .title, size: FontSize.HeaderSize)
        DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        MobilenumLabel.setFont(style: .body, size: FontSize.BodySize)
        PasswordLabel.setFont(style: .body, size: FontSize.BodySize)
        forgetLbl.setFont(style: .title, size: FontSize.TitleSize)
    }
    
    @IBAction func forgetClick() {
        if MobilTextFld.text != "" && MobilTextFld.text?.count == country_data?.mobile_number_length {
            ForgotPasswordAPIcall()
        } else {
            AlertModal.showAlert(
                title: AlertstringFile.Oops,
                message: AlertstringFile.Enter_valid_Mobile,
                on: self)
        }
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        validateMobileAndPassword()
    }
    
    func validateMobileAndPassword() {
        guard let mobile = MobilTextFld.text, !mobile.isEmpty else {
            return AlertModal.showAlert(title: AlertstringFile.Oops, message: AlertstringFile.Enter_valid_Mobile, on: self)
        }
        guard mobile.count == country_data?.mobile_number_length else {
            return AlertModal.showAlert(title: AlertstringFile.Oops, message: AlertstringFile.Enter_valid_Mobile, on: self)
        }
        guard let password = passTextFld.text, !password.isEmpty else {
            return AlertModal.showAlert(title: AlertstringFile.Oops, message: AlertstringFile.Invalid, on: self)
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
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        let secureID = SecureIDManager.getSecureID()
        let parameters: [String: Any] = [
            mobileNumber.mobile_number: MobilTextFld.text ?? "",
            mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
            mobileNumber.secure_id: secureID,
            mobileNumber.password:passTextFld.text ?? ""
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.validate_validate_user,parameters:parameters
                                  , type: ApitTypeSringFile.POST, token: "") { [self] (result: Result<UserValidationResponseSuc,Error>) in
            switch result {
            case .success(let response):
                if response.status == true {
                    DispatchQueue.main.async { [self] in
                        guard let data = response.data?.first else {
                            return
                        }
                        if #available(iOS 15.0, *) {
                            self.hideActivityLoader()
                        }
                        UserDefaultFileManager.saveUserDetails(data: (data))
                        if(data.is_number_exists == true){
                            if(data.otp_sent == true){
                                UserDefaultFileManager.saveLoginCredentials(
                                    mobile_number:MobilTextFld.text ?? "",
                                    pwd:passTextFld.text ?? "")
                                otp_Vc(valdiateResponse: response.data ?? [])
                            }else {
                                if data.is_password_updated == true {
                                    UserDefaultFileManager.saveLoginCredentials(
                                        mobile_number:MobilTextFld.text ?? "",
                                        pwd:passTextFld.text ?? "")
                                    if(data.user_details?.is_staff == true) &&  (
                                        data.user_details?.is_parent == true
                                    ){
                                        let vc = PriorityVC()
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                        
                                    }else if(data.user_details?.is_staff == true){
                                        if(data.user_details?.staff_details?.count ?? 0 > 1){
                                            let vc = PriorityVC()
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }else{
                                            let vc = TapBarVC()
                                            ServiceUrl.token = data.user_details?.staff_details?.first?.access_token ?? ""
                                            vc.login_astype = 1
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                    }else if(data.user_details?.is_parent == true){
                                        
                                        if(data.user_details?.child_details?.count ?? 0 > 1){
                                            let vc = PriorityVC()
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }else{
                                            let vc = TapBarVC()
                                            vc.login_astype = 2
                                            ServiceUrl.token = data.user_details?.child_details?.first?.access_token ?? ""
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                    }
                                }
                            }
                        }else {
                            AlertModal.showAlert(
                                title: AlertstringFile.Oops,
                                message: response.message ?? "",
                                on: self)
                        }
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        if #available(iOS 15.0, *) {
                            self.hideActivityLoader()
                        }
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
    
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    
    func ForgotPasswordAPIcall() {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        APIService.shared
            .makeApi(url: ServiceUrl.cred_forgot_password, parameters: [COMMON_PARAMETER.mobile_number : MobilTextFld.text ?? ""], type: ApitTypeSringFile.POST, token: ServiceUrl.token){[self] (
                result : Result<ForgotPasswordResponeSuc,
                Error>
            ) in
                
                switch result {
                    
                case.success(let successmessage):
                    DispatchQueue.main.async { [self] in
                        if #available(iOS 15.0, *) {
                            self.hideActivityLoader()
                        }
                        if successmessage.status == true {
                            let vc = OTPVc(nibName: nil, bundle: nil)
                            vc.modalPresentationStyle = .fullScreen
                            vc.mobile_number = MobilTextFld.text
                            vc.pageType = screenType.isForgotPassword
                            vc.forgotpasswordData = successmessage.data ?? []
                            vc.otpContent = successmessage.data?.first?.forgot_otp_message ?? ""
                            vc.didnotReciveMessage = successmessage.data?.first?.more_info ?? ""
                            present(vc, animated: true)
                            
                        }else {
                            DispatchQueue.main.async {
                                self.AlertModal.showAlert(
                                    title: AlertstringFile.Oops,
                                    message: successmessage.message ?? "",
                                    on: self)
                            }
                        }
                    }
                    
                case.failure(let error):
                    
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        if #available(iOS 15.0, *) {
                            self.hideActivityLoader()
                        }
                    }
                }
            }
    }
}

@available(iOS 14.0, *)
extension LoginVc: UITextFieldDelegate {
    
    @IBAction func togglePasswordVisibility() {
        passTextFld.isSecureTextEntry.toggle()
        let imageName = passTextFld.isSecureTextEntry ? ImageName.eye_slash : ImageName.eye_fill
        eyeImage.image = imageName
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if textField == MobilTextFld {
            MobilTextFld.layer.borderColor = UIColor.systemBlue.cgColor
            MobilTextFld.backgroundColor = .white
        }else {
            PasswordBaseview.layer.borderColor = UIColor.systemBlue.cgColor
            PasswordBaseview.backgroundColor = .white
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
        if textField == MobilTextFld {
            MobilTextFld.layer.borderColor = UIColor.clear.cgColor
            MobilTextFld.backgroundColor = .systemGray5.withAlphaComponent(0.8)
        }else {
            PasswordBaseview.layer.borderColor = UIColor.clear.cgColor
            PasswordBaseview.backgroundColor = .systemGray5.withAlphaComponent(0.8)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === MobilTextFld {
            if string.count > 1 {
                return true
            }
            let currentText = textField.text ?? ""
            let formattedText = removeCountryCodeAndSpaces(from: currentText)
            if formattedText != currentText {
                textField.text = formattedText
            }
            let newLength = (formattedText.count + string.count - range.length)
            return newLength <= (country_data?.mobile_number_length ?? 10)
        }
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let cleanedText = removeCountryCodeAndSpaces(from: text)
        let maxLength = country_data?.mobile_number_length ?? 10
        let finalText = String(cleanedText.prefix(maxLength))
        textField.text = finalText
    }
    
    func removeCountryCodeAndSpaces(from phone: String) -> String {
        let pattern = "^\\+\\d{1,3}\\s*"
        var phoneWithoutCountryCode = phone
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(location: 0, length: phone.utf16.count)
            phoneWithoutCountryCode = regex.stringByReplacingMatches(in: phone,options: [],range: range,withTemplate: "")
        }
        let trimmedPhone = phoneWithoutCountryCode.components(separatedBy: .whitespacesAndNewlines).joined()
        return trimmedPhone
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        guard let activeTextField = [MobilTextFld, passTextFld].first(where: { $0.isFirstResponder }) else {
            return
        }
        let textFieldBottom = activeTextField.convert(activeTextField.bounds, to: self.view).maxY
        let keyboardTop = self.view.frame.height - keyboardFrame.height
        if textFieldBottom > keyboardTop {
            let overlap = textFieldBottom - keyboardTop + 80
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
}


