//
//  SchoolStrengthVC.swift
//  VsSchoolChimes
//
//  Created by chandhru on 12/12/24.
//
//import UIKit
//import Charts
//
//class SectionStregnthTVC: UITableViewCell {
//
//    @IBOutlet weak var outerView: UIView!
//    @IBOutlet weak var pieChartView: PieChartView!
//    private var subtitleLabel: UILabel?
//
//    var schoolStrength: SchoolStrength? {
//        didSet {
//            setChartData()
//        }
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        setupChart()
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        subtitleLabel?.removeFromSuperview()
//        subtitleLabel = nil
//    }
//
//    private func setupChart() {
//        pieChartView.holeColor = UIColor.clear
//        pieChartView.holeRadiusPercent = 0.4
//        pieChartView.transparentCircleRadiusPercent = 0.45
//        pieChartView.rotationEnabled = true
//        pieChartView.highlightPerTapEnabled = true
//        pieChartView.drawEntryLabelsEnabled = false
//        pieChartView.centerTextRadiusPercent = 0.95
//
//        let legend = pieChartView.legend
//        legend.enabled = true
//        legend.orientation = .vertical
//        legend.horizontalAlignment = .right
//        legend.verticalAlignment = .center
//        legend.xEntrySpace = 8
//        legend.yEntrySpace = 10
//        legend.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        legend.textColor = UIColor.label
//    }
//
//    private func setChartData() {
//        guard let schoolStrength = schoolStrength else {
//            pieChartView.data = nil
//            return
//        }
//
//        let staffCount = parseDouble(schoolStrength.total_staff_strength)
//        let studentCount = parseDouble(schoolStrength.total_student_strength)
//        let girlsCount = parseDouble(schoolStrength.total_girls_strength)
//        let boysCount = parseDouble(schoolStrength.total_boys_strength)
//        let othersCount = parseDouble(schoolStrength.total_others_strength)
//
//        let chartTotal = staffCount + girlsCount + boysCount + othersCount
//        guard chartTotal > 0 else {
//            showNoDataState()
//            return
//        }
//
//        var entries: [PieChartDataEntry] = []
//        var labels: [String] = []
//        var colors: [UIColor] = []
//
//        // Do NOT include studentCount in chart slices
//
//        
//        if staffCount > 0 {
//            entries.append(PieChartDataEntry(value: staffCount, label: "Staff"))
//            labels.append("Staff")
//            colors.append(.systemOrange)
//        }
//        
//        if studentCount > 0 {
//            entries.append(PieChartDataEntry(value: staffCount, label: "Total Students"))
//            labels.append("Total Students")
//            colors.append(.blue)
//        }
//        
//        if boysCount > 0 {
//            entries.append(PieChartDataEntry(value: boysCount, label: "Boys"))
//            labels.append("Boys")
//            colors.append(.systemTeal)
//        }
//        if girlsCount > 0 {
//            entries.append(PieChartDataEntry(value: girlsCount, label: "Girls"))
//            labels.append("Girls")
//            colors.append(.systemPink)
//        }
//
//        if othersCount > 0 {
//            entries.append(PieChartDataEntry(value: othersCount, label: "Others"))
//            labels.append("Others")
//            colors.append(.systemGray)
//        }
//
//        let dataSet = PieChartDataSet(entries: entries, label: "")
//        dataSet.colors = colors
//        dataSet.sliceSpace = 3.0
//        dataSet.selectionShift = 8.0
//        dataSet.drawValuesEnabled = true
//        dataSet.valueFont = UIFont.boldSystemFont(ofSize: 11)
//        dataSet.valueTextColor = .white
//        dataSet.valueFormatter = CountValueFormatter()
//
//        dataSet.xValuePosition = .insideSlice
//        dataSet.yValuePosition = .insideSlice
//        dataSet.valueLinePart1Length = 0
//        dataSet.valueLinePart2Length = 0
//        dataSet.valueLineWidth = 0
//        dataSet.valueLineColor = .clear
//
//        let data = PieChartData(dataSet: dataSet)
//        pieChartView.data = data
//
//        // ✅ Set total (excluding student count) in center
//        pieChartView.centerText = generateCenterText(totalCount: Int(chartTotal))
//
//        // ✅ Add full legend with total student count
//        createCustomLegend(
//            entries: entries,
//            labels: labels,
//            colors: colors,
//            total: chartTotal,
//            studentCount: Int(studentCount)
//        )
//
//        pieChartView.animate(xAxisDuration: 1.2, yAxisDuration: 1.2, easingOption: .easeInOutQuart)
//    }
//
//    private func parseDouble(_ string: String?) -> Double {
//        guard let string = string?.trimmingCharacters(in: .whitespacesAndNewlines), !string.isEmpty else { return 0.0 }
//        return Double(string) ?? 0.0
//    }
//
//    private func showNoDataState() {
//        pieChartView.data = nil
//        pieChartView.centerText = "No Data\nAvailable"
//        pieChartView.legend.enabled = false
//    }
//
//    private func generateCenterText(totalCount: Int) -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        let formattedTotal = formatter.string(from: NSNumber(value: totalCount)) ?? "\(totalCount)"
//        return "\(formattedTotal)\nTotal"
//    }
//
//    private func createCustomLegend(entries: [PieChartDataEntry], labels: [String], colors: [UIColor], total: Double, studentCount: Int) {
//        var legendEntries: [LegendEntry] = []
//
//        // ✅ Add Total Students on top (separate)
////        if studentCount > 0 {
////            let entry = LegendEntry()
////            entry.label = String(format: "Total Students (%d)", studentCount)
////            entry.form = .circle
////            entry.formSize = 8
////            entry.formColor = .systemBlue
////            legendEntries.append(entry)
////        }
//
//        for (index, entry) in entries.enumerated() {
////            let percentage = (entry.value / total) * 100
//            let count = Int(entry.value)
//            let legendEntry = LegendEntry()
//            legendEntry.label = String(format: "%@ - %d ", labels[index], count)
//            legendEntry.form = .circle
//            legendEntry.formSize = 8
//            legendEntry.formColor = colors[index]
//            legendEntries.append(legendEntry)
//        }
//
//        pieChartView.legend.setCustom(entries: legendEntries)
//    }
//}
//// MARK: - Value Formatter
//class CountValueFormatter: ValueFormatter {
//    func stringForValue(_ value: Double, entry: Charts.ChartDataEntry, dataSetIndex: Int, viewPortHandler: Charts.ViewPortHandler?) -> String {
//        return "\(Int(value))"
//    }
//}
import UIKit
import Charts

