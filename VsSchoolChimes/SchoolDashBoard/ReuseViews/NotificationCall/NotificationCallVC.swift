//
//  NotificationCallVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/10/25.
//

import UIKit
import AVFAudio
import AVFoundation
import MediaPlayer

struct NotificationData {
    var ei1 = ""
    var ei2 = ""
    var ei3 = ""
    var ei4 = "iPhone"
    var ei5 = ""
    var receiver_id = ""
    var circular_id = ""
    var retrycount = ""
    var diallist_id = ""
    var url = ""
}

class NotificationCallVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var cutCallBtn: UIButton!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var answerCallImg: UIButton!
    @IBOutlet weak var declineCallImg: UIButton!
    @IBOutlet weak var slideLabel: UILabel!
    @IBOutlet weak var rightIndicationStack: UIStackView!
    @IBOutlet weak var leftIndicationStack: UIStackView!
    @IBOutlet weak var draggableButton: UIButton!
    
    @IBOutlet var rightArrowBtns: [UIButton]!
    @IBOutlet var leftArrowBtns: [UIButton]!
    
    // MARK: - Properties
    private var gradientLayer: CAGradientLayer?
    private var originalCenter: CGPoint = .zero
    private var isDragging = false
    
    private var audioTimer: Timer?
    private var ringtoneTimeoutTimer: Timer?
    private var vibrationTimer: Timer?
    var startTime : String = ""
    var call_status: String = "NO"
    var voiceUrl: String = ""
    var ringTone: String = "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/communication/7043/2025-10-23/Communication_20251023_161939.wav"
    var welcomeFileUrl : String = ""
    var noti = NotificationData()
    private var audioPlayer: AVAudioPlayer?
    private var ringtonePlayer: AVAudioPlayer?
    private var volumeObserver: NSKeyValueObservation?
    private var totalQueueDuration: Double = 0
    var userInfo = [AnyHashable : Any]()
    var duration = "0"
    // Cache for downloaded audio to reduce I/O
    private static var audioCache: NSCache<NSString, NSData> = {
        let cache = NSCache<NSString, NSData>()
        cache.countLimit = 10 // Store up to 10 audio files
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB max
        return cache
    }()
    
    private enum CallState {
        case ringing
        case connecting
        case active
        case ended
    }
    
    private var callState: CallState = .ringing {
        didSet {
            handleCallStateChange()
        }
    }
    
    private var audioQueuePlayer: AVQueuePlayer?
    private var queueItems: [AVPlayerItem] = []
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopLocalRingtone()
        setupModernUI()
        setupCallerInfo()
        setupSlideToAnswerAnimation()
        addSwipeGesture()
        
        // Initially hide call controls
        cutCallBtn.isHidden = true
        speakerBtn.isHidden = true
        cutCallBtn.layer.cornerRadius = cutCallBtn.frame.width / 2
        cutCallBtn.alpha = 0
        speakerBtn.alpha = 0
        
        configureAudioSessionForRingtone()
        
//        if let url = URL(string: ringTone) {
            playLocalRingtone(named: "schoolchimes_tone", ext: "wav")
