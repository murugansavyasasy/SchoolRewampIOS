//
//  Extentions.swift
//  VsSchoolChimes
//
//  Created by admin on 26/02/25.
//

import Foundation
import UIKit
import Lottie
import RealityFoundation
@available(iOS 15.0, *)
fileprivate var lottieView: LottieAnimationView?
fileprivate var lottieOverlay: UIView?

@available(iOS 15.0, *)
fileprivate var loaderContainerView: UIView?
@available(iOS 15.0, *)
fileprivate var loaderAnimationView: LottieAnimationView?
extension UIImageView {
    func applyRTLFlip(_ isRTL: Bool) {
        if isRTL {
            self.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            self.transform = CGAffineTransform.identity
        }
    }
}
extension UIButton {
    func applyBackButton() {
        let isRTL = isAppRTL()
        self.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        self.contentHorizontalAlignment = isRTL ? .right : .left
        self.imageView?.applyRTLFlip(isRTL)
    }
    func applyRightButton() {
        let isRTL = isAppRTL()
        self.semanticContentAttribute = isRTL ? .forceLeftToRight: .forceRightToLeft
        self.imageView?.applyRTLFlip(isRTL)
    }
    private func isAppRTL() -> Bool {
        let language = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        return language == "ar"
    }
}
extension UIView {
    func applyRightTxt() {
        let language = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        let isRTL = (language == "ar")
        
        if let textView = self as? UITextView {
            textView.textAlignment = isRTL ? .right : .left
        } else if let textField = self as? UITextField {
            textField.textAlignment = isRTL ? .right : .left
        } else if let label = self as? UILabel {
            if isRTL{
                label.textAlignment = (label.textAlignment == .left) ? .right : .left
            }
        }else if let searchBar = self as? UISearchBar {
            if let textField = searchBar.value(forKey: "searchField") as? UITextField {
                textField.textAlignment = isRTL ? .right : .left
            }
        }
    }
    
    func applyRightTxt(with placeholderLabel: UILabel) {
        guard let textView = self as? UITextView else { return }
        
        let language = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        let isRTL = (language == "ar")
        
        textView.textAlignment = isRTL ? .right : .left
        
        let xPosition = isRTL ? (textView.frame.width - placeholderLabel.frame.width - 10) : 5
        placeholderLabel.frame.origin = CGPoint(x: xPosition, y: 8) // Adjust padding
    }
}
extension UIView {
    func addDoneButton() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.items = [flexSpace, doneButton]
        
        if let textField = self as? UITextField {
            textField.inputAccessoryView = toolbar
        } else if let textView = self as? UITextView {
            textView.inputAccessoryView = toolbar
        }
    }
    
    @objc private func dismissKeyboard() {
        self.endEditing(true)
    }
}
class Custom:UIButton{
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        self.backgroundColor = .brown
    }
}
class CustomView:UIView{
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.3
        self.layer.cornerRadius = 8
    }
}
//extension UITapGestureRecognizer {
//    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
//        guard let attributedText = label.attributedText else { return false }
//        let textStorage = NSTextStorage(attributedString: attributedText)
//        let layoutManager = NSLayoutManager()
//        let textContainer = NSTextContainer(size: label.bounds.size)
//        textContainer.lineFragmentPadding = 0
//        textContainer.maximumNumberOfLines = label.numberOfLines
//        textContainer.lineBreakMode = label.lineBreakMode
//        layoutManager.addTextContainer(textContainer)
//        textStorage.addLayoutManager(layoutManager)
//        
//        let location = self.location(in: label)
//        let textBoundingBox = layoutManager.usedRect(for: textContainer)
//        let textContainerOffset = CGPoint(x: (label.bounds.width - textBoundingBox.width) * 0.5 - textBoundingBox.origin.x, y: (label.bounds.height - textBoundingBox.height) * 0.5 - textBoundingBox.origin.y)
//        let locationInTextContainer = CGPoint(x: location.x - textContainerOffset.x, y: location.y - textContainerOffset.y)
//        
//        let characterIndex = layoutManager.characterIndex(for: locationInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
//        return NSLocationInRange(characterIndex, targetRange)
//    }
//}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Ensure there is attributed text
        guard let attributedText = label.attributedText else { return false }
        
        // Create instances of NSTextStorage, NSLayoutManager, and NSTextContainer.
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        // Calculate the actual drawing rect of the text in the label.
        // This returns where the text is actually drawn, not the entire bounds.
        let textRect = label.textRect(forBounds: label.bounds, limitedToNumberOfLines: label.numberOfLines)
        
        // Initialize the text container with the size of the text rectangle.
        let textContainer = NSTextContainer(size: textRect.size)
        textContainer.lineFragmentPadding = 0  // Remove padding
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        
        // Get the tap location in the label's coordinate system.
        let locationOfTouchInLabel = self.location(in: label)
        
        // Convert the tap coordinates to those relative to the text rectangle.
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textRect.origin.x,
            y: locationOfTouchInLabel.y - textRect.origin.y
        )
        
        // Find the index of the character that was tapped.
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        
        // Return true if the tapped character is within the target range.
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

