//
//  ViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import UIKit

class ViewController: UIViewController {
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
//        BottomView.layer.cornerRadius = 30
//        BottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
//        
//        GetStartedBtn.layer.cornerRadius = 15
//        GetStartedBtn.layer.masksToBounds = false
//                
//        // Adding shadow for a popped-up effect
//        GetStartedBtn.layer.shadowColor = UIColor.black.cgColor
//        GetStartedBtn.layer.shadowOffset = CGSize(width: 0, height: 5)
//        GetStartedBtn.layer.shadowOpacity = 0.3
//        GetStartedBtn.layer.shadowRadius = 6
//        
//        GetStartedBtn.addTarget(self, action: #selector(buttonTapped), for: .touchDown)
    }
    
    
    @objc func buttonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            sender.layer.shadowOffset = CGSize(width: 0, height: 2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
                sender.layer.shadowOffset = CGSize(width: 0, height: 5)
            }
        }
        
//        let vc = SplashViewController(nibName: nil, bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
    }
    
}
