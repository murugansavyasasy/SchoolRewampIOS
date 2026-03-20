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
    var stats: DashboardStats!
    var rooms: [Room] = []
    var dashBoardDataDetails: [HostelDashBoardData] = []
    var floors: [HostelDashBoardFloor] = []
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        HostelDashboardDateView.layer.cornerRadius = 15
        setupData()
        setupTableView()
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
//        stats = DashboardStats(
//            occupiedRooms: "6/8", emptyRooms: "2 Empty", bedsOccupied: "19/34",
//            availableBeds: "15 Available", totalStudents: "19", pendingIssues: "2",
//            outpassRequests: "1")

        stats = DashboardStats(totalStudents: "30", outpassRequests: "1")
        floors.removeAll()
        floors.append(contentsOf: [HostelDashBoardFloor(
            id: "1", floor_no: "1", floor_name: "Floor 1",
            rooms: [
                HostelDashBoardRooms(id: "101", number: "Room 101", currentOccupancy: 3, maxOccupancy: 5, totalBeds: 5, students: ["Ramesh", "Raja", "+2 more"]),
                HostelDashBoardRooms(id: "102", number: "Room 102", currentOccupancy: 2, maxOccupancy: 5, totalBeds: 5, students: ["Arun", "Kumar"]),
                HostelDashBoardRooms(id: "103", number: "Room 103", currentOccupancy: 4, maxOccupancy: 5, totalBeds: 5, students: ["Vijay", "Ajay", "+2 more"]),
                HostelDashBoardRooms(id: "104", number: "Room 104", currentOccupancy: 1, maxOccupancy: 5, totalBeds: 5, students: ["Siva"]),
                HostelDashBoardRooms(id: "105", number: "Room 105", currentOccupancy: 5, maxOccupancy: 5, totalBeds: 5, students: ["A", "B", "+3 more"])
            ]
        ),

        HostelDashBoardFloor(
            id: "2", floor_no: "2", floor_name: "Floor 2",
            rooms: [
                HostelDashBoardRooms(id: "201", number: "Room 201", currentOccupancy: 2, maxOccupancy: 5, totalBeds: 5, students: ["Karthik", "Mani"]),
                HostelDashBoardRooms(id: "202", number: "Room 202", currentOccupancy: 3, maxOccupancy: 5, totalBeds: 5, students: ["Suresh", "Ravi", "+1 more"]),
                HostelDashBoardRooms(id: "203", number: "Room 203", currentOccupancy: 5, maxOccupancy: 5, totalBeds: 5, students: ["A", "B", "+3 more"]),
                HostelDashBoardRooms(id: "204", number: "Room 204", currentOccupancy: 1, maxOccupancy: 5, totalBeds: 5, students: ["John"]),
                HostelDashBoardRooms(id: "205", number: "Room 205", currentOccupancy: 4, maxOccupancy: 5, totalBeds: 5, students: ["Deepak", "Hari", "+2 more"])
            ]
        ),

        HostelDashBoardFloor(
            id: "3", floor_no: "3", floor_name: "Floor 3",
            rooms: [
                HostelDashBoardRooms(id: "301", number: "Room 301", currentOccupancy: 3, maxOccupancy: 5, totalBeds: 5, students: ["Vimal", "Raj", "+1 more"]),
                HostelDashBoardRooms(id: "302", number: "Room 302", currentOccupancy: 2, maxOccupancy: 5, totalBeds: 5, students: ["Kiran", "Surya"]),
                HostelDashBoardRooms(id: "303", number: "Room 303", currentOccupancy: 5, maxOccupancy: 5, totalBeds: 5, students: ["A", "B", "+3 more"]),
                HostelDashBoardRooms(id: "304", number: "Room 304", currentOccupancy: 1, maxOccupancy: 5, totalBeds: 5, students: ["Naveen"]),
                HostelDashBoardRooms(id: "305", number: "Room 305", currentOccupancy: 4, maxOccupancy: 5, totalBeds: 5, students: ["Arjun", "Mohan", "+2 more"])
            ]
        ),

        HostelDashBoardFloor(
            id: "4", floor_no: "4", floor_name: "Floor 4",
            rooms: [
                HostelDashBoardRooms(id: "401", number: "Room 401", currentOccupancy: 2, maxOccupancy: 5, totalBeds: 5, students: ["Hari", "Ram"]),
                HostelDashBoardRooms(id: "402", number: "Room 402", currentOccupancy: 3, maxOccupancy: 5, totalBeds: 5, students: ["Sathish", "Gopi", "+1 more"]),
                HostelDashBoardRooms(id: "403", number: "Room 403", currentOccupancy: 5, maxOccupancy: 5, totalBeds: 5, students: ["A", "B", "+3 more"]),
                HostelDashBoardRooms(id: "404", number: "Room 404", currentOccupancy: 1, maxOccupancy: 5, totalBeds: 5, students: ["Raja"]),
                HostelDashBoardRooms(id: "405", number: "Room 405", currentOccupancy: 4, maxOccupancy: 5, totalBeds: 5, students: ["Vicky", "Ajith", "+2 more"])
            ]
        ),

        HostelDashBoardFloor(
            id: "5", floor_no: "5", floor_name: "Floor 5",
            rooms: [
                HostelDashBoardRooms(id: "501", number: "Room 501", currentOccupancy: 3, maxOccupancy: 5, totalBeds: 5, students: ["Santhosh", "Kumar", "+1 more"]),
                HostelDashBoardRooms(id: "502", number: "Room 502", currentOccupancy: 2, maxOccupancy: 5, totalBeds: 5, students: ["Dinesh", "Ravi"]),
                HostelDashBoardRooms(id: "503", number: "Room 503", currentOccupancy: 5, maxOccupancy: 5, totalBeds: 5, students: ["A", "B", "+3 more"]),
                HostelDashBoardRooms(id: "504", number: "Room 504", currentOccupancy: 1, maxOccupancy: 5, totalBeds: 5, students: ["Karthi"]),
                HostelDashBoardRooms(id: "505", number: "Room 505", currentOccupancy: 4, maxOccupancy: 5, totalBeds: 5, students: ["Arun", "Mani", "+2 more"])
            ]
        ),

        HostelDashBoardFloor(
            id: "6", floor_no: "6", floor_name: "Floor 6",
            rooms: [
                HostelDashBoardRooms(id: "601", number: "Room 601", currentOccupancy: 2, maxOccupancy: 5, totalBeds: 5, students: ["Ravi", "Kumar"]),
                HostelDashBoardRooms(id: "602", number: "Room 602", currentOccupancy: 3, maxOccupancy: 5, totalBeds: 5, students: ["Vijay", "Surya", "+1 more"]),
                HostelDashBoardRooms(id: "603", number: "Room 603", currentOccupancy: 5, maxOccupancy: 5, totalBeds: 5, students: ["A", "B", "+3 more"]),
                HostelDashBoardRooms(id: "604", number: "Room 604", currentOccupancy: 1, maxOccupancy: 5, totalBeds: 5, students: ["Siva"]),
                HostelDashBoardRooms(id: "605", number: "Room 605", currentOccupancy: 4, maxOccupancy: 5, totalBeds: 5, students: ["Ajay", "Deepak", "+2 more"])
            ]
        ),

        HostelDashBoardFloor(
            id: "7", floor_no: "7", floor_name: "Floor 7",
            rooms: [
                HostelDashBoardRooms(id: "701", number: "Room 701", currentOccupancy: 3, maxOccupancy: 5, totalBeds: 5, students: ["Kiran", "Ramesh", "+1 more"]),
                HostelDashBoardRooms(id: "702", number: "Room 702", currentOccupancy: 2, maxOccupancy: 5, totalBeds: 5, students: ["Arun", "Bala"]),
                HostelDashBoardRooms(id: "703", number: "Room 703", currentOccupancy: 5, maxOccupancy: 5, totalBeds: 5, students: ["A", "B", "+3 more"]),
                HostelDashBoardRooms(id: "704", number: "Room 704", currentOccupancy: 1, maxOccupancy: 5, totalBeds: 5, students: ["Vicky"]),
                HostelDashBoardRooms(id: "705", number: "Room 705", currentOccupancy: 4, maxOccupancy: 5, totalBeds: 5, students: ["Mani", "Hari", "+2 more"])
            ]
        ),

        HostelDashBoardFloor(
            id: "8", floor_no: "8", floor_name: "Floor 8",
            rooms: [
                HostelDashBoardRooms(id: "801", number: "Room 801", currentOccupancy: 2, maxOccupancy: 5, totalBeds: 5, students: ["Sathish", "Gopi"]),
                HostelDashBoardRooms(id: "802", number: "Room 802", currentOccupancy: 3, maxOccupancy: 5, totalBeds: 5, students: ["Raja", "Kumar", "+1 more"]),
                HostelDashBoardRooms(id: "803", number: "Room 803", currentOccupancy: 5, maxOccupancy: 5, totalBeds: 5, students: ["A", "B", "+3 more"]),
                HostelDashBoardRooms(id: "804", number: "Room 804", currentOccupancy: 1, maxOccupancy: 5, totalBeds: 5, students: ["John"]),
                HostelDashBoardRooms(id: "805", number: "Room 805", currentOccupancy: 4, maxOccupancy: 5, totalBeds: 5, students: ["Ajith", "Surya", "+2 more"])
            ]
        ),

        HostelDashBoardFloor(
            id: "9", floor_no: "9", floor_name: "Floor 9",
            rooms: [
                HostelDashBoardRooms(id: "901", number: "Room 901", currentOccupancy: 3, maxOccupancy: 5, totalBeds: 5, students: ["Arun", "Ravi", "+1 more"]),
                HostelDashBoardRooms(id: "902", number: "Room 902", currentOccupancy: 2, maxOccupancy: 5, totalBeds: 5, students: ["Mani", "Karthik"]),
                HostelDashBoardRooms(id: "903", number: "Room 903", currentOccupancy: 5, maxOccupancy: 5, totalBeds: 5, students: ["A", "B", "+3 more"]),
                HostelDashBoardRooms(id: "904", number: "Room 904", currentOccupancy: 1, maxOccupancy: 5, totalBeds: 5, students: ["Suresh"]),
                HostelDashBoardRooms(id: "905", number: "Room 905", currentOccupancy: 4, maxOccupancy: 5, totalBeds: 5, students: ["Vijay", "Deepak", "+2 more"])
            ]
        ),

        HostelDashBoardFloor(
            id: "10", floor_no: "10", floor_name: "Floor 10",
            rooms: [
                HostelDashBoardRooms(id: "1001", number: "Room 1001", currentOccupancy: 2, maxOccupancy: 5, totalBeds: 5, students: ["Hari", "Ram"]),
                HostelDashBoardRooms(id: "1002", number: "Room 1002", currentOccupancy: 3, maxOccupancy: 5, totalBeds: 5, students: ["Siva", "Ajay", "+1 more"]),
                HostelDashBoardRooms(id: "1003", number: "Room 1003", currentOccupancy: 5, maxOccupancy: 5, totalBeds: 5, students: ["A", "B", "+3 more"]),
                HostelDashBoardRooms(id: "1004", number: "Room 1004", currentOccupancy: 1, maxOccupancy: 5, totalBeds: 5, students: ["Kumar"]),
                HostelDashBoardRooms(id: "1005", number: "Room 1005", currentOccupancy: 4, maxOccupancy: 5, totalBeds: 5, students: ["Ramesh", "Arun", "+2 more"])
            ]
        )])
        print("statsstats",stats)
        print("roomsrooms",rooms)
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

            // Build student info dynamically based on existing room generic string entries just for UI showcase
            // The user wanted parent phone number added natively.
            var studentInfos: [StudentAttendanceInfo] = []

            for (idx, stName) in (room.students ?? []).enumerated() {
                var cleanName = stName
                if stName.contains("more") {
                    cleanName = "Other Student"
                }
                studentInfos.append(
                    StudentAttendanceInfo(
                        name: cleanName, id: "s\(idx + 1)", parentNum: "Parent: 9876543210",
                        state: 0))
            }

            let vc = MarkAttendanceViewController(
                nibName: "MarkAttendanceViewController", bundle: nil)
            vc.roomTitle = room.number ?? ""
            vc.roomSubtitle = "\(room.students?.count ?? 0) Students • \(room.totalBeds ?? 0) Beds"
            vc.students = studentInfos

            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section >= 2 ? 40 : .leastNormalMagnitude
    }
    
    func GetHostelListDashboard() {
        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_list_staff, parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false) {[self] (result: Result<HostelDashBoardSuc,Error>) in
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
