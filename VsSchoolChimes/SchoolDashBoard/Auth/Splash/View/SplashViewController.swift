//
//  SplashViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import UIKit



@available(iOS 14.0, *)
class SplashViewController: UIViewController {
    
    
    let loginAPI = Login()
    var logindata : [LoginResponseData] = []
   
    var countryId : String!
    var loginId : String!
    override func viewDidLoad() {
        super.viewDidLoad()
 
//        loginVerify()
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        let isRTL = (Language == "ar")  // Replace with your language-checking logic
            UIView.appearance().semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight

      
        let defaults = UserDefaults.standard
        
        countryId = defaults.string(forKey:DefaultsKeys.countryId)
        loginId = defaults.string(forKey:DefaultsKeys.LoginId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
            Version_Check()
        }
        
    }
 
    func Version_Check() {
        APIService.shared
            .makeApi(url: ServiceUrl.version_check, parameters: [
                COMMON_PARAMETER.device_type : API_CALL_HOTCODE.device_type,
                COMMON_PARAMETER.version_code: API_CALL_HOTCODE.Version_Code
            ], type: ApitTypeSringFile.POST, token: ServiceUrl.token) { [self] (
                result: Result<VersionCheckResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true {
                        DispatchQueue.main.async { [self] in
                            if successMessage.data?.first?.forceUpdate == true && successMessage.data?.first?.updateAvailable == true {
                                
                                let updateAlert = UIAlertController(
                                    title: "Needs to Update",
                                    message: "New updates are available. Would you like to update them now?",
                                    preferredStyle: .alert
                                )
                                updateAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                                    self.callAppStore(AppStoreLink: successMessage.data?.first?.redirect_url ?? "")
                                }))
                                
                                present(updateAlert, animated: true, completion: nil)
                                
                                
                            }else if successMessage.data?.first?.forceUpdate == false && successMessage.data?.first?.updateAvailable == true{
                                
                                let forceUpdateAlert = UIAlertController(
                                    title: "Needs to Update",
                                    message: "New updates are available. Would you like to update them now?",
                                    preferredStyle: .alert
                                )
                                forceUpdateAlert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: { _ in
                                    //                                    self.VerifyLogin()
                                    self.AppFlowChecking()
                                }))
                                forceUpdateAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                                    self.callAppStore(AppStoreLink: successMessage.data?.first?.redirect_url ?? "")
                                }))
                                present(forceUpdateAlert, animated: true, completion: nil)
                            }else{
                                
                                self.AppFlowChecking()
                                
                            }
                            
                        }
                    }else{
                        DispatchQueue.main.async {
                            
                            let updateAlert = UIAlertController(
                                title: "",
                                message: successMessage.message,
                                preferredStyle: .alert
                            )
                            updateAlert.addAction(UIAlertAction(title: "ok", style: .default, handler: { _ in
                                self.dismiss(animated: true)
                            }))
                            
                            self.present(
                                updateAlert,
                                animated: true,
                                completion: nil
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
 
    func AppFlowChecking(){
        
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
                
                let vc = PriorityViewController1(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
            
            
        }
    }
    
    func callAppStore (AppStoreLink : String)
    {
        
        let myUrl = AppStoreLink
        if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        guard let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
    


  

