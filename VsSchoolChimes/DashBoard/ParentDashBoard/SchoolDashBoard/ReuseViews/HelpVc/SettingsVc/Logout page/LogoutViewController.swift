//
//  LogoutViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 06/11/24.
//

import UIKit

class LogoutViewController: UIViewController {
    var demo = "gitdfchgvhbjnkjjhrdtyfgyu"
    var heloo = "laksh"
    
    @IBOutlet weak var DescribeLabel: UILabel!
    @IBOutlet var overallview: UIView!
    @IBOutlet weak var LogoutView: UIView!
    @IBOutlet weak var Cancellabel: UILabel!
    @IBOutlet weak var LogoutButtonView: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DescribeLabel.text = "Are you sure you want to logout?".translated()
        Cancellabel.text = "Cancel".translated()
        
        DescribeLabel.setFont(style: .title, size: FontSize.TitleSize)
        Cancellabel.setFont(style: .body, size: FontSize.BodySize)
//        LogoutButtonView.titleLabel?.text = "Logout".translated()
//        LogoutButtonView.titleLabel?.adjustsFontSizeToFitWidth = true
        LogoutButtonView.setTitle("Logout".translated(), for: .normal)
        LogoutButtonView.titleLabel?.adjustsFontSizeToFitWidth = true
        
        LogoutButtonView.setTitleFont(style: .body, size: 13)


        overallview.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        LogoutView.layer.cornerRadius = Colornames.CORadius10
        //cellview.layer.masksToBounds = true
        LogoutView.layer.shadowColor = UIColor.black.cgColor
        LogoutView.layer.shadowOpacity = 0.5
        LogoutView.layer.shadowOffset = CGSize(width: 4, height: 4)
        LogoutView.layer.shadowRadius = 3
        LogoutView.layer.masksToBounds = false
        
        LogoutButtonView.layer.cornerRadius = Colornames.CORadius15
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CancelAct))
        Cancellabel.addGestureRecognizer(tap)
        Cancellabel.isUserInteractionEnabled = true
    }

    @IBAction func LogoutAct(_ sender: Any) {
        
        if #available(iOS 14.0, *) {
            let vc = LoginVc(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        } else {
            // Fallback on earlier versions
        }
       // dismiss(animated: true)
    }
    
    @objc func CancelAct(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
}
