//
//  StaffDetailsPreviewVc.swift
//  School Chimes
//
//  Created by apple on 16/02/26.
//

import UIKit

class StaffDetailsPreviewVc: UIViewController {
    @IBOutlet weak var LeaveHistoryFullView: UIView!
    @IBOutlet weak var nameProfileLbl: UILabel!
    @IBOutlet weak var ContactInformationFullView: UIView!
    @IBOutlet weak var currentLeaveReqFullView: UIView!
    @IBOutlet weak var mailIdLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var phnNumberLbl: UILabel!
    @IBOutlet weak var ReasonLbl: UILabel!
    @IBOutlet weak var EndDateLbl: UILabel!
    @IBOutlet weak var startDateLbl: UILabel!
    @IBOutlet weak var noOfDaysLbl: UILabel!
    @IBOutlet weak var leaveTypeLbl: UILabel!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var RollLabel: UILabel!
    @IBOutlet weak var staffNameLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var RejectBtnName: UIButton!
    @IBOutlet weak var locationBackView: UIView!
    @IBOutlet weak var mailBackView: UIView!
    @IBOutlet weak var phnBackView: UIView!
    var staffID = ""
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var allLeaveRecords: [LeaveMonth]?
    var passedData: LeaveInfo?
    let leave_type = ["Approved","Rejected","Waiting for approval"]
    let alert = CustomAlert()
    @IBAction func rejectBtnAct(_ sender: UIButton) {
        alert.showAlertCancel(
            title: AlertstringFile.Confirm_title,
            message: "Are you sure want to reject the leave request",
            actionLbl1:  AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                
                self.Leave_Update_status(id:self.passedData?.id ??
                                    "", status:false )
            },
            onNo: {
                
            }
        )
       
    }
    @IBAction func ApproveBtnName(_ sender: UIButton) {
        
        alert.showAlertCancel(
            title: AlertstringFile.Confirm_title,
            message: "Are you sure want to approve the leave request",
            actionLbl1:  AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                self.Leave_Update_status(id:self.passedData?.id ?? "", status:true )
            },
            onNo: {
                
            })
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tv.register(UINib(nibName: "LeaveReqDateTvCell", bundle: nil), forCellReuseIdentifier: "LeaveReqDateTvCell")
        tv.dataSource = self
        tv.delegate = self
        DispatchQueue.main.async {
            self.uiUpdate()
        }
        GetStaffLeaveRequest()
        profileContainerView.layer.cornerRadius = 24 // 48x48
        profileContainerView.clipsToBounds = true
        
        let phnNumberClick = UITapGestureRecognizer(target: self, action: #selector(gotoNumberPad))
        phnNumberLbl.addGestureRecognizer(phnNumberClick)
        
        let emailClick = UITapGestureRecognizer(target: self, action: #selector(gotoEmail))
        mailIdLbl.addGestureRecognizer(emailClick)
        nameProfileLbl.text = shortName(from: passedData?.staff_name ?? "")
    }

    @IBAction func gotoNumberPad(){
        let phoneNumber = phnNumberLbl.text ?? "" // Replace with the phone number you want
        if let phoneURL = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
    
    
    @IBAction func gotoEmail() {
        let email = mailIdLbl.text ?? ""
        
        guard let mailURL = URL(string: "mailto:\(email)"),
              let gmailURL = URL(string: "googlegmail://co?to=\(email)") else {
            return
        }
        
        let canOpenMail = UIApplication.shared.canOpenURL(mailURL)
        let canOpenGmail = UIApplication.shared.canOpenURL(gmailURL)
        
        // Case 1: No apps available
        if !canOpenMail && !canOpenGmail {
            print("No mail apps available")
            return
        }
        
        // Case 2: Only one app → open directly (skip alert)
        if canOpenMail && !canOpenGmail {
            UIApplication.shared.open(mailURL)
            return
        }
        
        if canOpenGmail && !canOpenMail {
            UIApplication.shared.open(gmailURL)
            return
        }
        
        // Case 3: Both available → show alert
        let alert = UIAlertController(title: "Send Email",
                                      message: "Choose an app",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Apple Mail", style: .default) { _ in
            UIApplication.shared.open(mailURL)
        })
        
        alert.addAction(UIAlertAction(title: "Gmail", style: .default) { _ in
            UIApplication.shared.open(gmailURL)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX,
                                       y: self.view.bounds.midY,
                                       width: 0,
                                       height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    
    func uiUpdate(){
       
        ContactInformationFullView.layer.cornerRadius = 15
        ContactInformationFullView.layer.masksToBounds = true
        ContactInformationFullView.layer.borderWidth = 0.5
        ContactInformationFullView.layer.borderColor = UIColor.lightGray.cgColor
        
        locationBackView.layer.cornerRadius  = 15
        mailBackView.layer.cornerRadius  = 15
        phnBackView.layer.cornerRadius  = 15
        
        RejectBtnName.layer.borderWidth = 1
        RejectBtnName.layer.borderColor = UIColor.red1.cgColor
        
        profileContainerView.layer.cornerRadius = 24 // 48x48
        profileContainerView.clipsToBounds = true
        
        LeaveHistoryFullView.cornerRadius(10)
        LeaveHistoryFullView.layer.borderWidth = 0.5
        LeaveHistoryFullView.layer.borderColor = UIColor.lightGray.cgColor
        
        currentLeaveReqFullView.cornerRadius(10)
        currentLeaveReqFullView.layer.borderWidth = 0.5
        currentLeaveReqFullView.layer.borderColor = UIColor.lightGray.cgColor
        mailIdLbl.text = passedData?.email
        phnNumberLbl.text = passedData?.mobile_no
        addressLbl.text = passedData?.address
        ReasonLbl.text = passedData?.reason
        startDateLbl.text = passedData?.from_date
        EndDateLbl.text = passedData?.to_date
        let fromdate = passedData?.from_date ?? ""
        let formformatted = formatDate(fromdate)
        startDateLbl.text = formformatted
        let todate = passedData?.to_date ?? ""
        let toformatted = formatDate(todate)
       EndDateLbl.text = toformatted
        leaveTypeLbl.text = passedData?.leave_type
        staffNameLbl.text = passedData?.staff_name
        RollLabel.text = passedData?.role
        currentLeaveReqFullView.isHidden = passedData?.status != "Waiting for approval"
        
    }
    
    func Leave_Update_status(id: String, status: Bool) {
        let param: [String: Any] = [
            LeaveRequestStringFile.id: id,
            LeaveRequestStringFile.is_approve: status
        ]
        APIService.shared.makeApi(
            url:  ServiceUrl.comm_api_leave_req_update_status_Staff,
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
                        CustomAlert.showAlertWithOkAction(title: title, message: message, on: self) {
                            self.currentLeaveReqFullView.isHidden = true
                        }
                    } else {
                        self.alert.showAlert(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                    
                case .failure(let error):
                    self.alert.showAlert(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                }
            }
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
    @IBAction func BackBtnAct(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension StaffDetailsPreviewVc : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLeaveRecords?[section].details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveReqDateTvCell", for: indexPath) as? LeaveReqDateTvCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let data = allLeaveRecords?[indexPath.section].details?[indexPath.row]
        
        cell.leaveTypeLbl.text = data?.leave_type
        let result = splitDateMonth(data?.from_date ?? "")
        cell.dateLbl.text = result.day
        cell.monthLbl.text = result.month
        cell.detailLbl.text =  (data?.no_of_days ?? "") + " Day" + ". \(data?.from_date?.convertToTargetDateFormat() ?? "")" + " , \(data?.to_date?.convertToTargetDateFormat() ?? "")"
        
        cell.statusView.layer.cornerRadius = 10
        if data?.status == leave_type[0] {
            cell.statusView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
            cell.statusLbl.textColor = .systemGreen
            cell.statusLbl.text = leave_type[0]
            
           
        } else if data?.status == leave_type[1] {
            cell.statusView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            cell.statusLbl.textColor = .red
            cell.statusLbl.text = leave_type[1]
            
        } else {
            cell.statusView.backgroundColor = .systemOrange.withAlphaComponent(0.1)
           
            cell.statusLbl.textColor = .systemOrange
            cell.statusLbl.text = leave_type[2]
            
        }
        return cell
    }
    
    func splitDateMonth(_ dateString: String) -> (day: String, month: String) {
        
        let months = ["JAN","FEB","MAR","APR","MAY","JUN",
                      "JUL","AUG","SEP","OCT","NOV","DEC"]
        
        let parts = dateString.components(separatedBy: "-")
        
        if parts.count >= 2 {
            let day = parts[0]
            let monthIndex = Int(parts[1]) ?? 1
            let month = months[monthIndex - 1]
            
            return (day, month)
        }
        
        return ("","")
    }
    func GetStaffLeaveRequest() {
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_leave_req_list_staff,
            parameters: ["staff_id":staffID],
            type: ApitTypeSringFile.GET,
            token: StaffDetails?.access_token ?? "",
            isBaseUrl: false) { [weak self] (result: Result<LeaveInfoResponse,Error>) in
                
            guard let self = self else { return }
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self.allLeaveRecords = success.data
                    self.tv.reloadData()
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error:", error.localizedDescription)
                }
            }
        }
    }
}