extension String {
    func removingSlashComponent() -> String {
        let components = self.split(separator: "/").map { String($0) }
        return components.joined(separator: "")
    }
}
//extension UIViewController {
//
//    func showLoader(message: String = "Please wait...") {
//        DispatchQueue.main.async {
//            // Prevent multiple loaders
//            guard loaderAlert == nil else { return }
//
//            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//
//            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
//            loadingIndicator.hidesWhenStopped = true
//            loadingIndicator.style = .large
//            loadingIndicator.startAnimating()
//
//            alert.view.addSubview(loadingIndicator)
//            loaderAlert = alert
//
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func hideLoader() {
//        DispatchQueue.main.async {
//            loaderAlert?.dismiss(animated: true, completion: {
//                loaderAlert = nil
//            })
//        }
//    }
//}


//@available(iOS 15.0, *)
//extension UIViewController {
//    
//    func showLottieLoader() {
//        DispatchQueue.main.async {
//            guard lottieOverlay == nil else { return }
//            
//            // Overlay background
//            let overlay = UIView(frame: UIScreen.main.bounds)
//            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//            
//            // Load animation
//            guard let animation = try? LottieAnimation.named("percentage-circle") else {
//                print("Lottie animation not found!")
//                return
//            }
//            
//            let animationView = LottieAnimationView(animation: animation)
//            animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
//            animationView.center = overlay.center
//            animationView.loopMode = .loop
//            animationView.contentMode = .scaleAspectFit
//            animationView.play()
//            
//            overlay.addSubview(animationView)
//            
//            UIApplication.shared.keyWindow?.addSubview(overlay)
//            
//            lottieView = animationView
//            lottieOverlay = overlay
//        }
//    }
//    
//    func hideLottieLoader() {
//        DispatchQueue.main.async {
//            lottieView?.stop()
//            lottieOverlay?.removeFromSuperview()
//            lottieView = nil
//            lottieOverlay = nil
//        }
//    }
//}
@available(iOS 15.0, *)
extension UIViewController {
    
    func showLottieProgressLoader(animationName: String = "loader") {
        hideLottieProgressLoader()

        let containerSize: CGFloat = 100
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerSize, height: containerSize))
        
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: containerSize),
            container.heightAnchor.constraint(equalToConstant: containerSize)
        ])

        // Load Lottie animation
        let animationView = LottieAnimationView(name: animationName)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()

        container.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        loaderContainerView = container
        loaderAnimationView = animationView
    }
    
    func updateLottieProgress(to percent: Double) {
        let percentageText = "\(Int(percent))%"
        DispatchQueue.main.async {
            loaderAnimationView?.textProvider = DictionaryTextProvider(["percentage": percentageText])
        }
    }

    func hideLottieProgressLoader() {
        loaderAnimationView?.stop()
        loaderContainerView?.removeFromSuperview()
        loaderContainerView = nil
        loaderAnimationView = nil
    }
}

enum LoaderStyle {
    case circle
    case rectangle
}

class CircularProgressLoader: UIView {

    static let shared = CircularProgressLoader()

    private let backgroundView = UIView()
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    private let percentageLabel = UILabel()
    private var currentStyle: LoaderStyle = .circle

