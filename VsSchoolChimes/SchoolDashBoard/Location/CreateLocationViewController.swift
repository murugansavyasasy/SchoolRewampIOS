
//

import UIKit
import DropDown
import CoreLocation
import MapKit
class CreateLocationViewController: UIViewController, UITextFieldDelegate,CLLocationManagerDelegate,MKMapViewDelegate {
    @IBOutlet weak var addressOuterView: UIView!
    @IBOutlet weak var informationOuterView: UIView!
    @IBOutlet weak var locationNameTxt: UITextField!
    @IBOutlet weak var distanceTxt: UITextField!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var distanceOuterView: UIView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var distanceDropDownView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var adressLbl: UILabel!
    @IBOutlet weak var getLocationBtn: UIButton!
    @IBOutlet weak var latlongLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var instractionLbl: UILabel!
    
    let locationManager = CLLocationManager()
    var latitude = ""
    var longitude = ""
    var InstitudeId: Int!
    var refrenceAddress = ""
    var userId: Int!
    var hasCenteredMap = false
    var isManualLocationSet = false
    var dropDown = DropDown()
    var AlertModal = CustomAlert()
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let Pinned_Location = "Pinned Location"
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocation()
        locationNameTxt.setPadding(left: 10, right: 10)
        distanceTxt.setPadding(left: 10)
        distanceTxt.addDoneButton()
        locationNameTxt.addDoneButton()
        if !isManualLocationSet {
            isManualLocationSet = true
            updateMapToManualLocation(lat:Double(latitude) ?? 0.0, lon: Double(longitude) ?? 0.0)
            locationManager.stopUpdatingLocation()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
          mapView.addGestureRecognizer(tapGesture)
    
    }
    
    
    
