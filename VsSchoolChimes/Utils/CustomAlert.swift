//
//  CustomAlert.swift
//  VsSchoolChimes
//
//  Created by admin on 25/10/24.
//

import Foundation
import UIKit

class CustomAlert{
  
    func showAlert(title: String, message: String, on viewController: UIViewController) {
        
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
        
        
    }
    
    
}
