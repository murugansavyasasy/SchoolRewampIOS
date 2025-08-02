//
//  CreatePasswordVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/03/25.
//

import UIKit

@available(iOS 14.0, *)
class CreatePasswordVc: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var WelcomeLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var CreatePassTitleLbl: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var NewPassEyeImage: UIImageView!
    @IBOutlet weak var ConfirmPassEyeImage: UIImageView!
    @IBOutlet weak var createPassDefaultLbl: UILabel!
    @IBOutlet weak var ConfirmPassLabel: UILabel!
    @IBOutlet weak var confirmPassTextFld: UITextField!
    @IBOutlet weak var confirmPassBtnNam: UIButton!
    @IBOutlet weak var createPassTextFLd: UITextField!
    
    let alertModal = CustomAlert()
    
    var createPassText : String?
    var confirmPassText : String?
    var createNewPassword : Bool?
    var mobile_number : String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUpUI()
        
        createPassDefaultLbl.text = ChangePasswordStringFile.create_newpassword
        ConfirmPassLabel.text = ChangePasswordStringFile.confirm_password
        
        titleLbl.text = ChangePasswordStringFile.create_newpassword
        
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
        
        if createNewPassword == false{
            createPassDefaultLbl.text = ChangePasswordStringFile.Reset_the_new_password
            ConfirmPassLabel.text = ChangePasswordStringFile.confirm_password
            confirmPassBtnNam
                .setTitle(ChangePasswordStringFile.change_password, for: .normal)
            titleLbl.text = ChangePasswordStringFile.Reset_the_new_password
        }
        
    }
    
    
    func setUpUI(){
        
        
        
        
        BackBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        WelcomeLbl.setFont(style: .title, size: FontSize.TitleSize)
        DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        CreatePassTitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        BottomView.layer.cornerRadius = 30
        BottomView.layer.backgroundColor = Colornames.auth_screen_color?.cgColor
        BottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        confirmPassBtnNam.layer.backgroundColor = Colornames.auth_screen_color?.cgColor
        confirmPassBtnNam.layer.cornerRadius = 15
        confirmPassBtnNam.layer.masksToBounds = false
        
        // Adding shadow for a popped-up effect
        confirmPassBtnNam.layer.shadowColor = UIColor.black.cgColor
        confirmPassBtnNam.layer.shadowOffset = CGSize(width: 0, height: 5)
        confirmPassBtnNam.layer.shadowOpacity = 0.3
        confirmPassBtnNam.layer.shadowRadius = 6
        
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
            self.BottomView.frame.origin.y = self.view.frame.height - self.BottomView.frame.height - 30
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
        
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        
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
                            
                            
                            
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: "Success",
                                    message: successMessage.message ?? "",
                                    on: self
                                ) { [self] in
                                    
                                    UserDefaultFileManager
                                        .saveLoginCredentials(
                                            mobile_number:mobile_number ?? "",
                                            pwd:confirmPassTextFld.text ?? ""
                                        )
                                    
                                    if(UserDefaultFileManager.getUserDetails()?.user_details?.is_staff == true) &&  (
                                        UserDefaultFileManager.getUserDetails()?.user_details?.is_parent == true
                                    ){
                                        let vc = PriorityVC(nibName: nil,bundle: nil)
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                        
                                    }
                                    else if(UserDefaultFileManager.getUserDetails()?.user_details?.is_staff == true){
                                        if(UserDefaultFileManager.getUserDetails()?.user_details?.staff_role == PriorityType.is_staff){
                                            if(UserDefaultFileManager.getUserDetails()?.user_details?.staff_details?.count ?? 0 > 1)
                                            {
                                                let vc = PriorityVC(nibName: nil,bundle: nil)
                                                vc.modalPresentationStyle = .fullScreen
                                                present(vc, animated: true)
                                            }
                                            else{
                                                if let data = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details?.first{
                                                    UserDefaultFileManager.saveStaffDetails(data: data)}
                                                
                                                let vc = TapBarVC(nibName: nil,bundle: nil
                                                )
                                                vc.login_astype = 1
                                                vc.modalPresentationStyle = .fullScreen
                                                present(vc, animated: true)
                                            }
                                            
                                        }
                                        else{
                                            
                                            //
                                            if let data = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details?.first{
                                                UserDefaultFileManager.saveStaffDetails(data: data)}
                                            let vc = TapBarVC(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.login_astype = 1
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                        
                                    }
                                    else if(UserDefaultFileManager.getUserDetails()?.user_details?.is_parent == true){
                                        if(
                                            UserDefaultFileManager.getUserDetails()?.user_details?.child_details?.count ?? 0 > 1
                                        ){
                                            let vc = PriorityVC(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                        else{
                                            
                                            if let data =                                             UserDefaultFileManager.getUserDetails()?.user_details?.child_details?.first{
                                                UserDefaultFileManager.saveChildDetails(data: data)
                                            }
                                            
                                            let vc = TapBarVC(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.login_astype = 2
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                    }
                                    
                                }
                        }
                        
                    }else{
                        
                        DispatchQueue.main.async { [self] in
                            
                            alertModal
                                .showAlert(
                                    title: "",
                                    message:successMessage.message ?? "" ,
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
    
    
    func ResetPasswordAPIcall(){
        
        APIService.shared
            .makeApi(url: ServiceUrl.cred_reset_password, parameters: [COMMON_PARAMETER.mobile_number: mobile_number ??  "",COMMON_PARAMETER.new_password:confirmPassTextFld.text ?? ""], type: ApitTypeSringFile.POST, token: ServiceUrl.token){ [self] (
                result: Result<ResetPasswordSuc,
                Error>
            ) in
                
                switch result {
                    
                case.success(let successMessage):
                    
                    if successMessage.status == true {
                        
                        DispatchQueue.main.async { [self] in
                            
                            
                            
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: "Success",
                                    message: successMessage.message ?? "",
                                    on: self
                                ) { [self] in
                                    
                                    UserDefaultFileManager
                                        .saveLoginCredentials(
                                            mobile_number:mobile_number ?? "",
                                            pwd:confirmPassTextFld.text ?? ""
                                        )
                                    
                                    if(UserDefaultFileManager.getUserDetails()?.user_details?.is_staff == true) &&  (
                                        UserDefaultFileManager.getUserDetails()?.user_details?.is_parent == true
                                    ){
                                        let vc = PriorityVC(
                                            nibName: nil,
                                            bundle: nil
                                        )
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                        
                                    }
                                    else if(UserDefaultFileManager.getUserDetails()?.user_details?.is_staff == true){
                                        if(UserDefaultFileManager.getUserDetails()?.user_details?.staff_role == "p3"){
                                            if(
                                                UserDefaultFileManager
                                                    .getUserDetails()?.user_details?.staff_details?.count ?? 0 > 1
                                            )
                                            {
                                                let vc = PriorityVC(
                                                    nibName: nil,
                                                    bundle: nil
                                                )
                                                vc.modalPresentationStyle = .fullScreen
                                                present(vc, animated: true)
                                            }else{
                                                if let data = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details?.first{
                                                    UserDefaultFileManager.saveStaffDetails(data: data)}
                                                
                                                let vc = TapBarVC(
                                                    nibName: nil,
                                                    bundle: nil
                                                )
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
                                        
                                    }
                                    else if(UserDefaultFileManager.getUserDetails()?.user_details?.is_parent == true){
                                        
                                        //
                                        if(
                                            UserDefaultFileManager.getUserDetails()?.user_details?.child_details?.count ?? 0 > 1
                                        ){
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
    
}
