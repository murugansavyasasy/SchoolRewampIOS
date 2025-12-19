//
//  CreatePasswordVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/03/25.
//

import UIKit

@available(iOS 14.0, *)
class CreatePasswordVc: UIViewController{
    
    @IBOutlet weak var NewPassEyeImage: UIImageView!
    @IBOutlet weak var ConfirmPassEyeImage: UIImageView!
    @IBOutlet weak var titleLbl: LocalizationLabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var DescriptionLbl: LocalizationLabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var createPassDefaultLbl: LocalizationLabel!
    @IBOutlet weak var ConfirmPassLabel: LocalizationLabel!
    @IBOutlet weak var confirmPassTextFld: UITextField!
    @IBOutlet weak var confirmPassBtnNam: LocalizationButton!
    @IBOutlet weak var createPassTextFLd: UITextField!
    @IBOutlet weak var createPasswordBaseview: UIView!
    @IBOutlet weak var confirmPasswordBaseview: UIView!
    
    let alertModal = CustomAlert()
    var createPassText : String?
    var confirmPassText : String?
    var createNewPassword : Bool?
    var mobile_number : String?
    var chnage_passwordPage : Bool = false
    let mobileNo = UserDefaultFileManager.getLoginCredentials()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        if createNewPassword == true {
            createPassDefaultLbl.localizationKey = ChangePasswordStringFile.Enter_the_old_password
            ConfirmPassLabel.localizationKey = ChangePasswordStringFile.Enter_the_new_password
            titleLbl.localizationKey = ChangePasswordStringFile.change_password
        } else {
            createPassDefaultLbl.localizationKey = ChangePasswordStringFile.Enter_the_new_password
            ConfirmPassLabel.localizationKey = ChangePasswordStringFile.confirm_password
            titleLbl.localizationKey = ChangePasswordStringFile.Reset_password
            confirmPassBtnNam.localizationKey = ChangePasswordStringFile.Reset_password
            confirmPassBtnNam.setTitle(ChangePasswordStringFile.Reset_password, for: .normal)
        }
        
        createPassTextFLd.delegate = self
        confirmPassTextFld.delegate = self
        confirmPassTextFld.addDoneButton()
        createPassTextFLd.addDoneButton()
        createPassDefaultLbl.setFont(style: .title, size: FontSize.TitleSize)
        ConfirmPassLabel.setFont(style: .title, size: FontSize.TitleSize)
        confirmPassBtnNam.setTitleFont(style: .body, size: FontSize.BodySize)
        createPassTextFLd.isSecureTextEntry = true
        confirmPassTextFld.isSecureTextEntry = true
        
