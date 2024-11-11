//
//  PiechartCVCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 08/11/24.
//

import UIKit
import Charts

class PiechartCVCell: UICollectionViewCell {

    @IBOutlet weak var Cellview: UIView!
    @IBOutlet weak var pieChartView: PieChartView!

   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Configure the chart with the cell’s own data on load
        
        //cellview.layer.masksToBounds = true
        Cellview.layer.cornerRadius = 10
        Cellview.layer.shadowColor = UIColor.black.cgColor
        Cellview.layer.shadowOpacity = 0.5
        Cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        Cellview.layer.shadowRadius = 3
        Cellview.layer.masksToBounds = false
        
        pieChartView.frame = CGRect(x: 0, y: 0, width: 180, height: 165)
             setupPieChart()
               setChartData()
    }
    
    private func setupPieChart() {
            // Configure the general look of the pie chart
            pieChartView.usePercentValuesEnabled = false
            pieChartView.drawSlicesUnderHoleEnabled = false
            pieChartView.holeRadiusPercent = 0.0
            pieChartView.transparentCircleRadiusPercent = 0.0
            pieChartView.chartDescription.enabled = false
            pieChartView.drawEntryLabelsEnabled = false
            pieChartView.legend.enabled = false
        }

        private func setChartData() {
            // Define the data entries
            let entries = [
                PieChartDataEntry(value: 25, label: "Segment 1"),
                PieChartDataEntry(value: 25, label: "Segment 2"),
                PieChartDataEntry(value: 50, label: "Segment 3")
            ]
            
            let dataSet = PieChartDataSet(entries: entries, label: "")
            dataSet.colors = [UIColor.systemYellow,UIColor.systemRed, UIColor.systemTeal]
            
            // Set other dataset properties if needed
            dataSet.drawValuesEnabled = false // Hide values on the segments
            
            // Apply the data to the chart
            let data = PieChartData(dataSet: dataSet)
            pieChartView.data = data
            
            pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInExpo)
            
            // Refresh chart
            pieChartView.notifyDataSetChanged()
        }

    
    
}
