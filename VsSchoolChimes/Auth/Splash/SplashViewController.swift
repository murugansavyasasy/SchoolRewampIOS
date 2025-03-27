//
//  SplashViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import UIKit
import Darwin


@available(iOS 14.0, *)
class SplashViewController: UIViewController, UIPopoverPresentationControllerDelegate, ReminderCalback {
    func backToCall() {
        AppFlowChecking()
    }
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var bottumSheet: UIView!
    @IBOutlet weak var developerDescript: UILabel!
    var overlayView: UIView?
    var countryId : Int?
    var loginId : String!
    var version_Data : VersionData? = nil
    var AlertModal = CustomAlert()
    override func viewDidLoad() {
        super.viewDidLoad()
        if isDeveloperModeEnabled() {
            bottumSheet.isHidden = false
            bottumSheet.layer.cornerRadius = 30
            bottumSheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Rounds top corners only
            bottumSheet.backgroundColor = Colornames.auth_screen_color

            // Ensure the shadow appears correctly
            bottumSheet.layer.masksToBounds = false
            bottumSheet.layer.shadowColor = UIColor.black.cgColor
            bottumSheet.layer.shadowOffset = CGSize(width: 0, height: 5)
            bottumSheet.layer.shadowOpacity = 0.3
            bottumSheet.layer.shadowRadius = 6
            developerDescript.text = "Developer Mode is currently ON. Please turn it OFF to proceed.\n\nTo disable:\n1. Open Settings.\n2. Go to Privacy & Security.\n3. Tap Developer Mode.\n4. Turn it OFF and restart your device."
        }else{
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
        let Language = UserDefaults.standard.string(
            forKey: DefaultsKeys.Language ?? ""
        )
        let isRTL = (Language == "ar")  // Replace with your language-checking logic
            UIView.appearance().semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight

       
    }
    func isDeveloperModeEnabled() -> Bool {
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout.stride(ofValue: info)

        if sysctl(&mib, u_int(mib.count), &info, &size, nil, 0) != 0 {
            return false
        }
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    @IBAction func okAction(_ sender: UIButton) {
        exit(0)
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
        let parameters: [String: Any] = [
            mobileNumber.mobile_number: mobile_num ?? "" ,
            mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
            mobileNumber.secure_id: secureID,
            mobileNumber.password: password ?? ""
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
                                            vc.childDetail = localData.user_data?.user_details?.child_details?.first
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
                                        on: self)
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
                let vc = MobileNumberVc(nibName: nil, bundle: nil)
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
            title: version_Data?.toaster_title,
            message: version_Data?.new_version_updates,
            preferredStyle: .alert
        )
        
        if(
            version_Data?.update_available == true && version_Data?.force_update == true
        ){
            
//            forceUpdateAlert
//                .addAction(
//                    UIAlertAction(
//                        title: "Update",
//                        style: .default,
//                        handler: { [self] _ in
//                            self.callAppStore(AppStoreLink: version_Data?.play_store_link ?? "")}))
            showCustomPopup()
            
        }
        else if(
            version_Data?.update_available == true && version_Data?.force_update == false
        )
        {
            forceUpdateAlert.addAction(UIAlertAction(title: "Not Now", style: .default, handler: { _ in
            self.AppFlowChecking()
            }))
            
            showCustomPopup()
//            forceUpdateAlert
//                .addAction(
//                    UIAlertAction(
//                        title: "Update",
//                        style: .default,
//                        handler: { [self] _ in
//                            self.callAppStore(
//                                AppStoreLink: version_Data?.play_store_link ?? ""
//                            )
//                        })
//                )
        }
        
        present(forceUpdateAlert, animated: true, completion: nil)
        
        
    }

    func showCustomPopup() {
        // Create the overlay view
        let overlay = UIView(frame: self.view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Black transparent background
        overlay.tag = 1001 // Identify later for removal
        self.view.addSubview(overlay)
        self.overlayView = overlay
        
        // Create the popover content
        let popoverContentVC = UpdatePopupVC(nibName: nil, bundle: nil)
        popoverContentVC.view.backgroundColor = .white
        popoverContentVC.preferredContentSize = CGSize(width: view.frame.width - 60, height: view.frame.height - 300)
        popoverContentVC.reminderCalback = self
        popoverContentVC.modalPresentationStyle = .popover
        if let popoverPresentationController = popoverContentVC.popoverPresentationController {
            popoverPresentationController.delegate = self
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.permittedArrowDirections = []
            popoverPresentationController.passthroughViews = nil // Prevent dismissing on tap outside
        }

        self.present(popoverContentVC, animated: false)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // Keeps popover style on all devices
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }

}
    


  

