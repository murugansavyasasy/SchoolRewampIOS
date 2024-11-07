//
//  LogoutViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 06/11/24.
//

import UIKit

class LogoutViewController: UIViewController {

    @IBOutlet var overallview: UIView!
    @IBOutlet weak var LogoutView: UIView!
    @IBOutlet weak var Cancellabel: UILabel!
    @IBOutlet weak var LogoutButtonView: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        overallview.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        LogoutView.layer.cornerRadius = 10
        //cellview.layer.masksToBounds = true
        LogoutView.layer.shadowColor = UIColor.black.cgColor
        LogoutView.layer.shadowOpacity = 0.5
        LogoutView.layer.shadowOffset = CGSize(width: 4, height: 4)
        LogoutView.layer.shadowRadius = 3
        LogoutView.layer.masksToBounds = false
        
        LogoutButtonView.layer.cornerRadius = 15
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CancelAct))
        Cancellabel.addGestureRecognizer(tap)
        Cancellabel.isUserInteractionEnabled = true
    }

    @IBAction func LogoutAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @objc func CancelAct(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
}
