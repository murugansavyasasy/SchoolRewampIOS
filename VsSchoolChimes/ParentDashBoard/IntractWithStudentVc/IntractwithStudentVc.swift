//
//  IntractwithStudentVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 04/07/25.
//

import UIKit

class IntractwithStudentVc: UIViewController {
    
    @IBOutlet weak var backBtn: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var noDataFoundLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var searchBtn: UIButton!
    
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var getStandardDetails:[StaffMember]?
    var filteredData:[StaffMember]?
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backBtn.configureAsBackTitle(firstLine: " Intract With Student",
                                      secondLine: StaffDetails?.school_name ?? "")
        
        let nib = UINib(nibName: CellConfingName.interactTvcell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.interactTvcell)
        tv.delegate = self
        tv.dataSource = self
        searchBar.delegate = self
        searchBar.barTintColor = .white
        searchBar.searchTextField.backgroundColor = .white
        getStaff()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        searchBtn.setImage(UIImage(systemName: icon), for: .normal)
        
        searchView.isHidden = !sender.isSelected
        if sender.isSelected {
            searchBar.becomeFirstResponder()
        } else {
            view.endEditing(true)
            searchBar.text = ""
            filteredData = getStandardDetails
            noDataFoundLbl.isHidden = !(filteredData?.isEmpty ?? true)
            imgView.isHidden = !(filteredData?.isEmpty ?? true)
            noDataFoundLbl.text = CommonStringFile.No_data_found
            tv.reloadData()
        }
    }
}

extension IntractwithStudentVc:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.interactTvcell,
            for: indexPath
        ) as? interactTvcell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        let datas = filteredData?[indexPath.row]
        
        if let datas = datas {
            cell.nameLbl.text = datas.subject_name ?? ""
            cell.subjectLbl.text = "Class - \(datas.name ?? "") (\(datas.section_name ?? ""))"
            
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
            
            cell.userImg.image = UIImage(systemName: "person.3.sequence.fill")
            cell.userImg.isHidden = true
            cell.userBtn.isHidden = false
            if let name = datas.subject_name, !name.isEmpty {
                let firstTwo = String(name.prefix(2)).uppercased()
                cell.userBtn.setTitle(firstTwo, for: .normal)
            } else {
                cell.userBtn.setTitle("-", for: .normal) // fallback if empty
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = chatWithStudentVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        let datas = isSearching ? filteredData?[indexPath.row] : getStandardDetails?[indexPath.row]
        if let data = datas{
            vc.staffMembersData =  data
        }
        
        present(vc, animated: true)
    }
}

// ✅ UISearchBar Delegate
extension IntractwithStudentVc: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredData = getStandardDetails
        } else {
            filteredData = getStandardDetails?.filter {
                $0.subject_name?.localizedCaseInsensitiveContains(searchText) == true ||
                $0.name?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        noDataFoundLbl.isHidden = !(filteredData?.isEmpty ?? true)
        imgView.isHidden = !(filteredData?.isEmpty ?? true)
        tv.reloadData()
    }
    func getStaff(){
        APIService.shared
            .makeApi(url: ServiceUrl.interaction_classes_for_chat , parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? ""){ [self] (
                result:Result <StaffListResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            getStandardDetails = successMessage.data ?? []
                            filteredData = successMessage.data ?? []
                            searchView.isHidden = (successMessage.status ?? true)
                            noDataFoundLbl.isHidden = !(filteredData?.isEmpty ?? true)
                            imgView.isHidden = !(filteredData?.isEmpty ?? true)
                            tv.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            searchView.isHidden = (successMessage.status ?? false)
                            noDataFoundLbl.isHidden = !(filteredData?.isEmpty ?? true)
                            imgView.isHidden = !(filteredData?.isEmpty ?? true)
                            noDataFoundLbl.text = successMessage.message ?? ""
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [self] in
                        searchView.isHidden = true
                        noDataFoundLbl.isHidden = false
                        noDataFoundLbl.text = error.localizedDescription
                        imgView.isHidden = false
                    }
                    print(error.localizedDescription)
                }
            }
    }
}
