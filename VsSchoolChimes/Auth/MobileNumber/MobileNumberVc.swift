//
//  MobileNumberVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/03/25.
//

import UIKit

@available(iOS 14.0, *)
class MobileNumberVc: UIViewController {

    @IBOutlet weak var continueBtnName: UIButton!
    @IBOutlet weak var MobilenumLabel: UILabel!
    @IBOutlet weak var MobilTextFld:
    UITextField!
    var AlertModal = CustomAlert()
    var country_data : CountryData? = nil
    var mobile_number_length : Int?
    var mobile_no_hint : String?
    var activeTextField: UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
       
    }

    func setupUI() {
        
        country_data =   UserDefaultFileManager.getCountryDetails()
        mobile_no_hint = country_data?.mobile_no_hint
        mobile_number_length = country_data?.mobile_number_length
        
        continueBtnName.backgroundColor = Colornames.ButtonColor
        continueBtnName.layer.cornerRadius = CGFloat(Colornames.ButtoncornerRadius)
    
        MobilTextFld.delegate = self
        MobilTextFld.keyboardType = .numberPad
    }
    
    @IBAction func continueBtn(_ sender: Any) {
        
        
        validateCredentials()
        
    }
    
    
    func validateCredentials() {
        
        guard let mobile = MobilTextFld.text, !mobile.isEmpty else {
            return AlertModal.showAlert(title: "", message: AlertstringFile.Enter_valid_Mobile, on: self)
        }
        
        guard mobile.count == mobile_number_length else {
            return AlertModal.showAlert(title: "", message: AlertstringFile.Enter_valid_Mobile, on: self)
        }
        
        validate_user()
    }
    
    func otp_Vc(valdiateResponse : [UserData]){
        let vc = OTPVc(nibName: nil, bundle: nil)
        vc.validateMobileData = valdiateResponse
        vc.mobile_number = MobilTextFld.text ?? ""
        vc.pageType = screenType.isMobileNumber
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func validate_user() {
        
        let secureID = SecureIDManager.getSecureID()
        var parameters: [String: Any] = [
            mobileNumber.mobile_number: MobilTextFld.text ?? "",
            mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
            mobileNumber.secure_id: secureID
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
                                else{
                                    
                                    let vc = PasswordVc(nibName: nil, bundle: nil)
                                    vc.modalPresentationStyle = .fullScreen
                                    vc.mobile_number = MobilTextFld.text ?? ""
                                    present(vc, animated: true)
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

@available(iOS 14.0, *)
extension MobileNumberVc : UITextFieldDelegate {
    
    
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
    
    // MARK: - ✅ Done Button for Keyboard
    func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        doneToolbar.barStyle = .blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        
        doneToolbar.items = [flexSpace, doneButton]
        doneToolbar.sizeToFit()
        
        MobilTextFld.inputAccessoryView = doneToolbar // ✅ Added Done button for MobilTextFld
       
        
    }
    
    @objc func doneButtonAction() {
        view.endEditing(true) // ✅ Dismisses the keyboard for all text fields
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === MobilTextFld {
            let newLength = (textField.text?.count ?? 0) + string.count - range.length
            return newLength <= mobile_number_length ?? 0 // ✅ Ensures mobile number is max 10 digits
        }
        return true
    }
    
    
}
