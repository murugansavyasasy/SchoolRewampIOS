////
////  ApplyCustomFont.swift
////  VoicesnapSchoolApp
////
////  Created by Lakshmanan on 07/04/25.
////  Copyright © 2025 SchoolChimes. All rights reserved.
////
//
//import Foundation
//extension UILabel {
//    enum LabelStyle {
//        case header
//        case title
//        case body
//    }
//
//    func setFont(style: LabelStyle, size: CGFloat? = nil) {
//        switch style {
//          
//        case .header:
//            self.font = UIFont(name: "Gilroy-Bold", size: size ?? self.font.pointSize)
//                ?? UIFont.systemFont(ofSize: size ?? self.font.pointSize, weight: .bold)
//            if font == nil{
//                print("Gilroy-Bold not available")
//            }
//        case .title:
//            self.font = UIFont(name: "Gilroy-SemiBold", size: size ?? self.font.pointSize)
//                ?? UIFont.systemFont(ofSize: size ?? self.font.pointSize, weight: .bold)
//        case .body:
//            self.font = UIFont(name: "Gilroy-Regular", size: size ?? self.font.pointSize)
//                ?? UIFont.systemFont(ofSize: size ?? self.font.pointSize, weight: .medium)
//        }
//    }
//}
//
//
//
//extension UIButton {
//    enum ButtonStyle {
//        case primary
//        case secondary
//        case body
//    }
//
//    func setTitleFont(style: ButtonStyle, size: CGFloat? = nil) {
//        let defaultSize = size ?? self.titleLabel?.font.pointSize ?? 17
//
//        switch style {
//        case .primary:
//            let font = UIFont(name: "Gilroy-Bold", size: defaultSize)
//            if font != nil {
//                self.titleLabel?.font = font
//            } else {
//                print("Gilroy-Bold font not found. Using system font.")
//                self.titleLabel?.font = UIFont.systemFont(ofSize: defaultSize, weight: .bold)
//            }
//        case .secondary:
//            let font = UIFont(name: "Gilroy-SemiBold", size: defaultSize)
//            if font != nil {
//                self.titleLabel?.font = font
//            } else {
//                print("Gilroy_Semibold font not found. Using system font.")
//                self.titleLabel?.font = UIFont.systemFont(ofSize: defaultSize, weight: .regular)
//            }
//        case .body:
//            let font = UIFont(name: "Gilroy-Regular", size: defaultSize)
//            if font != nil {
//                self.titleLabel?.font = font
//            } else {
//                print("Gilroy-Regular font not found. Using system font.")
//                self.titleLabel?.font = UIFont.systemFont(ofSize: defaultSize, weight: .medium)
//            }
//        }
//    }
//}
//
//class FontSize {
//    
//    static var HeaderSize : CGFloat = 20
//    static var TitleSize : CGFloat = 18
//    static var BodySize : CGFloat = 14
//}