//        }
        
        setupVolumeObserver()
        setupPowerButtonObserver()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queueDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        
        if let ei1 = userInfo["ei1"] as? String {
            noti.ei1 = ei1
        }
        if let ei2 = userInfo["ei2"] as? String {
            noti.ei2 = ei2
        }
        if let ei3 = userInfo["ei3"] as? String {
            noti.ei3 = ei3
        }
        if let ei4 = userInfo["ei4"] as? String {
            noti.ei4 = ei4
        }
        if let ei5 = userInfo["ei5"] as? String {
            noti.ei5 = ei5
            noti.diallist_id = ei5
        }
        if let retrycount = userInfo["retry_count"] as? String {
            noti.retrycount = retrycount
        }
        if let circularId = userInfo["circular_id"] as? String {
            noti.circular_id = circularId
        }
        if let receiverId = userInfo["receiver_id"] as? String {
            noti.receiver_id = receiverId
        }
        if let receiverId = userInfo["url"] as? String {
            noti.url = receiverId
        }
    }
    
    @objc private func queueDidFinish() {
        guard audioQueuePlayer?.items().isEmpty == true else { return }
        
        DispatchQueue.main.async {
            self.durationLbl.text = "Call ended"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.dismissCallScreen()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = slideLabel.bounds
        originalCenter = draggableButton.center
        
        if draggableButton.layer.animation(forKey: "buttonBounce") == nil {
            addPulsatingRingAnimation()
            startChevronAnimation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanup()
    }
    
    // MARK: - Volume & Power Button Observers
    private func setupVolumeObserver() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error)")
        }
        
        // Observe system volume changes
        volumeObserver = AVAudioSession.sharedInstance().observe(\.outputVolume, options: [.new]) { [weak self] _, change in
            guard let self = self else { return }
            
            // Only mute ringtone when volume button is pressed during ringing state
            if self.callState == .ringing, self.ringtonePlayer?.isPlaying == true {
                DispatchQueue.main.async {
                    self.muteRingtone()
                }
            }
        }
    }
    
    private func setupPowerButtonObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func appWillResignActive() {
        // When user presses power button
        switch callState {
        case .ringing:
            print("🔴 Power button pressed - declining call")
            declineCallAction()
        case .active:
            print("🔴 Power button pressed - ending call")
            cutCallAction()
        default:
            break
        }
    }
    
    private func muteRingtone() {
        guard ringtonePlayer?.isPlaying == true else { return }
        stopVibration()
        ringtonePlayer?.stop()
        ringtonePlayer = nil
        ringtoneTimeoutTimer?.invalidate()
        ringtoneTimeoutTimer = nil
    }
    
    // MARK: - Audio Session Configuration
    private func configureAudioSessionForRingtone() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
        }
    }
    
    private func configureAudioSessionForCall() {
        do {
            // Switch to playAndRecord with voiceChat mode for earpiece routing
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            // Explicitly route to earpiece (receiver)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
        } catch {
            print("⚠️ Failed to configure audio session for call: \(error.localizedDescription)")
        }
    }
    private func isPhoneInSilentMode() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.ambient, mode: .default)
            try session.setActive(true)
            return session.outputVolume == 0
        } catch {
            print("Failed to check silent mode: \(error)")
            return false
        }
    }
