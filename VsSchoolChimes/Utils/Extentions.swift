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
import AVFoundation
import AVKit
@available(iOS 15.0, *)
fileprivate var lottieView: LottieAnimationView?
fileprivate var lottieOverlay: UIView?

@available(iOS 15.0, *)
fileprivate var loaderContainerView: UIView?
@available(iOS 15.0, *)
fileprivate var loaderAnimationView: LottieAnimationView?
private var loaderBackgroundView: UIView?
let YOUR_VIMEO_TOKEN = "8d74d8bf6b5742d39971cc7d3ffbb51a"
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
func setAttributedText(for label: UILabel, with text: String, firstString: String, secondString: String, color1: UIColor, color2: UIColor) {
    print(text)
    print(firstString)
    print(secondString)
    guard text.contains(firstString), text.contains(secondString) else { return } // Ensure both substrings exist in the text
    
    // Find ranges of the substrings
    let firstRange = (text as NSString).range(of: firstString)
    let secondRange = (text as NSString).range(of: secondString)
    
    // Create a mutable attributed string
    let attributedString = NSMutableAttributedString(string: text)
    
    // Apply colors to the respective ranges
    attributedString.addAttribute(.foregroundColor, value: color1, range: firstRange)
    attributedString.addAttribute(.foregroundColor, value: color2, range: secondRange)
    
    // Set the attributed string to the label
    label.attributedText = attributedString
}

private var loaderActivityIndicator: UIActivityIndicatorView?
var backgroundView: UIView?
import ObjectiveC
@available(iOS 15.0, *)
extension UIViewController {
    // Keep a static dictionary to store loader views per VC
        private static var loaders: [ObjectIdentifier: UIView] = [:]
        
        func showActivityLoader() {
            DispatchQueue.main.async {
                let id = ObjectIdentifier(self)
                if UIViewController.loaders[id] != nil { return } // already showing
                
                guard let window = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first?.keyWindow else { return }
                
                // Fullscreen background
                let bg = UIView(frame: window.bounds)
                bg.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                
                // Lottie animation
                let animationView = LottieAnimationView(name: "loader (2)")
                animationView.loopMode = .loop
                animationView.translatesAutoresizingMaskIntoConstraints = false
                bg.addSubview(animationView)
                
                NSLayoutConstraint.activate([
                    animationView.centerXAnchor.constraint(equalTo: bg.centerXAnchor),
                    animationView.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
                    animationView.widthAnchor.constraint(equalToConstant: 120),
                    animationView.heightAnchor.constraint(equalToConstant: 120)
                ])
                
                animationView.play()
                
                window.addSubview(bg)
                window.bringSubviewToFront(bg)
                
                // Save reference
                UIViewController.loaders[id] = bg
            }
        }
        
        func hideActivityLoader() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                let id = ObjectIdentifier(self)
                UIViewController.loaders[id]?.removeFromSuperview()
                UIViewController.loaders[id] = nil
            }
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
                // Animate stroke for circle
                CATransaction.begin()
                CATransaction.setDisableActions(false)
                CATransaction.setAnimationDuration(0.2)
                self.progressLayer.strokeEnd = CGFloat(stroke)
                CATransaction.commit()
            } else {
                // Update bar path manually for rectangle style
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
 class ExpandableLabelState {
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
extension UIView {
    func addTopAndBottomBorders(color: UIColor, thickness: CGFloat = 0.2) {
        // Remove old borders (if any)
        self.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }

        let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: thickness))
        topBorder.backgroundColor = color
        topBorder.tag = 999
        self.addSubview(topBorder)

        let bottomBorder = UIView(frame: CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness))
        bottomBorder.backgroundColor = color
        bottomBorder.tag = 999
        self.addSubview(bottomBorder)
    }
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
    case "jpg", "jpeg", "png", "gif", "heic", "heif", "webp":
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
        return "video (1)"  // 🔄 Fallback icon
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
            "EEE, d MMM yyyy",
            "dd-MM-yyyy hh:mm a"
        ]
        
        if let inputFormat = inputFormat {
            dateFormatter.dateFormat = inputFormat
            if let date = dateFormatter.date(from: self) {
                dateFormatter.dateFormat = "dd MMM yyyy"
                return dateFormatter.string(from: date)
            } else {
                return nil
            }
        } else {
            for format in possibleFormats {
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: self) {
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    return dateFormatter.string(from: date)
                }
            }
            return nil
        }
    }
}
func parseDate(from dateString: String, format: String = "dd-MM-yyyy") -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.timeZone = .current
    return formatter.date(from: dateString)
}

