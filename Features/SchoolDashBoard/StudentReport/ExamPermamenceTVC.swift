//
//  ExamPermamenceTVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/03/26.
//

import UIKit
import DGCharts

class ExamPermamenceTVC: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var overallSatack: UIStackView!
    @IBOutlet weak var subjectWiseStacke: UIStackView!
    @IBOutlet weak var persantageBtn: UIButton!
    @IBOutlet weak var lastExamsCount: UILabel!
    @IBOutlet weak var examStacke: UIStackView!
    @IBOutlet weak var stregnthView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var stregnthBtn: UIButton!
    @IBOutlet weak var weekBtn: UIButton!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var barChartView: BarChartView!

    override func awakeFromNib() {
        super.awakeFromNib()

        stregnthView.layer.cornerRadius = 12
        weekView.layer.cornerRadius = 12
        outerView.setShadow()
        stregnthView.clipsToBounds = true
        weekView.clipsToBounds = true

        stregnthView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
        stregnthBtn.setTitleColor(.systemGreen, for: .normal)

        weekView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
        weekBtn.setTitleColor(.systemRed, for: .normal)
        persantageBtn.layer.cornerRadius = persantageBtn.frame.height / 2
        persantageBtn.clipsToBounds = true
        outerView.setShadow()
        commonLineSetup()
        commonBarSetup()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        lineChartView.data = nil
        barChartView.data = nil
    }

    private func commonLineSetup() {

        lineChartView.chartDescription.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.enabled = false

        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.granularity = 1

        lineChartView.leftAxis.axisMinimum = 0
        lineChartView.leftAxis.axisMaximum = 100

        // ✅ X Axis Grid Line - Dashed
        lineChartView.xAxis.gridLineDashLengths = [4, 4]
        lineChartView.xAxis.gridLineDashPhase = 0
        lineChartView.xAxis.gridColor = UIColor.systemGray.withAlphaComponent(0.4)
        lineChartView.xAxis.gridLineWidth = 1.0

        // ✅ Y Axis Grid Line - Dashed
        lineChartView.leftAxis.gridLineDashLengths = [4, 4]
        lineChartView.leftAxis.gridLineDashPhase = 0
        lineChartView.leftAxis.gridColor = UIColor.systemGray.withAlphaComponent(0.4)
        lineChartView.leftAxis.gridLineWidth = 1.0

        lineChartView.animate(xAxisDuration: 1.0)
    }

    private func commonBarSetup() {

        barChartView.chartDescription.enabled = false
        barChartView.rightAxis.enabled = false
        barChartView.legend.enabled = false

        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.granularity = 1

        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.axisMaximum = 100

        barChartView.animate(yAxisDuration: 1.0)
    }

    func configureExam(data: ExamPerformance?) {

        guard let data = data,
              let exams = data.exams else { return }

        examStacke.isHidden = false
        subjectWiseStacke.isHidden = true

        lineChartView.isHidden = false
        barChartView.isHidden = true

        var entries: [ChartDataEntry] = []

        for (index, exam) in exams.enumerated() {
            entries.append(
                ChartDataEntry(
                    x: Double(index),
                    y: exam.score ?? 0
                )
            )
        }

        let dataSet = LineChartDataSet(entries: entries)
        dataSet.colors = [.systemBlue]
        dataSet.circleColors = [.systemBlue]
        dataSet.circleRadius = 5
        dataSet.lineWidth = 3
        dataSet.mode = .cubicBezier
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true

        // Gradient Fill
        let gradientColors = [
            UIColor.systemBlue.withAlphaComponent(0.4).cgColor,
            UIColor.systemBlue.withAlphaComponent(0.0).cgColor
        ] as CFArray

        let colorLocations: [CGFloat] = [1.0, 0.0]

        if let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: gradientColors,
            locations: colorLocations
        ) {
            dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
        }
        let chartData = LineChartData(dataSet: dataSet)
        lineChartView.data = chartData

        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(
            values: exams.map { $0.examName ?? "" }
        )

        // ✅ Attach Exam Marker
        let examMarker = ExamMarkerView()
        examMarker.chartView = lineChartView
        lineChartView.marker = examMarker

        // Improvement %
        let improvement = Int(data.improvementPercentage ?? 0)

        if improvement >= 0 {
            persantageBtn.setTitle("+\(improvement)%", for: .normal)
            persantageBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            persantageBtn.setTitleColor(.systemGreen, for: .normal)
        } else {
            persantageBtn.setTitle("\(improvement)%", for: .normal)
            persantageBtn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            persantageBtn.setTitleColor(.systemRed, for: .normal)
        }

        // Highest text (Attractive style)
        let score = Int(data.highestScore ?? 0)
        let exam = data.highestExamName ?? ""

        let normalText = "Highest Score: "
        let boldText = "\(score)% in \(exam)"

        let attributed = NSMutableAttributedString(
            string: normalText,
            attributes: [
                .foregroundColor: UIColor.systemGray,
                .font: UIFont.systemFont(ofSize: 14)
            ])

        attributed.append(NSAttributedString(
            string: boldText,
            attributes: [
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.boldSystemFont(ofSize: 15)
            ]))
        // Remove old score label if exists
        overallSatack.arrangedSubviews
            .filter { $0.tag == 555 }
            .forEach { $0.removeFromSuperview() }

        // Create label
        let scoreLabel = UILabel()
        scoreLabel.tag = 555
        scoreLabel.numberOfLines = 0
        scoreLabel.textAlignment = .center
        scoreLabel.attributedText = attributed

        // Add to stack
        overallSatack.addArrangedSubview(scoreLabel)

        let examCount = exams.count
        lastExamsCount.text = "Last \(examCount) Exams"
        lastExamsCount.textColor = .secondaryLabel
        lastExamsCount.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }

    func configureSubject(data: SubjectWisePerformance?) {

        guard let data = data,
              let subjects = data.subjects else { return }

        examStacke.isHidden = true
        subjectWiseStacke.isHidden = false

        lineChartView.isHidden = true
        barChartView.isHidden = false

        let renderer = GradientBarChartRenderer(
            dataProvider: barChartView,
            animator: barChartView.chartAnimator,
            viewPortHandler: barChartView.viewPortHandler
        )

        // ✅ Highest marks bar = Primary color
        renderer.primaryColorIndex = subjects.indices.max(by: {
            subjects[$0].marks < subjects[$1].marks
        }) ?? 0

        barChartView.renderer = renderer

        var entries: [BarChartDataEntry] = []

        for (_, subject) in subjects.enumerated() {
            entries.append(
                BarChartDataEntry(
                    x: Double(entries.count),
                    y: subject.marks
                )
            )
        }

        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = [UIColor.primery]
        dataSet.drawValuesEnabled = false

        let chartData = BarChartData(dataSet: dataSet)
        barChartView.data = chartData

        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(
            values: subjects.map { $0.subjectName }
        )

        let subjectMarker = SubjectMarkerView()
        subjectMarker.chartView = barChartView
        barChartView.marker = subjectMarker

        commonBarSetup()

        stregnthBtn.setTitle("Strong: \(data.strongestSubject ?? "")", for: .normal)
        weekBtn.setTitle("Weak: \(data.weakestSubject ?? "")", for: .normal)
        let legendColors = subjects.indices.map { renderer.barColor(for: $0) }
        buildLegend(subjects: subjects, colors: legendColors)
    }
    private func buildLegend(subjects: [SubjectPerformance], colors: [UIColor]) {

           // Remove old legend if exists
        overallSatack.arrangedSubviews
               .filter { $0.tag == 999 }
               .forEach { $0.removeFromSuperview() }

           // Outer vertical stack
           let outerStack = UIStackView()
           outerStack.tag = 999
           outerStack.axis = .vertical
           outerStack.alignment = .center
           outerStack.spacing = 6
           outerStack.translatesAutoresizingMaskIntoConstraints = false

           // Split subjects into rows of max 3
           let chunkSize = 3
           let chunks = stride(from: 0, to: subjects.count, by: chunkSize).map {
               Array(subjects[$0..<min($0 + chunkSize, subjects.count)])
           }
           let colorChunks = stride(from: 0, to: colors.count, by: chunkSize).map {
               Array(colors[$0..<min($0 + chunkSize, colors.count)])
           }

           for (rowIndex, chunk) in chunks.enumerated() {
               let rowStack = UIStackView()
               rowStack.axis = .horizontal
               rowStack.alignment = .center
               rowStack.spacing = 16
               rowStack.distribution = .equalSpacing

               for (itemIndex, subject) in chunk.enumerated() {
                   let color = colorChunks[rowIndex][itemIndex]

                   // Dot
                   let dot = UIView()
                   dot.backgroundColor = color
                   dot.layer.cornerRadius = 5
                   dot.translatesAutoresizingMaskIntoConstraints = false
                   dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
                   dot.heightAnchor.constraint(equalToConstant: 10).isActive = true

                   // Label: "Math: A+"
                   let label = UILabel()
                   label.font = UIFont.systemFont(ofSize: 13)
                   label.textColor = UIColor.label

                   let nameAttr = NSMutableAttributedString(
                       string: "\(subject.subjectName): ",
                       attributes: [.font: UIFont.systemFont(ofSize: 13),
                                    .foregroundColor: UIColor.secondaryLabel]
                   )
                   nameAttr.append(NSAttributedString(
                       string: subject.grade ?? gradeFromMarks(subject.marks),
                       attributes: [.font: UIFont.boldSystemFont(ofSize: 13),
                                    .foregroundColor: UIColor.label]
                   ))
                   label.attributedText = nameAttr

                   // Item stack (dot + label)
                   let itemStack = UIStackView(arrangedSubviews: [dot, label])
                   itemStack.axis = .horizontal
                   itemStack.alignment = .center
                   itemStack.spacing = 5

                   rowStack.addArrangedSubview(itemStack)
               }

               outerStack.addArrangedSubview(rowStack)
           }

        overallSatack.addArrangedSubview(outerStack)
       }

       private func gradeFromMarks(_ marks: Double) -> String {
           switch marks {
           case 90...100: return "A+"
           case 80..<90:  return "A"
           case 70..<80:  return "B+"
           case 60..<70:  return "B"
           case 50..<60:  return "C"
           default:       return "F"
           }
       }
}

