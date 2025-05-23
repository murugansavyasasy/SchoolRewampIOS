//
//  ReciverAttendanceReportVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 19/12/24.
//

import UIKit

class ReciverAttendanceReportVC: UIViewController {
    
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var noResordStack: UIStackView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var TV: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
   
    var childDetails = UserDefaultFileManager.get_child_Details()
    var attendanceReportData : [StudentAttendance]?
    let dateFormatter = DateFormatter()
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        searchBar.applyRightTxt()
        NameLbl.text = childDetails?.name
        StandardLbl.text = (
            childDetails?.standard_name ?? ""
        ) + " - " + (childDetails?.section_name ?? "")
        searchBar.placeholder = CommonStringFile.Search.translated()
        StyleAndTranslate()
        CellRigister()
        TV.delegate = self
        TV.dataSource = self
       
        Get_attendaceReport()
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    //MARK: UI Changes
    func StyleAndTranslate(){
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
    }
    
    //MARK: Cell Registeration
    func CellRigister(){
        let nib = UINib(nibName: CellConfingName.ReciverAttendReportTV, bundle: nil)
        TV.register(nib, forCellReuseIdentifier: CellConfingName.ReciverAttendReportTV)
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}

//MARK: Tableview Functions
extension ReciverAttendanceReportVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return attendanceReportData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.ReciverAttendReportTV, for: indexPath) as! ReciverAttendReportTV
        
        let dateStr = attendanceReportData?[indexPath.row].date ?? ""
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"

        if let date = inputFormatter.date(from: dateStr) {
            let outputFormatter = DateFormatter()
            
            // Get full month name
            outputFormatter.dateFormat = "MMMM"
            let monthName = outputFormatter.string(from: date)
            cell.monthLbl.text = monthName

            // Get day only
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            cell.DateLbl.text = "\(day)"
        }
        
        let formattedDateString = dateFormatter.convertDate(
            attendanceReportData?[indexPath.row].date ?? ""
        ) ?? ""
        cell.TakenLbl.text = formattedDateString
        cell.dayLbl.text = attendanceReportData?[indexPath.row].day
        cell.statusLbl.textColor = .white
        if attendanceReportData?[indexPath.row].type == "present" {
            cell.statusLbl.text = CommonStringFile.Present.translated()
            cell.StatusView.backgroundColor = .systemGreen
        }else{
            cell.statusLbl.text = CommonStringFile.Absent.translated()
            cell.StatusView.backgroundColor = .systemRed
            cell.MonthView.backgroundColor =  UIColor(named: "Red")
            cell.DateView.backgroundColor =  .white
            cell.DateView.layer.borderWidth = 0.5
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
    func Get_attendaceReport() {
        
        APIService.shared.makeApi(url: ServiceUrl.stud_attd_attendance_get_absent_dates_for_child, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") {[self] (result: Result<StudentAttendanceResponse,Error>) in
            
            switch result {
                
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        noResordStack.isHidden = true
                        attendanceReportData = SuccessMessage.data ?? []
                        TV.reloadData()
                    }
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        
                        noResordStack.isHidden = false
                        noRecordLbl.text = SuccessMessage.message ?? ""
                    }
                }
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
