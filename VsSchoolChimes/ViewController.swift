//
//  ViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import UIKit

@available(iOS 14.0, *)
class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let storyboard = UIStoryboard(name: "SplashStoryboard", bundle: nil)
            let viewController = storyboard.instantiateInitialViewController() as! SplashViewController
            self.present(viewController, animated: true)
        }
        
    }
    
}

