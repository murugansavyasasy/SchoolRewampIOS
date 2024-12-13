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
        
//        barchartHeight.constant = 0
//        barChartView.isHidden = true
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

   

    // Function to set up the bar chart
    private func setupBarChart() {
        barChartView.noDataText = "No data available."
        barChartView.chartDescription.enabled = false
        
        // X-Axis Configuration
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["A", "B", "C", "D"])
        barChartView.xAxis.granularity = 1
        
        // Y-Axis Configuration
        barChartView.leftAxis.axisMinimum = 0 // Ensure Y-axis starts at zero
        barChartView.rightAxis.enabled = false // Hide right axis
        
        // Legend
        barChartView.legend.enabled = false
    }

    // Function to populate bar chart data
    private func setBarChartData() {
        // Example values for sections A, B, C, D
        let sectionCounts = [50, 75, 30, 60]
        
        // Create data entries for each section
        var entries: [BarChartDataEntry] = []
        for (index, count) in sectionCounts.enumerated() {
            entries.append(BarChartDataEntry(x: Double(index), y: Double(count)))
        }
        
        // Data set
        let dataSet = BarChartDataSet(entries: entries, label: "Student Count")
        if #available(iOS 15.0, *) {
            dataSet.colors = [UIColor.systemMint,UIColor.systemYellow,UIColor.systemOrange,UIColor.systemRed]
        } else {
            // Fallback on earlier versions
        }
        dataSet.valueFont = .systemFont(ofSize: 12)
        dataSet.valueTextColor = .black
        
        // Add data set to BarChartData
        let data = BarChartData(dataSet: dataSet)
        data.setValueFormatter(DefaultValueFormatter(decimals: 0)) // No decimal places
        
        // Assign data to chart
        barChartView.data = data
        
        // Animate chart
        barChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
    }


}
