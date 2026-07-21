//
//  IntractwithStudentVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 04/07/25.
//

import UIKit

class IntractwithStudentVc: UIViewController {
    
    @IBOutlet weak var blockStudentBtnName: UIButton!
    @IBOutlet weak var backBtn: UILabel!
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
    var BlockList: [BlockedStudent]?
    var STAFFCHAT = "STAFFCHAT"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupContainerView.isHidden = true
        popupContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        popupView.layer.cornerRadius = 10
        backBtn.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName,
                                      secondLine: StaffDetails?.school_name ?? "")
        blockListDefLbl.text = CommonStringFile.BlockedStudentsList.translated()
        blockStudentBtnName.isHidden = true
        searchBtn.isHidden = true
        searchBar.delegate = self
        searchBar.isHidden = true
        searchBar.searchTextField.addDoneButton()
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = CommonStringFile.Search.translated()
        imgView.isHidden = true
        noDataFoundLbl.isHidden = true
        let nib = UINib(nibName: CellConfingName.interactTvcell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.interactTvcell)
        tv.delegate = self
        tv.dataSource = self
        getStaff()
        blockListTV.register(UINib(nibName: CellConfingName.SubmitedStudentTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.SubmitedStudentTVC)
        blockListTV.delegate = self
        blockListTV.dataSource = self
        
    }
    
    func getStaff(){
        APIService.shared
            .makeApi(url: ServiceUrl.interaction_classes_for_chat , parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false){ [self] (
                result:Result <StaffListResponse,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            getStandardDetails = successMessage.data ?? []
                            filteredData = successMessage.data ?? []
                            searchBtn.isHidden = filteredData?.isEmpty ?? false
                            noDataFoundLbl.isHidden = !(filteredData?.isEmpty ?? true)
                            imgView.isHidden = !(filteredData?.isEmpty ?? true)
                            blockStudentBtnName.isHidden = false
                            searchBtn.isHidden = false
                            tv.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            searchBtn.isHidden = filteredData?.isEmpty ?? false
                            noDataFoundLbl.isHidden = !(filteredData?.isEmpty ?? true)
                            imgView.isHidden = !(filteredData?.isEmpty ?? true)
                            noDataFoundLbl.text = successMessage.message ?? ""
                            blockStudentBtnName.isHidden = true
                            searchBtn.isHidden = true
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { [self] in
                        searchBtn.isHidden = true
                        noDataFoundLbl.isHidden = false
                        noDataFoundLbl.text = error.localizedDescription
                        imgView.isHidden = false
                        blockStudentBtnName.isHidden = true
                        searchBtn.isHidden = true
                    }
                    print(error.localizedDescription)
                }
            }
    }
    
    func get_blockList_Api(){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_interaction_blocked_students, parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false) {[weak self] (result:Result<BlockedStudentsResponse,Error>) in
            
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.BlockList = success.data
                    self.showPopup()
                    self.NodataView.isHidden = !(self.BlockList?.isEmpty ?? false)
                    self.popupNodataLbl.text = success.message
                    self.showPopup()
                    self.blockListTV.reloadData()
    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self) {}
                    self.NodataView.isHidden = false
                    self.popupNodataLbl.text = failure.localizedDescription
                }
            }
        }
    }
    
    func UnBlock_Api(student:BlockedStudent?){
        
        guard let student = student else{return}
        
        let alert = CustomAlert()
        
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.Unblock_this_Student, actionLbl1: AlertstringFile.Yes, actionLbl2: AlertstringFile.Cancel, on: self) {
            
            let param: [String:Any] = [
                ChatAPIKeys.student_id : student.id ?? "",
                ChatAPIKeys.is_block : false,
                ChatAPIKeys.reason : "",
                ChatAPIKeys.class_id : student.class_id ?? "",
                ChatAPIKeys.section_id : student.section_id ?? "",
                ChatAPIKeys.class_name : student.class_name ?? "",
                ChatAPIKeys.section_name : student.section_name ?? "",
            ]
            
            APIService.shared.makeApi(url: ServiceUrl.comm_api_interaction_block_student, parameters: param, type: ApitTypeSringFile.PUT, token: self.StaffDetails?.access_token ?? "", isBaseUrl: true) { [weak self]
                (result: Result<CommonApiSuc,Error>) in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        if success.status == true {
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success.translated(), message: success.message ?? "", on: self) {
                                if var blockList = self.BlockList,
                                   let index = blockList.firstIndex(where: { $0.id == student.id }) {
                                    blockList.remove(at: index)
                                    self.BlockList = blockList
                                    self.blockListTV.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                                    self.NodataView.isHidden = !blockList.isEmpty
                                    self.popupNodataLbl.text = CommonStringFile.No_Blocked_Students.translated()
                                }
                            }
                        }else{
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed.translated(), message: success.message ?? "", on: self) {}
                        }
                        
                    case .failure(let failure):
                        print("Error",failure.localizedDescription)
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed.translated(), message: failure.localizedDescription, on: self) {}
                    }
                }
            }
            
        } onNo: {
            
        }
    }
    
    func readStatusApi(sectionId:String, completion: (()->Void)? = nil){
        
        let param : [String:Any] = [
            ChatAPIKeys.Types : STAFFCHAT,
            ChatAPIKeys.detail_id: sectionId
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: param, type: ApitTypeSringFile.POST, token: StaffDetails?.access_token ?? "", isBaseUrl: true) { [weak self] (result: Result<CommonApiSuc,Error>) in
            
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success.status == true{
                        if let index = self.getStandardDetails?.firstIndex(where: {$0.section_id == sectionId}) {
                            self.getStandardDetails?[index].unread_count = 0
                        }
                        
                        if let filterIndex = self.filteredData?.firstIndex(where: {$0.section_id == sectionId}) {
                            self.filteredData?[filterIndex].unread_count = 0
                                self.tv.reloadRows(at: [IndexPath(row: filterIndex, section: 0)], with: UITableView.RowAnimation.automatic)
                        }
                    }
                    completion?()
                case .failure(let failure):
                    print(failure.localizedDescription)
                    completion?()
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
        searchBar.resignFirstResponder()
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
        
        searchBar.isHidden = !sender.isSelected
        if sender.isSelected {
            searchBar.becomeFirstResponder()
        } else {
            view.endEditing(true)
            searchBar.text = ""
            filteredData = getStandardDetails
            noDataFoundLbl.isHidden = !(filteredData?.isEmpty ?? true)
            imgView.isHidden = !(filteredData?.isEmpty ?? true)
            noDataFoundLbl.text = CommonStringFile.No_data_found.translated()
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
                
                cell.lastMessageLbl.text = (datas.last_msg?.isEmpty == false) ? datas.last_msg : CommonStringFile.No_messages_yet.translated()
                
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
            
            let cell = blockListTV.dequeueReusableCell(withIdentifier: CellConfingName.SubmitedStudentTVC, for: indexPath) as! SubmitedStudentTVC
            
            let student = BlockList?[indexPath.row]
            cell.studentNameLbl.text = student?.name
            if let name = student?.name, name.count >= 2 {
                let initials = name.prefix(2).uppercased()
                cell.initialBtn.setTitle(String(initials), for: .normal)
            }
            cell.standerdScection.text = (student?.class_name ?? "") + " - " + (student?.section_name ?? "")
            cell.reasonLbl.text = CommonStringFile.Reason.translated() + (student?.reason ?? "")
            cell.reasonLbl.isHidden = false
            cell.submitDate.text = CommonStringFile.BlockedOn.translated() + ": " + (student?.blocked_on ?? "")
            cell.statusView.layer.cornerRadius = 10
            cell.statusView.backgroundColor = .backGroundClr
            cell.statusView.tintColor = .backGroundClr
            cell.statusView.setTitleColor(.white, for: .normal)
            cell.statusView.setTitle(CommonStringFile.Unblock.translated(), for: .normal)
            cell.statusView.isUserInteractionEnabled = true
            cell.onBlock = { [weak self] in
                self?.UnBlock_Api(student: student)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tv {
            let datas = filteredData?[indexPath.row]
            guard let data = datas else { return }

            if (data.unread_count ?? 0) > 0 {
                readStatusApi(sectionId: data.section_id ?? "") { [weak self] in
                    guard let self = self else { return }
                    self.openChat(with: data)
                }
            } else {
                openChat(with: data)
            }
        }
    }

    private func openChat(with data: StaffMember) {
        let vc = chatWithStudentVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.staffMembersData = data
        present(vc, animated: true)
    }

}

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
