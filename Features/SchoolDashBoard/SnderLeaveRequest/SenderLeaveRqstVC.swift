//
//  SenderLeaveRqstVC.swift
//  VsSchoolChimes
//
//  Created by admin on 24/12/24.

import UIKit
protocol ConfirmDelegate{
    func confirm(index:Int,status:Bool)
}
@available(iOS 14.0, *)
class SenderLeaveRqstVC: UIViewController, EditDeleteDelegate, approvalAndReject, SelectedId {
    
    func StaffUpdate(index: IndexPath) {
        let studentId = filteredLeaveRecords?[index.section].details?[index.row].id
        let message = AlertstringFile.toapprovethisleaverequest
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: message,
                              actionLbl1: AlertstringFile.OK,
                              actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
            self.Leave_Update_status(id: studentId ?? "", status: true,indexPath: index)
        }, onNo: {})
    }
    
    func StaffRejectUpdate(index: IndexPath) {
        let studentId = filteredLeaveRecords?[index.section].details?[index.row].id
        let message = AlertstringFile.toRejectthisleaverequest
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: message,
                              actionLbl1: AlertstringFile.OK,
                              actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
            
            self.Leave_Update_status(id: studentId ?? "", status: false,indexPath: index)
        }, onNo: {})
    }
    
   
    func selectId(id: String?, edit: Bool?) {
        guard let id = id else { return }

        for (sectionIndex, month) in filteredLeaveRecords?.enumerated() ?? [].enumerated() {
            if let rowIndex = month.details?.firstIndex(where: { $0.id == id }) {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)

                if edit == true {
                    self.edit(edit: indexPath, delete: nil)
                } else {
                    self.edit(edit: nil, delete: indexPath)
                }
                return
            }
        }
    }
   
    
    func edit(edit: IndexPath?, delete: IndexPath?) {
        
        if let editIndexPath = edit {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                let leave = self.filteredLeaveRecords?[editIndexPath.section].details?[editIndexPath.row]
                guard let leave = leave else { return }
                
                let vc = ApplyLeaveReqVC(nibName: nil, bundle: nil)
                
                vc.editLeaveData = editLeaves(
                    id: leave.id,
                    fromDate: leave.from_date ?? "",
                    toDate: leave.to_date ?? "",
                    reson: leave.reason ?? "",
                    fromSession: leave.from_session ?? "",
                    Tosession: leave.to_session ?? "",
                    NoOfDays: leave.no_of_days ?? "",
                    LeaveType: leave.leave_type ?? "",
                    LeaveTypeId: Int(leave.leave_type_id?.value ?? "0") ?? 0)
                
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }
        }
        
        if let deleteIndexPath = delete {
            if let idToDelete = filteredLeaveRecords?[deleteIndexPath.section].details?[deleteIndexPath.row].id {
                deleteLeave(id: idToDelete, indexPath: deleteIndexPath)
            }
        }
    }
    
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var leaveRequestTable: UITableView!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NodateLbl: UILabel!
    @IBOutlet weak var filterBtnStack: UIStackView!
    @IBOutlet weak var approvedBtn: UIButton!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var rejectedBtn: UIButton!
    @IBOutlet weak var waitingBtn: UIButton!
    @IBOutlet weak var menuNameLbl: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var allLeaveRecords: [LeaveMonth]?
    var filteredLeaveRecords: [LeaveMonth]?
    var selectedStatus: String? = nil
    var searchQuery: String = ""
    let alert = CustomAlert()
    var selectedFilter: LeaveFilterType = .all
    var searchText: String = ""
    var pushnotificationMsg_id : String?
    let member_type = "STAFF"
    let leave_type = ["Approved","Rejected","Waiting for approval"]
    var isStaff  : Bool = false
    var isPrincipal  : Bool = false
    var staffId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TopView.layer.cornerRadius = 20
        TopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        menuNameLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName, secondLine: StaffDetails?.school_name ?? "")
        allBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        approvedBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        rejectedBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        waitingBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        addUnderline(to: allBtn, unSelectedBtn: [approvedBtn,rejectedBtn,waitingBtn])
        searchBar.isHidden = true
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.searchTextField.addDoneButton()
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        NodateLbl.isHidden = true
        NodataImage.isHidden = true
        leaveRequestTable.showsVerticalScrollIndicator = false
        leaveRequestTable.showsHorizontalScrollIndicator = false
        leaveRequestTable.register(UINib(nibName: CellConfingName.LeveHistoryTV, bundle: nil), forCellReuseIdentifier: CellConfingName.LeveHistoryTV)
        leaveRequestTable.register(UINib(nibName: "StaffLeaveReqTvCell", bundle: nil), forCellReuseIdentifier: "StaffLeaveReqTvCell")
        leaveRequestTable.delegate = self
        leaveRequestTable.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isStaff || isPrincipal{
           GetStaffLeaveRequest()
        }else{
            GetLeaveRequestAPI()
        }
    }
    
    func addUnderline(to selectedButton: UIButton, unSelectedBtn: [UIButton]) {
        ([selectedButton] + unSelectedBtn).forEach { button in
            button.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
            button.tintColor = .black
        }
        selectedButton.tintColor = .backGroundClr
        let underline = UIView()
        underline.tag = 999
        underline.backgroundColor = .backGroundClr
        underline.translatesAutoresizingMaskIntoConstraints = false
        selectedButton.addSubview(underline)
        
        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: selectedButton.bottomAnchor)
        ])
    }
    
    //MARK: Get Leave Requests API call
    func GetLeaveRequestAPI() {
        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_list, parameters: [LeaveRequestStringFile.member_type: member_type], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false) {[self] (result: Result<LeaveInfoResponse,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    allLeaveRecords = Success.data
                    filteredLeaveRecords = allLeaveRecords
                    NodateLbl.text = Success.message
                    NodataImage.isHidden = !(allLeaveRecords?.isEmpty ?? false)
                    NodateLbl.isHidden = !(allLeaveRecords?.isEmpty ?? false)
                    searchBtn.isHidden = allLeaveRecords?.isEmpty ?? false
                    filterBtnStack.isHidden = !(Success.status ?? true)
                    leaveRequestTable.reloadData()
                    if self.pushnotificationMsg_id != ""{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.scrollToLeave(with: self.pushnotificationMsg_id ?? "")
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    NodateLbl.text = error.localizedDescription
                    NodataImage.isHidden = false
                    NodateLbl.isHidden = false
                    searchBtn.isHidden = true
                    print("Error: ",error.localizedDescription)
                }
            }
        }
    }
    
    
    func GetStaffLeaveRequest() {
        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_list_staff, parameters: ["staff_id":""], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false) {[self] (result: Result<LeaveInfoResponse,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    allLeaveRecords = Success.data
                    filteredLeaveRecords = allLeaveRecords
                    NodateLbl.text = Success.message
                    NodataImage.isHidden = !(allLeaveRecords?.isEmpty ?? false)
                    NodateLbl.isHidden = !(allLeaveRecords?.isEmpty ?? false)
                    searchBtn.isHidden = allLeaveRecords?.isEmpty ?? false
                    filterBtnStack.isHidden = !(Success.status ?? true)
                    leaveRequestTable.reloadData()
                    if self.pushnotificationMsg_id != ""{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.scrollToLeave(with: self.pushnotificationMsg_id ?? "")
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    NodateLbl.text = error.localizedDescription
                    NodataImage.isHidden = false
                    NodateLbl.isHidden = false
                    searchBtn.isHidden = true
                    print("Error: ",error.localizedDescription)
                }
            }
        }
    }
    
    private func scrollToLeave(with id: String) {
        guard let data = filteredLeaveRecords else { return }
        for (sectionIndex, month) in data.enumerated() {
            if let rowIndex = month.details?.firstIndex(where: { $0.id == id }) {
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                leaveRequestTable.scrollToRow(at: indexPath, at: .middle, animated: true)
                highlightCell(at: indexPath)
                return
            }
        }
    }
    
    
    private func highlightCell(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let cell = self.leaveRequestTable.cellForRow(at: indexPath) {
                cell.contentView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.4)
                UIView.animate(withDuration: 0.5, delay: 1.0) {
                    cell.contentView.backgroundColor = .white
                }
            }
        }
    }
    
    
    //MARK: update staus Api call
    func Leave_Update_status(id: String, status: Bool,indexPath: IndexPath) {
        let param: [String: Any] = [
            LeaveRequestStringFile.id: id,
            LeaveRequestStringFile.is_approve: status
        ]
        APIService.shared.makeApi(
            url: isPrincipal ? ServiceUrl.comm_api_leave_req_update_status_Staff:ServiceUrl.comm_api_leave_req_update_status,
            parameters: param,
            type: ApitTypeSringFile.PUT,
            token: StaffDetails?.access_token ?? "", isBaseUrl: true
        ) { [weak self] (result: Result<CommonApiSuc, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success.status == true {
                        let title = AlertstringFile.Success
                        let message = success.message ?? ""
                        let newStatus = status ? self.leave_type[0] : self.leave_type[1]
                        // Format current date for updated_on
                        let formatter = DateFormatter()
                        formatter.dateFormat = DateInputs.ddMMMyyyyhhmma
                        let formattedDate = formatter.string(from: Date())
                        // ✅ Update SearchLeavetData
                        self.filteredLeaveRecords?[indexPath.section].details?[indexPath.row].status = newStatus
                        self.filteredLeaveRecords?[indexPath.section].details?[indexPath.row].updated_on = formattedDate
                        // ✅ Update LeaveRequestData (original)
                        if let idToUpdate = self.filteredLeaveRecords?[indexPath.section].details?[indexPath.row].id,
                           let sectionIndex = self.allLeaveRecords?.firstIndex(where: {
                               $0.details?.contains(where: { $0.id == idToUpdate }) == true
                           }),
                           let rowIndex = self.allLeaveRecords?[sectionIndex].details?.firstIndex(where: {
                               $0.id == idToUpdate
                           }) {
                            
                            self.allLeaveRecords?[sectionIndex].details?[rowIndex].status = newStatus
                            self.allLeaveRecords?[sectionIndex].details?[rowIndex].updated_on = formattedDate
                        }
                        // ✅ Reload updated row in table
                        self.leaveRequestTable.reloadRows(at: [indexPath], with: .automatic)
                        // ✅ Show confirmation
                        CustomAlert.showAlertWithOkAction(title: title, message: message, on: self) {}
                    } else {
                        self.alert.showAlert(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                    
                case .failure(let error):
                    self.alert.showAlert(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                }
            }
        }
    }
    
    
    func deleteLeave(id: String, indexPath: IndexPath) {
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
            self.alert.showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.deletemessage,
                                       actionLbl1: AlertstringFile.delete, actionLbl2: AlertstringFile.Cancel, on: self,
                                       onOk: {
                
                APIService.shared.makeApi(
                    url: ServiceUrl.comm_api_leave_req_for_staff_delete,
                    parameters: ["id": id],
                    type: ApitTypeSringFile.PUT,
                    token: self.StaffDetails?.access_token ?? "",
                    isBaseUrl: true
                ) { [weak self] (result: Result<CommonApiSuc, Error>) in
                        
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let success):
                            if success.status == true {
                                CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success,
                                                                  message: success.message ?? "", on: self) {
                                    
                                    // Remove from originalData
                                    if let originalSectionIndex = self.allLeaveRecords?.firstIndex(where: { $0.month == self.filteredLeaveRecords?[indexPath.section].month }),
                                       let originalRowIndex = self.allLeaveRecords?[originalSectionIndex].details?.firstIndex(where: { $0.id == id }) {
                                        self.allLeaveRecords?[originalSectionIndex].details?.remove(at: originalRowIndex)
                                        
                                        // Remove entire section if empty
                                        if self.allLeaveRecords?[originalSectionIndex].details?.isEmpty ?? false {
                                            self.allLeaveRecords?.remove(at: originalSectionIndex)
                                        }
                                    }
                                    
                                    // Remove from filteredData
                                    self.filteredLeaveRecords?[indexPath.section].details?.remove(at: indexPath.row)
                                    if self.filteredLeaveRecords?[indexPath.section].details?.isEmpty ?? false {
                                        self.filteredLeaveRecords?.remove(at: indexPath.section)
                                    }
                                    
                                    self.leaveRequestTable.reloadData()
                                }
                            } else {
                                self.alert.showAlert(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                            }
                            
                        case .failure(let error):
                            self.alert.showAlert(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                        }
                    }
                }
            }, onNo: {
                print("User canceled deletion")
            })
        }
    }
    //MARK: Button actions
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func searchBtnAct(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected{
            searchBar.isHidden = false
            DispatchQueue.main.async {
                self.searchBar.becomeFirstResponder()
            }
            sender.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else {
            searchBar.isHidden = true
            searchBar.resignFirstResponder()
            searchBar.searchTextField.text = ""
            searchText = ""
            sender.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            applyFilter()
        }
    }
    
    @IBAction func allBtnAct(_ sender: Any) {
        addUnderline(to: allBtn, unSelectedBtn: [approvedBtn,rejectedBtn,waitingBtn])
        selectedStatus = nil
        selectedFilter = .all
        applyFilter()
    }
    
    @IBAction func approvedBtnAct(_ sender: Any) {
        addUnderline(to: approvedBtn, unSelectedBtn: [allBtn,rejectedBtn,waitingBtn])
        selectedStatus = leave_type[0]
        selectedFilter = .approved
        applyFilter()
    }
    
    @IBAction func rejectedBtnAct(_ sender: Any) {
        addUnderline(to: rejectedBtn, unSelectedBtn: [allBtn,approvedBtn,waitingBtn])
        selectedStatus = leave_type[1]
        selectedFilter = .rejected
        applyFilter()
    }
    @IBAction func waitingBtnAct(_ sender: Any) {
        addUnderline(to: waitingBtn, unSelectedBtn: [allBtn,rejectedBtn,approvedBtn])
        selectedStatus = leave_type[2]
        selectedFilter = .waiting
        applyFilter()
    }
}

