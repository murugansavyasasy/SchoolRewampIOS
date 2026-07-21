//
//  whereismybusVc.swift
//  School Chimes
//
//  Created by apple on 08/05/26.
//

import UIKit
import WebKit
import CoreLocation
class whereismybusVc: UIViewController {

    @IBOutlet weak var busNumberLbl: UILabel!
    
    @IBOutlet weak var webview: WKWebView!
    var liveBusdataDetails : [livebusData]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var loginasType : Int?
    var busStatus  = ""
    override func viewDidLoad() {
        super.viewDidLoad()
//        LocationPermissionManager.shared.checkLocationPermission()
        showActivityLoader()
        GetBusDetails()
    }

    @IBAction func Backbtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func loadWebPage() {
        DispatchQueue.main.async { [weak self] in
            guard let self  = self else { return }
            if let url = URL(string: liveBusdataDetails?.first?.tracking_url ?? "") {
                let request = URLRequest(url: url)
                webview.load(request)
            }
            hideActivityLoader()
        }
       }

    
    func GetBusDetails() {
        APIService.shared.makeApi(url: ServiceUrl.get_vehicle_live_tracking_details, parameters: ["journey_type" : busStatus], type: ApitTypeSringFile.GET, token: (loginasType == 2 ? UserDefaultFileManager.get_child_Details()?.access_token : UserDefaultFileManager.get_staff_Details()?.access_token) ?? "", isBaseUrl: false) {[self] (result: Result<livebusDetails,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    if Success.status ?? false{
                       
                        liveBusdataDetails = Success.data
                        busNumberLbl.text = liveBusdataDetails?.first?.thing_id
                        loadWebPage()
                    }else{
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: Success.message ?? "", on: self) {
                            self.dismiss(animated: true)
                        }
                        hideActivityLoader()
                    }
                    
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    hideActivityLoader()
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: error.localizedDescription, on: self) {
                        self.dismiss(animated: true)
                    }
                   
                }
            }
        }
    }
}


class LocationPermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let shared = LocationPermissionManager()
    
    private let locationManager = CLLocationManager()
    
    @Published var isLocationEnabled = false
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    
    
    // MARK: - Permission Change Callback
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
            
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationEnabled = true
            print("Location Enabled")
            
        case .denied, .restricted:
            isLocationEnabled = false
            print("Location Denied")
            
        case .notDetermined:
            print("Permission Not Determined")
            
        @unknown default:
            break
        }
    }
    
    // MARK: - Open Settings
    func openAppSettings() {
        
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}
