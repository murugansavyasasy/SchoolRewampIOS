//
//  UILabel.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import Foundation
import UIKit



public protocol Localizable {

    var localized: String { get }

}



extension String: Localizable {

    public var localized: String {

        return NSLocalizedString(self, comment: "")

    }

}



// MARK: XIBLocalizable

public protocol XIBLocalizable {

    var localeKey: String? { get set }

}



extension UILabel: XIBLocalizable {

    @IBInspectable public var localeKey: String? {

        get { return nil }

        set(key) {

            text = key?.localized

        }

    }

}
