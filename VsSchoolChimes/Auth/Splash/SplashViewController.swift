//
//  SplashViewController.swift
//  VsSchoolChimes
//
//  Created by chandhru on 19/09/25.
import UIKit
import Darwin
import LocalAuthentication
import AVFoundation
import AudioToolbox
import ImageIO
import Foundation

// MARK: - DeveloperModeDetector
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
            defaults.object(forKey: setting) != nil
        }
        
        return isDebuggerAttached || hasDeveloperSettings
    }
    
    /// Continuously monitors developer mode status
    static func startDeveloperModeMonitoring(handler: @escaping (Bool) -> Void) {
        // Create a timer to check developer mode status periodically
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            let isEnabled = isDeveloperModeEnabled()
            handler(isEnabled)
        }
    }
}

// MARK: - SplashViewController
@available(iOS 14.0, *)
class SplashViewController: UIViewController, UIPopoverPresentationControllerDelegate, ReminderCalback {
    
    // MARK: - IBOutlets
    @IBOutlet weak var versionLbl: UILabel!
    @IBOutlet weak var bellImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var loadingDotsContainer: UIStackView!
    @IBOutlet weak var loadingTextLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var bottumSheet: UIView!
    @IBOutlet weak var developerDescript: UILabel!
    
    // MARK: - Properties
    private var gradientLayer: CAGradientLayer?
    private var bellAnimation: CABasicAnimation?
    private var loadingDots: [UIView] = []
    var overlayView: UIView?
    private var timer: Timer?
    
    private var countryId: Int?
    private var versionData: VersionData?
    private let alertModal = CustomAlert()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGradientBackground()
        setupBellIcon()
        setupLoadingDots()
        
        // Round circle view safely
        circleView.layer.cornerRadius = circleView.frame.width / 2
        circleView.clipsToBounds = true
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            versionLbl.text = "Version \(version)"
        }
        configureLanguageLayout()
        proceedWithAppFlow()
        
        // Load GIF
        if let animatedImage = loadGif(named: "Splach") {
            imgview.image = animatedImage
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.vibrateDevice()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSplashAnimations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = gradientView.bounds
        addGalaxyAnimation(around: circleView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bellImageView.layer.removeAllAnimations()
        loadingDots.forEach { $0.layer.removeAllAnimations() }
        bellAnimation = nil
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        [appNameLabel, taglineLabel, loadingDotsContainer, loadingTextLabel, bellImageView].forEach {
            $0?.alpha = 0
        }
    }
    
    private func setupGradientBackground() {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.31, green: 0.58, blue: 0.98, alpha: 1.0).cgColor , // #667eea
            UIColor(red: 0.24, green: 0.51, blue: 0.93, alpha: 1.0).cgColor,  // #764ba2
            UIColor(red: 0.18, green: 0.42, blue: 0.85, alpha: 1.0).cgColor
        ]

        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.frame = gradientView.bounds
        gradientView.layer.insertSublayer(layer, at: 0)
        gradientLayer = layer
    }
    
    private func setupBellIcon() {
        bellImageView.image = UIImage(named: "school_chimes 2")
        bellImageView.tintColor = .white
        bellImageView.contentMode = .scaleAspectFit
        bellImageView.layer.shadowColor = UIColor.black.cgColor
        bellImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        bellImageView.layer.shadowOpacity = 0.3
        bellImageView.layer.shadowRadius = 8
    }
    
    private func setupLoadingDots() {
        loadingDots = loadingDotsContainer.arrangedSubviews
        loadingDots.forEach {
            $0.layer.cornerRadius = min($0.bounds.width, $0.bounds.height) / 2
            $0.alpha = 0.5
            $0.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    // MARK: - Animations
    private func startSplashAnimations() {
        animateBellEntrance()
        animateTextElements()
        animateLoadingElements()
//        startBellRingingAnimation()
        startLogoRingAnimation()
    }
    
    private func animateBellEntrance() {
        bellImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).rotated(by: -0.2)
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut) { [weak self] in
            self?.bellImageView.alpha = 1
            self?.bellImageView.transform = .identity
        }
    }
    
    private func animateTextElements() {
        UIView.animate(withDuration: 1.5,
                       delay: 0.5,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
            self?.appNameLabel.alpha = 1
            self?.appNameLabel.transform = CGAffineTransform(translationX: 0, y: -30).scaledBy(x: 1.05, y: 1.05)
        }) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.appNameLabel.transform = .identity
            }
        }
        
        UIView.animate(withDuration: 1.5, delay: 1.0, options: .curveEaseOut) { [weak self] in
            self?.taglineLabel.alpha = 1
        }
    }
    
    private func animateLoadingElements() {
        UIView.animate(withDuration: 1.5, delay: 1.5, options: .curveEaseOut, animations: { [weak self] in
            self?.loadingDotsContainer.alpha = 1
            self?.loadingTextLabel.alpha = 1
        }) { [weak self] _ in
            self?.startLoadingDotsAnimation()
        }
    }
    
