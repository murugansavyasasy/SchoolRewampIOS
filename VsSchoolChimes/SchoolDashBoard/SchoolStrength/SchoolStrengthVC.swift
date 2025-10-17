//
//  SchoolStrengthVC.swift
//  VsSchoolChimes
//
//  Created by chandhru on 12/12/24.
//

import UIKit
import Charts
import DropDown

class SchoolStrengthVC: UIViewController {

    @IBOutlet weak var norecordLbl: UILabel!
    @IBOutlet weak var norecordImg: UIImageView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var acodomicYearLbl: UILabel!
    @IBOutlet weak var Tv: UITableView!
    @IBOutlet weak var academicyearDrp: UIView!

    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var SchoolStrength: [SchoolStrength]?
    var AcadimicYearDatas: [AcadimicYearData] = []
    var selectedIndexPath: IndexPath?
    var accadimYr: [String] = []
    var acodemicId: Int?
    var chartSet = false
    let acidamicdrops = DropDown()
    var displayArray : [StrengthDisplayModel] = []
    var totalBoys : String?
    var totalgirls : String?
    override func viewDidLoad() {
        super.viewDidLoad()

        UIupdate()
        BackBtn.applyBackButton()
        BackBtn
            .configureAsBackButton(
                firstLine: MenuStringFile.selectedMenuName,
                secondLine: staffDetails?.school_name ?? ""
            )

        let nib = UINib(nibName: CellConfingName.StrengthTvCell, bundle: nil)
        let nib1 = UINib(nibName: CellConfingName.SectionStregnthTVC, bundle: nil)
        Tv.register(nib, forCellReuseIdentifier: CellConfingName.StrengthTvCell)
        Tv.register(nib1, forCellReuseIdentifier: CellConfingName.SectionStregnthTVC)
        Tv.register(UINib(nibName: "SummerizeTvCel", bundle: nil), forCellReuseIdentifier: "SummerizeTvCel")
        Tv.register(UINib(nibName: "GenderDistriTvcel", bundle: nil), forCellReuseIdentifier: "GenderDistriTvcel")
        Tv.register(UINib(nibName: "LblTvCell", bundle: nil), forCellReuseIdentifier: "LblTvCell")
        
      
        Tv.estimatedRowHeight = 100
        Tv.rowHeight = UITableView.automaticDimension

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(academicYearDrop_action))
        academicyearDrp.addGestureRecognizer(tapGesture)