func getDateRangeLabel(from fromDate: Date, to toDate: Date) -> String {
    let calendar = Calendar.current
    let today = Date()
    
    let fromDay = calendar.startOfDay(for: fromDate)
    let toDay = calendar.startOfDay(for: toDate)
    let todayDay = calendar.startOfDay(for: today)
    
    // Ensure range ends today
    guard toDay == todayDay else {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: fromDate)) - \(formatter.string(from: toDate))"
    }
    
    // Get difference in components
    let days = calendar.dateComponents([.day], from: fromDay, to: todayDay).day ?? 0
    let weeks = calendar.dateComponents([.weekOfYear], from: fromDay, to: todayDay).weekOfYear ?? 0
    let months = calendar.dateComponents([.month], from: fromDay, to: todayDay).month ?? 0
    let years = calendar.dateComponents([.year], from: fromDay, to: todayDay).year ?? 0
    
    // Logic
    if days == 0 {
        return "Today"
    } else if days < 7 {
        return "Last \(days + 1) Days"
    } else if weeks < 4 {
        return "Last \(weeks) Week" + (weeks > 1 ? "s" : "")
    } else if months < 12 {
        return "Last \(months) Month" + (months > 1 ? "s" : "")
    } else {
        return "Last \(years) Year" + (years > 1 ? "s" : "")
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
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    for format in possibleFormats {
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = toFormat
            return dateFormatter.string(from: date)
        }
    }
    return nil
}

public class ViewAnimator {
    
    // MARK: - Smooth Fade In
    public static func showFade(_ view: UIView, duration: TimeInterval = 0.3) {
        view.isHidden = false
        view.alpha = 0
        UIView.animate(withDuration: duration) {
            view.alpha = 1
        }
    }
    
    // MARK: - Smooth Fade Out
    public static func hideFade(_ view: UIView, duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0
        }) { _ in
            view.isHidden = true
        }
    }
    
    // MARK: - Slide and Fade In
    public static func showSlideFade(_ view: UIView, duration: TimeInterval = 0.4) {
        view.isHidden = false
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: -20)
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
            view.alpha = 1
            view.transform = .identity
        })
    }
    
    // MARK: - Slide and Fade Out
    public static func hideSlideFade(_ view: UIView, duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: -20)
        }, completion: { _ in
            view.isHidden = true
            view.transform = .identity
        })
    }
    
    public static func animateConstraintChange(duration: TimeInterval = 0.3, animations: @escaping () -> Void) {
        UIView.animate(withDuration: duration, animations: {
            animations()
        })
    }
    
    
}

extension UIView {
    func fadeAndPopIn(duration: TimeInterval = 0.25) {
        self.alpha = 0
        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        self.isHidden = false
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut]) {
            self.alpha = 1
            self.transform = .identity
        }
    }
}


class DateFormatterHelper {
    static let shared = DateFormatterHelper()
    private init() {}
    