// MARK: - Line Chart Marker (Exam Performance)
class ExamMarkerView: MarkerView {

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {

        containerView.backgroundColor = UIColor(white: 0.15, alpha: 0.92)
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        valueLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        valueLabel.textColor = UIColor.systemBlue
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
        ])
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if let chartView = chartView as? LineChartView,
           let formatter = chartView.xAxis.valueFormatter {
            let title = formatter.stringForValue(entry.x, axis: chartView.xAxis)
            titleLabel.text = title
        } else {
            titleLabel.text = "Exam"
        }
        valueLabel.text = "score : \(Int(entry.y))"
        layoutIfNeeded()
        let size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        self.frame.size = size
        self.offset = CGPoint(x: -size.width / 2, y: -size.height - 12)
    }
}

// MARK: - Bar Chart Marker (Subject-wise Performance)
class SubjectMarkerView: MarkerView {

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {

        containerView.backgroundColor = UIColor(white: 0.15, alpha: 0.92)
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        valueLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        valueLabel.textColor = .lightGray
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
        ])
    }

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if let chartView = chartView as? BarChartView,
           let formatter = chartView.xAxis.valueFormatter {
            let title = formatter.stringForValue(entry.x, axis: chartView.xAxis)
            titleLabel.text = title
        } else {
            titleLabel.text = "Subject"
        }
        valueLabel.text = "marks : \(Int(entry.y))"
        layoutIfNeeded()
        let size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        self.frame.size = size
        self.offset = CGPoint(x: -size.width / 2, y: -size.height - 12)
    }
}
// MARK: - Clean Solid Color Bar Renderer
class GradientBarChartRenderer: BarChartRenderer {

