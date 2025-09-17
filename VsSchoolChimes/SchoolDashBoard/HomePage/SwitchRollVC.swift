//
//  SwitchRollVC.swift
//  School Chimes
//
//  Created by Chandhru on 17/09/25.
//

import UIKit

protocol SwitchRollDelegate: AnyObject {
    func switchRoll(userToken: String)
}

class SwitchRollVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userTable: UITableView!
    var staffDetails = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var childDetails = UserDefaultFileManager.getUserDetails()?.user_details?.child_details
    var staffDetail = UserDefaultFileManager.get_staff_Details()
    weak var delegate: SwitchRollDelegate?
    var isStudent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTable.register(UINib(nibName: CellConfingName.SwitchRollTVC, bundle: nil),
                           forCellReuseIdentifier: CellConfingName.SwitchRollTVC)
        userTable.delegate = self
        userTable.dataSource = self
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isStudent ? (childDetails?.count ?? 0) : (staffDetails?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SwitchRollTVC, for: indexPath) as? SwitchRollTVC else {
            return UITableViewCell()
        }
        
        if isStudent {
            let child = childDetails?[indexPath.row]
            cell.nameLbl.text = child?.name
            cell.schoolLbl.text = child?.school_name
            cell.profileImg.kf.setImage(with: URL(string: childDetails?[indexPath.row].profile ?? ""),placeholder: UIImage(systemName: "person.fill"))
            if let accessToken = child?.access_token,
               accessToken == staffDetail?.access_token {
                cell.selectIconBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            } else {
                cell.selectIconBtn.setImage(UIImage(systemName: "circle"), for: .normal)
            }
            
        } else {
            let staff = staffDetails?[indexPath.row]
            cell.nameLbl.text = staff?.name
            cell.schoolLbl.text = staff?.school_name
            cell.profileImg.kf.setImage(with: URL(string: staffDetails?[indexPath.row].staff_profile ?? ""),placeholder: UIImage(systemName: "person.fill"))
            if let accessToken = staff?.access_token,
               accessToken == staffDetail?.access_token {
                cell.selectIconBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                
            } else {
                cell.selectIconBtn.setImage(UIImage(systemName: "circle"), for: .normal)            }
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isStudent {
            if let child = childDetails?[indexPath.row] {
                UserDefaultFileManager.saveChildDetails(data: child)
                delegate?.switchRoll(userToken: child.access_token ?? "")
                dismiss(animated: true)
            }
        } else {
            if let staff = staffDetails?[indexPath.row] {
                UserDefaultFileManager.saveStaffDetails(data: staff)
                delegate?.switchRoll(userToken: staff.access_token ?? "")
                dismiss(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