        let eyeTap = UITapGestureRecognizer(target: self, action: #selector(showPassword))
        ConfirmPassEyeImage.addGestureRecognizer(eyeTap)
        ConfirmPassEyeImage.isUserInteractionEnabled = true
        
        let NeweyeTap = UITapGestureRecognizer(target: self, action: #selector(showPassword))
        NewPassEyeImage.addGestureRecognizer(NeweyeTap)
        NewPassEyeImage.isUserInteractionEnabled = true
        if chnage_passwordPage{
            createPassDefaultLbl.localizationKey = ChangePasswordStringFile.Enter_the_old_password
            ConfirmPassLabel.localizationKey = ChangePasswordStringFile.Enter_the_New_password
            titleLbl.localizationKey = ChangePasswordStringFile.change_password
            confirmPassBtnNam.localizationKey = ChangePasswordStringFile.change_password
            confirmPassBtnNam.setTitle(ChangePasswordStringFile.change_password, for: .normal)
        }
    }
    
    func setUpUI(){
        
        BackBtn.layer.cornerRadius = BackBtn.frame.width / 2
        BackBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        titleLbl.setFont(style: .header, size: FontSize.TitleSize)
        BottomView.layer.cornerRadius = 40
        BottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        confirmPassBtnNam.layer.cornerRadius = 15
        confirmPassBtnNam.layer.masksToBounds = false
        confirmPassBtnNam.layer.shadowColor = UIColor.black.cgColor
        confirmPassBtnNam.layer.shadowOffset = CGSize(width: 0, height: 2)
        confirmPassBtnNam.layer.shadowOpacity = 0.2
        confirmPassBtnNam.layer.shadowRadius = 2
        createPasswordBaseview.layer.cornerRadius = 20
        confirmPasswordBaseview.layer.cornerRadius = 20
        createPassTextFLd.layer.cornerRadius = 20
        confirmPassTextFld.layer.cornerRadius = 20
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        createPassTextFLd.leftView = paddingView
        createPassTextFLd.leftViewMode = .always
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        confirmPassTextFld.leftView = paddingView2
        confirmPassTextFld.leftViewMode = .always
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if let activeField = view.firstResponder as? UIView {
            let activeFieldFrame = activeField.convert(activeField.bounds, to: self.view)
            let keyboardTop = self.view.frame.height - keyboardFrame.height
            let overlap = activeFieldFrame.maxY - keyboardTop + 10
            if overlap > 0 {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y = -overlap
                }
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
    
    @IBAction func backBtn(_ sender: Any) {
        if chnage_passwordPage{
            self.presentingViewController?.dismiss(animated: true)
        }else{
            self.presentingViewController?.presentingViewController?.dismiss(animated: true)
        }
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        if createPassTextFLd.text != "" {
            if  confirmPassTextFld.text != "" {
                if createPassTextFLd.text == confirmPassTextFld.text{
                    if createNewPassword == false{
                        ResetPasswordAPIcall()
                    }else{
                        self.CretaeNewPasswordAPIcall()
                    }
                }else{
                    view.makeToast(AlertstringFile.Password_Missmatched)
                }
            }else{
                view.makeToast(AlertstringFile.Enterthe_confirm_password)
            }
        }else{
            view.makeToast(AlertstringFile.Enter_the_new_password)
        }
        
        if chnage_passwordPage{
            if createPassTextFLd.text != "" && confirmPassTextFld.text != ""{
                changePassword()
            }else{
                view.makeToast(AlertstringFile.Enter_the_new_password)
            }
            
        }
        
    }
    
    @IBAction func showPassword(_ sender: UITapGestureRecognizer) {
        if sender.view == NewPassEyeImage{
            createPassTextFLd.isSecureTextEntry.toggle()
            let imageName = createPassTextFLd.isSecureTextEntry ? ImageName.eye_slash : ImageName.eye_fill
            NewPassEyeImage.image = imageName
        }else if sender.view == ConfirmPassEyeImage{
            confirmPassTextFld.isSecureTextEntry.toggle()
            let imageName = confirmPassTextFld.isSecureTextEntry ? ImageName.eye_slash : ImageName.eye_fill
            ConfirmPassEyeImage.image = imageName
        }
    }
    
    
    @available(iOS 14.0, *)
    func CretaeNewPasswordAPIcall(){
        APIService.shared
            .makeApi(url: ServiceUrl.cred_create_new_password, parameters: [
                
                COMMON_PARAMETER.mobile_number: mobile_number ?? "" ,COMMON_PARAMETER.new_password:confirmPassTextFld.text ?? ""
            ], type: ApitTypeSringFile.POST, token: ""){ [self] (
                result: Result<CreateNewPasswordSuc,
                Error>
            ) in
                switch result {
                case.success(let successMessage):
                    if successMessage.status == true {
                        DispatchQueue.main.async { [self] in
                            CustomAlert.showAlertWithOkAction(
                                title: AlertstringFile.Success,
                                message: successMessage.message ?? "",
                                on: self
                            ) { [self] in
                                
                                UserDefaultFileManager.saveLoginCredentials(mobile_number:mobile_number ?? "",pwd:confirmPassTextFld.text ?? "")
                                
                                if(UserDefaultFileManager.getUserDetails()?.user_details?.is_staff == true) &&  (UserDefaultFileManager.getUserDetails()?.user_details?.is_parent == true){
                                    let vc = PriorityVC(nibName: nil,bundle: nil)
                                    vc.modalPresentationStyle = .fullScreen
                                    present(vc, animated: true)
                                    
                                }else if(UserDefaultFileManager.getUserDetails()?.user_details?.is_staff == true){
                                    if(UserDefaultFileManager.getUserDetails()?.user_details?.staff_role == PriorityType.is_staff) || (UserDefaultFileManager.getUserDetails()?.user_details?.staff_role == PriorityType.is_grouphead) || (
                                        UserDefaultFileManager
                                            .getUserDetails()?.user_details?.staff_role == PriorityType.is_principal
                                    ){
                                        if(UserDefaultFileManager.getUserDetails()?.user_details?.staff_details?.count ?? 0 > 1){
                                            let vc = PriorityVC(nibName: nil,bundle: nil)
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }else{
                                            if let data = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details?.first{
                                                UserDefaultFileManager.saveStaffDetails(data: data)}
                                            
                                            let vc = TapBarVC(nibName: nil,bundle: nil)
                                            vc.login_astype = 1
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                        
                                    }else{
                                        if let data = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details?.first{
                                            UserDefaultFileManager.saveStaffDetails(data: data)}
                                        let vc = TapBarVC(nibName: nil,bundle: nil)
                                        vc.login_astype = 1
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                    }
                                    
                                }else if(UserDefaultFileManager.getUserDetails()?.user_details?.is_parent == true){
                                    if(
                                        UserDefaultFileManager.getUserDetails()?.user_details?.child_details?.count ?? 0 > 1
                                    ){
                                        let vc = PriorityVC(nibName: nil,bundle: nil)
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                    }else{
                                        
                                        if let data =                                 UserDefaultFileManager.getUserDetails()?.user_details?.child_details?.first{
                                            UserDefaultFileManager.saveChildDetails(data: data)
                                        }
                                        
                                        let vc = TapBarVC(nibName: nil,bundle: nil)
                                        vc.login_astype = 2
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                    }
                                }
                            }
                        }
                        
                    }else{
                        DispatchQueue.main.async { [self] in
                            alertModal.showAlert(title: "",message:successMessage.message ?? "" ,on: self)
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
            }
    }
    
    
    func ResetPasswordAPIcall(){
        
        APIService.shared.makeApi(url: ServiceUrl.cred_reset_password, parameters: [COMMON_PARAMETER.mobile_number: mobile_number ??  "",COMMON_PARAMETER.new_password:confirmPassTextFld.text ?? ""], type: ApitTypeSringFile.POST, token: ServiceUrl.token){ [self] (result: Result<ResetPasswordSuc, Error>) in
            switch result {
            case.success(let successMessage):
                if successMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success,message: successMessage.message ?? "",on: self) { [self] in
                            
                            UserDefaultFileManager.saveLoginCredentials(mobile_number:mobile_number ?? "",pwd:confirmPassTextFld.text ?? "")
                            
                            if(UserDefaultFileManager.getUserDetails()?.user_details?.is_staff == true) &&  (
                                UserDefaultFileManager.getUserDetails()?.user_details?.is_parent == true
                            ){
                                let vc = PriorityVC(nibName: nil,bundle: nil)
                                vc.modalPresentationStyle = .fullScreen
                                present(vc, animated: true)
                                
                            }else if(UserDefaultFileManager.getUserDetails()?.user_details?.is_staff == true){
                                if(UserDefaultFileManager.getUserDetails()?.user_details?.staff_role == PriorityType.is_staff){
                                    if(UserDefaultFileManager
                                        .getUserDetails()?.user_details?.staff_details?.count ?? 0 > 1){
                                        let vc = PriorityVC(nibName: nil,bundle: nil)
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                    }else{
                                        if let data = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details?.first{
                                            UserDefaultFileManager.saveStaffDetails(data: data)}
                                        
                                        let vc = TapBarVC(nibName: nil,bundle: nil)
                                        vc.login_astype = 1
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                    }
                                    
                                } else{
                                    if let data = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details?.first{
                                        UserDefaultFileManager.saveStaffDetails(data: data)}
                                    
                                    let vc = TapBarVC(nibName: nil,bundle: nil)
                                    vc.login_astype = 1
                                    vc.modalPresentationStyle = .fullScreen
                                    present(vc, animated: true)
                                }
                                
                            }else if(UserDefaultFileManager.getUserDetails()?.user_details?.is_parent == true){
                                if(UserDefaultFileManager.getUserDetails()?.user_details?.child_details?.count ?? 0 > 1){
                                    let vc = PriorityVC(nibName: nil,bundle: nil)
                                    vc.modalPresentationStyle = .fullScreen
                                    present(vc, animated: true)
                                }else{
                                    if let data =              UserDefaultFileManager.getUserDetails()?.user_details?.child_details?.first{
                                        UserDefaultFileManager.saveChildDetails(data: data)
                                    }
                                    
                                    let vc = TapBarVC(nibName: nil,bundle: nil)
                                    vc.login_astype = 2
                                    vc.modalPresentationStyle = .fullScreen
                                    present(vc, animated: true)
                                }
                            }
                        }
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        alertModal.showAlert(title:"",message:successMessage.message ?? "" ,on: self)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func changePassword(){
        APIService.shared
            .makeApi(url: ServiceUrl.cred_change_password, parameters: [COMMON_PARAMETER.mobile_number: mobileNo?.mobile_number ?? "" ,COMMON_PARAMETER.new_password:confirmPassTextFld.text ?? "",COMMON_PARAMETER.old_password : createPassTextFLd.text ?? ""], type: ApitTypeSringFile.POST, token: ServiceUrl.token){ [self] (
                result: Result<ResetPasswordSuc,
                Error>
            ) in
                switch result {
                case.success(let successMessage):
                    if successMessage.status == true {
                        DispatchQueue.main.async { [self] in
                            if #available(iOS 15.0, *) {
                                let loginVC = LoginVc(nibName: nil, bundle: nil)
                                let nav = UINavigationController(rootViewController: loginVC)
                                nav.navigationBar.isHidden = true
                                if let window = UIApplication.shared.connectedScenes
                                    .compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first {
                                    window.rootViewController = nav
                                    window.makeKeyAndVisible()
                                }
                            }
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            alertModal.showAlert(title:"",message:successMessage.message ?? "" ,on: self)
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


@available(iOS 14.0, *)
extension CreatePasswordVc: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == createPassTextFLd {
            createPasswordBaseview.layer.borderColor = UIColor.systemBlue.cgColor
            createPasswordBaseview.layer.borderWidth = 1
            createPasswordBaseview.backgroundColor = .white
        }
        else if textField == confirmPassTextFld {
            confirmPasswordBaseview.layer.borderColor = UIColor.systemBlue.cgColor
            confirmPasswordBaseview.layer.borderWidth = 1
            confirmPasswordBaseview.backgroundColor = .white
        }
        textField.layer.cornerRadius = 20
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == createPassTextFLd {
            createPasswordBaseview.layer.borderColor = UIColor.clear.cgColor
            createPasswordBaseview.layer.borderWidth = 0
            createPasswordBaseview.backgroundColor = .systemGray5
        }
        else if textField == confirmPassTextFld {
            confirmPasswordBaseview.layer.borderColor = UIColor.clear.cgColor
            confirmPasswordBaseview.layer.borderWidth = 0
            confirmPasswordBaseview.backgroundColor = .systemGray5
        }
        textField.layer.borderWidth = 0
        textField.backgroundColor = .clear
    }
}
extension UIView {
    var firstResponder: UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            if let responder = subview.firstResponder {
                return responder
            }
        }
        return nil
    }
}
