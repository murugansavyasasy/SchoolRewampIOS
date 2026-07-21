//
//  Fonts.swift
//  VsSchoolChimes
//
//  Created by admin on 27/11/24.
//

import Foundation
import UIKit

extension UILabel {
    enum LabelStyle {
        case header
        case title
        case body
    }
    
    func setFont(style: LabelStyle, size: CGFloat? = nil) {
        switch style {
            
        case .header:
            self.font = UIFont(name: "Poppins-Bold", size: size ?? self.font.pointSize)
            ?? UIFont.systemFont(ofSize: size ?? self.font.pointSize, weight: .bold)
            if font == nil{
                print("Poppins bold not available")
            }
        case .title:
            self.font = UIFont(name: "Poppins-Bold", size: size ?? self.font.pointSize)
            ?? UIFont.systemFont(ofSize: size ?? self.font.pointSize, weight: .bold)
        case .body:
            self.font = UIFont(name: "Poppins-Medium", size: size ?? self.font.pointSize)
            ?? UIFont.systemFont(ofSize: size ?? self.font.pointSize, weight: .medium)
        }
    }
}



extension UIButton {
    enum ButtonStyle {
        case primary
        case secondary
        case body
    }
    
    func setTitleFont(style: ButtonStyle, size: CGFloat? = nil) {
        let defaultSize = size ?? self.titleLabel?.font.pointSize ?? 17
        
        switch style {
        case .primary:
            let font = UIFont(name: "Poppins-Bold", size: defaultSize)
            if font != nil {
                self.titleLabel?.font = font
            } else {
                print("Poppins-Bold font not found. Using system font.")
                self.titleLabel?.font = UIFont.systemFont(ofSize: defaultSize, weight: .bold)
            }
        case .secondary:
            let font = UIFont(name: "Poppins-Medium", size: defaultSize)
            if font != nil {
                self.titleLabel?.font = font
            } else {
                print("Poppins-Regular font not found. Using system font.")
                self.titleLabel?.font = UIFont.systemFont(ofSize: defaultSize, weight: .regular)
            }
        case .body:
            let font = UIFont(name: "Poppins-Medium", size: defaultSize)
            if font != nil {
                self.titleLabel?.font = font
            } else {
                print("Poppins-Medium font not found. Using system font.")
                self.titleLabel?.font = UIFont.systemFont(ofSize: defaultSize, weight: .medium)
            }
        }
    }
}

class FontSize {
    
    static var HeaderSize : CGFloat = 15//20
    static var TitleSize : CGFloat = 14
    static var Twelve : CGFloat = 12
    static var BodySize : CGFloat = 13
}
