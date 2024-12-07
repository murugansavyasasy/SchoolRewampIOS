    //
    //  LocationViewController.swift
    //  VoicesnapSchoolApp
    //
    //  Created by admin on 29/08/24.
    //  Copyright © 2024 Gayathri. All rights reserved.
    //

    import UIKit
    import CoreLocation
    import ObjectMapper
    import DropDown
    import LocalAuthentication
class LocationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
    
    @IBOutlet weak var plusViewHeight: NSLayoutConstraint!
    @IBOutlet weak var markAttendDfltLbl: UILabel!
    @IBOutlet weak var attendanceDefltLbl: UILabel!
    @IBOutlet weak var faceIdDefaultLbl: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var ErrorLablelView: UIView!
    @IBOutlet weak var ErrorLablel: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var selectyrDrop: NSLayoutConstraint!
    
    @IBOutlet weak var selectMontheight: NSLayoutConstraint!
    @IBOutlet weak var selectMonthlbl: UILabel!
    @IBOutlet weak var selectYearsLbl: UILabel!
    @IBOutlet weak var selectMonth: UIViewX!
    @IBOutlet weak var selectYrsview: UIViewX!
    @IBOutlet weak var punchFullView: UIView!
    @IBOutlet weak var punchButton: UIViewX!
    @IBOutlet weak var enabelview: UIViewX!
    @IBOutlet weak var locationAlertFullView: UIViewX!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var plusview: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var histroyView: UIView!
    @IBOutlet weak var punchView: UIView!
    
    var TvIdentfier = "LocationTableViewCell"
    
    let locationManager = CLLocationManager()
   
   
    var allowedDistance = CLLocationDistance() // 5 meters
    let currentYear = Calendar.current.component(.year, from: Date())
    var currentLat = ""
    var currentLogi = ""
    var RefrenceAddress = ""
    var getHistorydata  : [GetHirstorydatadetails] = []
    var instituteId : Int!
    var staffId : Int!
    var type : Int!
    var years: [String] = []
    var fetchdata : [FechdataDetails]!
    let dropDown = DropDown()
    var selectedDictionary = NSDictionary()
    var monthNames: [String] = []
    
    // DateFormatter to get the month names
    let dateFormatter = DateFormatter()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var bioMatricEnable  : Int!
    var staus : Bool!
    
    let firstParagraph = "Note : You are outside the institutes boundary. you will not be able to mark your attendanc"
    
    let secondParagraph = "Please try again when you are within the designated area."
    
    var device = UIDevice.current.name
    var punch_type = 1
    var secureId  = ""
    var currentDistanceForPuchCheck : Double!
    var apiDistanceForPuchCheck :  Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        switchBtn.isHidden = true
        faceIdDefaultLbl.isHidden = true
