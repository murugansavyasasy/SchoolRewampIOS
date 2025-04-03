//
//  Extentions.swift
//  VsSchoolChimes
//
//  Created by admin on 26/02/25.
//

import Foundation
import UIKit
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
        self.backgroundColor = .button
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
        guard let attributedText = label.attributedText else { return false }
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let location = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (label.bounds.width - textBoundingBox.width) * 0.5 - textBoundingBox.origin.x, y: (label.bounds.height - textBoundingBox.height) * 0.5 - textBoundingBox.origin.y)
        let locationInTextContainer = CGPoint(x: location.x - textContainerOffset.x, y: location.y - textContainerOffset.y)
        
        let characterIndex = layoutManager.characterIndex(for: locationInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(characterIndex, targetRange)
    }
}
extension String {
    func removingSlashComponent() -> String {
        let components = self.split(separator: "/").map { String($0) }
        return components.joined(separator: "")
    }
}
