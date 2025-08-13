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
        
        TitleLbl.text = AttendanceString.attendanceReport
        TitleLbl.setFont(style: .header, size: FontSize.HeaderSize)
        
        tv.register(UINib(nibName: CellConfingName.ReciverAttendReportTV, bundle: nil), forCellReuseIdentifier: CellConfingName.ReciverAttendReportTV)
        Get_attendaceReport()
        tv.delegate = self
        tv.dataSource = self
        
    }

    func Get_attendaceReport() {
        
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_attendance_get_absent_dates_for_child, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") {[self] (result: Result<StudentAttendanceResponse,Error>) in
            
            switch result {
                
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        attendanceReportData = SuccessMessage.data ?? []
                        tv.reloadData()
                    }
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        
                       
                    }
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
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
            outputFormatter.dateFormat = "MMMM"
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
