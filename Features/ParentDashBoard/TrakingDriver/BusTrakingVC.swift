//
//  BusTrakingVC.swift
//  BusTraking
//
//  Created by Chandhru on 12/02/26.
//
import UIKit
import MapLibre
import CoreLocation

class BusTrakingVC: UIViewController, MLNMapViewDelegate, RecentMoveDelegate {
    func recentMove(_ recent: Bool) {
        guard recent else { return }
        
        // enable auto follow again
        userHasZoomed = false
        isRecenterActive = true
        
        let busCoord = busAnnotation.coordinate
        
        let camera = MLNMapCamera(
            lookingAtCenter: busCoord,
            altitude: altitudeForZoomLevel(16),
            pitch: 45,
            heading: mapView.camera.heading
        )
        
        mapView.setCamera(camera, withDuration: 1.0, animationTimingFunction: CAMediaTimingFunction(name: .easeInEaseOut))
    }
    
    @IBOutlet weak var mapView: MLNMapView!
    var stops: [BusStop] = [
        BusStop(id: "1", name: "Stop 1", time: "09:00",
                latitude: 13.0418, longitude: 80.2341,
                isCompleted: false, isCurrent: true),
        
        BusStop(id: "2", name: "Stop 2", time: "09:05",
                latitude: 13.0350, longitude: 80.2360,
                isCompleted: false, isCurrent: false),
        
        BusStop(id: "3", name: "Stop 3", time: "09:10",
                latitude: 13.0280, longitude: 80.2300,
                isCompleted: false, isCurrent: false),
        
        BusStop(id: "4", name: "Stop 4", time: "09:15",
                latitude: 13.0109, longitude: 80.2120,
                isCompleted: false, isCurrent: false),
        
        BusStop(id: "5", name: "Stop 5", time: "09:20",
                latitude: 12.9941, longitude: 80.1709,
                isCompleted: false, isCurrent: false)
    ]
    
