//
//  SideMenuVC.swift
//  School Chimes
//
//  Created by Chandhru on 01/08/25.
//

import UIKit

protocol SideMenuDelegate: AnyObject {
    func meunu(viewController: UIViewController?)
    func didTapProfileImage(from imageView: UIImageView?)
}

@available(iOS 14.0, *)
class SideMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImgaView: UIImageView!
    @IBOutlet weak var menuTable: UITableView!
    weak var delegate: SideMenuDelegate?
    var isSwitchRoleExpanded = false
    var isStudent:Bool?
    // MARK: - Data
    var menuArray: [MenuItem] = [
        MenuItem(name: "DashBoard".translated(), icon: "house"),
        MenuItem(name: "View Profile".translated(), icon: "person.circle"),
        MenuItem(name: "Settings".translated(), icon: "gear"),
        MenuItem(name: "Help".translated(), icon: "questionmark.circle")
    ]
    
    let staff_roll = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var childCount = UserDefaultFileManager.getUserDetails()?.user_details?.child_details
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var childeDetail = UserDefaultFileManager.get_child_Details()
    let transitionDelegate = TransitioningDelegate()
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if isStudent ?? false{
            userName.text = childeDetail?.name
            setupProfileImage(url: URL(string: childeDetail?.profile ?? ""))
        }else{
            userName.text = staffDetails?.name
            setupProfileImage(url: URL(string: staffDetails?.staff_profile ?? ""))
        }
        menuTable.register(UINib(nibName: "SideTvcell", bundle: nil), forCellReuseIdentifier: "SideTvcell")
        let staffCount = staffDetailsCount?.count ?? 0
        let studentCount = childCount?.count ?? 0
        if (staffCount + studentCount) > 1 {
            menuArray.append(MenuItem(name: "Switch Role".translated(), icon: "arrow.2.squarepath"))
        }

        
        // Exit is always last
        menuArray.append(MenuItem(name: "Logout".translated(), icon: "iphone.and.arrow.forward"))
        
        menuTable.delegate = self
        menuTable.dataSource = self
        menuTable.tableFooterView = UIView() // Removes extra separators
    }
    
    private func setupProfileImage(url:URL?) {
        if let url = url{
            profileImgaView.kf.setImage(with: url,placeholder:UIImage(systemName: "person.circle.fill"))
        }else{
            profileImgaView.image = UIImage(systemName: "person.circle.fill")
        }
       
        profileImgaView.layer.cornerRadius = profileImgaView.frame.width / 2
        profileImgaView.clipsToBounds = true
        profileImgaView.layer.borderWidth = 2
        profileImgaView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        profileImgaView.isUserInteractionEnabled = true
        // 2️⃣ Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        profileImgaView.addGestureRecognizer(tapGesture)
        
    }
    init(isStudent: Bool = false) {
        self.isStudent = isStudent
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        delegate?.didTapProfileImage(from: sender.view as? UIImageView)
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SideTvcell",
//                                                 for: indexPath) as! SideTvcell
//        let item = menuArray[indexPath.row]
//        
//        cell.ExameLbl.text = item.name
//        
//        if let iconName = item.icon {
//            if let systemImage = UIImage(systemName: iconName) {
//                cell.iconBtn.setImage(systemImage, for: .normal)
//            } else {
//                cell.iconBtn.setImage(UIImage(named: iconName), for: .normal)
//            }
//        }
//        
//        if item.name == "Logout".translated() {
//            cell.ExameLbl.textColor = .red
//            cell.iconBtn.tintColor = .red
//        }else{
//            cell.ExameLbl.textColor = .label
//            cell.iconBtn.tintColor = .link
//        }
//        
//        return cell
        
        return UITableViewCell()
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = menuArray[indexPath.row]
        
        switch selectedItem.name {
        case "View Profile".translated():
            delegate?.meunu(viewController: UpdateProfileVC(isStudent: isStudent ?? false))
            
        case "Settings".translated():
            delegate?.meunu(viewController: SettingsViewController())
            
        case "Switch Role".translated():
//            if isSwitchRoleExpanded {
//                // collapse → remove inserted schools
//                menuArray.removeAll { item in
//                    staffDetailsCount?.contains(where: { $0.school_name == item.name }) ?? false
//                }
//                isSwitchRoleExpanded = false
//            } else {
//                // expand → insert schools before Exit
//                for i in 0..<(staffDetailsCount?.count ?? 0) {
//                    let schoolName = staffDetailsCount?[i].school_name ?? "Unknown"
//                    menuArray.insert(MenuItem(name: schoolName, icon: "building.columns"),
//                                     at: menuArray.count - 1)
//                }
//                isSwitchRoleExpanded = true
//            }
//            tableView.reloadData()
            delegate?.meunu(viewController: UIViewController())
            
        case "Help".translated():
            delegate?.meunu(viewController: HelpVc())
            
        case "Logout".translated():
            delegate?.meunu(viewController: LogoutViewController())
            
        default:
//            if let school = staffDetailsCount?.first(where: { $0.school_name == selectedItem.name }) {
//                print("Switched to school: \(school.school_name ?? "")")
//                UserDefaultFileManager.saveStaffDetails(data: school)
//                // Collapse menu after selection
//                menuArray.removeAll { item in
//                    staffDetailsCount?.contains(where: { $0.school_name == item.name }) ?? false
//                }
//                isSwitchRoleExpanded = false
//                tableView.reloadData()
//                delegate?.meunu(viewController: nil)
//            }
            delegate?.meunu(viewController: CustomDasboard())
        }
    }
}
// MARK: - Data Models
struct MenuItem {
    let name: String?
    let icon: String?
}