//    private func startBellRingingAnimation() {
//        let anim = CABasicAnimation(keyPath: "transform.rotation")
//        anim.fromValue = -0.1
//        anim.toValue = 0.1
//        anim.duration = 0.5
//        anim.autoreverses = true
//        anim.repeatCount = .infinity
//        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        bellAnimation = anim
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//            self?.bellImageView.layer.add(anim, forKey: "bellRing")
//        }
//    }
    private func startLogoRingAnimation() {
        // Ensure shadow is configured
        bellImageView.layer.shadowColor = UIColor.systemYellow.cgColor
        bellImageView.layer.shadowOpacity = 0.8
        bellImageView.layer.shadowOffset = .zero
        bellImageView.layer.shadowRadius = 10
        bellImageView.clipsToBounds = false  // Important for glow visibility

        // Scale animation
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue = 1.2
        scaleAnim.duration = 0.8
        scaleAnim.autoreverses = true
        scaleAnim.repeatCount = .infinity
        scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Glow pulse (shadow radius animation)
        let glowAnim = CABasicAnimation(keyPath: "shadowRadius")
        glowAnim.fromValue = 10
        glowAnim.toValue = 25
        glowAnim.duration = 0.8
        glowAnim.autoreverses = true
        glowAnim.repeatCount = .infinity
        glowAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Add animations
        bellImageView.layer.add(scaleAnim, forKey: "scalePulse")
        bellImageView.layer.add(glowAnim, forKey: "glowPulse")
    }


    private func addGalaxyAnimation(around view: UIView) {
        let pulseCount = 3   // number of rings
        let animationDuration: CFTimeInterval = 3.0
        
        for i in 0..<pulseCount {
            let circleLayer = CAShapeLayer()
            let radius: CGFloat = view.bounds.width / 2 + 20
            
            // Circle path
            let circlePath = UIBezierPath(
                ovalIn: CGRect(
                    x: -radius,
                    y: -radius,
                    width: radius * 2,
                    height: radius * 2
                )
            )
            circleLayer.path = circlePath.cgPath
            circleLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = UIColor(red: 0.31, green: 0.58, blue: 0.98, alpha: 1.0).cgColor // bright blue
            circleLayer.lineWidth = 2.0
            circleLayer.opacity = 0.0
            
            view.layer.insertSublayer(circleLayer, below: view.layer.sublayers?.first)
            
            // Scale animation
            let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
            scaleAnim.fromValue = 0.6
            scaleAnim.toValue = 1.8
            scaleAnim.duration = animationDuration
            scaleAnim.repeatCount = .infinity
            
            // Fade animation
            let fadeAnim = CABasicAnimation(keyPath: "opacity")
            fadeAnim.fromValue = 0.7
            fadeAnim.toValue = 0.0
            fadeAnim.duration = animationDuration
            fadeAnim.repeatCount = .infinity
            
            // Group animations
            let group = CAAnimationGroup()
            group.animations = [scaleAnim, fadeAnim]
            group.duration = animationDuration
            group.repeatCount = .infinity
            group.beginTime = CACurrentMediaTime() + Double(i) * (animationDuration / Double(pulseCount))
            
            circleLayer.add(group, forKey: "galaxyPulse")
        }
    }

    private func startLoadingDotsAnimation() {
        for (index, dot) in loadingDots.enumerated() {
            let delay = Double(index) * 0.2
            Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse]) {
                    dot.alpha = 1.0
                    dot.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }
            }
        }
    }
    
    // MARK: - Business Logic
    func backToCall() {
        AppFlowChecking()
    }
    
    func vibrateDevice() {
        AudioServicesPlaySystemSound(1004)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    private func configureLanguageLayout() {
        guard let language = UserDefaults.standard.string(forKey: DefaultsKeys.Language) else { return }
        UIView.appearance().semanticContentAttribute = language == "ar" ? .forceRightToLeft : .forceLeftToRight
    }
    
    @IBAction func okAction(_ sender: UIButton) {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }
    
    // MARK: - Developer Mode
    func checkDeveloperMode() {
//        if DeveloperModeDetector.isDeveloperModeEnabled() {
//            showDeveloperModePopup()
//        } else {
            proceedWithAppFlow()
//        }
    }
    
    private func showDeveloperModePopup() {
        let alert = UIAlertController(title: "Developer Mode Detected",
                                      message: "This app cannot run in Developer Mode for security reasons.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.okAction(self!.okBtn)
        })
        present(alert, animated: true)
    }
    
    // MARK: - Biometric & Version Check
    func checkBiometricStatus() {
        if BiometricAuthentication.shared.isBiometricEnabledInApp() && BiometricAuthentication.shared.isBiometricAvailable() {
            BiometricAuthentication.shared.authenticateUser(from: self) { [weak self] success in
                guard let self else { return }
                if success {
                    self.versionCheck()
                } else {
                    print("❌ Authentication Failed!")
                    self.versionCheck()
                }
            }
        } else {
            versionCheck()
        }
    }
    
    func versionCheck() {
        let params: [String: Any] = [
            COMMON_PARAMETER.device_type: API_PARAMS_HOTCODE.device_type,
            COMMON_PARAMETER.version_code: API_PARAMS_HOTCODE.Version_Code,
            COMMON_PARAMETER.country_id: countryId ?? 0
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.version_check,
                                  parameters: params,
                                  type: ApitTypeSringFile.POST,
                                  token: ServiceUrl.token) { [weak self] (result: Result<VersionCheckResponse, Error>) in
            guard let self else { return }
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        self.versionData = response.data?.first
                        if let countryDetails = self.versionData?.country_details {
                            UserDefaultFileManager.saveCountryDetails(data: countryDetails)
                            ServiceUrl.baseurl = countryDetails.base_url ?? ""
                            ServiceUrl.report_url = countryDetails.reporting_url ?? ""
                        }
                        
                        if self.versionData?.update_available == true {
                            self.showUpdatePopup()
                        } else {
                            self.AppFlowChecking()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.AppFlowChecking()
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Version_Check error: \(error.localizedDescription)")
                    self.AppFlowChecking()
                }
            }
        }
    }
    
    // MARK: - Validate User Flow
    func validateUser() {
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? ""
        let password = UserDefaultFileManager.getLoginCredentials()?.pwd ?? ""
        let secureID = SecureIDManager.getSecureID()
        
        let parameters: [String: Any] = [
            mobileNumber.mobile_number: mobile_num,
            mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
            mobileNumber.secure_id: secureID,
            mobileNumber.password: password
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.validate_validate_user, parameters: parameters, type: ApitTypeSringFile.POST, token: ServiceUrl.token) { [weak self] (result: Result<UserValidationResponseSuc, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    guard response.status == true, let Data = response.data?.first else {
                        // show alert and go to login
                        CustomAlert.showAlertWithOkAction(title: "Alert", message: response.message ?? "Something went wrong", on: self) {
                            let vc = LoginVc(nibName: nil, bundle: nil)
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
                        }
                        return
                    }
                    
                    // Save user details
                    UserDefaultFileManager.saveUserDetails(data: Data)
                    
                    if Data.is_password_updated == true {
                        if Data.otp_sent == true {
                            self.otp_Vc(valdiateResponse: response.data ?? [])
                        } else {
                            // Save credentials
                            UserDefaultFileManager.saveLoginCredentials(mobile_number: mobile_num, pwd: password)
                            
                            // Decide VC based on roles
                            if (Data.user_details?.is_staff == true) && (Data.user_details?.is_parent == true) {
                                let vc = PriorityVC(nibName: nil, bundle: nil)
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true)
                            
                            } else if Data.user_details?.is_staff == true {
                                // staff flow
                                if Data.user_details?.staff_role == PriorityType.is_staff {
                                    if (Data.user_details?.staff_details?.count ?? 0) > 1 {
                                        let vc = PriorityVC(nibName: nil, bundle: nil)
                                        vc.modalPresentationStyle = .fullScreen
                                        self.present(vc, animated: true)
                                    } else {
                                        if let staffData = Data.user_details?.staff_details?.first {
                                            UserDefaultFileManager.saveStaffDetails(data: staffData)
                                        }
                                        let vc = TapBarVC(nibName: nil, bundle: nil)
                                        vc.login_astype = 1
                                        vc.modalPresentationStyle = .fullScreen
                                        self.present(vc, animated: true)
                                    }
                                } else {
                                    if let staffData = Data.user_details?.staff_details?.first {
                                        UserDefaultFileManager.saveStaffDetails(data: staffData)
                                    }
                                    let vc = TapBarVC(nibName: nil, bundle: nil)
                                    vc.login_astype = 1
                                    vc.modalPresentationStyle = .fullScreen
                                    self.present(vc, animated: true)
                                }
                                
                            } else if Data.user_details?.is_parent == true {
                                // parent flow
                                if (Data.user_details?.child_details?.count ?? 0) > 1 {
                                    let vc = PriorityVC(nibName: nil, bundle: nil)
                                    vc.modalPresentationStyle = .fullScreen
                                    self.present(vc, animated: true)
                                } else {
                                    if let child = Data.user_details?.child_details?.first {
                                        UserDefaultFileManager.saveChildDetails(data: child)
                                    }
                                    let vc = TapBarVC(nibName: nil, bundle: nil)
                                    vc.login_astype = 2
                                    vc.modalPresentationStyle = .fullScreen
                                    self.present(vc, animated: true)
                                }
                            }
                            
                        }
                    } else {
                        // password not updated
                        self.alertModal.showAlert(title: "", message: response.message ?? "", on: self)
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    if #available(iOS 15.0, *) {
                        self.hideLottieProgressLoader()
                    }
                    print("validate_user error:", error.localizedDescription)
                    // Optionally show alert
                }
            }
        }
    }
    
    private func navigateBasedOnUserRole(data: UserData) {
        let isStaff = data.user_details?.is_staff == true
        let isParent = data.user_details?.is_parent == true
        
        if isStaff && isParent {
            presentPriorityVC()
        } else if isStaff {
            if data.user_details?.staff_details?.count ?? 0 > 1 {
                presentPriorityVC()
            } else if let staffData = data.user_details?.staff_details?.first {
                UserDefaultFileManager.saveStaffDetails(data: staffData)
                presentTapBarVC(loginType: 1)
            }
        } else if isParent {
            if data.user_details?.child_details?.count ?? 0 > 1 {
                presentPriorityVC()
            } else if let childData = data.user_details?.child_details?.first {
                UserDefaultFileManager.saveChildDetails(data: childData)
                presentTapBarVC(loginType: 2)
            }
        }
    }
    
    private func presentPriorityVC() {
        let vc = PriorityVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func presentTapBarVC(loginType: Int) {
        let vc = TapBarVC()
        vc.login_astype = loginType
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func otp_Vc(valdiateResponse: [UserData]) {
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number
        let vc = OTPVc(nibName: nil, bundle: nil)
        vc.validateMobileData = valdiateResponse
        vc.pageType = screenType.isSplash
        vc.mobile_number = mobile_num
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    // MARK: - App Flow Decision
    func AppFlowChecking() {
        guard let credentials = UserDefaultFileManager.getLoginCredentials(),
              credentials.mobile_number != nil,
              credentials.pwd != nil else {
            let isLoggedOut = UserDefaults.standard.bool(forKey: "Logout")
            let vc = isLoggedOut ? LoginVc() : MobileNumberVc()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            return
        }
        validateUser()
    }
    
    func proceedWithAppFlow() {
        if let countryDetails = UserDefaultFileManager.getCountryDetails() {
            countryId = countryDetails.id
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) { [weak self] in
            guard let self else { return }
            if self.countryId != nil {
                self.checkBiometricStatus()
            } else {
                let vc = CountryListVC()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
    }
    
    // MARK: - App Store Link
    func callAppStore(appStoreLink: String) {
        guard let url = URL(string: appStoreLink), !url.absoluteString.isEmpty else { return }
        UIApplication.shared.open(url, options: [:])
    }
    
    // MARK: - Update Popup
    func showUpdatePopup() {
        guard let versionData = versionData else {
            AppFlowChecking()
            return
        }
        
        let alert = UIAlertController(title: versionData.toaster_title,
                                      message: versionData.new_version_updates,
                                      preferredStyle: .alert)
        
        if versionData.update_available ?? false {
            if versionData.force_update ?? false {
                alert.addAction(UIAlertAction(title: "Update", style: .default) { [weak self] _ in
                    self?.callAppStore(appStoreLink: versionData.app_store_link ?? "")
                })
            } else {
                alert.addAction(UIAlertAction(title: "Not Now", style: .default) { [weak self] _ in
                    self?.AppFlowChecking()
                })
                alert.addAction(UIAlertAction(title: "Update", style: .default) { [weak self] _ in
                    self?.callAppStore(appStoreLink: versionData.app_store_link ?? "")
                })
            }
            present(alert, animated: true)
        } else {
            AppFlowChecking()
        }
    }
    
    func showCustomPopup() {
        overlayView = UIView(frame: view.bounds)
        overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView?.tag = 1001
        view.addSubview(overlayView!)
        
        let popoverContentVC = UpdatePopupVC()
        popoverContentVC.view.backgroundColor = .white
        popoverContentVC.preferredContentSize = CGSize(width: view.frame.width - 60, height: view.frame.height - 300)
        popoverContentVC.reminderCalback = self
        popoverContentVC.modalPresentationStyle = .popover
        
        if let popover = popoverContentVC.popoverPresentationController {
            popover.delegate = self
            popover.sourceView = view
            popover.permittedArrowDirections = []
            popover.passthroughViews = nil
        }
        
        present(popoverContentVC, animated: false)
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        false
    }
    
    // MARK: - GIF Loader
    func loadGif(named name: String) -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        var images: [UIImage] = []
        var duration: Double = 0.0
        let count = CGImageSourceGetCount(source)
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
                if let props = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [CFString: Any],
                   let gifInfo = props[kCGImagePropertyGIFDictionary] as? [CFString: Any],
                   let frameDuration = gifInfo[kCGImagePropertyGIFUnclampedDelayTime] as? Double ?? gifInfo[kCGImagePropertyGIFDelayTime] as? Double {
                    duration += frameDuration
                } else {
                    duration += 0.1
                }
            }
        }
        
        return duration > 0 ? UIImage.animatedImage(with: images, duration: duration) : nil
    }
}
