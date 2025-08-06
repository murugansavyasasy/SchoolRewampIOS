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
class SenderLeaveRqstVC: UIViewController, ConfirmDelegate, EditDeleteDelegate {
   
    
    func edit(edit: IndexPath?, delete: IndexPath?) {
        guard let indexPath = edit,
              let studentId = SearchLeavetData?[indexPath.section].details?[indexPath.row].id else { return }

        if let delete = delete {
            switch delete.row {
            case 0: // Approve
                let message = "Are you sure you want to approve this leave request?"
                alert.showAlertCancel(title: AlertstringFile.Confirm, message: message,
                                      actionLbl1: AlertstringFile.OK,
                                      actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
                    self.Leave_Update_status(id: studentId, status: true, indexPath: indexPath)
                }, onNo: {})

            case 1: // Reject
                let message = "Are you sure you want to reject this leave request?"
                alert.showAlertCancel(title: AlertstringFile.Confirm, message: message,
                                      actionLbl1: AlertstringFile.OK,
                                      actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
                    self.Leave_Update_status(id: studentId, status: false, indexPath: indexPath)
                }, onNo: {})

            default:
                break
            }
        }
    }

    
    
    
    func confirm(index: Int, status: Bool) {
        
//        let message = status==true ? "Are you sure you want to approve this leave request?" : "Are you sure you want to reject this leave request?"
//        
//        let Leaveid = SearchLeavetData?[index].id ?? ""
//
//        alert.showAlertCancel(title: AlertstringFile.Confirm, message: message, actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self, onOk: {
//            
//            self.Leave_Update_status(id: Leaveid, status: status, index: index)
//            
//        }, onNo: {
//            
//        }
//        )
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var leaveRequestTable: UITableView!
    @IBOutlet weak var EmptyView: UIView!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NodateLbl: UILabel!
    
    var LeaveRequestData: [LeaveMonth]?
    var SearchLeavetData: [LeaveMonth]?
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
    
    func Leave_Update_status(id: String, status: Bool, indexPath: IndexPath) {
        let param: [String: Any] = [
            LeaveRequestStringFile.id: id,
            LeaveRequestStringFile.is_approve: status
        ]
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_leave_req_update_status,
            parameters: param,
            type: ApitTypeSringFile.PUT,
            token: StaffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<CommonApiSuc, Error>) in
            
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success.status == true {
                        let title = AlertstringFile.Success
                        let message = success.message ?? ""
                        let newStatus = status ? "Approved" : "Rejected"

                        // Format current date for updated_on
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd MMM yyyy hh:mm a"
                        let formattedDate = formatter.string(from: Date())

                        // ✅ Update SearchLeavetData
                        self.SearchLeavetData?[indexPath.section].details?[indexPath.row].status = newStatus
                        self.SearchLeavetData?[indexPath.section].details?[indexPath.row].updated_on = formattedDate

                        // ✅ Update LeaveRequestData (original)
                        if let idToUpdate = self.SearchLeavetData?[indexPath.section].details?[indexPath.row].id,
                           let sectionIndex = self.LeaveRequestData?.firstIndex(where: {
                               $0.details?.contains(where: { $0.id == idToUpdate }) == true
                           }),
                           let rowIndex = self.LeaveRequestData?[sectionIndex].details?.firstIndex(where: {
                               $0.id == idToUpdate
                           }) {
                            
                            self.LeaveRequestData?[sectionIndex].details?[rowIndex].status = newStatus
                            self.LeaveRequestData?[sectionIndex].details?[rowIndex].updated_on = formattedDate
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

    
    
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

@available(iOS 14.0, *)
extension SenderLeaveRqstVC : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        SearchLeavetData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .clear  // Customize color

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFont(style: .title, size: FontSize.TitleSize)
        label.textColor = .darkGray
        label.text = SearchLeavetData?[section].month
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)])

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchLeavetData?[section].details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaveRequestTable.dequeueReusableCell(withIdentifier: CellConfingName.LeveHistoryTV, for: indexPath) as! LeveHistoryTV
        
        guard let leaveData = SearchLeavetData?[indexPath.section].details?[indexPath.row] else { return cell }
        
        cell.nameLbl.text = leaveData.student_name
        cell.dateLbl.text = "\(convertDate(leaveData.leave_from ?? "", toFormat: DateFormatString.StandardFormat) ?? "") - \(convertDate(leaveData.leave_to ?? "", toFormat: DateFormatString.StandardFormat) ?? "")"
        cell.resonLbl.text = leaveData.reason
        cell.aproveBtn.setTitle(leaveData.status, for: .normal)
        let firstLetter = leaveData.student_name?.first.map { String($0) } ?? ""
       
       // cell.delegate = self
        cell.aproveBtn.isUserInteractionEnabled = true
        cell.rejectBtn.isUserInteractionEnabled = true
        cell.aproveBtn.tag = indexPath.row
        cell.rejectBtn.tag = indexPath.row
        cell.durationLbl.text = (leaveData.no_of_days ?? "") + " Days Application"
        if leaveData.status == "Approved" {
            cell.editClickBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
            cell.editClickBtn.setTitleColor(.systemGreen, for: .normal)
            cell.editClickBtn.setTitle("Approved", for: .normal)
            cell.aproveBtn.isHidden = true
            cell.rejectBtn.isHidden = true
        } else if leaveData.status == "Rejected" {
            cell.aproveBtn.isHidden = true
            cell.rejectBtn.isHidden = true
            cell.editClickBtn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            cell.editClickBtn.setTitleColor(.red, for: .normal)
            cell.editClickBtn.setTitle("Rejected", for: .normal)
            cell.editClickBtn.isHidden = false
        } else {
            cell.aproveBtn.backgroundColor = Colornames.AprovedClr
            cell.aproveBtn.setTitle("Approve", for: .normal)
            cell.rejectBtn.setTitle("Reject", for: .normal)
            cell.aproveBtn.isHidden = false
            cell.rejectBtn.isHidden = false
            cell.editClickBtn.isHidden = true
        }
        
        cell.indexPath = indexPath
        cell.delegate = self
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
extension SenderLeaveRqstVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            SearchLeavetData = LeaveRequestData
        } else {
            SearchLeavetData = LeaveRequestData?.compactMap { month in
                let filteredDetails = month.details?.filter { leave in
                    leave.applied_on?.lowercased().contains(searchText.lowercased()) == true ||
                    leave.student_name?.lowercased().contains(searchText.lowercased()) == true ||
                    leave.class_name?.lowercased().contains(searchText.lowercased()) == true ||
                    leave.section_name?.lowercased().contains(searchText.lowercased()) == true ||
                    leave.reason?.lowercased().contains(searchText.lowercased()) == true ||
                    leave.status?.lowercased().contains(searchText.lowercased()) == true
                }
                
                if let filteredDetails, !filteredDetails.isEmpty {
                    return LeaveMonth(month: month.month, details: filteredDetails)
                } else {
                    return nil
                }
            }
        }
        
        // Show or hide empty state
        let isEmpty = SearchLeavetData?.allSatisfy { $0.details?.isEmpty ?? true } ?? true
        NodateLbl.text = "No data found!"
        NodataImage.isHidden = !isEmpty
        NodateLbl.isHidden = !isEmpty
        EmptyView.isHidden = !isEmpty
        
        leaveRequestTable.reloadData()
    }
}

