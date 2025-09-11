//
//  NewAbsenteesViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 23/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class NewAbsenteesViewController: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var Tv: UITableView!
    @IBOutlet weak var cvIcon: UICollectionView!
    
    var ClickID = 0
    var absentData: [AbsenteeDate]?
    var class_wiseData: [ClassWise]?
    var sectionwiseData: [SectionBasedList]?
    let StaffDetails = UserDefaultFileManager.get_staff_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackBtn.applyBackButton()
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: StaffDetails?.school_name ?? "")
        
        cvIcon.register(UINib(nibName: CellConfingName.CVIconCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.CVIconCollectionViewCell)
        Tv.register(UINib(nibName: CellConfingName.ClassTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.ClassTableViewCell)
        
        cvIcon.dataSource = self
        cvIcon.delegate = self
        
        Tv.dataSource = self
        Tv.delegate = self
        
        Absentees_Response()
    }
    
    @IBAction func BackAct() {
        dismiss(animated: true)
    }
    
    func Absentees_Response() {
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_api_attendance_get_absentees_count_by_date, parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "") { [weak self] (result: Result<AbsenteesResponse, Error>) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.absentData = response.data
                    self.class_wiseData = self.absentData?.first?.class_wise ?? []
                    self.populateSectionwiseData(forDateIndex: 0)
                    
                    self.cvIcon.reloadData()
                    self.Tv.reloadData()
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error fetching absentees:", error.localizedDescription)
                }
            }
        }
    }
    
    // Helper to populate sectionwiseData for a given date index
    func populateSectionwiseData(forDateIndex index: Int) {
        guard let absentData = absentData, absentData.indices.contains(index) else {
            sectionwiseData = []
            return
        }
        
        class_wiseData = absentData[index].class_wise ?? []
        sectionwiseData = []
        
        for classItem in class_wiseData ?? [] {
            for section in classItem.section_wise ?? [] {
                let sectionData = SectionBasedList(
                    className: classItem.class_name ?? "", section_id: section.section_id ?? "",
                    sectionName: section.section_name ?? "",
                    absentCount: section.total_absentees ?? "",
                    date: absentData[index].date ?? ""
                )
                sectionwiseData?.append(sectionData)
            }
        }
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension NewAbsenteesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return absentData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.CVIconCollectionViewCell, for: indexPath) as? CVIconCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let data = absentData?[indexPath.item]
        
        cell.countLbl.text = data?.total_absentees
        
        let date = data?.date ?? ""
        cell.dayLbl.text = ConvertDateStringSmart(date, toFormat: "EEEE")
        cell.dateLbl.text = ConvertDateStringSmart(date, toFormat: "dd")
        cell.MnthLbl.text = ConvertDateStringSmart(date, toFormat: "MMMM")
        
        if ClickID == indexPath.row {
            cell.dateFulView.backgroundColor = .attendence
            cell.dayLbl.textColor = .black
            cell.dateLbl.textColor = .black
        } else {
            cell.dateFulView.backgroundColor = .white
            cell.dayLbl.textColor = .gray
            cell.dateLbl.textColor = .gray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ClickID = indexPath.row
        populateSectionwiseData(forDateIndex: indexPath.item)
        
        cvIcon.reloadData()
        Tv.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 130)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension NewAbsenteesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionwiseData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ClassTableViewCell, for: indexPath) as? ClassTableViewCell else {
            return UITableViewCell()
        }
        
        if let data = sectionwiseData?[indexPath.row] {
            cell.classNameLbl.text = "Class : \(data.className)"
            cell.absentCountlbl.text = data.absentCount
            cell.sectionNameLbl.text = "Section : \(data.sectionName)"
            cell.dateLbl.text = data.date.convertToTargetDateFormat()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let vc = SectionViewController(nibName: nil, bundle: nil)
//        
//        if let data = sectionwiseData?[indexPath.row] {
//            vc.SelectedDate = data.date
//        }
//        
//        if let classes = class_wiseData, classes.indices.contains(indexPath.row) {
//            vc.section_wiseData = classes[indexPath.row].section_wise
//        }
//        
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
        if let data = sectionwiseData?[indexPath.row] {
            let vc = AbsentStudentListVC(nibName: nil, bundle: nil)
            vc.sectionId = data.section_id
            vc.date = data.date
            vc.backTitte1 = "Class (\(data.className))"
            vc.backTitte2 = "Section (\(data.sectionName))"
            
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Data Models
struct SectionBasedList {
    let className: String
    let section_id: String
    let sectionName: String
    let absentCount: String
    let date: String
}
