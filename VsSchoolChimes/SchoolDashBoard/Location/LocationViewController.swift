//
//  LocationViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 29/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import CoreLocation
import DropDown
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
    @IBOutlet weak var addLocationBtn: UIButton!
    
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
    var instituteId : Int!
    var staffId : Int!
    var type : Int!
    var years: [String] = []
    let dropDown = DropDown()
    var selectedDictionary = NSDictionary()
    var monthNames: [String] = []
    let dateFormatter = DateFormatter()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var bioMatricEnable  : Int!
    var staus : Bool!
    var device = UIDevice.current.name
    var punch_type = 1
    var secureId  = ""
    var currentDistanceForPuchCheck : Double!
    var apiDistanceForPuchCheck :  Int!
    let firstParagraph = "Note : You are outside the institutes boundary. you will not be able to mark your attendanc"
    let secondParagraph = "Please try again when you are within the designated area."
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
    override func viewDidLoad() {
        super.viewDidLoad()
        print("add_location_enabel",UserDefaultFileManager.get_staff_Details())
        checkAuthenticationAvailability()
        ViewAnimator.hideFade(LocationErrorStack)
        ViewAnimator.hideFade(punchStack)
        EnableLocationBtn.layer.cornerRadius = 10
        TaptoPunchBtn.layer.cornerRadius = 10
        LocationErrorStack.layer.cornerRadius = 10
        LocationErrorStack.backgroundColor = .systemBlue.withAlphaComponent(0.4)
        StyleAndTranslate()
    }
    
    
      
    
    func StyleAndTranslate(){
        
        AllowLocationLbl.setFont(style: .body, size: FontSize.BodySize)
        AllowLocationDescribeLbl.setFont(style: .body, size: FontSize.BodySize)
        PunchDescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        EnableLocationBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        TaptoPunchBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        addLocationBtn.setTitleFont(style: .body, size: FontSize.BodySize)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
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
    
    @objc private func appDidBecomeActive() {
           // Check and then fetch
           checkAndFetchLocationData()
       }
       
    @objc func checkAndFetchLocationData() {
           let status = CLLocationManager.authorizationStatus()
           
           if status == .authorizedAlways || status == .authorizedWhenInUse {
               // ✅ Add delay for safety (system breathing time)
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                   call_locationManager()
               }
           } else {
               print("❗️ Location permission not granted yet.")
               checkLocationAuthorization()
           }
       }
    
    
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    

    @IBAction func SegmentAction(_ sender: Any) {
        
        if SegmentControl.selectedSegmentIndex == 1{
            addChildViewControllerToContainer()
        }else{
            removeChildVC()
            checkLocationAuthorization()
        }
    }
    
    @IBAction func PunchBtnAct(_ sender: Any) {
        Punch_Api()
    }
    
    @IBAction func AddLocationAct(_ sender: Any) {
        
        let vc = CreateLocationViewController(nibName: nil, bundle: nil)
        vc.longitude = currentLogi ?? ""
        vc.latitude = currentLat ?? ""
        vc.refrenceAddress = RefrenceAddress
        vc.modalPresentationStyle = .fullScreen
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
        // Check if biometric authentication or passcode is available
        if context.canEvaluatePolicy(policy, error: &error) {
            // Attempt to authenticate using biometrics or passcode
            authenticateUser(context: context, policy: policy)
        } else {
            // Neither biometric authentication nor passcode is available
            print("No biometric authentication or passcode is set.")
            
            punch_type = 1
//            call_locationManager()
        }
    }
    
