//
//  LeveHistoryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
import DropDown

import UIKit

class LeveHistoryVC: UIViewController, editDelete {
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var monthWish: UIView!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var toLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var historyTable: UITableView!
    @IBOutlet weak var EmptyView: UIView!
    @IBOutlet weak var NodataLbl: UILabel!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var TopInfoView: UIView!
    let alert = CustomAlert()
    var LeaveHistoryData: [LeaveInfo]?
    var childDetails = UserDefaultFileManager.get_child_Details()
    var openedPopupIndex: IndexPath?
    var delegate: EditObject?
    override func viewDidLoad() {
        super.viewDidLoad()

        fromLbl.setFont(style:.title, size: FontSize.TitleSize)
        toLbl.setFont(style:.title, size: FontSize.TitleSize)
        statusLbl.setFont(style:.title, size: FontSize.TitleSize)
        headerTitle.setFont(style:.body, size: FontSize.BodySize)
        NodataLbl.setFont(style:.title, size: FontSize.HeaderSize)
        NodataLbl.text = CommonStringFile.No_data_found

        TopInfoView.isHidden = true
        EmptyView.isHidden = true
        NodataImage.isHidden = true
        NodataLbl.isHidden = true

        historyTable.register(UINib(nibName: CellConfingName.LeveHistoryTV, bundle: nil), forCellReuseIdentifier: CellConfingName.LeveHistoryTV)
        historyTable.delegate = self
        historyTable.dataSource = self

        // Tap outside to dismiss popup
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        GetLeaveReqHistory()
    }

    @objc func dismissPopup() {
        guard let index = openedPopupIndex,
              let cell = historyTable.cellForRow(at: index) as? LeveHistoryTV else { return }

        cell.hidePopup()
        openedPopupIndex = nil
    }

    func edit(edit: Int?, delete: Int?) {
        // Special case for showing popup
        if delete == -999, let row = edit {
            let indexPath = IndexPath(row: row, section: 0)

            // Close previous
            if let previous = openedPopupIndex, previous != indexPath,
               let prevCell = historyTable.cellForRow(at: previous) as? LeveHistoryTV {
                prevCell.hidePopup()
            }

            if openedPopupIndex == indexPath {
                // Same cell tapped → hide
                if let cell = historyTable.cellForRow(at: indexPath) as? LeveHistoryTV {
                    cell.hidePopup()
                    openedPopupIndex = nil
                }
            } else {
                // Open new
                if let cell = historyTable.cellForRow(at: indexPath) as? LeveHistoryTV {
                    cell.showPopup.isHidden = false
                    cell.iconBtn.isSelected = true
                    cell.aproveBtn.isHidden = true
                    openedPopupIndex = indexPath
                }
            }
            return
        }

        if let edit = edit {
            let editLeave = editLeave(id: LeaveHistoryData?[edit].id, fromDate: LeaveHistoryData?[edit].leave_from ?? "", toDate: LeaveHistoryData?[edit].leave_to ?? "", reson: LeaveHistoryData?[edit].reason ?? "")
            delegate?.edit(edit:editLeave)
        }

        if let delete = delete {
            print("Delete tapped at index: \(delete)")
            deleteLeave(id: LeaveHistoryData?[delete].id ?? "", index: delete)
        }
    }
    func deleteLeave(id:String,index:Int){
        
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.deletemessage, actionLbl1: AlertstringFile.delete, actionLbl2: AlertstringFile.Cancel, on: self,
                              
            onOk: {
                  
            APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_delete, parameters:["id":id], type: ApitTypeSringFile.Put, token: self.childDetails?.access_token ?? "") {[weak self] (result: Result<CommonApiSuc,Error>) in
                
                DispatchQueue.main.async { [weak self] in
                    
                    guard let self = self else {return}
                    
                    switch result{
                        
                    case .success(let success):
                        
                        if success.status == true{
                            
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: success.message ?? "", on: self) {
                                self.LeaveHistoryData?.remove(at: index)
                                self.historyTable.reloadData()
                            }
                        }else {
                            
                            alert.showAlert(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                        }
                        
                    case .failure(let error):
                        
                        alert.showAlert(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                    }
                }
            }
            
        }, onNo: {
            
            print("user Canceled Action")
        }
        )
    }
    func GetLeaveReqHistory() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }

        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_list,
                                  parameters: [LeaveRequestStringFile.member_type: "STUDENT"],
                                  type: ApitTypeSringFile.GET,
                                  token: childDetails?.access_token ?? "") { [weak self] (result: Result<LeaveInfoResponse, Error>) in

            DispatchQueue.main.async {
                guard let self = self else { return }
                if #available(iOS 15.0, *) {
                    self.hideLottieProgressLoader()
                }

                switch result {
                case .success(let success):
                    self.LeaveHistoryData = success.data
                    let isEmpty = self.LeaveHistoryData?.isEmpty ?? true
                    self.EmptyView.isHidden = !isEmpty
                    self.NodataImage.isHidden = !isEmpty
                    self.NodataLbl.isHidden = !isEmpty
                    self.TopInfoView.isHidden = isEmpty
                    self.historyTable.reloadData()

                case .failure(let error):
                    self.NodataLbl.text = error.localizedDescription
                    self.EmptyView.isHidden = false
                    self.NodataImage.isHidden = false
                    self.NodataLbl.isHidden = false
                    self.TopInfoView.isHidden = true
                    print("Error: ", error.localizedDescription)
                }
            }
        }
    }
}
extension LeveHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LeaveHistoryData?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTable.dequeueReusableCell(withIdentifier: CellConfingName.LeveHistoryTV, for: indexPath) as! LeveHistoryTV

        guard let leaveData = LeaveHistoryData?[indexPath.row] else { return cell }
        cell.aproveBtn.isUserInteractionEnabled = false
        cell.rejectBtn.isUserInteractionEnabled = false
        cell.nameLbl.text = leaveData.student_name
        cell.dateLbl.text = "\(convertDate(leaveData.leave_from, toFormat: DateFormatString.StandardFormat) ?? "") - \(convertDate(leaveData.leave_to, toFormat: DateFormatString.StandardFormat) ?? "")"
        cell.resonLbl.text = leaveData.reason
        cell.aproveBtn.setTitle(leaveData.status, for: .normal)
        let firstLetter = leaveData.student_name.first.map { String($0) } ?? ""
        cell.iconBtn.setTitle(firstLetter.uppercased(), for: .normal)
        cell.delegate = self
        cell.iconBtn.tag = indexPath.row
        cell.editBtn.tag = indexPath.row
        cell.deleteBtn.tag = indexPath.row
        cell.durationLbl.text = daysBetweenLabel(start: leaveData.leave_from, end: leaveData.leave_to)
        if leaveData.status == "Approved" {
            cell.aproveBtn.backgroundColor = Colornames.AprovedClr
            cell.editClickBtn.isHidden = true
        } else if leaveData.status == "Rejected" {
            cell.aproveBtn.backgroundColor = .red
            cell.editClickBtn.isHidden = true
        } else {
            cell.aproveBtn.backgroundColor = Colornames.pendingClr
            cell.aproveBtn.setTitle("Waiting", for: .normal)
            cell.editClickBtn.isHidden = false
        }

        // Popup visibility control
        let isPopupOpen = openedPopupIndex == indexPath
        cell.showPopup.isHidden = !isPopupOpen
        cell.iconBtn.isSelected = isPopupOpen
        cell.aproveBtn.isHidden = isPopupOpen

        return cell
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissPopup()
    }
}

