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
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorization()
        LocationErrorStack.isHidden = true
        punchStack.isHidden = true
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
    @objc func appDidBecomeActive() {
        checkLocationAuthorization()
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
    
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    

    @IBAction func SegmentAction(_ sender: Any) {
        
        if SegmentControl.selectedSegmentIndex == 1{
            addChildViewControllerToContainer()
        }else{
            removeChildVC()
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

    func showCustomLocationView(ishiden:Bool){
        LocationErrorStack.isHidden = ishiden
        punchStack.isHidden = !ishiden
        
    }
    @IBAction func enableLocationButtonTapped(_ sender: UIButton) {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings)
        }
    }

    func checkLocationAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            // Request permission
            call_locationManager()
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Show alert to guide the user to settings
//            showPopup(topTitle: "Allow location acess to mark your attendance !", content: "To enhance your experience and provide accurate loaction-based features,please enabel GPS. ", image: "")
            showCustomLocationView(ishiden: false)
        case .authorizedWhenInUse, .authorizedAlways:
            // Start location updates
            LocationErrorStack.isHidden = true
            punchStack.isHidden = false
           
            call_locationManager()
            locationManager.startUpdatingLocation()
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
        }
    }
    
func authenticateUser(context: LAContext, policy: LAPolicy) {
        context.evaluatePolicy(policy, localizedReason: "Please authenticate to proceed") { [self] success, authenticationError in
            
            DispatchQueue.main.async { [self] in
                if success {
                    print("Authentication successful")
                    // Proceed with your functionality
                } else {
                    // Authentication failed
                    if let error = authenticationError {
                        print("Authentication failed: \(error.localizedDescription)")
                        
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
        guard let currentLocation = locations.last else { return }
        let currentLatitude = currentLocation.coordinate.latitude
        let currentLongitude = currentLocation.coordinate.longitude
        print("Current Latitude: \(currentLatitude)")
        print("Current Longitude: \(currentLongitude)")
        let targetLocation = CLLocation(latitude:Double(currentLatitude) , longitude: Double(currentLongitude))
        currentLat = String(currentLatitude)
        currentLogi = String(currentLongitude)
        let distanceInMeters = currentLocation.distance(from: targetLocation)
        print("distanceeeewdas",distanceInMeters)
        let location = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
        convertCoordinatesToAddress(location: location)
        get_locationDetails(
            currentLongitude : currentLogi ?? "" ,
            currentLatitude : currentLat ?? "",
            distance: Int(distanceInMeters)
        )
        locationManager.stopUpdatingLocation()
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
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied or restricted.")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
   
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
                            
                        }
                    }
                    
                case.failure(let error) :
                    
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
            }
    }
    
    func get_locationDetails(curentLogittude : String , currentLatitute : String, distance : Int) {
        APIService.shared
            .makeApi(url: ServiceUrl.staff_attd_geometric_get_staff_geometric_location, parameters:[:] , type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "" ){ [self] (
                result : Result<StaffGeometricLocation,
                Error>
            ) in
                switch result {
                case.success(let succesmessage) :
                    if succesmessage.status == true {
                        DispatchQueue.main.async { [self] in
                            
                            getlocationDataDetails = succesmessage.data ?? []
                            
                            for i in 0..<(succesmessage.data?.count ?? 0){
                                var distanceInt = Int(succesmessage.data?[i].distance ?? "")
                                let distance = haversineDistance(
                                    lat1: Double(
                                        succesmessage.data?[i].latitude ?? ""
                                    )!,
                                    lon1: Double(
                                        succesmessage.data?[i].longitude ?? ""
                                    )!,
                                    lat2: Double(currentLatitute)!,
                                    lon2: Double(curentLogittude)!
                                )
                                currentDistanceForPuchCheck = distance
                                apiDistanceForPuchCheck = distanceInt
                                
                                // Check if the distance is smaller
                                if distance <= Double(distanceInt!) {
                                  
                                    punchStack.isHidden = false
//                                    .isHidden = true
                                    LocationErrorStack.isHidden = true
                                    
                                    PunchDescriptionLbl.text = "Tap on the Punch button to record your attendance for the day. A confirmation message will appear once your attendance is successfully marked."
                                    punchStack.backgroundColor = .white
                                    
                                    break
                                    
                                } else {
                                   
                                    AllowLoactionThumbnail.image = ImageName.need_location_access
                                    punchStack.layer.cornerRadius = 10
                                    punchStack.backgroundColor = .red
                                        .withAlphaComponent(0.4)
                                    PunchDescriptionLbl.text = "Note : You are outside the institutes boundary. you will not be able to mark your attendanc \n\n Please try again when you are within the designated area."
                                    LocationErrorStack.isHidden = false
                                    punchStack.isHidden = true
                                    AllowLoactionThumbnail.isHidden = true
//                                    errorLabel.isHidden = false
//                                    punchFullView.isHidden = true
//                                    ErrorLablelView.isHidden = false
                                }
                                
                            }
                            
                        }
                    }else {
                        
                        DispatchQueue.main.async {
//                            CustomAlert
//                                .showAlertWithOkAction(
//                                    title: AlertstringFile.Sccuess,
//                                    message: succesmessage.message ?? "",
//                                    on: self
//                                ) {
//                                    
//                                }
                        }
                    }
                    
                case.failure(let error) :
                    
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        self.getlocationDataDetails = successMessage.data ?? []
                        
                        for i in 0..<(successMessage.data?.count ?? 0) {
                            guard let locationData = successMessage.data?[i],
                                  let distanceInt = Int(locationData.distance ?? ""),
                                  let lat1 = Double(locationData.latitude ?? ""),
                                  let lon1 = Double(locationData.longitude ?? ""),
                                  let lat2 = Double(currentLatitude),
                                  let lon2 = Double(currentLongitude)
                            else {
                                continue
                            }
                            
                            let calculatedDistance = self.haversineDistance(
                                lat1: lat1,
                                lon1: lon1,
                                lat2: lat2,
                                lon2: lon2
                            )
                            
                            self.currentDistanceForPuchCheck = calculatedDistance
                            self.apiDistanceForPuchCheck = distanceInt
                            
                            if calculatedDistance <= Double(distanceInt) {
                                self.punchStack.isHidden = false
                                self.LocationErrorStack.isHidden = true
                                self.PunchDescriptionLbl.text = "Tap on the Punch button to record your attendance for the day. A confirmation message will appear once your attendance is successfully marked."
                                break
                            } else {
                                self.AllowLoactionThumbnail.image = ImageName.need_location_access
                                self.punchStack.layer.cornerRadius = 10
                                self.punchStack.backgroundColor = UIColor.red.withAlphaComponent(0.4)
                                self.PunchDescriptionLbl.text = """
                                Note: You are outside the institute's boundary. You will not be able to mark your attendance. 

                                Please try again when you are within the designated area.
                                """
                                self.LocationErrorStack.isHidden = false
                                self.punchStack.isHidden = true
                                self.AllowLoactionThumbnail.isHidden = true
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
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
