//
//  ForceUpdateVc.swift
//  School Chimes
//
//  Created by apple on 24/01/26.
//

import UIKit
protocol DismissDelegate: AnyObject {
    func checkLaterFunc(isNewUser:Bool)
}

class ForceUpdateVc: UIViewController {
    @IBOutlet weak var backBtnName: UIButton!
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var launchDateContainerView: UIView!
    @IBOutlet weak var expectedLaunchLabel: UILabel!
    @IBOutlet weak var launchDateLabel: UILabel!
    @IBOutlet weak var forceUpdateBtn: UIButton!
    @IBOutlet weak var notNowLbl: UILabel!
    
    // Gradient layer
    private var gradientLayer: CAGradientLayer?
    var appRedirectLink : String = ""
    var is_forceUpdate : Bool = false
    var isNewAppLaunch : Bool = false
    var titlle : String = ""
    var descriptions : String = ""
    weak var delegate: DismissDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setBulletAttributedText(descriptions, textView: descriptionLabel)
    }

    func setBulletAttributedText(_ text: String, textView: UITextView) {

        let parts = text.split(separator: "~")
        let attributedText = NSMutableAttributedString()

        for part in parts {
            let bullet = "• "
            let content = part.trimmingCharacters(in: .whitespaces)

            let bulletAttr = NSAttributedString(
                string: bullet,
                attributes: [.font: UIFont.boldSystemFont(ofSize: 14)]
            )

            let textAttr = NSAttributedString(
                string: content + "\n",
                attributes: [.font: UIFont.systemFont(ofSize: 14)]
            )

            attributedText.append(bulletAttr)
            attributedText.append(textAttr)
        }

        textView.attributedText = attributedText
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradientFrame()
    }
    
    private func updateGradientFrame() {
        // Update gradient frame when view layout changes
        if let gradientView = containerView.subviews.first {
            gradientLayer?.frame = gradientView.bounds
        }
        
        // Update button gradient
        if let buttonGradient = forceUpdateBtn.layer.sublayers?.first as? CAGradientLayer {
            buttonGradient.frame = forceUpdateBtn.bounds
        }
    }
    private func setupUI() {
        // Container view styling
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 20
        expectedLaunchLabel.text = titlle
        // Add gradient to top of container
        addGradientBackground()
        
        // Launch date container styling
        launchDateContainerView.layer.cornerRadius = 12
        launchDateContainerView.layer.masksToBounds = true
        
        // Button styling
        forceUpdateBtn.layer.cornerRadius = 12
        forceUpdateBtn.layer.masksToBounds = true
        
        // Add gradient to button
        addButtonGradient()
        
        // Icon glow effect
        if let glowView = iconImageView.superview?.subviews.first(where: { $0.tag == 0 || $0 != iconImageView }) {
            glowView.layer.cornerRadius = iconImageView.frame.size.width/2
            glowView.layer.masksToBounds = false
            
            // Add blur effect
            glowView.layer.shadowColor = UIColor.systemPink.cgColor
            glowView.layer.shadowOffset = .zero
            glowView.layer.shadowOpacity = 0.6
            glowView.layer.shadowRadius = 30
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkLaterTapped))
        notNowLbl.isUserInteractionEnabled = true
        notNowLbl.addGestureRecognizer(tapGesture)

        notNowLbl.isHidden = is_forceUpdate
        
    }

    @objc private func checkLaterTapped() {
        dismissPopup()
    }
    private func dismissPopup() {
        delegate?.checkLaterFunc(isNewUser: false)
        animateExit { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
    }
    private func animateExit(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.containerView.alpha = 0
            self.view.alpha = 0
        }) { _ in
            completion()
        }
    }
    private func addGradientBackground() {

        guard let gradientView = containerView.subviews.first else { return }

        let gradient = CAGradientLayer()

        gradient.colors = [
            UIColor(red: 0.239, green: 0.510, blue: 0.929, alpha: 1.0).cgColor, // RIGHT SIDE (#3D82ED)
            UIColor.white.cgColor// LEFT SIDE
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0.5) // LEFT
        gradient.endPoint = CGPoint(x: 1, y: 0.5)   // RIGHT

        gradient.frame = gradientView.bounds
        gradient.cornerRadius = gradientView.layer.cornerRadius

        gradientView.layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient
    }

    
    private func addButtonGradient() {

        let gradient = CAGradientLayer()

        gradient.colors = [
           
            UIColor(red: 0.239, green: 0.510, blue: 0.929, alpha: 1.0).cgColor, // RIGHT (#3D82ED)
            UIColor.white.cgColor // LEFT
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        gradient.frame = forceUpdateBtn.bounds
        gradient.cornerRadius = 12

        // 🔴 Important: avoid adding multiple gradients
        forceUpdateBtn.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        forceUpdateBtn.layer.insertSublayer(gradient, at: 0)
    }

    
    
    @IBAction func updateBtnAct(_ sender: UIButton) {
        callAppStore ()
    }
    
    func callAppStore ()
    {
        if let url = URL(string: "\(appRedirectLink)"), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        guard let url = URL(string: "\(appRedirectLink)"), !url.absoluteString.isEmpty else {
        return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
