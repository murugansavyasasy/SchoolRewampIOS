//
//  TotalMarkTvCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 22/07/25.
//

import UIKit

class TotalMarkTvCell: UITableViewCell {

    @IBOutlet weak var CircleView: UIView!
    @IBOutlet weak var obtainedMarkLbl: UILabel!
    @IBOutlet weak var totalMarkLbl: UILabel!
    @IBOutlet weak var GradeLbl: UILabel!
    @IBOutlet weak var RemarksLbl: UILabel!
    
    private var dotsAdded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        CircleView.layer.cornerRadius = CircleView.frame.width / 2
        
        obtainedMarkLbl.setFont(style: .header, size: 40)
        totalMarkLbl.setFont(style: .body, size: FontSize.BodySize)
        GradeLbl.setFont(style: .title, size: FontSize.TitleSize)
        RemarksLbl.setFont(style: .body, size: FontSize.BodySize)
        RemarksLbl.textColor = .dotColour
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
            super.layoutSubviews()

            // Only add dots once
        if !dotsAdded {
            addDotRing(around: CircleView, dotCount: 36, radiusOffset: 20, dotSize: 5, color: .dotColour.withAlphaComponent(0.8))
                   addDotRing(around: CircleView, dotCount: 28, radiusOffset: 38, dotSize: 7, color: .dotColour.withAlphaComponent(0.6))
                   addDotRing(around: CircleView, dotCount: 20, radiusOffset: 55, dotSize: 9, color: .dotColour.withAlphaComponent(0.2))
                   dotsAdded = true
               }
        }
    
    private func addDotRing(
        around view: UIView,
        dotCount: Int,
        radiusOffset: CGFloat,
        dotSize: CGFloat,
        color: UIColor
    ) {
        guard let containerLayer = view.superview?.layer else { return }
        guard let containerView = view.superview else { return }

        // Get actual center of the view relative to superview
        let centerInSuperview = containerView.convert(CGPoint(x: view.bounds.midX, y: view.bounds.midY), from: view)

        let radius = view.bounds.width / 2 + radiusOffset

        for i in 0..<dotCount {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(dotCount))
            let x = centerInSuperview.x + radius * cos(angle)
            let y = centerInSuperview.y + radius * sin(angle)

            let dot = CAShapeLayer()
            let dotPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: dotSize, height: dotSize)))
            dot.path = dotPath.cgPath
            dot.fillColor = color.cgColor//.withAlphaComponent(0.4).cgColor
            dot.frame = CGRect(x: x - dotSize / 2, y: y - dotSize / 2, width: dotSize, height: dotSize)
            dot.name = "backgroundDot"

            // Optional: fade-in animation
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = 0
            fade.toValue = 1
            fade.duration = 1.0
            fade.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            dot.add(fade, forKey: "fadeIn")

            containerLayer.insertSublayer(dot, below: view.layer)
        }
    }

}