//        locationAlertFullView.isHidden = true
        ErrorLablelView.isHidden = true
        noRecordLbl.isHidden = true
        punchFullView.isHidden = true
        errorLabel.isHidden = true
        selectyrDrop.constant = 0
        selectMontheight.constant = 0
        
      
      let strUDID : String = Util.str_deviceid()
        
        print("strUDID",strUDID)
      
        let deviceModel = getDeviceModelName()
      
        device = deviceModel
        print("Device Model: \(deviceModel)")
        secureId = strUDID
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"  // This will give the full month name
        let monthName = dateFormatter.string(from: date)
        print("Current Month: \(monthName)")
        selectMonthlbl.text = monthName
        
        checkLocationServices()
        
        
        
        let combinedText = "\(firstParagraph)\n\n\(secondParagraph)"
        
        let attributedString = NSMutableAttributedString(string: combinedText)
        
        // Apply custom formatting if needed
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        // Set the attributed text to the label
        errorLabel.attributedText = attributedString
        let userDefaults = UserDefaults.standard
        
        if  type  == 1{
            
            
        }else{
            
          
            
            instituteId = userDefaults.integer(forKey: DefaultsKeys.SchoolD)
            staffId = userDefaults.integer(forKey: DefaultsKeys.StaffID)
            bioMatricEnable = userDefaults.integer(forKey: DefaultsKeys.biometricEnable)
            
        }
        
        
        
        if  bioMatricEnable == 1{
            //
            plusview.isHidden = false
            //
        }else{
            
            
            plusview.isHidden = true
        }
        
        
        
        for i in 0..<21 {
            let year = currentYear - i
            years.append(String(year))
            
            
        }
        
        selectYearsLbl.text = years[0]
        
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMMM"
        for month in 1...12 {
            var components = DateComponents()
            components.month = month
            if let date = Calendar.current.date(from: components) {
                let monthName = dateFormatter.string(from: date)
                monthNames.append(monthName)
            }
        }
        
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                tv.isHidden = true
                locationAlertFullView.isHidden = false
                print("Location access is not available.")
                
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Location access is granted.")
            @unknown default:
                break
            }
        } else {
            print("Location services are not enabled on this device.")
        }
        let rowNib = UINib(nibName: TvIdentfier, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: TvIdentfier)
        
        
        let history = UITapGestureRecognizer(target: self, action: #selector(history))
        histroyView.addGestureRecognizer(history)
        
        let punch = UITapGestureRecognizer(target: self, action: #selector(punch))
        punchView.addGestureRecognizer(punch)
        let punchbttn = UITapGestureRecognizer(target: self, action: #selector(punchButtonss))
        punchButton.addGestureRecognizer(punchbttn)
        let plus = UITapGestureRecognizer(target: self, action: #selector(plus))
        plusview.addGestureRecognizer(plus)
        let back = UITapGestureRecognizer(target: self, action: #selector(backviw))
        backView.addGestureRecognizer(back)
        let enabel = UITapGestureRecognizer(target: self, action: #selector(enabelclick))
        enabelview.addGestureRecognizer(enabel)
        let yearsDrops = UITapGestureRecognizer(target: self, action: #selector(selectYrsDrop))
        selectYrsview.addGestureRecognizer(yearsDrops)
        let MothDrops = UITapGestureRecognizer(target: self, action: #selector(selectMothDrop))
        selectMonth.addGestureRecognizer(MothDrops)
    }
    
    
    func getDeviceModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let modelCode = withUnsafePointer(to: &systemInfo.machine) { ptr in
            return String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        
        let modelMap: [String: String] = [
            // iPhones
            
            
            "iPhone14,7": "iPhone 14",
                   "iPhone14,8": "iPhone 14 Plus",
                   "iPhone15,2": "iPhone 14 Pro",
                   "iPhone15,3": "iPhone 14 Pro Max",
                   
                   // iPhone 15 Series
                   "iPhone15,4": "iPhone 15",
                   "iPhone15,5": "iPhone 15 Plus",
                   "iPhone16,1": "iPhone 15 Pro",
                   "iPhone16,2": "iPhone 15 Pro Max",
                   
                   // iPhone 16 Series (expected, add more as confirmed in the future)
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
            // Add more as needed
        ]
        
        return modelMap[modelCode] ?? modelCode // Returns modelCode if not found in the map
    }
    
    func checkAuthenticationAvailability() {
        
        locationAlertFullView.isHidden = true
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
            locationVc()
        }
        
        
    }
    
    func authenticateUser(context: LAContext, policy: LAPolicy) {
        context.evaluatePolicy(policy, localizedReason: "Please authenticate to proceed") { [self] success, authenticationError in
            
            DispatchQueue.main.async { [self] in
                if success {
                    print("Authentication successful")
                    // Proceed with your functionality
                    
                    
                    punch_type = 3
                    locationVc()
                    
                } else {
                    
                    // Authentication failed
                    if let error = authenticationError {
                        print("Authentication failed: \(error.localizedDescription)")
                        punch_type = 1
                        locationVc()
                    }
                }
                
                
                
                
            }
            
            
        }
        
        
        
    }
    
    
    func locationVc(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        
        
    }
    @IBAction func history(){
        plusview.isHidden = true
        plusViewHeight.constant = 0
        histroyView .backgroundColor = UIColor(named: "CustomOrange")
        attendanceDefltLbl.textColor = .white
        punchView.backgroundColor = .white
        markAttendDfltLbl.textColor = .black
        selectyrDrop.constant = 30
        selectMontheight.constant = 30
        punchFullView.isHidden = true
        locationAlertFullView.isHidden = true
        
        tv.isHidden = false
        
        AttendaceHistory()
    }
    
    
    @IBAction func punch(){
        
        
        if  bioMatricEnable == 1{
            //
            plusview.isHidden = false
            plusViewHeight.constant = 78
            //
        }else{
            
            
            plusview.isHidden = true
            plusViewHeight.constant = 0
        }
        
       
        punchView.backgroundColor = UIColor(named: "CustomOrange")
        histroyView.backgroundColor = .white
        
        markAttendDfltLbl.textColor = .white
        
        attendanceDefltLbl.textColor = .black
        
        tv.isHidden = true
        noRecordLbl.isHidden = true
        selectyrDrop.constant = 0
        selectMontheight.constant = 0
        
        checkLocationServices()
        
        
        
    }
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true if Settings was opened successfully
            })
        }
    }
    @IBAction func enabelclick(){
        
        openAppSettings()
    }
    
    @IBAction func punchButtonss(){
        
        
        locationVc()
        
        // Check if the distance is smaller
        if currentDistanceForPuchCheck <= Double(apiDistanceForPuchCheck) {
          
            punchFullView.isHidden = false
            errorLabel.isHidden = true
            ErrorLablelView.isHidden = true
            punchAPi()
          
            
        } else {
           
            
            errorLabel.isHidden = false
            punchFullView.isHidden = true
            ErrorLablelView.isHidden = false
        }
        
        
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
                print("authorizedWhenInUse")
        case .restricted, .denied:
            // Location services are restricted or denied, prompt the user to enable them in settings
            print("denied")
            showAlertToEnableLocationServices()
        case .authorizedAlways, .authorizedWhenInUse:
            checkAuthenticationAvailability()
            print("authorizedWhenInUse")
            //
        @unknown default:
            break
        }
    }
    
    func showAlertToEnableLocationServices() {
        
        locationAlertFullView.isHidden = false
        
    }
    
    
    
    
    @IBAction func selectYrsDrop(){
        
        
        
        let myArray = years
        
        dropDown.dataSource = myArray//4
        dropDown.anchorView = selectYrsview //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            selectYearsLbl.text = item
            
            selectMonthlbl.text = monthNames[0]
            AttendaceHistory()
        }
    }
    
    @IBAction func selectMothDrop(){
        
        
        
        let myArray = monthNames
        
        dropDown.dataSource = myArray//4
        dropDown.anchorView = selectMonth //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            
            selectMonthlbl.text = item
            
            AttendaceHistory()
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // Location services are enabled, so now check the authorization status
            print("heloo")
//            locationAlertFullView.isHidden = true
            checkLocationAuthorization()
        } else {
            
            print("heloo11")
            // Location services are not enabled, prompt the user to enable them
            showAlertToEnableLocationServices()
        }
    }
    
    @IBAction func backviw(){
        
        dismiss(animated: true)
    }
    
    
    @IBAction func plus(){
        
        let vc = CreateLocationViewController(nibName: nil, bundle: nil)
        vc.latitude =  currentLat
        vc.longitude = currentLogi
        vc.refrenceAddress = RefrenceAddress
        vc.InstitudeId = instituteId
        vc.userId = staffId
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
    
   
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
        
        locationAlertFullView.isHidden = true
        
        tv.isHidden = true
        guard let currentLocation = locations.last else { return }
        
        
        
        
        let currentLatitude = currentLocation.coordinate.latitude
        let currentLongitude = currentLocation.coordinate.longitude
        
        print("Current Latitude: \(currentLatitude)")
        print("Current Longitude: \(currentLongitude)")
        
        
        let targetLocation = CLLocation(latitude:Double(currentLatitude) , longitude: Double(currentLongitude))
        
        
        let distanceInMeters = currentLocation.distance(from: targetLocation)
        allowedDistance = distanceInMeters
        
        print("distanceeeewdas",distanceInMeters)
        
        
        let location = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
        convertCoordinatesToAddress(location: location)
        
        currentLat = String(currentLatitude)
        currentLogi = String(currentLongitude)
        
        loactionFech(curentLogittude : currentLogi , currentLatitute : currentLat, distance: Int(distanceInMeters))
        
        locationManager.stopUpdatingLocation()
    }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Location Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return getHistorydata.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TvIdentfier, for: indexPath) as!
        LocationTableViewCell
        cell.selectionStyle = .none
        
        
        
        cell.fullView.layer.cornerRadius = 20
        cell.calanderView.layer.cornerRadius = 10
        cell.calanderView.layer.masksToBounds = true
        cell.fullView.layer.masksToBounds = true
        cell.fullView.layer.shadowColor = UIColor.black.cgColor
        cell.fullView.layer.shadowOpacity = 0.5
        cell.fullView.layer.shadowOffset = CGSize(width: 4, height: 4)
        cell.fullView.layer.shadowRadius = 5
        cell.fullView.layer.masksToBounds = false
        cell.firstInLbl.isHidden = false
        cell.workingHrsLbl.isHidden = false
        cell.toDateLbl.isHidden = false
        let data : GetHirstorydatadetails = getHistorydata[indexPath.row]
        
        cell.namelbl.text = data.staffName
        
        cell.workingHrsLbl.text = "Working Hours - \(data.working_hours ?? "0")"
        
       
        
        cell.StatusLbl.layer.cornerRadius = 5
        cell.StatusLbl.layer.masksToBounds = true
        
        let eventDate = data.date
        let dateFormatter = DateFormatter()
        // Input format
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if let date = dateFormatter.date(from: eventDate!) {
            
            dateFormatter.dateFormat = "EEEE"
            let formattedDate1 = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "MMM"
            let formattedDate2 = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "d"
            let formattedDate = dateFormatter.string(from: date)
            
            cell.dayLbl.text =  formattedDate1
            cell.datelbl.text = formattedDate
            cell.mnthLbl.text =  formattedDate2
            
            print(formattedDate)
        } else {
            print("Invalid date format")
        } // date converstion End
        
        
        
        
        if data.leave_type == "Absent"{
            
            cell.StatusLbl.text = data.leave_type
            cell.StatusLbl.backgroundColor = .red
            
            cell.attendanceTypeLbl.text = data.attendance_type
            
            
        }else{
            cell.namelbl.text = data.staffName
            
            cell.StatusLbl.backgroundColor  = UIColor(named: "presentGreen")
            cell.attendanceTypeLbl.text = data.attendance_type
            cell.StatusLbl.text = data.leave_type
            
            
        }
        
        cell.firstInLbl.text =  "First in - \(data.in_time ?? "0")"
        if data.in_time ?? "" == "" {
            cell.firstInLbl.isHidden = true
        }
        
        cell.namelbl.text = data.staffName
        if data.working_hours ?? "" == "" {
            cell.workingHrsLbl.isHidden = true
        }
        cell.toDateLbl.text = "Last out - \(data.out_time ?? "0")"
        if data.out_time ?? "" == "" {
            cell.toDateLbl.isHidden = true
        }
        cell.attendanceTypeLbl.text = data.attendance_type
        cell.namelbl.text =
            data.staffName
    
        
        let click = imageClick(target: self, action: #selector(click))
        click.date = data.date
        click.staffId = data.staffId
       
        cell.fullView.addGestureRecognizer(click)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    @IBAction func click(ges : imageClick){
       
        let vc = PunchHistoryListVC(nibName: nil, bundle: nil)
        vc.date = ges.date
        vc.instituteId = instituteId
        vc.staffId = ges.staffId
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
        
    }
    
    func punchAPi(){
        
       
        
        
        
        let punchModal = punchModal()
        
        punchModal.institute_id = instituteId
        punchModal.user_id = staffId
        punchModal.staff_or_student = "staff"
        punchModal.punch_type = punch_type
        punchModal.device_id = secureId
        punchModal.device_model = device
        
        var  punchModalStr = punchModal.toJSONString()
        print("punchModalStr",punchModal.toJSON())
        
        
        PunchRequest.call_request(param: punchModalStr!) {
            
            [self] (res) in
            
            let PunchRes : punchResponce = Mapper<punchResponce>().map(JSONString: res)!
            
            if PunchRes.status == 1 {
                
                let refreshAlert = UIAlertController(title: "", message: PunchRes.message, preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                    

                    
                }))
                present(refreshAlert, animated: true, completion: nil)
            }else{
                
                
                let refreshAlert = UIAlertController(title: "", message: PunchRes.message, preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                    

                    
                }))
                present(refreshAlert, animated: true, completion: nil)
                
            }
            
            
            
        }
        
        
    }
    
    
    func AttendaceHistory(){
        
        let year = selectYearsLbl.text!
        var YearLbl = ""
        let monthName = selectMonthlbl.text!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // Full month name format
        
        if let date = dateFormatter.date(from: monthName) {
            let calendar = Calendar.current
            let monthNumber = calendar.component(.month, from: date)
            print("The month number for \(monthName) is \(monthNumber).")
            
            if  monthNumber == 1 || monthNumber == 2 || monthNumber == 3 || monthNumber == 4 || monthNumber == 5 || monthNumber == 6 || monthNumber == 7 || monthNumber == 8 || monthNumber == 9 {
                YearLbl = year +  "-" + "0" + String(monthNumber)
            }else{
                YearLbl = year +  "-"  + String(monthNumber)
                
            }
            
        } else {
            print("Invalid month name.")
        }
        
        let param : [String : Any] =
        [
            
            "institiuteId": instituteId!,
            "attendance_month" : YearLbl,
            "userId"    : staffId!
            
            
        ]
        
        print("paramparam",param)
        
        GetAttendanceHistroyReq.call_request(param: param){ [self]
            (res) in
            
            print("resres",res)
            let getattendace : GethistoryModal = Mapper<GethistoryModal>().map(JSONString: res)!
            
            
            if getattendace.status == 1  {
                tv.isHidden  = false
                
                getHistorydata = getattendace.data
                noRecordLbl.isHidden = true
                tv.dataSource = self
                tv.delegate = self
                tv.reloadData()
                
            }else{
                tv.isHidden  = true
                noRecordLbl.isHidden = false
                noRecordLbl.text = getattendace.message
                
            }
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
    
    func loactionFech(curentLogittude : String , currentLatitute : String, distance : Int  ){
        
        
        
        let param : [String : Any] =
        [
            
            "userId": staffId!,
            "institute_id" : instituteId!
            
        ]
        
        print("paramparamm,nc",param)
        
        fechLocationReq.call_request(param: param){ [self]
            (res) in
            
            print("resres",res)
            let getattendace : fechModal = Mapper<fechModal>().map(JSONString: res)!
            
            if getattendace.status == 1  {
                noRecordLbl.isHidden = true
                for i in getattendace.data{
                    var distanceInt = Int(i.distance)
                    let distance = haversineDistance(lat1: Double(i.latitude)!, lon1: Double(i.longitude)!, lat2: Double(currentLatitute)!, lon2: Double(curentLogittude)!)
                    currentDistanceForPuchCheck = distance
                    apiDistanceForPuchCheck = distanceInt
                    
                    // Check if the distance is smaller
                    if distance <= Double(distanceInt!) {
                      
                        punchFullView.isHidden = false
                        errorLabel.isHidden = true
                        ErrorLablelView.isHidden = true
                        
                        break
                        
                    } else {
                       
                        
                        errorLabel.isHidden = false
                        punchFullView.isHidden = true
                        ErrorLablelView.isHidden = false
                    }
                    
                }
                
            }else{
                
                ErrorLablelView.isHidden = true
                noRecordLbl.text = getattendace.message
                noRecordLbl.isHidden = false
                
            }
        }
        
        
    }
    
    
  
}

class imageClick : UITapGestureRecognizer{
    
   var  date  : String!
    var staffId : Int!
}


