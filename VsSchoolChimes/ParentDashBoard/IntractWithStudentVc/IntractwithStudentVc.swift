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
    @IBOutlet weak var blockListTV: UITableView!
    @IBOutlet weak var blockListDefLbl: UILabel!
    @IBOutlet weak var popupContainerView: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var NodataView: UIView!
    @IBOutlet weak var popupNodataLbl: UILabel!
    
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var getStandardDetails:[StaffMember]?
    var filteredData:[StaffMember]?
    var isSearching = false
    var BlockList: [BlockedStudent]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupContainerView.isHidden = true
        popupContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        popupView.layer.cornerRadius = 10
        
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
        
        blockListTV.register(UINib(nibName: "SubmitedStudentTVC", bundle: nil), forCellReuseIdentifier: "SubmitedStudentTVC")
        blockListTV.delegate = self
        blockListTV.dataSource = self
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
    
    func get_blockList_Api(){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_interaction_blocked_students, parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "") {[weak self] (result:Result<BlockedStudentsResponse,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    
                    self.BlockList = success.data
                    
                    if self.BlockList?.isEmpty == true{
                        CustomAlert.showAlertWithOkAction(title: "No Data", message: success.message ?? "", on: self) {}
                        self.NodataView.isHidden = false
                        self.popupNodataLbl.text = success.message
                    }else{
                        self.NodataView.isHidden = true
                        self.showPopup()
                        self.blockListTV.reloadData()
                    }
                    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self) {}
                    self.NodataView.isHidden = false
                    self.popupNodataLbl.text = failure.localizedDescription
                }
            }
        }
    }
    
    func UnBlock_Api(id:String){
        
        let alert = CustomAlert()
        
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: "Are you sure want to Unblock this Student?", actionLbl1: "Yes", actionLbl2: AlertstringFile.Cancel, on: self) {
            
            let param: [String:Any] = [
                "student_id" : id,
                "is_block" : false,
                "reason" : ""
            ]
            
            APIService.shared.makeApi(url: ServiceUrl.comm_api_interaction_block_student, parameters: param, type: ApitTypeSringFile.PUT, token: self.StaffDetails?.access_token ?? "") { [weak self]
                (result: Result<CommonApiSuc,Error>) in
                
                guard let self = self else {return}
                
                DispatchQueue.main.async {
                    
                    switch result {
                    case .success(let success):
                        
                        if success.status == true {
                            
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: success.message ?? "", on: self) {
                                
                                if var blockList = self.BlockList,
                                   let index = blockList.firstIndex(where: { $0.id == id }) {
                                    blockList.remove(at: index)
                                    self.BlockList = blockList
                                    self.blockListTV.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                                }
                            }
                        }else{
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self) {}
                        }
                        
                    case .failure(let failure):
                        
                        print("Error",failure.localizedDescription)
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self) {}
                    }
                }
            }
            
        } onNo: {
            
        }
    }
    
    func readStatusApi(sectionId:String,index:Int){
        
        let param : [String:Any] = [
            "type" : "STAFFCHAT",
            "detail_id" : sectionId
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: param, type: ApitTypeSringFile.POST, token: StaffDetails?.access_token ?? "") { [weak self] (result: Result<CommonApiSuc,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                   
                    if success.status == true{
                        
                        if let index = self.getStandardDetails?.firstIndex(where: {$0.section_id == sectionId}) {
                            
                            self.getStandardDetails?[index].unread_count = 0
                            if self.isSearching == false{
                                self.tv.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.automatic)
                            }
                        }
                        
                        if let filterIndex = self.filteredData?.firstIndex(where: {$0.section_id == sectionId}) {
                            self.filteredData?[filterIndex].unread_count = 0
                            if self.isSearching{
                                self.tv.reloadRows(at: [IndexPath(row: filterIndex, section: 0)], with: UITableView.RowAnimation.automatic)
                            }
                        }
                    }
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func blockListAct(_ sender: Any) {
        
        get_blockList_Api()
    }
    
    @IBAction func popupDismissAct(_ sender: Any) {
        
        hidePopup()
    }
    
    func showPopup() {
        popupContainerView.alpha = 0
        popupContainerView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.popupContainerView.alpha = 1
        }
    }

    func hidePopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popupContainerView.alpha = 0
        }) { _ in
            self.popupContainerView.isHidden = true
        }
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
        if tableView == tv {
            return filteredData?.count ?? 0
        }else{
            return BlockList?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tv {
            
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
        }else {
            
            let cell = blockListTV.dequeueReusableCell(withIdentifier: "SubmitedStudentTVC", for: indexPath) as! SubmitedStudentTVC
            
            let student = BlockList?[indexPath.row]
            
            cell.studentNameLbl.text = student?.name
            if let letter = student?.name?.first{
                cell.initialBtn.setTitle(String(letter).uppercased(), for: .normal)
            }
            
            cell.submitDate.text = "Blocked on: " + (student?.blocked_on ?? "")
            cell.statusView.layer.cornerRadius = 10
            cell.statusView.backgroundColor = .systemBlue
            cell.statusView.setTitleColor(.white, for: .normal)
            cell.statusView.setTitle("Unblock", for: .normal)
            cell.onBlock = { [weak self] in
                self?.UnBlock_Api(id: student?.id ?? "")
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tv{
            
            let datas = isSearching ? filteredData?[indexPath.row] : getStandardDetails?[indexPath.row]
            
            if (datas?.unread_count ?? 0) > 0{
                readStatusApi(sectionId: datas?.section_id ?? "", index: indexPath.row)
            }
            
            let vc = chatWithStudentVc(nibName: nil, bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            if let data = datas{
                vc.staffMembersData =  data
            }
            present(vc, animated: true)
        }
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
}
