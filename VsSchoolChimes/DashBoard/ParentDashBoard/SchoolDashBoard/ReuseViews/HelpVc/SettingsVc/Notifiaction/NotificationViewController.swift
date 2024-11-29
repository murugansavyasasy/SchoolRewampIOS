//
//  NotificationViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 25/10/24.
//

import UIKit

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
 
    @IBOutlet weak var NotificationpageHeader: UILabel!
    
    var name = ["Saranraj","Murugan","Gayathri","Sathish","Lakshmanan","Chandru","Reventh"]
    
    var type = ["Voice Message","Assignment Message","Image Message","Notice Board Message","Homework Message","Attendence Message","Exam Message"]
    var icon = [UIImage(named: "voice"),UIImage(named:"Phone"),UIImage(named: "message"),UIImage(named: "mail")]
    var content = ["Come to school","complete the Asssignment","Draw the Image","Follow the Noticeboard","Complete the Homework","You are absent Today","Chemistry Exam"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationpageHeader.text = "Notifications".translated()
        NotificationpageHeader.setFont(style: .header, size: 20)
        
        tableview.dataSource = self
        tableview.delegate = self
        
        let nib = UINib(nibName: CellConfingName.NotificationTableViewCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier:  CellConfingName.NotificationTableViewCell)
        
    }
    
    
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
        
    }
    
    
    
  
    
}



extension NotificationViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return name.count
        //array.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.NotificationTableViewCell, for: indexPath) as! NotificationTableViewCell
        
        cell.NameLabel.text = name[indexPath.row]
        cell.messageTypeLabel.text = type[indexPath.row % type.count]
        cell.imgview.image = icon[indexPath.row % icon.count]
        cell.contentLabel.text = content[indexPath.row % content.count]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
