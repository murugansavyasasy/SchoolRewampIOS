//
//  busListVC.swift
//  School Chimes
//
//  Created by apple on 08/05/26.
//

import UIKit

class busListVC: UIViewController {
  
    @IBOutlet weak var studentname: UILabel!
    @IBOutlet weak var tv: UITableView!
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var loginasType : Int?
    var is_wonBustracking : Bool = false
  
    // Parsed Data Store
    private var routeData: [StudentRouteData] = [StudentRouteData(
        student_id: "10001",
        student_name: "Arun Kumar",
        admission_no: "SKV-001",
        route_id: "101",
        route_name: "Route A",
        stop_id: "5001",
        stop_name: "Anna Nagar Bus Stop",
        latitude: "13.0878",
        longitude: "80.2101",
        landmark: "Near Anna Arch",
        vehicle_id: "2001",
        vehicle_no: "TN01AB1234",
        tentative_pickup_time: "07:45 am",
        tentative_drop_time: "04:45 pm",
        stopping_points: [
            StoppingPoint(
                vehicle_id: "2001",
                route_name: "Route A",
                journey_type: "PICKING",
                start_time: "07:30 am",
                end_time: "08:00 am",
                working_days: [
                    "MONDAY",
                    "TUESDAY",
                    "WEDNESDAY",
                    "THURSDAY",
                    "FRIDAY"
                ],
                stops: [
                    Stops(
                        stop_id: "5000",
                        stop_name: "School Campus",
                        stop_time: "07:30 am",
                        latitude: "13.0827",
                        longitude: "80.2707",
                        landmark: "Main Gate"
                    ),
                    Stops(
                        stop_id: "5001",
                        stop_name: "Anna Nagar Bus Stop",
                        stop_time: "07:45 am",
                        latitude: "13.0878",
                        longitude: "80.2101",
                        landmark: "Near Anna Arch"
                    )
                ]
            ),
            StoppingPoint(
                vehicle_id: "2001",
                route_name: "Route A",
                journey_type: "DROPPING",
                start_time: "04:30 pm",
                end_time: "05:00 pm",
                working_days: [
                    "MONDAY",
                    "TUESDAY",
                    "WEDNESDAY",
                    "THURSDAY",
                    "FRIDAY"
                ],
                stops: [
                    Stops(
                        stop_id: "5000",
                        stop_name: "School Campus",
                        stop_time: "04:30 pm",
                        latitude: "13.0827",
                        longitude: "80.2707",
                        landmark: "Main Gate"
                    ),
                    Stops(
                        stop_id: "5001",
                        stop_name: "Anna Nagar Bus Stop",
                        stop_time: "04:45 pm",
                        latitude: "13.0878",
                        longitude: "80.2101",
                        landmark: "Near Anna Arch"
                    )
                ]
            )
        ]
    )]
    
    private var routeDataList: [StudentRouteData] = []
    
