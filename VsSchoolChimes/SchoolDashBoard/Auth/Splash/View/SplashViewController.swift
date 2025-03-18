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
   
    var countryId : String?
    var loginId : String!
    var version_Data : VersionData? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
 

        let Language = UserDefaults.standard.string(
            forKey: DefaultsKeys.Language ?? ""
        )
        let isRTL = (Language == "ar")  // Replace with your language-checking logic
            UIView.appearance().semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight

//        if let countryDetails = UserDefaultFileManager.getCountryDetails() {
//            countryId = countryDetails.country_id
//        }
        
        countryId = localData.country_data?.country_id
        print("countryId",localData.country_data?.country_id)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
            
            if(countryId != nil){
                Version_Check()
             }
            else{
                let vc = CountryVc(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
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
                            
                            version_Data = successMessage.data?.first
                            
                            localData.country_data = version_Data?.countryDetails ?? nil
                            
                            ServiceUrl.baseurl = version_Data?.countryDetails?.base_url ?? ""
                            ServiceUrl.report_url = version_Data?.countryDetails?.reporting_url ?? ""
                            
                            
                            if(version_Data?.updateAvailable == true){
                                showUpdatePopup()
                                
                            }
                            else{
                                self.AppFlowChecking()
                            }
                            
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
    
    func showUpdatePopup ()
    {
        
        let forceUpdateAlert = UIAlertController(
            title: "Needs to Update",
            message: "New updates are available. Would you like to update them now?",
            preferredStyle: .alert
        )
        
        if(
            version_Data?.updateAvailable == true && version_Data?.forceUpdate == true
        ){
            
            forceUpdateAlert
                .addAction(
                    UIAlertAction(
                        title: "Update",
                        style: .default,
                        handler: { [self] _ in
                            self.callAppStore(AppStoreLink: version_Data?.redirect_url ?? "")
                        })
                )
        }
        else if(
            version_Data?.updateAvailable == true && version_Data?.forceUpdate == false
        )
        {
            forceUpdateAlert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: { _ in
                //
                self.AppFlowChecking()
            }))
            
            
            forceUpdateAlert
                .addAction(
                    UIAlertAction(
                        title: "Update",
                        style: .default,
                        handler: { [self] _ in
                            self.callAppStore(AppStoreLink: version_Data?.redirect_url ?? "")
                        })
                )
        }
        
        present(forceUpdateAlert, animated: true, completion: nil)
        
        
    }
}
    


  

