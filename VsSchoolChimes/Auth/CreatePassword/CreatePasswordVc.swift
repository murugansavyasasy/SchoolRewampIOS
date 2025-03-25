//
//  CreatePasswordVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/03/25.
//

import UIKit

@available(iOS 14.0, *)
class CreatePasswordVc: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var WelcomeLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var CreatePassTitleLbl: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var eyeImage: UIImageView!
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
        
        createPassTextFLd.delegate = self
        confirmPassTextFld.delegate = self
        confirmPassTextFld.addDoneButton()
        createPassTextFLd.addDoneButton()
        
    createPassDefaultLbl.setFont(style: .title, size: FontSize.TitleSize)
    ConfirmPassLabel.setFont(style: .title, size: FontSize.TitleSize)
    confirmPassBtnNam.setTitleFont(style: .body, size: FontSize.BodySize)

    if createNewPassword == false{
    createPassDefaultLbl.text = ChangePasswordStringFile.Reset_the_new_password
    ConfirmPassLabel.text = ChangePasswordStringFile.confirm_password
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
    
    @IBAction func showPassword(_ sender: UIButton) {
        sender.isSelected.toggle()
        let img = sender.isSelected ? ImageName.eye_fill : ImageName.eye_slash
       if sender.tag != 0{
           confirmPassTextFld.isSecureTextEntry = !sender.isSelected
           sender.setImage(img, for: .normal)
        }else{
            createPassTextFLd.isSecureTextEntry = !sender.isSelected
            sender.setImage(img, for: .normal)
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
                            
                            alertModal
                                .showAlert(
                                    title: "",
                                    message:successMessage.message ?? "" ,
                                    on: self
                                )
                            
                            let vc = LoginVc(nibName: nil, bundle: nil)
                            vc.modalPresentationStyle = .fullScreen
                            present(vc, animated: true, completion: nil)
                        }
                        
                    }else{
                        
                        DispatchQueue.main.async {
                            
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

             alertModal
                 .showAlert(
                     title: "",
                     message:successMessage.message ?? "" ,
                     on: self
                 )
             
             let vc = LoginVc(nibName: nil, bundle: nil)
             vc.modalPresentationStyle = .fullScreen
             present(vc, animated: true, completion: nil)

         }

         }else{

         DispatchQueue.main.async {
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

    
       
    }
