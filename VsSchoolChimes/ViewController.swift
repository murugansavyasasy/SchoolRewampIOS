//
//  ViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import UIKit

class ViewController: UIViewController {
    
    
    let name = "" // added by laks

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let storyboard = UIStoryboard(name: "SplashStoryboard", bundle: nil)
            let viewController = storyboard.instantiateInitialViewController() as! SplashViewController
            self.present(viewController, animated: true)
        }
        
        
        
            }


}

