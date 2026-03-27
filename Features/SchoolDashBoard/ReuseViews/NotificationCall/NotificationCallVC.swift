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
    
    @IBOutlet weak var answerStack: UIStackView!
    @IBOutlet weak var declineStack: UIStackView!
    // MARK: - IBOutlets
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var cutCallBtn: UIButton!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var rightIndicationStack: UIStackView!
    @IBOutlet weak var leftIndicationStack: UIStackView!
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
    var itemDurations: [AVPlayerItem: Double] = [:]
    var queueItems: [AVPlayerItem] = []
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
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        stopLocalRingtone()
        setupModernUI()
        setupCallerInfo()
        cutCallBtn.isHidden = true
        speakerBtn.isHidden = true
        cutCallBtn.layer.cornerRadius = cutCallBtn.frame.width / 2
        cutCallBtn.alpha = 0
        speakerBtn.alpha = 0
        
        configureAudioSessionForRingtone()
        
            playLocalRingtone(named: "schoolchimes_tone", ext: "wav")
        
        let declineClick = UITapGestureRecognizer(target: self, action: #selector(DeclineBtnAct))
        declineStack.addGestureRecognizer(declineClick)
        
         let AnswerClick = UITapGestureRecognizer(target: self, action: #selector(AnswerBtnAct))
        answerStack.addGestureRecognizer(AnswerClick)
        
        setupVolumeObserver()
        setupPowerButtonObserver()
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(queueDidFinish),
//            name: .AVPlayerItemDidPlayToEndTime,
//            object: nil
//        )
        
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
        if let receiverurl = userInfo["url"] as? String {
            noti.url = receiverurl
        }
    }
    
    @objc private func queueFinished(notification: Notification) {

        guard let player = audioQueuePlayer else { return }

        // Wait a bit to allow queue update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

            if player.items().isEmpty && player.currentItem == nil {
                self.audioTimer?.invalidate()

                DispatchQueue.main.async {
                    self.durationLbl.text = "Call ended"

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.dismissCallScreen()
                    }
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanup()
    }
    private func setDefaultSpeakerOn() {
        speakerBtn.isSelected = true
        speakerBtn.backgroundColor = UIColor.white.withAlphaComponent(0.3)

        do {
            let session = AVAudioSession.sharedInstance()
            try session.overrideOutputAudioPort(.speaker)
        } catch {
            print("⚠️ Speaker enable failed: \(error)")
        }
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
            declineCallAction()
        case .active:
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

    // MARK: - Audio Session Configuration
    private func configureAudioSessionForCall() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP]
            )
            
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            try session.overrideOutputAudioPort(.speaker)
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
            return false
        }
    }

    private func playLocalRingtone(named name: String, ext: String) {
        guard let path = Bundle.main.url(forResource: name, withExtension: ext) else {
            playSystemDefaultTone()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
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
    
    
    @IBAction func DeclineBtnAct() {
        
        declineCallAction()
    }
    
    
    @IBAction func AnswerBtnAct() {
        
        answerCallAction()
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
//        draggableButton.layer.add(bounceAnimation, forKey: "buttonBounce")
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.05, 1.0, 1.05, 1.0]
        scaleAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1.0]
        scaleAnimation.timingFunctions = Array(repeating: CAMediaTimingFunction(name: .easeInEaseOut), count: 4)
        scaleAnimation.duration = 2.0
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.isRemovedOnCompletion = false
//        draggableButton.layer.add(scaleAnimation, forKey: "buttonScale")
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
//    private func setupSlideToAnswerAnimation() {
//        slideLabel.text = "slide to answer or decline"
//        slideLabel.textAlignment = .center
//        slideLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
//        slideLabel.textColor = UIColor.white.withAlphaComponent(0.9)
//        
//        let gradient = CAGradientLayer()
//        gradient.frame = slideLabel.bounds
//        gradient.colors = [
//            UIColor.clear.cgColor,
//            UIColor.white.cgColor,
//            UIColor.clear.cgColor
//        ]
//        gradient.locations = [0.0, 0.5, 1.0]
//        gradient.startPoint = CGPoint(x: 0, y: 0.5)
//        gradient.endPoint = CGPoint(x: 1, y: 0.5)
//        
//        let animation = CABasicAnimation(keyPath: "locations")
//        animation.fromValue = [-0.5, 0.0, 0.5]
//        animation.toValue = [0.5, 1.0, 1.5]
//        animation.duration = 2.5
//        animation.repeatCount = .infinity
//        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        
//        gradient.add(animation, forKey: "slideAnimation")
//        slideLabel.layer.mask = gradient
//        gradientLayer = gradient
//    }
//    
    // MARK: - Swipe Gesture
//    private func addSwipeGesture() {
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        draggableButton.addGestureRecognizer(panGesture)
//    }
    
//    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: swipeView)
//        let buttonSize = draggableButton.frame.width
//        let maxSwipe = (swipeView.frame.width - buttonSize) / 2 - 15
//        
//        switch gesture.state {
//        case .began:
//            isDragging = true
//            draggableButton.layer.removeAnimation(forKey: "buttonBounce")
//            draggableButton.layer.removeAnimation(forKey: "buttonScale")
//            
//            UIView.animate(withDuration: 0.2) {
//                self.draggableButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//                self.rightIndicationStack.alpha = 0
//                self.leftIndicationStack.alpha = 0
//            }
//            
//        case .changed:
//            let newX = originalCenter.x + translation.x
//            let minX = buttonSize / 2 + 15
//            let maxX = swipeView.frame.width - buttonSize / 2 - 15
//            draggableButton.center.x = max(minX, min(maxX, newX))
//            
//            let offset = draggableButton.center.x - originalCenter.x
//            let progress = min(abs(offset) / maxSwipe, 1.0)
//            
//            if offset > 0 {
//                let greenColor = UIColor.systemGreen.withAlphaComponent(0.3 * progress)
//                swipeView.backgroundColor = greenColor
//                swipeView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.5 * progress).cgColor
//                answerCallImg.alpha = 1.0
//                declineCallImg.alpha = max(0.3, 1.0 - (0.7 * progress))
//            } else if offset < 0 {
//                let redColor = UIColor.systemRed.withAlphaComponent(0.3 * progress)
//                swipeView.backgroundColor = redColor
//                swipeView.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.5 * progress).cgColor
//                declineCallImg.alpha = 1.0
//                answerCallImg.alpha = max(0.3, 1.0 - (0.7 * progress))
//            } else {
//                resetSwipeViewColors()
//            }
//            
//        case .ended, .cancelled:
//            isDragging = false
//            let velocity = gesture.velocity(in: swipeView).x
//            let offset = draggableButton.center.x - originalCenter.x
//            
//            UIView.animate(withDuration: 0.2) {
//                self.draggableButton.transform = .identity
//            }
//            
//            if offset > maxSwipe * 0.65 || velocity > 600 {
//                answerCallAction()
//            } else if offset < -maxSwipe * 0.65 || velocity < -600 {
//                declineCallAction()
//            } else {
//                resetSwipeView()
//            }
//            
//        default:
//            break
//        }
//    }
    
    private func resetSwipeViewColors() {
        swipeView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        swipeView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor

    }
    
    private func resetSwipeView() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
//            self.draggableButton.center = self.originalCenter
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
        
            self.startTime = self.getCurrentDateTimeString()
            self.navigateToCallScreen()
       
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
            call_status = "NO"
            self.dismissCallScreen()
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
    private func navigateToCallScreen() {
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
            self.configureAudioSessionForCall()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.setDefaultSpeakerOn()
            }
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
            } else {
                try session.overrideOutputAudioPort(.none)
            }
        } catch {
            print("⚠️ Failed to toggle speaker: \(error.localizedDescription)")
        }
    }
    
    private func dismissCallScreen() {

        Update_NotificationStatus()
        stopLocalRingtone()
        cleanup()

        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
            self.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in

            if self.presentingViewController != nil {
                self.dismiss(animated: false)
                return
            }

            if let nav = self.navigationController {
                nav.popViewController(animated: true)
                return
            }
            if let window = UIApplication.shared.windows.first {

                let storyboard = UIStoryboard(name: "SplashStoryboard", bundle: nil)
                let homeVC = storyboard.instantiateViewController(withIdentifier: "SplashVC")

                let nav = UINavigationController(rootViewController: homeVC)
                window.rootViewController = nav
                window.makeKeyAndVisible()
            }
        }
    }
    private func setupAudioPlayer() {
        stopLocalRingtone()
        configureAudioSessionForCall()

        audioQueuePlayer = AVQueuePlayer()
        totalQueueDuration = 0
        itemDurations.removeAll()

        if let w = URL(string: welcomeFileUrl), !welcomeFileUrl.isEmpty {
            queueItems.append(AVPlayerItem(url: w))
        }

        if let v = URL(string: voiceUrl), !voiceUrl.isEmpty {
            queueItems.append(AVPlayerItem(url: v))
        }

        guard let player = audioQueuePlayer else { return }

        Task {
            for item in queueItems {
                do {
                    let duration = try await item.asset.load(.duration)
                    let sec = CMTimeGetSeconds(duration)

                    if sec.isFinite {
                        self.totalQueueDuration += sec
                        self.itemDurations[item] = sec
                    }
                } catch {
                    print("Duration failed")
                    self.itemDurations[item] = 0
                }
            }
            for item in queueItems {
                item.preferredForwardBufferDuration = 5
                player.insert(item, after: nil)
            }

            player.actionAtItemEnd = .advance
            player.automaticallyWaitsToMinimizeStalling = true
            player.volume = 1.0

            DispatchQueue.main.async {
                self.startQueueTimer()
            }

            self.observeQueueFinish()
            self.setDefaultSpeakerOn()

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
 
    private func startQueueTimer() {
        audioTimer?.invalidate()

        audioTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.audioQueuePlayer,
                  let currentItem = player.currentItem else { return }

            var totalPlayed: Double = 0

            for item in self.queueItems {

                if item == currentItem {
                    let current = CMTimeGetSeconds(player.currentTime())
                    totalPlayed += current.isFinite ? current : 0
                    break
                }

                totalPlayed += self.itemDurations[item] ?? 0
            }

            let total = self.totalQueueDuration

            self.durationLbl.text = String(
                format: "Connected\n\n%02d:%02d / %02d:%02d",
                Int(totalPlayed)/60, Int(totalPlayed)%60,
                Int(total)/60, Int(total)%60
            )
        }
    }
    
    private func handleAudioPlaybackError() {
        durationLbl.text = "Audio unavailable"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismissCallScreen()
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
        logoImg.layer.removeAnimation(forKey: "logoPulse")
        logoImg.layer.removeAnimation(forKey: "shadowPulse")
        gradientLayer = nil
    }
    
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

        DispatchQueue.global(qos: .userInitiated).async {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("AudioSession deactivation failed: \(error)")
            }
        }
    }
    
    deinit {
        cleanup()
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



