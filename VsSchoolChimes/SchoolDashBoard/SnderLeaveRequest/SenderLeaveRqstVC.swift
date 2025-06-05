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
class SenderLeaveRqstVC: UIViewController, ConfirmDelegate {
    
    
    func confirm(index: Int, status: Bool) {
        
        let message = status==true ? "Are you sure you want to approve this leave request?" : "Are you sure you want to reject this leave request?"
        
        let Leaveid = SearchLeavetData?[index].id ?? ""
        
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: message, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
            
            self.Leave_Update_status(id: Leaveid, status: status)
            
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
      
        BackBtn.setTitle(MenuStringFile.LeaveRequest.translated(), for: .normal)
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.applyRightTxt()
        searchBar.searchTextField.addDoneButton()
        searchBar.delegate = self
        
        NodateLbl.isHidden = true
        NodataImage.isHidden = true
        EmptyView.isHidden = true
        
        GetLeaveRequestAPI()
        
        leaveRequestTable.register(UINib(nibName: CellConfingName.SenderLeaveTV, bundle: nil), forCellReuseIdentifier: CellConfingName.SenderLeaveTV)
        
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
    
    func Leave_Update_status(id: String, status: Bool) {
        
        let param: [String:Any] = [LeaveRequestStringFile.id: id,LeaveRequestStringFile.is_approve: status]
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_update_status, parameters: param, type: ApitTypeSringFile.Put, token: StaffDetails?.access_token ?? "") { [self] (result:Result<CommonApiSuc,Error>) in
            
            switch result{
                
            case .success(let success):
                
                DispatchQueue.main.async {[self] in
                    
                    let title = success.status == true ? AlertstringFile.Success : AlertstringFile.Failed
                    
                    CustomAlert.showAlertWithOkAction(title: title, message: success.message ?? "", on: self){
                        
                        self.GetLeaveRequestAPI()
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {[self] in
                    
                    print("Error: ",error.localizedDescription)
                    
                    alert.showAlert(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
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
        let cell = leaveRequestTable.dequeueReusableCell(withIdentifier: CellConfingName.SenderLeaveTV, for: indexPath) as! SenderLeaveTV
        
        let LeaveRequest = SearchLeavetData?[indexPath.row]

        cell.applyedTimeLbl.text = ConvertDateStringSmart(LeaveRequest?.applied_on, toFormat: "dd MMM yyyy hh:mm a")
        cell.studentName.text = LeaveRequest?.student_name
        cell.studentClass.text = (LeaveRequest?.class_name ?? "") + " " + (LeaveRequest?.section_name ?? "")
        cell.fromDate.text =   convertDate(LeaveRequest?.leave_from ?? "", toFormat: "dd MMM yyyy")
        cell.toDate.text =  convertDate(LeaveRequest?.leave_to ?? "", toFormat: "dd MMM yyyy")
        cell.resonLbl.text = LeaveRequest?.reason
        cell.NoOfDaysLbl.text = LeaveRequest?.no_of_days
        cell.delegate = self
        
        if LeaveRequest?.status == "Approved"{
            
            cell.UpdatedOnBtn.isHidden = false
            cell.UpdatedOnBtn.backgroundColor = .systemGreen.withAlphaComponent(0.3)
            cell.UpdatedOnBtn.setTitleColor(.systemGreen, for: .normal)
            cell.ApproveRejectStack.isHidden = true
            cell.StatusBtn.backgroundColor = .systemGreen.withAlphaComponent(0.8)
            cell.StatusBtn.setTitle(LeaveRequest?.status, for: .normal)
            
        }else if LeaveRequest?.status == "Rejected" {
            
            cell.UpdatedOnBtn.isHidden = false
            cell.UpdatedOnBtn.backgroundColor = .systemRed.withAlphaComponent(0.3)
            cell.UpdatedOnBtn.setTitleColor(.systemRed, for: .normal)
            cell.ApproveRejectStack.isHidden = true
            cell.StatusBtn.setTitle(LeaveRequest?.status, for: .normal)
            cell.StatusBtn.backgroundColor = .systemRed.withAlphaComponent(0.8)
        }
        let btnTitle = (LeaveRequest?.status ?? "") + " on " + (ConvertDateStringSmart(LeaveRequest?.updated_on, toFormat: "dd MMM yyyy hh:mm a"))
        cell.UpdatedOnBtn.setTitle(btnTitle, for: .normal)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
