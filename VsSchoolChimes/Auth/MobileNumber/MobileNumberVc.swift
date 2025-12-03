//
//  MobileNumberVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/03/25.
//

import UIKit

@available(iOS 14.0, *)
class MobileNumberVc: UIViewController,UITextFieldDelegate {
 
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var LoginTitleLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var WelcomeLbl: UILabel!
    @IBOutlet weak var BannerImageview: UIImageView!
    @IBOutlet weak var continueBtnName: UIButton!
    @IBOutlet weak var MobilenumLabel: UILabel!
    @IBOutlet weak var MobilTextFld:UITextField!
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var AlertModal = CustomAlert()
    var country_data : CountryData?
    var mobile_number_length : Int?
    var mobile_no_hint : String?
    var activeTextField: UITextField?
    var isFromCountry = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        // Assuming your textField is named `myTextField`
        let textFieldBottom = MobilTextFld.convert(MobilTextFld.bounds, to: self.view).maxY
        let keyboardTop = self.view.frame.height - keyboardFrame.height

        // Only move up if the textField is hidden by the keyboard
        if textFieldBottom > keyboardTop {
            let overlap = textFieldBottom - keyboardTop + 80 // Add a bit of padding
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
    func setupUI() {
        
        backBtn.isHidden = !isFromCountry
        backBtn.layer.cornerRadius = backBtn.frame.width / 2
        
        ContentView.layer.cornerRadius = 40
        ContentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        scrollView.layer.cornerRadius = 40
        scrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        country_data =   UserDefaultFileManager.getCountryDetails()
        MobilTextFld.addDoneButton()
        MobilTextFld.layer.cornerRadius = 20
        MobilTextFld.backgroundColor = .systemGray5.withAlphaComponent(0.7)

        continueBtnName.layer.cornerRadius = 15
        continueBtnName.layer.masksToBounds = false
       // continueBtnName.backgroundColor = Colornames.auth_screen_color
        // Adding shadow for a popped-up effect
        continueBtnName.layer.shadowColor = UIColor.black.cgColor
        continueBtnName.layer.shadowOffset = CGSize(width: 0, height: 5)
        continueBtnName.layer.shadowOpacity = 0.3
        continueBtnName.layer.shadowRadius = 6
        MobilTextFld.placeholder = country_data?.mobile_no_hint
        MobilTextFld.delegate = self
        MobilTextFld.keyboardType = .phonePad
        MobilTextFld.textContentType = .telephoneNumber
        MobilTextFld.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        WelcomeLbl.setFont(style: .title, size: 16)
        DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        LoginTitleLbl.setFont(style: .header, size: 16)
        MobilenumLabel.setFont(style: .body, size: 13)
        continueBtnName.setTitleFont(style: .primary, size: FontSize.TitleSize)
        addPadding(to: MobilTextFld, amount: 10)
        
    }
    
    func addPadding(to textField: UITextField, amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Active/focused text field
        textField.backgroundColor = .white
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 20
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        // Inactive/unfocused text field
        textField.layer.borderColor = UIColor.clear.cgColor
        textField.layer.borderWidth = 0
        textField.backgroundColor = .systemGray5
    }
    
    @IBAction func continueBtn(_ sender: Any) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
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
            return AlertModal.showAlert(title: AlertstringFile.Oops, message: AlertstringFile.Enter_valid_Mobile, on: self)
        }
        guard mobile.count == country_data?.mobile_number_length else {
            return AlertModal.showAlert(title: AlertstringFile.Oops, message: AlertstringFile.Enter_valid_Mobile, on: self)
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
        
        let parameters: [String: Any] = [
            mobileNumber.mobile_number: MobilTextFld.text ?? "",
            mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
            mobileNumber.secure_id: secureID ]
        
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
                            
                           
                            guard let data = response.data?.first else {
                                print("No data available")
                                return
                            }
                            
                            print("Responce Data : ",data)
                            
                            UserDefaultFileManager
                                .saveUserDetails(
                                    data: (data))
                            
                            if(data.is_number_exists == true){
                                
                                if(data.otp_sent == true){
                                    
                                    otp_Vc(valdiateResponse: response.data ?? [])
                                }
                                else if(data.is_password_updated == true) {
                                    
                                    let vc = PasswordVc(nibName: nil, bundle: nil)
                                    vc.modalPresentationStyle = .fullScreen
                                    vc.mobile_number = MobilTextFld.text ?? ""
                                    present(vc, animated: true)
                                    
                                }
                                
                            }
                            else {
                                AlertModal
                                    .showAlert(
                                        title: AlertstringFile.Oops,
                                        message: response.message ?? "",
                                        on: self
                                    )
                            }
                            
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            AlertModal
                                .showAlert(
                                    title: AlertstringFile.Oops,
                                    message: response.message ?? "",
                                    on: self
                                )
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [self] in
                        print(error.localizedDescription)
                        AlertModal
                            .showAlert(
                                title: AlertstringFile.Oops,
                                message: error.localizedDescription,
                                on: self
                            )
                    }
                }
            }
        
    }

    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    
}

@available(iOS 14.0, *)
extension MobileNumberVc : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Allow autofill suggestion (detected when string has more than 1 character)
        if string.count > 1 {
            return true
        }
        
        // Get current text
        let currentText = textField.text ?? ""
        let formattedText = removeCountryCodeAndSpaces(from: currentText)
        
        // Ensure correct formatting
        if formattedText != currentText {
            textField.text = formattedText
        }

        // Check length restriction
        let newLength = (formattedText.count + string.count - range.length)
        return newLength <= (country_data?.mobile_number_length ?? 10)
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }

        // Remove country code & spaces
        let cleanedText = removeCountryCodeAndSpaces(from: text)

        // Limit to max length
        let maxLength = country_data?.mobile_number_length ?? 10
        let finalText = String(cleanedText.prefix(maxLength))

        // Set cleaned text back to textField
        textField.text = finalText
    }

    
    func removeCountryCodeAndSpaces(from phone: String) -> String {
        // Define a regex pattern that matches a leading '+' followed by 1-3 digits and any optional whitespace.
        let pattern = "^\\+\\d{1,3}\\s*"
        var phoneWithoutCountryCode = phone

        // Remove the country code using the regular expression.
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(location: 0, length: phone.utf16.count)
            phoneWithoutCountryCode = regex.stringByReplacingMatches(in: phone,
                                                                     options: [],
                                                                     range: range,
                                                                     withTemplate: "")
        }
        
        // Remove all whitespace (spaces, newlines, etc.) from the remaining phone number.
        let trimmedPhone = phoneWithoutCountryCode.components(separatedBy: .whitespacesAndNewlines).joined()
        return trimmedPhone
    }
}