    @objc func mapTapped() {
        let coordinate = CLLocationCoordinate2D(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0) // Example coordinate (San Francisco)

        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = Pinned_Location
        
        // Open in Apple Maps
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
   
    func setupUI() {
        [informationOuterView, locationView, addressOuterView].forEach { $0?.layer.cornerRadius = 10 }
        [distanceOuterView, informationOuterView].forEach { $0?.layer.borderWidth = 1 }
        [distanceOuterView, informationOuterView].forEach { $0?.layer.borderColor = UIColor.lightGray.cgColor }
        locationNameTxt.layer.borderWidth = 1
        locationNameTxt.layer.borderColor = UIColor.lightGray.cgColor
        locationNameTxt.layer.cornerRadius = 4
        instractionLbl.text = "\(CommonStringFile.add_location_firstMessage)\n\n\(CommonStringFile.add_location_firstMessage)"
    }
    
    func setupLocation() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if #available(iOS 14.0, *) {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            case .denied, .restricted:
                showSettingsAlert()
            default: break
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
            case .denied, .restricted:
                showSettingsAlert()
            default: break
            }
        }
    }
    
    func showSettingsAlert() {
        let alert = UIAlertController(
            title: AlertstringFile.Location_Access_Needed,
            message: AlertstringFile.Please_allow_location_access,
            preferredStyle: .alert
        )
        alert
            .addAction(
                UIAlertAction(title: AlertstringFile.Cancel, style: .cancel)
            )
        alert
            .addAction(
                UIAlertAction(
                    title: AlertstringFile.Open_Settings,
                    style: .default
                ) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }
    
    func updateMapToManualLocation(lat: Double, lon: Double, radius: CLLocationDistance = 10) {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(region, animated: true)
        showPinAndRadius(at: coordinate, radius: radius)
        self.latitude = "\(lat)"
        self.longitude = "\(lon)"
        self.latlongLbl.text = "Lat: \(lat.rounded(toPlaces: 6)), Long: \(lon.rounded(toPlaces: 6))"
        let location = CLLocation(latitude: lat, longitude: lon)
        fetchAddress(from: location) { [weak self] address in
            self?.adressLbl.text = address
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !isManualLocationSet, let currentLocation = locations.last else { return }
        
        if !hasCenteredMap {
            hasCenteredMap = true
            let region = MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
            mapView.setRegion(region, animated: true)
        }
        
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        self.latitude = "\(lat)"
        self.longitude = "\(lon)"
        self.latlongLbl.text = "Lat: \(lat.rounded(toPlaces: 6)), Long: \(lon.rounded(toPlaces: 6))"
        
        fetchAddress(from: currentLocation) { [weak self] address in
            self?.adressLbl.text = address
        }
        
        showPinAndRadius(at: currentLocation.coordinate, radius: 10)
    }
    
    func showPinAndRadius(at coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        let circle = MKCircle(center: coordinate, radius: radius)
        mapView.addOverlay(circle)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pulsePin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            view?.layer.cornerRadius = 10
            view?.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            
            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.duration = 0.8
            pulse.fromValue = 1
            pulse.toValue = 1.5
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            view?.layer.add(pulse, forKey: "pulse")
            
            let colorPulse = CABasicAnimation(keyPath: "backgroundColor")
            colorPulse.fromValue = UIColor.systemBlue.cgColor
            colorPulse.toValue = UIColor.systemGreen.cgColor
            colorPulse.duration = 0.8
            colorPulse.autoreverses = true
            colorPulse.repeatCount = .infinity
            view?.layer.add(colorPulse, forKey: "colorPulse")
        }
        
        view?.annotation = annotation
        return view
    }
    


    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circleOverlay)
            renderer.strokeColor = UIColor.systemBlue
            renderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.2)
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func fetchAddress(from location: CLLocation, completion: @escaping (String) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let place = placemarks?.first {
                let address = [place.name, place.locality, place.administrativeArea, place.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                completion(address)
            } else {
                completion("Address not found")
            }
        }
    }
    
    @IBAction func backclick(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func dropDown(_ sender: UIButton) {
        let myArray = [ "20","30","40","50","60","70","80","90","100"]
                dropDown.dataSource = myArray//4
                dropDown.anchorView = distanceDropDownView //5
                dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
                dropDown.direction = .bottom
                DropDown.appearance().backgroundColor = UIColor.white
                dropDown.show() //7
                dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                    print("Selected item: \(item) at index: \(index)")
                    distanceLbl.text = item
                    distanceTxt.text = item
                }
    }
    @IBAction func history(_ sender: UIButton) {
        let vc = AddLocationHistory(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    @IBAction func saveLocation(_ sender: UIButton) {
        
        
        if  9 >= Int(distanceTxt.text!) ?? 0  && locationNameTxt.text?.isEmpty ?? true {
            
            let refreshAlert = UIAlertController(
                title: "",
                message: AlertstringFile.Enter_location_name + AlertstringFile.Distance_Should ,
                preferredStyle: UIAlertController.Style.alert
            )
           
            refreshAlert
                .addAction(
                    UIAlertAction(
                        title: AlertstringFile.OK,
                        style: .default,
                        handler: { [self] (
                            action: UIAlertAction!
                        ) in
           
                                   
                               })
)
                           present(refreshAlert, animated: true, completion: nil)
            
            
            
        }else{
            if locationNameTxt.text != "" && longitude != "" && latitude != "" && distanceTxt.text != ""{
                if #available(iOS 15.0, *) {
                    showLottieProgressLoader(animationName: "loader (2)")
                }
                
                APIService.shared.makeApi(
                    url: ServiceUrl.staff_attd_geometric_set_geometric_location,
                    parameters: [  "location": locationNameTxt.text ?? "",
                                   "longitude":longitude,
                                   "latitude": latitude,
                                   "distance": distanceTxt.text ?? ""],
                    type: ApitTypeSringFile.POST,
                    token:staffDetails?.access_token ?? ""
                ) { [self] (result: Result<StaffGeometricLocation, Error>) in
                    DispatchQueue.main.async {
                        if #available(iOS 15.0, *) {
                            self.hideLottieProgressLoader()
                        }
                        
                        switch result {
                        case .success(let response):
                            
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: AlertstringFile.Sccuess, message: response.message ?? "",
                                    on: self
                                ) {
                                    self.dismiss(animated: true)
                                }
                        case .failure(let error):
                            print("Error fetching attachments:", error.localizedDescription)
                            self.AlertModal.showAlert(title: "", message: error.localizedDescription, on: self)
                        }
                    }
                }
                
            }
        }
    }
    
}

// MARK: - Extensions

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UITextField {
    func setPadding(left: CGFloat = 0, right: CGFloat = 0) {
        if left > 0 {
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.height))
            self.leftView = leftPaddingView
            self.leftViewMode = .always
        }
        if right > 0 {
            let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.height))
            self.rightView = rightPaddingView
            self.rightViewMode = .always
        }
    }
}
