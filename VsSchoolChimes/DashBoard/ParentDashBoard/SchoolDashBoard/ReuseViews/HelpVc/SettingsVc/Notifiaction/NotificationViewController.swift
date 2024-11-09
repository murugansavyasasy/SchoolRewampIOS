//
//  NotificationViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 25/10/24.
//

import UIKit

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
 
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return 15
        //array.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.NotificationTableViewCell, for: indexPath) as! NotificationTableViewCell
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
