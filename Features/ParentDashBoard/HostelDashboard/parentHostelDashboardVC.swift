//
//  parentHostelDashboardVC.swift
//  School Chimes
//
//  Created by apple on 11/03/26.
//

import UIKit
enum DashboardRow {
    case gatePass
    case todayAttendance
    case feesinfo
    case detailedAttendance
    case outpassRequests
    case hostelInfo
   
}
class parentHostelDashboardVC: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var studentDataFullView: UIView!
    @IBOutlet weak var schoolNameLbl: UILabel!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var DateBtn: UIButton!
    @IBOutlet weak var FirstLetterView: UIView!
    @IBOutlet weak var firstLetterLbl: UILabel!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var nodataLbl: UILabel!
    
//    
//    var outpassRequestsModel = OutpassRequestsModel(
//        requests: [
//            OutpassRequestData(reason: "i  am sick", fromToDate: "13/10/2000 -  15/10/2000", requestTime: "04:00 AM", status: "Pending"),
//            OutpassRequestData(reason: "i  am sick", fromToDate: "13/10/2000 -  15/10/2000", requestTime: "04:00 AM", status: "Accepted")
//        ]
//    )
    
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var HosteldataDetails   : [HostelDashboardData] = []
    var rows: [DashboardRow] = []
    var datadetails: [HostelDetailsData]?
    var selectedMonth: MonthItem?
    var years:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.96, alpha: 1)
        studentDataFullView.layer.cornerRadius = 10
        studentDataFullView.layer.cornerRadius = 15
        DateBtn.layer.cornerRadius = 10
        DateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        FirstLetterView.layer.cornerRadius = 8
        NoDataImage.isHidden = true
        nodataLbl.isHidden = true
        setupYearAndMonth()
        setupTableView()
        GetHostelDetails()
    }
    
    @IBAction func dateBtnAct(_ sender: Any) {
        
        let vc = yearAndMonthCalenderVc()
        vc.years = years
        vc.selectdMonth = selectedMonth
        vc.onDateSelected = { [weak self] month in
            self?.selectedMonth = month
            self?.DateBtn.setTitle("\(month.name) \(month.year)", for: .normal)
            self?.GetHostelDetails()
        }
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func setupYearAndMonth(){
        
        let calendar = Calendar.current
        let currentDate = Date()
        
        let month = calendar.component(.month, from: currentDate)
        let year = calendar.component(.year, from: currentDate)
        let monthName = calendar.monthSymbols
        let shortName = calendar.shortMonthSymbols
        
        years = [String(year - 1), String(year)]
        
       selectedMonth = MonthItem(
        id: month,
        name: monthName[month - 1],
        shortName: shortName[month - 1],
        monthNumber: month,
        year: year,
        isSelected: true
       )
        DateBtn.setTitle("\(selectedMonth?.name ?? "") \(selectedMonth?.year ?? 0)", for: .normal)
    }
    
    private func setupTableView() {
//        tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
       
//        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Register the awesome XIB custom cells
        tableView.register(UINib(nibName: "OverallStatsCell", bundle: nil), forCellReuseIdentifier: "OverallStatsCell")
        tableView.register(UINib(nibName: "TodayAttendanceCell", bundle: nil), forCellReuseIdentifier: "TodayAttendanceCell")
        tableView.register(UINib(nibName: "AttendanceOverviewCell", bundle: nil), forCellReuseIdentifier: "AttendanceOverviewCell")
        tableView.register(UINib(nibName: "SessionAnalysisCell", bundle: nil), forCellReuseIdentifier: "SessionAnalysisCell")
        tableView.register(UINib(nibName: "WeeklyTrendCell", bundle: nil), forCellReuseIdentifier: "WeeklyTrendCell")
        tableView.register(UINib(nibName: "DetailedAttendanceCell", bundle: nil), forCellReuseIdentifier: "DetailedAttendanceCell")
        tableView.register(UINib(nibName: "OutpassStatsCell", bundle: nil), forCellReuseIdentifier: "OutpassStatsCell")
        tableView.register(UINib(nibName: "OutpassRequestsCell", bundle: nil), forCellReuseIdentifier: "OutpassRequestsCell")
        tableView.register(UINib(nibName: "HostelInfoCell", bundle: nil), forCellReuseIdentifier: "HostelInfoCell")
        tableView.register(UINib(nibName: "GatePassTvcell", bundle: nil), forCellReuseIdentifier: "GatePassTvcell")
        tableView.register(UINib(nibName: "studentPendingFeeTv", bundle: nil), forCellReuseIdentifier: "studentPendingFeeTv")
        
    }
    
   
}
   

extension parentHostelDashboardVC : UITableViewDelegate, UITableViewDataSource,newRequestScreen {
    func newOutpassVc() {
        let vc = NewOutpassRequestVC(nibName: nil, bundle: nil)
        vc.studentHostelInfo =  datadetails?.first
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch rows[indexPath.row] {
        case .detailedAttendance:
            return 450
        default:
            return UITableView.automaticDimension
        }
    }
    

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let data = HosteldataDetails.first else {
            return UITableViewCell()
        }

        let rowType = rows[indexPath.row]

