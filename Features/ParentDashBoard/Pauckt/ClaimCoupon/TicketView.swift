//
//  TicketView.swift
//  VoicesnapSchoolApp
//
//  Created by Lakshmanan on 04/04/25.
//  Copyright © 2025 SchoolChimes. All rights reserved.
//

import Foundation
import UIKit

class CustomTicketView: UIView {
    
    private let cornerRadius: CGFloat = 20
    private let notchRadius: CGFloat = 15
    private let notchYFactor: CGFloat = 0.4  // Position of the notch as % from top
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShape()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShape()
    }
    
    private func setupShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createTicketPath().cgPath
        //shapeLayer.fillColor = UIColor(named: "TicketViewColour")?.cgColor
        shapeLayer.fillColor = UIColor.systemGray4.withAlphaComponent(0.3).cgColor
        shapeLayer.shadowColor = UIColor.white.cgColor
        shapeLayer.shadowOpacity = 0.2
        shapeLayer.shadowOffset = CGSize(width: 0, height: 4)
        shapeLayer.shadowRadius = 2
        layer.insertSublayer(shapeLayer, at: 0)
        
        addDashedLine()
    }
    
    private func createTicketPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        let notchY = height * notchYFactor

        path.move(to: CGPoint(x: cornerRadius, y: 0))
        
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        path.addArc(withCenter: CGPoint(x: width - cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: -CGFloat.pi / 2,
                    endAngle: 0,
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: width, y: notchY - notchRadius))
        path.addArc(withCenter: CGPoint(x: width, y: notchY),
                    radius: notchRadius,
                    startAngle: -CGFloat.pi / 2,
                    endAngle: CGFloat.pi / 2,
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        path.addArc(withCenter: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: 0,
                    endAngle: CGFloat.pi / 2,
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: cornerRadius, y: height))
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: height - cornerRadius),
                    radius: cornerRadius,
                    startAngle: CGFloat.pi / 2,
                    endAngle: CGFloat.pi,
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: 0, y: notchY + notchRadius))
        path.addArc(withCenter: CGPoint(x: 0, y: notchY),
                    radius: notchRadius,
                    startAngle: CGFloat.pi / 2,
                    endAngle: -CGFloat.pi / 2,
                    clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
                    radius: cornerRadius,
                    startAngle: CGFloat.pi,
                    endAngle: 3 * CGFloat.pi / 2,
                    clockwise: true)
        
        path.close()
        return path
    }

    private func addDashedLine() {
        let width = bounds.width
        let height = bounds.height
        let notchY = height * notchYFactor
        let padding: CGFloat = notchRadius + 8 // leave space after notches

        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: padding, y: notchY))
        linePath.addLine(to: CGPoint(x: width - padding, y: notchY))

        let dashLayer = CAShapeLayer()
        dashLayer.path = linePath.cgPath
        dashLayer.strokeColor = UIColor.gray.cgColor
        dashLayer.lineWidth = 1
        dashLayer.lineDashPattern = [6, 4] // dash-gap
        dashLayer.fillColor = nil

        layer.addSublayer(dashLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Remove all custom shape layers before redrawing
        layer.sublayers?.removeAll(where: { $0 is CAShapeLayer })
        setupShape()
    }
}
