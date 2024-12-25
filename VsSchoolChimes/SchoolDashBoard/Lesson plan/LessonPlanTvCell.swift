//
//  LessonPlanTvCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/12/24.
//

import UIKit
import Charts

class LessonPlanTvCell: UITableViewCell {
    
    @IBOutlet weak var navigateview: UIView!
    @IBOutlet weak var viewBtn: UIButton!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var Redview: UIView!
    @IBOutlet weak var Greenlabel: UILabel!
    @IBOutlet weak var Greenview: UIView!
    @IBOutlet weak var percentagesStackView: UIStackView!
    @IBOutlet weak var Cellview: UIView!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    var val1: Double! = 75
    var val2: Double! = 25
    var id  = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Cellview.layer.cornerRadius = 12.0
        Cellview.layer.masksToBounds = false
        
        // Shadow to make it look "popped up"
        Cellview.layer.shadowColor = UIColor.black.cgColor
        Cellview.layer.shadowOpacity = 0.2
        Cellview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Cellview.layer.shadowRadius = 6
        
        // Optional: Add a border for a polished look
        Cellview.layer.borderColor = UIColor.lightGray.cgColor
        Cellview.layer.borderWidth = 0.5
        
        // Background color for the card
        Cellview.backgroundColor = .white
        navigateview.layer.cornerRadius = 10
        //viewBtn.layer.cornerRadius = 10
        pieChartView.frame = CGRect(x: 0, y: 0, width: 180, height: 165)
        setupPieChart()
        
    }
    
    
    @IBAction func ViewbtnAct(_ sender: Any) {
        id = 1
    }
    
    func  getvalue(a:Int,b:Int){
        
        val1 = Double(a)
        val2 = Double(b)
        setChartData()
    }
    private func setupPieChart() {
        // Configure the general look of the pie chart
        pieChartView.usePercentValuesEnabled = true
        pieChartView.drawSlicesUnderHoleEnabled = false
        pieChartView.holeRadiusPercent = 0.0
        pieChartView.transparentCircleRadiusPercent = 0.0
        pieChartView.chartDescription.enabled = true
        pieChartView.drawEntryLabelsEnabled = false // Optional: Set to true if you want labels
        pieChartView.legend.enabled = false
    }
    
    private func setChartData() {
        // Define the data entries
        let entries = [
            PieChartDataEntry(value: val1, label: "Completed"),
            PieChartDataEntry(value: val2, label: "Pending")
        ]
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        
        // Set the colors for the slices
        if #available(iOS 15.0, *) {
            dataSet.colors = [UIColor.systemMint, UIColor.systemRed]
        } else {
            dataSet.colors = [UIColor.green, UIColor.red]
        }
        
        // Enable value display and format as percentages
        dataSet.drawValuesEnabled = true
        dataSet.valueTextColor = .white // Customize text color
        dataSet.valueFont = UIFont.systemFont(ofSize: 14) // Customize text font
        
        // Configure number formatter for percentage values
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.multiplier = 1
        numberFormatter.positiveSuffix = " %" // Append % symbol
        
        
        // Set the value formatter
        dataSet.valueFormatter = DefaultValueFormatter(formatter: numberFormatter)
        
        // Apply the data to the chart
        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
        
        // Animate the chart
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInExpo)
        
        // Refresh chart
        pieChartView.notifyDataSetChanged()
        
        // Optional: Update the labels outside the chart
        Greenlabel.text = CommonStringFile.completed.translated()
        redLabel.text = CommonStringFile.pending.translated()
    }
    
    
    private func displayPercentages(entries: [PieChartDataEntry]) {
        // Assuming you have a UIStackView named `percentagesStackView` added in your storyboard
        percentagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() } // Clear old labels
        // Calculate the total value
        let totalValue = entries.reduce(0) { $0 + $1.value }
        
        // Create labels for each entry
        for entry in entries {
            let percentage = (entry.value / totalValue) * 100
            let label = UILabel()
            label.text = "\(entry.label ?? ""): \(String(format: "%.1f", percentage))%"
            label.textAlignment = .center
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 14)
            
            percentagesStackView.addArrangedSubview(label)
        }
        
    }
 
    func animatePopUpEffect() {
        UIView.animate(withDuration: 0.1, animations: {
            self.Cellview.transform = CGAffineTransform(scaleX: 1.02, y: 1.02) // Slightly scale up
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.Cellview.transform = CGAffineTransform.identity // Return to normal size
            }
        }
    }
    
    
}

