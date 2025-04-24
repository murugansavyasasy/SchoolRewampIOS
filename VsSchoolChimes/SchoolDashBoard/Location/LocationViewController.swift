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
    var currentLat = ""
    var currentLogi = ""
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
      //  LocationErrorStack.isHidden = true
        punchStack.isHidden = true
        
        LocationErrorStack.layer.cornerRadius = 10
        LocationErrorStack.backgroundColor = .systemBlue.withAlphaComponent(0.4)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
//    @objc func appDidBecomeActive() {
//        
//        checkLocationAuthorization()
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        checkLocationAuthorization()
        //NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
//    
//    func handleLocationAuthorizationStatus(_ status: CLAuthorizationStatus) {
//        switch status {
//        case .notDetermined:
//            print("Location permission not determined yet.")
//        case .restricted:
//            print("Location permission is restricted (e.g., parental controls).")
//        case .denied:
//            print("Location permission denied.")
//            showCustomLocationView(ishiden: false)
//        case .authorizedWhenInUse, .authorizedAlways:
//            print("Location permission granted.")
//            showCustomLocationView(ishiden: true)
//            
//        @unknown default:
//            break
//        }
//    }
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
    }
    
    @IBAction func AddLocationAct(_ sender: Any) {
    }
    
    
    
//    func addChildViewControllerToContainer() {
//        let storyboard = UIStoryboard(name: "LocationReportVC", bundle: nil)
//        guard let childVC = storyboard.instantiateViewController(withIdentifier: "LocationReportVC") as? LocationReportVC else { return }
//
//        addChild(childVC) // Step 1: Add child
//        childVC.view.frame = containerView.bounds // Step 2: Set size to container
//        containerView.addSubview(childVC.view) // Step 3: Add view to container
//        childVC.didMove(toParent: self) // Step 4: Notify child
//    }
    
    var childVC: LocationReportVC?

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


    
    
//    
//    func checkLocationAuthorization() {
//        let status = CLLocationManager.authorizationStatus()
//        switch status {
//        case .notDetermined:
//            // Request permission
//           ""
//        case .restricted, .denied:
//            // Show alert to guide the user to settings
//            showCustomLocationView(ishiden: false)
//        case .authorizedWhenInUse, .authorizedAlways:
//            // Start location updates
//            showCustomLocationView(
//                ishiden: true
//            )
//        @unknown default:
//            break
//        }
//    }

    
//    func showCustomLocationView(ishiden:Bool){
//        
//        LocationErrorStack.isHidden = ishiden
//        punchStack.isHidden = !ishiden
//        
//    }
    @IBAction func enableLocationButtonTapped(_ sender: UIButton) {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings)
        }
    }

    
}