    var stopCoordinates: [CLLocationCoordinate2D] {
        stops.compactMap {
            guard let lat = $0.latitude, let lon = $0.longitude else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
    
    var roadCoords: [CLLocationCoordinate2D] = []
    var completedCoords: [CLLocationCoordinate2D] = []
    var busAnnotation = MLNPointAnnotation()
    var userAnnotation = MLNPointAnnotation()
    var detailsVC: BusDetailsVC?
    
    // Route rendering properties
    var completedSource: MLNShapeSource?
    var remainingSource: MLNShapeSource?
    var completedLayer: MLNLineStyleLayer?
    var remainingLayer: MLNLineStyleLayer?
    var routeLayersSetup = false
    var shouldStartBusAfterStyleLoad = false
    
    var busIndex = 0
    var timer: Timer?
    var busSpeed: CFTimeInterval = 0.8
    var currentZoomLevel: Double = 16
    var userHasZoomed = false
    var isRecenterActive = true
    var isUserGesture = false
    var currentStopIndex = 0
    let stopReachThreshold: Double = 0.05
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        addStopPins()
        showUserPin()
        fetchRoadRoute()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.presentBottomSheet()
        }
    }
    @IBAction func back(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true)    }
    
    
    func setupMap() {
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.styleURL = URL(
            string: "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json"
        )
        
        mapView.delegate = self
        mapView.gestureRecognizers?.forEach { recognizer in
            recognizer.addTarget(self, action: #selector(handleMapGesture))
        }
    }
    
    // MARK: — Map Delegate
    
    func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
        
        guard let firstStop = stops.first,
              let lat = firstStop.latitude,
              let lon = firstStop.longitude else { return }
        
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        mapView.setCenter(coord, zoomLevel: 15, animated: false)
    }
    
    func addBlueDotAnimation(to view: UIView) {
        let dotSize: CGFloat = 14
        
        let dot = UIView(frame: CGRect(
            x: (view.bounds.width - dotSize) / 2,
            y: (view.bounds.height - dotSize) / 2,
            width: dotSize,
            height: dotSize
        ))
        
        dot.backgroundColor = .systemBlue
        dot.layer.cornerRadius = dotSize / 2
        dot.layer.borderWidth = 2
        dot.layer.borderColor = UIColor.white.cgColor
        dot.layer.shadowColor = UIColor.systemBlue.cgColor
        dot.layer.shadowOpacity = 0.6
        dot.layer.shadowRadius = 4
        dot.layer.shadowOffset = .zero
        
        view.addSubview(dot)
        let pulseLayer = CALayer()
        pulseLayer.frame = dot.frame
        pulseLayer.cornerRadius = dotSize / 2
        pulseLayer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.35).cgColor
        
        view.layer.insertSublayer(pulseLayer, below: dot.layer)
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1
        scale.toValue = 3
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.6
        fade.toValue = 0
        
        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = 1.5
        group.repeatCount = .infinity
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        pulseLayer.add(group, forKey: "pulse")
    }
    
    func setupRouteLayers() {
        guard let style = mapView.style else {
            print("❌ Style not ready yet")
            return
        }
        
        guard !routeLayersSetup else {
            print("⚠️ Route layers already setup")
            return
        }
        
        if style.source(withIdentifier: "completed-route") != nil {
            print("⚠️ Completed route source already exists")
            return
        }
        
        completedSource = MLNShapeSource(identifier: "completed-route", shape: nil, options: nil)
        style.addSource(completedSource!)
        
        completedLayer = MLNLineStyleLayer(identifier: "completed-layer", source: completedSource!)
        completedLayer?.lineColor = NSExpression(forConstantValue: UIColor.systemGray)
        completedLayer?.lineWidth = NSExpression(forConstantValue: 6)
        completedLayer?.lineJoin = NSExpression(forConstantValue: "round")
        completedLayer?.lineCap = NSExpression(forConstantValue: "round")
        
        remainingSource = MLNShapeSource(identifier: "remaining-route", shape: nil, options: nil)
        style.addSource(remainingSource!)
        
        remainingLayer = MLNLineStyleLayer(identifier: "remaining-layer", source: remainingSource!)
        remainingLayer?.lineColor = NSExpression(forConstantValue: UIColor.systemGreen)
        remainingLayer?.lineWidth = NSExpression(forConstantValue: 6)
        remainingLayer?.lineJoin = NSExpression(forConstantValue: "round")
        remainingLayer?.lineCap = NSExpression(forConstantValue: "round")
        
        var insertBeforeLayer: MLNStyleLayer?
        if let layers = style.layers as? [MLNStyleLayer] {
            for (index, layer) in layers.enumerated() {
                if layer.identifier.contains("com.mapbox.annotations") ||
                    layer.identifier.contains("annotations") {
                    insertBeforeLayer = layer
                    break
                }
            }
        }
        
        if let annotationLayer = insertBeforeLayer {
            style.insertLayer(completedLayer!, below: annotationLayer)
            style.insertLayer(remainingLayer!, below: annotationLayer)
        } else {
            style.addLayer(completedLayer!)
            style.addLayer(remainingLayer!)
        }
        
        routeLayersSetup = true
    }
    
    func setupAndStartRoute() {
        setupRouteLayers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateRemainingRoute()
            self.startBus()
        }
    }
    
    func presentBottomSheet() {
        let vc = BusDetailsVC()
        detailsVC = vc
        vc.delegate = self
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom(identifier: .init("small")) { _ in 200 },
                    .medium(),
                    .large()
                ]
            } else {
                // Fallback on earlier versions
            }
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .large
        }
        
        vc.isModalInPresentation = true
        vc.presentationController?.delegate = self
        present(vc, animated: true)
    }
    
    // MARK: — Stop Pins
    
    //    func addStopPins() {
    //        for (i, coord) in stopCoordinates.enumerated() {
    //            let pin = MLNPointAnnotation()
    //            pin.coordinate = coord
    //            pin.title = stops[i].name
    //            mapView.addAnnotation(pin)
    //        }
    //        print("📍 Added \(stopCoordinates.count) stop pins")
    //    }
    
    // MARK: — Demo User
    
    func showUserPin() {
        userAnnotation.coordinate = CLLocationCoordinate2D(latitude: 13.0300, longitude: 80.2250)
        mapView.addAnnotation(userAnnotation)
    }
    
    // MARK: — Fetch Road Route
    
    func fetchRoadRoute() {
        guard !stops.isEmpty else { return }
        
        let path = stops.compactMap { stop -> String? in
            if let lon = stop.longitude, let lat = stop.latitude {
                return "\(lon),\(lat)"
            }
            return nil
        }.joined(separator: ";")
        
        guard !path.isEmpty else { return }
        
        let urlString = "https://router.project-osrm.org/route/v1/driving/\(path)?overview=full&geometries=geojson"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Route fetch error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                guard
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let routes = json["routes"] as? [[String: Any]],
                    let firstRoute = routes.first,
                    let geometry = firstRoute["geometry"] as? [String: Any],
                    let coords = geometry["coordinates"] as? [[Double]]
                else {
                    return
                }
                
                self.roadCoords = coords.map {
                    CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])
                }
                DispatchQueue.main.async {
                    self.shouldStartBusAfterStyleLoad = true
                    
                    if self.mapView.style != nil {
                        self.setupAndStartRoute()
                    } else {
                        print("⏳ Waiting for style to load...")
                    }
                }
                
            } catch {
                print("❌ JSON parse error: \(error)")
            }
            
        }.resume()
    }
    
    // MARK: — Route Drawing
    
    func updateRemainingRoute() {
        
        guard let remainingSource = remainingSource else { return }
        
        let remainingCount = roadCoords.count - busIndex
        if remainingCount <= 1 {
            remainingSource.shape = nil
            return
        }
        var coords = Array(roadCoords.suffix(from: busIndex))
        
        let polyline = MLNPolyline(
            coordinates: &coords,
            count: UInt(coords.count))
        
        remainingSource.shape = polyline
    }
    
    
    func startBus() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            self.moveBus()
        }
    }
    
    @objc func handleMapGesture(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            userHasZoomed = true
            isRecenterActive = false
        }
    }
    
    
    func moveBus() {
        guard busIndex < roadCoords.count else {
            timer?.invalidate()
            showTripCompletePopup()
            return
        }
        
        let next = roadCoords[busIndex]
        
        if busIndex == 0 {
            busAnnotation.coordinate = next
            mapView.addAnnotation(busAnnotation)
            completedCoords.append(next)
            
            if currentStopIndex < stops.count {
                updateLiveMetrics(current: next)
            }
            
            busIndex += 1
            return
        }
        
        let previous = roadCoords[busIndex - 1]
        let heading = bearing(from: previous, to: next)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(busSpeed)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .linear))
        
        busAnnotation.coordinate = next
        completedCoords.append(next)
        if completedCoords.count >= 2 {
            var coords = completedCoords
            let polyline = MLNPolyline(coordinates: &coords, count: UInt(coords.count))
            completedSource?.shape = polyline
        }
        if busIndex < roadCoords.count - 1 {
            updateRemainingRoute()
        }
        
        if !userHasZoomed && isRecenterActive {
            let camera = MLNMapCamera(
                lookingAtCenter: next,
                altitude: mapView.camera.altitude,
                pitch: mapView.camera.pitch,
                heading: heading
            )
            mapView.setCamera(camera, animated: false)
        }
        
        CATransaction.commit()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isUserGesture = false
        }
        
        if currentStopIndex < stops.count {
            updateLiveMetrics(current: next)
        }
        
        busIndex += 1
    }
    
    func bearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDirection {
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var angle = atan2(y, x) * 180 / .pi
        if angle < 0 { angle += 360 }
        
        return angle
    }
    
    func altitudeForZoomLevel(_ zoom: Double) -> CLLocationDistance {
        let metersPerPixel = 156543.03392
        * cos(mapView.centerCoordinate.latitude * .pi / 180)
        / pow(2, zoom)
        
        return metersPerPixel * Double(mapView.bounds.height)
    }
    
    func showTripCompletePopup() {
        let popupView = createTripCompleteView()
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.alpha = 0
        blurView.tag = 999
        
        view.addSubview(blurView)
        view.addSubview(popupView)
        
        UIView.animate(withDuration: 0.3) {
            blurView.alpha = 0.7
            popupView.transform = .identity
        }
    }
    
    func createTripCompleteView() -> UIView {
        let width: CGFloat = 300
        let height: CGFloat = 400
        
        let container = UIView(frame: CGRect(
            x: (view.bounds.width - width) / 2,
            y: (view.bounds.height - height) / 2,
            width: width,
            height: height
        ))
        
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 20
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.3
        container.layer.shadowOffset = CGSize(width: 0, height: 10)
        container.layer.shadowRadius = 20
        container.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        let iconSize: CGFloat = 80
        let iconView = UIView(frame: CGRect(
            x: (width - iconSize) / 2,
            y: 40,
            width: iconSize,
            height: iconSize
        ))
        iconView.backgroundColor = UIColor.systemGreen
        iconView.layer.cornerRadius = iconSize / 2
        
        let checkmark = UILabel(frame: iconView.bounds)
        checkmark.text = "✓"
        checkmark.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        checkmark.textColor = .white
        checkmark.textAlignment = .center
        iconView.addSubview(checkmark)
        
        container.addSubview(iconView)
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 140, width: width - 40, height: 40))
        titleLabel.text = "Trip Completed!"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        container.addSubview(titleLabel)
        
        let messageLabel = UILabel(frame: CGRect(x: 20, y: 190, width: width - 40, height: 60))
        messageLabel.text = "Successfully completed \(stops.count) stops\nThank you for traveling with us!"
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 2
        container.addSubview(messageLabel)
        
        let statsLabel = UILabel(frame: CGRect(x: 20, y: 260, width: width - 40, height: 30))
        let distance = String(format: "%.1f", Double(roadCoords.count) * 0.01)
        statsLabel.text = "📍 Distance: ~\(distance) km"
        statsLabel.font = UIFont.systemFont(ofSize: 14)
        statsLabel.textAlignment = .center
        statsLabel.textColor = .secondaryLabel
        container.addSubview(statsLabel)
        
        let doneButton = UIButton(frame: CGRect(x: 30, y: 310, width: width - 60, height: 50))
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .systemBlue
        doneButton.layer.cornerRadius = 12
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        doneButton.addTarget(self, action: #selector(dismissTripComplete), for: .touchUpInside)
        container.addSubview(doneButton)
        
        return container
    }
    
    @objc func dismissTripComplete() {
        for subview in view.subviews {
            if subview.tag == 999 || subview.backgroundColor == .systemBackground {
                UIView.animate(withDuration: 0.3, animations: {
                    subview.alpha = 0
                    subview.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }) { _ in
                    subview.removeFromSuperview()
                }
            }
        }
    }
}

