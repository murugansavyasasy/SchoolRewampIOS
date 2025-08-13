//
//  NotificationViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 25/10/24.
//

import UIKit

@available(iOS 14.0, *)
class NotificationViewController: UIViewController {
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    
    var name = ["Saranraj","Murugan","Gayathri","Sathish","Lakshmanan","Chandru","Reventh"]
    
    var type = ["Voice Message","Assignment Message","Image Message","Notice Board Message","Homework Message","Attendence Message","Exam Message"]
    var icon = [UIImage(named: "voice"),UIImage(named:"Phone"),UIImage(named: "message"),UIImage(named: "mail")]
    var content = ["Come to school","complete the Asssignment","Draw the Image","Follow the Noticeboard","Complete the Homework","You are absent Today","Chemistry Exam"]
    let MenuRedirect = MenuRedirectHandler.shared
    var passValue = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackBtn.setTitle(MenuTapbar.Notifications.translated(), for: .normal)
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        
        BackBtn.setTitleFont(style: .primary, size:FontSize.HeaderSize)
        
        searchbar.delegate = self
        searchbar.addDoneButton()
        
       
        
        let nib = UINib(nibName: "NotificationsTvCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier:  "NotificationsTvCell")
        let nib1 = UINib(nibName: "NotiTvheader", bundle: nil)
        tableview
            .register(
                nib1,
                forHeaderFooterViewReuseIdentifier: "NotiTvheader"
            )
        
        tableview.dataSource = self
        tableview.delegate = self
    }
    
//    override func viewDidLayoutSubviews() {
//        if passValue == 1{
//            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
//            outerView.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
//        }else{
//            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
//            outerView.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
//        }
//    }
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
}


@available(iOS 14.0, *)
extension NotificationViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
             return name.count
         }
    
     
      func tableView(_ tableView: UITableView,
                     viewForHeaderInSection section: Int) -> UIView? {
          guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NotiTvheader") as? NotiTvheader else { return nil }
         
          
          return header
      }

     func tableView(_ tableView: UITableView,
                    heightForHeaderInSection section: Int) -> CGFloat {
         return 60
     }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return name.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsTvCell", for: indexPath) as! NotificationsTvCell
      
//        cell.NameLabel.text = name[indexPath.row]
//        cell.messageTypeLabel.text = type[indexPath.row % type.count]
//        cell.imgview.image = icon[indexPath.row % icon.count]
//        cell.contentLabel.text = content[indexPath.row % content.count]
//        let firstletter = name[indexPath.row].first ?? "A"
//        
//        if let letterColor = ColorManager.shared.letterColors[firstletter] {
//            cell.ProfileLbl.backgroundColor = letterColor
//        }
//
//        cell.ProfileLbl.text = String(firstletter)
//        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        MenuRedirect.receiverEvent(from: self)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

@available(iOS 14.0, *)
extension NotificationViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchbar.resignFirstResponder()
    }
    
}