    // Track expand/collapse state per student row (default: pickup expanded, drop collapsed)
    private var pickupExpansionStates: [Int: Bool] = [:]
    private var dropExpansionStates: [Int: Bool] = [:]
    private let mockJSONPayload = """
    {
      "status": true,
      "message": "Successfully got the student route details.",
      "data": [
        {
          "student_id": "60159782",
          "student_name": "Test 1",
          "admission_no": "SS-582",
          "route_id": "2802",
          "route_name": "E12",
          "stop_id": "19514",
          "stop_name": "Vinayak Nagar- Ramdev Super Market",
          "latitude": "18.66769",
          "longitude": "78.11122",
          "landmark": "Bombay Bakery",
          "vehicle_id": "2484",
          "vehicle_no": "TS16UA9430",
          "tentative_pickup_time": "07:40 am",
          "tentative_drop_time": "06:50 pm",
          "stopping_points": [
            {
              "vehicle_id": "2484",
              "route_name": "E12",
              "journey_type": "PICKING",
              "start_time": "07:35 am",
              "end_time": "07:45 am",
              "working_days": [
                "MONDAY",
                "TUESDAY",
                "WEDNESDAY",
                "THURSDAY",
                "FRIDAY",
                "SATURDAY"
              ],
              "stops": [
                {
                  "stop_id": "19485",
                  "stop_name": "Nilgiri Campus",
                  "stop_time": "07:35 am",
                  "latitude": "18.67125",
                  "longitude": "78.11256",
                  "landmark": "Prashanthi Homes"
                },
                {
                  "stop_id": "19514",
                  "stop_name": "Vinayak Nagar- Ramdev Super Market",
                  "stop_time": "07:40 am",
                  "latitude": "18.66769",
                  "longitude": "78.11122",
                  "landmark": "Bombay Bakery"
                }
              ]
            },
            {
              "vehicle_id": "2484",
              "route_name": "E12",
              "journey_type": "DROPPING",
              "start_time": "06:45 pm",
              "end_time": "06:55 pm",
              "working_days": [
                "MONDAY",
                "TUESDAY",
                "WEDNESDAY",
                "THURSDAY",
                "FRIDAY",
                "SATURDAY"
              ],
              "stops": [
                {
                  "stop_id": "19513",
                  "stop_name": "Bharath Gas Godown- Vinayak Nagar",
                  "stop_time": "06:45 pm",
                  "latitude": "18.67715",
                  "longitude": "78.10865",
                  "landmark": "Bombay Bakery"
                },
                {
                  "stop_id": "19514",
                  "stop_name": "Vinayak Nagar- Ramdev Super Market",
                  "stop_time": "06:50 pm",
                  "latitude": "18.66769",
                  "longitude": "78.11122",
                  "landmark": "Bombay Bakery"
                }
              ]
            }
          ]
        }
      ]
    }
    """
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        parseAPIPayload()
        setupTableView()
        tv.reloadData()
        let name = studentDetails?.name ?? ""
        let standard = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        studentname.configureAsBackTitle(firstLine: name, secondLine: standard)
        
   
        
//        GetBusRoutDetails()
       
    }

    
    private func setupTableView() {
        
        tv.delegate = self
        tv.dataSource = self
        
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 600
        tv.showsVerticalScrollIndicator = false
        
        // Register single cell
        tv.register(UINib(nibName: "RouteHeaderCell", bundle: nil), forCellReuseIdentifier: "RouteHeaderCell")
    }
    
    private func parseAPIPayload() {
        guard let data = mockJSONPayload.data(using: .utf8) else {
            print("Failed to convert mock JSON string to data")
            return
        }
        
        do {
            let response = try JSONDecoder().decode(StudentRouteDetailsResponse.self, from: data)
            self.routeDataList = response.data ?? []
        } catch {
            print("Error parsing student route details JSON: \(error)")
        }
    }
    @IBAction func backbtnAct(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    
    func GetBusRoutDetails() {
        APIService.shared.makeApi(url: ServiceUrl.get_student_route_list, parameters: [:], type: ApitTypeSringFile.GET, token: (loginasType == 2 ? UserDefaultFileManager.get_child_Details()?.access_token : UserDefaultFileManager.get_staff_Details()?.access_token) ?? "", isBaseUrl: false) {[self] (result: Result<StudentRouteDetailsResponse,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    if Success.status ?? false{
                        routeData = Success.data ?? []
                        tv.reloadData()
                    }else{
                        tv.reloadData()
                       
//                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: Success.message ?? "", on: self) {
//                            self.dismiss(animated: true)
//                        }
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
    
    
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension busListVC: UITableViewDataSource, UITableViewDelegate {
    
    private func findMyBus() {
        let vc = BusTrakingVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func dropfunction(){
        let vc = whereismybusVc(nibName: nil, bundle: nil)
        vc.loginasType = loginasType
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func pickfunction(){
        let vc = whereismybusVc(nibName: nil, bundle: nil)
        vc.loginasType = loginasType
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteHeaderCell", for: indexPath) as! RouteHeaderCell
        let studentData = routeDataList[indexPath.row]
        
        let isPickupExpanded = pickupExpansionStates[indexPath.row, default: false]
        let isDropExpanded = dropExpansionStates[indexPath.row, default: false]
        
        cell.configure(with: studentData, isPickupExpanded: isPickupExpanded, isDropExpanded: isDropExpanded)
        
        cell.onTogglePickup = { [weak self, weak tableView] in
            guard let self = self, let tableView = tableView else { return }
            let current = self.pickupExpansionStates[indexPath.row, default: true]
            let newPickupState = !current
            self.pickupExpansionStates[indexPath.row] = newPickupState
            
            // If expanding pickup, collapse drop
            if newPickupState {
                self.dropExpansionStates[indexPath.row] = false
            }
            
            let updatedPickup = newPickupState
            let updatedDrop = self.dropExpansionStates[indexPath.row, default: false]
            
            cell.configure(with: studentData, isPickupExpanded: updatedPickup, isDropExpanded: updatedDrop)
            
            UIView.animate(withDuration: 0.3) {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        
        cell.onToggleDrop = { [weak self, weak tableView] in
            guard let self = self, let tableView = tableView else { return }
            let current = self.dropExpansionStates[indexPath.row, default: false]
            let newDropState = !current
            self.dropExpansionStates[indexPath.row] = newDropState
            
            // If expanding drop, collapse pickup
            if newDropState {
                self.pickupExpansionStates[indexPath.row] = false
            }
            
            let updatedPickup = self.pickupExpansionStates[indexPath.row, default: true]
            let updatedDrop = newDropState
            
            cell.configure(with: studentData, isPickupExpanded: updatedPickup, isDropExpanded: updatedDrop)
            
            UIView.animate(withDuration: 0.3) {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        
        if is_wonBustracking{
            cell.findMypickBusBtnname.isHidden = false
            cell.findMyDropBusBtnName.isHidden = false
            cell.findMyBusButton.isHidden = true
        }else{
            cell.findMypickBusBtnname.isHidden = true
            cell.findMyDropBusBtnName.isHidden = true
            cell.findMyBusButton.isHidden = false
        }
        
        cell.onFindMyBus = { [weak self] in
            guard let self = self else { return }
            self.findMyBus()
        }
        cell.onFindPickupMyBus = { [weak self] in
            guard let self = self else { return }
            self.pickfunction()
        }
        cell.onFindDropMyBus = { [weak self] in
            guard let self = self else { return }
            self.dropfunction()
        }
        
        cell.onSizeChanged = { [weak tableView] in
            UIView.performWithoutAnimation {
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
        }
        
        return cell
    }
}
