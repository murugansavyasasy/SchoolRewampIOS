//
//  SettingsViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 26/10/24.
//

import UIKit

class SettingsViewController: UIViewController {
    
    

    @IBOutlet weak var tableview: UITableView!
   
    let sections: [Section] = [
           Section(title: "GENERAL", items: ["Notifications", "FAQ", "Contact Us", "Terms and Conditions"]),
           Section(title: "FEEDBACK", items: ["Report a bug", "Send Feedback", "Logout"])
       ]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableview.dataSource = self
        tableview.delegate = self
     
        
        let nib = UINib(nibName: CellConfingName.SettingsTableViewCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.SettingsTableViewCell)
        
        
        tableview.register(UINib(nibName:CellConfingName.SettingHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.SettingHeaderView)
//        
//        let rateButton = UIButton(type: .system)
//        rateButton.setTitle("Rate Us", for: .normal)
//        rateButton.addTarget(self, action: #selector(showRatingPopup), for: .touchUpInside)
//        view.addSubview(rateButton)

    }

}



@available(iOS 14.0, *)
extension SettingsViewController : UITableViewDelegate , UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
  
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier:CellConfingName.SettingHeaderView) as! SettingHeaderView
        cell.headerLabel.text = sections[section].title
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SettingsTableViewCell, for: indexPath) as! SettingsTableViewCell
        cell.nameLbl.text = sections[indexPath.section].items[indexPath.row]
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if  sections[indexPath.section].items[indexPath.row] == "Contact Us"{
            
            let vc = ContactUsVc(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }else if  sections[indexPath.section].items[indexPath.row] == "Notifications"{
            
            let vc = NotificationViewController(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        }
        else if  sections[indexPath.section].items[indexPath.row] == "Report a bug"{
            
            let vc = ReportBugVcViewController(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        }else if  sections[indexPath.section].items[indexPath.row] == "Send Feedback"{
            
            let ratingVC = RateUsVc(nibName: nil, bundle: nil)
              ratingVC.modalPresentationStyle = .overCurrentContext
              ratingVC.modalTransitionStyle = .crossDissolve
              present(ratingVC, animated: true, completion: nil)
            
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
  
    
    
    
}
struct Section {
    let title: String
    let items: [String]
}

let sections: [Section] = [
    Section(title: "GENERAL", items: ["Notifications", "FAQ", "Contact Us", "Terms and Conditions"]),
    Section(title: "FEEDBACK", items: ["Report a bug", "Send Feedback", "Logout"])
]