    private override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        setupCommonUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCommonUI() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .white
        backgroundView.layer.cornerRadius = 20
        backgroundView.clipsToBounds = true
        addSubview(backgroundView)

        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: 100),
            backgroundView.heightAnchor.constraint(equalToConstant: 100)
        ])

        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.textAlignment = .center
        percentageLabel.font = UIFont.boldSystemFont(ofSize: 13)
        percentageLabel.textColor = .black
        backgroundView.addSubview(percentageLabel)

        NSLayoutConstraint.activate([
            percentageLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            percentageLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        ])
    }

    private func setupStyle(_ style: LoaderStyle) {
        trackLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()

        let path: UIBezierPath

        if style == .circle {
            let padding: CGFloat = 20
            let diameter: CGFloat = 100 - (padding * 2)
            let centerPoint = CGPoint(x: 50, y: 50)
            path = UIBezierPath(arcCenter: centerPoint, radius: diameter / 2, startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true)

            trackLayer.strokeColor = UIColor.lightGray.cgColor
            progressLayer.strokeColor = UIColor.systemGreen.cgColor

            trackLayer.lineWidth = 8
            progressLayer.lineWidth = 5

            trackLayer.fillColor = UIColor.clear.cgColor
            progressLayer.fillColor = UIColor.clear.cgColor

            trackLayer.path = path.cgPath
            progressLayer.path = path.cgPath
        } else {
            // Rectangle loader
            let baseRect = CGRect(x: 10, y: 45, width: 80, height: 10)
            path = UIBezierPath(roundedRect: baseRect, cornerRadius: 5)

            trackLayer.fillColor = UIColor.lightGray.cgColor
            progressLayer.fillColor = UIColor.systemGreen.cgColor

            trackLayer.strokeColor = nil
            progressLayer.strokeColor = nil

            trackLayer.lineWidth = 0
            progressLayer.lineWidth = 0

            trackLayer.path = path.cgPath
            progressLayer.path = UIBezierPath(roundedRect: CGRect(x: 10, y: 45, width: 0, height: 10), cornerRadius: 5).cgPath
        }

        backgroundView.layer.addSublayer(trackLayer)
        backgroundView.layer.addSublayer(progressLayer)

        progressLayer.strokeEnd = 0
        percentageLabel.text = "0%"
        self.currentStyle = style
    }

    func show(style: LoaderStyle = .circle) {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

            if self.superview == nil {
                window.addSubview(self)
            }

            self.setupStyle(style)
        }
    }

    func updateProgress(to percent: Double) {
        DispatchQueue.main.async {
            let clamped = max(0.0, min(100.0, percent))
            let stroke = clamped / 100.0
            self.percentageLabel.text = String(format: "%.0f%%", clamped)

            if self.currentStyle == .circle {
                self.progressLayer.strokeEnd = CGFloat(stroke)
            } else {
                let width = 80 * CGFloat(stroke)
                let path = UIBezierPath(roundedRect: CGRect(x: 10, y: 45, width: width, height: 10), cornerRadius: 5)
                self.progressLayer.path = path.cgPath
            }

            if clamped >= 100 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.hide()
                }
            }
        }
    }

    func hide() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
}
class ExpandableLabel: UILabel {

    // MARK: - Public Properties
    var isExpanded: Bool = false {
        didSet {
            updateLabel()
        }
    }
    var onTap: (() -> Void)?
    
    // MARK: - Private Properties
    private var fullText: String = ""
    private let maxTrimLength = 100

    // MARK: - Configure Label
    func configure(text: String, isExpanded: Bool = false) {
        self.fullText = text
        self.isExpanded = isExpanded
        self.numberOfLines = 0
        updateLabel()
        addTapGesture()
    }

    // MARK: - Update Attributed Text
    private func updateLabel() {
        self.attributedText = createAttributedText(text: fullText)
    }

    // MARK: - Create Attributed Text
    private func createAttributedText(text: String) -> NSAttributedString {
        guard let font = self.font else { return NSAttributedString(string: text) }
        
        if isExpanded {
            let fullString = text + " " + CommonStringFile.seeLess.translated()
            let attributed = NSMutableAttributedString(string: fullString, attributes: [.font: font])
            let seeLessRange = (fullString as NSString).range(of: CommonStringFile.seeLess.translated())
            attributed.addAttributes([
                .foregroundColor: UIColor.link,
                .font: UIFont.boldSystemFont(ofSize: font.pointSize)
            ], range: seeLessRange)
            return attributed
        } else {
            var displayText = text
            if text.count > maxTrimLength {
                displayText = String(text.prefix(maxTrimLength)).trimmingCharacters(in: .whitespacesAndNewlines)
                displayText += "... " + CommonStringFile.seemore.translated()
            }
            let attributed = NSMutableAttributedString(string: displayText, attributes: [.font: font])
            let seeMoreRange = (displayText as NSString).range(of: CommonStringFile.seemore.translated())
            if seeMoreRange.location != NSNotFound {
                attributed.addAttributes([
                    .foregroundColor: UIColor.link,
                    .font: UIFont.boldSystemFont(ofSize: font.pointSize)
                ], range: seeMoreRange)
            }
            return attributed
        }
    }

    // MARK: - Add Tap Gesture
    private func addTapGesture() {
        isUserInteractionEnabled = true
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    // MARK: - Handle Tap
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let text = self.attributedText?.string else { return }
        let nsText = text as NSString
        let tappableText = isExpanded ? CommonStringFile.seeLess.translated() : CommonStringFile.seemore.translated()
        let tappableRange = nsText.range(of: tappableText)

        let tapLocation = gesture.location(in: self)
        let index = indexOfCharacter(at: tapLocation)

        if NSLocationInRange(index, tappableRange) {
            onTap?()
        }
    }

    // MARK: - Get Index of Character at Tap Point
    private func indexOfCharacter(at point: CGPoint) -> Int {
        guard let attributedText = self.attributedText else { return NSNotFound }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: self.bounds.size)

        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        return layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
    }
}

