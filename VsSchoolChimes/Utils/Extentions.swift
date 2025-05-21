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
private var loaderBackgroundView: UIView?
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

        // Create full-screen background layer that blocks interactions
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3) // semi-transparent
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.isUserInteractionEnabled = true // block interactions
        view.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let containerSize: CGFloat = 100
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerSize, height: containerSize))
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        backgroundView.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
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
        loaderBackgroundView = backgroundView
    }

    func updateLottieProgress(to percent: Double) {
        let percentageText = "\(Int(percent))%"
        DispatchQueue.main.async {
            loaderAnimationView?.textProvider = DictionaryTextProvider(["percentage": percentageText])
        }
    }

    func hideLottieProgressLoader() {
        loaderAnimationView?.stop()
        loaderBackgroundView?.removeFromSuperview()
        loaderContainerView = nil
        loaderAnimationView = nil
        loaderBackgroundView = nil
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
fileprivate class ExpandableLabelState {
    var fullText: String = ""
    var isExpanded: Bool = false
    var onTap: (() -> Void)?
}

extension UILabel {

    private struct AssociatedKeys {
        static var expandableState = "expandableState"
    }

    private var expandableState: ExpandableLabelState {
        if let state = objc_getAssociatedObject(self, &AssociatedKeys.expandableState) as? ExpandableLabelState {
            return state
        }
        let state = ExpandableLabelState()
        objc_setAssociatedObject(self, &AssociatedKeys.expandableState, state, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return state
    }

    var isExpanded: Bool {
        get { expandableState.isExpanded }
        set {
            expandableState.isExpanded = newValue
            updateExpandableLabel()
        }
    }

    var onExpandableTap: (() -> Void)? {
        get { expandableState.onTap }
        set { expandableState.onTap = newValue }
    }

    func setupExpandable(text: String, isExpanded: Bool = false) {
        expandableState.fullText = text
        expandableState.isExpanded = isExpanded
        self.numberOfLines = 0
        updateExpandableLabel()
        addExpandableTapGesture()
    }

    private func updateExpandableLabel() {
        let fullText = expandableState.fullText
        guard let font = self.font else { return }

        if fullText.count <= 100 {
            self.attributedText = NSAttributedString(string: fullText, attributes: [.font: font])
            return
        }

        if expandableState.isExpanded {
            let text = fullText + " " + CommonStringFile.seeLess.translated()
            let attr = NSMutableAttributedString(string: text, attributes: [.font: font])
            let range = (text as NSString).range(of: CommonStringFile.seeLess.translated())
            attr.addAttributes([.foregroundColor: UIColor.link, .font: UIFont.boldSystemFont(ofSize: font.pointSize)], range: range)
            self.attributedText = attr
        } else {
            var trimmed = String(fullText.prefix(100)).trimmingCharacters(in: .whitespacesAndNewlines)
            trimmed += "... " + CommonStringFile.seemore.translated()
            let attr = NSMutableAttributedString(string: trimmed, attributes: [.font: font])
            let range = (trimmed as NSString).range(of: CommonStringFile.seemore.translated())
            attr.addAttributes([.foregroundColor: UIColor.link, .font: UIFont.boldSystemFont(ofSize: font.pointSize)], range: range)
            self.attributedText = attr
        }
    }

    private func addExpandableTapGesture() {
        isUserInteractionEnabled = true
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleExpandableLabelTap(_:)))
        addGestureRecognizer(tap)
    }

    @objc private func handleExpandableLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let text = self.attributedText?.string else { return }

        // Only handle tap if full text is longer than 100
        if expandableState.fullText.count <= 100 { return }

        let nsText = text as NSString
        let keyword = expandableState.isExpanded ? CommonStringFile.seeLess.translated() : CommonStringFile.seemore.translated()
        let range = nsText.range(of: keyword)

        let tapPoint = gesture.location(in: self)
        let index = indexOfCharacter(at: tapPoint)

        if NSLocationInRange(index, range) {
            expandableState.onTap?()
        }
    }

    private func indexOfCharacter(at point: CGPoint) -> Int {
        guard let attributedText = self.attributedText else { return NSNotFound }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)

        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        return layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
    }
}
func downloadFile(from urlString: String, folderName: String, fileName: String, completion: ((Result<URL, Error>) -> Void)? = nil) {
    guard let fileURL = URL(string: urlString) else {
        print("❌ Invalid URL string.")
        completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
        return
    }
    
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let folderURL = documentsURL.appendingPathComponent(folderName, isDirectory: true)
    let destinationURL = folderURL.appendingPathComponent(fileName)
    
    // Ensure folder exists
    do {
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            print("📁 Created folder at: \(folderURL.path)")
        }
    } catch {
        print("❌ Could not create folder: \(error.localizedDescription)")
        completion?(.failure(error))
        return
    }
    
    // Download task
    let task = URLSession.shared.downloadTask(with: fileURL) { tempLocalURL, response, error in
        if let error = error {
            print("❌ Download failed: \(error.localizedDescription)")
            completion?(.failure(error))
            return
        }
        
        guard let tempLocalURL = tempLocalURL else {
            let noFileError = NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Temp file not found"])
            print("❌ No temp file URL")
            completion?(.failure(noFileError))
            return
        }
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: tempLocalURL, to: destinationURL)
            print("✅ File saved to: \(destinationURL.path)")
            completion?(.success(destinationURL))
        } catch {
            print("❌ File saving failed: \(error.localizedDescription)")
            completion?(.failure(error))
        }
    }
    
    task.resume()
}
extension DateFormatter {
    func convertDate(_ dateString: String, fromFormat: String = "dd-MM-yyyy", toFormat: String = "dd MMM yyyy") -> String? {
        self.dateFormat = fromFormat

        if let date = self.date(from: dateString) {
            self.dateFormat = toFormat
            return self.string(from: date)
        }
        return nil
    }
    
}

