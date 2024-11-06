//
//  SplashViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import UIKit



class SplashViewController: UIViewController {
    
    
    let loginAPI = Login()
    var logindata : [LoginResponseData] = []
   
    var countryId : String!
    var loginId : String!
    override func viewDidLoad() {
        super.viewDidLoad()
 
//        loginVerify()

      
        let defaults = UserDefaults.standard
        
        countryId = defaults.string(forKey:DefaultsKeys.countryId)
        loginId = defaults.string(forKey:DefaultsKeys.LoginId)
        
        print("countryIdcountryId",countryId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
          
            if countryId == nil{
                
                let vc = CountryVc(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
                
            }else{
                
                if loginId == nil{
                    
                    let vc = LoginVc(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }else{
                    
                    let vc = TapBarVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
             
                
            }
        }
        
    }
    
    
    
    func loginVerify(){
      
        loginAPI.postMethod(CountryID: 1, DeviceType: "iphone", MobileNumber: "9003769500", Password: "1234", SecureID: "2126A741-1042-434D-A331-61CA7A66378A")  { [self] result in
            switch result {
               case .success(let response):
                   print("Successfully got response:", response)
                
                logindata = response
                   // You can access the globalLoginResponseData variable anywhere now
               case .failure(let error):
                   print("Error:", error.localizedDescription)
               }
        }
        
    }
  
}
