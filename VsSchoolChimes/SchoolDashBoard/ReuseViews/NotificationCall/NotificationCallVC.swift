//
//  NotificationCallVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/10/25.
//

import UIKit
import AVFAudio
import AVFoundation

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
    private var gradientLayer: CAGradientLayer!
    private var animation: CABasicAnimation!
    private var originalCenter: CGPoint = .zero
    private var isDragging = false
    
    private var callTimer: Timer?
    private var audioTimer: Timer?
    private var callDuration: Int = 0
    var voiceUrl: String = "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/communication/7045/2025-09-266/RecordedAudio.m4a"
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        configureAudioSession()
        playDefaultRingtone()
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = slideLabel.bounds
        originalCenter = draggableButton.center
        
        if ((draggableButton.layer.animationKeys()?.contains("buttonBounce")) == nil) ?? true {
            addPulsatingRingAnimation()
            startChevronAnimation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAllAnimations()
        stopTimers()
    }
    private func playDefaultRingtone() {
        // Path to the default iPhone ringtone
        let ringtonePath = "/System/Library/Audio/UISounds/Ringers/Opening.m4r"
        let ringtoneURL = URL(fileURLWithPath: ringtonePath)
        
        do {
            // Configure audio session
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Create and configure audio player
            audioPlayer = try AVAudioPlayer(contentsOf: ringtoneURL)
            audioPlayer?.numberOfLoops = -1  // Loop indefinitely like a real call
            audioPlayer?.play()
            
            // Auto dismiss after a few rings (adjust timing as needed)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.audioPlayer?.stop()
                self.dismiss(animated: true)
            }
        } catch {
            print("Failed to play ringtone: \(error)")
        }
    }

    // MARK: - Audio Session Configuration
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
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
        
        // Add subtle pulse to logo
        addLogoPulseAnimation()
        
        // Swipe view with glassmorphism effect
        swipeView.layer.cornerRadius = 30
        swipeView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        swipeView.clipsToBounds = false
        swipeView.layer.borderWidth = 1.5
        swipeView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        
        // Add shadow to swipe view
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
        
        // Add inner shadow effect to button
        let innerShadow = CALayer()
        innerShadow.frame = draggableButton.bounds
        innerShadow.cornerRadius = draggableButton.frame.width / 2
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 2)
        innerShadow.shadowOpacity = 0.1
        innerShadow.shadowRadius = 3
        
        // Answer and decline buttons styling (center arrows - always visible)
        answerCallImg.tintColor = UIColor.systemGreen
        answerCallImg.alpha = 1.0
        declineCallImg.tintColor = UIColor.systemRed
        declineCallImg.alpha = 1.0
        
        // Cut call button styling
        cutCallBtn.backgroundColor = UIColor.systemRed
        cutCallBtn.tintColor = .white
        cutCallBtn.layer.shadowColor = UIColor.systemRed.cgColor
        cutCallBtn.layer.shadowOpacity = 0.5
        cutCallBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        cutCallBtn.layer.shadowRadius = 12
        
        // Speaker button styling
        speakerBtn.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        speakerBtn.tintColor = .white
        speakerBtn.layer.cornerRadius = speakerBtn.frame.width / 2
        speakerBtn.layer.borderWidth = 1
        speakerBtn.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
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
        // Add iPhone-style side-to-side bounce animation
        addButtonBounceAnimation()
    }
    
    // MARK: - iPhone Call Button Bounce Animation
    private func addButtonBounceAnimation() {
        // Create a subtle side-to-side movement animation
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        
        // Define the bounce path: center -> right -> center -> left -> center
        bounceAnimation.values = [0, 8, 0, -8, 0]
        bounceAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1.0]
        
        // Use ease-in-out for smooth, natural movement
        bounceAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        
        bounceAnimation.duration = 2.0
        bounceAnimation.repeatCount = .infinity
        bounceAnimation.isRemovedOnCompletion = false
        
        draggableButton.layer.add(bounceAnimation, forKey: "buttonBounce")
        
        // Add a subtle scale pulse to emphasize the interactive nature
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.05, 1.0, 1.05, 1.0]
        scaleAnimation.keyTimes = [0, 0.25, 0.5, 0.75, 1.0]
        scaleAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        scaleAnimation.duration = 2.0
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.isRemovedOnCompletion = false
        
        draggableButton.layer.add(scaleAnimation, forKey: "buttonScale")
    }
    
    // MARK: - Synchronized Arrow Animation
    private func startChevronAnimation() {
        // Animate both sides simultaneously with matching timing
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
            
            // Fade + slight movement animation
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
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = slideLabel.bounds
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-0.5, 0.0, 0.5]
        animation.toValue = [0.5, 1.0, 1.5]
        animation.duration = 2.5
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(animation, forKey: "slideAnimation")
        slideLabel.layer.mask = gradientLayer
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
            // Stop bounce animation when user starts dragging
            draggableButton.layer.removeAnimation(forKey: "buttonBounce")
            draggableButton.layer.removeAnimation(forKey: "buttonScale")
            
            // Hide arrow indicators during swipe
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
            
            // Visual feedback based on direction
            let offset = draggableButton.center.x - originalCenter.x
            let progress = min(abs(offset) / maxSwipe, 1.0)
            
            if offset > 0 {
                // Swiping right - turn green
                let greenColor = UIColor.systemGreen.withAlphaComponent(0.3 * progress)
                swipeView.backgroundColor = greenColor
                swipeView.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.5 * progress).cgColor
                
                // Keep center arrows visible, fade the opposite one slightly
                answerCallImg.alpha = 1.0
                declineCallImg.alpha = max(0.3, 1.0 - (0.7 * progress))
            } else if offset < 0 {
                // Swiping left - turn red
                let redColor = UIColor.systemRed.withAlphaComponent(0.3 * progress)
                swipeView.backgroundColor = redColor
                swipeView.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.5 * progress).cgColor
                
                // Keep center arrows visible, fade the opposite one slightly
                declineCallImg.alpha = 1.0
                answerCallImg.alpha = max(0.3, 1.0 - (0.7 * progress))
            } else {
                // At center - reset to default
                swipeView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
                swipeView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
                answerCallImg.alpha = 1.0
                declineCallImg.alpha = 1.0
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
    
    private func resetSwipeView() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.draggableButton.center = self.originalCenter
            self.answerCallImg.alpha = 0.8
            self.declineCallImg.alpha = 0.8
            
            // Reset swipe view color to default
            self.swipeView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            self.swipeView.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
            
            // Show arrow indicators again
            self.rightIndicationStack.alpha = 1.0
            self.leftIndicationStack.alpha = 1.0
        } completion: { _ in
            // Restart bounce animation after reset
            self.addButtonBounceAnimation()
        }
    }
    
    // MARK: - Actions
    private func answerCallAction() {
        stopAllAnimations()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Smooth transition animation
        UIView.animate(withDuration: 0.4, animations: {
            self.draggableButton.center.x = self.swipeView.frame.width - self.draggableButton.frame.width / 2 - 15
            self.draggableButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.answerCallImg.alpha = 1.0
            self.declineCallImg.alpha = 0
            self.slideLabel.alpha = 0
        }) { _ in
            self.navigateToCallScreen()
        }
    }
    
    private func declineCallAction() {
        stopAllAnimations()
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        // Smooth transition animation
        UIView.animate(withDuration: 0.4, animations: {
            self.draggableButton.center.x = self.draggableButton.frame.width / 2 + 15
            self.draggableButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.declineCallImg.alpha = 1.0
            self.answerCallImg.alpha = 0
            self.slideLabel.alpha = 0
        }) { _ in
            self.dismissCallScreen()
        }
    }
    
    // MARK: - Call Handling
    private func navigateToCallScreen() {
        // Animate to active call UI
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
            
            self.nameLbl.text = "School Chimes"
            self.durationLbl.text = "Connecting..."
            self.setupAudioPlayer()
            self.cutCallBtn.addTarget(self, action: #selector(self.cutCallAction), for: .touchUpInside)
            self.speakerBtn.addTarget(self, action: #selector(self.toggleSpeaker), for: .touchUpInside)
        }
    }
    
    @objc private func cutCallAction() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        UIView.animate(withDuration: 0.3) {
            self.cutCallBtn.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            self.stopTimers()
            self.dismissCallScreen()
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
            try session.overrideOutputAudioPort(speakerBtn.isSelected ? .speaker : .none)
        } catch {
            print("Failed to toggle speaker: \(error.localizedDescription)")
        }
    }
    
    private func dismissCallScreen() {
        stopTimers()
        audioPlayer?.stop()
        audioPlayer = nil
        
        UIView.animate(withDuration: 0.4, animations: {
            self.view.alpha = 0
            self.view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    // MARK: - Audio Player
    private func setupAudioPlayer() {
        guard let url = URL(string: voiceUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { print("Download error: \(error)"); return }
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                do {
                    self.audioPlayer = try AVAudioPlayer(data: data)
                    self.audioPlayer?.delegate = self
                    self.audioPlayer?.prepareToPlay()
                    self.audioPlayer?.play()
                    
                    self.startAudioTimer()
                } catch {
                    print("Audio setup failed: \(error)")
                }
            }
        }.resume()
    }
    
    // MARK: - Timer
    private func startAudioTimer() {
        audioTimer?.invalidate()
        audioTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            let current = Int(player.currentTime)
            let minutes = current / 60
            let seconds = current % 60
            self.durationLbl.text = "Connected\n\n\(String(format: "%02d:%02d", minutes, seconds))"
        }
    }
    private func stopTimers() {
        audioTimer?.invalidate()
        audioTimer = nil
        callTimer?.invalidate()
        callTimer = nil
    }
    
    private func stopAllAnimations() {
        stopChevronAnimation()
        draggableButton.layer.removeAnimation(forKey: "buttonBounce")
        draggableButton.layer.removeAnimation(forKey: "buttonScale")
        logoImg.layer.removeAnimation(forKey: "logoPulse")
        logoImg.layer.removeAnimation(forKey: "shadowPulse")
        slideLabel.layer.mask = nil
    }
    
    deinit {
        stopAllAnimations()
        stopTimers()
        audioPlayer?.stop()
        audioPlayer = nil
        print("NotificationCallVC deinitialized")
    }
}

// MARK: - AVAudioPlayerDelegate
extension NotificationCallVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.durationLbl.text = "Call ended"
            
            // Auto dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.dismissCallScreen()
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
        DispatchQueue.main.async {
            self.durationLbl.text = "Audio error"
        }
    }
}
