//
//  SchoolStrengthVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 12/12/24.
//

import UIKit
import Charts
import DropDown

class SchoolStrengthVC: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var TotalStrengthView: UIView!
    @IBOutlet weak var totalCountLbl: UILabel!
    @IBOutlet weak var staffCountLbl: UILabel!
    @IBOutlet weak var acodomicYearLbl: UILabel!
    @IBOutlet weak var studentCountLbl: UILabel!
    @IBOutlet weak var Tv: UITableView!
    @IBOutlet weak var academicyearDrp: UIView!
    @IBOutlet weak var pieChartView: PieChartView!
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var SchoolStrength : [SchoolStrength]?
    var AcadimicYearDatas : [AcadimicYearData] = []
    var selectedIndexPath: IndexPath?
    var accadimYr :[String] = []
    var acodemicId : Int?
    let acidamicdrops = DropDown()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        UIupdate()
        setupPieChart()
        BackBtn.applyBackButton()
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.SchoolStrength, secondLine: staffDetails?.school_name ?? "")
        getacadmicYr()
        let nib = UINib(nibName: CellConfingName.StrengthTvCell, bundle: nil)
        Tv.register(nib, forCellReuseIdentifier: CellConfingName.StrengthTvCell)
        Tv.register(UINib(nibName: "StandardTVC", bundle: nil), forCellReuseIdentifier: "StandardTVC")
        Tv.register(UINib(nibName: "SectionStregnthTVC", bundle: nil), forCellReuseIdentifier: "SectionStregnthTVC")
        let acidmaciyrClick = UITapGestureRecognizer(target: self, action:
                                                        #selector(academicYearDrop_action))
       
        academicyearDrp.addGestureRecognizer(acidmaciyrClick)
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
       applyShadowAndCornerRadius(to: academicyearDrp)
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
    @IBAction func academicYearDrop_action() {
        acidamicdrops.anchorView = academicyearDrp
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: academicyearDrp.bounds.height)
        acidamicdrops.show()
        acidamicdrops.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            acodemicId = AcadimicYearDatas[index].id
            acodomicYearLbl.text = AcadimicYearDatas[index].year ?? ""
            Get_School_Strength()
        }
        
        
    }
    func getacadmicYr(){
        APIService.shared
            .makeApi(url: ServiceUrl.comm_recipient_get_academic_year_list , parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <get_academic_yearSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            AcadimicYearDatas = successMessage.data ?? []
                            for i in 0..<(AcadimicYearDatas.count){
                                if AcadimicYearDatas[i].current_academic_year ?? false == true{
                                    acodomicYearLbl.text = AcadimicYearDatas[i].year
                                    acodemicId = AcadimicYearDatas[i].id
                                    Get_School_Strength()
                                }
                                accadimYr.append(AcadimicYearDatas[i].year ?? "")
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
    @IBAction func BackbtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    func Get_School_Strength() {
        
        APIService.shared.makeApi(url: ServiceUrl.admin_api_get_school_strength, parameters: [COMMON_PARAMETER.academic_year_id : acodemicId ?? 0], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [self] (result: Result<SchoolStrengthResponse,Error>) in
            
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
                        setChartData()
                        Tv.reloadData()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.StrengthTvCell, for: indexPath) as? StrengthTvCell,
              let standard = SchoolStrength?.first?.standards?[indexPath.row] else {
            return UITableViewCell()
        }

        // Configure standard data
        cell.confic(standard.sections)
        cell.StandardBtn.setTitle(standard.name, for: .normal)
        cell.boysCountLbl.text = "Boys : \(standard.boys_count ?? 0)"
        cell.girlsCountLbl.text = "Girls : \(standard.girls_count ?? 0)"
        cell.countLbl.text = "Total: \(standard.total_students ?? "")"

        let sectionNames = standard.sections?.compactMap { $0.name } ?? []
        let sectionStrengths = standard.sections?.compactMap { Int($0.total_students ?? "") } ?? []
//        cell.setBarChartData(withLabels: sectionNames, sectionCounts: sectionStrengths)

        // Show expanded view and border if selected
        if selectedIndexPath == indexPath {
//            cell.barchartHeight.constant = 150
            cell.barchartHeight.constant = cell.sectionCollertionView.collectionViewLayout.collectionViewContentSize.height
//            cell.barChartView.isHidden = false
//            cell.barChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
            cell.BottomLblHeight.constant = 0
            cell.BottomLbl.isHidden = true
//            cell.SideBtn.isHidden = false
            
            cell.cellview.layer.cornerRadius = 10
            cell.cellview.layer.shadowColor = UIColor.black.cgColor
            cell.cellview.layer.shadowOpacity = 0.5
            cell.layer.shadowOffset = CGSize(width: 4, height: 4)
            cell.cellview.layer.shadowRadius = 4
            cell.cellview.backgroundColor = .white
        } else {
            // Reset to collapsed state
            cell.barchartHeight.constant = 0
            cell.barChartView.isHidden = true
            cell.BottomLblHeight.constant = 0
            cell.BottomLbl.isHidden = true
            cell.SideBtn.isHidden = true
            cell.cellview.layer.cornerRadius = 0
            cell.cellview.layer.shadowColor = UIColor.clear.cgColor
            cell.cellview.layer.shadowOpacity = 0
            cell.cellview.layer.shadowRadius = 0
            cell.cellview.backgroundColor = .clear
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle selection
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil // Deselect
        } else {
            selectedIndexPath = indexPath
        }

        tableView.reloadData() // Refresh UI
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//extension SchoolStrengthVC: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return SchoolStrength?.first?.standards?.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = Tv.dequeueReusableCell(withIdentifier: CellConfingName.StrengthTvCell, for: indexPath) as! StrengthTvCell
//
//        let standard = SchoolStrength?.first?.standards?[indexPath.row]
//        cell.confic(standard?.sections)
//        cell.standardLbl.text = standard?.name
//        cell.countLbl.text = standard?.total_students
//
//        let name = standard?.sections?.compactMap{$0.name} ?? []
//        let strength = standard?.sections?.compactMap {
//            Int($0.total_students ?? "")
//        } ?? []
//
//        cell.setBarChartData(withLabels: name, sectionCounts: strength)
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Safely unwrap the cell
//        if let cell = tableView.cellForRow(at: indexPath) as? StrengthTvCell {
//            // Update UI elements
//            if cell.barChartView.isHidden == true{
//                cell.barchartHeight.constant = cell.sectionCollertionView.collectionViewLayout.collectionViewContentSize.height
//                cell.layer.borderColor = UIColor.black.cgColor
//                cell.layer.borderWidth = 1
////                cell.barChartView.isHidden = false
//                cell.barChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
//                cell.BottomLblHeight.constant = 0 //21
//                cell.BottomLbl.isHidden = true//false
////                cell.SideBtn.isHidden = false
//            }else{
//                cell.barchartHeight.constant = 0
//                cell.barChartView.isHidden = true
//                cell.BottomLblHeight.constant = 0
//                cell.BottomLbl.isHidden = true
//                cell.SideBtn.isHidden = true
//                cell.layer.borderColor = UIColor.clear.cgColor
//                cell.layer.borderWidth = 0
//            }
//            // Animate layout changes
//            tableView.beginUpdates()
//            tableView.endUpdates()
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        // Safely unwrap the cell
//        if let cell = tableView.cellForRow(at: indexPath) as? StrengthTvCell {
//            // Reset UI elements
//            cell.barchartHeight.constant = 0
//            cell.barChartView.isHidden = true
//            cell.BottomLblHeight.constant = 0
//            cell.BottomLbl.isHidden = true
//            cell.SideBtn.isHidden = true
//
//            // Animate layout changes
//            tableView.beginUpdates()
//            tableView.endUpdates()
//        }
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//}
//import UIKit
//import Charts
//
//class SchoolStrengthVC: UIViewController {
//
//    @IBOutlet weak var BackBtn: UIButton!
//    @IBOutlet weak var TotalStrengthView: UIView!
//    @IBOutlet weak var totalCountLbl: UILabel!
//    @IBOutlet weak var staffCountLbl: UILabel!
//    @IBOutlet weak var studentCountLbl: UILabel!
//    @IBOutlet weak var Tv: UITableView!
//    @IBOutlet weak var pieChartView: PieChartView!
//
//    var staffDetails = UserDefaultFileManager.get_staff_Details()
//    var SchoolStrength : [SchoolStrength]?
//    var StandardStrength : [Standard]?
//    var expandedSections: Set<Int> = []
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        UIupdate()
//        setupPieChart()
//        BackBtn.applyBackButton()
//        BackBtn.configureAsBackButton(firstLine: MenuStringFile.SchoolStrength, secondLine: staffDetails?.school_name ?? "")
//
//        Get_School_Strength()
//        let nib = UINib(nibName: CellConfingName.StrengthTvCell, bundle: nil)
//        Tv.register(nib, forCellReuseIdentifier: CellConfingName.StrengthTvCell)
//        Tv.register(UINib(nibName: "StandardTVC", bundle: nil), forHeaderFooterViewReuseIdentifier: "StandardTVC")
//        Tv.register(UINib(nibName: "SectionStregnthTVC", bundle: nil), forCellReuseIdentifier: "SectionStregnthTVC")
//        Tv.delegate = self
//        Tv.dataSource = self
//    }
//    override func viewDidLayoutSubviews() {
//        view.applyGradient(
//            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
//            startPoint: CGPoint(x: 1, y: 0.5),
//            endPoint: CGPoint(x: 0, y: 0.5)
//        )
//    }
//
//   func UIupdate(){
//       TotalStrengthView.layer.cornerRadius = 10
//       TotalStrengthView.layer.masksToBounds = false
//
//       // Shadow to make it look "popped up"
//       TotalStrengthView.layer.shadowColor = UIColor.black.cgColor
//       TotalStrengthView.layer.shadowOpacity = 0.2
//       TotalStrengthView.layer.shadowOffset = CGSize(width: 0, height: 4)
//       TotalStrengthView.layer.shadowRadius = 6
//
//       // Optional: Add a border for a polished look
//       TotalStrengthView.layer.borderColor = UIColor.lightGray.cgColor
//       TotalStrengthView.layer.borderWidth = 0.5
//
//       // Background color for the card
//       TotalStrengthView.backgroundColor = .white
//
//       studentCountLbl.setFont(style: .body, size: FontSize.BodySize)
//       staffCountLbl.setFont(style: .body, size: FontSize.BodySize)
//       totalCountLbl.setFont(style: .body, size: FontSize.BodySize)
//    }
//
//    @IBAction func BackbtnAct(_ sender: Any) {
//
//        dismiss(animated: true)
//    }
//
//    func Get_School_Strength() {
//
//        APIService.shared.makeApi(url: ServiceUrl.admin_api_get_school_strength, parameters: [COMMON_PARAMETER.academic_year_id : 6], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [self] (result: Result<SchoolStrengthResponse,Error>) in
//
//            switch result {
//
//
//            case .success(let successMessage):
//
//                if successMessage.status == true {
//                    DispatchQueue.main.async { [self] in
//
//                        SchoolStrength = successMessage.data
//                        let total = (Int(SchoolStrength?.first?.total_student_strength ?? "0") ?? 0) + (Int(SchoolStrength?.first?.total_staff_strength ?? "0") ?? 0)
//                        studentCountLbl.text = "Students - \(SchoolStrength?.first?.total_student_strength ?? "")"
//                        staffCountLbl.text = "Staffs - \(SchoolStrength?.first?.total_staff_strength ?? "")"
//                        totalCountLbl.text = "Total - \(total)"
//                        StandardStrength = SchoolStrength?.first?.standards
//                        setChartData()
//                        Tv.reloadData()
//                    }
//                }else {
//
//                    DispatchQueue.main.async { [self] in
//
//                        SchoolStrength = successMessage.data
//                    }
//                }
//
//            case .failure(let error):
//
//                print("Error: \(error.localizedDescription)")
//            }
//
//        }
//    }
//
//    private func setupPieChart() {
//        // Configure the general look of the pie chart
//        pieChartView.usePercentValuesEnabled = true
//        pieChartView.drawSlicesUnderHoleEnabled = false
//        pieChartView.holeRadiusPercent = 0.0
//        pieChartView.transparentCircleRadiusPercent = 0.0
//        pieChartView.chartDescription.enabled = true
//        pieChartView.drawEntryLabelsEnabled = false
//        pieChartView.legend.enabled = false
//    }
//
//    private func setChartData() {
//
//        let studentcount = Double(SchoolStrength?.first?.total_student_strength ?? "0") ?? 0
//        let staffcount = Double(SchoolStrength?.first?.total_staff_strength ?? "0") ?? 0
//
//        // Define the data entries
//        let entries = [
//            PieChartDataEntry(value: studentcount, label: "Students"),
//            PieChartDataEntry(value: staffcount, label: "Staff")
//        ]
//
//        let dataSet = PieChartDataSet(entries: entries, label: "")
//        if #available(iOS 15.0, *) {
//            dataSet.colors = [UIColor.systemMint,UIColor.systemRed]
//        }
//        // Enable value display and format as percentages
//        dataSet.drawValuesEnabled = false
//        dataSet.valueTextColor = .white // Customize text color
//        dataSet.valueFont = UIFont.systemFont(ofSize: 14) // Customize text font
//
//        // Configure number formatter for percentage values
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .percent
//        numberFormatter.maximumFractionDigits = 1
//        numberFormatter.multiplier = 1
//
//        // Set the value formatter
//        dataSet.valueFormatter = DefaultValueFormatter(formatter: numberFormatter)
//
//        // Apply the data to the chart
//        let data = PieChartData(dataSet: dataSet)
//        pieChartView.data = data
//
//        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInExpo)
//
//        // Refresh chart
//        pieChartView.notifyDataSetChanged()
//    }
//}
//
//extension SchoolStrengthVC: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return StandardStrength?.count ?? 0
//    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "StandardTVC") as! StandardTVC
//        cell.standerdNameLbl.text = StandardStrength?[section].name
//        cell.totalCountLbl.layer.cornerRadius = 8
//        cell.totalCountLbl.setTitle("\(StandardStrength?[section].total_students ?? "") Students", for: .normal)
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSection(_:)))
//        cell.tag = section
//        cell.addGestureRecognizer(tapGesture)
//
//
//        if expandedSections.contains(section){
//            cell.arrowBtn.setImage(UIImage(named: "arrow_up"), for: .normal)
//
//        }else{
//            cell.arrowBtn.setImage(UIImage(named: "arrow_down"), for: .normal)
//        }
//        return cell
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return expandedSections.contains(section) ? (StandardStrength?[section].sections?.count ?? 0) : 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = Tv.dequeueReusableCell(withIdentifier: "SectionStregnthTVC", for: indexPath) as! SectionStregnthTVC
//
//        if let section = StandardStrength?[indexPath.section],
//           let secList = section.sections?[indexPath.row] {
//
//            // Safely unwrap each count and update labels
//            let boysCount = secList.boys_count ?? 0
//            let girlsCount = secList.girls_count ?? 0
//            let othersCount = secList.other_count ?? 0
//
//            cell.boysCountLbl.text = "👦 \(boysCount)"
//            cell.girlsCountLbl.text = "👧 \(girlsCount)"
//            cell.otersCountLbl.text = "🧑 \(othersCount)"
//
//            // Hide labels if the value is 0
//            cell.boysCountLbl.isHidden = boysCount == 0
//            cell.girlsCountLbl.isHidden = girlsCount == 0
//            cell.otersCountLbl.isHidden = othersCount == 0
//        }
//
//        return cell
//    }
//
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Safely unwrap the cell
//        if let cell = tableView.cellForRow(at: indexPath) as? StrengthTvCell {
//            // Update UI elements
//            if cell.barChartView.isHidden == true{
//                cell.barchartHeight.constant = 170
//                cell.barChartView.isHidden = false
//                cell.barChartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
//                cell.BottomLblHeight.constant = 0 //21
//                cell.BottomLbl.isHidden = true//false
//                cell.SideBtn.isHidden = false
//            }else{
//                cell.barchartHeight.constant = 0
//                cell.barChartView.isHidden = true
//                cell.BottomLblHeight.constant = 0
//                cell.BottomLbl.isHidden = true
//                cell.SideBtn.isHidden = true
//            }
//            // Animate layout changes
//            tableView.beginUpdates()
//            tableView.endUpdates()
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        // Safely unwrap the cell
//        if let cell = tableView.cellForRow(at: indexPath) as? StrengthTvCell {
//            // Reset UI elements
//            cell.barchartHeight.constant = 0
//            cell.barChartView.isHidden = true
//            cell.BottomLblHeight.constant = 0
//            cell.BottomLbl.isHidden = true
//            cell.SideBtn.isHidden = true
//
//            // Animate layout changes
//            tableView.beginUpdates()
//            tableView.endUpdates()
//        }
//    }
//    @objc func toggleSection(_ sender: UITapGestureRecognizer) {
//        guard let headerView = sender.view else { return }
//        let section = headerView.tag
//
//        var sectionsToReload = IndexSet()
//
//        if expandedSections.contains(section) {
//            expandedSections.remove(section)
//            sectionsToReload.insert(section)
//        } else {
//            if let previousSection = expandedSections.first {
//                expandedSections.remove(previousSection)
//                sectionsToReload.insert(previousSection)
//            }
//
//            expandedSections.insert(section)
//            sectionsToReload.insert(section)
//        }
//
//        Tv.reloadSections(sectionsToReload, with: .automatic)
//    }
//}
