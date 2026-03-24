//
//  parentHostelDashboardVC.swift
//  School Chimes
//
//  Created by apple on 11/03/26.
//

import UIKit

class parentHostelDashboardVC: UIViewController {
   
    
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var studentDataFullView: UIView!
    
   
    @IBOutlet weak var monthStatusFullView: UIView!
    @IBOutlet weak var attendaceStatusFullView: UIView!
    
    // Dummy Data from the UI designs
    var overviewModel = AttendanceOverviewModel(
        title: "Attendance Overview - March 2026",
        presentCount: 18,
        absentCount: 3
    )
    
    var sessionModel = SessionAnalysisModel(
        title: "Session-wise Analysis",
        sessions: [
            SessionAnalysisSession(title: "Morning", presentCount: 0, absentCount: 6, percentageString: "86%"),
            SessionAnalysisSession(title: "Afternoon", presentCount: 0, absentCount: 6, percentageString: "86%"),
            SessionAnalysisSession(title: "Evening", presentCount: 0, absentCount: 6, percentageString: "86%")
        ]
    )
    
    var weeklyModel = WeeklyTrendModel(
        title: "Weekly Attendance Trend",
        points: [
            WeeklyTrendPoint(dateLabel: "Mar 7", percentage: 65),
            WeeklyTrendPoint(dateLabel: "Mar 6", percentage: 100),
            WeeklyTrendPoint(dateLabel: "Mar 5", percentage: 65),
            WeeklyTrendPoint(dateLabel: "Mar 4", percentage: 100),
            WeeklyTrendPoint(dateLabel: "Mar 3", percentage: 10),
            WeeklyTrendPoint(dateLabel: "", percentage: 100),
            WeeklyTrendPoint(dateLabel: "Mar 1", percentage: 100)
        ]
    )
    
    var detailedModel = DetailedAttendanceModel(
        sessions: ["Morning", "Afternoon", "Evening", "Night"],
        days: [
            DetailedAttendanceDay(dayLabel: "Mar 30", status: ["Present", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 29", status: ["Present", "Absent", "Present", "Not Taken"]),
            DetailedAttendanceDay(dayLabel: "Mar 28", status: ["Present", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 27", status: ["Absent", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 26", status: ["Present", "Present", "Not Taken", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 25", status: ["Present", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 24", status: ["Present", "Absent", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 23", status: ["Present", "Present", "Present", "Not Taken"]),
            DetailedAttendanceDay(dayLabel: "Mar 22", status: ["Present", "Present", "Absent", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 21", status: ["Present", "Present", "Present", "Present"]),
            
            DetailedAttendanceDay(dayLabel: "Mar 20", status: ["Absent", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 19", status: ["Present", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 18", status: ["Present", "Absent", "Present", "Not Taken"]),
            DetailedAttendanceDay(dayLabel: "Mar 17", status: ["Present", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 16", status: ["Present", "Present", "Not Taken", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 15", status: ["Present", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 14", status: ["Absent", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 13", status: ["Present", "Present", "Present", "Not Taken"]),
            DetailedAttendanceDay(dayLabel: "Mar 12", status: ["Present", "Absent", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 11", status: ["Present", "Present", "Present", "Present"]),
            
            DetailedAttendanceDay(dayLabel: "Mar 10", status: ["Present", "Present", "Absent", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 9", status: ["Present", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 8", status: ["Present", "Absent", "Not Taken", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 7", status: ["Present", "Present", "Absent", "Not Taken"]),
            DetailedAttendanceDay(dayLabel: "Mar 6", status: ["Present", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 5", status: ["Absent", "Present", "Present", "Not Taken"]),
            DetailedAttendanceDay(dayLabel: "Mar 4", status: ["Present", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 3", status: ["Present", "Absent", "Not Taken", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 2", status: ["Present", "Present", "Present", "Present"]),
            DetailedAttendanceDay(dayLabel: "Mar 1", status: ["Absent", "Present", "Present", "Present"])
        ]
    )
    
    var outpassModel = OutpassStatsModel(
        totalRequests: "25",
        pending: "10",
        accepted: "10",
        declined: "5"
    )

    var overallModel = OverallStatsModel(
        percentage: "80%",
        presentCount: "20",
        absentCount: "10"
    )
    
    var todayModel = TodayAttendanceModel(
        sessions: [
            TodayAttendanceSession(rawString: "morning : Present"),
            TodayAttendanceSession(rawString: "AfterNoon : Absent"),
            TodayAttendanceSession(rawString: "Evening : Not taken")
        ]
    )
    
    var outpassRequestsModel = OutpassRequestsModel(
        requests: [
            OutpassRequestData(reason: "i  am sick", fromToDate: "13/10/2000 -  15/10/2000", requestTime: "04:00 AM", status: "Pending"),
            OutpassRequestData(reason: "i  am sick", fromToDate: "13/10/2000 -  15/10/2000", requestTime: "04:00 AM", status: "Accepted")
        ]
    )
    
    var hostelInfoModel = HostelInformationModel(
        infoBlocks: [
            HostelInfoData(rawString: "warden name : saranraj "),
            HostelInfoData(rawString: "Address : 3/18 kaverstreet")
        ]
    )
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0.96, alpha: 1)
        studentDataFullView.layer.cornerRadius = 10
        monthStatusFullView.layer.cornerRadius = 10
        attendaceStatusFullView.layer.cornerRadius = 10
        studentDataFullView.layer.cornerRadius = 15
        setupTableView()
    }


    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func setupTableView() {
//        tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
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
        
    }
    
   
}
   

extension parentHostelDashboardVC : UITableViewDelegate, UITableViewDataSource,newRequestScreen {
    func newOutpassVc() {
        let vc = NewOutpassRequestVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 { return 110 } // Overall Stats
//        else if indexPath.row == 1 { return 270 } // Today's Attendance
       if indexPath.row == 2 { return 450 } // Attendance Overview
//        else if indexPath.row == 3 { return 380 } // Session-wise Analysis
//        else if indexPath.row == 4 { return 280 } // Weekly Trend
//        else if indexPath.row == 5 { return 450 } // Detailed Records
//        else if indexPath.row == 6 { return 260 } // Outpass stats
//        else if indexPath.row == 7 { return 360 } // Outpass Requests
//        else { return 200 } // Hostel Info
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "GatePassTvcell", for: indexPath) as! GatePassTvcell
            cell.selectionStyle = .none
            return cell
        }

    else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodayAttendanceCell", for: indexPath) as! TodayAttendanceCell
            cell.configure(with: todayModel)
        cell.selectionStyle = .none
            return cell
        }

        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailedAttendanceCell", for: indexPath) as! DetailedAttendanceCell
            cell.configure(with: detailedModel)
            cell.selectionStyle = .none
            return cell
        }
        else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutpassStatsCell", for: indexPath) as! OutpassStatsCell
            cell.configure(with: outpassModel)
            cell.selectionStyle = .none
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutpassRequestsCell", for: indexPath) as! OutpassRequestsCell
            cell.configure(with: outpassRequestsModel)
            cell.newRequestdelegate = self
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HostelInfoCell", for: indexPath) as! HostelInfoCell
            cell.configure(with: hostelInfoModel)
            cell.selectionStyle = .none
            return cell
        }
    }
}

