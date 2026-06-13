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
    
    private var routeDataList: [StudentRouteData] = []
    private var pickupExpansionStates: [Int: Bool] = [:]
    private var dropExpansionStates: [Int: Bool] = [:]
   var myLates = ""
    var myLongs = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupTableView()

        let name = studentDetails?.name ?? ""
        let standard = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        studentname.configureAsBackTitle(firstLine: name, secondLine: standard)
        
        GetBusRoutDetails()
       
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
    

    @IBAction func backbtnAct(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    
    func GetBusRoutDetails() {
        APIService.shared.makeApi(url: ServiceUrl.get_student_route_list, parameters: [:], type: ApitTypeSringFile.GET, token: (loginasType == 2 ? UserDefaultFileManager.get_child_Details()?.access_token : UserDefaultFileManager.get_staff_Details()?.access_token) ?? "", isBaseUrl: false) {[self] (result: Result<StudentRouteDetailsResponse,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    if Success.status ?? false{
                        self.routeDataList = Success.data ?? []
                        if let route = routeDataList.first,
                           let location = getLatLong(for: route) {

                            myLates = location.lat ?? ""
                            myLongs = location.long ?? ""
                        }
                        tv.reloadData()
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

    func getLatLong(for route: StudentRouteData) -> (lat: String?, long: String?)? {
        
        for stoppingPoint in route.stopping_points ?? [] {
            if let stop = stoppingPoint.stops?.first(where: {
                $0.stop_id == route.stop_id
            }) {
                return (stop.latitude, stop.longitude)
            }
        }
        
        return nil
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension busListVC: UITableViewDataSource, UITableViewDelegate {
    
    private func findMyBus() {
        let vc = whereismybusVc(nibName: nil, bundle: nil)
        vc.loginasType = loginasType
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    private func dropfunction(index : Int,myLate : String,myLong : String){
        guard let stoppingPoint = routeDataList[index].stopping_points?.last else {
            return
        }
        
        if stoppingPoint.journey_type == "DROPPING" {
            let vc = BusTrakingVC(nibName: nil, bundle: nil)
            vc.isPickingRoute = false
            vc.busnumber = routeDataList[index].vehicle_reg_no ?? ""
            vc.destinationLatitude = myLate
            vc.destinationLongitude = myLong
            vc.stops = stoppingPoint.stops ?? []
            vc.maproutUrl = routeDataList[index].map_url_schoolchimes ?? ""
            vc.vehicleId =  routeDataList[index].vehicle_reg_no ?? ""
            vc.routeId = routeDataList[index].route_id
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)

        }
    }
    
    private func pickfunction(index:Int){
        guard let stoppingPoint = routeDataList[index].stopping_points?.first else {
               return
           }

           if stoppingPoint.journey_type == "PICKING" {
               let vc = BusTrakingVC(nibName: nil, bundle: nil)
               vc.isPickingRoute = true
               vc.busnumber = routeDataList[index].vehicle_reg_no ?? ""
               vc.stops = stoppingPoint.stops ?? []
               vc.vehicleId = routeDataList[index].vehicle_reg_no ?? ""
               vc.routeId = routeDataList[index].route_id
               vc.maproutUrl = routeDataList[index].map_url_schoolchimes ?? ""
               vc.modalPresentationStyle = .fullScreen
               present(vc, animated: true)

           }
       
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
            cell.pickupHeaderContainer.isHidden = false
            cell.dropHeaderContainer.isHidden = false
        }else{
            cell.findMypickBusBtnname.isHidden = true
            cell.findMyDropBusBtnName.isHidden = true
            cell.findMyBusButton.isHidden = false
            cell.pickupHeaderContainer.isHidden = true
            cell.dropHeaderContainer.isHidden = true
        }
        
        cell.onFindMyBus = { [weak self] in
            guard let self = self else { return }
            self.findMyBus()
        }
        cell.onFindPickupMyBus = { [weak self] index in
            guard let self = self else { return }
            self.pickfunction(index: index)
        }
        cell.onFindDropMyBus = { [weak self] index in
            guard let self = self else { return }
            self.dropfunction(index: index,myLate: myLates,myLong: myLongs)
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
