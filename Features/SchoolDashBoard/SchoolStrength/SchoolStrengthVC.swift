//
//  SchoolStrengthVC.swift
//  VsSchoolChimes
//
//  Created by chandhru on 12/12/24.
//

import UIKit

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
    var totalStudents : String?
    var totalStaffs : String?
    var previousData : Previous?
    let Total = "Total".translated()
    let Students = "Students".translated()
    let Staff = "Staff".translated()
    let Standard = "Standard".translated()
    let Boys = "Boys".translated()
    let Girls = "Girls".translated()
    let NotSpecified = "Not specified".translated()
    let TotalStudents = "Total Students".translated()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIupdate()
        BackBtn.applyBackButton()
        BackBtn
            .configureAsBackButton(
                firstLine: MenuStringFile.selectedMenuName,
                secondLine: staffDetails?.school_name ?? "")
        let nib = UINib(nibName: CellConfingName.StrengthTvCell, bundle: nil)
        Tv.register(nib, forCellReuseIdentifier: CellConfingName.StrengthTvCell)
        Tv.register(UINib(nibName: CellConfingName.SummerizeTvCel, bundle: nil), forCellReuseIdentifier: CellConfingName.SummerizeTvCel)
        Tv.register(UINib(nibName: CellConfingName.GenderDistriTvcel, bundle: nil), forCellReuseIdentifier: CellConfingName.GenderDistriTvcel)
        Tv.register(UINib(nibName: CellConfingName.LblTvCell, bundle: nil), forCellReuseIdentifier: CellConfingName.LblTvCell)
        Tv.estimatedRowHeight = 100
        Tv.rowHeight = UITableView.automaticDimension
        Tv.showsVerticalScrollIndicator = false
        Tv.showsHorizontalScrollIndicator = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(academicYearDrop_action))
        academicyearDrp.addGestureRecognizer(tapGesture)
        if localData.accidamic_year_data?.data?.isEmpty == false {
            getAcademicYear()
        }
    }
    
    func createStrengthList(from data: SchoolStrength) -> [StrengthDisplayModel] {
        var list: [StrengthDisplayModel] = []
        let totalStudent = Int(data.total_student_strength ?? "0") ?? 0
        let totalStaff = Int(data.total_staff_strength ?? "0") ?? 0
        let total = totalStudent + totalStaff
        let totalPreviousYear = Int(previousData?.total_student_strength ?? "0") ?? 0 + (
            Int(previousData?.total_staff_strength ?? "0") ?? 0
        )
        list.append(
            StrengthDisplayModel(
                Total: total,
                name: Total,
                previousYear: totalPreviousYear,
                Girl:Int(data.total_student_strength ?? "0") ?? 0,
                boys:  Int(data.total_staff_strength ?? "0") ?? 0,
                others: 0,
                message: previousData?.message ?? ""))
        list.append(
            StrengthDisplayModel(
                Total: totalStudent,
                name: Students,
                previousYear: Int(previousData?.total_student_strength ?? "") ?? 0,
                Girl: Int(data.total_girls_strength ?? "0") ?? 0,
                boys: Int(data.total_boys_strength ?? "0") ?? 0,
                others: Int(data.total_others_strength ?? "0") ?? 0,
                message: previousData?.message ?? ""
            )
        )
        list.append(
            StrengthDisplayModel(
                Total: totalStaff,
                name: Staff,
                previousYear: Int(previousData?.total_staff_strength ?? "") ?? 0,
                Girl: Int(data.total_female_staffs_strength ?? "0") ?? 0,
                boys: Int(data.total_male_staffs_strength ?? "0") ?? 0,
                others: Int(data.total_other_staffs_strength ?? "0") ?? 0,
                message: previousData?.message ?? ""
            )
        )
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
    
//    func getacadmicYr() {
//        for i in 0..<(localData.accidamic_year_data?.data?.count ?? 0){
////            if let year = localData.accidamic_year_data?.data?[i].year{
////                AcademicList.append(year)
////            }
//            if localData.accidamic_year_data?.data?[i].current_academic_year == true {
//                acodomicYearLbl.text = localData.accidamic_year_data?.data?[i].year
//                acodemicId = localData.accidamic_year_data?.data?[i].id
//            }
//        }
//        accadimYr = localData.accidamic_year_data?.data?.compactMap { $0.year } ?? []
//        Get_School_Strength()
//    }
    
    func getAcademicYear() {
       let academicData = localData.accidamic_year_data?.data

        accadimYr = academicData?.compactMap { $0.year } ?? []

        // Get current academic year first
        let currentYear = academicData?.first(where: { $0.current_academic_year == true })
        acodomicYearLbl.text = currentYear?.year
        acodemicId = currentYear?.id

        // Now safely call this since acodemicId is set
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
            token: staffDetails?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<SchoolStrengthResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async { [self] in
                    self.SchoolStrength = response.data
                    self.previousData = response.data?.first?.previous
                    if let firstData = response.data?.first {
                        let strengthList = self.createStrengthList(from: firstData)
                        self.displayArray = strengthList
                    }
                    self.selectedIndexPath = nil
                    self.chartSet = false
                    self.totalStudents = response.data?.first?.total_student_strength ?? "0"
                    self.totalStaffs = response.data?.first?.total_staff_strength ?? "0"
                    let hasData = !(response.data?.isEmpty ?? true)
                    self.norecordLbl.text = response.message
                    self.norecordLbl.isHidden = hasData
                    self.norecordImg.isHidden = hasData
                    if response.status == true{
                        self.Tv.isHidden = false
                        self.Tv.delegate = self
                        self.Tv.dataSource = self
                        self.Tv.reloadData()
                    }else{
                        self.Tv.isHidden = true
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
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SummerizeTvCel, for: indexPath) as? SummerizeTvCel else {
                return UITableViewCell()
            }
            cell.dispalyArray = displayArray
            cell.cv.reloadData()
            return cell
        }
        else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.GenderDistriTvcel, for: indexPath) as? GenderDistriTvcel else {
                return UITableViewCell()
            }
            cell.updateProgress(studentCount:totalStudents ?? "",staffCount: totalStaffs ?? "")
            cell.updateLabels(staffCount: totalStaffs ?? "", studentCount: totalStudents ?? "")
            return cell
        }
        else if indexPath.section == 2{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LblTvCell, for: indexPath) as? LblTvCell else {
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
            cell.updateProgress(boys: standard.boys_count ?? "0", girls: standard.girls_count ?? "0", others: standard.other_count ?? "")
            cell.standardLbl.text = Standard.translated() + " " + (standard.name ?? "")
            cell.boysCountLbl.text = "\(Boys.translated()): \(standard.boys_count ?? "")"
            cell.girlsCountLbl.text = "\(Girls.translated()): \(standard.girls_count ?? "")"
            cell.othersCountLbl.text = "\(NotSpecified.translated()): \(standard.other_count ?? "")"
            cell.countLbl.text = "\(TotalStudents.translated()): \(standard.total_students ?? "")"
            
            let total = Int(standard.total_students ?? "") ?? 0
            let boys  = Int(standard.boys_count ?? "") ?? 0
            let girls = Int(standard.girls_count ?? "") ?? 0
            let other = Int(standard.other_count ?? "") ?? 0

            
            cell.maleImageView.isHidden = true
            cell.femaleImgView.isHidden = true
            cell.othersImageView.isHidden = true

            cell.maleImageView.image = nil
            cell.femaleImgView.image = nil
            cell.othersImageView.image = nil

            if total > 0 {

                if total == boys {
                    cell.maleImageView.image = UIImage(named: "males")
                    cell.femaleImgView.image = UIImage(named: "males")

                    cell.maleImageView.tintColor = .maleClr
                    cell.femaleImgView.tintColor = .maleClr

                    cell.maleImageView.isHidden = false
                    cell.femaleImgView.isHidden = false

                } else if total == girls {
                    cell.maleImageView.image = UIImage(named: "females")
                    cell.femaleImgView.image = UIImage(named: "females")

                    cell.maleImageView.tintColor = .femaleClr
                    cell.femaleImgView.tintColor = .femaleClr

                    cell.maleImageView.isHidden = false
                    cell.femaleImgView.isHidden = false

                } else if total == other {
                    cell.maleImageView.image = .otherGender
                    cell.femaleImgView.image = .otherGender

                    cell.maleImageView.isHidden = false
                    cell.femaleImgView.isHidden = false

                } else {
                   
                    if boys > 0 {
                        cell.maleImageView.image = UIImage(named: "males")
                        cell.maleImageView.tintColor = .maleClr
                        cell.maleImageView.isHidden = false
                    }

                    if girls > 0 {
                        cell.femaleImgView.image = UIImage(named: "females")
                        cell.femaleImgView.tintColor = .femaleClr
                        cell.femaleImgView.isHidden = false
                    }

                    if other > 0 {
                        cell.othersImageView.image = .otherGender
                        cell.othersImageView.isHidden = false
                    }
                }
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
            tableView.reloadData()}
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
    var Total: Int
    var name: String
    var previousYear: Int
    var Girl : Int
    var boys : Int
    var others: Int
    var message : String
}
