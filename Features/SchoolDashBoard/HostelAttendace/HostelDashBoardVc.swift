//
//  HostelDashBoardVc.swift
//  School Chimes
//
//  Created by apple on 03/03/26.
//

import UIKit

class HostelDashBoardVc: UIViewController {

    
    @IBOutlet weak var HostelDashboardDateView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var acodemicdropView: UIView!
    @IBOutlet weak var acodomicYearLbl: UILabel!
    var AcadimicYearDatas: [AcadimicYearData] = []
    var stats: DashboardStats!
    var rooms: [Room] = []
    var dashBoardDataDetails: [HostelDashBoardData] = []
    var floors: [HostelDashBoardFloor] = []
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var hostelData : HostelListData?
    let acidamicdrops = DropDown()
    var accadimYr: [String] = []
    var academicId : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        HostelDashboardDateView.layer.cornerRadius = 15
        setupData()
        setupTableView()
        GetHostelListDashboard()
        acodemicdropView.layer.cornerRadius = 8
        acodemicdropView.layer.borderWidth = 1
        acodemicdropView.layer.borderColor = UIColor.white.cgColor
        getacadmicYr()
        
        let accadmicYrTap = UITapGestureRecognizer(target: self, action: #selector(selectAcodemic))
        acodemicdropView.addGestureRecognizer(accadmicYrTap)
       
    }

    func getacadmicYr() {
        showActivityLoader()
        APIService.shared.makeApi(
            url: ServiceUrl.comm_recipient_get_academic_year_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
        ) { [self] (result: Result<get_academic_yearSuc, Error>) in
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async { [self] in
                    AcadimicYearDatas = response.data ?? []
                   
                    for year in AcadimicYearDatas where year.current_academic_year == true {
                        acodomicYearLbl.text = year.year
                        academicId = String(year.id ?? 0)
                        GetHostelListDashboard()
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
              
            }
            hideActivityLoader()
        }
    }
    
    @IBAction func selectAcodemic() {
        accadimYr = AcadimicYearDatas.compactMap { $0.year }
        acidamicdrops.anchorView = acodemicdropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acodemicdropView.bounds.height)
        acidamicdrops.show()
        
        acidamicdrops.selectionAction = { [self] (index: Int, item: String) in
            acodomicYearLbl.text = item
            academicId = String(AcadimicYearDatas[index].id ?? 0)
            GetHostelListDashboard()
        }
    }
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        view.layer.backgroundColor = UIColor(white: 0.97, alpha: 1.0).cgColor
        tableView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(StatsticTvCell.self)
        tableView.register(TodaysAttendaceTvcell.self)
        tableView.register(HostelRoomTvCell.self)
        
    }

    private func setupData() {
        stats = DashboardStats(totalStudents: "30", outpassRequests: "1")
    }


    @IBAction func BackBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension HostelDashBoardVc : UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + floors.count
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 || section == 1 {
            return 1
        } else {
            let floorIndex = section - 2
            return floors[safe: floorIndex]?.rooms?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "StatsticTvCell", for: indexPath)
                as! StatsticTvCell
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        case 1:
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "TodaysAttendaceTvcell", for: indexPath)
                as! TodaysAttendaceTvcell
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        case 2...:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HostelRoomTvCell", for: indexPath) as! HostelRoomTvCell
            cell.selectionStyle = .none

            let floorIndex = indexPath.section - 2

            if let room = floors[safe: floorIndex]?.rooms?[safe: indexPath.row] {
                cell.configure(with: room)
            }

            return cell
        default: return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section >= 2 {

            let floorIndex = section - 2
            guard let floor = floors[safe: floorIndex] else { return nil }

            let headerView = UIView()
            headerView.backgroundColor = .clear

            let titleLabel = UILabel()
            titleLabel.text = floor.floor_name   // ✅ dynamic set
            titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.textColor = .lightGray

            headerView.addSubview(titleLabel)

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
                titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ])

            return headerView
        }

        return nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section >= 2 {
            let floorIndex = indexPath.section - 2

            guard let room = floors[safe: floorIndex]?.rooms?[safe: indexPath.row] else { return }

            let vc = MarkAttendanceViewController(
                nibName: "MarkAttendanceViewController", bundle: nil)
            vc.roomTitle = room.number ?? ""
            vc.roomSubtitle = "\(room.students?.count ?? 0) Students • \(room.total_beds ?? 0) Beds"
            vc.hostelId = hostelData?.id ?? ""
            vc.roomId = room.id ?? ""
            vc.academic_year_id = academicId
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section >= 2 ? 40 : .leastNormalMagnitude
    }
    
    func GetHostelListDashboard() {
        APIService.shared.makeApi(url: ServiceUrl.hostel_attendance_room_details, parameters: ["hostel_id": hostelData?.id ?? "" ,"academic_year_id" : academicId ?? ""], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false) {[self] (result: Result<HostelDashBoardSuc,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    if let data = Success.data {
                           self.dashBoardDataDetails = data
                           self.floors = data.first?.floors ?? []
                           self.tableView.reloadData()
                       }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                   
                }
            }
        }
    }
    
}

extension HostelDashBoardVc: AttendanceSummaryCellDelegate {
    func didTapViewHistory() {
        let vc = AttendanceHistoryViewController(
            nibName: "AttendanceHistoryViewController", bundle: nil)
        vc.hostelId = hostelData?.id
        vc.academicYearId = academicId
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
}

extension HostelDashBoardVc: DashboardStatsCellDelegate {
    func MessMenu() {
        let vc = MesstimeTabelVC(nibName: "MesstimeTabelVC", bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    func didTapPendingIssues() {
        let vc = AdminRequestsViewController(nibName: "AdminRequestsViewController", bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
        
    }
    
    func didTapOutpassRequests() {
        let vc = OutpassRequestsViewController(
            nibName: "OutpassRequestsViewController", bundle: nil)
        vc.hostelId = hostelData?.id ?? ""
        vc.accidemicyearId = academicId ?? ""
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
        
    }
}


struct DashboardStats {
//    let occupiedRooms: String
//    let emptyRooms: String
//    let bedsOccupied: String
//    let availableBeds: String
    let totalStudents: String
//    let pendingIssues: String
    let outpassRequests: String
}

struct Room {
    let number: String
    let hasAlert: Bool
    let currentOccupancy: Int
    let maxOccupancy: Int
    let totalBeds: Int
    let students: [String]
}