extension BusTrakingVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        guard let sheet = presentationController.presentedViewController.sheetPresentationController else { return }
        sheet.animateChanges {
            sheet.selectedDetentIdentifier = .init("small")
        }
    }
    
    func distanceBetween(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
        let loc1 = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let loc2 = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return loc1.distance(from: loc2) / 1000
    }
    
    func updateLiveMetrics(current: CLLocationCoordinate2D) {
        guard currentStopIndex < stops.count else { return }
        
        let targetStop = stops[currentStopIndex]
        let distanceToStop = distanceBetween(current, targetStop.coordinate)
        
        if distanceToStop < stopReachThreshold {
            stops[currentStopIndex].isCompleted = true
            stops[currentStopIndex].isCurrent = false
            
            currentStopIndex += 1
            
            if currentStopIndex < stops.count {
                stops[currentStopIndex].isCurrent = true
            } else {
                return
            }
        }
        
        let remainingDistance: Double
        if currentStopIndex < stopCoordinates.count {
            remainingDistance = distanceBetween(current, stopCoordinates[currentStopIndex])
        } else {
            remainingDistance = 0
        }
        
        let speed = Double.random(in: 30...45)
        let eta = remainingDistance > 0 ? Int((remainingDistance / speed) * 60) : 0
        
        let liveData = BusLiveData(
            speed: speed,
            etaMinutes: eta,
            distanceKm: remainingDistance,
            nextStop: currentStopIndex < stops.count ? stops[currentStopIndex].name : "-",
            currentStopIndex: currentStopIndex
        )
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.detailsVC?.updateStops(self.stops)
            self.detailsVC?.updateLiveData(liveData)
        }
    }
    
    func mapView(_ mapView: MLNMapView, annotationCanShowCallout annotation: MLNAnnotation) -> Bool {
        if annotation === busAnnotation {
            return false
        }
        return true
    }
    
    func addStopPins() {
        for (i, coord) in stopCoordinates.enumerated() {
            let pin = MLNPointAnnotation()
            pin.coordinate = coord
            pin.title = stops[i].name
            mapView.addAnnotation(pin)
        }
    }
    
    func mapView(_ mapView: MLNMapView,
                 viewFor annotation: MLNAnnotation) -> MLNAnnotationView? {
        if annotation === busAnnotation {
            return nil
        }
        if annotation === userAnnotation {
            let id = "UserBlueDot"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            
            if view == nil {
                view = MLNAnnotationView(reuseIdentifier: id)
                view!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                
                addBlueDotAnimation(to: view!)
            }
            
            return view
        }
        guard let title = annotation.title, let stopName = title else {
            return nil
        }
        
        let reuseIdentifier = "stopPinView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            
            annotationView = MLNAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView?.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
            
            let containerView = UIView(frame: annotationView!.bounds)
            containerView.tag = 1000
            annotationView?.addSubview(containerView)
            
            let labelBackground = UIView()
            labelBackground.backgroundColor = .white
            labelBackground.layer.cornerRadius = 8
            labelBackground.layer.shadowColor = UIColor.black.cgColor
            labelBackground.layer.shadowOpacity = 0.25
            labelBackground.layer.shadowOffset = CGSize(width: 0, height: 2)
            labelBackground.layer.shadowRadius = 4
            labelBackground.tag = 1001
            containerView.addSubview(labelBackground)
            
            let nameLabel = UILabel()
            nameLabel.font = .systemFont(ofSize: 11, weight: .semibold)
            nameLabel.textAlignment = .center
            nameLabel.textColor = .black
            nameLabel.tag = 1002
            labelBackground.addSubview(nameLabel)
            
            let pinDot = UIView()
            pinDot.backgroundColor = .systemRed
            pinDot.layer.cornerRadius = 6
            pinDot.layer.borderWidth = 2
            pinDot.layer.borderColor = UIColor.white.cgColor
            pinDot.tag = 1003
            containerView.addSubview(pinDot)
            
            let pinStem = UIView()
            pinStem.backgroundColor = .systemRed
            pinStem.tag = 1004
            containerView.addSubview(pinStem)
        }
        
        if let container = annotationView?.viewWithTag(1000),
           let labelBg = container.viewWithTag(1001),
           let nameLabel = labelBg.viewWithTag(1002) as? UILabel,
           let pinDot = container.viewWithTag(1003),
           let pinStem = container.viewWithTag(1004) {
            
            nameLabel.text = stopName
            
            let labelSize = (stopName as NSString).size(
                withAttributes: [.font: UIFont.systemFont(ofSize: 11, weight: .semibold)]
            )
            
            let labelWidth = min(labelSize.width + 16, 100)
            let labelHeight: CGFloat = 24
            
            labelBg.frame = CGRect(
                x: (100 - labelWidth) / 2,
                y: 0,
                width: labelWidth,
                height: labelHeight
            )
            
            nameLabel.frame = labelBg.bounds
            
            pinStem.frame = CGRect(x: 48, y: labelHeight, width: 2, height: 8)
            pinDot.frame = CGRect(x: 44, y: labelHeight + 8, width: 12, height: 12)
            
            container.frame = CGRect(x: 0, y: 0, width: 100, height: labelHeight + 20)
            annotationView?.frame = container.frame
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MLNMapView, imageFor annotation: MLNAnnotation) -> MLNAnnotationImage? {
        if annotation === busAnnotation {
            if let img = UIImage(named: "bus") {
                let size = CGSize(width: 30, height: 30)
                UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
                img.draw(in: CGRect(origin: .zero, size: size))
                if let resized = UIGraphicsGetImageFromCurrentImageContext() {
                    UIGraphicsEndImageContext()
                    return MLNAnnotationImage(image: resized, reuseIdentifier: "bus")
                }
                UIGraphicsEndImageContext()
            }
        }
        return nil
    }
    
}

extension BusStop {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: latitude ?? 0,
            longitude: longitude ?? 0
        )
    }
}
struct BusStop: Codable {

    let id: String
    let name: String
    let time: String
    let latitude: Double?
    let longitude: Double?
    var isCompleted: Bool
    var isCurrent: Bool
    var status: StopStatus {

        if isCompleted {
            return .completed
        } else if isCurrent {
            return .current
        } else {
            return .upcoming
        }
    }
}

// MARK: - Stop Status

enum StopStatus {

    case completed
    case current
    case upcoming

    var displayName: String {

        switch self {
        case .completed: return "Completed"
        case .current: return "Current"
        case .upcoming: return "Upcoming"
        }
    }
}

// MARK: - Bus Model

struct Bus: Codable {

    let id: String
    let busNumber: String
    let route: String
    let currentSpeed: Double
    let currentLatitude: Double
    let currentLongitude: Double
    let driverName: String
    let driverPhone: String
    let stops: [BusStop]

    var formattedSpeed: String {
        "\(Int(currentSpeed)) km/h"
    }
}
