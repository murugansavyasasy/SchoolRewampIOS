
//  LoginVc.swift
//  VsSchoolChimes
//
//  Created by admin on 23/10/24.
//

import UIKit

@available(iOS 14.0, *)
class LoginVc: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var MobilenumLabel: UILabel!
    @IBOutlet weak var forgetLbl: UILabel!
    @IBOutlet weak var passTextFld: UITextField!
    @IBOutlet weak var MobilTextFld: UITextField!
    @IBOutlet weak var loginBtnNm: UIButton!
    
    @IBOutlet weak var eyeImage: UIImageView!
    var activeTextField: UITextField?
    var AlertModal = CustomAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addDoneButtonOnKeyboard() // ✅ Added Done button for both text fields
        
        let forgetTap = UITapGestureRecognizer(target: self, action: #selector(forgetClick))
        forgetLbl.addGestureRecognizer(forgetTap)
        
        let eyeImageTap = UITapGestureRecognizer(target: self, action: #selector(togglePasswordVisibility))
        eyeImage.addGestureRecognizer(eyeImageTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MobilTextFld.becomeFirstResponder() // ✅ Forces keyboard to appear faster
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupUI() {
        loginBtnNm.backgroundColor = Colornames.ButtonColor
        loginBtnNm.layer.cornerRadius = CGFloat(Colornames.ButtoncornerRadius)
        
        MobilTextFld.delegate = self
        MobilTextFld.keyboardType = .numberPad
        
        passTextFld.delegate = self
        passTextFld.keyboardType = .default
        passTextFld.isSecureTextEntry = true
    }
    
    @IBAction func forgetClick() {
        if MobilTextFld.text != "" && MobilTextFld.text?.count == 10 {
            let vc = OTPVc(nibName: nil, bundle: nil)
            vc.forgetType = true
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        } else {
            view.makeToast(AlertstringFile.Enter_the_10_digit)
        }
    }
    
    @IBAction func togglePasswordVisibility() {
        passTextFld.isSecureTextEntry.toggle()
        let imageName = passTextFld.isSecureTextEntry ? "eye.fill" : "eye.slash.fill"
        eyeImage.image = UIImage(systemName: imageName)
    }
    
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
        passTextFld.inputAccessoryView = doneToolbar  // ✅ Added Done button for passTextFld
    }
    
    @objc func doneButtonAction() {
        view.endEditing(true) // ✅ Dismisses the keyboard for all text fields
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === MobilTextFld {
            let newLength = (textField.text?.count ?? 0) + string.count - range.length
            return newLength <= 10 // ✅ Ensures mobile number is max 10 digits
        }
        return true
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        if MobilTextFld.text!.isEmpty {
            AlertModal.showAlert(title: "", message: AlertstringFile.Enter_valid_Mobile, on: self)
            return
        }
        
        if MobilTextFld.text?.count != 10 {
            AlertModal.showAlert(title: "", message: AlertstringFile.Enter_valid_Mobile, on: self)
            return
        }
        
        if passTextFld.text!.isEmpty {
            AlertModal.showAlert(title: "", message: AlertstringFile.Invalid, on: self)
            return
        }
        
        let userDefault = UserDefaults.standard
        userDefault.set("1", forKey: DefaultsKeys.LoginId)
        
        let vc = OTPVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

