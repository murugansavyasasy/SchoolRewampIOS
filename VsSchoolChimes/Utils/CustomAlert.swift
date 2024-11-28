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
    
    func showAlertCancel(title: String, message: String, actionLbl1: String, actionLbl2: String, on viewController: UIViewController, onOk: @escaping () -> Void, onNo: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // OK button
        let okAction = UIAlertAction(title: actionLbl1, style: .default) { _ in
            onOk()
        }
        alert.addAction(okAction)

        // No button
        let noAction = UIAlertAction(title: actionLbl2, style: .cancel) { _ in
            onNo()
        }
        alert.addAction(noAction)

        // Present the alert
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    
    
}
