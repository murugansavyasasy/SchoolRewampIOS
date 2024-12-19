//
//  NetworkMoniter.swift
//  VsSchoolChimes
//
//  Created by admin on 18/12/24.
//

import Network
import UIKit

class NetworkMonitor {
    static let shared = NetworkMonitor() // Singleton
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    var isConnected: Bool = true // Default to connected
    
    // Start monitoring network
    func startMonitoring() {
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = (path.status == .satisfied)
                if !self.isConnected {
                    self.showNoInternetAlert()
                }
            }
        }
    }
    
    // Stop monitoring network
    func stopMonitoring() {
        monitor.cancel()
    }
    
    // Show alert for no internet
    private func showNoInternetAlert() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        let alertController = UIAlertController(
            title: "No Internet Connection",
            message: "Please check your network settings.",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        
      
        // Prevent multiple alerts by checking if another alert is presented
        if rootViewController.presentedViewController == nil {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
}
