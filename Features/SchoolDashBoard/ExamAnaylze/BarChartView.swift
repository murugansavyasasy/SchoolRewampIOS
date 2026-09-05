import UIKit

extension UIColor {
    convenience init?(hexString: String) {
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
}

class BarChartViews: UIView {
    
    // MARK: - Properties
    private var subjects: [AnalysisSubject] = []
    private var selectedExamIds: [String] = [] // lowercased, spaces/hyphens removed
    private var examColorMap: [String: UIColor] = [:]
    
    private let defaultBarColor = UIColor(red: 0.11, green: 0.44, blue: 0.95, alpha: 1.0)
    
    private var yGridValues: [CGFloat] = [0, 20, 40, 60, 80, 100]
      private var maxYValue: CGFloat = 100.0
    
    // Tap selection callback
    struct BarHitArea {
        let frame: CGRect
        let subjectName: String
        let examName: String
        let mark: AnalysisSubjectMark
    }
    private var barHitAreas: [BarHitArea] = []
    var onBarTap: ((_ subjectName: String, _ examName: String, _ mark: AnalysisSubjectMark) -> Void)?
    // MARK: - Configuration
    func configure(with subjects: [AnalysisSubject], selectedExamIds: [String], examColorMap: [String: UIColor] = [:]) {
        self.subjects = subjects
        self.selectedExamIds = selectedExamIds
        self.examColorMap = examColorMap
        setupTapGesture()
        calculateYScale()
        setNeedsDisplay()
    }
    
    private func setupTapGesture() {
          if gestureRecognizers?.first(where: { $0 is UITapGestureRecognizer }) == nil {
              let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
              addGestureRecognizer(tap)
          }
      }
      
      @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
          let location = gesture.location(in: self)
          if let hit = barHitAreas.first(where: { $0.frame.contains(location) }) {
              onBarTap?(hit.subjectName, hit.examName, hit.mark)
          }
      }
      
    
    private func calculateYScale() {
        var maxObtained: CGFloat = 0.0
        var foundObtained = false
        
        for subject in subjects {
            let filteredMarks = selectedExamIds.isEmpty ? subject.marks : subject.marks.filter { mark in
                let normalizedId = mark.examName.lowercased()
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "-", with: "")
                return selectedExamIds.contains(normalizedId)
            }
            
            for mark in filteredMarks {
                if let obt = Double(mark.obtainedMark) {
                    maxObtained = max(maxObtained, CGFloat(obt))
                    foundObtained = true
                }
            }
        }
        
        let maxVal: CGFloat
        if foundObtained && maxObtained > 0 {
            maxVal = maxObtained
        } else {
            // Fallback to highest maxMark
            var maxLimit: CGFloat = 100.0
            for subject in subjects {
                let filteredMarks = selectedExamIds.isEmpty ? subject.marks : subject.marks.filter { mark in
                    let normalizedId = mark.examName.lowercased()
                        .replacingOccurrences(of: " ", with: "")
                        .replacingOccurrences(of: "-", with: "")
                    return selectedExamIds.contains(normalizedId)
                }
                for mark in filteredMarks {
                    if let maxM = Double(mark.maxMark) {
                        maxLimit = max(maxLimit, CGFloat(maxM))
                    }
                }
            }
            maxVal = maxLimit
        }
        
        // Compute clean steps of 5
        let steps = 5
        let rawStep = maxVal / CGFloat(steps)
        let step: CGFloat
        if rawStep <= 2 {
            step = 2
        } else if rawStep <= 5 {
            step = 5
        } else if rawStep <= 10 {
            step = 10
        } else if rawStep <= 20 {
            step = 20
        } else if rawStep <= 50 {
            step = 50
        } else {
            step = ceil(rawStep / 10.0) * 10.0
        }
        
