//
//  ParantMapVC.swift
//  VsSchoolChimes
//
//  Created by admin on 27/02/25.
//

import UIKit
import MapKit
import CoreLocation

class ParantMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var driverLocation: CLLocationCoordinate2D?
    var driverPathCoordinates: [CLLocationCoordinate2D] = []
    
    let startLocation = CLLocationCoordinate2D(latitude: 13.049952, longitude: 80.282906) // Marina Beach
    let endLocation = CLLocationCoordinate2D(latitude: 13.00813, longitude: 80.21331) // Guindy Railway Station
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupLocationManager()
        setupDriverPath()
        updateAnnotations()
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.mapType = .satellite
        mapView.showsUserLocation = true
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupDriverPath() {
        driverPathCoordinates = [
            startLocation,
            CLLocationCoordinate2D(latitude: 13.0400, longitude: 80.2600),
            CLLocationCoordinate2D(latitude: 13.0300, longitude: 80.2400),
            CLLocationCoordinate2D(latitude: 13.0200, longitude: 80.2200),
            endLocation
        ]
    }
    
    func updateAnnotations() {
        mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })
        
        addAnnotation(at: startLocation, title: "Start: Marina Beach", imageName: "a")
        addAnnotation(at: endLocation, title: "End: Guindy", imageName: "p")
        
        if let driver = driverLocation {
            addAnnotation(at: driver, title: "Driver", imageName: "icon_filled_star")
        }
        
        drawPath()
    }
    
    private func addAnnotation(at coordinate: CLLocationCoordinate2D, title: String, imageName: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func drawPath() {
        guard driverPathCoordinates.count > 1 else { return }
        
        DispatchQueue.main.async {
            self.mapView.removeOverlays(self.mapView.overlays)
        }
        
        for i in 0..<(driverPathCoordinates.count - 1) {
            let source = driverPathCoordinates[i]
            let destination = driverPathCoordinates[i + 1]
            
            let directionRequest = MKDirections.Request()
            directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
            directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            directionRequest.transportType = .automobile
            
            MKDirections(request: directionRequest).calculate { [weak self] response, error in
                guard let self = self, let route = response?.routes.first else { return }
                DispatchQueue.main.async {
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 6
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let identifier = annotation.title ?? ""
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier ?? "")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        if let title = annotation.title, let imageName = getImageName(for: title ?? "") {
            annotationView?.image = resizeImage(image: UIImage(named: imageName)!, targetSize: CGSize(width: 40, height: 40))
        }
        
        annotationView?.canShowCallout = true
        return annotationView
    }
    
    private func getImageName(for title: String) -> String? {
        switch title {
        case "Start: Marina Beach": return "a"
        case "Driver": return "icon_filled_star"
        case "End: Guindy": return "p"
        default: return "location-marker"
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            showLocationPermissionAlert()
        }
    }
    
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(
            title: "Location Required",
            message: "Please enable location services in Settings.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func zoomOut(_ sender: UIButton) {
        adjustMapZoom(scale: 2.0)
    }
    
    @IBAction func zoomIn(_ sender: UIButton) {
        adjustMapZoom(scale: 0.5)
    }
    
    private func adjustMapZoom(scale: Double) {
        var region = mapView.region
        region.span.latitudeDelta *= scale
        region.span.longitudeDelta *= scale
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func changeMap(_ sender: UIButton) {
        mapView.mapType = mapView.mapType == .standard ? .satellite : .standard
    }
}
