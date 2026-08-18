import UIKit

class LineChartViews: UIView {
    
    // MARK: - Properties
    private var examTotals: [(label: String, total: CGFloat)] = []
    
    private let maxScore: CGFloat = 100.0
    private let minScore: CGFloat = 0.0
    
    // MARK: - Configuration
    func configure(with examTotals: [(label: String, total: CGFloat)]) {
        self.examTotals = examTotals
        setNeedsDisplay()
    }
    
    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !examTotals.isEmpty else { return }
        
        let context = UIGraphicsGetCurrentContext()
        
        let paddingLeft: CGFloat = 35
        let paddingRight: CGFloat = 20
        let paddingTop: CGFloat = 25
        let paddingBottom: CGFloat = 35
        
        let chartWidth = bounds.width - paddingLeft - paddingRight
        let chartHeight = bounds.height - paddingTop - paddingBottom
        
        // 1. Draw dashed Y Grid lines (0, 20, 40, 60, 80, 100)
        let gridValues: [CGFloat] = [0, 20, 40, 60, 80, 100]
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor(red: 0.35, green: 0.45, blue: 0.56, alpha: 1.0)
        ]
        
        for gridVal in gridValues {
            let ratio = (gridVal - minScore) / (maxScore - minScore)
            let y = bounds.height - paddingBottom - (chartHeight * ratio)
            
            // Draw grid line
            context?.saveGState()
            context?.setStrokeColor(UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0).cgColor)
            context?.setLineWidth(0.8)
            
            if gridVal == 100 {
                // Red Max line
                context?.setStrokeColor(UIColor(red: 0.94, green: 0.27, blue: 0.22, alpha: 0.6).cgColor)
                context?.setLineWidth(1.0)
            }
            context?.setLineDash(phase: 0, lengths: [4, 4])
            context?.move(to: CGPoint(x: paddingLeft, y: y))
            context?.addLine(to: CGPoint(x: bounds.width - paddingRight, y: y))
            context?.strokePath()
            context?.restoreGState()
            
            // Label text
            var labelStr = "\(Int(gridVal))"
            if gridVal == 100 {
                labelStr = "100"
            }
            let size = labelStr.size(withAttributes: labelAttributes)
            let textRect = CGRect(x: paddingLeft - size.width - 6, y: y - size.height / 2, width: size.width, height: size.height)
            labelStr.draw(in: textRect, withAttributes: labelAttributes)
            
            // Draw "Max (100)" text on the guideline
            if gridVal == 100 {
                let maxAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9, weight: .bold),
                    .foregroundColor: UIColor(red: 0.94, green: 0.27, blue: 0.22, alpha: 0.8)
                ]
                let maxStr = "Max (100)"
                let maxStrSize = maxStr.size(withAttributes: maxAttributes)
                maxStr.draw(at: CGPoint(x: bounds.width/2 - maxStrSize.width/2, y: y - maxStrSize.height - 2), withAttributes: maxAttributes)
            }
        }
        
        // 2. Draw Trend Line and Nodes
        var points: [CGPoint] = []
        let segmentWidth = chartWidth / CGFloat(max(1, examTotals.count - 1))
        
        for (i, item) in examTotals.enumerated() {
            let x = paddingLeft + (CGFloat(i) * segmentWidth)
            let clampedTotal = max(minScore, min(maxScore, item.total))
            let ratio = (clampedTotal - minScore) / (maxScore - minScore)
            let y = bounds.height - paddingBottom - (chartHeight * ratio)
            points.append(CGPoint(x: x, y: y))
        }
        
        if points.count > 1 {
            // Draw line curve
            let linePath = UIBezierPath()
            linePath.move(to: points[0])
            for i in 1..<points.count {
                linePath.addLine(to: points[i])
            }
            
            context?.saveGState()
            context?.setStrokeColor(UIColor(red: 0.05, green: 0.14, blue: 0.23, alpha: 1.0).cgColor)
            context?.setLineWidth(2.5)
            context?.setLineJoin(.round)
            context?.addPath(linePath.cgPath)
            context?.strokePath()
            context?.restoreGState()
        }
        
        // 3. Draw Dots and Value Labels
        for (i, point) in points.enumerated() {
            // Dot
            context?.saveGState()
            context?.setFillColor(UIColor.white.cgColor)
            context?.setStrokeColor(UIColor(red: 0.05, green: 0.14, blue: 0.23, alpha: 1.0).cgColor)
            context?.setLineWidth(2.0)
            
            let radius: CGFloat = 4.5
            let dotRect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
            context?.fillEllipse(in: dotRect)
            context?.strokeEllipse(in: dotRect)
            context?.restoreGState()
            
            // Value Label
            let totalVal = examTotals[i].total
            let valStr = "\(Int(totalVal))"
            let valAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                .foregroundColor: UIColor(red: 0.11, green: 0.44, blue: 0.95, alpha: 1.0)
            ]
            let valSize = valStr.size(withAttributes: valAttributes)
            valStr.draw(at: CGPoint(x: point.x - valSize.width / 2, y: point.y - valSize.height - 4), withAttributes: valAttributes)
            
            // Draw Exam Label X-Axis (alternating to prevent overlap)
            let examLabel = examTotals[i].label
            
            let examSize = examLabel.size(withAttributes: labelAttributes)
            let yOffset: CGFloat = (i % 2 == 0) ? 8.0 : 18.0
            examLabel.draw(at: CGPoint(x: point.x - examSize.width / 2, y: bounds.height - paddingBottom + yOffset), withAttributes: labelAttributes)
        }
        
        // 4. Draw Axis Lines
        context?.setStrokeColor(UIColor(red: 0.68, green: 0.72, blue: 0.78, alpha: 1.0).cgColor)
        context?.setLineWidth(1.0)
        // X line
        context?.move(to: CGPoint(x: paddingLeft, y: bounds.height - paddingBottom))
        context?.addLine(to: CGPoint(x: bounds.width - paddingRight, y: bounds.height - paddingBottom))
        // Y line
        context?.move(to: CGPoint(x: paddingLeft, y: paddingTop))
        context?.addLine(to: CGPoint(x: paddingLeft, y: bounds.height - paddingBottom))
        context?.strokePath()
    }
}