        self.maxYValue = step * CGFloat(steps)
        self.yGridValues = (0...steps).map { CGFloat($0) * step }
    }
    // MARK: - Draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        barHitAreas.removeAll()
        guard !subjects.isEmpty else { return }
        
        let context = UIGraphicsGetCurrentContext()
        
        let paddingLeft: CGFloat = 30
        let paddingRight: CGFloat = 10
        let paddingTop: CGFloat = 20
        let paddingBottom: CGFloat = 35
        
        let chartWidth = rect.width - paddingLeft - paddingRight
        let chartHeight = rect.height - paddingTop - paddingBottom
        
        // 1. Draw Grid Lines and Y-Axis Labels (representing raw marks instead of percentages)
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor(red: 0.35, green: 0.45, blue: 0.56, alpha: 1.0)
        ]
        
        for yValue in yGridValues {
            let ratio = maxYValue > 0 ? yValue / maxYValue : 0.0
            let y = rect.height - paddingBottom - (chartHeight * ratio)
            
            // Draw grid line (dashed)
            context?.saveGState()
            context?.setStrokeColor(UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1.0).cgColor)
            context?.setLineWidth(0.8)
            if yValue > 0 {
                context?.setLineDash(phase: 0, lengths: [4, 4])
            }
            context?.move(to: CGPoint(x: paddingLeft, y: y))
            context?.addLine(to: CGPoint(x: rect.width - paddingRight, y: y))
            context?.strokePath()
            context?.restoreGState()
            
            
            // Y label text (without percentage sign)
            let labelStr = "\(Int(yValue))"
            let size = labelStr.size(withAttributes: labelAttributes)
            let textRect = CGRect(x: paddingLeft - size.width - 6, y: y - size.height / 2, width: size.width, height: size.height)
            labelStr.draw(in: textRect, withAttributes: labelAttributes)
        }
        
        // 2. Draw Grouped Bars and X-Axis Subject Labels
        let groupWidth = chartWidth / CGFloat(subjects.count)
        let maxBarWidth: CGFloat = 10
        let interBarSpacing: CGFloat = 3
        
        for (i, subject) in subjects.enumerated() {
            let groupLeft = paddingLeft + (CGFloat(i) * groupWidth)
            
            // Filter marks based on selected exams (or show all if empty)
            let filteredMarks = selectedExamIds.isEmpty ? subject.marks : subject.marks.filter { mark in
                let normalizedId = mark.examName.lowercased()
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "-", with: "")
                return selectedExamIds.contains(normalizedId)
            }
            
            let totalBars = filteredMarks.count
            if totalBars > 0 {
                let barsTotalWidth = (CGFloat(totalBars) * maxBarWidth) + (CGFloat(totalBars - 1) * interBarSpacing)
                let groupCenterX = groupLeft + (groupWidth / 2)
                var barLeft = groupCenterX - (barsTotalWidth / 2)
                
                for (_, mark) in filteredMarks.enumerated() {
                    let obtained = Double(mark.obtainedMark) ?? 0.0
                    // Height is proportional to obtained/maxYValue ratio
                                      let ratio = maxYValue > 0 ? CGFloat(obtained) / maxYValue : 0.0
                    let barHeight = chartHeight * ratio
                    let y = rect.height - paddingBottom - barHeight
                    
                    // Get color from JSON code node or fallback to examColorMap or defaultBarColor
                    let normalizedExamName = mark.examName.lowercased()
                    let color = (mark.colorCode != nil) ? (UIColor(hexString: mark.colorCode!) ?? defaultBarColor) : (examColorMap[normalizedExamName] ?? defaultBarColor)
//                    
//                    let barPath = UIBezierPath(roundedRect: CGRect(x: barLeft, y: y, width: maxBarWidth, height: barHeight), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 2, height: 2))
                    let barRect = CGRect(x: barLeft, y: y, width: maxBarWidth, height: barHeight)
                                    let barPath = UIBezierPath(roundedRect: barRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 2, height: 2))
                    color.setFill()
                    barPath.fill()
                    
                    barHitAreas.append(BarHitArea(frame: barRect, subjectName: subject.subjectName, examName: mark.examName, mark: mark))
                    
                    // Draw obtained mark label text (e.g. 40)
                    let markStr = mark.obtainedMark.isEmpty ? "0" : mark.obtainedMark
                    let markFont = UIFont.systemFont(ofSize: 8, weight: .bold)
                    let markAttributes: [NSAttributedString.Key: Any] = [
                        .font: markFont,
                        .foregroundColor: color
                    ]
                    let markSize = markStr.size(withAttributes: markAttributes)
                    let markTextRect = CGRect(x: barLeft + (maxBarWidth - markSize.width)/2, y: y - markSize.height - 2, width: markSize.width, height: markSize.height)
                    markStr.draw(in: markTextRect, withAttributes: markAttributes)
                    
                    barLeft += maxBarWidth + interBarSpacing
                }
            }
            
            // Draw Subject Name
            var subjectName = subject.subjectName.replacingOccurrences(of: "_", with: " ")

            // Allow only 11 characters
            if subjectName.count > 11 {
                subjectName = String(subjectName.prefix(11)) + "..."
            }

            let subjectSize = subjectName.size(withAttributes: labelAttributes)

            let subjectTextRect = CGRect(
                x: groupLeft + (groupWidth - subjectSize.width) / 2,
                y: rect.height - paddingBottom + 8,
                width: subjectSize.width,
                height: subjectSize.height
            )

            subjectName.draw(in: subjectTextRect, withAttributes: labelAttributes)
        }
        
        // 3. Draw Axis Lines
        context?.setStrokeColor(UIColor(red: 0.68, green: 0.72, blue: 0.78, alpha: 1.0).cgColor)
        context?.setLineWidth(1.0)
        // X line
        context?.move(to: CGPoint(x: paddingLeft, y: rect.height - paddingBottom))
        context?.addLine(to: CGPoint(x: rect.width - paddingRight, y: rect.height - paddingBottom))
        // Y line
        context?.move(to: CGPoint(x: paddingLeft, y: paddingTop))
        context?.addLine(to: CGPoint(x: paddingLeft, y: rect.height - paddingBottom))
        context?.strokePath()
    }
}
