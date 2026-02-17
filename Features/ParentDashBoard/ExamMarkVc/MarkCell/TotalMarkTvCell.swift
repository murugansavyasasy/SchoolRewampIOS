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
    @IBOutlet weak var ExamTitleLbl: UILabel!
    
    private var dotsAdded = false
    private let ringContainerLayer = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        CircleView.layer.cornerRadius = CircleView.frame.width / 2
        
        ExamTitleLbl.setFont(style: .header, size: FontSize.HeaderSize)
        obtainedMarkLbl.setFont(style: .header, size: 40)
        totalMarkLbl.setFont(style: .body, size: FontSize.BodySize)
        //        GradeLbl.setFont(style: .title, size: FontSize.TitleSize)
        //        RemarksLbl.setFont(style: .body, size: FontSize.BodySize)
        RemarksLbl.textColor = .parentClr
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        CircleView.layer.cornerRadius = CircleView.bounds.width / 2

        // Ensure container attached once
        if ringContainerLayer.superlayer == nil {
            contentView.layer.insertSublayer(ringContainerLayer, below: CircleView.layer)
        }

        // Match container frame
        ringContainerLayer.frame = contentView.bounds

        // Remove old dots (important for reuse + rotation)
        ringContainerLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        // Add rings
        addDotRing(dotCount: 36, radiusOffset: 20, dotSize: 5, color: .parentClr.withAlphaComponent(0.8))
        addDotRing(dotCount: 28, radiusOffset: 38, dotSize: 7, color: .parentClr.withAlphaComponent(0.6))
        addDotRing(dotCount: 20, radiusOffset: 55, dotSize: 9, color: .parentClr.withAlphaComponent(0.2))
    }

    
    private func addDotRing(
        dotCount: Int,
        radiusOffset: CGFloat,
        dotSize: CGFloat,
        color: UIColor
    ) {
        let center = CircleView.center
        let baseRadius = CircleView.bounds.width / 2
        let radius = baseRadius + radiusOffset
        
        for i in 0..<dotCount {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(dotCount))
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            
            let dot = CAShapeLayer()
            let dotPath = UIBezierPath(ovalIn: CGRect(origin: .zero,
                                                      size: CGSize(width: dotSize, height: dotSize)))
            dot.path = dotPath.cgPath
            dot.fillColor = color.cgColor
            dot.frame = CGRect(x: x - dotSize/2,
                               y: y - dotSize/2,
                               width: dotSize,
                               height: dotSize)
            
            ringContainerLayer.addSublayer(dot)
        }
    }
}
