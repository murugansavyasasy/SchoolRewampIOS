//
//  SplashVC.swift
//  School Chimes
//
//  Created by Chandhru on 21/11/25.
//

import UIKit
import Darwin
import AVFoundation
import AudioToolbox

// MARK: - Confetti Particle
class ConfettiParticle: UIView {
    var startPosition: CGPoint = .zero
    var endPosition: CGPoint = .zero
    var animationDelay: Double = 0
    var animationDuration: Double = 2.0
    var fadeStartTime: Double = 0.8
    var rotation: CGFloat = 0
    
    init(color: UIColor, size: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        backgroundColor = color
        layer.cornerRadius = size / 2
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}

// MARK: - Star Particle View
class StarParticleView: UIView {
    private let starLayer = CAShapeLayer()
    
    init(size: CGFloat, color: UIColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        setupStar(size: size, color: color)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    private func setupStar(size: CGFloat, color: UIColor) {
        let path = createStarPath(size: size)
        starLayer.path = path.cgPath
        starLayer.fillColor = color.cgColor
        starLayer.shadowColor = color.cgColor
        starLayer.shadowRadius = 3
        starLayer.shadowOpacity = 0.8
        starLayer.shadowOffset = .zero
        layer.addSublayer(starLayer)
    }
    
    private func createStarPath(size: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: size / 2, y: size / 2)
        let points = 4
        let outerRadius = size / 2
        let innerRadius = size / 6
        
        for i in 0..<(points * 2) {
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let angle = CGFloat(i) * .pi / CGFloat(points) - .pi / 2
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 { path.move(to: point) }
            else { path.addLine(to: point) }
        }
        path.close()
        return path
    }
    
    func startBlinking() {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [0.2, 1.0, 0.2]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = Double.random(in: 1.0...2.5)
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: "blink")
        
        let scaleAnim = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnim.values = [0.8, 1.2, 0.8]
        scaleAnim.keyTimes = [0, 0.5, 1]
        scaleAnim.duration = animation.duration
        scaleAnim.repeatCount = .infinity
        layer.add(scaleAnim, forKey: "pulse")
    }
}

// MARK: - Ripple Ring View
class RippleRingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.cornerRadius = frame.width / 2
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}

// MARK: - SplashVC
@available(iOS 14.0, *)
class SplashVC: UIViewController, UIPopoverPresentationControllerDelegate, ViewAttachments {
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var empoweringLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var underlineWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var dot1: UIView!
    @IBOutlet weak var dot2: UIView!
    @IBOutlet weak var dot3: UIView!
    @IBOutlet weak var confettiContainerView: UIView!
    @IBOutlet weak var rippleContainerView: UIView!
    
    // MARK: - Properties
    private var confettiParticles: [ConfettiParticle] = []
    private var starParticles: [StarParticleView] = []
    private var rippleTimer: Timer?
    private var isAnimating = true
    private var dotAnimationTimers: [Timer] = []
    private var overlayView: UIView?
    private var popoverOverlayView: UIView?
    private var countryId: Int?
    private var versionData: VersionData?
    
    // Lottie colors
    private let confettiYellow = UIColor(red: 1.0, green: 0.878, blue: 0.416, alpha: 1.0)
    private let confettiGreen = UIColor(red: 0.204, green: 0.98, blue: 0.698, alpha: 1.0)
    private let confettiPink = UIColor(red: 1.0, green: 0.502, blue: 0.557, alpha: 1.0)
    
    private let frameRate: Double = 30.0
    private let lottieWidth: CGFloat = 400
    private let lottieHeight: CGFloat = 400
    private let sizeScaleDown: CGFloat = 0.6
    private let speedMultiplier: Double = 0.75
    private let extraRandomConfettiCount = 12
    
