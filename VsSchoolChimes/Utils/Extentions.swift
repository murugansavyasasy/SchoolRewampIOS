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
//            label.textAlignment = isRTL ? .left : .right
            label.textAlignment = (label.textAlignment == .left) ? .right : .left
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

