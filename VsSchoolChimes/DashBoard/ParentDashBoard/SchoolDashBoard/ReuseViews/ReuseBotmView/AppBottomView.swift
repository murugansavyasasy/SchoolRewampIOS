//
//  AppBottomView.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class AppBottomView: UIView {

    @IBOutlet weak var settingsImageView: UIImageView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var homeView: UIView!
    
    @IBOutlet weak var helpView: UIView!
    let nibName = "AppBottomView"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
        
      
        
        let settingsTap = UITapGestureRecognizer(target: self, action: #selector(settings))
        settingsView.addGestureRecognizer(settingsTap)
        let HomeTap = UITapGestureRecognizer(target: self, action: #selector(HomeVc))
        homeView.addGestureRecognizer(HomeTap)
    }
    
    
    func commonInit() {
    guard let view = loadViewFromNib() else { return }
    view.frame = self.bounds
    self.addSubview(view)
    }


    func loadViewFromNib() -> UIView? {
    let nib = UINib(nibName: nibName, bundle: nil)
    return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    
    func getCurrentViewController() -> UIViewController? {

    if let rootController = UIApplication.shared.keyWindow?.rootViewController {
        var currentController: UIViewController! = rootController
        while( currentController.presentedViewController != nil ) {
            currentController = currentController.presentedViewController
        }
        return currentController
    }
    return nil

    }
    
    @IBAction func settings(){
        settingsImageView.layer.cornerRadius = 10
        settingsImageView.layer.masksToBounds = true
        settingsImageView.backgroundColor = Colornames.ClickClr
        
        let nagivate = self.getCurrentViewController()
        let vc = SettingsViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        nagivate?.present(vc, animated: true)
      
    
    }
    
    @IBAction func HomeVc(){
        let nagivate = self.getCurrentViewController()
        let vc = HomePageVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        nagivate?.present(vc, animated: true)
      
    
    }
    
}