class SectionStregnthTVC: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    private var subtitleLabel: UILabel?

    var schoolStrength: SchoolStrength? {
        didSet {
            setChartData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupChart()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        subtitleLabel?.removeFromSuperview()
        subtitleLabel = nil
    }

    private func setupChart() {
        pieChartView.holeColor = UIColor.clear
        pieChartView.holeRadiusPercent = 0.4
        pieChartView.transparentCircleRadiusPercent = 0.45
        pieChartView.rotationEnabled = true
        pieChartView.highlightPerTapEnabled = true
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.centerTextRadiusPercent = 0.95

        let legend = pieChartView.legend
        legend.enabled = true
        legend.orientation = .vertical
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .center
        legend.xEntrySpace = 8
        legend.yEntrySpace = 10
        legend.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        legend.textColor = UIColor.label
    }

    private func setChartData() {
        guard let schoolStrength = schoolStrength else {
            pieChartView.data = nil
            return
        }

       
        let staffCount = parseDouble(schoolStrength.total_staff_strength)
        let studentCount = parseDouble(schoolStrength.total_student_strength)
        let girlsCount = parseDouble(schoolStrength.total_girls_strength)
        let boysCount = parseDouble(schoolStrength.total_boys_strength)
        let othersCount = parseDouble(schoolStrength.total_others_strength)

        let chartTotal = staffCount + girlsCount + boysCount + othersCount
        guard chartTotal > 0 else {
            showNoDataState()
            return
        }

        var entries: [PieChartDataEntry] = []
        var labels: [String] = []
        var colors: [UIColor] = []

        // ✅ Reorder to match desired sequence: Staff, Girls, Boys, Others
        if staffCount > 0 {
            entries.append(PieChartDataEntry(value: staffCount, label: "Staff"))
            labels.append("Staff")
            colors.append(.systemOrange)
        }
        
        if girlsCount > 0 {
            entries.append(PieChartDataEntry(value: girlsCount, label: "Girls"))
            labels.append("Girls")
            colors.append(.systemPink)
        }

        if boysCount > 0 {
            entries.append(PieChartDataEntry(value: boysCount, label: "Boys"))
            labels.append("Boys")
            colors.append(.systemTeal)
        }

        if othersCount > 0 {
            entries.append(PieChartDataEntry(value: othersCount, label: "Others"))
            labels.append("Others")
            colors.append(.systemGray)
        }

        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = colors
        dataSet.sliceSpace = 3.0
        dataSet.selectionShift = 8.0
        dataSet.drawValuesEnabled = true
        dataSet.valueFont = UIFont.boldSystemFont(ofSize: 11)
        dataSet.valueTextColor = .white
        dataSet.valueFormatter = CountValueFormatter()

        dataSet.xValuePosition = .insideSlice
        dataSet.yValuePosition = .insideSlice
        dataSet.valueLinePart1Length = 0
        dataSet.valueLinePart2Length = 0
        dataSet.valueLineWidth = 0
        dataSet.valueLineColor = .clear

        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data

        // ✅ Set total (excluding student count) in center
        pieChartView.centerText = generateCenterText(totalCount: Int(chartTotal))

        // ✅ Add custom legend in desired order
        createCustomLegend(
            entries: entries,
            labels: labels,
            colors: colors,
            total: chartTotal,
            studentCount: Int(studentCount),
            staffCount: Int(staffCount)
        )

        pieChartView.animate(xAxisDuration: 1.2, yAxisDuration: 1.2, easingOption: .easeInOutQuart)
    }

    private func parseDouble(_ string: String?) -> Double {
        guard let string = string?.trimmingCharacters(in: .whitespacesAndNewlines), !string.isEmpty else { return 0.0 }
        return Double(string) ?? 0.0
    }

    private func showNoDataState() {
        pieChartView.data = nil
        pieChartView.centerText = "No Data\nAvailable"
        pieChartView.legend.enabled = false
    }

    private func generateCenterText(totalCount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedTotal = formatter.string(from: NSNumber(value: totalCount)) ?? "\(totalCount)"
        return "\(formattedTotal)\nTotal"
    }

    private func createCustomLegend(entries: [PieChartDataEntry], labels: [String], colors: [UIColor], total: Double, studentCount: Int, staffCount: Int) {
        var legendEntries: [LegendEntry] = []

        // ✅ 1. Staff first (with bold formatting)
        if staffCount > 0 {
            let staffEntry = LegendEntry()
            staffEntry.label = String(format: "Staff - %d", staffCount)
            staffEntry.form = .circle
            staffEntry.formSize = 8
            staffEntry.formColor = .systemOrange
            legendEntries.append(staffEntry)
        }

        // ✅ 2. Total Students second (with bold formatting)
        if studentCount > 0 {
            let studentEntry = LegendEntry()
            studentEntry.label = String(format: "Total Students - %d", studentCount)
            studentEntry.form = .circle
            studentEntry.formSize = 0
            studentEntry.formColor = .clear // No color indicator for total
            legendEntries.append(studentEntry)
        }

        // ✅ 3. Girls and Boys (indented/sub-items with aligned forms)
        for (index, entry) in entries.enumerated() {
            let count = Int(entry.value)
            let label = labels[index]
            
            // Skip staff as it's already added above
            if label == "Staff" { continue }
            
            let legendEntry = LegendEntry()
            legendEntry.label = String(format: "  %@ - %d", label.lowercased(), count) // Indented with lowercase
            legendEntry.form = .circle
            legendEntry.formSize = 6 // Slightly smaller for sub-items
            legendEntry.formColor = colors[index]
            legendEntries.append(legendEntry)
        }

        pieChartView.legend.setCustom(entries: legendEntries)
    }
}

// MARK: - Value Formatter
class CountValueFormatter: ValueFormatter {
    func stringForValue(_ value: Double, entry: Charts.ChartDataEntry, dataSetIndex: Int, viewPortHandler: Charts.ViewPortHandler?) -> String {
        return "\(Int(value))"
    }
}
