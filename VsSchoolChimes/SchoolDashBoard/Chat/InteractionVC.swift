//
//  InteractionVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/01/25.
//

import UIKit

class InteractionVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var FullView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var noDatimgView: UIImageView!
    @IBOutlet weak var noDataFoundLbl: UILabel!
    var passvalue = 0
    var staffMembersData: [StaffMember]?
    var filterData: [StaffMember]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        searchBar.searchTextField.addDoneButton()
        backBtn.applyBackButton()
        FullView.layer.cornerRadius = 30
        FullView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        FullView.layer.masksToBounds = true
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        let name = studentDetails?.name ?? ""
        let standard = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")
        backBtn.configureAsBackButton(firstLine: name, secondLine: standard)
        let nib = UINib(nibName: CellConfingName.interactTvcell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.interactTvcell)
        tv.delegate = self
        tv.dataSource = self
        searchBar.delegate = self
        getStaff()
        
    }
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        searchBtn.setImage(UIImage(systemName: icon), for: .normal)
        
        searchBar.isHidden = !sender.isSelected
        if sender.isSelected {
            searchBar.becomeFirstResponder()
        } else {
            view.endEditing(true)
            searchBar.text = ""
            filterData = staffMembersData
            noDataFoundLbl.isHidden = !(filterData?.isEmpty ?? true)
            noDatimgView.isHidden = !(filterData?.isEmpty ?? true)
            noDataFoundLbl.text = CommonStringFile.No_data_found
            tv.reloadData()
        }
    }
    
    @IBAction func backBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
 
}

extension InteractionVC : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.interactTvcell,
            for: indexPath
        ) as? interactTvcell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        if let datas = filterData?[indexPath.row] {
            cell.nameLbl.text = datas.name ?? ""
            cell.subjectLbl.text = datas.subject_name ?? ""
            
            // Unread count handling
            let unreadCount = datas.unread_count ?? 0
            cell.unReadCountBtn.isHidden = unreadCount == 0
            cell.unReadCountBtn.setTitle("\(unreadCount)", for: .normal)
            cell.lastMessageLbl.text = (datas.last_msg?.isEmpty == false) ? datas.last_msg : "No messages yet"
            // Last update time
            if let submittedDate = datas.last_msg_time?.chatTimeDisplay() {
                let (timeAgo, _) = submittedDate
                cell.lastUpdateTimeLbl.text = timeAgo
                cell.lastUpdateTimeLbl.isHidden = timeAgo == "Invalid time"
                cell.iconBtn.isHidden = timeAgo == "Invalid time"
            } else {
                cell.lastUpdateTimeLbl.isHidden = true
                cell.iconBtn.isHidden = true
            }
            
            cell.userImg.isHidden = datas.profile?.isEmpty ?? true
            cell.userBtn.isHidden = !cell.userImg.isHidden
            if let name = datas.name, !name.isEmpty {
                let firstTwo = String(name.prefix(2)).uppercased()
                cell.userBtn.setTitle(firstTwo, for: .normal)
            } else {
                cell.userBtn.setTitle("-", for: .normal) // fallback if empty
            }
        }
        return cell
        
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
        let vc = ChatVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        if let datas = filterData?[indexPath.row]{
            vc.staffMembersData = datas
        }
       
        // vc.getValue = getValue
        present(vc, animated: true)
        
        
    }
    

    func getStaff(){
        APIService.shared
            .makeApi(url: ServiceUrl.interaction_staff_details_for_chat , parameters: [:], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? ""){ [self] (
                result:Result <StaffListResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            staffMembersData = successMessage.data ?? []
                            filterData = successMessage.data ?? []
                            noDatimgView.isHidden = !(filterData?.isEmpty ?? false)
                            noDataFoundLbl.isHidden = !(filterData?.isEmpty ?? false)
                            tv.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            staffMembersData = successMessage.data ?? []
                            filterData = successMessage.data ?? []
                            noDatimgView.isHidden = !(filterData?.isEmpty ?? false)
                            noDataFoundLbl.isHidden = !(filterData?.isEmpty ?? false)
                            tv.reloadData()
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
}
extension InteractionVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filterData = staffMembersData
        } else {
            filterData = staffMembersData?.filter {
                $0.subject_name?.localizedCaseInsensitiveContains(searchText) == true ||
                $0.name?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        noDataFoundLbl.isHidden = !(filterData?.isEmpty ?? true)
        noDatimgView.isHidden = !(filterData?.isEmpty ?? true)
        tv.reloadData()
    }
}
