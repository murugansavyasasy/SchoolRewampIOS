//
//  NewAttendanceReportVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 31/07/25.
//

import UIKit

class NewAttendanceReportVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var SearchBtn: UIButton!
    
    
    var childDetails = UserDefaultFileManager.get_child_Details()
    var attendanceReportData : [StudentAttendance]?
    var FilteredReportData : [StudentAttendance]?
    let dateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TopView.layer.cornerRadius = 20
        TopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        let name = childDetails?.name ?? ""
        let standard = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        studentNameLbl.configureAsBackTitle(firstLine: name, secondLine: standard)
        
        TitleLbl.text = AttendanceString.LeaveHistory
        TitleLbl.setFont(style: .header, size: FontSize.HeaderSize)
        
        searchBar.isHidden = true
        searchBar.placeholder = CommonStringFile.Search
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        searchBar.backgroundImage = UIImage()
        
        NoDataImage.isHidden = true
        NoDataLbl.isHidden = true
        
        cv.register(
            UINib(nibName: "AttendanceRepCv", bundle: nil),
            forCellWithReuseIdentifier: "AttendanceRepCv")
        cv.delegate = self
        cv.dataSource = self
        Get_attendaceReport()
        
    }
    
    func Get_attendaceReport() {
        
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_attendance_get_absent_dates_for_child, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") {[weak self] (result: Result<StudentAttendanceResponse,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let SuccessMessage):
                    
                    self.attendanceReportData = SuccessMessage.data ?? []
                    self.FilteredReportData = self.attendanceReportData
                    self.cv.reloadData()
                    self.SearchBtn.isHidden = !(SuccessMessage.status ?? false)
                    self.NoDataImage.isHidden = SuccessMessage.status ?? false
                    self.NoDataLbl.isHidden = SuccessMessage.status ?? false
                    self.NoDataLbl.text = SuccessMessage.message
                case .failure(let error):
                    self.NoDataImage.isHidden = false
                    self.NoDataLbl.isHidden = false
                    self.SearchBtn.isHidden = true
                    self.NoDataLbl.text = error.localizedDescription
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func searchBtnAct(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected{
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
            SearchBtn.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else{
            searchBar.isHidden = true
            searchBar.resignFirstResponder()
            SearchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            searchBar.searchTextField.text = ""
            FilteredReportData = attendanceReportData
            NoDataLbl.isHidden = true
            NoDataImage.isHidden = true
            cv.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            FilteredReportData = attendanceReportData
        } else {
            let lowercasedQuery = trimmed.lowercased()
            
            FilteredReportData = attendanceReportData?.filter { record in
                let dateStr = record.date?.convertToTargetDateFormat()?.lowercased()
                let dayStr = record.day?.lowercased()
                let typeStr = record.type?.lowercased()
                
                return
                (dateStr?.contains(lowercasedQuery) ?? false) ||
                (dayStr?.contains(lowercasedQuery) ?? false) ||
                (typeStr?.contains(lowercasedQuery) ?? false)
            }
        }
        
        let ishidden = !(FilteredReportData?.isEmpty == true)
        NoDataImage.isHidden = ishidden
        NoDataLbl.isHidden = ishidden
        NoDataLbl.text = "No Data Found"
        
        cv.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilteredReportData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttendanceRepCv", for: indexPath) as! AttendanceRepCv
        let dateStr = FilteredReportData?[indexPath.row].date ?? ""
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        
        if let date = inputFormatter.date(from: dateStr) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM"
            let monthName = outputFormatter.string(from: date)
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            cell.MnthLbl.text = monthName
            cell.dateLbl.text = String(day)
            
        }
        
        let formattedDateString = dateFormatter.convertDate(
            FilteredReportData?[indexPath.row].date ?? ""
        ) ?? ""
        cell.dateYrLbl.text = formattedDateString
        cell.dayLbl.text = FilteredReportData?[indexPath.row].day
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: 200 )
    }
    
    
    
}

