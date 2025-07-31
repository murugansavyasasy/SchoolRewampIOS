//
//  HomeWorkCvCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 22/07/25.
//

import UIKit
import Charts


protocol EditAndDelete{
    
    func EditDeleteclcik()
        
        
    
}
class HomeWorkCvCell: UICollectionViewCell {
    @IBOutlet weak var pieChartHeight: NSLayoutConstraint!
    @IBOutlet weak var homeWorkCompletImg: UIImageView!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var stafNamLbl: UILabel!
    @IBOutlet weak var pieChartWidth: NSLayoutConstraint!
    @IBOutlet weak var PieChartTrailling: NSLayoutConstraint!
    @IBOutlet weak var roundview: UIView!
    @IBOutlet weak var pieChart: PieChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        roundview.layer.cornerRadius = roundview.frame.width/2
        contentView.layer.masksToBounds = true
        applyShadowAndCornerRadius(to: contentView)
        setupPieChart()
        
        
        
    }

    
    private func setupPieChart() {
        pieChart.holeRadiusPercent = 0.9 // Adjust inner circle size
        pieChart.transparentCircleRadiusPercent = 0.2
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.enabled = false
        pieChart.chartDescription.enabled = false
        pieChart.holeColor = UIColor.white // Background of the hole
       }
    
    
    func setProgress(to percentage: Double) {
        let progressEntry = PieChartDataEntry(value: percentage, label: nil)
        let emptyEntry = PieChartDataEntry(value: 100 - percentage, label: nil)
        
        let progressColor = colorForPercentage(percentage) //UIColor.systemYellow.withAlphaComponent(0.8)
//        SideColourView.backgroundColor = progressColor.withAlphaComponent(0.6)

        let progressDataSet = PieChartDataSet(entries: [progressEntry, emptyEntry], label: "Hello")
        progressDataSet.colors = [progressColor, UIColor.lightGray]
        progressDataSet.drawValuesEnabled = false

        let pieData = PieChartData(dataSet: progressDataSet)
        pieChart.data = pieData

        // Display Percentage in the Center
            let percentageText = "\(Int(percentage))%"
            let attributedString = NSAttributedString(
                string: percentageText,
                attributes: [
                 .font: UIFont(name: "Poppins-Bold", size: 11), // Change font size
                 .foregroundColor: UIColor.homeWorkClr // Change text color
                ]
            )
            
        pieChart.centerAttributedText = attributedString
        pieChart.centerTextRadiusPercent = 0.9
        
//        if isAnimate{
//            pieChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInExpo)
//        }
    }
 
    func colorForPercentage(_ percentage: Double) -> UIColor {
        switch percentage {
            //        case 0...20:
            //            return UIColor.systemRed.withAlphaComponent(0.8)
            //        case 21...40:
            //            return UIColor.systemOrange.withAlphaComponent(0.8)
            //        case 41...60:
            //            return UIColor.systemYellow.withAlphaComponent(0.8)
            //        case 61...100:
            //            return UIColor.systemGreen.withAlphaComponent(0.8)
        case 1...99:
            return UIColor.homeWorkClr.withAlphaComponent(0.8)
        case 100:
            return UIColor.systemGreen.withAlphaComponent(0.8)
        default:
            return UIColor.lightGray // Default color (0% or invalid input)
        }
    }
}
