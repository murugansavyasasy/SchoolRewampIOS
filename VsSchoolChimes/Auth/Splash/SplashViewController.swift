//
//  SplashViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import UIKit



@available(iOS 14.0, *)
class SplashViewController: UIViewController {
    
    var countryId : Int?
    var loginId : String!
    var version_Data : VersionData? = nil
    var AlertModal = CustomAlert()
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let Language = UserDefaults.standard.string(
            forKey: DefaultsKeys.Language ?? ""
        )
        let isRTL = (Language == "ar")  // Replace with your language-checking logic
            UIView.appearance().semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight

        if let countryDetails =   UserDefaultFileManager.getCountryDetails() {
            countryId = countryDetails.id
        }
        let secureID = SecureIDManager.getSecureID()
        print("secureIDsecureID",secureID)
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
                COMMON_PARAMETER.device_type : API_PARAMS_HOTCODE.device_type,
                COMMON_PARAMETER.version_code: API_PARAMS_HOTCODE.Version_Code,
                COMMON_PARAMETER.country_id: countryId  ?? 0 ,
            ], type: ApitTypeSringFile.POST, token: ServiceUrl.token) { [self] (
                result: Result<VersionCheckResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true {
                        DispatchQueue.main.async { [self] in
                            
                            version_Data = successMessage.data?.first
                            UserDefaultFileManager
                                .saveCountryDetails(
                                    data: (version_Data?.country_details)!)
                            ServiceUrl.baseurl = version_Data?.country_details?.base_url ?? ""
                            ServiceUrl.report_url = version_Data?.country_details?.reporting_url ?? ""
                            if(version_Data?.update_available == true){
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
    
    
    func validate_user() {
        
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number
        let password = UserDefaultFileManager.getLoginCredentials()?.pwd
        
        let secureID = SecureIDManager.getSecureID()
        var parameters: [String: Any] = [
            mobileNumber.mobile_number: mobile_num,
            mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
            mobileNumber.secure_id: secureID,
            mobileNumber.password:password
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
                                else {
                                    
                                    if data.is_password_updated == true {
                                        
                                        UserDefaultFileManager
                                            .saveLoginCredentials(
                                                mobile_number:mobile_num ?? "",
                                                pwd:password ?? ""
                                            )
                                        
                                        localData.user_details = data.user_details
                                        
                                        if(data.user_details?.is_staff == true) &&  (
                                            data.user_details?.is_parent == true
                                        ){
                                            let vc = PriorityVC(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                            
                                        }
                                        else if(data.user_details?.is_staff == true){
                                            let vc = TapBarVC(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.passedValue = 1
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                            
                                        }
                                        else if(data.user_details?.is_parent == true){
                                            
                                            let vc = TapBarVC(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.passedValue = 2
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                    }
                                    else{
                                        
                                    }
                                    
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
    
    
    func otp_Vc(valdiateResponse : [UserData]){
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number

        let vc = OTPVc(nibName: nil, bundle: nil)
        vc.validateMobileData = valdiateResponse
        vc.pageType = screenType.isSplash
        vc.mobile_number = mobile_num
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    func AppFlowChecking(){
    
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number
        let password = UserDefaultFileManager.getLoginCredentials()?.pwd
        
        if (mobile_num != nil) && (password != nil){
               validate_user()
                }
         
            else{
                let vc = LoginVc(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)

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
            version_Data?.update_available == true && version_Data?.force_update == true
        ){
            forceUpdateAlert
                .addAction(
                    UIAlertAction(
                        title: "Update",
                        style: .default,
                        handler: { [self] _ in
                            self.callAppStore(AppStoreLink: version_Data?.play_store_link ?? "")}))
        }
        else if(
            version_Data?.update_available == true && version_Data?.force_update == false
        )
        {
            forceUpdateAlert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: { _ in
            self.AppFlowChecking()
            }))
            
            
            forceUpdateAlert
                .addAction(
                    UIAlertAction(
                        title: "Update",
                        style: .default,
                        handler: { [self] _ in
                            self.callAppStore(
                                AppStoreLink: version_Data?.play_store_link ?? ""
                            )
                        })
                )
        }
        
        present(forceUpdateAlert, animated: true, completion: nil)
        
        
    }
}
    


  

