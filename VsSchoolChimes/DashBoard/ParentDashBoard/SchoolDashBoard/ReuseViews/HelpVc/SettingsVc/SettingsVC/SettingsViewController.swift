//
//  SettingsViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 26/10/24.
//

import UIKit

@available(iOS 14.0, *)
class SettingsViewController: UIViewController {
    
    

    @IBOutlet weak var tableview: UITableView!
   
    let sections: [Section] = [
           Section(title: "GENERAL", items: ["Notifications", "FAQ", "Contact Us", "Terms and Conditions","Change App Language"]),
           Section(title: "FEEDBACK", items: ["Report a bug", "Send Feedback", "Logout"])
       ]
 
 
    let Images: [Image] = [
        Image(title: "GENERAL", Imageitems: ["bell.fill", "person.crop.circle.badge.questionmark.fill", "phone.arrow.up.right.circle.fill", "chart.line.uptrend.xyaxis","character.bubble.ja"]),
        Image(title: "FEEDBACK", Imageitems: ["questionmark.diamond.fill", "paperplane.fill", "iphone.and.arrow.forward"])
    ]
    
    var imagesArray: [UIImage] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for imageCategory in Images {
           
            for uiImage in imageCategory.uiImages {
                if let image = uiImage {
                    print("Loaded UIImage: \(image)")
                    imagesArray.append(image)
                } else {
                    print("Failed to load UIImage for one of the symbols.")
                }
            }
        }
        tableview.dataSource = self
        tableview.delegate = self
        view.backgroundColor = Colornames.topBackgroundCLr
        tableview.backgroundColor = Colornames.bottomClr
        
       
        let nib = UINib(nibName: CellConfingName.SettingsTableViewCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.SettingsTableViewCell)
        
        
        tableview.register(UINib(nibName:CellConfingName.SettingHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.SettingHeaderView)


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
        
        
        cell.imgView.image = Images[indexPath.section].uiImages[indexPath.row]
        
      
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
            
            let vc = RateUsViewController(nibName: "RateUsViewController", bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        }
        
        
        else if  sections[indexPath.section].items[indexPath.row] == "Logout"{
            
            let vc = LogoutViewController(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
            
        }
        
        else if  sections[indexPath.section].items[indexPath.row] == "FAQ"{
            
            
            let vc = FAQViewController(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
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
    Section(title: "GENERAL", items: ["Notifications", "FAQ", "Contact Us", "Terms and Conditions","Change App Language"]),
    Section(title: "FEEDBACK", items: ["Report a bug", "Send Feedback", "Logout"])
]


struct Image {
    let title: String
    let uiImages: [UIImage?]
    
    // Custom initializer that takes an array of system image names (strings)
    init(title: String, Imageitems: [String]) {
        self.title = title
        // Convert each string in Imageitems to a UIImage
        self.uiImages = Imageitems.map { UIImage(systemName: $0) }
    }
}

let Images: [Image] = [
    Image(title: "GENERAL", Imageitems: ["bell.fill", "person.crop.circle.badge.questionmark.fill", "phone.arrow.up.right.circle.fill", "chart.line.uptrend.xyaxis","character.bubble.ja"]),
    Image(title: "FEEDBACK", Imageitems: ["questionmark.diamond.fill", "paperplane.fill", "iphone.and.arrow.forward"])
]



// Example of accessing UIImages




