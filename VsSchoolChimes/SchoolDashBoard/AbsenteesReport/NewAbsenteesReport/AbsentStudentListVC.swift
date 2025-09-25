//
//  AbsentStudentListVC.swift
//  School Chimes
//
//  Created by Chandhru on 11/09/25.
//

import UIKit

class AbsentStudentListVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var studentCV: UICollectionView!
    @IBOutlet weak var NodataLbl: UILabel!
    @IBOutlet weak var NoDataImage: UIImageView!

    var absentStudentData: [AbsentisReportStudent] = []
    var searchStudentData: [AbsentisReportStudent] = []
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var sectionId: String?
    var date: String?
    var backTitte1: String?
    var backTitte2: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        studentCV.register(UINib(nibName: "AbsentStudentCVC", bundle: nil), forCellWithReuseIdentifier: "AbsentStudentCVC")
        studentCV.delegate = self
        studentCV.dataSource = self

        searchBar.delegate = self
        searchBar.isHidden = true
        searchView.isHidden = true

        AbsentStudent(sectionId: sectionId ?? "", date: date ?? "")
    }

    // MARK: - UICollectionView DataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchStudentData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AbsentStudentCVC", for: indexPath) as? AbsentStudentCVC else {
            return UICollectionViewCell()
        }
        let student = searchStudentData[indexPath.item]
        cell.configure(with: student)
        return cell
    }

    // MARK: - UICollectionView DelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2
        return CGSize(width: width, height: width * 1.2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    // MARK: - Search Functionality

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchStudentData = absentStudentData
        } else {
            searchStudentData = absentStudentData.filter { student in
                student.student_name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        updateEmptyState()
        studentCV.reloadData()
    }

    func updateEmptyState() {
        let hasData = !searchStudentData.isEmpty
        NodataLbl.isHidden = hasData
        NoDataImage.isHidden = hasData
        studentCV.isHidden = !hasData
        if !hasData {
            NodataLbl.text = "No matching students found"
        }
    }

    // MARK: - Actions

    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        searchBar.isHidden = !sender.isSelected
        searchView.isHidden = !sender.isSelected
        
        if !sender.isSelected {
            searchBar.text = ""
            searchStudentData = absentStudentData
            updateEmptyState()
            studentCV.reloadData()
            searchBar.resignFirstResponder()
        }
    }

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - API Call

    func AbsentStudent(sectionId: String, date: String) {
        if #available(iOS 15.0, *) {
            self.hideActivityLoader()
        }

        let param = [
            AbsenteesReportStringFile.absent_on: date,
            AbsenteesReportStringFile.section_id: sectionId
        ]

        APIService.shared.makeApi(
            url: ServiceUrl.stud_attd_api_attendance_get_absentees_students_by_date,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<AbsentisReportStudentResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if #available(iOS 15.0, *) {
                    self.hideActivityLoader()
                }

                switch result {
                case .success(let response):
                    self.absentStudentData = response.data
                    self.searchStudentData = response.data

                    let hasData = !response.data.isEmpty
                    self.NodataLbl.isHidden = hasData
                    self.NoDataImage.isHidden = hasData
                    self.NodataLbl.text = response.message
                    self.studentCV.isHidden = !hasData
                    self.studentCV.reloadData()

                case .failure(let error):
                    print("API error: \(error.localizedDescription)")
                    self.NodataLbl.isHidden = false
                    self.NoDataImage.isHidden = false
                    self.NodataLbl.text = "Failed to load data"
                    self.studentCV.isHidden = true
                }
            }
        }
    }
}
