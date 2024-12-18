//
//  StrengthTvCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 12/12/24.
//

import UIKit
import Charts

class StrengthTvCell: UITableViewCell {
    
    @IBOutlet weak var dropdownImgview: UIImageView!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var countView: UIView!
    @IBOutlet weak var standardLbl: UILabel!
    @IBOutlet weak var barchartHeight: NSLayoutConstraint!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var cellview: UIView!
    
    @IBOutlet weak var StandardView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        countLbl.setFont(style: .body, size: FontSize.BodySize)
        standardLbl.setFont(style: .title, size: FontSize.TitleSize)
        StandardView.layer.cornerRadius = 10
        cellview.layer.cornerRadius = 10
        countView.layer.cornerRadius = 10
        setupBarChart()
        setBarChartData()
        
    }
    
    private func setupBarChart() {
        barChartView.noDataText = "No data available."
        barChartView.chartDescription.enabled = false
        
        // Change the background color of the chart
        barChartView.backgroundColor = UIColor.white
        
        // X-Axis Configuration
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"])
        barChartView.xAxis.granularity = 0.5
        barChartView.xAxis.labelCount = 26
        barChartView.xAxis.avoidFirstLastClippingEnabled = true
        
        // Add extra offsets for better padding
        barChartView.setExtraOffsets(left: 10, top: 10, right: 10, bottom: 10)
        
        // Enable scrolling
        barChartView.setScaleEnabled(false) // Disable pinch zoom
        barChartView.dragEnabled = true // Enable drag
        barChartView.fitBars = false // Do not auto-fit bars
        
        // Y-Axis Configuration
        barChartView.leftAxis.axisMinimum = 0 // Ensure Y-axis starts at zero
        barChartView.rightAxis.enabled = false // Hide right axis
        
        // Legend
        barChartView.legend.enabled = false
        
        // Adding custom labels (Axis Titles) inside the chart
        addAxisLabels()
    }
    
    private func addAxisLabels() {
        // Add X-Axis Label (Class) inside the chart, below the X-axis
        let xAxisLabel = UILabel()
        xAxisLabel.text = "Swipe to see All Classes"
        xAxisLabel.font = .systemFont(ofSize: 14)
        xAxisLabel.textColor = .lightGray
        barChartView.addSubview(xAxisLabel)
        
        // Setting position of X-Axis label manually
        xAxisLabel.translatesAutoresizingMaskIntoConstraints = false
        xAxisLabel.centerXAnchor.constraint(equalTo: barChartView.centerXAnchor).isActive = true
        xAxisLabel.topAnchor.constraint(equalTo: barChartView.bottomAnchor, constant: -15).isActive = true // Adjust the value to position the label
    }
    
    private func setBarChartData() {
        let sectionCounts = [44, 27, 19, 41, 33, 30, 49, 32, 36, 40, 22, 29, 37, 45, 35, 39, 24, 28, 50, 38, 31, 34, 42, 43, 25, 50]
        
        // Create data entries for each section
        var entries: [BarChartDataEntry] = []
        for (index, count) in sectionCounts.enumerated() {
            entries.append(BarChartDataEntry(x: Double(index), y: Double(count)))
        }
        
        // Data set
        let dataSet = BarChartDataSet(entries: entries, label: "Student Count")
        if #available(iOS 15.0, *) {
            //dataSet.colors = [UIColor.systemMint, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemRed]
            dataSet.colors = [UIColor.systemMint]
        } else {
            // Fallback on earlier versions
        }
        dataSet.valueFont = .systemFont(ofSize: 12)
        dataSet.valueTextColor = .black
        
        // Add data set to BarChartData
        let data = BarChartData(dataSet: dataSet)
        data.setValueFormatter(DefaultValueFormatter(decimals: 0)) // No decimal places
        data.barWidth = 0.5 // Bars take 50% of the allocated space
        
        // Assign data to chart
        barChartView.data = data
        
        // Adjust chart's visible range
        let visibleBarCount: Double = 6 // Number of bars to display at once
        barChartView.setVisibleXRangeMaximum(visibleBarCount)
        barChartView.moveViewToX(-25) // Start viewing from the beginning
        
        // Animate chart
        barChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
    }
    
}