    // REDUCED: Confetti size multiplier (was 1.0, now 0.5 for 50% smaller)
    private let confettiSizeMultiplier: CGFloat = 0.5
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Bundle.main.appVersion ?? "1.0")
        setupUI()
        createStars()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSplashAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllAnimations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupDotCornerRadius()
    }
    
    // MARK: - Setup
    private func setupUI() {
        setColoredEmpoweringText()
        headerLabel.alpha = 0
        logoImageView.alpha = 0
        logoImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        empoweringLabel.alpha = 0
        underlineView.alpha = 0
        underlineView.layer.cornerRadius = underlineView.frame.height/2
        underlineWidthConstraint.constant = 0
        dot1.alpha = 0
        dot2.alpha = 0
        dot3.alpha = 0
    }
    
    private func setupDotCornerRadius() {
        [dot1, dot2, dot3].forEach { dot in
            dot?.layer.cornerRadius = (dot?.bounds.width ?? 0) / 2
        }
    }
    
    // MARK: - Stars Creation
    private func createStars() {
        let starColors: [UIColor] = [
            UIColor(hex: "#4FC3F7"),  // Light blue
            UIColor(hex: "#29B6F6"),  // Sky blue
            UIColor(hex: "#03A9F4"),  // Blue
            UIColor(hex: "#81D4FA")   // Pale blue
        ]
        
        let numberOfStars = 12
        let containerBounds = confettiContainerView.bounds
        
        for _ in 0..<numberOfStars {
            let size = CGFloat.random(in: 6...14)
            let color = starColors.randomElement() ?? starColors[0]
            let star = StarParticleView(size: size, color: color)
            
            let x = CGFloat.random(in: 20...(containerBounds.width - 20))
            let y = CGFloat.random(in: 60...(containerBounds.height * 0.7))
            star.center = CGPoint(x: x, y: y)
            star.alpha = 0
            
            // Use confettiContainerView for stars
            confettiContainerView.addSubview(star)
            starParticles.append(star)
        }
    }
    
    // Show stars after confetti ends
    private func showStars() {
        for (index, star) in starParticles.enumerated() {
            let delay = Double(index) * 0.08
            UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseIn) {
                star.alpha = 1.0
            } completion: { _ in
                star.startBlinking()
            }
        }
    }
    
    // MARK: - Coordinate Conversion
    private func convertLottiePoint(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        let containerWidth = confettiContainerView.bounds.width
        let containerHeight = confettiContainerView.bounds.height
        
        let scaleX = containerWidth / lottieWidth
        let scaleY = containerHeight / lottieHeight
        let scale = min(scaleX, scaleY)
        
        let offsetX = (containerWidth - lottieWidth * scale) / 2
        let offsetY = (containerHeight - lottieHeight * scale) / 2
        
        return CGPoint(
            x: x * scale + offsetX,
            y: y * scale + offsetY
        )
    }
    
    private func convertLottieSize(_ size: CGFloat) -> CGFloat {
        let containerWidth = confettiContainerView.bounds.width
        let scale = containerWidth / lottieWidth
        // REDUCED: Apply confetti size multiplier
        return size * scale * confettiSizeMultiplier
    }
    
    // MARK: - Animation Sequence
    private func startSplashAnimation() {
        createLottieConfetti()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.revealLogoWithRipples()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) { [weak self] in
            self?.animateHeaderLabel()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.6) { [weak self] in
            self?.animateEmpoweringSection()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            self?.animateDots()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) { [weak self] in
            self?.proceedWithAppFlow()
        }
    }
    
    // MARK: - Lottie-style Confetti Creation
    private func createLottieConfetti() {
        let configs: [(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, Int, Int, Int, Int, Int)] = [
            (-75.297, -25.656, 194.703, 212.344, 3.974 * 0.8, 0, 0, 95, 81, 96),
            (489.087, -39.256, 205.087, 204.744, 3.974 * 0.8, 1, 0, 89, 73, 88),
            (-110.913, 308.744, 205.087, 204.744, 3.974 * 0.8, 0, 17, 77, 62, 77),
            (393.087, 460.744, 205.087, 204.744, 12.466 * 0.8, 0, 0, 93, 69, 92),
            (221.087, 484.744, 205.087, 204.744, 9.822 * 0.8, 1, 14, 85, 70, 85),
            (-10.913, 488.744, 205.087, 204.744, 12.118 * 0.8, 0, 5, 80, 65, 80),
            (525.087, 372.744, 205.087, 204.744, 9.822 * 0.8, 0, 17, 95, 80, 95),
            (201.087, -87.256, 205.087, 204.744, 12.026 * 0.8, 1, 0, 60, 45, 60),
            (533.087, 144.744, 205.087, 204.744, 12.336 * 0.8, 0, 17, 92, 74, 93),
            (581.087, 292.744, 205.087, 204.744, 15.584 * 0.8, 0, 0, 90, 75, 90),
            (301.087, -91.256, 205.087, 204.744, 15.956 * 0.8, 2, 0, 90, 68, 91),
            (129.087, 524.744, 205.087, 204.744, 9.822 * 0.8, 2, 13, 88, 70, 89),
            (169.087, 444.744, 205.087, 204.744, 7.438 * 0.8, 2, 10, 89, 74, 89),
            (-54.913, 240.744, 205.087, 204.744, 7.438 * 0.8, 0, 0, 90, 67, 89),
            (97.087, -83.256, 205.087, 204.744, 15.448 * 0.8, 2, 0, 87, 66, 88),
            (437.087, 108.744, 205.087, 204.744, 10.768 * 0.8, 2, 16, 76, 62, 77),
            (441.087, 264.744, 205.087, 204.744, 10.768 * 0.8, 0, 11, 95, 80, 95),
            (309.087, 452.744, 205.087, 204.744, 15.052 * 0.8, 1, 0, 103, 88, 103),
            (397.087, -51.256, 205.087, 204.744, 15.052 * 0.8, 2, 4, 76, 61, 76),
            (-54.913, 164.744, 205.087, 204.744, 12.884 * 0.8, 0, 0, 82, 62, 83),
            (-26.913, 428.744, 205.087, 204.744, 9.822 * 0.8, 1, 42, 102, 86, 101),
            (329.087, -43.256, 205.087, 204.744, 11.292 * 0.8, 0, 3, 72, 56, 73),
            (-22.913, 100.744, 205.087, 204.744, 9.822 * 0.8, 0, 0, 84, 69, 84),
            (85.087, -27.256, 205.087, 204.744, 12.008 * 0.8, 0, 0, 51, 34, 49),
            (-82.913, 364.744, 205.087, 204.744, 22.976 * 0.8, 0, 14, 94, 79, 94),
            (433.087, 392.744, 205.087, 204.744, 9.822 * 0.8, 1, 0, 83, 67, 82),
            (457.087, 184.744, 205.087, 204.744, 9.82 * 0.8, 0, 0, 45, 29, 44),
            (73.087, 516.744, 205.087, 204.744, 14.378 * 0.8, 0, 0, 97, 82, 97),
            (177.087, -99.256, 205.087, 204.744, 22.264 * 0.8, 1, 0, 91, 75, 90),
            (465.087, 48.744, 205.087, 204.744, 9.822 * 0.8, 2, 11, 71, 57, 72),
        ]
        
        let colors = [confettiYellow, confettiGreen, confettiPink]
        
        for config in configs {
            let (startX, startY, endX, endY, size, colorIdx, startFrame, endFrame, fadeStart, fadeEnd) = config
            
            let convertedStart = convertLottiePoint(startX, startY)
            let convertedEnd = convertLottiePoint(endX, endY)
            let convertedSize = convertLottieSize(size)
            
            let particle = ConfettiParticle(color: colors[colorIdx], size: convertedSize)
            particle.startPosition = convertedStart
            particle.endPosition = convertedEnd
            particle.center = convertedStart
            particle.alpha = 1.0
            particle.rotation = CGFloat.random(in: 0...(2 * .pi))
            
            particle.animationDelay = Double(startFrame) / frameRate
            particle.animationDuration = Double(endFrame - startFrame) / frameRate
            particle.fadeStartTime = Double(fadeStart - startFrame) / Double(endFrame - startFrame)
            
            confettiContainerView.addSubview(particle)
            confettiParticles.append(particle)
            
            animateParticle(particle)
        }
    }
    
    private func animateParticle(_ particle: ConfettiParticle) {
        let delay = particle.animationDelay
        let duration = particle.animationDuration
        let fadeStartTime = particle.fadeStartTime
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: .curveEaseInOut,
            animations: {
                particle.center = particle.endPosition
                particle.transform = CGAffineTransform(rotationAngle: particle.rotation)
            }
        )
        
        let fadeDelay = delay + (duration * fadeStartTime)
        let fadeDuration = duration * (1.0 - fadeStartTime)
        
        UIView.animate(
            withDuration: fadeDuration,
            delay: fadeDelay,
            options: .curveEaseIn,
            animations: {
                particle.alpha = 0
            },
            completion: { _ in
                particle.removeFromSuperview()
            }
        )
    }
    
    // MARK: - Logo Reveal with Ripples
    private func revealLogoWithRipples() {
        confettiParticles.forEach { $0.removeFromSuperview() }
        confettiParticles.removeAll()
        
        // DARKEN: Animate gradient to darker blue
        gradientView.transitionToDarkerGradient(duration: 0.8)
        
        // Show stars after confetti ends
        showStars()
        
        logoImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 1.5,
            options: .curveEaseOut,
            animations: {
                self.logoImageView.alpha = 1.0
                self.logoImageView.transform = .identity
            }
        )
        
        startContinuousRippleAnimation()
    }
    
    // MARK: - Continuous Ripple Animation
    private func startContinuousRippleAnimation() {
        guard isAnimating else { return }
        
        createRippleWithNaturalDelay(at: 0.0)
        createRippleWithNaturalDelay(at: 1.0)
        createRippleWithNaturalDelay(at: 2.1)
        
        rippleTimer = Timer.scheduledTimer(withTimeInterval: 3.2, repeats: true) { [weak self] _ in
            guard let self = self, self.isAnimating else { return }
            let randomOffset = Double.random(in: 2.7...3.7)
            DispatchQueue.main.asyncAfter(deadline: .now() + randomOffset) {
                self.createRippleWithNaturalDelay(at: 0.0)
            }
        }
    }
    
    private func createRippleWithNaturalDelay(at baseDelay: TimeInterval) {
        guard isAnimating else { return }
        let delay = baseDelay + Double.random(in: 0.0...0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createSingleRipple()
        }
    }
    
    private func createSingleRipple() {
        guard isAnimating else { return }
        
        let centerX = view.bounds.midX
        let centerY = view.bounds.midY
        let initialSize: CGFloat = 80
        
        let ripple = RippleRingView(frame: CGRect(
            x: centerX - initialSize / 2,
            y: centerY - initialSize / 2,
            width: initialSize,
            height: initialSize
        ))
        
        ripple.alpha = 0.5
        ripple.layer.borderColor = UIColor.systemGray5.cgColor
        ripple.layer.borderWidth = CGFloat.random(in: 1...1.3)
        
        rippleContainerView.addSubview(ripple)

        let finalSize: CGFloat = CGFloat.random(in: 260...360)
        let duration = Double.random(in: 2.0...3.0)
        let delay = Double.random(in: 0.2...0.5)

        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            let scale = finalSize / initialSize
            ripple.transform = CGAffineTransform(scaleX: scale, y: scale)
            ripple.alpha = 0
        } completion: { _ in
            ripple.removeFromSuperview()
        }
    }
    
    // MARK: - Element Animations
    private func animateHeaderLabel() {
        headerLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                self.headerLabel.alpha = 1
                self.headerLabel.transform = .identity
            }
        )
    }
    
    private func animateEmpoweringSection() {
        empoweringLabel.transform = CGAffineTransform(translationX: 0, y: 30)
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                self.empoweringLabel.alpha = 1
                self.empoweringLabel.transform = .identity
            }
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.underlineView.alpha = 1
            self?.underlineWidthConstraint.constant = 230
            UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut) {
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    private func setColoredEmpoweringText() {
        let fullText = "Empowering 3000+ schools"
        let firstPart = "Empowering"
        let secondPart = "3000+ schools"
        
        let attributed = NSMutableAttributedString(string: fullText)
        
        attributed.addAttribute(.foregroundColor,
                                value: UIColor.darkGray,
                                range: (fullText as NSString).range(of: firstPart))
        
        attributed.addAttribute(.foregroundColor,
                                value: UIColor.systemPurple,
                                range: (fullText as NSString).range(of: secondPart))
        
        empoweringLabel.attributedText = attributed
    }
    
    private func animateDots() {
        let dots = [dot1, dot2, dot3]
        
        for (index, dot) in dots.enumerated() {
            let delay = Double(index) * 0.2
            Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
                UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse]) {
                    dot?.alpha = 1.0
                    dot?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }
            }
        }
    }
    
    // MARK: - Stop Animations
    private func stopAllAnimations() {
        isAnimating = false
        rippleTimer?.invalidate()
        rippleTimer = nil
        
        dotAnimationTimers.forEach { $0.invalidate() }
        dotAnimationTimers.removeAll()
        
        rippleContainerView.subviews.forEach { $0.removeFromSuperview() }
        confettiParticles.forEach { $0.removeFromSuperview() }
        confettiParticles.removeAll()
        
        starParticles.forEach {
            $0.layer.removeAllAnimations()
            $0.removeFromSuperview()
        }
        starParticles.removeAll()
    }
    
    // MARK: - Developer Mode Check
    private func checkDeveloperMode() {
        if DeveloperModeDetector.isDeveloperModeEnabled() {
            showDeveloperModeAlert()
        }
    }
    
    private func showDeveloperModeAlert() {
        let alert = UIAlertController(
            title: "Developer Mode Detected",
            message: "This app cannot run in Developer Mode for security reasons.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { exit(0) }
        })
        present(alert, animated: true)
    }

    // MARK: - Biometric & Version Check
    private func checkBiometricStatus() {
        if BiometricAuthentication.shared.isBiometricEnabledInApp() && BiometricAuthentication.shared.isBiometricAvailable() {
            BiometricAuthentication.shared.authenticateUser(from: self) { [weak self] success in
                DispatchQueue.main.async { self?.versionCheck() }
            }
        } else {
            versionCheck()
        }
    }
    
    private func versionCheck() {
        let params: [String: Any] = [
            COMMON_PARAMETER.device_type: API_PARAMS_HOTCODE.device_type,
            COMMON_PARAMETER.version_code: API_PARAMS_HOTCODE.Version_Code,
            COMMON_PARAMETER.country_id: countryId ?? 0
        ]
        
        APIService.shared.makeApi(
            url: ServiceUrl.version_check,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: ServiceUrl.token
        ) { [weak self] (result: Result<VersionCheckResponse, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status ?? false {
                        self.versionData = response.data?.first
                        if let countryDetails = self.versionData?.country_details {
                            
                            UserDefaultFileManager.saveCountryDetails(data: countryDetails)
                            ServiceUrl.baseurl = countryDetails.base_url ?? ""
                        }
                            if self.versionData?.update_available == true {
                                self.showUpdatePopup()
                            } else {
                                self.appFlowChecking()
                            }
                    } else {
                        self.appFlowChecking()
                    }
                case .failure(let error):
                    print("Version check error: \(error.localizedDescription)")
                    self.appFlowChecking()
                }
            }
        }
    }
    
    // MARK: - Validate User
    private func validateUser() {
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? ""
        let password = UserDefaultFileManager.getLoginCredentials()?.pwd ?? ""
        let secureID = SecureIDManager.getSecureID()
        
        let parameters: [String: Any] = [
            mobileNumber.mobile_number: mobile_num,
            mobileNumber.device_type: API_PARAMS_HOTCODE.device_type,
            mobileNumber.secure_id: secureID,
            mobileNumber.password: password
        ]
        
        APIService.shared.makeApi(
            url: ServiceUrl.validate_validate_user,
            parameters: parameters,
            type: ApitTypeSringFile.POST,
            token: ServiceUrl.token
        ) { [weak self] (result: Result<UserValidationResponseSuc, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.status == true, let userData = response.data?.first else {
//                        CustomAlert.showAlertWithOkAction(title: "Alert", message: response.message ?? "Something went wrong", on: self) {
                            let vc = LoginVc(nibName: nil, bundle: nil)
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
//                        }
                        return
                    }
                    if self.versionData?.is_rate_as ?? false {
                        self.presentPopover()
                    }else{
                        if userData.otp_sent == true{
                            let vc = OTPVc(nibName: nil, bundle: nil)
                            vc.validateMobileData = response.data ?? []
                            vc.mobile_number = mobile_num
                            vc.pageType = screenType.isLoginPage
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
                        }else{
                            UserDefaultFileManager.saveUserDetails(data: userData)
                            self.navigateBasedOnUserRole(data: userData)
                        }
                    }
                case .failure(let error):
                    print("Validation error: \(error.localizedDescription)")
                    self.navigateToLogin()
                }
            }
        }
    }
    
    // MARK: - Navigation Helpers
    private func navigateBasedOnUserRole(data: UserData) {
        let isStaff = data.user_details?.is_staff == true
        let isParent = data.user_details?.is_parent == true
        if isStaff && isParent {
            presentViewController(PriorityVC.self)
        } else if isStaff {
            handleStaffNavigation(data: data)
        } else if isParent {
            handleParentNavigation(data: data)
        }
    }
    
    private func handleStaffNavigation(data: UserData) {
        if (data.user_details?.staff_details?.count ?? 0) > 1 {
            presentViewController(PriorityVC.self)
        } else if let staffData = data.user_details?.staff_details?.first {
            UserDefaultFileManager.saveStaffDetails(data: staffData)
            presentTapBarVC(loginType: 1)
        }
    }
    
    private func handleParentNavigation(data: UserData) {
        if (data.user_details?.child_details?.count ?? 0) > 1 {
            presentViewController(PriorityVC.self)
        } else if let childData = data.user_details?.child_details?.first {
            UserDefaultFileManager.saveChildDetails(data: childData)
            presentTapBarVC(loginType: 2)
        }
    }
    
    private func presentViewController<T: UIViewController>(_ viewControllerType: T.Type) {
        let vc = T()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func presentTapBarVC(loginType: Int) {
        let vc = TapBarVC()
        vc.login_astype = loginType
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func navigateToLogin() {
        let isLoggedOut = UserDefaults.standard.bool(forKey: "Logout")
        let vc = isLoggedOut ? LoginVc() : MobileNumberVc()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    // MARK: - App Flow Decision
    private func appFlowChecking() {
        guard let credentials = UserDefaultFileManager.getLoginCredentials(),
              !credentials.mobile_number.isNilOrEmpty else {
            navigateToLogin()
            return
        }
        validateUser()
    }
    
    private func proceedWithAppFlow() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "Onboarding")
        if hasCompletedOnboarding {
            if let countryDetails = UserDefaultFileManager.getCountryDetails() {
                countryId = countryDetails.id
                checkBiometricStatus()
            } else {
                presentViewController(CountryListVC.self)
            }
        } else {
            let vc = OnboardingVC()
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
    }
    
    // MARK: - Update Popup
    private func showUpdatePopup() {
        guard let versionData = versionData else {
            appFlowChecking()
            return
        }
        let alert = UIAlertController(
            title: versionData.toaster_title,
            message: versionData.new_version_updates,
            preferredStyle: .alert
        )
        
        if versionData.force_update ?? false {
            alert.addAction(UIAlertAction(title: "Update", style: .default) { [weak self] _ in
                self?.openAppStore(link: versionData.app_store_link ?? "")
            })
        } else {
            alert.addAction(UIAlertAction(title: "Not Now", style: .default) { [weak self] _ in
                self?.appFlowChecking()
            })
            alert.addAction(UIAlertAction(title: "Update", style: .default) { [weak self] _ in
                self?.openAppStore(link: versionData.app_store_link ?? "")
            })
        }
        present(alert, animated: true)
    }
    
    private func openAppStore(link: String) {
        guard let url = URL(string: link), !link.isEmpty else { return }
        UIApplication.shared.open(url, options: [:])
    }
    
    // MARK: - Utility Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
}

// MARK: - String Extension
extension String {
    var isNilOrEmpty: Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

// MARK: - Bundle Extension
extension Bundle {
    var appVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

// MARK: - GradientView with Transition Support
class GradientView: UIView {
    
    private var gradientLayer: CAGradientLayer?
    private let lightColors: [CGColor] = [
        UIColor(hex: "#6EC9F5").cgColor,
        UIColor(hex: "#B3E5FC").cgColor,
        UIColor(hex: "#FFFFFF").cgColor
    ]
    private let darkColors: [CGColor] = [
        UIColor(hex: "#1E88E5").cgColor,
        UIColor(hex: "#64B5F6").cgColor,
        UIColor(hex: "#E3F2FD").cgColor
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = lightColors
        gradient.locations = [0.0, 0.45, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.cornerRadius = 10
        gradient.masksToBounds = true
        self.layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient
    }
    
    func transitionToDarkerGradient(duration: CFTimeInterval) {
        guard let gradientLayer = gradientLayer else { return }
        
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.fromValue = lightColors
        colorAnimation.toValue = darkColors
        colorAnimation.duration = duration
        colorAnimation.fillMode = .forwards
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(colorAnimation, forKey: "colorChange")
        gradientLayer.colors = darkColors
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = self.bounds
        gradientLayer?.cornerRadius = 10
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
}
@available(iOS 14.0, *)
extension SplashVC {
    func viewAttachment(sender: UIButton) {
        updatePopoverHeight()
    }
    
    func dismiss(_: Bool) {
        versionData?.is_rate_as = false
        removePopoverOverlay()
        validateUser()
    }
    private func presentPopover() {
        let popoverVC = RateUsViewController()
        popoverVC.modalPresentationStyle = .popover
        popoverVC.delegate = self
        popoverVC.loadViewIfNeeded()
        popoverVC.view.layoutIfNeeded()
        
        let scrollContentHeight = popoverVC.tableview.contentSize.height
        let paddingX: CGFloat = 20
        let width = view.frame.width - (paddingX * 2)
        let height = min(scrollContentHeight, view.frame.height)
        
        popoverVC.preferredContentSize = CGSize(width: width, height: height)
        
        let originX = (view.frame.width - width) / 2
        let originY = (view.frame.height - height) / 2
        let sourceRect = CGRect(x: originX, y: originY, width: width, height: height)
        
        addPopoverOverlay()
        
        if let popover = popoverVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.backgroundColor = .white
            popover.sourceRect = sourceRect
            popover.permittedArrowDirections = []
            popover.delegate = self
        }
        
        present(popoverVC, animated: true)
    }
    private func addPopoverOverlay() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        let overlay = UIView(frame: window.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.alpha = 0

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopoverOverlay))
        overlay.addGestureRecognizer(tapGesture)

        window.addSubview(overlay)
        popoverOverlayView = overlay

        UIView.animate(withDuration: 0.2) {
            overlay.alpha = 1
        }
    }
    func updatePopoverHeight() {
        guard let presentedVC = presentedViewController as? RateUsViewController else { return }

        presentedVC.loadViewIfNeeded()
        presentedVC.view.layoutIfNeeded()

        let scrollContentHeight = presentedVC.tableview.contentSize.height
        let paddingX: CGFloat = 20
        let width = view.frame.width - (paddingX * 2)
        let height = min(scrollContentHeight, view.frame.height * 0.85)

        presentedVC.preferredContentSize = CGSize(width: width, height: height)

        if let popover = presentedVC.popoverPresentationController {
            popover.sourceRect = CGRect(
                x: (view.frame.width - width) / 2,
                y: (view.frame.height - height) / 2,
                width: width,
                height: height
            )
        }
    }
    @objc private func dismissPopoverOverlay() {
        guard let popoverVC = presentedViewController else { return }
        popoverVC.dismiss(animated: true) {
            self.validateUser()
        }
        removePopoverOverlay()
    }


    private func removePopoverOverlay() {
        guard let overlay = popoverOverlayView else { return }

        UIView.animate(withDuration: 0.2, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            overlay.removeFromSuperview()
            self.popoverOverlayView = nil
        })
    }
}

@available(iOS 14.0, *)
extension SplashVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        removePopoverOverlay()
        self.validateUser()
    }
}
