
//

import UIKit
import CoreLocation
//import DropDown
import LocalAuthentication
class LocationViewController: UIViewController {
    
    
    @IBOutlet weak var addlocationbtnName: UIButton!
    @IBOutlet weak var TaptoPunchBtn: UIButton!
    @IBOutlet weak var PunchDescriptionLbl: UILabel!
    @IBOutlet weak var PunchThumbnail: UIImageView!
    @IBOutlet weak var EnableLocationBtn: UIButton!
    @IBOutlet weak var AllowLocationDescribeLbl: UILabel!
    @IBOutlet weak var AllowLocationLbl: UILabel!
    @IBOutlet weak var AllowLoactionThumbnail: UIImageView!
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var LocationErrorStack: UIStackView!
    @IBOutlet weak var punchStack: UIStackView!
    @IBOutlet weak var SegmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    let locationManager = CLLocationManager()
    var allowedDistance = CLLocationDistance() // 5 meters
    let currentYear = Calendar.current.component(.year, from: Date())
    var RefrenceAddress = ""
    var years: [String] = []
    let dropDown = DropDown()
    var selectedDictionary = NSDictionary()
    var monthNames: [String] = []
    let dateFormatter = DateFormatter()
    var device = UIDevice.current.name
    var punch_type = 1
    var secureId  = ""
    var currentDistanceForPuchCheck : Double!
    var apiDistanceForPuchCheck :  Int!
    var getlocationDataDetails:[GeometricLocation]?
    var currentLat:String?
    var currentLogi:String?
    var ExstingLogi:String?
    var ExstingLat:String?
    var ExstingDistance:String?
    var isPopupVisible = false
    var childVC: LocationReportVC?
    let add_location_enabel = UserDefaultFileManager.get_staff_Details()?.biometric_enable
    private var lastIsInsideAllowedArea: Bool?
    var staff = "staff"
    var urlss : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let segments = ["Punch In".translated(), "Reports".translated()]
        SegmentControl.removeAllSegments()
        segments.enumerated().forEach {
            SegmentControl.insertSegment(withTitle: $1, at: $0, animated: false)
        }
        SegmentControl.selectedSegmentIndex = 0
        ViewAnimator.hideFade(LocationErrorStack)
        ViewAnimator.hideFade(punchStack)
        EnableLocationBtn.layer.cornerRadius = 10
        TaptoPunchBtn.layer.cornerRadius = 10
        LocationErrorStack.layer.cornerRadius = 10
        LocationErrorStack.backgroundColor = .systemBlue.withAlphaComponent(0.4)
        SegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        SegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        SegmentControl.selectedSegmentTintColor = .primery
        StyleAndTranslate()
    }
    
    func StyleAndTranslate(){
        BackBtn
            .configureAsBackButton(
                firstLine:MenuStringFile.selectedMenuName,
                secondLine: UserDefaultFileManager
                    .get_staff_Details()?.school_name ?? ""
            )
        AllowLocationLbl.setFont(style: .body, size: FontSize.BodySize)
        AllowLocationDescribeLbl.setFont(style: .body, size: FontSize.BodySize)
        PunchDescriptionLbl.setFont(style: .header, size: FontSize.HeaderSize)
        EnableLocationBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        TaptoPunchBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "plus.circle.fill")
            config.title = "Add Location"
            config.imagePlacement = .top
            config.imagePadding = 8
            addlocationbtnName.configuration = config
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLocationEnabel(Show: add_location_enabel ?? false )
        NotificationCenter.default.addObserver(self, selector: #selector(checkAndFetchLocationData), name: UIApplication.didBecomeActiveNotification, object: nil)
        checkLocationAuthorization()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addLocationEnabel(Show:Bool){
        addlocationbtnName.isHidden = !Show
    }
    func getDeviceModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) { ptr in
            return String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        let modelMap: [String: String] = [
            
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone16,3": "iPhone 16",
            "iPhone16,4": "iPhone 16 Plus",
            "iPhone17,1": "iPhone 16 Pro",
            "iPhone17,2": "iPhone 16 Pro Max",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone13,1": "iPhone 12 mini",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone11,8": "iPhone XR",
            "iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max",
            "iPhone11,6": "iPhone XS Max (China)",
            "iPhone10,3": "iPhone X",
            "iPhone10,6": "iPhone X (GSM)",
            "iPhone10,1": "iPhone 8",
            "iPhone10,4": "iPhone 8 (GSM)",
            "iPhone10,2": "iPhone 8 Plus",
            "iPhone10,5": "iPhone 8 Plus (GSM)",
            "iPhone9,1": "iPhone 7",
            "iPhone9,3": "iPhone 7 (GSM)",
            "iPhone9,2": "iPhone 7 Plus",
            "iPhone9,4": "iPhone 7 Plus (GSM)",
            "iPhone8,1": "iPhone 6s",
            "iPhone8,2": "iPhone 6s Plus",
            "iPhone8,4": "iPhone SE (1st generation)",
            "iPhone7,2": "iPhone 6",
            "iPhone7,1": "iPhone 6 Plus",
            "iPhone6,1": "iPhone 5s (GSM)",
            "iPhone6,2": "iPhone 5s (Global)",
            "iPhone5,1": "iPhone 5 (GSM)",
            "iPhone5,2": "iPhone 5 (Global)",
            "iPhone5,3": "iPhone 5c (GSM)",
            "iPhone5,4": "iPhone 5c (Global)",
            "iPhone4,1": "iPhone 4s",
            "iPhone3,1": "iPhone 4 (GSM)",
            "iPhone3,2": "iPhone 4 (GSM Rev A)",
            "iPhone3,3": "iPhone 4 (CDMA)",
            "iPhone2,1": "iPhone 3GS",
            "iPhone1,2": "iPhone 3G",
            "iPhone1,1": "iPhone",
            
            // iPads
            "iPad13,16": "iPad Air (5th generation, WiFi)",
            "iPad13,17": "iPad Air (5th generation, WiFi+Cellular)",
            "iPad13,4": "iPad Pro 11 inch (3rd generation, WiFi)",
            "iPad13,5": "iPad Pro 11 inch (3rd generation, WiFi+Cellular)",
            "iPad13,6": "iPad Pro 11 inch (3rd generation, WiFi+Cellular)",
            "iPad13,7": "iPad Pro 11 inch (3rd generation, WiFi+Cellular)",
            "iPad13,8": "iPad Pro 12.9 inch (5th generation, WiFi)",
            "iPad13,9": "iPad Pro 12.9 inch (5th generation, WiFi+Cellular)",
            "iPad13,10": "iPad Pro 12.9 inch (5th generation, WiFi+Cellular)",
            "iPad13,11": "iPad Pro 12.9 inch (5th generation, WiFi+Cellular)",
            "iPad12,1": "iPad (9th generation, WiFi)",
            "iPad12,2": "iPad (9th generation, WiFi+Cellular)",
            "iPad11,6": "iPad (8th generation, WiFi)",
            "iPad11,7": "iPad (8th generation, WiFi+Cellular)",
            "iPad11,3": "iPad Air (4th generation, WiFi)",
            "iPad11,4": "iPad Air (4th generation, WiFi+Cellular)",
            "iPad8,1": "iPad Pro 11 inch (1st generation, WiFi)",
            "iPad8,2": "iPad Pro 11 inch (1st generation, WiFi)",
            "iPad8,3": "iPad Pro 11 inch (1st generation, WiFi+Cellular)",
            "iPad8,4": "iPad Pro 11 inch (1st generation, WiFi+Cellular)",
            "iPad8,9": "iPad Pro 11 inch (2nd generation, WiFi)",
            "iPad8,10": "iPad Pro 11 inch (2nd generation, WiFi+Cellular)",
            "iPad7,5": "iPad (6th generation, WiFi)",
            "iPad7,6": "iPad (6th generation, WiFi+Cellular)",
            
        ]
        return modelMap[modelCode] ?? modelCode // Returns modelCode if not found in the map
    }
    @objc private func appDidBecomeActive() {
        // Check and then fetch
        checkAndFetchLocationData()
    }
    
    @objc func checkAndFetchLocationData() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                call_locationManager()
            }
        } else {
            checkLocationAuthorization()
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func SegmentAction(_ sender: Any) {
        if SegmentControl.selectedSegmentIndex == 1{
            addLocationEnabel(Show: false )
            addChildViewControllerToContainer()
        }else{
            
            addLocationEnabel(Show: add_location_enabel ?? false )
            removeChildVC()
            checkLocationAuthorization()
        }
    }
    
    @IBAction func PunchBtnAct(_ sender: Any) {
        checkAuthenticationAvailability()
    }
    
    @IBAction func AddLocationAct(_ sender: Any) {
        let vc = CreateLocationViewController(nibName: nil, bundle: nil)
        vc.longitude = currentLogi ?? ""
        vc.latitude = currentLat ?? ""
        vc.refrenceAddress = RefrenceAddress
        vc.modalPresentationStyle = .popover
        present(vc, animated: true)
    }
    
    func addChildViewControllerToContainer() {
        let vc = LocationReportVC(nibName: nil, bundle: nil)
        addChild(vc)
        vc.view.frame = containerView.bounds
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
        self.childVC = vc // Save reference
    }
    
    func removeChildVC() {
        guard let vc = childVC else { return }
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
        childVC = nil
    }
    
    
    @IBAction func enableLocationButtonTapped(_ sender: UIButton) {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings)
        }
    }
    
    @objc func checkLocationAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            // Request permission
            DispatchQueue.main.async { [self] in
                call_locationManager()
                locationManager.requestWhenInUseAuthorization()
            }
        case .restricted, .denied:
            DispatchQueue.main.async { [self] in
                ViewAnimator.showFade(LocationErrorStack)
                ViewAnimator.hideFade(punchStack)
                addLocationEnabel(Show: false)
            }
        case .authorizedWhenInUse, .authorizedAlways:
            // Start location updates
            DispatchQueue.main.async { [self] in
                ViewAnimator.hideFade(LocationErrorStack)
                ViewAnimator.showFade(punchStack)
                call_locationManager()
            }
        @unknown default:
            break
        }
    }
    
    
    func call_locationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func checkAuthenticationAvailability() {
        let context = LAContext()
        var error: NSError?
        let policy: LAPolicy = .deviceOwnerAuthentication
        if context.canEvaluatePolicy(policy, error: &error) {
            authenticateUser(context: context, policy: policy)
        } else {
            punch_type = 1
            Punch_Api()
        }
    }
    
    func authenticateUser(context: LAContext, policy: LAPolicy) {
        context.evaluatePolicy(policy, localizedReason: "Please authenticate to proceed") { [self] success, authenticationError in
            DispatchQueue.main.async { [self] in
                if success {
                    punch_type = 3
                    Punch_Api()
                } else {
                    // Authentication failed
                    if let error = authenticationError {
                        print("Authentication failed: \(error.localizedDescription)")
                        punch_type = 1
                        Punch_Api()
                    }
                }
            }
        }
    }
}
extension LocationViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
            case .locationUnknown:
            default:
                print("Location Manager error: \(clError.localizedDescription)")
            }
        } else {
            print("Location Manager error: \(error.localizedDescription)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            currentLat = String(latitude)
            currentLogi = String(longitude)
            let targetLocation = CLLocation(latitude:Double(latitude) , longitude: Double(longitude))
            let distanceInMeters = location.distance(from: targetLocation)
            let location = CLLocation(latitude: latitude, longitude: longitude)
            convertCoordinatesToAddress(location: location)
            locationManager.stopUpdatingLocation()
            getLocationDetails(
                currentLongitude : currentLogi ?? "" ,
                currentLatitude : currentLat ?? "",
                distance: Int(distanceInMeters)
            )
        }
    }
    
    // Handle errors
    func convertCoordinatesToAddress(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [self] (placemarks, error) in
            if let error = error {
                print("Error in reverse geocoding: \(error.localizedDescription)")
            } else if let placemarks = placemarks, let placemark = placemarks.first {
                let address = self.formatAddress(from: placemark)
                RefrenceAddress = address
            }
        }
    }
    
    func formatAddress(from placemark: CLPlacemark) -> String {
        var address = ""
        if let name = placemark.name {
            address += name
        }
        if let thoroughfare = placemark.thoroughfare {
            address += ", \(thoroughfare)"
        }
        if let locality = placemark.locality {
            address += ", \(locality)"
        }
        if let administrativeArea = placemark.administrativeArea {
            address += ", \(administrativeArea)"
        }
        if let postalCode = placemark.postalCode {
            address += ", \(postalCode)"
        }
        if let country = placemark.country {
            address += ", \(country)"
        }
        
        return address
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func Punch_Api(){
        APIService.shared
            .makeApi(url: ServiceUrl.staff_attd_geometric_entry_using_app, parameters:[
                
                PunchStringFile.device_id : SecureIDManager.getSecureID(),
                PunchStringFile.device_model : device,
                PunchStringFile.punch_type : punch_type,
                PunchStringFile.staff_or_student : staff
            ] , type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "" ){ [self] (
                result : Result<CommonApiSuc,
                Error>
            ) in
                switch result {
                case.success(let succesmessage) :
                    if succesmessage.status == true {
                        DispatchQueue.main.async { [self] in
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message:succesmessage.message ?? "" ,
                                    on: self)}
                    }else {
                        DispatchQueue.main.async {
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: AlertstringFile.Alert_title,
                                    message:succesmessage.message ?? "" ,
                                    on: self
                                )
                        }
                    }
                    
                case.failure(let error) :
                    
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
            }
    }
    
    func getLocationDetails(currentLongitude: String, currentLatitude: String, distance: Int) {
        APIService.shared.makeApi(
            url: ServiceUrl.staff_attd_geometric_get_staff_geometric_location,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<StaffGeometricLocation, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.status == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                        var isInsideAllowedArea = false
                        guard let currentLat = Double(currentLatitude),
                              let currentLong = Double(currentLongitude) else {
                            print("Invalid current coordinates")
                            return
                        }
                        for location in response.data ?? [] {
                            guard let lat1 = Double(location.latitude ?? ""),
                                  let lon1 = Double(location.longitude ?? ""),
                                  let allowedDistance = Int(location.distance ?? "") else {
                                continue
                            }
                            let calculatedDistance = self.haversineDistance(
                                lat1: lat1,
                                lon1: lon1,
                                lat2: currentLat,
                                lon2: currentLong
                            )
                            if calculatedDistance <= Double(allowedDistance) {
                                isInsideAllowedArea = true
                                break
                            }
                        }
                        if self.lastIsInsideAllowedArea != isInsideAllowedArea {
                            self.lastIsInsideAllowedArea = isInsideAllowedArea
                            DispatchQueue.main.async {
                                self.updatePunchUI(isInside: isInsideAllowedArea)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorLocation(alertMessage: response.message ?? "")
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    private func updatePunchUI(isInside: Bool) {
        if isInside {
            showInsideBoundaryUI()
        } else {
            showOutsideBoundaryUI()
        }
    }
    
    private func showInsideBoundaryUI() {
        ViewAnimator.showFade(TaptoPunchBtn)
        ViewAnimator.showFade(punchStack)
        ViewAnimator.hideFade(LocationErrorStack)
        PunchDescriptionLbl.text = CommonStringFile.Tap_on_the_punch.translated()
        PunchThumbnail.image = UIImage(named: "PunchAttenace")
        punchStack.backgroundColor = .white
        PunchDescriptionLbl.textColor = .black
    }
    
    private func showOutsideBoundaryUI() {
        ViewAnimator.hideFade(TaptoPunchBtn)
        ViewAnimator.showFade(punchStack)
        ViewAnimator.showFade(PunchThumbnail)
        PunchThumbnail.image = ImageName.need_location_access
        punchStack.layer.cornerRadius = 10
        punchStack.backgroundColor = UIColor(named: "errorColor")
        PunchDescriptionLbl.textColor = .white
        PunchDescriptionLbl.text = CommonStringFile.locationErrorMessage.translated()
    }
    
    
    private func errorLocation(alertMessage: String) {
        addLocationEnabel(Show: add_location_enabel ?? false)
        ViewAnimator.hideFade(TaptoPunchBtn)
        ViewAnimator.showFade(punchStack)
        ViewAnimator.showFade(PunchThumbnail)
        PunchThumbnail.image = ImageName.need_location_access
        PunchDescriptionLbl.text = alertMessage
    }
    
    
    func locationCheck() {
        guard let distanceString = ExstingDistance else {
            return
        }
        let cleanedDistance = distanceString.replacingOccurrences(of: " m", with: "")
        guard let distanceInt = Int(cleanedDistance) else {
            return
        }
        guard let exLatString = ExstingLat,
              let crntLatString = currentLat,
              let ExtLogiString = ExstingLogi,
              let crntLogiString = currentLogi,
              let exLat = Double(exLatString),
              let crntLat = Double(crntLatString),
              let ExtLogi = Double(ExtLogiString),
              let crntLogi = Double(crntLogiString) else {
            return
        }
        let distance = haversineDistance(lat1: exLat, lon1: ExtLogi, lat2: crntLat, lon2: crntLogi)
    }
    func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadiusKm: Double = 6371.0
        let dLat = degreesToRadians(lat2 - lat1)
        let dLon = degreesToRadians(lon2 - lon1)
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(degreesToRadians(lat1)) * cos(degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadiusKm * c * 1000 // Convert to meters
    }
    
    // Helper function to convert degrees to radians
    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180
    }
    
}
