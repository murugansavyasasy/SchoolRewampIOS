//
//  BusDetailsVC.swift
//  BusTraking
//
//  Created by Chandhru on 13/02/26.
//
import UIKit
import CoreLocation

struct BusLiveData {
    var speed: Double
    var etaMinutes: Int
    var distanceKm: Double
    var nextStop: String
    var currentStopIndex: Int
}

class BusDetailsVC: UIViewController, RecentMoveDelegate {
    func recentMove(_ recent: Bool) {
        delegate?.recentMove(recent)
    }
    
    // MARK: - Outlets
    @IBOutlet weak var routeProgressTableView: UITableView!
    @IBOutlet weak var callDriverButton: UIButton!
    @IBOutlet weak var shareLocationButton: UIButton!
    
    // MARK: - Properties
    var busStops: [BusStop] = []
    var currentLocation: CLLocation?
    var delegate:RecentMoveDelegate?
    var busNumber: String = "Bus #42"
    var busRoute: String = "Villupuram to  ulundurpet"
    var eta = "-- mins"
    var distance = "-- km"
    var speed = "-- km/h"
    var nextStop = "--"
    
    weak var liveCell: BusDetailsTVC?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        callDriverButton.layer.cornerRadius = 12
        shareLocationButton.layer.cornerRadius = 12
        shareLocationButton.layer.borderWidth = 2
        shareLocationButton.layer.borderColor = UIColor.systemGray5.cgColor
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        
        routeProgressTableView.delegate = self
        routeProgressTableView.dataSource = self
        routeProgressTableView.separatorStyle = .none
        routeProgressTableView.backgroundColor = .systemBackground
        
        routeProgressTableView.register(
            UINib(nibName: "BusDetailsTVC", bundle: nil),
            forCellReuseIdentifier: "BusDetailsTVC"
        )
        
        routeProgressTableView.register(
            UINib(nibName: "BusStopTableViewCell", bundle: nil),
            forCellReuseIdentifier: BusStopTableViewCell.identifier
        )
    }
    
    // MARK: - LIVE BUS UPDATE ENTRY POINT
    func updateLiveData(_ data: BusLiveData) {

        speed = String(format: "%.0f km/h", data.speed)
        eta = "\(data.etaMinutes) mins"
        distance = String(format: "%.2f km", data.distanceKm)
        nextStop = data.nextStop

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.liveCell?.busspeedFullView.isHidden = data.etaMinutes == 0 || data.distanceKm == 0.0
            self.liveCell?.etaLabel.text = self.eta
            self.liveCell?.distanceLabel.text = self.distance
            self.liveCell?.speedLabel.text = self.speed
            self.liveCell?.nextStopLabel.text = self.nextStopName()
        }
    }
    
    private var previousStops: [BusStop] = []

    func updateStops(_ stops: [BusStop]) {

        let oldStops = previousStops
        previousStops = stops
        busStops = stops

        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }

            if oldStops.isEmpty {

                self.routeProgressTableView.reloadData()
                return
            }

            var changedRows: [IndexPath] = []

            for index in 0..<min(oldStops.count, stops.count) {

                if oldStops[index].isCompleted != stops[index].isCompleted ||
                    oldStops[index].isCurrent != stops[index].isCurrent {

                    changedRows.append(
                        IndexPath(row: index, section: 1)
                    )
                }
            }

            if !changedRows.isEmpty {

                self.routeProgressTableView.reloadRows(
                    at: changedRows,
                    with: .none
                )
            }
        }
    }
    
    private func nextStopName() -> String {
        if let currentStop = busStops.first(where: { $0.isCurrent }) {
            return currentStop.stop_name
        }
        
        if let nextStop = busStops.first(where: { !$0.isCompleted && !$0.isCurrent }) {
            return nextStop.stop_name
        }
        
        return nextStop
    }
    
    func callDriver() {
        
        let phone = "9876543210"
        if let url = URL(string: "tel://\(phone)"),
           UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url)
        }
    }
    
    func shareLocation() {
        
        guard let loc = currentLocation else { return }
        
        let link = "https://maps.google.com/?q=\(loc.coordinate.latitude),\(loc.coordinate.longitude)"
        
        let activityVC = UIActivityViewController(
            activityItems: ["Bus live location:", link],
            applicationActivities: nil
        )
        
        present(activityVC, animated: true)
    }
}

extension BusDetailsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        
        section == 0 ? 1 : busStops.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "BusDetailsTVC",
                for: indexPath
            ) as! BusDetailsTVC
            
            liveCell = cell
            
            cell.busNumberLabel.text = busNumber
            cell.busRouteLabel.text = busRoute
            cell.busStatusLabel.text = "LIVE"
            cell.etaLabel.text = eta
            cell.distanceLabel.text = distance
            cell.speedLabel.text = speed
            cell.nextStopLabel.text = nextStopName()
            cell.delegate = self
            cell.callDriverAction = { [weak self] in
                self?.callDriver()
            }
            
            cell.shareLocationAction = { [weak self] in
                self?.shareLocation()
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BusStopTableViewCell.identifier,
            for: indexPath
        ) as! BusStopTableViewCell
        
        let stop = busStops[indexPath.row]
        let isLast = indexPath.row == busStops.count - 1
        
        cell.configure(with: stop, isLast: isLast)
        
        return cell
    }
}

extension BusDetailsVC: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        
        UITableView.automaticDimension
    }
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        section == 1 ? "Route Progress" : nil
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        guard indexPath.section == 1 else { return }
        
        let stop = busStops[indexPath.row]
        var statusText = "Upcoming"
        if stop.isCompleted {
            statusText = "Completed"
        } else if stop.isCurrent {
            statusText = "Current Stop"
        }
        
        let alert = UIAlertController(
            title: stop.stop_name,
            message: """
            Arrival: \(stop.stop_time)
            Status: \(statusText)
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
