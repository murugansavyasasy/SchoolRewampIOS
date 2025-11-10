//
//  QuizCompletedFirstTv.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 09/09/25.
//

import UIKit
import Charts

class QuizCompletedFirstTv: UITableViewCell {

    @IBOutlet weak var subjectQuiz: UILabel!
    @IBOutlet weak var completedAtLbl: UILabel!
    @IBOutlet weak var wishesLbl: UILabel!
    @IBOutlet weak var notAnsBtn: UIButton!
    @IBOutlet weak var wrongBtn: UIButton!
    @IBOutlet weak var crtBtn: UIButton!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        fullview.layer.cornerRadius = 10
        fullview.backgroundColor = .white
        wrongBtn.setTitleFont(style: .primary, size: 10)
        wrongBtn.layer.cornerRadius = 10
        notAnsBtn.layer.cornerRadius = 10
        crtBtn.layer.cornerRadius = 10
        notAnsBtn.setTitleFont(style: .primary, size: 10)
        crtBtn.setTitleFont(style: .primary, size: 10)
        setupPieChart()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    
    func configureButton(_ button: UIButton, systemImageName: String, title: String, tintColor: UIColor) {
        let image = UIImage(systemName: systemImageName)
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        
        // Text and image spacing
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        
        // Alignment & color
        button.tintColor = tintColor
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.semanticContentAttribute = .forceLeftToRight
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
           
           let progressColor = UIColor.primery //UIColor.systemYellow.withAlphaComponent(0.8)
//           SideColourView.backgroundColor = progressColor.withAlphaComponent(0.6)

           let progressDataSet = PieChartDataSet(entries: [progressEntry, emptyEntry], label: "Hello")
           progressDataSet.colors = [
            progressColor,
            UIColor.lightGray.withAlphaComponent(0.6)
           ]
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
           
//           if isAnimate{
//               pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInExpo)
//           }
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
            return UIColor.systemOrange.withAlphaComponent(0.8)
        case 100:
            return UIColor.systemGreen.withAlphaComponent(0.8)
        default:
            return UIColor.lightGray // Default color (0% or invalid input)
        }
    }
    
}
