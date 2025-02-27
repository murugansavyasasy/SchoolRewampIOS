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
