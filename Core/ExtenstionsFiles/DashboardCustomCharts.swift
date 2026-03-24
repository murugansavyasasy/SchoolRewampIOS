import UIKit

class DonutChartView: UIView {
    var presentValue: Int = 18
    var absentValue: Int = 3
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let total = CGFloat(presentValue + absentValue)
        guard total > 0 else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius: CGFloat = min(bounds.width, bounds.height) / 2 - 10
        let lineWidth: CGFloat = 26
        
        let presentAngle = (CGFloat(presentValue) / total) * 2 * .pi
        let startAngle: CGFloat = -.pi / 2
        
        let presentPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: startAngle + presentAngle, clockwise: true)
        let presentLayer = CAShapeLayer()
        presentLayer.path = presentPath.cgPath
        presentLayer.fillColor = UIColor.clear.cgColor
        presentLayer.strokeColor = UIColor.systemGreen.cgColor
        presentLayer.lineWidth = lineWidth
        self.layer.addSublayer(presentLayer)
        
        let gap: CGFloat = 0.1
        let absentStart = startAngle + presentAngle + gap
        let absentEnd = startAngle + 2 * .pi - gap
        
        if absentValue > 0 {
            let absentPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: absentStart, endAngle: absentEnd, clockwise: true)
            let absentLayer = CAShapeLayer()
            absentLayer.path = absentPath.cgPath
            absentLayer.fillColor = UIColor.clear.cgColor
            absentLayer.strokeColor = UIColor.systemRed.cgColor
            absentLayer.lineWidth = lineWidth
            self.layer.addSublayer(absentLayer)
        }
    }
}

class SimpleBarChartView: UIView {
    var dataPoints: [(title: String, presentCount: Int, absentCount: Int)] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        setupChart()
    }
    
    func setupChart() {
        guard !dataPoints.isEmpty else { return }
        let maxY = max(8, (dataPoints.max(by: { max($0.presentCount, $0.absentCount) < max($1.presentCount, $1.absentCount) }).map { max($0.presentCount, $0.absentCount) } ?? 8) + 2)
        
        let chartBottom: CGFloat = bounds.height - 30
        let chartLeft: CGFloat = 30
        
        // Draw Y Axis and lines
        for i in 0...4 {
            let val = (CGFloat(i) / 4.0) * CGFloat(maxY)
            let yPos = chartBottom - (chartBottom * CGFloat(i) / 4.0)
            
            // Grid line
             let line = CAShapeLayer()
             let path = UIBezierPath()
             path.move(to: CGPoint(x: chartLeft, y: yPos))
             path.addLine(to: CGPoint(x: bounds.width, y: yPos))
             line.path = path.cgPath
             line.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
             line.lineWidth = 1
             line.lineDashPattern = [4, 4]
             layer.addSublayer(line)
             
             // Label
             let label = CATextLayer()
             label.string = "\(Int(val))"
             label.fontSize = 12
             label.foregroundColor = UIColor.darkGray.cgColor
             label.frame = CGRect(x: 0, y: yPos - 8, width: chartLeft - 5, height: 16)
             label.alignmentMode = .right
             label.contentsScale = UIScreen.main.scale
             layer.addSublayer(label)
        }
        
        // Base line
        let baseLine = CAShapeLayer()
        let bPath = UIBezierPath()
        bPath.move(to: CGPoint(x: chartLeft, y: chartBottom))
        bPath.addLine(to: CGPoint(x: bounds.width, y: chartBottom))
        baseLine.path = bPath.cgPath
        baseLine.strokeColor = UIColor.gray.cgColor
        baseLine.lineWidth = 1
        layer.addSublayer(baseLine)
        
        // Draw bars
        let barWidth: CGFloat = 20
        let spacing: CGFloat = (bounds.width - chartLeft - CGFloat(dataPoints.count) * barWidth) / CGFloat(dataPoints.count + 1)
        
        for (idx, point) in dataPoints.enumerated() {
            let xPos = chartLeft + spacing + CGFloat(idx) * (barWidth + spacing)
            let presentHeight = (CGFloat(point.presentCount) / CGFloat(maxY)) * chartBottom
            let absentHeight = (CGFloat(point.absentCount) / CGFloat(maxY)) * chartBottom
            
            // Draw absent as main red block (based on image)
            let barLayer = CALayer()
            barLayer.backgroundColor = UIColor.systemRed.cgColor
            barLayer.frame = CGRect(x: xPos, y: chartBottom - absentHeight, width: barWidth, height: absentHeight)
            barLayer.cornerRadius = 4
            layer.addSublayer(barLayer)
            
            // Add label below
            let label = CATextLayer()
            label.string = point.title
            label.fontSize = 11
            label.foregroundColor = UIColor.darkGray.cgColor
            label.frame = CGRect(x: xPos - 20, y: chartBottom + 5, width: barWidth + 40, height: 16)
            label.alignmentMode = .center
            label.contentsScale = UIScreen.main.scale
            layer.addSublayer(label)
        }
    }
}

