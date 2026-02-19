import UIKit
import GoogleMaps

class busTracker: UIViewController {

    private var mapView: GMSMapView!
    private var busMarker = GMSMarker()
    
    private var timer: Timer?
    private var currentIndex = 0
    
    // 4 Stops (Simulated Google Sheet Data)
    private let busStops: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 13.0418, longitude: 80.2341),
        CLLocationCoordinate2D(latitude: 13.0210, longitude: 80.2215),
        CLLocationCoordinate2D(latitude: 13.0106, longitude: 80.2209),
        CLLocationCoordinate2D(latitude: 12.9791, longitude: 80.2213)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGoogleMap()
        addStopMarkers()
        startBusAnimation()
    }
}

// MARK: - Setup Map
extension busTracker {
    
    private func setupGoogleMap() {
        
        let camera = GMSCameraPosition.camera(
            withLatitude: busStops.first!.latitude,
            longitude: busStops.first!.longitude,
            zoom: 13
        )
        
        mapView = GMSMapView(frame: view.bounds, camera: camera)
        view.addSubview(mapView)
        
        // Enable Traffic Layer
        mapView.isTrafficEnabled = true
    }
}

// MARK: - Add Stops
extension busTracker {
    
    private func addStopMarkers() {
        
        for (index, stop) in busStops.enumerated() {
            let marker = GMSMarker(position: stop)
            marker.title = "Stop \(index + 1)"
            marker.icon = GMSMarker.markerImage(with: .red)
            marker.map = mapView
        }
        
        // Add Bus Marker
        busMarker.position = busStops.first!
        busMarker.title = "School Bus"
        busMarker.icon = UIImage(systemName: "bus.fill")
        busMarker.map = mapView
    }
}

// MARK: - Animation
extension busTracker {
    
    private func startBusAnimation() {
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.moveBus()
        }
    }
    
    private func moveBus() {
        
        guard currentIndex < busStops.count - 1 else {
            timer?.invalidate()
            return
        }
        
        currentIndex += 1
        let nextStop = busStops[currentIndex]
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.5)
        
        busMarker.position = nextStop
        mapView.animate(toLocation: nextStop)
        
        CATransaction.commit()
    }
}
