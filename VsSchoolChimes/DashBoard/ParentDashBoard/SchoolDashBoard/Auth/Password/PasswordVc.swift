//
//  PasswordVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class PasswordVc: UIViewController {

    
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
            
            
            createPassDefaultLbl.text = "Reset your password."
            
        }
    }

    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
        
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        
        
        
        if createPassTextFLd.text == confirmPassTextFld.text{
            
           
            alertModal.showAlert(title: "", message: "Enter valid password", on: self)
            
        }else{
            
            
            let vc = HomePageVc(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        }
        
    }
    
}
