//
//  SenderLeaveRqstVC.swift
//  VsSchoolChimes
//
//  Created by admin on 24/12/24.
//

import UIKit
protocol ConfirmDelegate{
    func confirm(index:Int,status:Bool)
}
@available(iOS 14.0, *)
class SenderLeaveRqstVC: UIViewController, ConfirmDelegate, editDelete {
    func edit(edit: Int?, delete: Int?) {
        guard let studentId = SearchLeavetData?[edit ?? 0].id else { return }
        if delete == 0{
            
            let message = "Are you sure you want to approve this leave request?"
            
            alert.showAlertCancel(title: AlertstringFile.Confirm, message: message, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
                self.Leave_Update_status(id: studentId, status:true, index:edit ?? 0)
                
            }, onNo: {
                
            }
            )
            
        }else{
            let message = "Are you sure you want to reject this leave request?"
            
            alert.showAlertCancel(title: AlertstringFile.Confirm, message: message, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
                
                self.Leave_Update_status(id: studentId, status:true, index:edit ?? 0)
                
            }, onNo: {
                
            }
            )
            
        }
    }
    
    
    
    func confirm(index: Int, status: Bool) {
        
        let message = status==true ? "Are you sure you want to approve this leave request?" : "Are you sure you want to reject this leave request?"
        
        let Leaveid = SearchLeavetData?[index].id ?? ""
        
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: message, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
            
            self.Leave_Update_status(id: Leaveid, status: status, index: index)
            
        }, onNo: {
            
        }
        )
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var leaveRequestTable: UITableView!
    @IBOutlet weak var EmptyView: UIView!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NodateLbl: UILabel!
    
    var LeaveRequestData: [LeaveInfo]?
    var SearchLeavetData: [LeaveInfo]?
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    let alert = CustomAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        
        // BackBtn.setTitle(MenuStringFile.LeaveRequest.translated(), for: .normal)
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: StaffDetails?.school_name ?? "")
        // BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.applyRightTxt()
        searchBar.searchTextField.addDoneButton()
        searchBar.delegate = self
        
        NodateLbl.isHidden = true
        NodataImage.isHidden = true
        EmptyView.isHidden = true
        
        leaveRequestTable.showsVerticalScrollIndicator = false
        leaveRequestTable.showsHorizontalScrollIndicator = false
        
        GetLeaveRequestAPI()
        
        leaveRequestTable.register(UINib(nibName: CellConfingName.LeveHistoryTV, bundle: nil), forCellReuseIdentifier: CellConfingName.LeveHistoryTV)
        
        leaveRequestTable.delegate = self
        leaveRequestTable.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    //MARK: Get Leave Requests API call
    
    func GetLeaveRequestAPI() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_list, parameters: [LeaveRequestStringFile.member_type: "STAFF"], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "") {[self] (result: Result<LeaveInfoResponse,Error>) in
            
            switch result{
                
            case .success(let Success):
                
                DispatchQueue.main.async {[self] in
                    
                    LeaveRequestData = Success.data
                    SearchLeavetData = LeaveRequestData
                    NodateLbl.text = Success.message
                    NodataImage.isHidden = !(LeaveRequestData?.isEmpty ?? false)
                    NodateLbl.isHidden = !(LeaveRequestData?.isEmpty ?? false)
                    EmptyView.isHidden = !(LeaveRequestData?.isEmpty ?? false)
                    searchBar.isHidden = (LeaveRequestData?.isEmpty ?? false)
                    leaveRequestTable.reloadData()
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async { [self] in
                    NodateLbl.text = error.localizedDescription
                    NodataImage.isHidden = false
                    NodateLbl.isHidden = false
                    EmptyView.isHidden = false
                    print("Error: ",error.localizedDescription)
                }
            }
        }
    }
    
    func Leave_Update_status(id: String, status: Bool, index: Int) {
        
        let param: [String: Any] = [
            LeaveRequestStringFile.id: id,
            LeaveRequestStringFile.is_approve: status
        ]
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_leave_req_update_status,
            parameters: param,
            type: ApitTypeSringFile.PUT,
            token: StaffDetails?.access_token ?? ""
        ) { [self] (result: Result<CommonApiSuc, Error>) in
            
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    if success.status == true {
                        let title = AlertstringFile.Success
                        let message = success.message ?? ""
                        let newStatus = status ? "Approved" : "Rejected"
                        
                        // Get formatted date
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd MMM yyyy hh:mm a"
                        let formattedDate = formatter.string(from: Date())
                        
                       self.SearchLeavetData?[index].status = newStatus
                        self.SearchLeavetData?[index].updated_on = formattedDate
                        if let idToUpdate = self.SearchLeavetData?[index].id,
                           let originalIndex = self.LeaveRequestData?.firstIndex(where: { $0.id == idToUpdate }) {
                            self.LeaveRequestData?[originalIndex].status = newStatus
                            self.LeaveRequestData?[originalIndex].updated_on = formattedDate
                        }
                        
                        // ✅ Reload updated row
                        self.leaveRequestTable.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        
                        // ✅ Show success
                        CustomAlert.showAlertWithOkAction(title: title, message: message, on: self) {}
                    } else {
                        let title = AlertstringFile.Failed
                        self.alert.showAlert(title: title, message: success.message ?? "", on: self)
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error:", error.localizedDescription)
                    self.alert.showAlert(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                }
            }
        }
    }
    
    
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

