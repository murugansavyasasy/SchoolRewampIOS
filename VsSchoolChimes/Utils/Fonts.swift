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
        case .title:
            self.font = UIFont(name: "Poppins-Bold", size: size ?? self.font.pointSize)
                ?? UIFont.systemFont(ofSize: size ?? self.font.pointSize, weight: .bold)
        case .body:
            self.font = UIFont(name: "Poppins-Medium", size: size ?? self.font.pointSize)
                ?? UIFont.systemFont(ofSize: size ?? self.font.pointSize, weight: .medium)
        }
    }
}
