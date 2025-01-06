//
//  RibbonView.swift
//  VsSchoolChimes
//
//  Created by admin on 30/12/24.
//

import UIKit

class RibbonView: UIView {

    override func draw(_ rect: CGRect) {
        // Define constants
        let ribbonColor = UIColor.red
        let cornerRadius: CGFloat = 8
        let ribbonHeight: CGFloat = 50
        let foldedWidth: CGFloat = 20
        let curveOffset: CGFloat = 10

        // Draw the main rectangle
        let mainRect = CGRect(x: foldedWidth, y: 0, width: rect.width - (foldedWidth * 2), height: ribbonHeight)
        let mainPath = UIBezierPath(roundedRect: mainRect, cornerRadius: cornerRadius)
        ribbonColor.setFill()
        mainPath.fill()

        // Draw the left folded part
        let leftFoldPath = UIBezierPath()
        leftFoldPath.move(to: CGPoint(x: 0, y: 0))
        leftFoldPath.addLine(to: CGPoint(x: foldedWidth, y: 0))
        leftFoldPath.addQuadCurve(to: CGPoint(x: 0, y: ribbonHeight), controlPoint: CGPoint(x: foldedWidth / 2, y: ribbonHeight + curveOffset))
        leftFoldPath.close()
        ribbonColor.setFill()
        leftFoldPath.fill()

        // Draw the right folded part
        let rightFoldPath = UIBezierPath()
        rightFoldPath.move(to: CGPoint(x: rect.width, y: 0))
        rightFoldPath.addLine(to: CGPoint(x: rect.width - foldedWidth, y: 0))
        rightFoldPath.addQuadCurve(to: CGPoint(x: rect.width, y: ribbonHeight), controlPoint: CGPoint(x: rect.width - foldedWidth / 2, y: ribbonHeight + curveOffset))
        rightFoldPath.close()
        ribbonColor.setFill()
        rightFoldPath.fill()

        // Add "NEW" text in the center
        let text = "NEW"
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.white
        ]
        let textSize = text.size(withAttributes: textAttributes)
        let textRect = CGRect(
            x: mainRect.midX - textSize.width / 2,
            y: mainRect.midY - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: textAttributes)
    }
}