        if localData.accidamic_year_data?.data?.isEmpty == false {
            getacadmicYr()
        }
    }

    
    func createStrengthList(from data: SchoolStrength) -> [StrengthDisplayModel] {
        var list: [StrengthDisplayModel] = []
        
        let totalStudent = Int(data.total_student_strength ?? "0") ?? 0
        let totalStaff = Int(data.total_staff_strength ?? "0") ?? 0
        let total = totalStudent + totalStaff

        
        
        list.append(StrengthDisplayModel(count: totalStaff, name: "Students", previousYear: 12,Girl: Int(data.total_girls_strength ?? "0") ?? 0))
        
        list
            .append(
                StrengthDisplayModel(
                    count: totalStudent,
                    name: "Staff",
                    previousYear: 10,
                    Girl: Int(data.total_girls_strength ?? "0") ?? 0
                )
            )
        list.append(StrengthDisplayModel(count: total, name: "Total", previousYear: 8,Girl: Int(data.total_girls_strength ?? "0") ?? 0))
        
        return list
    }

    func UIupdate() {
        academicyearDrp.setShadow()
    }

    @IBAction func academicYearDrop_action() {
        acidamicdrops.anchorView = academicyearDrp
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: academicyearDrp.bounds.height)
        acidamicdrops.show()
        acidamicdrops.selectionAction = { [weak self] index, item in
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
        displayArray.removeAll()
        APIService.shared.makeApi(
            url: ServiceUrl.admin_api_get_school_strength,
            parameters: [COMMON_PARAMETER.academic_year_id: acodemicId ?? 0],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<SchoolStrengthResponse, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                DispatchQueue.main.async { [self] in
                    self.SchoolStrength = response.data
                    if let firstData = response.data?.first {
                        let strengthList = self.createStrengthList(from: firstData)
                        
                        // இங்கே உங்க chart / progress update function க்கு pass பண்ணலாம்
                        print("✅ Strength List:", strengthList)
                        self.displayArray = strengthList
                    }
                    self.selectedIndexPath = nil
                    self.chartSet = false
                    self.totalBoys = response.data?.first?.total_boys_strength ?? "0"
                    self.totalgirls = response.data?.first?.total_girls_strength ?? "0"
                    let hasData = !(response.data?.isEmpty ?? true)
                    self.norecordLbl.text = response.message
                    self.norecordLbl.isHidden = hasData
                    self.norecordImg.isHidden = hasData
                    self.Tv.delegate = self
                    self.Tv.dataSource = self
                    self.Tv.reloadData()
                    if hasData {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            let indexPath = IndexPath(row: 0, section: 0)
                            if let cell = self.Tv.cellForRow(at: indexPath) as? SectionStregnthTVC {
                                cell.schoolStrength = self.SchoolStrength?.first
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

extension SchoolStrengthVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
//        return (SchoolStrength?.isEmpty ?? true) ? 1 : 2
        
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return section == 0 ? SchoolStrength?.count ?? 0 : (SchoolStrength?.first?.standards?.count ?? 0)
        
        if section == 0 {
            
            return 1
        }else if section == 1 {
            return 1
        }else if section == 2 {
            return 1
        }
        else{
            
            return SchoolStrength?.first?.standards?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SummerizeTvCel", for: indexPath) as? SummerizeTvCel else {
                return UITableViewCell()
            }
            cell.dispalyArray = displayArray
//            if !chartSet {
//                cell.schoolStrength = SchoolStrength?.first
//            }
//            applyShadowAndCornerRadius(to: cell.outerView)
            return cell

        }
        else if indexPath.section == 1 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "GenderDistriTvcel", for: indexPath) as? GenderDistriTvcel else {
                return UITableViewCell()
            }
    
            cell.updateProgress(absentees:totalgirls ?? ""  , total:totalBoys ?? "" )
            return cell
        }
        
        else if indexPath.section == 2{
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LblTvCell", for: indexPath) as? LblTvCell else {
                return UITableViewCell()
            }
            
            
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.StrengthTvCell, for: indexPath) as? StrengthTvCell,
                  let standard = SchoolStrength?.first?.standards?[indexPath.row] else {
                return UITableViewCell()
            }
            
          
            cell.configure(standard.sections)
            cell.updateProgress(boys: String(standard.boys_count ?? 0), girls: String(standard.girls_count ?? 0))
//            cell.boycount = String(standard.boys_count ?? 0)
//            cell.girlscount = String(standard.girls_count ?? 0)
            cell.standardLbl.text = "Standard  " + (standard.name ?? "")
            cell.boysCountLbl.text = "Boys : \(standard.boys_count ?? 0)"
            cell.girlsCountLbl.text = "Girls : \(standard.girls_count ?? 0)"
            cell.countLbl.text = "Total Students: \(standard.total_students ?? "")"

            if standard.girls_count == 0{
                cell.femaleImgView.image = UIImage(named: "males")
                cell.femaleImgView.tintColor = .maleClr
            }
            if standard.boys_count  == 0{
                cell.femaleImgView.image = UIImage(named: "females")
                cell.femaleImgView.tintColor = .femaleClr
            }
            let isExpanded = (indexPath == selectedIndexPath)
            cell.barchartHeight.constant = isExpanded ? cell.sectionCollertionView.collectionViewLayout.collectionViewContentSize.height : 0
            cell.cellview.backgroundColor = isExpanded ? .white : .clear
            cell.cellview.layer.cornerRadius = 10
            cell.cellview.layer.shadowColor = UIColor.black.cgColor
            cell.cellview.layer.shadowOpacity = isExpanded ? 0.3 : 0.0
            cell.cellview.layer.shadowRadius = 4
            cell.cellview.layer.shouldRasterize = true
            cell.cellview.layer.rasterizationScale = UIScreen.main.scale

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 1  ||  indexPath.section != 0 {
            selectedIndexPath = (selectedIndexPath == indexPath) ? nil : indexPath
            chartSet = true
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section{
        case 0 : return 190
        case 1 :  return 150
        case 2 :  return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
        
    }
    
    
}

struct StrengthDisplayModel {
    var count: Int
    var name: String
    var previousYear: Int
    var Girl : Int
}
