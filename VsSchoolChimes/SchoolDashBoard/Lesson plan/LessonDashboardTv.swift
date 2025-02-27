//
//  LessonDashboardTv.swift
//  VsSchoolChimes
//
//  Created by MacBook on 18/02/25.
//

import UIKit
import Charts

@available(iOS 15.0, *)
class LessonDashboardTv: UITableViewCell {

    @IBOutlet weak var SideColourView: UIView!
    @IBOutlet weak var ViewBtn: UIButton!
    @IBOutlet weak var Cellview: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var StaffNameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var SubjectLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        Cellview.layer.cornerRadius = 12.0
        Cellview.layer.masksToBounds = false
        
        // Shadow to make it look "popped up"
        Cellview.layer.shadowColor = UIColor.black.cgColor
        Cellview.layer.shadowOpacity = 0.2
        Cellview.layer.shadowOffset = CGSize(width: 0, height: 4)
        Cellview.layer.shadowRadius = 6
        Cellview.layer.borderColor = UIColor.lightGray.cgColor
        Cellview.layer.borderWidth = 0.5
        Cellview.backgroundColor = .white
        
        SideColourView.layer.cornerRadius = 10
        SideColourView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
        
        ViewBtn.layer .cornerRadius = 10
        ViewBtn.setTitleFont(style: .body, size: 14)
        
        setupPieChart()
       // setProgress(to: 30)
        
        SubjectLbl.setFont(style: .title, size: FontSize.TitleSize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        StaffNameLbl.setFont(style: .body, size: FontSize.BodySize)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
    private func setupPieChart() {
           pieChartView.holeRadiusPercent = 0.6 // Adjust inner circle size
           pieChartView.transparentCircleRadiusPercent = 0.65
           pieChartView.drawEntryLabelsEnabled = false
           pieChartView.legend.enabled = false
           pieChartView.chartDescription.enabled = false
           pieChartView.holeColor = UIColor.white // Background of the hole
       }

       func setProgress(to percentage: Double) {
           let progressEntry = PieChartDataEntry(value: percentage, label: nil)
           let emptyEntry = PieChartDataEntry(value: 100 - percentage, label: nil)
           
           let progressColor = colorForPercentage(percentage) //UIColor.systemYellow.withAlphaComponent(0.8)
           SideColourView.backgroundColor = progressColor.withAlphaComponent(0.6)

           let progressDataSet = PieChartDataSet(entries: [progressEntry, emptyEntry], label: "Hello")
           progressDataSet.colors = [progressColor, UIColor.lightGray]
           progressDataSet.drawValuesEnabled = false

           let pieData = PieChartData(dataSet: progressDataSet)
           pieChartView.data = pieData

           // Display Percentage in the Center
               let percentageText = "\(Int(percentage))%"
               let attributedString = NSAttributedString(
                   string: percentageText,
                   attributes: [
                    .font: UIFont(name: "Poppins-Bold", size: 14), // Change font size
                       .foregroundColor: UIColor.black // Change text color
                   ]
               )
               
               pieChartView.centerAttributedText = attributedString
               pieChartView.centerTextRadiusPercent = 0.9
           
           pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInExpo)
       }
    
    func colorForPercentage(_ percentage: Double) -> UIColor {
        switch percentage {
        case 1...20:
            return UIColor.systemRed.withAlphaComponent(0.8)
        case 21...40:
            return UIColor.systemOrange.withAlphaComponent(0.8)
        case 41...60:
            return UIColor.systemYellow.withAlphaComponent(0.8)
        case 61...100:
            return UIColor.systemGreen.withAlphaComponent(0.8)
        default:
            return UIColor.lightGray // Default color (0% or invalid input)
        }
    }

}