    private var cachedColors: [Int: UIColor] = [:]
    var primaryColorIndex: Int = 0 // ✅ எந்த bar primary color-ல இருக்கணும்

    func barColor(for index: Int) -> UIColor {
        if let cached = cachedColors[index] { return cached }

        // ✅ Primary index = UIColor.primery, மத்தவை random
        let color: UIColor
        if index == primaryColorIndex {
            color = UIColor.primery
        } else {
            let hue = CGFloat.random(in: 0.0...1.0)
            color = UIColor(hue: hue, saturation: 0.75, brightness: 0.90, alpha: 1.0)
        }

        cachedColors[index] = color
        return color
    }

    override func drawDataSet(context: CGContext, dataSet: BarChartDataSetProtocol, index: Int) {
        guard let dataProvider = dataProvider,
              let barData = dataProvider.barData else { return }

        let trans = dataProvider.getTransformer(forAxis: dataSet.axisDependency)
        let phaseY = animator.phaseY
        let barWidthHalf = barData.barWidth / 2.0

        for i in 0..<dataSet.entryCount {
            guard let entry = dataSet.entryForIndex(i) as? BarChartDataEntry else { continue }

            var rect = CGRect(
                x: entry.x - barWidthHalf,
                y: 0,
                width: barData.barWidth,
                height: entry.y * phaseY
            )
            trans.rectValueToPixel(&rect)

            let color = barColor(for: i)

            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: 8, height: 8)
            )

            context.setFillColor(color.cgColor)
            context.addPath(path.cgPath)
            context.fillPath()
        }
    }
}
