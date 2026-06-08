//
//  BusTrakingVC.swift
//  BusTraking
//  Created by Chandhru on 12/02/26.
//

import UIKit
import MapLibre
import CoreLocation

class BusTrakingVC: UIViewController, MLNMapViewDelegate, RecentMoveDelegate {
    
    func recentMove(_ recent: Bool) {
        guard recent else { return }
        
        userHasZoomed = false
        isRecenterActive = true
        
        getLatestGeoLocation()
    }
    
    @IBOutlet weak var mapView: MLNMapView!
    
    var stops: [Stops] = []
    var stopCoordinates: [CLLocationCoordinate2D] {
        stops.compactMap {
            guard let lat = Double($0.latitude ?? ""), let lon = Double($0.longitude ?? "") else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
    
    var roadCoords: [CLLocationCoordinate2D] = []
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
    var userHasZoomed = false
    var isRecenterActive = true
    var currentStopIndex = 0
    var stopRouteIndices: [Int] = []
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var latestGeoLocation: GeoLocationData?
    var deviceId: String?
    var vehicleId: String?
    var routeId: String?
    var destinationLatitude: String = ""
    var destinationLongitude: String = ""
    var isFetchingLocation = false
    var hasShownApiError = false
    var hasReachedDestination = false
    var maxBusIndexReached = 0
    var isBusOnRoute = false
    private var hasShownBottomSheet = false
    var lastLiveData: BusLiveData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("stopsssss",stops)
        if !stops.isEmpty {
            stops[0].isCurrent = true
        }
        
        setupMap()
        addStopPins()
        showUserPin()
        fetchRoadRoute()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    
    func getLatestGeoLocation() {

        guard !isFetchingLocation else { return }
        
        isFetchingLocation = true
        let secureID = SecureIDManager.getSecureID()
        let parameter: [String: Any] = [
            "device_id": "ea973ebc50a1f536",//secureID,
            "vehicle_id": vehicleId ?? "",
            "route_id": routeId ?? ""
        ]

        APIService.shared.makeApi(
            url: ServiceUrl.get_latest_geo_location,
            parameters: parameter,
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? "",
            isBaseUrl: true
        ) { [weak self] (result: Result<GeoLocationResponse, Error>) in

            guard let self = self else { return }

            DispatchQueue.main.async {

                self.isFetchingLocation = false

                switch result {

                case .success(let response):

                    if response.status == true {

                        guard let latest = response.data?.first else {
                            self.sendUnavailableData()
                            return
                        }

                        self.latestGeoLocation = latest

                        guard
                            let latString = latest.latitude,
                            let lonString = latest.longitude,
                            let latitude = Double(latString),
                            let longitude = Double(lonString)
                        else {
                            self.sendUnavailableData()
                            return
                        }

                        let currentCoord = CLLocationCoordinate2D(
                            latitude: latitude,
                            longitude: longitude
                        )


                        guard
                            let destLat = Double(self.destinationLatitude),
                            let destLon = Double(self.destinationLongitude)
                        else {
                            self.updateBusLocation(currentCoord, etaMinutes: 0, distanceKm: 0)
                            return
                        }

                        let destinationCoord = CLLocationCoordinate2D(
                            latitude: destLat,
                            longitude: destLon
                        )

                        let distanceKm = self.distanceBetween(currentCoord, destinationCoord)
                        let speed = 40.0
                        let etaMinutes = distanceKm > 0 ? Int((distanceKm / speed) * 60) : 0

                        self.updateBusLocation(
                            currentCoord,
                            etaMinutes: etaMinutes,
                            distanceKm: distanceKm
                        )

                    } else {

                        // ✅ API status false — show alert, dismiss page
                        guard !self.hasShownApiError else { return }
                        self.hasShownApiError = true
                        self.timer?.invalidate()
                        self.timer = nil

                        let alert = UIAlertController(
                            title: "Unable to Track Bus",
                            message: response.message ?? "Unable to fetch bus location.",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            self.detailsVC?.dismiss(animated: false)
                            self.dismiss(animated: true)
                        })
                        self.present(alert, animated: true)
                    }

                case .failure(let error):

                    // ✅ API failure — show alert, dismiss page
                    print("❌ Location API Error:", error.localizedDescription)

                    guard !self.hasShownApiError else { return }
                    self.hasShownApiError = true
                    self.timer?.invalidate()
                    self.timer = nil

                    let alert = UIAlertController(
                        title: "Unable to Track Bus",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.detailsVC?.dismiss(animated: false)
                        self.dismiss(animated: true)
                    })
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func sendUnavailableData() {
        let liveData = BusLiveData(
            speed: 0,
            etaMinutes: 0,
            distanceKm: 0,
            nextStop: "Location Unavailable",
            currentStopIndex: currentStopIndex
        )
        if let detailsVC = detailsVC, detailsVC.isViewLoaded {
            detailsVC.updateStops(stops)
            detailsVC.updateLiveData(liveData)
        }
    }
    
    func presentBottomSheetIfNeeded() {
        guard !hasShownBottomSheet else { return }
        guard !hasReachedDestination else { return }
        guard currentStopIndex < stops.count else { return }
        
        hasShownBottomSheet = true
        presentBottomSheet()
    }
    
    func calculateStopRouteIndices() {
        stopRouteIndices.removeAll()
        
        for stop in stops {
            var nearestIndex = 0
            var shortestDistance = Double.greatestFiniteMagnitude
            
            let stopLocation = CLLocation(
                latitude: stop.coordinate.latitude,
                longitude: stop.coordinate.longitude
            )
            
            for (index, coord) in roadCoords.enumerated() {
                let routePoint = CLLocation(
                    latitude: coord.latitude,
                    longitude: coord.longitude
                )
                let distance = stopLocation.distance(from: routePoint)
                if distance < shortestDistance {
                    shortestDistance = distance
                    nearestIndex = index
                }
            }
            stopRouteIndices.append(nearestIndex)
        }
        
        print("📍 Stop route indices: \(stopRouteIndices)")
    }
    
    func updateLiveMetrics(current: CLLocationCoordinate2D, etaMinutes: Int, distanceKm: Double) {

        updateStopStatusFromRoute()

        // ✅ Update destination flag first
        if !hasReachedDestination && distanceKm > 0 && distanceKm < 0.20 {
            hasReachedDestination = true
        }

        guard currentStopIndex < stops.count && !hasReachedDestination else {

            if timer != nil {
                timer?.invalidate()
                timer = nil

                if hasShownBottomSheet,
                   let detailsVC = detailsVC,
                   detailsVC.presentingViewController != nil {
                    // ✅ Dismiss bottom sheet first, then show popup
                    detailsVC.dismiss(animated: true) { [weak self] in
                        self?.showTripCompletePopup()
                    }
                } else {
                    // ✅ No bottom sheet shown — show popup directly
                    showTripCompletePopup()
                }
            }
            return
        }

        // ✅ Only reaches here if trip is NOT complete
        // So bottom sheet will only show if trip is active
        presentBottomSheetIfNeeded()

        let speed = 40.0
        let nextStopName = stops[currentStopIndex].stop_name ?? ""

        let liveData = BusLiveData(
            speed: speed,
            etaMinutes: etaMinutes,
            distanceKm: distanceKm,
            nextStop: nextStopName,
            currentStopIndex: currentStopIndex
        )
        
        lastLiveData = liveData

        if let detailsVC = detailsVC, detailsVC.isViewLoaded {
            detailsVC.updateStops(stops)
            detailsVC.updateLiveData(liveData)
        }
    }
    
    func updateStopStatusFromRoute() {

        guard !stopRouteIndices.isEmpty else { return }

        // ✅ If bus is not on route, don't update stop status
        guard isBusOnRoute else {
            print("⚠️ Bus off route — stop status not updated")
            return
        }

        for i in 0..<stops.count {
            stops[i].isCurrent = false
        }

        var nextUncompletedIndex = stops.count

        for (index, stopRouteIndex) in stopRouteIndices.enumerated() {
            if busIndex >= stopRouteIndex {
                stops[index].isCompleted = true
            } else {
                nextUncompletedIndex = index
                break
            }
        }

        if nextUncompletedIndex < stops.count {
            stops[nextUncompletedIndex].isCurrent = true
            currentStopIndex = nextUncompletedIndex
        } else {
            currentStopIndex = stops.count
        }
    }
    
    func updateRouteProgress(_ current: CLLocationCoordinate2D) {

        guard !roadCoords.isEmpty else { return }

        var nearestIndex = 0
        var shortestDistance = Double.greatestFiniteMagnitude

        let currentLocation = CLLocation(
            latitude: current.latitude,
            longitude: current.longitude
        )

        for (index, coord) in roadCoords.enumerated() {
            let pointLocation = CLLocation(
                latitude: coord.latitude,
                longitude: coord.longitude
            )
            let distance = currentLocation.distance(from: pointLocation)
            if distance < shortestDistance {
                shortestDistance = distance
                nearestIndex = index
            }
        }

        let maxRouteDistance: CLLocationDistance = 500

        guard shortestDistance <= maxRouteDistance else {
            print("⚠️ Bus is \(Int(shortestDistance))m away from route — ignoring")
            isBusOnRoute = false   // ✅ mark as off route
            updateCompletedRoute()
            updateRemainingRoute()
            return
        }

        isBusOnRoute = true        // ✅ mark as on route

        maxBusIndexReached = max(maxBusIndexReached, nearestIndex)
        busIndex = maxBusIndexReached

        updateCompletedRoute()
        updateRemainingRoute()
    }
    
    func updateCompletedRoute() {
        
        guard let completedSource = completedSource else {
            return
        }
        
        guard busIndex > 1 else {
            
            completedSource.shape = nil
            return
        }
        
        var coords = Array(
            roadCoords.prefix(busIndex)
        )
        
        let polyline = MLNPolyline(
            coordinates: &coords,
            count: UInt(coords.count)
        )
        
        completedSource.shape = polyline
    }
    
    func updateBusLocation(_ currentCoord: CLLocationCoordinate2D, etaMinutes: Int, distanceKm: Double) {
        
        busAnnotation.coordinate = currentCoord
        
        if !(mapView.annotations?.contains {
            $0 === busAnnotation
        } ?? false) {
            mapView.addAnnotation(busAnnotation)
        }
        
        updateRouteProgress(currentCoord)
        updateLiveMetrics(current: currentCoord, etaMinutes: etaMinutes, distanceKm: distanceKm)
        
        if !userHasZoomed && isRecenterActive {
            let camera = MLNMapCamera(
                lookingAtCenter: currentCoord,
                altitude: altitudeForZoomLevel(13),
                pitch: 45,
                heading: mapView.camera.heading
            )
            mapView.setCamera(camera, animated: true)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        timer?.invalidate()
        timer = nil
        presentingViewController?.dismiss(animated: true)
    }
    
    
    func setupMap() {
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.styleURL = URL(
            string:
                "https://tiles.openfreemap.org/styles/bright"
        )
        
        mapView.delegate = self
        mapView.automaticallyAdjustsContentInset = false
        mapView.gestureRecognizers?.forEach { recognizer in
            recognizer.addTarget(self, action: #selector(handleMapGesture))
            
        }
    }
    
    
    // MARK: — Map Delegate
    
    func mapView(_ mapView: MLNMapView,
                 didFinishLoading style: MLNStyle) {
        
        guard let firstStop = stops.first,
              let lat = Double(firstStop.latitude ?? "0.0"),
              let lon = Double(firstStop.longitude ?? "0.0") else { return }
        
        mapView.setCenter(
            CLLocationCoordinate2D(latitude: lat, longitude: lon),
            zoomLevel: 13,
            animated: false
        )
        
        if shouldStartBusAfterStyleLoad {
            setupAndStartRoute()
        }
    }
    
    func addBlueDotAnimation(to view: UIView) {
        let dotSize: CGFloat = 14
        
        let dot = UIView(frame: CGRect(
            x: (view.bounds.width - dotSize) / 2,
            y: (view.bounds.height - dotSize) / 2,
            width: dotSize,
            height: dotSize
        ))
        
        dot.backgroundColor = .red
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
        vc.fromStop = stops.first?.stop_name ?? ""
        vc.toStop = stops.last?.stop_name ?? ""
        vc.delegate = self

        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom(identifier: .init("small")) { _ in 200 },
                    .medium(),
                    .large()
                ]
            }
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .large
        }

        vc.isModalInPresentation = true
        vc.presentationController?.delegate = self

        // ✅ Push data once sheet is fully presented
        present(vc, animated: true) { [weak self] in
            guard let self = self else { return }
            vc.updateStops(self.stops)
            if let liveData = self.lastLiveData {
                vc.updateLiveData(liveData)
            }
        }
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
        
//        let urlString = "https://router.project-osrm.org/route/v1/driving/\(path)?overview=full&geometries=geojson"
        
        let urlString = "  http://192.168.6.87:5000/route/v1/driving/\(path)?overview=false"
        
    
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
                    
                    self.calculateStopRouteIndices()
                    
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
        
        timer?.invalidate()
        
        getLatestGeoLocation()
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {[weak self] _ in
            self?.getLatestGeoLocation()
        }
    }
    
    @objc func handleMapGesture(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            userHasZoomed = true
            isRecenterActive = false
        }
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
            height: height - 50
        ))
        
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 20
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.3
        container.layer.shadowOffset = CGSize(width: 0, height: 10)
        container.layer.shadowRadius = 20
        container.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        container.tag = 1998
        
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
        
//        let statsLabel = UILabel(frame: CGRect(x: 20, y: 260, width: width - 40, height: 30))
//        let distance = String(format: "%.1f", Double(roadCoords.count) * 0.01)
//        statsLabel.text = "📍 Distance: ~\(distance) km"
//        statsLabel.font = UIFont.systemFont(ofSize: 14)
//        statsLabel.textAlignment = .center
//        statsLabel.textColor = .secondaryLabel
//        container.addSubview(statsLabel)
        
        let doneButton = UIButton(frame: CGRect(x: 30, y: 280, width: width - 60, height: 50))
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
        presentingViewController?.dismiss(animated: true)
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
            pin.title = stops[i].stop_name
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



extension Stops {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: Double(latitude ?? "") ?? 0,
            longitude:  Double(longitude ?? "" ) ?? 0
        )
    }
}
