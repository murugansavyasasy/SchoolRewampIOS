//
//  NewAttendanceReportVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 31/07/25.
//

import UIKit

class NewAttendanceReportVC: UIViewController {

    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    
    var childDetails = UserDefaultFileManager.get_child_Details()
    var attendanceReportData : [StudentAttendance]?
    let dateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TopView.layer.cornerRadius = 20
        TopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        let name = childDetails?.name ?? ""
        let standard = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        backBtn.configureAsBackButton(firstLine: name, secondLine: standard, colour: .white)
        
        TitleLbl.text = AttendanceString.LeaveHistory
        TitleLbl.setFont(style: .header, size: FontSize.HeaderSize)
        
        NoDataImage.isHidden = true
        NoDataLbl.isHidden = true
        
        tv.register(UINib(nibName: CellConfingName.ReciverAttendReportTV, bundle: nil), forCellReuseIdentifier: CellConfingName.ReciverAttendReportTV)
        tv.delegate = self
        tv.dataSource = self
        Get_attendaceReport()
        
    }

    func Get_attendaceReport() {
        
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_attendance_get_absent_dates_for_child, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") {[weak self] (result: Result<StudentAttendanceResponse,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                switch result {
                    
                case .success(let SuccessMessage):
                    
                    self.attendanceReportData = SuccessMessage.data ?? []
                    self.tv.reloadData()
                    self.NoDataImage.isHidden = SuccessMessage.status ?? false
                    self.NoDataLbl.isHidden = SuccessMessage.status ?? false
                    self.NoDataLbl.text = SuccessMessage.message
                case .failure(let error):
                    self.NoDataImage.isHidden = false
                    self.NoDataLbl.isHidden = false
                    self.NoDataLbl.text = error.localizedDescription
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}


extension NewAttendanceReportVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attendanceReportData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.ReciverAttendReportTV, for: indexPath) as! attendanceRepTv
        
        let dateStr = attendanceReportData?[indexPath.row].date ?? ""
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        
        if let date = inputFormatter.date(from: dateStr) {
            let outputFormatter = DateFormatter()
            
            // Get full month name
            outputFormatter.dateFormat = "MMM"
            let monthName = outputFormatter.string(from: date)
            
            
            // Get day only
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            //            cell.dayLbl.text = "\(day)"
            cell.datelbl.text = "\(monthName) \n \(day)"
        }
        
        let formattedDateString = dateFormatter.convertDate(
            attendanceReportData?[indexPath.row].date ?? ""
        ) ?? ""
        cell.dateYrLbl.text = formattedDateString
        cell.dayLbl.text = attendanceReportData?[indexPath.row].day
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
}
