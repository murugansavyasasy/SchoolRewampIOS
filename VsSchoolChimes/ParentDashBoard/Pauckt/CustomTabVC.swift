//
//  CustomTabVC.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 24/02/25.
//  Copyright © 2025 Gayathri. All rights reserved.
//

import UIKit

//class CustomTabVC: UIViewController {
//
//    // Child View Controllers
////    let homeVC = HomePaucktVC()
////    let profileVC = ReedimHistoryVc()
//    let selectColor = UIColor(red: 244/255, green: 245/255, blue: 249/255, alpha: 1)
//    @IBOutlet weak var rewardsBtn: UIButton!
//    @IBOutlet weak var containerView: UIView!
//    // Custom Tab Bar
//    @IBOutlet weak var hoemBtn: UIButton!
//    let customTabBar = UIStackView()
//    
//    @IBOutlet weak var tabView: UIView!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0).cgColor,
//            UIColor.white.cgColor
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
//        
//        gradientLayer.frame = UIScreen.main.bounds
//        view.layer.insertSublayer(gradientLayer, at: 0)
//        tabView.layer.cornerRadius = 28
//        tabView.layer.shadowColor = UIColor.black.cgColor
//        tabView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        tabView.layer.shadowRadius = 5
//        tabView.layer.shadowOpacity = 0.3
//        rewardsBtn.tintColor = .black
//        hoemBtn.layer.cornerRadius = 22
//        rewardsBtn.layer.cornerRadius = 22
//        hoemBtn.backgroundColor = selectColor
//        switchToTab(index: 0) // Default to first tab
//    }
//   
//    @IBAction func changeIndex(_ sender: UIButton) {
//        switchToTab(index: sender.tag)
//        rewardsBtn.tintColor = sender.tag != 0 ? .systemBlue : .black
//        hoemBtn.tintColor = sender.tag == 0 ? .systemBlue : .black
//        hoemBtn.backgroundColor = sender.tag == 0 ? .systemGray6 : .clear
//        rewardsBtn.backgroundColor = sender.tag != 0 ? selectColor : .clear
//    }
//    
//    
////    private func switchToTab(index: Int) {
////        let selectedVC: UIViewController
////        switch index {
////        case 0: selectedVC = homeVC
////        case 1: selectedVC = profileVC
////        default: return
////        }
////        
////        for subview in containerView.subviews {
////            subview.removeFromSuperview()
////        }
////        
////        addChild(selectedVC)
////        selectedVC.view.frame = containerView.bounds
////        containerView.addSubview(selectedVC.view)
////        selectedVC.didMove(toParent: self)
////        
////        // Update button colors
////        for (i, button) in customTabBar.arrangedSubviews.enumerated() {
////            (button as? UIButton)?.tintColor = (i == index) ? .blue : .gray
////        }
////    }
//}