class SimpleLineChartView: UIView {
    var dataPoints: [(label: String, percentage: Double)] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        setupChart()
    }
    
    func setupChart() {
        guard !dataPoints.isEmpty else { return }
        
        let chartBottom: CGFloat = bounds.height - 30
        let chartLeft: CGFloat = 30
        
        // Grid
        for i in 0...4 {
            let val = [0, 25, 50, 75, 100][i]
            let yPos = chartBottom - (chartBottom * CGFloat(i) / 4.0)
            
            let line = CAShapeLayer()
            let path = UIBezierPath()
            path.move(to: CGPoint(x: chartLeft, y: yPos))
            path.addLine(to: CGPoint(x: bounds.width, y: yPos))
            line.path = path.cgPath
            line.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
            line.lineWidth = 1
            line.lineDashPattern = [4, 4]
            layer.addSublayer(line)
            
            let label = CATextLayer()
            label.string = "\(val)"
            label.fontSize = 11
            label.foregroundColor = UIColor.darkGray.cgColor
            label.frame = CGRect(x: 0, y: yPos - 8, width: chartLeft - 5, height: 14)
            label.alignmentMode = .right
            label.contentsScale = UIScreen.main.scale
            layer.addSublayer(label)
        }
        
        // Base line
        let baseLine = CAShapeLayer()
        let bPath = UIBezierPath()
        bPath.move(to: CGPoint(x: chartLeft, y: chartBottom))
        bPath.addLine(to: CGPoint(x: chartLeft, y: 0))
        baseLine.path = bPath.cgPath
        baseLine.strokeColor = UIColor.gray.cgColor
        baseLine.lineWidth = 1
        layer.addSublayer(baseLine)
        
        // Points Calculation
        let spacing: CGFloat = (bounds.width - chartLeft - 20) / CGFloat(max(1, dataPoints.count - 1))
        var cgPoints: [CGPoint] = []
        
        for (idx, point) in dataPoints.enumerated() {
            let xPos = chartLeft + 10 + CGFloat(idx) * spacing
            let yPos = chartBottom - (CGFloat(point.percentage) / 100.0) * chartBottom
            cgPoints.append(CGPoint(x: xPos, y: yPos))
            
            let label = CATextLayer()
            label.string = point.label
            label.fontSize = 11
            label.foregroundColor = UIColor.darkGray.cgColor
            label.frame = CGRect(x: xPos - 20, y: chartBottom + 5, width: 40, height: 14)
            label.alignmentMode = .center
            label.contentsScale = UIScreen.main.scale
            layer.addSublayer(label)
        }
        
        // Draw Path (Smooth)
        let linePath = UIBezierPath()
        if let first = cgPoints.first {
            linePath.move(to: first)
            for i in 1..<cgPoints.count {
                let current = cgPoints[i]
                linePath.addLine(to: current)
            }
        }
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = UIColor.systemBlue.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 3
        layer.addSublayer(lineLayer)
        
        // Draw Dots
        for pt in cgPoints {
            let dot = CALayer()
            dot.backgroundColor = UIColor.systemBlue.cgColor
            dot.frame = CGRect(x: pt.x - 4, y: pt.y - 4, width: 8, height: 8)
            dot.cornerRadius = 4
            layer.addSublayer(dot)
        }
    }
}

class SolidPieChartView: UIView {
    var accepted: CGFloat = 10
    var pending: CGFloat = 10
    var declined: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let total = accepted + pending + declined
        guard total > 0 else { return }
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        
        var startAngle: CGFloat = -.pi / 2
        
        let pieces: [(CGFloat, UIColor, String)] = [
            (accepted, .systemGreen, "Act"),
            (pending, .systemOrange, "Pen"),
            (declined, .systemRed, "Dec")
        ]
        
        for (value, color, labelText) in pieces {
            if value <= 0 { continue }
            let angle = (value / total) * 2 * .pi
            let endAngle = startAngle + angle
            
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            path.close()
            
            let sliceLayer = CAShapeLayer()
            sliceLayer.path = path.cgPath
            sliceLayer.fillColor = color.cgColor
            sliceLayer.strokeColor = UIColor.white.cgColor // white divider lines
            sliceLayer.lineWidth = 2
            self.layer.addSublayer(sliceLayer)
            
            // Draw brief label simply in the center of the slice if possible
            let midAngle = startAngle + angle / 2
            let labelRadius = radius * 0.65 // place slightly past middle
            let actX = center.x + cos(midAngle) * labelRadius
            let actY = center.y + sin(midAngle) * labelRadius
            
            let textL = CATextLayer()
            textL.string = labelText
            textL.fontSize = 12
            textL.foregroundColor = UIColor.white.cgColor
            textL.alignmentMode = .center
            textL.frame = CGRect(x: actX - 15, y: actY - 8, width: 30, height: 16)
            textL.contentsScale = UIScreen.main.scale
            self.layer.addSublayer(textL)
            
            startAngle = endAngle
        }
    }
}
