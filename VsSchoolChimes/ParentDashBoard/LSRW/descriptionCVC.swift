//
//  descriptionCVC.swift
//  School Chimes
//
//  Created by Chandhru on 20/12/25.
//

import UIKit
import Charts

class descriptionCVC: UICollectionViewCell {

    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var outerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupPieChart()
        
        // ✅ Configure label for proper text wrapping
        descriptionLbl.numberOfLines = 0
        descriptionLbl.lineBreakMode = .byWordWrapping
        descriptionLbl.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        
        // ✅ Add corner radius and shadow to outer view
        outerView.layer.cornerRadius = 12
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.08
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 8
        outerView.layer.masksToBounds = false
    }
    
    // ✅ CRITICAL: Set preferredMaxLayoutWidth when bounds change
    override func layoutSubviews() {
        super.layoutSubviews()
        // Account for stackview margins and spacing (10 left + 10 right + 20 icon + 10 spacing + 100 pie chart + 10 spacing)
        let availableWidth = bounds.width - 160
        descriptionLbl.preferredMaxLayoutWidth = availableWidth
    }
    
    private func setupPieChart() {
        pieChartView.holeRadiusPercent = 0.6
        pieChartView.transparentCircleRadiusPercent = 0.65
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.legend.enabled = false
        pieChartView.chartDescription.enabled = false
        pieChartView.holeColor = UIColor.white
        pieChartView.rotationEnabled = false
        pieChartView.highlightPerTapEnabled = false
    }

    func setProgress(to percentage: Double) {
        let progressEntry = PieChartDataEntry(value: percentage, label: nil)
        let emptyEntry = PieChartDataEntry(value: 100 - percentage, label: nil)
        
        let progressColor = colorForPercentage(percentage)
        let progressDataSet = PieChartDataSet(entries: [progressEntry, emptyEntry], label: "")
        progressDataSet.colors = [
            progressColor,
            UIColor.lightGray.withAlphaComponent(0.3)
        ]
        progressDataSet.drawValuesEnabled = false
        progressDataSet.sliceSpace = 2

        let pieData = PieChartData(dataSet: progressDataSet)
        pieChartView.data = pieData

        // Center text with percentage
        let percentageText = "\(Int(percentage))%"
        let attributedString = NSAttributedString(
            string: percentageText,
            attributes: [
                .font: UIFont(name: "Poppins-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.black
            ]
        )
        pieChartView.centerAttributedText = attributedString
        pieChartView.centerTextRadiusPercent = 0.9
        
        // Animate the chart
        pieChartView.animate(xAxisDuration: 0.8, easingOption: .easeOutCubic)
    }
    
    func colorForPercentage(_ percentage: Double) -> UIColor {
        switch percentage {
        case 0:
            return UIColor.systemRed.withAlphaComponent(0.8)
        case 1..<25:
            return UIColor.systemRed.withAlphaComponent(0.7)
        case 25..<50:
            return UIColor.systemOrange.withAlphaComponent(0.8)
        case 50..<75:
            return UIColor.systemYellow.withAlphaComponent(0.8)
        case 75..<100:
            return UIColor.systemGreen.withAlphaComponent(0.7)
        case 100:
            return UIColor.systemGreen.withAlphaComponent(0.9)
        default:
            return UIColor.lightGray
        }
    }
    
    // ✅ Configure cell with text and percentage
    func configure(text: String?, percentage: Double?) {
        descriptionLbl.text = text
        
        if let percentage = percentage {
            pieChartView.isHidden = false
            setProgress(to: percentage)
        } else {
            pieChartView.isHidden = true
        }
    }
    
    // ✅ Prepare for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        descriptionLbl.text = nil
        pieChartView.clear()
    }
}