func authenticateUser(context: LAContext, policy: LAPolicy) {
        context.evaluatePolicy(policy, localizedReason: "Please authenticate to proceed") { [self] success, authenticationError in
            
            DispatchQueue.main.async { [self] in
                if success {
                    print("Authentication successful")
                    punch_type = 3
//                    call_locationManager()
                    // Proceed with your functionality
                } else {
                    // Authentication failed
                    if let error = authenticationError {
                        print("Authentication failed: \(error.localizedDescription)")
                        punch_type = 1
//                        call_locationManager()
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
                print("Location access denied by user.")
            case .locationUnknown:
                print("Location could not be determined.")
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
            
            print("Latitude: \(latitude), Longitude: \(longitude)")
            
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
                print("Address: \(address)")
                
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
    
    
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        switch status {
//        case .authorizedWhenInUse, .authorizedAlways:
//            locationManager.startUpdatingLocation()
//        case .denied, .restricted:
//            print("Location access denied or restricted.")
//        case .notDetermined:
//            locationManager.requestWhenInUseAuthorization()
//        @unknown default:
//            break
//        }
//    }
//   
    func Punch_Api(){
        
        APIService.shared
            .makeApi(url: ServiceUrl.staff_attd_geometric_entry_using_app, parameters:[
                
                PunchStringFile.device_id : SecureIDManager.getSecureID(),
                PunchStringFile.device_model : device,
                PunchStringFile.punch_type : punch_type,
                PunchStringFile.staff_or_student : "staff"
                
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
                                    title: AlertstringFile.Sccuess,
                                    message:succesmessage.message ?? "" ,
                                    on: self
                                )
                        }
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

                            print("Checking location \(location.location ?? "")")
                            print("Distance to location: \(calculatedDistance) meters")

                            if calculatedDistance <= Double(allowedDistance) {
                                isInsideAllowedArea = true
                                break // Stop at first match
                            }
                        }

                        // ✅ Only update UI if the status has changed
                        if self.lastIsInsideAllowedArea != isInsideAllowedArea {
                            self.lastIsInsideAllowedArea = isInsideAllowedArea
                            DispatchQueue.main.async {
                                self.updatePunchUI(isInside: isInsideAllowedArea)
                            }
                        } else {
                            print("🔁 Skipped UI update, no change in punch status.")
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
        PunchDescriptionLbl.text = "Tap on the Punch button to record your attendance for the day. A confirmation message will appear once your attendance is successfully marked."
        punchStack.backgroundColor = .white
    }

    private func showOutsideBoundaryUI() {
        ViewAnimator.hideFade(TaptoPunchBtn)
        ViewAnimator.showFade(punchStack)
        ViewAnimator.showFade(PunchThumbnail)
        PunchThumbnail.image = ImageName.need_location_access
        punchStack.layer.cornerRadius = 10
        punchStack.backgroundColor = UIColor.red.withAlphaComponent(0.4)
        PunchDescriptionLbl.text = """
        Note: You are outside the institute's boundary. You will not be able to mark your attendance.

        Please try again when you are within the designated area.
        """
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
            print("Error: Distance string is nil")
            return
        }
        let cleanedDistance = distanceString.replacingOccurrences(of: " m", with: "")
        guard let distanceInt = Int(cleanedDistance) else {
            print("Error: Unable to convert distance to Int")
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
            print("Error: Invalid latitude/longitude values")
            return
        }
        
        let distance = haversineDistance(lat1: exLat, lon1: ExtLogi, lat2: crntLat, lon2: crntLogi)
        
        if distance <= Double(distanceInt) {
            print("The existing location is within \(distanceInt) meters of the current location.")
           
        } else {
            print("The existing location is more than \(distanceInt) meters away.")
           
        }
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


// MARK: To save the present absent person's :


//       @objc func savePDF() {
//           guard let pdfData = AttPDFGenerator.generateAttendancePDF(from: attendanceRecords,meetingTitle: "Sports day meeting",watermarkImageName: "SavayasasyLogo") else { return }
//
//           let fileName = "AttendanceReport.pdf"
//           let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//           let filePath = documentDirectory.appendingPathComponent(fileName)
//
//           do {
//               try pdfData.write(to: filePath)
//               showPDFPreview(filePath: filePath)
//           } catch {
//               print("Failed to save PDF:", error)
//           }
//       }
//
//       func showPDFPreview(filePath: URL) {
//           let previewVC = PDFsPreviewVC(pdfURL: filePath)
//           navigationController?.pushViewController(previewVC, animated: true)
//       }