extension UILabel {
    func setStyledDateTime(dateString: String, timeString: String?) {
        let dateAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        let timeAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.gray]

        let attributedText = NSMutableAttributedString(string: dateString, attributes: dateAttributes)
        if let time = timeString {
            let timeAttributedString = NSAttributedString(string: "  " + time, attributes: timeAttributes)
            attributedText.append(timeAttributedString)
        }

        self.attributedText = attributedText
    }
}
func getFileIconName(for fileURL: URL) -> String {
    let ext = fileURL.pathExtension.lowercased()

    switch ext {
    case "jpg", "jpeg", "png", "gif", "heic", "heif":
        return "image"              // 🖼 Your image icon name
    case "pdf":
        return "pdf (1)"            // 📄 Your PDF icon name
    case "doc", "docx":
        return "microsoft-word"     // 📃 Word icon
    case "xls", "xlsx":
        return "exel"               // 📊 Excel icon
    case "ppt", "pptx":
        return "ppt"                // 📽 PowerPoint icon
    default:
        return "txt-file"  // 🔄 Fallback icon
    }
}
extension String {
    func convertToTargetDateFormat(inputFormat: String? = nil) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let possibleFormats = [
            "yyyy-MM-dd",
            "dd/MM/yyyy",
            "MM/dd/yyyy",
            "yyyy/MM/dd",
            "d MMM yyyy",
            "dd MMM yyyy",
            "yyyy-MM-dd HH:mm:ss",
            "MMM d, yyyy",
            "EEE, d MMM yyyy"
        ]
        
        if let inputFormat = inputFormat {
            dateFormatter.dateFormat = inputFormat
            if let date = dateFormatter.date(from: self) {
                dateFormatter.dateFormat = "E d MMM yyyy"
                return dateFormatter.string(from: date)
            } else {
                return nil
            }
        } else {
            for format in possibleFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: self) {
                    dateFormatter.dateFormat = "E d MMM yyyy"
                    return dateFormatter.string(from: date)
                }
            }
            return nil
        }
    }
}

func convertDate(_ dateString: String, toFormat: String = "dd-MM-yyyy") -> String? {
    let possibleFormats = [
        "yyyy-MM-dd",
        "dd/MM/yyyy",
        "MM/dd/yyyy",
        "yyyy/MM/dd",
        "d MMM yyyy",
        "dd MMM yyyy",
        "yyyy-MM-dd HH:mm:ss",
        "MMM d, yyyy",
        "EEE, d MMM yyyy"
    ]

    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Safe for parsing known formats

    for format in possibleFormats {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = toFormat
            return dateFormatter.string(from: date)
        }
    }
    return nil
}

