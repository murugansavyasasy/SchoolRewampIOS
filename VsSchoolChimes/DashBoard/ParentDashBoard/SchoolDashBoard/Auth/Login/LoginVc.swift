//
//  LoginVc.swift
//  VsSchoolChimes
//
//  Created by admin on 23/10/24.
//

import UIKit

@available(iOS 14.0, *)
class LoginVc: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var forgetLbl: UILabel!
    @IBOutlet weak var passTextFld: UITextField!
    @IBOutlet weak var MobilTextFld: UITextField!
    @IBOutlet weak var loginBtnNm: UIButton!
    
    @IBOutlet weak var eyeImage: UIImageView!
    var activeTextField: UITextField?
    var AlertModal = CustomAlert()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        loginBtnNm.backgroundColor = Colornames.ButtonColor
        loginBtnNm.layer.cornerRadius = CGFloat(Colornames.ButtoncornerRadius)
        
        MobilTextFld.delegate = self
        MobilTextFld.keyboardType = .numberPad
        self.addDoneButtonOnKeyboard()
        
        passTextFld.delegate = self
        passTextFld.isUserInteractionEnabled = true
        //passwordTextfield.isSecureTextEntry = true
        passTextFld.keyboardType = .default
        
        
        // Add observers for keyboard appearance and disappearance
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        let forget = UITapGestureRecognizer(target: self, action: #selector(forgetClick))
        forgetLbl.addGestureRecognizer(forget)
        let eyeImageTap = UITapGestureRecognizer(target: self, action: #selector(forgetClick))
        eyeImage.addGestureRecognizer(eyeImageTap)
        
    }

    
    deinit {
        // Remove observers when the view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction  func forgetClick(){
        
        
        let vc = OTPVc(nibName: nil, bundle: nil)
        vc.forgetType = true
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
           activeTextField = passTextFld
       }

       func textFieldDidEndEditing(_ textField: UITextField) {
           activeTextField = nil
       }

       // MARK: - Keyboard Handling
       @objc func keyboardWillShow(notification: NSNotification) {
           if activeTextField == passTextFld {  // Check if the active text field is the one you want to scroll for
               if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                   let keyboardHeight = keyboardFrame.cgRectValue.height
                   
                   // Adjust the view or scroll the content
                   UIView.animate(withDuration: 0.3) {
                       self.view.frame.origin.y = -keyboardHeight  // Shift the whole view up
                   }
               }
           }
       }

       @objc func keyboardWillHide(notification: NSNotification) {
           // Reset the view position when the keyboard is hidden
           UIView.animate(withDuration: 0.3) {
               self.view.frame.origin.y = 0  // Reset view to original position
           }
       }

    @IBAction func loginBtn(_ sender: Any) {
        

        if MobilTextFld.text!.isEmpty {

            AlertModal.showAlert(title: "", message: "Enter valid Mobile", on: self)
      
        }

        else if (MobilTextFld.text?.count) != 10 {

            AlertModal.showAlert(title: "", message: "Enter valid Mobile", on: self)
       
        }

        else if  passTextFld.text!.isEmpty{

            AlertModal.showAlert(title: "", message: "Invalid Password", on: self)

      

        } else{
            
            var term : String = "1"
            
            let userDefault = UserDefaults.standard
            userDefault.set(term, forKey: DefaultsKeys.LoginId)
           
            let vc = PriorityViewController1(nibName: nil, bundle: nil)
                  vc.modalPresentationStyle = .fullScreen
                  present(vc, animated: true)
        }
        
  
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {


    if textField === MobilTextFld {

    return range.location <= 9
    }
    else{

    return true

    }

    }

    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent

        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButtonAction))

      
        let items = [flexSpace, done]

        doneToolbar.items = items

        doneToolbar.sizeToFit()

        
        self.MobilTextFld.inputAccessoryView = doneToolbar

    }

    @objc func doneButtonAction()
    {
        MobilTextFld.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // Dismiss the keyboard
            return true // Indicate that the text field should process the return key
        }
   

}
