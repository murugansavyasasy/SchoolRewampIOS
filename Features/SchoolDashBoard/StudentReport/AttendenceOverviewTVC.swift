//
//  AttendenceOverviewTVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/03/26.
//

import UIKit
import DGCharts

class AttendenceOverviewTVC: UITableViewCell {
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var percentagepichart: PieChartView!
    @IBOutlet weak var presenrtIconBtn: UIButton!
    @IBOutlet weak var absentIconBtn: UIButton!
    @IBOutlet weak var leaveIconBtn: UIButton!
    @IBOutlet weak var presentDayLbl: UILabel!
    @IBOutlet weak var absentDayLbl: UILabel!
    @IBOutlet weak var leaveLbl: UILabel!
    @IBOutlet weak var weekSatack: UIStackView!
    @IBOutlet var dayLbl: [UILabel]!
    @IBOutlet var dayCountBtn: [UIButton]!
    override func awakeFromNib() {
        super.awakeFromNib()
        absentIconBtn.layer.cornerRadius = absentIconBtn.frame.height/2
        leaveIconBtn.layer.cornerRadius = leaveIconBtn.frame.height/2
        presenrtIconBtn.layer.cornerRadius = presenrtIconBtn.frame.height/2
        percentagepichart.usePercentValuesEnabled = false
        percentagepichart.chartDescription.enabled = false
        outerView.setShadow()
    }
    func configure(data: AttendanceOverview?) {
        
        guard let data = data else { return }
        
        let present = Double(data.presentDays ?? 0)
        let absent = Double(data.absentDays ?? 0)
        let leave = Double(data.leaveDays ?? 0)
        
        let total = present + absent + leave
        
        let percentage = total == 0 ? 0 : (present / total) * 100
        
        // Update Labels
        presentDayLbl.text = "\(Int(present)) days"
        absentDayLbl.text = "\(Int(absent)) days"
        leaveLbl.text = "\(Int(leave)) days"
        
        setupPieChart(present: present, absent: absent, leave: leave, percentage: percentage)
        
        setupWeekData(data.weeklyAttendance)
    }
    private func setupPieChart(present: Double, absent: Double, leave: Double, percentage: Double) {
        
        let entries = [
            PieChartDataEntry(value: present),
            PieChartDataEntry(value: absent),
            PieChartDataEntry(value: leave)
        ]
        
        let dataSet = PieChartDataSet(entries: entries)
        
        dataSet.colors = [
            UIColor.systemGreen,
            UIColor.systemRed,
            UIColor.systemOrange
        ]
        
        dataSet.drawValuesEnabled = false
        
        let data = PieChartData(dataSet: dataSet)
        
        percentagepichart.data = data
        
        // Donut Style
        percentagepichart.drawHoleEnabled = true
        percentagepichart.holeRadiusPercent = 0.75
        percentagepichart.transparentCircleRadiusPercent = 0.80
        
        // Center Text
        let centerText = NSMutableAttributedString(
            string: "\(Int(percentage))%\n",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor.label
            ]
        )
        
        let subText = NSAttributedString(
            string: "Present",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        
        centerText.append(subText)
        
        percentagepichart.centerAttributedText = centerText
        
        // Remove Extra UI
        percentagepichart.legend.enabled = false
        percentagepichart.rotationEnabled = false
        percentagepichart.highlightPerTapEnabled = false
        percentagepichart.entryLabelColor = .clear
    }
    private func setupWeekData(_ weekly: [DayAttendance]?) {
        
        guard let weekly = weekly else { return }
        
        for (index, day) in weekly.enumerated() {
            
            dayLbl[index].text = String(day.dayName?.prefix(1) ?? "").uppercased()
            
            if index < dayCountBtn.count {
                
                switch day.status {
                case .present:
                    dayCountBtn[index].backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
                    dayCountBtn[index].tintColor = UIColor.systemGreen
                case .absent:
                    dayCountBtn[index].backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
                    dayCountBtn[index].tintColor = UIColor.systemRed
                case .leave:
                    dayCountBtn[index].backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
                    dayCountBtn[index].tintColor = UIColor.systemOrange
                case .holiday:
                    dayCountBtn[index].backgroundColor = UIColor.systemGray5
                    dayCountBtn[index].tintColor = UIColor.systemGray
                    
                case .none:
                    dayCountBtn[index].backgroundColor = UIColor.systemGray5
                    dayCountBtn[index].tintColor = UIColor.systemGray
                }
                dayCountBtn[index].layer.cornerRadius = 12
            }
        }
    }
}
