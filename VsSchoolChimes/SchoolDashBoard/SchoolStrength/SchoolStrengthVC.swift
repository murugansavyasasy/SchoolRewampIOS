//
//  SchoolStrengthVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 12/12/24.
//

import UIKit
import Charts

class SchoolStrengthVC: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var TotalStrengthView: UIView!
    @IBOutlet weak var totalCountLbl: UILabel!
    @IBOutlet weak var staffCountLbl: UILabel!
    @IBOutlet weak var studentCountLbl: UILabel!
    @IBOutlet weak var Tv: UITableView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    var isBarChartVisible: [Bool] = [false, false, false,false] // Replace with dynamic count if needed
    var classes = ["9th Standard","10th Standard","12th Standard","11th Standard"]
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    
    var SchoolStrength : [SchoolStrength]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        UIupdate()
        setupPieChart()
        BackBtn.applyBackButton()
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.SchoolStrength, secondLine: staffDetails?.school_name ?? "")
        
        Get_School_Strength()
        let nib = UINib(nibName: CellConfingName.StrengthTvCell, bundle: nil)
        Tv.register(nib, forCellReuseIdentifier: CellConfingName.StrengthTvCell)
        
        Tv.delegate = self
        Tv.dataSource = self
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
   func UIupdate(){
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
    }
    
    @IBAction func BackbtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    func Get_School_Strength() {
        
        APIService.shared.makeApi(url: ServiceUrl.admin_api_get_school_strength, parameters: [COMMON_PARAMETER.academic_year_id : 6], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [self] (result: Result<SchoolStrengthResponse,Error>) in
            
            switch result {
                
                
            case .success(let successMessage):
                
                if successMessage.status == true {
                    DispatchQueue.main.async { [self] in
                        
                        SchoolStrength = successMessage.data
                        let total = (Int(SchoolStrength?.first?.total_student_strength ?? "0") ?? 0) + (Int(SchoolStrength?.first?.total_staff_strength ?? "0") ?? 0)
                        studentCountLbl.text = "Students - \(SchoolStrength?.first?.total_student_strength ?? "")"
                        staffCountLbl.text = "Staffs - \(SchoolStrength?.first?.total_staff_strength ?? "")"
                        totalCountLbl.text = "Total - \(total)"
                        setChartData()
                        Tv.reloadData()
                    }
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        
                        SchoolStrength = successMessage.data
                    }
                }
                
            case .failure(let error):
                
                print("Error: \(error.localizedDescription)")
            }
            
        }
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
        
        let studentcount = Double(SchoolStrength?.first?.total_student_strength ?? "0") ?? 0
        let staffcount = Double(SchoolStrength?.first?.total_staff_strength ?? "0") ?? 0
        
        // Define the data entries
        let entries = [
            PieChartDataEntry(value: studentcount, label: "Students"),
            PieChartDataEntry(value: staffcount, label: "Staff")
        ]
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        if #available(iOS 15.0, *) {
            dataSet.colors = [UIColor.systemMint,UIColor.systemRed]
        }
        // Enable value display and format as percentages
        dataSet.drawValuesEnabled = false
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
    }
}

extension SchoolStrengthVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SchoolStrength?.first?.standards?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Tv.dequeueReusableCell(withIdentifier: CellConfingName.StrengthTvCell, for: indexPath) as! StrengthTvCell
        
        let standard = SchoolStrength?.first?.standards?[indexPath.row]
        
        cell.standardLbl.text = standard?.name
        cell.countLbl.text = standard?.total_students
        
        let name = standard?.sections?.compactMap{$0.name} ?? []
        let strength = standard?.sections?.compactMap {
            Int($0.total_students ?? "")
        } ?? []
        
        cell.setBarChartData(withLabels: name, sectionCounts: strength)
        
//        if isBarChartVisible[indexPath.row] {
//            cell.barchartHeight.constant = 150
//            cell.barChartView.isHidden = false
//            cell.barChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
//            cell.BottomLblHeight.constant = 21
//            cell.BottomLbl.isHidden = false
//        } else {
//            
//            cell.barchartHeight.constant = 0
//            cell.barChartView.isHidden = true
//            cell.BottomLblHeight.constant = 0
//            cell.BottomLbl.isHidden = true
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Safely unwrap the cell
        if let cell = tableView.cellForRow(at: indexPath) as? StrengthTvCell {
            // Update UI elements
            if cell.barChartView.isHidden == true{
                cell.barchartHeight.constant = 150
                cell.barChartView.isHidden = false
                cell.barChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
                cell.BottomLblHeight.constant = 0 //21
                cell.BottomLbl.isHidden = true//false
                cell.SideBtn.isHidden = false
            }else{
                cell.barchartHeight.constant = 0
                cell.barChartView.isHidden = true
                cell.BottomLblHeight.constant = 0
                cell.BottomLbl.isHidden = true
                cell.SideBtn.isHidden = true
            }
            // Animate layout changes
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Safely unwrap the cell
        if let cell = tableView.cellForRow(at: indexPath) as? StrengthTvCell {
            // Reset UI elements
            cell.barchartHeight.constant = 0
            cell.barChartView.isHidden = true
            cell.BottomLblHeight.constant = 0
            cell.BottomLbl.isHidden = true
            cell.SideBtn.isHidden = true
            
            // Animate layout changes
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
