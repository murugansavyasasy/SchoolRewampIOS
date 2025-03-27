//
//  UpdatePopupVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 26/03/25.
//

import UIKit
protocol ReminderCalback{
    func backToCall()
}
class UpdatePopupVC: UIViewController {

    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var remindMeLater: UIButton!
    @IBOutlet weak var descriptTxt: UITextView!
    @IBOutlet weak var updatedVersionLbl: UILabel!
    @IBOutlet weak var currentVersionLbl: UILabel!
    var reminderCalback:ReminderCalback?
    override func viewDidLoad() {
        super.viewDidLoad()
        remindMeLater.layer.borderWidth = 1
        remindMeLater.layer.borderColor = UIColor.lightGray.cgColor
        ButtonUi(remindMeLater)
        ButtonUi(updateBtn)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 14.0, *) {
            (self.presentingViewController as? SplashViewController)?.overlayView?.removeFromSuperview()
        } 
    }
    func ButtonUi(_ sender:UIButton){
        sender.layer.cornerRadius = 8
        sender.layer.masksToBounds = false
          // Adding shadow for a popped-up effect
        sender.layer.shadowColor = UIColor.black.cgColor
        sender.layer.shadowOffset = CGSize(width: 0, height: 5)
        sender.layer.shadowOpacity = 0.3
        sender.layer.shadowRadius = 6
    }
    @IBAction func later(_ sender: UIButton) {
        dismiss(animated: true){
            self.reminderCalback?.backToCall()
        }
    }
    @IBAction func update(_ sender: UIButton) {
        let myUrl = ""
        if let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        guard let url = URL(string: "\(myUrl)"), !url.absoluteString.isEmpty else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
