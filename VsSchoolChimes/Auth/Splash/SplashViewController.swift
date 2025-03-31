//
//  SplashViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import UIKit
import Darwin
import LocalAuthentication


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
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure language and layout
        configureLanguageLayout()
        proceedWithAppFlow()
        //        checkDeveloperMode()
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        //            let vc = SchoolListVC(nibName: nil, bundle: nil)
        //            vc.modalPresentationStyle = .fullScreen
        //            self.present(vc, animated: true)
        //            self.showCustomPopup()
        //        }
    }
    func checkBiometricStatus() {
        if BiometricAuthentication.shared.isBiometricEnabledInApp(){
            if BiometricAuthentication.shared.isBiometricAvailable() {
                BiometricAuthentication.shared.authenticateUser(from: self) { [self] success in
                    if success {
                        Version_Check()
                    } else {
                        print("❌ Authentication Failed!")
                    }
                }
            }
        }else{
            Version_Check()
        }
    }
    
    
    func checkDeveloperMode() {
        if isDeveloperModeEnabled() {
            showDeveloperModePopup()
            //               proceedWithAppFlow()
        } else {
            proceedWithAppFlow()
        }
    }
    
    func isDeveloperModeEnabled() -> Bool {
        var devMode: Int32 = 0
        var size = MemoryLayout<Int32>.size
        let result = sysctlbyname("hw.optional.arm64", &devMode, &size, nil, 0)
        
        if result == 0 {
            return devMode == 1
        }
        return false
    }
    // Show Developer Mode Popup
    private func showDeveloperModePopup() {
        // Configure bottom sheet
        configureBottomSheet()
        
        // Set developer description
        developerDescript.text = """
          Developer Mode is currently ON. 
          Please turn it OFF to proceed.
          
          To disable:
          1. Open Settings
          2. Go to Privacy & Security
          3. Tap Developer Mode
          4. Turn it OFF and restart your device
          """
        
        // Additional UI configurations
        bottumSheet.isHidden = false
    }
    
    // Configure Bottom Sheet
    private func configureBottomSheet() {
        bottumSheet.layer.cornerRadius = 30
        bottumSheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottumSheet.backgroundColor = Colornames.auth_screen_color
        
        // Shadow configuration
        bottumSheet.layer.masksToBounds = false
        bottumSheet.layer.shadowColor = UIColor.black.cgColor
        bottumSheet.layer.shadowOffset = CGSize(width: 0, height: 5)
        bottumSheet.layer.shadowOpacity = 0.3
        bottumSheet.layer.shadowRadius = 6
    }
    
    // Configure Language and Layout
    private func configureLanguageLayout() {
        guard let language = UserDefaults.standard.string(forKey: DefaultsKeys.Language) else {
            return
        }
        
        let isRTL = (language == "ar")
        UIView.appearance().semanticContentAttribute = isRTL
        ? .forceRightToLeft
        : .forceLeftToRight
    }
    @IBAction func okAction(_ sender: UIButton) {
        UIApplication.shared.performSelector(onMainThread: #selector(NSXPCConnection.suspend), with: nil, waitUntilDone: false)
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
                            
                            guard let Data = response.data?.first else {
                                print("No data available")
                                return
                            }
                            
                            UserDefaultFileManager
                                .saveUserDetails(
                                    data: (Data))
                            
                            if(Data.is_password_updated == true){
                                
                                if(Data.otp_sent == true){
                                    
                                    otp_Vc(valdiateResponse: response.data ?? [])
                                }
                                else {
                                    
                                    
                                    UserDefaultFileManager
                                        .saveLoginCredentials(
                                            mobile_number:mobile_num ?? "",
                                            pwd:password ?? ""
                                        )
                                    
                                    
                                    if(Data.user_details?.is_staff == true) &&  (
                                        Data.user_details?.is_parent == true
                                    ){
                                        let vc = PriorityVC(
                                            nibName: nil,
                                            bundle: nil
                                        )
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                        
                                    }
                                    else if(Data.user_details?.is_staff == true){
                                        let vc = TapBarVC(
                                            nibName: nil,
                                            bundle: nil
                                        )
                                        vc.login_astype = 1
                                        vc.modalPresentationStyle = .fullScreen
                                        present(vc, animated: true)
                                        
                                    }
                                    else if(Data.user_details?.is_parent == true){
                                        
                                        if(
                                            Data.user_details?.child_details?.count ?? 0 > 1
                                        ){
                                            let vc = PriorityVC(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
                                        else{
                                            
                                            let vc = TapBarVC(
                                                nibName: nil,
                                                bundle: nil
                                            )
                                            vc.login_astype = 2
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                        }
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
        
        let mobile_num = /*"707070707070"*/ UserDefaultFileManager.getLoginCredentials()?.mobile_number
        let password = /*"1234"*/ UserDefaultFileManager.getLoginCredentials()?.pwd
        if (mobile_num != nil) && (password != nil){
            validate_user()
        }
        else{
            let is_login :Bool?
            let userDefaults = UserDefaults.standard
            is_login = userDefaults.bool(forKey: "Logout")
           
            if is_login ==  true{
                let vc = LoginVc(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }else{
                let vc = MobileNumberVc(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
            
        }
    }
    func proceedWithAppFlow() {
        if let countryDetails = UserDefaultFileManager.getCountryDetails() {
            countryId = countryDetails.id
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
            if self.countryId != nil {
                checkBiometricStatus()
            } else {
                let vc = CountryVc(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
               validate_user()
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
            title: version_Data?.toaster_title,
            message: version_Data?.new_version_updates,
            preferredStyle: .alert
        )
        
        if(
            version_Data?.update_available == true && version_Data?.force_update == true
        ){
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

class DeveloperModeDetector {
    /// Checks if Developer Mode is currently enabled on the device
    static func isDeveloperModeEnabled() -> Bool {
        // Method 1: Check if debugger is attached
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.size
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        
        guard sysctl(&mib, u_int(mib.count), &info, &size, nil, 0) == 0 else {
            return false
        }
        
        let isDebuggerAttached = (info.kp_proc.p_flag & P_TRACED) != 0
        
        // Method 2: Check for common developer-related settings
        let defaults = UserDefaults.standard
        let developerModeSettings = [
            "WebKitDeveloperExtras",
            "DebugSwiftUIView",
            "UIViewLayoutFeedbackLoopDebuggingThreshold"
        ]
        
        let hasDeveloperSettings = developerModeSettings.contains { setting in
            return defaults.object(forKey: setting) != nil
        }
        
        return isDebuggerAttached || hasDeveloperSettings
    }
    
    /// Continuously monitors developer mode status
    static func startDeveloperModeMonitoring(handler: @escaping (Bool) -> Void) {
        // Create a timer to check developer mode status periodically
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            let isEnabled = isDeveloperModeEnabled()
            handler(isEnabled)
        }
    }
    
    /// Example usage demonstrating how to use the detection methods
    static func demonstrateUsage() {
        // One-time check
        if isDeveloperModeEnabled() {
            print("Developer mode is currently ON")
        } else {
            print("Developer mode is currently OFF")
        }
        
        // Continuous monitoring
        startDeveloperModeMonitoring { status in
            if status {
                print("Developer mode detected!")
                // Optionally take action like logging or alerting
            }
        }
    } 
}