//    private func playRingtone(from url: URL) {
//        let cacheKey = url.absoluteString as NSString
//        // Check cache first
//        if let cachedData = Self.audioCache.object(forKey: cacheKey) {
//            playRingtoneData(cachedData as Data)
//            return
//        }
//        // Download if not cached
//        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
//            guard let self = self else { return }
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.playSystemDefaultTone()
//                }
//                return
//            }
//            guard let data = data else {
//                DispatchQueue.main.async {
//                    self.playSystemDefaultTone()
//                }
//                return
//            }
//            // Cache the downloaded data
//            Self.audioCache.setObject(data as NSData, forKey: cacheKey, cost: data.count)
//            
//            DispatchQueue.main.async {
//                self.playRingtoneData(data)
//            }
//        }
//        task.resume()
//    }
//
    private func playLocalRingtone(named name: String, ext: String) {
        guard let path = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("❌ schoolchimes_tone.wav not found")
            playSystemDefaultTone()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1   // infinite loop
            audioPlayer?.play()
        } catch {
            print("❌ Local audio play failed:", error)
            playSystemDefaultTone()
        }
    }

    private func stopLocalRingtone() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    private func playRingtoneData(_ data: Data) {
        guard !isPhoneInSilentMode() else {
            return
        }
        
        do {
            // Use .playback so it can play even in silent if you want
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .voiceChat)
            try AVAudioSession.sharedInstance().setActive(true)
            
            self.ringtonePlayer = try AVAudioPlayer(data: data)
            self.ringtonePlayer?.numberOfLoops = -1
            self.ringtonePlayer?.prepareToPlay()
            self.ringtonePlayer?.play()
            
            self.startVibration()
            self.ringtoneTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { [weak self] _ in
                self?.handleRingtoneTimeout()
            }
        } catch {
            self.playSystemDefaultTone()
        }
    }
    
    
    private func handleRingtoneTimeout() {
        guard callState == .ringing else { return }
        stopVibration()
        ringtonePlayer?.stop()
        ringtonePlayer = nil
        dismissCallScreen()
    }
    
    private func playSystemDefaultTone() {
        AudioServicesPlaySystemSound(1005)
        startVibration()
        ringtoneTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.handleRingtoneTimeout()
        }
    }
    
    private func startVibration() {
        stopVibration()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    private func stopVibration() {
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
    
    // MARK: - Call State Management
    private func handleCallStateChange() {
        switch callState {
        case .ringing:
            break // Initial state
        case .connecting:
            nameLbl.text = "School Chimes"
            durationLbl.text = "Connecting..."
        case .active:
            setupAudioPlayer()
        case .ended:
            cleanup()
        }
    }
    
    // MARK: - UI Setup
    private func setupModernUI() {
        // Background gradient with darker theme
        let gradientBG = CAGradientLayer()
        gradientBG.frame = view.bounds
        gradientBG.colors = [
            UIColor(red: 0.08, green: 0.10, blue: 0.13, alpha: 1).cgColor,
            UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1).cgColor,
            UIColor(red: 0.08, green: 0.10, blue: 0.13, alpha: 1).cgColor
        ]
        gradientBG.locations = [0.0, 0.5, 1.0]
        view.layer.insertSublayer(gradientBG, at: 0)
        
        // Logo setup with glow effect
        logoImg.layer.cornerRadius = logoImg.frame.width / 2
        logoImg.clipsToBounds = true
        logoImg.contentMode = .scaleAspectFill
        logoImg.layer.shadowColor = UIColor.white.cgColor
        logoImg.layer.shadowOpacity = 0.4
        logoImg.layer.shadowOffset = .zero
        logoImg.layer.shadowRadius = 25
        logoImg.layer.masksToBounds = false
        
        addLogoPulseAnimation()
        
        // Swipe view with glassmorphism effect
        swipeView.layer.cornerRadius = 30
        swipeView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        swipeView.clipsToBounds = false
        swipeView.layer.borderWidth = 1.5
        swipeView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        
        swipeView.layer.shadowColor = UIColor.black.cgColor
        swipeView.layer.shadowOpacity = 0.3
        swipeView.layer.shadowOffset = CGSize(width: 0, height: 10)
        swipeView.layer.shadowRadius = 20
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = swipeView.bounds
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        swipeView.insertSubview(blurView, at: 0)
        
        // Draggable button with enhanced styling
        draggableButton.layer.cornerRadius = draggableButton.frame.width / 2
        draggableButton.backgroundColor = .white
        draggableButton.layer.shadowColor = UIColor.black.cgColor
        draggableButton.layer.shadowOpacity = 0.4
        draggableButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        draggableButton.layer.shadowRadius = 20
        
        answerCallImg.tintColor = UIColor.systemGreen
        declineCallImg.tintColor = UIColor.systemRed
        
        cutCallBtn.backgroundColor = UIColor.systemRed
        cutCallBtn.tintColor = .white
        cutCallBtn.layer.shadowColor = UIColor.systemRed.cgColor
        cutCallBtn.layer.shadowOpacity = 0.5
        cutCallBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        cutCallBtn.layer.shadowRadius = 12
        
        speakerBtn.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        speakerBtn.tintColor = .white
        speakerBtn.layer.cornerRadius = speakerBtn.frame.width / 2
        speakerBtn.layer.borderWidth = 1
        speakerBtn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        cutCallBtn.addTarget(self, action: #selector(cutCallAction), for: .touchUpInside)
        speakerBtn.addTarget(self, action: #selector(toggleSpeaker), for: .touchUpInside)
    }
    
    private func setupCallerInfo() {
        nameLbl.text = "School Chimes"
        nameLbl.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        nameLbl.textColor = .white
        nameLbl.textAlignment = .center
        nameLbl.numberOfLines = 1
        nameLbl.adjustsFontSizeToFitWidth = true
        nameLbl.minimumScaleFactor = 0.7
        
        durationLbl.text = "Incoming Call"
        durationLbl.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        durationLbl.numberOfLines = 0
        durationLbl.textColor = UIColor.white
        durationLbl.textAlignment = .center
    }
    
    // MARK: - Logo Pulse Animation
    private func addLogoPulseAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.08
        pulseAnimation.duration = 1.2
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        logoImg.layer.add(pulseAnimation, forKey: "logoPulse")
        
        let shadowPulse = CABasicAnimation(keyPath: "shadowRadius")
        shadowPulse.fromValue = 25
        shadowPulse.toValue = 35
        shadowPulse.duration = 1.2
        shadowPulse.autoreverses = true
        shadowPulse.repeatCount = .infinity
        shadowPulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        logoImg.layer.add(shadowPulse, forKey: "shadowPulse")
    }
    
    // MARK: - Button Animation Setup
    private func addPulsatingRingAnimation() {
        addButtonBounceAnimation()
    }
    
    private func addButtonBounceAnimation() {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        bounceAnimation.values = [0, 8, 0, -8, 0]
        bounceAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1.0]
        bounceAnimation.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 4)
        bounceAnimation.duration = 2.0
        bounceAnimation.repeatCount = .infinity
        bounceAnimation.isRemovedOnCompletion = false
        draggableButton.layer.add(bounceAnimation, forKey: "buttonBounce")
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.05, 1.0, 1.05, 1.0]
        scaleAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1.0]
        scaleAnimation.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 4)
        scaleAnimation.duration = 2.0
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.isRemovedOnCompletion = false
        draggableButton.layer.add(scaleAnimation, forKey: "buttonScale")
    }
    
    // MARK: - Synchronized Arrow Animation
    private func startChevronAnimation() {
        animateArrowSet(rightArrowBtns, direction: .right)
        animateArrowSet(leftArrowBtns, direction: .left)
    }
    
    private enum ArrowDirection {
        case left, right
    }
    
    private func animateArrowSet(_ arrows: [UIButton], direction: ArrowDirection) {
        let sortedArrows = direction == .left ? arrows.reversed() : arrows
        
        for (index, arrow) in sortedArrows.enumerated() {
            arrow.alpha = 0.0
            let delay = Double(index) * 0.12
            
            UIView.animate(withDuration: 0.5,
                           delay: delay,
                           options: [.repeat, .autoreverse, .curveEaseInOut],
                           animations: {
                arrow.alpha = 1.0
                let offset: CGFloat = direction == .right ? 3 : -3
                arrow.transform = CGAffineTransform(translationX: offset, y: 0)
            })
        }
    }
    
    private func stopChevronAnimation() {
        for button in rightArrowBtns + leftArrowBtns {
            button.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.2) {
                button.alpha = 0.0
                button.transform = .identity
            }
        }
    }
    
    // MARK: - Slide to Answer Label Animation
    private func setupSlideToAnswerAnimation() {
        slideLabel.text = "slide to answer or decline"
        slideLabel.textAlignment = .center
        slideLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        slideLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        
        let gradient = CAGradientLayer()
        gradient.frame = slideLabel.bounds
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-0.5, 0.0, 0.5]
        animation.toValue = [0.5, 1.0, 1.5]
        animation.duration = 2.5
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradient.add(animation, forKey: "slideAnimation")
        slideLabel.layer.mask = gradient
        gradientLayer = gradient
    }
    
    // MARK: - Swipe Gesture
    private func addSwipeGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        draggableButton.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: swipeView)
        let buttonSize = draggableButton.frame.width
        let maxSwipe = (swipeView.frame.width - buttonSize) / 2 - 15
        
        switch gesture.state {
        case .began:
            isDragging = true
            draggableButton.layer.removeAnimation(forKey: "buttonBounce")
            draggableButton.layer.removeAnimation(forKey: "buttonScale")
            
            UIView.animate(withDuration: 0.2) {
                self.draggableButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                self.rightIndicationStack.alpha = 0
                self.leftIndicationStack.alpha = 0
            }
            
        case .changed:
            let newX = originalCenter.x + translation.x
            let minX = buttonSize / 2 + 15
            let maxX = swipeView.frame.width - buttonSize / 2 - 15
            draggableButton.center.x = max(minX, min(maxX, newX))
            
            let offset = draggableButton.center.x - originalCenter.x
            let progress = min(abs(offset) / maxSwipe, 1.0)
            
            if offset > 0 {
                let greenColor = UIColor.systemGreen.withAlphaComponent(0.3 * progress)
                swipeView.backgroundColor = greenColor
                swipeView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.5 * progress).cgColor
                answerCallImg.alpha = 1.0
                declineCallImg.alpha = max(0.3, 1.0 - (0.7 * progress))
            } else if offset < 0 {
                let redColor = UIColor.systemRed.withAlphaComponent(0.3 * progress)
                swipeView.backgroundColor = redColor
                swipeView.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.5 * progress).cgColor
                declineCallImg.alpha = 1.0
                answerCallImg.alpha = max(0.3, 1.0 - (0.7 * progress))
            } else {
                resetSwipeViewColors()
            }
            
        case .ended, .cancelled:
            isDragging = false
            let velocity = gesture.velocity(in: swipeView).x
            let offset = draggableButton.center.x - originalCenter.x
            
            UIView.animate(withDuration: 0.2) {
                self.draggableButton.transform = .identity
            }
            
            if offset > maxSwipe * 0.65 || velocity > 600 {
                answerCallAction()
            } else if offset < -maxSwipe * 0.65 || velocity < -600 {
                declineCallAction()
            } else {
                resetSwipeView()
            }
            
        default:
            break
        }
    }
    
    private func resetSwipeViewColors() {
        swipeView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        swipeView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        answerCallImg.alpha = 1.0
        declineCallImg.alpha = 1.0
    }
    
    private func resetSwipeView() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.draggableButton.center = self.originalCenter
            self.resetSwipeViewColors()
            self.rightIndicationStack.alpha = 1.0
            self.leftIndicationStack.alpha = 1.0
        } completion: { _ in
            self.addButtonBounceAnimation()
        }
    }
    
    // MARK: - Actions
    private func answerCallAction() {
        guard callState == .ringing else { return }
        stopLocalRingtone()
        stopAllAnimations()
        stopVibration()
        ringtonePlayer?.stop()
        ringtonePlayer = nil
        ringtoneTimeoutTimer?.invalidate()
        ringtoneTimeoutTimer = nil
        call_status = "OC"
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        callState = .connecting
        
        UIView.animate(withDuration: 0.4, animations: {
            self.draggableButton.center.x = self.swipeView.frame.width - self.draggableButton.frame.width / 2 - 15
            self.draggableButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.answerCallImg.alpha = 1.0
            self.declineCallImg.alpha = 0
            self.slideLabel.alpha = 0
        }) { _ in
            self.startTime = self.getCurrentDateTimeString()
            self.navigateToCallScreen()
        }
    }
    
    private func declineCallAction() {
        guard callState == .ringing else { return }
        
        stopAllAnimations()
        stopLocalRingtone()
        stopVibration()
        ringtonePlayer?.stop()
        ringtonePlayer = nil
        ringtoneTimeoutTimer?.invalidate()
        ringtoneTimeoutTimer = nil
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        callState = .ended
        UIView.animate(withDuration: 0.4, animations: {
            self.draggableButton.center.x = self.draggableButton.frame.width / 2 + 15
            self.draggableButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.declineCallImg.alpha = 1.0
            self.answerCallImg.alpha = 0
            self.slideLabel.alpha = 0
        }) { [self] _ in
            call_status = "NO"
            self.dismissCallScreen()
        }
    }
    
    @objc private func cutCallAction() {
        guard callState == .active else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        callState = .ended
        UIView.animate(withDuration: 0.3) {
            self.cutCallBtn.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            self.call_status = "NO"
            self.dismissCallScreen()
        }
    }
    // MARK: - Call Handling
    private func navigateToCallScreen() {
        // Configure audio session for call (earpiece routing)
        configureAudioSessionForCall()
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.swipeView.alpha = 0
            self.swipeView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
            self.cutCallBtn.isHidden = false
            self.speakerBtn.isHidden = false
            
            self.cutCallBtn.alpha = 1.0
            self.durationLbl.alpha = 1.0
            self.speakerBtn.alpha = 1.0
            self.nameLbl.alpha = 1.0
            
            self.cutCallBtn.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.speakerBtn.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut) {
                self.cutCallBtn.transform = .identity
                self.speakerBtn.transform = .identity
            }
            
            self.callState = .active
        }
    }
    
    
    
    @objc private func toggleSpeaker() {
        speakerBtn.isSelected.toggle()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.2) {
            self.speakerBtn.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.speakerBtn.transform = .identity
                self.speakerBtn.backgroundColor = self.speakerBtn.isSelected ?
                UIColor.white.withAlphaComponent(0.3) :
                UIColor.white.withAlphaComponent(0.15)
            }
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            if speakerBtn.isSelected {
                try session.overrideOutputAudioPort(.speaker)
                print("🔈 Speaker ON")
            } else {
                try session.overrideOutputAudioPort(.none)
                print("🔇 Speaker OFF (earpiece)")
            }
        } catch {
            print("⚠️ Failed to toggle speaker: \(error.localizedDescription)")
        }
    }
    
    private func dismissCallScreen() {
        Update_NotificationStatus()
        stopLocalRingtone()
        cleanup()
      
        UIView.animate(withDuration: 0.4, animations: {
            self.view.alpha = 0
            self.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            self.dismiss(animated: false) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    exit(0)
                }
            }
        }
    }
    
    // MARK: - Audio Player
    private func setupAudioPlayer() {

        stopLocalRingtone()   // stop ringing when answered

        audioQueuePlayer = AVQueuePlayer()
        queueItems.removeAll()
        totalQueueDuration = 0

        var orderedUrls: [URL] = []

        if let w = URL(string: welcomeFileUrl), !welcomeFileUrl.isEmpty {
            orderedUrls.append(w)
        }

        if let v = URL(string: voiceUrl), !voiceUrl.isEmpty {
            orderedUrls.append(v)
        }

        guard !orderedUrls.isEmpty else {
            dismissCallScreen()
            return
        }

        let dispatchGroup = DispatchGroup()

        for url in orderedUrls {
            dispatchGroup.enter()

            let cacheKey = url.absoluteString as NSString

            if let cachedData = Self.audioCache.object(forKey: cacheKey) {
                let item = createQueueItem(from: cachedData as Data)
                self.queueItems.append(item)
                dispatchGroup.leave()
            } else {
                URLSession.shared.dataTask(with: url) { data, _, error in
                    defer { dispatchGroup.leave() }

                    guard let data = data, error == nil else { return }

                    Self.audioCache.setObject(data as NSData, forKey: cacheKey, cost: data.count)

                    let item = self.createQueueItem(from: data)
                    self.queueItems.append(item)

                }.resume()
            }
        }

        dispatchGroup.notify(queue: .main) {
            guard let player = self.audioQueuePlayer else { return }

            self.totalQueueDuration = 0

            for item in self.queueItems {
                player.insert(item, after: nil)

                let sec = CMTimeGetSeconds(item.asset.duration)
                if sec.isFinite { self.totalQueueDuration += sec }
            }

            self.startQueueTimer()
            self.observeQueueFinish()
            player.play()
        }
    }
    private func observeQueueFinish() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queueFinished),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }

    @objc private func queueFinished(notification: Notification) {

        guard let player = audioQueuePlayer,
              let item = notification.object as? AVPlayerItem else { return }

        if player.items().last == item {
            audioTimer?.invalidate()
            duration = durationStringToSeconds(durationLbl.text ?? "")
            
            DispatchQueue.main.async {
                self.durationLbl.text = "Call ended"

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.dismissCallScreen()
                }
            }
        }
    }

    
    private func createQueueItem(from data: Data) -> AVPlayerItem {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")

        try? data.write(to: tempURL)

        let asset = AVURLAsset(url: tempURL)
        asset.loadValuesAsynchronously(forKeys: ["duration"])

        let item = AVPlayerItem(asset: asset)
        item.preferredForwardBufferDuration = 5
        return item
    }

    
    
    private func startQueueTimer() {
        audioTimer?.invalidate()

        audioTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.audioQueuePlayer else { return }

            let seconds = CMTimeGetSeconds(player.currentTime())
            guard seconds.isFinite, !seconds.isNaN else { return }

            guard self.totalQueueDuration > 0 else { return }

            let cur = Int(seconds)
            let total = Int(self.totalQueueDuration)

            self.durationLbl.text = String(
                format: "Connected\n\n%02d:%02d / %02d:%02d",
                cur/60, cur%60, total/60, total%60
            )
        }
    }


    
    
    
    private func playAudioData(_ data: Data) {
        do {
            self.audioPlayer = try AVAudioPlayer(data: data)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
            
            self.startAudioTimer()
            print("✅ Audio playing through earpiece")
        } catch {
            print("Audio setup failed: \(error)")
            self.handleAudioPlaybackError()
        }
    }
    
    private func handleAudioPlaybackError() {
        durationLbl.text = "Audio unavailable"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismissCallScreen()
        }
    }
    
    // MARK: - Timer
    private func startAudioTimer() {
        audioTimer?.invalidate()
        audioTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            
            // Current time
            let current = Int(player.currentTime)
            let currentMinutes = current / 60
            let currentSeconds = current % 60
            
            // Total duration
            let total = Int(player.duration)
            let totalMinutes = total / 60
            let totalSeconds = total % 60
            
            // Format: "Connected\n\n00:45 / 03:20"
            self.durationLbl.text = String(format: "Connected\n\n%02d:%02d / %02d:%02d",
                                           currentMinutes, currentSeconds,
                                           totalMinutes, totalSeconds)
        }
    }
    
    private func stopAllTimers() {
        audioTimer?.invalidate()
        audioTimer = nil
        ringtoneTimeoutTimer?.invalidate()
        ringtoneTimeoutTimer = nil
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
    
    private func stopAllAnimations() {
        stopChevronAnimation()
        draggableButton.layer.removeAnimation(forKey: "buttonBounce")
        draggableButton.layer.removeAnimation(forKey: "buttonScale")
        logoImg.layer.removeAnimation(forKey: "logoPulse")
        logoImg.layer.removeAnimation(forKey: "shadowPulse")
        slideLabel.layer.mask = nil
        gradientLayer = nil
    }
    
    // MARK: - Cleanup
    private func cleanup() {
        stopAllAnimations()
        stopAllTimers()
        stopVibration()
        
        audioPlayer?.stop()
        audioPlayer = nil
        
        ringtonePlayer?.stop()
        ringtonePlayer = nil
        
        volumeObserver?.invalidate()
        volumeObserver = nil
        
        NotificationCenter.default.removeObserver(self)
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    deinit {
        cleanup()
        print("NotificationCallVC deinitialized")
    }
}

// MARK: - AVAudioPlayerDelegate
extension NotificationCallVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard player == audioPlayer else { return }
        
        DispatchQueue.main.async {
            if flag {
                self.durationLbl.text = "Call ended"
            } else {
                self.durationLbl.text = "Call ended"
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.dismissCallScreen()
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard player == audioPlayer else { return }
        
        print("Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async {
            self.durationLbl.text = "Audio error"
            self.handleAudioPlaybackError()
        }
    }
    
    func durationStringToSeconds(_ time: String) -> String {
        let parts = time.split(separator: ":").map { Int($0) ?? 0 }

        var seconds = 0

        if parts.count == 3 {           // hh:mm:ss
            seconds = parts[0] * 3600 + parts[1] * 60 + parts[2]
        } else if parts.count == 2 {    // mm:ss
            seconds = parts[0] * 60 + parts[1]
        } else if parts.count == 1 {    // ss
            seconds = parts[0]
        }

        return "\(seconds)"
    }

    func Update_NotificationStatus(){
        
        let param : [String:Any] = [
            "ei1": noti.ei1,
            "ei2":  noti.ei2,
            "ei3":  noti.ei3,
            "ei4" : noti.ei4,
            "ei5" : noti.ei5,
            "receiver_id" : noti.receiver_id,
            "circular_id" : noti.circular_id,
            "duration" : Int(duration) ?? 0,
            "start_time" : startTime,
            "end_time" : getCurrentDateTimeString(),
            "retry_count" : noti.retrycount,
            "phone" : UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? "",
            "diallist_id" : noti.ei5,
            "call_status" : call_status,
            "url" : noti.url
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.update_notification_call_log, parameters: param, type: ApitTypeSringFile.POST, token: "", isBaseUrl: true) { [weak self] (result: Result<CommonApiSuc,Error>) in
            
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success.status == true{
                       
                    }else{
                        
                    }
                case .failure(let failure):
                    
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                }
            }
        }
    }

    func getCurrentDateTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.string(from: Date())
    }
}



