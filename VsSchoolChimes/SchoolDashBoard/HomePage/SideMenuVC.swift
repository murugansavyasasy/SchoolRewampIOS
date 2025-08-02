//
//  SideMenuVC.swift
//  School Chimes
//
//  Created by Chandhru on 01/08/25.
//

import UIKit
protocol SideMenuDelegate: AnyObject {
    func meunu(viewController: UIViewController?)
}
@available(iOS 14.0, *)
class SideMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet weak var menuTable: UITableView!
    weak var delegate: SideMenuDelegate?
    // MARK: - Data
    var menuArray = [
        MenuItem(name: "View Profile", icon: "person.circle"),
        MenuItem(name: "Settings", icon: "gear"),
        MenuItem(name: "Help", icon: "questionmark.circle"),
        MenuItem(name: "Switch Role", icon: "arrow.2.squarepath")
    ]
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTable.register(UINib(nibName: "SideTvcell", bundle: nil), forCellReuseIdentifier: "SideTvcell")
        menuTable.delegate = self
        menuTable.dataSource = self
        menuTable.tableFooterView = UIView() // Removes extra separators
    }
  
    // MARK: - Actions
    @IBAction func hideSideMenu(_ sender: UIButton) {
        
//        delegate?.hideSideMenu()
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideTvcell", for: indexPath) as! SideTvcell
        let item = menuArray[indexPath.row]
        cell.ExameLbl.text = item.name
        cell.iconBtn.setImage(UIImage(systemName: item.icon ?? ""), for: .normal)
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch menuArray[indexPath.row].name{
        case "View Profile":
            delegate?.meunu(viewController:ProfileViewController())
        case "Settings":
            delegate?.meunu(viewController:SettingsViewController())
        case "Help":
            delegate?.meunu(viewController:HelpVc())
        default:
            delegate?.meunu(viewController:UIViewController())
        }
    }
}

// MARK: - Data Models
struct MenuItem {
    let name: String?
    let icon: String?
}

