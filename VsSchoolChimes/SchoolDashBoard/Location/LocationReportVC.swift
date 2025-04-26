//
//  LocationReportVC.swift
//  SchoolChimes
//
//  Created by Lakshmanan on 24/04/25.
//

import UIKit
import DropDown

class LocationReportVC: UIViewController{

    @IBOutlet weak var Tv: UITableView!
    @IBOutlet weak var SelectYearDropdownView: UIViewX!
    @IBOutlet weak var SelectMonthDropdownView: UIViewX!
    @IBOutlet weak var MonthLbl: UILabel!
    @IBOutlet weak var YearLbl: UILabel!
    
    var staffdetails = UserDefaultFileManager.get_staff_Details()
    var AttendanceDetails: [StaffAttendance]?
    let currentYear = Calendar.current.component(.year, from: Date())
    let dateFormatter = DateFormatter()
    var currentMonth = Calendar.current.component(.month, from: Date())
    
    var years: [String] = []
    var Months: [String] = []
    
    var dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applyShadowAndCornerRadius(to:SelectYearDropdownView)
        applyShadowAndCornerRadius(to:SelectMonthDropdownView)
        
        for i in 0..<21 {
            let year = currentYear - i
            years.append(String(year))
        }
        
        YearLbl.text = years[0]
        
        Months = getMonthNames(for: years[0])
        
        MonthLbl.text = Months[0]
        
       // Geometric_Punch_History()
        
        let YearTap = UITapGestureRecognizer(target: self, action: #selector(YearSelection))
        SelectYearDropdownView.addGestureRecognizer(YearTap)
        SelectYearDropdownView.isUserInteractionEnabled = true
        
        let MonthTap = UITapGestureRecognizer(target: self, action: #selector(MonthSelection))
        SelectMonthDropdownView.addGestureRecognizer(MonthTap)
        SelectMonthDropdownView.isUserInteractionEnabled = true

        let rowNib = UINib(nibName: CellConfingName.LocationTableViewCell, bundle: nil)
        Tv.register(rowNib, forCellReuseIdentifier: CellConfingName.LocationTableViewCell)
        
        Tv.delegate = self
        Tv.dataSource = self
    }
    
    @IBAction func YearSelection(){
        
        dropDown.dataSource = years
        dropDown.anchorView = SelectYearDropdownView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            YearLbl.text = item
            Months = getMonthNames(for: item)
        }
    }
    
    @IBAction func MonthSelection() {
        
        dropDown.dataSource = Months
        dropDown.anchorView = SelectMonthDropdownView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show()
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            MonthLbl.text = item
        }
    }
    
    
    func Geometric_Punch_History() {
        
        let param = [StaffAttendanceReportStringFile.attendance_dt:""]
        
        APIService.shared.makeApi(url: ServiceUrl.staff_attd_geometric_geometric_staff_attendance_report, parameters: param, type: ApitTypeSringFile.GET, token: staffdetails?.access_token ?? "") { [self] (reult: Result<StaffAttendanceResponse,Error>) in
            
            switch reult {
                
            case .success(let successMessage):
                
                if successMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        
                        AttendanceDetails = successMessage.data
                    }
                    
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        
                        AttendanceDetails = successMessage.data
                    }
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async {
                    
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func getMonthNames(for selectedYear: String) -> [String] {
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale.current
        monthFormatter.dateFormat = "MMMM" // Use "LLL" for short month names

        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())

        let selectedYearInt = Int(selectedYear) ?? 0
        let maxMonth = (selectedYearInt == currentYear) ? currentMonth : 12

        return (1...maxMonth).compactMap { month in
            var components = DateComponents()
            components.year = 2000 // dummy year
            components.month = month
            if let date = Calendar.current.date(from: components) {
                return monthFormatter.string(from: date)
            }
            return nil
        }
    }

    
}


extension LocationReportVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       // return AttendanceDetails?.count ?? 0
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Tv.dequeueReusableCell(withIdentifier: CellConfingName.LocationTableViewCell, for: indexPath) as! LocationTableViewCell
        
        cell.selectionStyle = .none
        cell.fullView.layer.cornerRadius = 20
        cell.calanderView.layer.cornerRadius = 10
        cell.calanderView.layer.masksToBounds = true
        cell.fullView.layer.masksToBounds = true
        cell.fullView.layer.shadowColor = UIColor.black.cgColor
        cell.fullView.layer.shadowOpacity = 0.5
        cell.fullView.layer.shadowOffset = CGSize(width: 4, height: 4)
        cell.fullView.layer.shadowRadius = 5
        cell.fullView.layer.masksToBounds = false
        cell.firstInLbl.isHidden = false
        cell.workingHrsLbl.isHidden = false
        cell.toDateLbl.isHidden = false
        cell.StatusLbl.layer.cornerRadius = 5
        cell.StatusLbl.layer.masksToBounds = true
        
        cell.namelbl.text = "Lakshmanan"/*AttendanceDetails?[indexPath.row].name*/
        cell.attendanceTypeLbl.text = AttendanceDetails?[indexPath.row].attendance_type
        cell.firstInLbl.text = "First in - " + (
            AttendanceDetails?[indexPath.row].in_time ?? ""
        )
        cell.toDateLbl.text = "Last out - " + (
            AttendanceDetails?[indexPath.row].out_time ?? ""
        )
        cell.workingHrsLbl.text = "Working Hours - " +  (
            AttendanceDetails?[indexPath.row].working_hours ?? ""
        )
        cell.StatusLbl.text = "Present"/*AttendanceDetails?[indexPath.row].leave_type*/
        if cell.StatusLbl.text == "Absent" {
            cell.StatusLbl.backgroundColor = .systemRed
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let historyTap = UITapGestureRecognizer(target: self, action: #selector(GoTOHISTORY))
        cell.historyTimImage.addGestureRecognizer(historyTap)
        cell.historyTimImage.isUserInteractionEnabled = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func GoTOHISTORY(){
        let vc = PunchHistoryListVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
