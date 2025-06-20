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

           let nib = UINib(nibName: CellConfingName.StrengthTvCell, bundle: nil)
           Tv.register(nib, forCellReuseIdentifier: CellConfingName.StrengthTvCell)
           Tv.delegate = self
           Tv.dataSource = self
           Tv.estimatedRowHeight = 100
           Tv.rowHeight = UITableView.automaticDimension

           let acidmaciyrClick = UITapGestureRecognizer(target: self, action:#selector(academicYearDrop_action))
           academicyearDrp.addGestureRecognizer(acidmaciyrClick)

           if localData.accidamic_year_data?.data?.isEmpty == false {
               getacadmicYr()
           }
       }

       override func viewDidLayoutSubviews() {
           view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5), endPoint: CGPoint(x: 0, y: 0.5))
       }

       func UIupdate() {
           TotalStrengthView.layer.cornerRadius = 10
           TotalStrengthView.layer.shadowColor = UIColor.black.cgColor
           TotalStrengthView.layer.shadowOpacity = 0.2
           TotalStrengthView.layer.shadowOffset = CGSize(width: 0, height: 4)
           TotalStrengthView.layer.shadowRadius = 6
           TotalStrengthView.layer.borderColor = UIColor.lightGray.cgColor
           TotalStrengthView.layer.borderWidth = 0.5
           TotalStrengthView.backgroundColor = .white

           applyShadowAndCornerRadius(to: academicyearDrp)

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
               self.acodemicId = localData.accidamic_year_data?.data?[index].id
               self.acodomicYearLbl.text = item
               self.Get_School_Strength()
           }
       }

       func getacadmicYr() {
           accadimYr = localData.accidamic_year_data?.data?.compactMap { $0.year } ?? []
           acodomicYearLbl.text = accadimYr.last ?? ""
           acodemicId = localData.accidamic_year_data?.data?.last?.id ?? 0
           Get_School_Strength()
       }

       @IBAction func BackbtnAct(_ sender: Any) {
           dismiss(animated: true)
       }

       func Get_School_Strength() {
           APIService.shared.makeApi(url: ServiceUrl.admin_api_get_school_strength, parameters: [COMMON_PARAMETER.academic_year_id: acodemicId ?? 0], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (result: Result<SchoolStrengthResponse, Error>) in
               guard let self = self else { return }

               switch result {
               case .success(let response):
                   DispatchQueue.main.async {
                       self.SchoolStrength = response.data
                       let studentCount = Int(response.data?.first?.total_student_strength ?? "0") ?? 0
                       let staffCount = Int(response.data?.first?.total_staff_strength ?? "0") ?? 0
                       self.studentCountLbl.text = "Students - \(studentCount)"
                       self.staffCountLbl.text = "Staffs - \(staffCount)"
                       self.totalCountLbl.text = "Total - \(studentCount + staffCount)"
                       self.setChartData()
                       UIView.transition(with: self.Tv, duration: 0.3, options: .transitionCrossDissolve) {
                           self.Tv.reloadData()
                       }
                   }
               case .failure(let error):
                   print("Error: \(error.localizedDescription)")
               }
           }
       }

       private func setupPieChart() {
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

           let entries = [
               PieChartDataEntry(value: studentcount, label: "Students"),
               PieChartDataEntry(value: staffcount, label: "Staff")
           ]

           let dataSet = PieChartDataSet(entries: entries, label: "")
           if #available(iOS 15.0, *) {
               dataSet.colors = [UIColor.systemMint, UIColor.systemRed]
           }
           dataSet.drawValuesEnabled = false
           dataSet.valueTextColor = .white
           dataSet.valueFont = .systemFont(ofSize: 14)

           let numberFormatter = NumberFormatter()
           numberFormatter.numberStyle = .percent
           numberFormatter.maximumFractionDigits = 1
           numberFormatter.multiplier = 1
           dataSet.valueFormatter = DefaultValueFormatter(formatter: numberFormatter)

           pieChartView.data = PieChartData(dataSet: dataSet)
           pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutBack)
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

           cell.confic(standard.sections)
           cell.StandardBtn.setTitle(standard.name, for: .normal)
           cell.boysCountLbl.text = "Boys : \(standard.boys_count ?? 0)"
           cell.girlsCountLbl.text = "Girls : \(standard.girls_count ?? 0)"
           cell.countLbl.text = "Total: \(standard.total_students ?? "")"

           if selectedIndexPath == indexPath {
               cell.barchartHeight.constant = cell.sectionCollertionView.collectionViewLayout.collectionViewContentSize.height
               cell.BottomLblHeight.constant = 0
               cell.BottomLbl.isHidden = true
               cell.cellview.layer.cornerRadius = 10
               cell.cellview.layer.shadowColor = UIColor.black.cgColor
               cell.cellview.layer.shadowOpacity = 0.5
               cell.cellview.layer.shadowRadius = 4
               cell.cellview.layer.shouldRasterize = true
               cell.cellview.layer.rasterizationScale = UIScreen.main.scale
               cell.cellview.backgroundColor = .white
           } else {
               cell.barchartHeight.constant = 0
               cell.barChartView.isHidden = true
               cell.BottomLblHeight.constant = 0
               cell.BottomLbl.isHidden = true
               cell.SideBtn.isHidden = true
               cell.cellview.layer.shadowOpacity = 0
               cell.cellview.backgroundColor = .clear
           }

           return cell
       }

       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           selectedIndexPath = (selectedIndexPath == indexPath) ? nil : indexPath
           tableView.reloadData()
       }

       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return UITableView.automaticDimension
       }
   }
