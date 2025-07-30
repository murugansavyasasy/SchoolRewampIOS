//
//  NewAbsenteesViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 23/04/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
//import ObjectMapper

class NewAbsenteesViewController: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var Tv: UITableView!
    @IBOutlet weak var cvIcon: UICollectionView!
    
    var ClickID  = 0
    var absentData : [AbsenteeDate]?
    var  class_wiseData: [ClassWise]?
    let StaffDetails = UserDefaultFileManager.get_staff_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: StaffDetails?.school_name ?? "")
        
        cvIcon.register(UINib(nibName: CellConfingName.CVIconCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.CVIconCollectionViewCell)
        let rowNib = UINib(nibName: CellConfingName.ClassTableViewCell, bundle: nil)
        Tv.register(rowNib, forCellReuseIdentifier: CellConfingName.ClassTableViewCell)
        
        cvIcon.dataSource = self
        cvIcon.delegate = self
        
        Tv.dataSource = self
        Tv.delegate = self
        
        Absentees_Response()
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    @IBAction func BackAct() {
        dismiss(animated: true)
    }
    
    func Absentees_Response() {
        
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_api_attendance_get_absentees_count_by_date, parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "") { [self] (result:Result <AbsenteesResponse,Error>) in
            
            switch result {
            case .success(let successMessage):
                DispatchQueue.main.async { [self] in
                    
                    absentData = successMessage.data
                    class_wiseData = absentData?.first?.class_wise ?? []
                    cvIcon.reloadData()
                    Tv.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
}

extension NewAbsenteesViewController : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return absentData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellConfingName.CVIconCollectionViewCell ,
            for: indexPath) as? CVIconCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        cell.countLbl.text = absentData?[indexPath.item].total_absentees
        
        let date = absentData?[indexPath.row].date ?? ""
        
        cell.dayLbl.text = ConvertDateStringSmart(date, toFormat: "EEEE")
        cell.dateLbl.text = ConvertDateStringSmart(date, toFormat: "dd")
        cell.MnthLbl.text = ConvertDateStringSmart(date, toFormat: "MMMM")
        
        if ClickID == indexPath.row {
            cell.dateFulView.backgroundColor = .attendence
            cell.dayLbl.textColor = .black
            cell.dateLbl.textColor = .black
        }
        else{
            cell.dateFulView.backgroundColor = .white
            cell.dayLbl.textColor = .gray
            cell.dateLbl.textColor = .gray
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ClickID = indexPath.row
        class_wiseData = absentData?[indexPath.item].class_wise
        cvIcon.reloadData()
        Tv.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 130 )
    }
}

extension NewAbsenteesViewController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  class_wiseData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.ClassTableViewCell,
            for: indexPath) as? ClassTableViewCell else{
            return UITableViewCell()}
        
        cell.classNameLbl.text = class_wiseData?[indexPath.row].name
        cell.absentCountlbl.text = class_wiseData?[indexPath.row].total_absentees
        cell.dateLbl.text = absentData?[ClickID].date
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = SectionViewController(nibName: nil, bundle: nil)
        vc.SelectedDate = absentData?[ClickID].date
        vc.section_wiseData = class_wiseData?[indexPath.row].section_wise
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