    private let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        return formatter
    }()
    
    private let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    private let outputTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()
    
    func parseDate(from string: String) -> Date? {
        return inputFormatter.date(from: string)
    }
    
    func formatDateToDayMonthYear(date: Date) -> String {
        return outputDateFormatter.string(from: date)
    }
    
    func formatTime(date: Date) -> String {
        return outputTimeFormatter.string(from: date)
    }
}
func isDueDatePassed(dueDate: String) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"
    guard let dueDateObject = dateFormatter.date(from: dueDate) else {
        print("Invalid date format")
        return false
    }
    let currentDate = Calendar.current.startOfDay(for: Date())
    
    // Compare dueDate with currentDate
    return dueDateObject < currentDate
}
func extractVimeoID(from url: String) -> String? {
    let pattern = #"(\d+)$"#
    
    if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
        let nsString = url as NSString
        let range = NSRange(location: 0, length: nsString.length)
        
        if let match = regex.firstMatch(in: url, options: [], range: range) {
            let id = nsString.substring(with: match.range(at: 1))
            return id
        }
    }
    return nil
}
func fetchVimeoVideoFiles(videoID: String, accessToken: String, completion: @escaping ([String]) -> Void) {
    let urlString = "https://api.vimeo.com/videos/\(videoID)"
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        completion([])
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Network error: \(error.localizedDescription)")
            DispatchQueue.main.async { completion([]) }
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Invalid response from Vimeo")
            DispatchQueue.main.async { completion([]) }
            return
        }

        guard let data = data,
              let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let files = jsonObject["files"] as? [[String: Any]] else {
            print("Error parsing JSON or missing 'files'")
            DispatchQueue.main.async { completion([]) }
            return
        }

        let videoURLs = files.compactMap { $0["link"] as? String }
        DispatchQueue.main.async { completion(videoURLs) }
    }.resume()
}

func loadVimeoThumbnail(from url: String, accessToken: String, completion: @escaping (UIImage?) -> Void) {
    guard let videoID = extractVimeoID(from: url) else {
        completion(nil)
        return
    }

    let apiURL = URL(string: "https://api.vimeo.com/videos/\(videoID)")!
    var request = URLRequest(url: apiURL)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Vimeo API error: \(error.localizedDescription)")
            completion(nil)
            return
        }

        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let pictures = json["pictures"] as? [String: Any],
              let sizes = pictures["sizes"] as? [[String: Any]],
              let last = sizes.last,
              let thumbnailURLString = last["link"] as? String,
              let thumbnailURL = URL(string: thumbnailURLString) else {
            print("Failed to parse thumbnail")
            completion(nil)
            return
        }

        // Download thumbnail image
        URLSession.shared.dataTask(with: thumbnailURL) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                print("Failed to load image data")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }.resume()
}

extension UILabel {
    func setRequiredText(_ text: String, asteriskColor: UIColor = .red) {
        // Main label font: Poppins-Bold, size 14
        let mainFont = UIFont(name: "Poppins-Bold", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)

        // Asterisk font: Poppins-Regular, larger size
        let asteriskFont = UIFont(name: "Poppins-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .regular)

        let normalText = NSAttributedString(
            string: text,
            attributes: [
                .font: mainFont,
                .foregroundColor: self.textColor ?? .black
            ])

        let asteriskText = NSAttributedString(
            string: "*",
            attributes: [
                .font: asteriskFont,
                .foregroundColor: asteriskColor,
                .baselineOffset: 2 // tweak to align nicely with main text
            ])

        let combined = NSMutableAttributedString()
        combined.append(normalText)
        combined.append(asteriskText)

        self.attributedText = combined
    }
    func profilesetRequiredText(_ text: String, asteriskColor: UIColor = .red) {

        // Asterisk font: Poppins-Regular, larger size
        let asteriskFont = UIFont(name: "Poppins-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .regular)

        let normalText = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: self.textColor ?? .black
            ])

        let asteriskText = NSAttributedString(
            string: "*",
            attributes: [
                .font: asteriskFont,
                .foregroundColor: asteriskColor,
                .baselineOffset: 2 // tweak to align nicely with main text
            ])

        let combined = NSMutableAttributedString()
        combined.append(normalText)
        combined.append(asteriskText)

        self.attributedText = combined
    }
}
class BottomRoundedView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCorners()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCorners()
    }
    
    private func setupCorners() {
        self.layer.cornerRadius = 20
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // bottom left + bottom right
        self.clipsToBounds = true
    }
}