//MARK: Tableview Delegate Functions
@available(iOS 14.0, *)
extension SenderLeaveRqstVC : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return filteredLeaveRecords?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .clear  // Customize color
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFont(style: .title, size: FontSize.TitleSize)
        label.textColor = .darkGray
        label.text = filteredLeaveRecords?[section].month
        headerView.addSubview(label)
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0)])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
            return filteredLeaveRecords?[section].details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isStaff || isPrincipal{
            guard let  cell = leaveRequestTable.dequeueReusableCell(withIdentifier: "StaffLeaveReqTvCell", for: indexPath) as? StaffLeaveReqTvCell else { return UITableViewCell() }
            
            guard let leaveData = filteredLeaveRecords?[indexPath.section].details?[indexPath.row] else { return cell }
            
            cell.nameLbl.text = leaveData.staff_name
            cell.nameProfileLbl.text = shortName(from: leaveData.staff_name ?? "")
//            cell.nameLbl.numberOfLines = 1
            cell.priorityLbl.text = leaveData.role
            let fromdate = leaveData.from_date ?? ""
            let formformatted = formatDate(fromdate)
            cell.staringDateLbl.text = formformatted
            let todate = leaveData.to_date ?? ""
            let toformatted = formatDate(todate)
            cell.EnddateLbl.text = toformatted
            cell.leaveReasonLbl.text = leaveData.reason
//            cell.aproveBtn.setTitle(leaveData.status, for: .normal)
            cell.aproveBtn.isUserInteractionEnabled = true
            cell.RejectBtnName.isUserInteractionEnabled = true
            cell.aproveBtn.tag = indexPath.row
            cell.RejectBtnName.tag = indexPath.row
            cell.ApprovalAndReject = self
            cell.statusLbl.text = leaveData.status
            cell.NoOfDaysLbl.text = (leaveData.no_of_days ?? "")
            cell.edit(edit: true, delete: true, selectedId: leaveData.id ?? "")
          
            if isStaff{
                cell.StatusView.isHidden = false
                cell.viewDetailsLbl.isHidden = true
                cell.aproveBtn.isHidden = true
                cell.RejectBtnName.isHidden = true
            }else if isPrincipal{
                cell.StatusView.isHidden = true
                cell.aproveBtn.isHidden = false
                cell.RejectBtnName.isHidden = false
                cell.viewDetailsLbl.isHidden = false
               
            }
            
            switch leaveData.status {

            case leave_type[0]: // Approved
                cell.StatusView.isHidden = false
                cell.StatusView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
                cell.statusLbl.textColor = .systemGreen
                cell.aproveBtn.isHidden = true
                cell.RejectBtnName.isHidden = true
                cell.threeDotBtnName.isHidden = true
            case leave_type[1]: // Rejected
                cell.StatusView.isHidden = false
                cell.StatusView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
                cell.statusLbl.textColor = .systemRed
                cell.aproveBtn.isHidden = true
                cell.RejectBtnName.isHidden = true
                cell.threeDotBtnName.isHidden = true

            default: // Pending
                if isStaff {
                    cell.StatusView.isHidden = false
                    cell.StatusView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.3)
                    cell.statusLbl.textColor = .systemOrange
                    cell.aproveBtn.isHidden = true
                    cell.RejectBtnName.isHidden = true
                    cell.threeDotBtnName.isHidden = false
                } else  if isPrincipal{
                    cell.StatusView.isHidden = true
                    cell.aproveBtn.isHidden = false
                    cell.RejectBtnName.isHidden = false
                    cell.threeDotBtnName.isHidden = true
                }
            }
            
            cell.leaveTypeLbl.text = leaveData.leave_type
            cell.indexPath = indexPath
            cell.delegate = self
            cell.EditLeave = self
            return cell
        }
        else{
            
            let cell = leaveRequestTable.dequeueReusableCell(withIdentifier: CellConfingName.LeveHistoryTV, for: indexPath) as! LeveHistoryTV
            
            guard let leaveData = filteredLeaveRecords?[indexPath.section].details?[indexPath.row] else { return cell }
            
            cell.nameLbl.text = leaveData.student_name
            cell.dateLbl.text = "\(convertDate(leaveData.leave_from ?? "", toFormat: DateFormatString.StandardFormat) ?? "") - \(convertDate(leaveData.leave_to ?? "", toFormat: DateFormatString.StandardFormat) ?? "")"
            cell.resonLbl.text = leaveData.reason
            cell.aproveBtn.setTitle(leaveData.status, for: .normal)
            cell.classLbl.text = (leaveData.class_name ?? "") + " - " + (leaveData.section_name ?? "")
            cell.aproveBtn.isUserInteractionEnabled = true
            cell.rejectBtn.isUserInteractionEnabled = true
            cell.aproveBtn.tag = indexPath.row
            cell.rejectBtn.tag = indexPath.row
            cell.durationLbl.text = (leaveData.no_of_days ?? "") + MenuStringFile.DaysApplication
            if leaveData.status == leave_type[0] {
                cell.editClickBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
                cell.editClickBtn.setTitleColor(.systemGreen, for: .normal)
                cell.editClickBtn.setTitle(leave_type[0], for: .normal)
                cell.aproveBtn.isHidden = true
                cell.rejectBtn.isHidden = true
                cell.editClickBtn.isHidden = false
            } else if leaveData.status == leave_type[1] {
                cell.aproveBtn.isHidden = true
                cell.rejectBtn.isHidden = true
                cell.editClickBtn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
                cell.editClickBtn.setTitleColor(.red, for: .normal)
                cell.editClickBtn.setTitle(leave_type[1], for: .normal)
                cell.editClickBtn.isHidden = false
            } else {
                cell.aproveBtn.backgroundColor = .systemGreen
                cell.aproveBtn.setTitle("Approve", for: .normal)
                cell.rejectBtn.setTitle("Reject", for: .normal)
                cell.aproveBtn.isHidden = false
                cell.rejectBtn.isHidden = false
                cell.editClickBtn.isHidden = true
            }
            cell.LeaveTypeLbl.text = leaveData.leave_type
            
            cell.onApprove = { [weak self] in
                
                guard let self = self else { return }
                
                let message = AlertstringFile.toapprovethisleaverequest
                alert.showAlertCancel(title: AlertstringFile.Confirm, message: message,
                                      actionLbl1: AlertstringFile.OK,
                                      actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
                    self.Leave_Update_status(id: leaveData.id ?? "", status: true, indexPath: indexPath)
                }, onNo: {})
            }
            
            cell.onReject = { [weak self] in
                
                guard let self = self else { return }
                
                let message = AlertstringFile.toRejectthisleaverequest
                alert.showAlertCancel(title: AlertstringFile.Confirm, message: message,
                                      actionLbl1: AlertstringFile.OK,
                                      actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
                    self.Leave_Update_status(id: leaveData.id ?? "", status: false, indexPath: indexPath)
                }, onNo: {})
            }
            
            return cell
            
        }
    }
    func formatDate(_ dateString: String) -> String {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM dd"
            
            return outputFormatter.string(from: date)
        }
        
        return ""
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPrincipal{
            let vc = StaffDetailsPreviewVc()
            vc.staffID  = filteredLeaveRecords?[indexPath.section].details?[indexPath.row].staff_id ?? ""
            vc.passedData = filteredLeaveRecords?[indexPath.section].details?[indexPath.row]
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView() // empty view
    }
    
    
    func daysBetweenLabel(start: String, end: String) -> String {
        let savedCode = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        let localeID = normalizedLocaleIdentifier(for: savedCode)
        let formatter = DateFormatter()
        formatter.dateFormat = DateInputs.dd_MM_yyyy
        formatter.locale = Locale(identifier: localeID)
        guard let fromDate = formatter.date(from: start),
              let toDate = formatter.date(from: end) else {
            return "Invalid date"
        }
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.day], from: fromDate, to: toDate).day ?? 0
        let totalDays = diff + 1 // Include both from and to dates
        return totalDays == 1 ? "( 1 day )" : "( \(totalDays) days )"
    }
}

