//
//  ColourManager.swift
//  VsSchoolChimes
//
//  Created by Admin on 13/02/25.
//

import Foundation
import UIKit

class ColorManager {
    static let shared = ColorManager() // Singleton instance

    let letterColors: [Character: UIColor] = [
        "A": UIColor(hex: "#FFB6C1"), // Light Pink
        "B": UIColor(hex: "#FFDAB9"), // Peach Puff
        "C": UIColor(hex: "#E6E6FA"), // Lavender
        "D": UIColor(hex: "#D8BFD8"), // Thistle
        "E": UIColor(hex: "#FAEBD7"), // Antique White
        "F": UIColor(hex: "#FFE4B5"), // Moccasin
        "G": UIColor(hex: "#98FB98"), // Pale Green
        "H": UIColor(hex: "#AFEEEE"), // Pale Turquoise
        "I": UIColor(hex: "#F5DEB3"), // Wheat
        "J": UIColor(hex: "#DDA0DD"), // Plum
        "K": UIColor(hex: "#B0E0E6"), // Powder Blue
        "L": UIColor(hex: "#F08080"), // Light Coral
        "M": UIColor(hex: "#E0FFFF"), // Light Cyan
        "N": UIColor(hex: "#FFD700"), // Gold
        "O": UIColor(hex: "#87CEFA"), // Light Sky Blue
        "P": UIColor(hex: "#FFB6C1"), // Light Pink
        "Q": UIColor(hex: "#FFEFD5"), // Papaya Whip
        "R": UIColor(hex: "#E6E6FA"), // Lavender
        "S": UIColor(hex: "#F5F5DC"), // Beige
        "T": UIColor(hex: "#B0C4DE"), // Light Steel Blue
        "U": UIColor(hex: "#FAFAD2"), // Light Goldenrod Yellow
        "V": UIColor(hex: "#D8BFD8"), // Thistle
        "W": UIColor(hex: "#FFFACD"), // Lemon Chiffon
        "X": UIColor(hex: "#F0E68C"), // Khaki
        "Y": UIColor(hex: "#E0FFFF"), // Light Cyan
        "Z": UIColor(hex: "#C8A2C8")  // Lilac
    ]

    private init() {} // Private initializer prevents multiple instances
}
