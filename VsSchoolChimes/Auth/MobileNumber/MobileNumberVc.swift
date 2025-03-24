//
//  MobileNumberVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/03/25.
//

import UIKit

@available(iOS 14.0, *)
class MobileNumberVc: UIViewController {

    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var continueBtnName: UIButton!
    @IBOutlet weak var MobilenumLabel: UILabel!
    @IBOutlet weak var MobilTextFld:
    UITextField!
    var AlertModal = CustomAlert()
    var country_data : CountryData?
    var mobile_number_length : Int?
    var mobile_no_hint : String?
    var activeTextField: UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
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
    func setupUI() {
        
        country_data =   UserDefaultFileManager.getCountryDetails()
        MobilTextFld.addDoneButton()
        BottomView.layer.cornerRadius = 30
        BottomView.backgroundColor = Colornames.auth_screen_color
        BottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]

      continueBtnName.layer.cornerRadius = 15
      continueBtnName.layer.masksToBounds = false
        continueBtnName.backgroundColor = Colornames.auth_screen_color
        // Adding shadow for a popped-up effect
        continueBtnName.layer.shadowColor = UIColor.black.cgColor
        continueBtnName.layer.shadowOffset = CGSize(width: 0, height: 5)
        continueBtnName.layer.shadowOpacity = 0.3
        continueBtnName.layer.shadowRadius = 6
        MobilTextFld.placeholder = country_data?.mobile_no_hint
        MobilTextFld.delegate = self
        MobilTextFld.keyboardType = .numberPad
    }
    
    @IBAction func continueBtn(_ sender: Any) {
        
        guard let button = sender as? UIButton else { return }

          // Animate the button when it is tapped
          UIView.animate(withDuration: 0.1, animations: {
              button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
              button.layer.shadowOffset = CGSize(width: 0, height: 2)
          }) { _ in
              // Animate the button back to its original state after the first animation
              UIView.animate(withDuration: 0.1) {
                  button.transform = .identity
                  button.layer.shadowOffset = CGSize(width: 0, height: 5)
              }
          }
        
        validateCredentials()
        
    }
    
    
    func validateCredentials() {
        
        guard let mobile = MobilTextFld.text, !mobile.isEmpty else {
            return AlertModal.showAlert(title: "", message: AlertstringFile.Enter_valid_Mobile, on: self)
        }
        
        guard mobile.count == country_data?.mobile_number_length else {
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
            return newLength <= country_data?.mobile_number_length ?? 0 // ✅ Ensures mobile number is max 10 digits
        }
        return true
    }
    
    
}
