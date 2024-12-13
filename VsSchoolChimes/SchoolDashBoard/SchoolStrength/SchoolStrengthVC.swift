//
//  SchoolStrengthVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 12/12/24.
//

import UIKit
import Charts

class SchoolStrengthVC: UIViewController {

    @IBOutlet weak var TotalStrengthView: UIView!
    @IBOutlet weak var totalCountLbl: UILabel!
    @IBOutlet weak var staffCountLbl: UILabel!
    @IBOutlet weak var studentCountLbl: UILabel!
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var Tv: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    var isBarChartVisible: [Bool] = [false, false, false,false] // Replace with dynamic count if needed
    var classes = ["9th Standard","10th Standard","12th Standard","11th Standard"]
    override func viewDidLoad() {
        super.viewDidLoad()

        TotalStrengthView.layer.cornerRadius = 10
      
        TotalStrengthView.layer.masksToBounds = false
        
        // Shadow to make it look "popped up"
        TotalStrengthView.layer.shadowColor = UIColor.black.cgColor
        TotalStrengthView.layer.shadowOpacity = 0.2
        TotalStrengthView.layer.shadowOffset = CGSize(width: 0, height: 4)
        TotalStrengthView.layer.shadowRadius = 6
        
        // Optional: Add a border for a polished look
        TotalStrengthView.layer.borderColor = UIColor.lightGray.cgColor
        TotalStrengthView.layer.borderWidth = 0.5

        // Background color for the card
        TotalStrengthView.backgroundColor = .white
        
        studentCountLbl.setFont(style: .body, size: FontSize.BodySize)
        staffCountLbl.setFont(style: .body, size: FontSize.BodySize)
        totalCountLbl.setFont(style: .body, size: FontSize.BodySize)
        setupPieChart()
        setChartData()
       
        let nib = UINib(nibName: CellConfingName.StrengthTvCell, bundle: nil)
        Tv.register(nib, forCellReuseIdentifier: CellConfingName.StrengthTvCell)
        
        Tv.delegate = self
        Tv.dataSource = self
    }

    
    @IBAction func BackbtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    private func setupPieChart() {
        // Configure the general look of the pie chart
        pieChartView.usePercentValuesEnabled = true
        pieChartView.drawSlicesUnderHoleEnabled = false
        pieChartView.holeRadiusPercent = 0.0
        pieChartView.transparentCircleRadiusPercent = 0.0
        pieChartView.chartDescription.enabled = true
        pieChartView.drawEntryLabelsEnabled = false
        pieChartView.legend.enabled = false
    }
    
    private func setChartData() {
        // Define the data entries
        let entries = [
            PieChartDataEntry(value: 543, label: "Students"),
            PieChartDataEntry(value: 63, label: "Staff")
        ]
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        if #available(iOS 15.0, *) {
            dataSet.colors = [UIColor.systemMint,UIColor.systemRed]
        } else {
            // Fallback on earlier versions
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

        // Set the value formatter
        dataSet.valueFormatter = DefaultValueFormatter(formatter: numberFormatter)
        
        // Apply the data to the chart
        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
        
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInExpo)
        
        // Refresh chart
        pieChartView.notifyDataSetChanged()
        
//        Greenlabel.text = "Completed"
//        redLabel.text = "Pending"
        // displayPercentages(entries: entries)
    }
    
   

}



extension SchoolStrengthVC: UITableViewDelegate, UITableViewDataSource {
   

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isBarChartVisible.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Tv.dequeueReusableCell(withIdentifier: CellConfingName.StrengthTvCell, for: indexPath) as! StrengthTvCell
        cell.standardLbl.text = classes[indexPath.row]
        
        if isBarChartVisible[indexPath.row] {
            cell.barchartHeight.constant = 150
            cell.barChartView.isHidden = false
            cell.barChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
        } else {
           
            cell.barchartHeight.constant = 0
            cell.barChartView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle the state for the selected row
        isBarChartVisible[indexPath.row] = !isBarChartVisible[indexPath.row]
        
        // Reload the specific row to reflect the change
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