@available(iOS 14.0, *)
extension SenderLeaveRqstVC : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchLeavetData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaveRequestTable.dequeueReusableCell(withIdentifier: CellConfingName.LeveHistoryTV, for: indexPath) as! LeveHistoryTV
        
        let LeaveRequest = SearchLeavetData?[indexPath.row]
        guard let leaveData = SearchLeavetData?[indexPath.row] else { return cell }
        
        cell.nameLbl.text = leaveData.student_name
        cell.dateLbl.text = "\(convertDate(leaveData.leave_from, toFormat: DateFormatString.StandardFormat) ?? "") - \(convertDate(leaveData.leave_to, toFormat: DateFormatString.StandardFormat) ?? "")"
        cell.resonLbl.text = leaveData.reason
        cell.aproveBtn.setTitle(leaveData.status, for: .normal)
        let firstLetter = leaveData.student_name.first.map { String($0) } ?? ""
        cell.iconBtn.setTitle(firstLetter.uppercased(), for: .normal)
        cell.delegate = self
        cell.aproveBtn.isUserInteractionEnabled = true
        cell.rejectBtn.isUserInteractionEnabled = true
        cell.aproveBtn.tag = indexPath.row
        cell.rejectBtn.tag = indexPath.row
        cell.durationLbl.text = daysBetweenLabel(start: leaveData.leave_from, end: leaveData.leave_to)
        if leaveData.status == "Approved" {
            cell.aproveBtn.backgroundColor = Colornames.AprovedClr
            cell.aproveBtn.isHidden = false
            cell.rejectBtn.isHidden = true
        } else if leaveData.status == "Rejected" {
            cell.aproveBtn.backgroundColor = .red
            cell.aproveBtn.isHidden = true
            cell.rejectBtn.isHidden = false
        } else {
            cell.aproveBtn.backgroundColor = Colornames.AprovedClr
            cell.aproveBtn.setTitle("Approve", for: .normal)
            cell.rejectBtn.setTitle("Reject", for: .normal)
            cell.aproveBtn.isHidden = false
            cell.rejectBtn.isHidden = false
        }
        
        cell.showPopup.isHidden = true
        cell.editClickBtn.isHidden = true
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func daysBetweenLabel(start: String, end: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
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

@available(iOS 14.0, *)
extension SenderLeaveRqstVC: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            
            SearchLeavetData = LeaveRequestData
            
        } else {
            
            SearchLeavetData = LeaveRequestData?.filter{ Leave in
                
                Leave.applied_on.lowercased().contains(searchText.lowercased()) ||
                Leave.student_name.lowercased().contains(searchText.lowercased()) ||
                Leave.class_name.lowercased().contains(searchText.lowercased()) ||
                Leave.section_name.lowercased().contains(searchText.lowercased()) ||
                Leave.reason.lowercased().contains(searchText.lowercased()) ||
                Leave.status.lowercased().contains(searchText.lowercased())
            }
        }
        
        NodateLbl.text = "No data found!"
        NodataImage.isHidden = !(SearchLeavetData?.isEmpty ?? false)
        NodateLbl.isHidden = !(SearchLeavetData?.isEmpty ?? false)
        EmptyView.isHidden = !(SearchLeavetData?.isEmpty ?? false)
        leaveRequestTable.reloadData()
    }
}