        switch rowType {
            
        case .gatePass:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GatePassTvcell", for: indexPath) as! GatePassTvcell
            cell.selectionStyle = .none
            cell.configure(with: data.gate_pass?.first)
            return cell
            
        case .feesinfo :
            let cell = tableView.dequeueReusableCell(withIdentifier: "studentPendingFeeTv", for: indexPath) as! studentPendingFeeTv
            cell.config(data: data.fee_details ?? [])
            cell.onPaybuttonTapped = {[weak self] in
                let vc = FeeDetails()
                MenuStringFile.selectedMenuName = "Fees"
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            }
            return cell
            
        case .todayAttendance:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayAttendanceCell", for: indexPath) as! TodayAttendanceCell
            cell.selectionStyle = .none
            cell.configure(with: data)
            return cell
            
        case .detailedAttendance:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailedAttendanceCell", for: indexPath) as! DetailedAttendanceCell
            cell.selectionStyle = .none
            cell.configure(with: data.attendance_details?.first)
            return cell
  
        case .outpassRequests:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutpassRequestsCell", for: indexPath) as! OutpassRequestsCell
            cell.configure(data: data.out_pass_requests ?? [])
            cell.newRequestdelegate = self
            
            cell.onSeeMore = {[weak self] in
                let vc = OutpassRequestsVC()
                vc.outpassRequestList = data.out_pass_requests ?? []
                vc.Hosteldetails = self?.datadetails
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            }
            
            cell.onViewDetails = { [weak self] data in
                guard let self = self else { return }
                
                let data = GatePass(
                    action_by: data.action_by,
                    admission_no: datadetails?.first?.admission_no ?? "",
                    reason: data.reason,
                    profile: "",
                    floor_no: datadetails?.first?.floor_no,
                    room_no: datadetails?.first?.room_no,
                    fromdate_todate: data.fromdate_todate,
                    request_time: data.request_time,
                    status: data.status
                )
                
                let vc = yearAndMonthCalenderVc()
                vc.GatepassData = data
                vc.isGatePass = true
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true)
            }
            return cell
            
        case .hostelInfo :
            let cell = tableView.dequeueReusableCell(withIdentifier: "HostelInfoCell", for: indexPath) as! HostelInfoCell
            if let datas = data.hostel_info?.first{
                cell.configure(with: datas)
            }
            return cell
        }
        
        
        
    }
    
    
    func GetHostelDetails() {
        APIService.shared.makeApi(url: ServiceUrl.hostel_attendance_hostel_info, parameters: [:], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? "", isBaseUrl: false) {[self] (result: Result<HostelDetailsResponse,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    if Success.status ?? false{
                        
                        datadetails = Success.data ?? []
                        firstLetterLbl.text = datadetails?.first?.student_name?
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .first
                            .map { String($0).uppercased() } ?? ""
                        studentNameLbl.text = datadetails?.first?.student_name
                        schoolNameLbl.text = datadetails?.first?.hostel_name
                        let classname = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")
                        let roomNo = (datadetails?.first?.floor_name ?? "") +
                        " - " + "Room No:" + (datadetails?.first?.room_no ?? "")
                        classNameLbl.text = classname + " , " + roomNo
//
                        let year = String(selectedMonth?.year ?? 0)
                        let month = String(selectedMonth?.monthNumber ?? 0)
                        GetParentDashboardDetails(hostelId: Success.data?.first?.hostel_id ?? "", yearId: year, monthId: month)
                        
                    }else{
                        
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: Success.message ?? "", on: self) {
                            self.dismiss(animated: true)
                        }
                    }
                    
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: error.localizedDescription, on: self) {
                        self.dismiss(animated: true)
                    }
                   
                }
            }
        }
    }
    
    
    func GetParentDashboardDetails(hostelId : String,yearId : String, monthId : String) {
        
        APIService.shared.makeApi(
            url: ServiceUrl.hostel_attendance_parent_dashboard,
            parameters: [
                "hostel_id": hostelId,
                "year_id": yearId,
                "month_id": monthId
            ],
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? "",
            isBaseUrl: false
        ) { [weak self] (result: Result<HostelDashboardResponse, Error>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                switch result {
                    
                case .success(let success):
                    
                    guard success.status == true,
                          let data = success.data?.first else {
                        self.NoDataImage.isHidden = false
                        self.nodataLbl.isHidden = false
                        self.nodataLbl.text = success.message
                        self.rows = []
                        self.tableView.reloadData()
                        return
                    }
                    
                    self.HosteldataDetails = [data]
                    self.rows.removeAll()
                    
                    if !(data.gate_pass?.isEmpty ?? true) {
                        self.rows.append(.gatePass)
                    }
                    
                    if !(data.today_attendance?.isEmpty ?? true) {
                        self.rows.append(.todayAttendance)
                    }
                    
                    if !(data.fee_details?.isEmpty ?? true){
                        self.rows.append(.feesinfo)
                    }
                    
                    if !(data.attendance_details?.first?.days?.isEmpty ?? true) {
                        self.rows.append(.detailedAttendance)
                    }
                    
//                    if !(data.out_pass_requests?.isEmpty ?? true) {
                        self.rows.append(.outpassRequests)
                 //   }
                    
                    if !(data.hostel_info?.isEmpty ?? true){
                        self.rows.append(.hostelInfo)
                    }
                    
                   
                    
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.tableView.reloadData()
                    
                case .failure(let failure):
                    self.NoDataImage.isHidden = false
                    self.nodataLbl.isHidden = false
                    self.nodataLbl.text = failure.localizedDescription
                    self.rows = []
                    self.tableView.reloadData()
                }
            }
        }
    }
}

