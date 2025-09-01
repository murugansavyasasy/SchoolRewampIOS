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
    var isSwitchRoleExpanded = false
    // MARK: - Data
    var menuArray: [MenuItem] = [
        MenuItem(name: "View Profile", icon: "person.circle"),
        MenuItem(name: "Settings", icon: "gear"),
        MenuItem(name: "Help", icon: "questionmark.circle")
    ]
    
    let staff_roll = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTable.register(UINib(nibName: "SideTvcell", bundle: nil), forCellReuseIdentifier: "SideTvcell")
        if checkMutipleSchool() {
            menuArray.append(MenuItem(name: "Switch Role", icon: "arrow.2.squarepath"))
        }
        
        // Exit is always last
        menuArray.append(MenuItem(name: "Exit", icon: "iphone.and.arrow.forward"))
        
        menuTable.delegate = self
        menuTable.dataSource = self
        menuTable.tableFooterView = UIView() // Removes extra separators
    }
    
    func checkMutipleSchool() -> Bool {
        if staffDetailsCount?.count ?? 0 > 1 {
            switch staff_roll {
            case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideTvcell",
                                                 for: indexPath) as! SideTvcell
        let item = menuArray[indexPath.row]
        
        cell.ExameLbl.text = item.name
        
        if let iconName = item.icon {
            if let systemImage = UIImage(systemName: iconName) {
                cell.iconBtn.setImage(systemImage, for: .normal)
            } else {
                cell.iconBtn.setImage(UIImage(named: iconName), for: .normal)
            }
        }
        
        if item.name == "Exit" {
            cell.ExameLbl.textColor = .red
            cell.iconBtn.tintColor = .red
        }else{
            cell.ExameLbl.textColor = .label
            cell.iconBtn.tintColor = .link
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = menuArray[indexPath.row]
        
        switch selectedItem.name {
        case "View Profile":
            delegate?.meunu(viewController: ProfileViewController())
            
        case "Settings":
            delegate?.meunu(viewController: SettingsViewController())
            
        case "Switch Role":
            if isSwitchRoleExpanded {
                // collapse → remove inserted schools
                menuArray.removeAll { item in
                    staffDetailsCount?.contains(where: { $0.school_name == item.name }) ?? false
                }
                isSwitchRoleExpanded = false
            } else {
                // expand → insert schools before Exit
                for i in 0..<(staffDetailsCount?.count ?? 0) {
                    let schoolName = staffDetailsCount?[i].school_name ?? "Unknown"
                    menuArray.insert(MenuItem(name: schoolName, icon: "building.columns"),
                                     at: menuArray.count - 1)
                }
                isSwitchRoleExpanded = true
            }
            tableView.reloadData()
            
        case "Help":
            delegate?.meunu(viewController: HelpVc())
            
        case "Exit":
            // TODO: handle logout / dismiss
            delegate?.meunu(viewController: UIViewController())
            
        default:
            if let school = staffDetailsCount?.first(where: { $0.school_name == selectedItem.name }) {
                print("Switched to school: \(school.school_name ?? "")")
                UserDefaultFileManager.saveStaffDetails(data: school)
                // Collapse menu after selection
                menuArray.removeAll { item in
                    staffDetailsCount?.contains(where: { $0.school_name == item.name }) ?? false
                }
                isSwitchRoleExpanded = false
                tableView.reloadData()
                delegate?.meunu(viewController: nil)
            }
        }
    }
}
// MARK: - Data Models
struct MenuItem {
    let name: String?
    let icon: String?
}
