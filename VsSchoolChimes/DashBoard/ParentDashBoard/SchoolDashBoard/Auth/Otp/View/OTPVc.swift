//
//  OTPVc.swift
//  VsSchoolChimes
//
//  Created by admin on 23/10/24.
//

import UIKit

class OTPVc: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var otpTextField1: UITextField!
       @IBOutlet weak var otpTextField2: UITextField!
       @IBOutlet weak var otpTextField3: UITextField!
       @IBOutlet weak var otpTextField4: UITextField!
       @IBOutlet weak var otpTextField5: UITextField!
       @IBOutlet weak var otpTextField6: UITextField!
   
    
    @IBOutlet weak var validationBtnNm: UIButton!
    
    @IBOutlet weak var ResendLbl: UILabel!
    
    var forgetType  = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
       

        // Do any additional setup after loading the view.
        
        validationBtnNm.layer.cornerRadius = CGFloat(Colornames.ButtoncornerRadius)
        validationBtnNm.backgroundColor = Colornames.ButtonColor 
        validationBtnNm.titleLabel?.textColor = .white
        
        setupOTPTextFields()
        
        
    }


   
    @IBAction func validationBtn(_ sender: Any) {
        
        let vc = PasswordVc(nibName: nil, bundle: nil)
        vc.forgetType = forgetType
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
        
    }
    
    
    
    func setupOTPTextFields() {
            let otpFields = [otpTextField1, otpTextField2, otpTextField3, otpTextField4, otpTextField5, otpTextField6]

            for (index, textField) in otpFields.enumerated() {
                textField?.delegate = self
                textField?.tag = index // Assign a tag to each text field
                textField?.textAlignment = .center
                textField?.keyboardType = .numberPad
//                textField?.borderStyle = .roundedRect
                textField?.font = UIFont.systemFont(ofSize: 24)
                textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            }
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            // Check if user input is valid and limit to one character
            if let text = textField.text, text.count > 1 {
                textField.text = String(text.prefix(1))
            }
            
            // Move to the next text field if the current text field has 1 character
            if textField.text?.count == 1 {
                switch textField {
                case otpTextField1:
                    otpTextField2.becomeFirstResponder()
                case otpTextField2:
                    otpTextField3.becomeFirstResponder()
                case otpTextField3:
                    otpTextField4.becomeFirstResponder()
                case otpTextField4:
                    otpTextField5.becomeFirstResponder()
                case otpTextField5:
                    otpTextField6.becomeFirstResponder()
                case otpTextField6:
                    otpTextField6.resignFirstResponder() // Dismiss keyboard if it's the last field
                default:
                    break
                }
            }
        }

        // Handle text field input restrictions (only one character per field)
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Allow backspace and single character input only
            guard let currentText = textField.text else { return false }
            let newLength = currentText.count + string.count - range.length
            return newLength <= 1
        }

        // Optionally, collect the entire OTP when needed (for submission)
        func collectOTP() -> String {
            let otpFields = [otpTextField1, otpTextField2, otpTextField3, otpTextField4, otpTextField5, otpTextField6]
            return otpFields.compactMap { $0?.text }.joined()
        }
    
}
