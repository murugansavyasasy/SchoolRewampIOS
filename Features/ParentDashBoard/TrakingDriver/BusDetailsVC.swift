////
////  BusDetailsVC.swift
////  BusTraking
////
////  Created by Chandhru on 13/02/26.
////
//import UIKit
//import CoreLocation
//
//struct BusLiveData {
//    var speed: Double
//    var etaMinutes: Int
//    var distanceKm: Double
//    var nextStop: String
//    var currentStopIndex: Int
//}
//
//class BusDetailsVC: UIViewController, RecentMoveDelegate {
//    func recentMove(_ recent: Bool) {
//        delegate?.recentMove(recent)
//    }
//    
//    
//    // MARK: - Outlets
//    
//    @IBOutlet weak var routeProgressTableView: UITableView!
//    
//    // MARK: - Properties
//    
//    var busStops: [BusStop] = []
//    var currentLocation: CLLocation?
//    var delegate:RecentMoveDelegate?
//    var busNumber: String = "Bus #42"
//    var busRoute: String = "Route 101"
//    
//    var eta = "-- mins"
//    var distance = "-- km"
//    var speed = "-- km/h"
//    var nextStop = "--"
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupTableView()
//    }
//    
//    // MARK: - Setup
//    
//    private func setupTableView() {
//        
//        routeProgressTableView.delegate = self
//        routeProgressTableView.dataSource = self
//        routeProgressTableView.separatorStyle = .none
//        routeProgressTableView.backgroundColor = .systemBackground
//        
//        routeProgressTableView.register(
//            UINib(nibName: "BusDetailsTVC", bundle: nil),
//            forCellReuseIdentifier: "BusDetailsTVC"
//        )
//        
//        routeProgressTableView.register(UINib(nibName: "BusStopTableViewCell", bundle: nil),
//                                        forCellReuseIdentifier: BusStopTableViewCell.identifier
//        )
//    }
//    
//    // MARK: - LIVE BUS UPDATE ENTRY POINT
//    
//    func updateLiveData(_ data: BusLiveData) {
//        
//        speed = String(format: "%.0f km/h", data.speed)
//        eta = "\(data.etaMinutes) mins"
//        distance = String(format: "%.2f km", data.distanceKm)
//        nextStop = data.nextStop
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            if self.routeProgressTableView.numberOfSections > 0 {
//                self.routeProgressTableView.reloadSections(
//                    IndexSet(integer: 0),
//                    with: .none
//                )
//            }
//        }
//    }
//    
//    func updateStops(_ stops: [BusStop]) {
//        
//        self.busStops = stops
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            if !self.busStops.isEmpty && self.routeProgressTableView.numberOfSections > 1 {
//                self.routeProgressTableView.reloadSections(
//                    IndexSet(integer: 1),
//                    with: .none
//                )
//            } else {
//                // First time loading
//                self.routeProgressTableView.reloadData()
//            }
//        }
//    }
//    private func nextStopName() -> String {
//        if let currentStop = busStops.first(where: { $0.isCurrent }) {
//            return currentStop.name
//        }
//        
//        if let nextStop = busStops.first(where: { !$0.isCompleted && !$0.isCurrent }) {
//            return nextStop.name
//        }
//        
//        return nextStop
//    }
//    func callDriver() {
//        
//        let phone = "9876543210"
//        if let url = URL(string: "tel://\(phone)"),
//           UIApplication.shared.canOpenURL(url) {
//            
//            UIApplication.shared.open(url)
//        }
//    }
//    
//    func shareLocation() {
//        
//        guard let loc = currentLocation else { return }
//        
//        let link = "https://maps.google.com/?q=\(loc.coordinate.latitude),\(loc.coordinate.longitude)"
//        
//        let activityVC = UIActivityViewController(
//            activityItems: ["Bus live location:", link],
//            applicationActivities: nil
//        )
//        
//        present(activityVC, animated: true)
//    }
//}
//
//extension BusDetailsVC: UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int { 2 }
//    
//    func tableView(
//        _ tableView: UITableView,
//        numberOfRowsInSection section: Int
//    ) -> Int {
//        
//        section == 0 ? 1 : busStops.count
//    }
//    
//    func tableView(
//        _ tableView: UITableView,
//        cellForRowAt indexPath: IndexPath
//    ) -> UITableViewCell {
//        
//        if indexPath.section == 0 {
//            
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: "BusDetailsTVC",
//                for: indexPath
//            ) as! BusDetailsTVC
//            
//            cell.busNumberLabel.text = busNumber
//            cell.busRouteLabel.text = busRoute
//            cell.busStatusLabel.text = "On Route"
//            cell.etaLabel.text = eta
//            cell.distanceLabel.text = distance
//            cell.speedLabel.text = speed
//            cell.nextStopLabel.text = nextStopName()
//            cell.delegate = self
//            cell.callDriverAction = { [weak self] in
//                self?.callDriver()
//            }
//            
//            cell.shareLocationAction = { [weak self] in
//                self?.shareLocation()
//            }
//            
//            return cell
//        }
//        
//        let cell = tableView.dequeueReusableCell(
//            withIdentifier: BusStopTableViewCell.identifier,
//            for: indexPath
//        ) as! BusStopTableViewCell
//        
//        let stop = busStops[indexPath.row]
//        let isLast = indexPath.row == busStops.count - 1
//        
//        cell.configure(with: stop, isLast: isLast)
//        
//        return cell
//    }
//}
//
//extension BusDetailsVC: UITableViewDelegate {
//    
//    func tableView(
//        _ tableView: UITableView,
//        heightForRowAt indexPath: IndexPath
//    ) -> CGFloat {
//        
//        UITableView.automaticDimension
//    }
//    
//    func tableView(
//        _ tableView: UITableView,
//        titleForHeaderInSection section: Int
//    ) -> String? {
//        section == 1 ? "Route Progress" : nil
//    }
//    
//    func tableView(
//        _ tableView: UITableView,
//        didSelectRowAt indexPath: IndexPath
//    ) {
//        
//        guard indexPath.section == 1 else { return }
//        
//        let stop = busStops[indexPath.row]
//        var statusText = "Upcoming"
//        if stop.isCompleted {
//            statusText = "Completed"
//        } else if stop.isCurrent {
//            statusText = "Current Stop"
//        }
//        
//        let alert = UIAlertController(
//            title: stop.name,
//            message: """
//            Arrival: \(stop.time)
//            Status: \(statusText)
//            """,
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
