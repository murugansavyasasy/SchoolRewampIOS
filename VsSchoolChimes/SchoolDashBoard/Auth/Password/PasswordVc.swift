    //
    //  PasswordVc.swift
    //  VsSchoolChimes
    //
    //  Created by admin on 26/10/24.
    //

    import UIKit

    @available(iOS 14.0, *)
    class PasswordVc: UIViewController {

    @IBOutlet weak var eyeImage: UIImageView!
    @IBOutlet weak var createPassDefaultLbl: UILabel!
    @IBOutlet weak var ConfirmPassLabel: UILabel!
    @IBOutlet weak var confirmPassTextFld: UITextField!
    @IBOutlet weak var confirmPassBtnNam: UIButton!
    @IBOutlet weak var createPassTextFLd: UITextField!

    let alertModal = CustomAlert()
    var forgetType  = false
    var createPassText : String?
    var confirmPassText : String?
    override func viewDidLoad() {
        
    super.viewDidLoad()
        createPassDefaultLbl.text = createPassText
        ConfirmPassLabel.text = confirmPassText
    createPassDefaultLbl.setFont(style: .title, size: FontSize.TitleSize)
    ConfirmPassLabel.setFont(style: .title, size: FontSize.TitleSize)
    confirmPassBtnNam.setTitleFont(style: .body, size: FontSize.BodySize)

    if forgetType == false{
    createPassDefaultLbl.text = ChangePasswordStringFile.Reset_the_new_password
    }

    let eyeImageTap = UITapGestureRecognizer(target: self, action: #selector(togglePasswordVisibility))
    eyeImage.addGestureRecognizer(eyeImageTap)
        
    }

    @IBAction func backBtn(_ sender: Any) {

    //        dismiss(animated: true)

    }

    @IBAction func confirmBtn(_ sender: Any) {

    if createPassTextFLd.text != "" {

    if  confirmPassTextFld.text != "" {

    if createPassTextFLd.text == confirmPassTextFld.text{

    //view.makeToast(AlertstringFile.Successfully_password_created)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        
        self.CretaeNewPasswordAPIcall()
//    let vc = PriorityViewController1(nibName: nil, bundle: nil)
//    vc.modalPresentationStyle = .fullScreen
//    self.present(vc, animated: true)
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

    @IBAction func togglePasswordVisibility() {
    confirmPassTextFld.isSecureTextEntry.toggle()
    let imageName = confirmPassTextFld.isSecureTextEntry ? "eye.fill" : "eye.slash.fill"
    eyeImage.image = UIImage(named: imageName)

    }

        func CretaeNewPasswordAPIcall(){
            
            APIService.shared.makeApi(url: ServiceUrl.password_create_new_password, parameters: [COMMON_PARAMETER.mobile_number: "" ?? "",COMMON_PARAMETER.new_password:confirmPassTextFld.text ?? "",CreateNewPasswordStringFile.old_password: "" ?? ""], type: ApitTypeSringFile.POST, token: ServiceUrl.token){ [self] (result: Result<CreateNewPasswordSuc, Error>) in
                
                switch result {
                    
                case.success(let successMessage):
                    
                    if successMessage.status == true {
                        
                        DispatchQueue.main.async { [self] in
                            
                            alertModal.showAlert(title: "", message: "Password Changed Successfully", on: self)
                        }
                        
                    }else{
                        
                        DispatchQueue.main.async {
                            
                            print("Try again later")
                            
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
            }
            
        }
        
//        func CretaeNewPasswordAPIcall(){
//         
//         APIService.shared.makeApi(url: ServiceUrl.password_create_new_password, parameters: [COMMON_PARAMETER.mobile_number: "" ?? "",COMMON_PARAMETER.new_password:confirmPassTextFld.text ?? "",CreateNewPasswordStringFile.old_password: "" ?? ""], type: ApitTypeSringFile.POST, token: ServiceUrl.token){ [self] (result: Result<CreateNewPasswordSuc, Error>) in
//         
//         switch result {
//         
//         case.success(let successMessage):
//         
//         if successMessage.status == true {
//         
//         DispatchQueue.main.async { [self] in
//         
//         }
//         
//         }else{
//         
//         DispatchQueue.main.async {
//         
//         }
//         }
//         
//         case .failure(let error):
//         DispatchQueue.main.async {
//         print(error.localizedDescription)
//         }
//         }
//         }
//         
//         }
//         
//         func ResetPasswordAPIcall(){
//         
//         APIService.shared.makeApi(url: ServiceUrl.password_reset_password, parameters: [COMMON_PARAMETER.mobile_number: "" ?? "",COMMON_PARAMETER.new_password:confirmPassTextFld.text ?? ""], type: ApitTypeSringFile.POST, token: ServiceUrl.token){ [self] (result: Result<ResetPasswordSuc, Error>) in
//         
//         switch result {
//         
//         case.success(let successMessage):
//         
//         if successMessage.status == true {
//         
//         DispatchQueue.main.async { [self] in
//         
//         
//         
//         }
//         
//         }else{
//         
//         DispatchQueue.main.async {
//         
//         }
//         }
//         
//         case .failure(let error):
//         DispatchQueue.main.async {
//         print(error.localizedDescription)
//         }
//         }
//         }
//         
//         }
//        
//        

    }
