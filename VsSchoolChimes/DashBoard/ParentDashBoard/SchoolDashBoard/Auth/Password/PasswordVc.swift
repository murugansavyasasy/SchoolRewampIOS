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
    @IBOutlet weak var confirmPassTextFld: UITextField!
    @IBOutlet weak var confirmPass: UITextField!
    
    @IBOutlet weak var confirmPassBtnNam: UIButton!
    @IBOutlet weak var createPassTextFLd: UITextField!
    
    let alertModal = CustomAlert()
    
    var forgetType  = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
        
        
        if forgetType == true{
            
            
            createPassDefaultLbl.text = "Reset the new password"
            
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
                    
                    view.makeToast("Successfully password created")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let vc = PriorityViewController1(nibName: nil, bundle: nil)
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }else{
                    view.makeToast("Password Missmatched")
                }
            }else{
                view.makeToast("Enter the confirm password ")
                }
            
        }else{
            
           
            view.makeToast("Enter the new password ")
            
        }
        
    }
    
    @IBAction func togglePasswordVisibility() {
        confirmPassTextFld.isSecureTextEntry.toggle()
        let imageName = confirmPassTextFld.isSecureTextEntry ? "eye.fill" : "eye.slash.fill"
        eyeImage.image = UIImage(named: imageName)
       
        }
    
    
}
