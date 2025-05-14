//
//  AttendanceReportVc.swift
//  School Chimes
//
//  Created by Lakshmanan on 14/05/25.
//

import UIKit

class AttendanceReportVc: UIViewController {

    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var TV: UITableView!
    
    var FilteredReport: [AttenenceReportData]?
    var AttendanceReport: [AttenenceReportData]?
    let StaffDetails = UserDefaultFileManager.get_staff_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SearchBar.searchTextField.addDoneButton()
        SearchBar.delegate = self
       
        let nib = UINib(nibName: CellConfingName.AttendenceReportTVCell, bundle: nil)
        TV.register(nib, forCellReuseIdentifier: CellConfingName.AttendenceReportTVCell)
    }
    
    //MARK: Attendance report API Call
    func student_attendance_report(){
        
        let Param = [
            AttendanceReportStringFile.from_date : "",
            AttendanceReportStringFile.to_date : "",
            AttendanceReportStringFile.standard_id : ""/*standardDropdown.selectedItem*/,
            AttendanceReportStringFile.section_id : ""/*SectionDropdown.selectedItem*/,
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.attendance_student_attendance_report, parameters: Param, type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "") { [self] (result:Result<AttendanceReportResponse,Error>) in
            
            switch result {
                
            case .success(let successMessage):
                
                if successMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        
                        AttendanceReport = successMessage.data
                        FilteredReport = AttendanceReport
                        TV.reloadData()
                    }
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        
                        AttendanceReport = successMessage.data
                        FilteredReport = AttendanceReport
                        TV.reloadData()
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

extension AttendanceReportVc : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FilteredReport?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.AttendenceReportTVCell, for: indexPath) as! AttendenceReportTVCell
        
        let report = FilteredReport?[indexPath.row]
        
        if report?.att_status == "P"{
            
           // cell.cellView.layer.borderColor = UIColor.systemGreen.cgColor
            cell.statusView.backgroundColor = .systemGreen
            cell.statusLbl.text = "Present"
           
        }else{
            
           // cell.cellView.layer.borderColor = UIColor.systemRed.cgColor
            cell.statusView.backgroundColor = .systemRed
            cell.statusLbl.text = "Absent"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
}


extension AttendanceReportVc : UISearchBarDelegate {
    
}