//MARK: Searchbar Delegate Functions
@available(iOS 14.0, *)
extension SenderLeaveRqstVC: UISearchBarDelegate {
    func applyFilter() {
        // 1. Apply status filter first
        var baseData: [LeaveMonth]
        if selectedFilter == .all {
            baseData = allLeaveRecords ?? []
        } else {
            baseData = allLeaveRecords?.compactMap { month in
                let filteredDetails = month.details?.filter {
                    $0.status == selectedFilter.rawValue
                }
                if let details = filteredDetails, !details.isEmpty {
                    return LeaveMonth(month: month.month, details: details)
                }
                return nil
            } ?? []
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let lowercasedQuery = searchText.lowercased()
            filteredLeaveRecords = baseData.compactMap { month in
                let filteredDetails = month.details?.filter { info in
                    let fromDate = info.leave_from?.convertToTargetDateFormat()
                    let toDate   = info.leave_to?.convertToTargetDateFormat()
                    let classSection = [info.class_name, info.section_name]
                        .compactMap { $0 }
                        .joined(separator: " - ")
                    return
                    (info.student_name?.lowercased().contains(lowercasedQuery) ?? false) ||
                    (info.class_name?.lowercased().contains(lowercasedQuery) ?? false) ||
                    (classSection.lowercased().contains(lowercasedQuery)) ||
                    (info.reason?.lowercased().contains(lowercasedQuery) ?? false) ||
                    (info.leave_type?.lowercased().contains(lowercasedQuery) ?? false) ||
                    (info.no_of_days?.lowercased().contains(lowercasedQuery) ?? false) ||
                    (fromDate?.lowercased().contains(lowercasedQuery) ?? false) ||
                    (toDate?.lowercased().contains(lowercasedQuery) ?? false)
                }
                
                if let details = filteredDetails, !details.isEmpty {
                    return LeaveMonth(month: month.month, details: details)
                }
                return nil
            }
        } else {
            filteredLeaveRecords = baseData
        }
        NodateLbl.text = CommonStringFile.No_data_found
        NodateLbl.isHidden = !(filteredLeaveRecords?.isEmpty ?? false)
        NodataImage.isHidden = !(filteredLeaveRecords?.isEmpty ?? false)
        leaveRequestTable.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchQuery = searchText.lowercased()
        self.searchText = searchText
        applyFilter()
    }
}

