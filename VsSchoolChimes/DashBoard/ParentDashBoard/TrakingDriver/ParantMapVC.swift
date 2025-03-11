//
//  ParantMapVC.swift
//  VsSchoolChimes
//
//  Created by admin on 27/02/25.
//

import UIKit
import MapKit
import CoreLocation
//import FirebaseDatabase

class ParantMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var zoomOutBtn: UIButton!
    @IBOutlet weak var zoomInBtn: UIButton!
    @IBOutlet weak var mapTypeBtn: UIButton!
    
    let locationManager = CLLocationManager()
    var startLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707) // Default start location
    var driverLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 13.0600, longitude: 80.2500) // Default driver location
    var parentLocations: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 13.0500, longitude: 80.2824), // Parent 1
        CLLocationCoordinate2D(latitude: 13.0400, longitude: 80.2600), // Parent 2
        CLLocationCoordinate2D(latitude: 13.0300, longitude: 80.2700)  // Parent 3
    ]
    var schoolLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 13.0098, longitude: 80.2318) // Default school location
    
//    let databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMapView()
        setupLocationManager()
        observeDriverLocation()
        observeParentLocations()
        updateAnnotations()
    }
    
    @IBAction func startTrip(_ sender: UIButton) {
    }
    private func setupUI() {
        backBtn.applyBackButton()
        [zoomOutBtn, zoomInBtn, mapTypeBtn].forEach { $0?.buttonCornerRadius() }
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.showsUserLocation = true
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func observeDriverLocation() {
//        databaseRef.child("driverLocation").observe(.value) { [weak self] snapshot in
//            guard let self = self, let value = snapshot.value as? [String: Double],
//                  let latitude = value["latitude"], let longitude = value["longitude"] else { return }
//            
//            let newLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//            self.updateDriverLocation(newLocation)
//        }
    }
    
    private func observeParentLocations() {
//        databaseRef.child("parentLocations").observe(.value) { [weak self] snapshot in
//            guard let self = self, let values = snapshot.value as? [[String: Double]] else { return }
//            
//            var newParentLocations: [CLLocationCoordinate2D] = []
//            
//            for value in values {
//                if let latitude = value["latitude"], let longitude = value["longitude"] {
//                    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                    newParentLocations.append(location)
//                }
//            }
//            
//            if !newParentLocations.isEmpty {
//                self.parentLocations = newParentLocations
//                DispatchQueue.main.async {
//                    self.updateAnnotations()
//                }
//            }
//        }
    }
    
    private func updateDriverLocation(_ newLocation: CLLocationCoordinate2D) {
        driverLocation = newLocation
        DispatchQueue.main.async {
            self.updateAnnotations()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        // Only update startLocation if it hasn't been set yet
        if startLocation == nil {
            startLocation = latestLocation.coordinate
            updateAnnotations()
        }
    }
    
    private func updateAnnotations() {
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        mapView.removeOverlays(mapView.overlays)
        
        if let startLoc = startLocation {
            addAnnotation(at: startLoc, title: "Start Location", color: .green)
        }
        
        if let driverLoc = driverLocation {
            addAnnotation(at: driverLoc, title: "Driver", color: .blue)
        }
        
        // Add all parent locations
        for (index, parentLocation) in parentLocations.enumerated() {
            addAnnotation(at: parentLocation, title: "Parent \(index + 1)", color: .red)
        }
        
        addAnnotation(at: schoolLocation, title: "School", color: .purple)
        
        // Draw the complete route path
        drawCompletePath()
    }
    
    private func addAnnotation(at coordinate: CLLocationCoordinate2D, title: String, color: UIColor = .red) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let identifier = "CustomAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        // Customize pin color based on title
        if let markerView = annotationView as? MKMarkerAnnotationView {
            if (((annotation.title ?? "")?.contains("Parent")) != nil) {
                markerView.markerTintColor = .red
            } else if (annotation.title ?? "") == "Start Location" {
                markerView.markerTintColor = .green
            } else if (annotation.title ?? "") == "Driver" {
                markerView.markerTintColor = .blue
            } else if (annotation.title ?? "") == "School" {
                markerView.markerTintColor = .purple
            } else {
                markerView.markerTintColor = .orange
            }
        }
        
        return annotationView
    }
    
    func drawCompletePath() {
        guard let startLoc = startLocation,
              let driverLoc = driverLocation,
              !parentLocations.isEmpty else { return }
        
        // First segment: Start to Driver
        createDirectionsRequest(from: startLoc, to: driverLoc, routeTitle: "startToDriver")
        
        // Middle segments: Driver to each Parent, then Parent to Parent
        var lastLocation = driverLoc
        
        for (index, parentLocation) in parentLocations.enumerated() {
            let routeTitle = (index == 0) ? "driverToParent1" : "parent\(index)ToParent\(index+1)"
            createDirectionsRequest(from: lastLocation, to: parentLocation, routeTitle: routeTitle)
            lastLocation = parentLocation
        }
        
        // Final segment: Last Parent to School
        createDirectionsRequest(from: lastLocation, to: schoolLocation, routeTitle: "lastParentToSchool")
    }
    
    private func createDirectionsRequest(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, routeTitle: String) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        MKDirections(request: request).calculate { [weak self] response, error in
            guard let self = self, let route = response?.routes.first else { return }
            DispatchQueue.main.async {
                let overlay = route.polyline
                overlay.title = routeTitle
                self.mapView.addOverlay(overlay, level: .aboveRoads)
                
                // Fit map to show all annotations
                self.fitMapToShowAllAnnotations()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            
            if polyline.title == "startToDriver" {
                renderer.strokeColor = .lightGray
            } else if polyline.title == "lastParentToSchool" {
                renderer.strokeColor = .blue
            } else if polyline.title?.contains("driverToParent") ?? false {
                renderer.strokeColor = .blue
            } else if polyline.title?.contains("parentToParent") ?? false || polyline.title?.contains("parent") ?? false {
                renderer.strokeColor = .blue
            } else {
                renderer.strokeColor = .blue
            }
            
            renderer.lineWidth = 6
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    private func fitMapToShowAllAnnotations() {
        guard mapView.annotations.count > 0 else { return }
        
        var zoomRect = MKMapRect.null
        for annotation in mapView.annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1)
            zoomRect = zoomRect.isNull ? pointRect : zoomRect.union(pointRect)
        }
        
        // Add some padding
        let insets = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)
        mapView.setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
    
    @IBAction func zoomOut(_ sender: UIButton) {
        adjustMapZoom(scale: 2.0)
    }
    
    @IBAction func zoomIn(_ sender: UIButton) {
        adjustMapZoom(scale: 0.5)
    }
    
    private func adjustMapZoom(scale: Double) {
        var region = mapView.region
        let newLatitudeDelta = max(min(region.span.latitudeDelta * scale, 90.0), 0.001)
        let newLongitudeDelta = max(min(region.span.longitudeDelta * scale, 180.0), 0.001)
        region.span.latitudeDelta = newLatitudeDelta
        region.span.longitudeDelta = newLongitudeDelta
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func changeMap(_ sender: UIButton) {
        mapView.mapType = mapView.mapType == .standard ? .satellite : .standard
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension UIButton {
    func buttonCornerRadius(cornerRadius: CGFloat = 20, shadowColor: UIColor = .black, shadowOpacity: Float = 0.3, shadowOffset: CGSize = CGSize(width: 0, height: 2), shadowRadius: CGFloat = 5) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
    }
}
