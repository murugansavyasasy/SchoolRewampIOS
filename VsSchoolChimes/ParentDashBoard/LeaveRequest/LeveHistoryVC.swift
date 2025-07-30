//
//  LeveHistoryVC.swift
//  VsSchoolChimes
//

import UIKit
import DropDown

enum LeaveStatus: String {
    case approved = "Approved"
    case rejected = "Rejected"
    case waiting  = "Waiting"

    static func from(_ value: String) -> LeaveStatus {
        switch value {
        case "Approved": return .approved
        case "Rejected": return .rejected
        default: return .waiting
        }
    }
}

class LeveHistoryVC: UIViewController, editDelete {

    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var waitingBtn: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var monthWish: UIView!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var historyTable: UITableView!
    @IBOutlet weak var NodataLbl: UILabel!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var TopInfoView: UIView!

    let alert = CustomAlert()
    var leaveHistoryData: [LeaveInfo] = []
    var filteredLeaveData: [LeaveInfo] = []
    var childDetails = UserDefaultFileManager.get_child_Details()
    var openedPopupIndex: IndexPath?
    var delegate: EditObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        addUnderline(to: allBtn, unSelectedBtn: [rejectBtn, approveBtn, waitingBtn])
        headerTitle.setFont(style: .body, size: FontSize.BodySize)
        NodataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        NodataLbl.text = CommonStringFile.No_data_found

        TopInfoView.isHidden = true
        NodataImage.isHidden = true
        NodataLbl.isHidden = true

        historyTable.register(UINib(nibName: CellConfingName.LeveHistoryTV, bundle: nil), forCellReuseIdentifier: CellConfingName.LeveHistoryTV)
        historyTable.delegate = self
        historyTable.dataSource = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        getLeaveRequestHistory()
    }

    @objc func dismissPopup() {
        guard let index = openedPopupIndex,
              let cell = historyTable.cellForRow(at: index) as? LeveHistoryTV else { return }

        cell.hidePopup()
        openedPopupIndex = nil
    }

    func edit(edit: Int?, delete: Int?) {
        if delete == -999, let row = edit {
            let indexPath = IndexPath(row: row, section: 0)

            if let previous = openedPopupIndex, previous != indexPath,
               let prevCell = historyTable.cellForRow(at: previous) as? LeveHistoryTV {
                prevCell.hidePopup()
            }

            if openedPopupIndex == indexPath {
                if let cell = historyTable.cellForRow(at: indexPath) as? LeveHistoryTV {
                    cell.hidePopup()
                    openedPopupIndex = nil
                }
            } else {
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
            let leave = filteredLeaveData[edit]
            if let originalIndex = leaveHistoryData.firstIndex(where: { $0.id == leave.id }) {
                let editLeaveObj = editLeave(
                    id: leave.id,
                    fromDate: leave.leave_from ?? "",
                    toDate: leave.leave_to ?? "",
                    reson: leave.reason ?? ""
                )
                delegate?.edit(edit: editLeaveObj)
            }
        }

        if let delete = delete {
            let idToDelete = leaveHistoryData[delete].id ?? ""
            deleteLeave(id: idToDelete, index: delete)
        }
    }

    func deleteLeave(id: String, index: Int) {
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.deletemessage,
                              actionLbl1: AlertstringFile.delete, actionLbl2: AlertstringFile.Cancel, on: self,
        onOk: {
            APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_delete,
                                      parameters: ["id": id],
                                      type: ApitTypeSringFile.PUT,
                                      token: self.childDetails?.access_token ?? "") { [weak self] (result: Result<CommonApiSuc, Error>) in

                DispatchQueue.main.async {
                    guard let self = self else { return }

                    switch result {
                    case .success(let success):
                        if success.status == true {
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success,
                                                              message: success.message ?? "", on: self) {
                                if
                                   let originalIndex = self.leaveHistoryData.firstIndex(where: { $0.id == self.filteredLeaveData[index].id }) {
                                    self.leaveHistoryData.remove(at: originalIndex)
                                }
                                self.filteredLeaveData.remove(at: index)
                                self.historyTable.reloadData()
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

    func getLeaveRequestHistory() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_list,
                                  parameters: [LeaveRequestStringFile.member_type: "STUDENT"],
                                  type: ApitTypeSringFile.GET,
                                  token: childDetails?.access_token ?? "") { [weak self] (result: Result<LeaveInfoResponse, Error>) in

            DispatchQueue.main.async {
                guard let self = self else { return }
                if #available(iOS 15.0, *) { self.hideLottieProgressLoader() }

                switch result {
                case .success(let response):
                    self.leaveHistoryData = response.data ?? []
                    self.filteredLeaveData = self.leaveHistoryData
                    let isEmpty = self.leaveHistoryData.isEmpty
                    self.NodataImage.isHidden = !isEmpty
                    self.NodataLbl.isHidden = !isEmpty
                    self.TopInfoView.isHidden = isEmpty
                    self.historyTable.reloadData()

                case .failure(let error):
                    self.NodataLbl.text = error.localizedDescription
                    self.NodataImage.isHidden = false
                    self.NodataLbl.isHidden = false
                    self.TopInfoView.isHidden = true
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    func addUnderline(to selectedButton: UIButton, unSelectedBtn: [UIButton]) {
        ([selectedButton] + unSelectedBtn).forEach { button in
            button.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
            button.tintColor = .black
        }
        selectedButton.tintColor = .systemBlue
        let underline = UIView()
        underline.tag = 999
        underline.backgroundColor = .systemBlue
        underline.translatesAutoresizingMaskIntoConstraints = false
        selectedButton.addSubview(underline)

        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: selectedButton.bottomAnchor)
        ])
    }

    // MARK: - Filter Actions
    @IBAction func approveAct(_ sender: UIButton) {
        addUnderline(to: approveBtn, unSelectedBtn: [rejectBtn, allBtn, waitingBtn])
        filteredLeaveData = leaveHistoryData.filter { LeaveStatus.from($0.status) == .approved }
        historyTable.reloadData()
    }

    @IBAction func rejectAct(_ sender: UIButton) {
        addUnderline(to: rejectBtn, unSelectedBtn: [approveBtn, allBtn, waitingBtn])
        filteredLeaveData = leaveHistoryData.filter { LeaveStatus.from($0.status) == .rejected }
        historyTable.reloadData()
    }

    @IBAction func waitingAct(_ sender: UIButton) {
        addUnderline(to: waitingBtn, unSelectedBtn: [rejectBtn, allBtn, approveBtn])
        filteredLeaveData = leaveHistoryData.filter {
            let status = LeaveStatus.from($0.status)
            return status == .waiting
        }
        historyTable.reloadData()
    }

    @IBAction func AllAct(_ sender: UIButton) {
        addUnderline(to: allBtn, unSelectedBtn: [rejectBtn, approveBtn, waitingBtn])
        filteredLeaveData = leaveHistoryData
        historyTable.reloadData()
    }
}

// MARK: - TableView Delegate & DataSource
extension LeveHistoryVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLeaveData.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = historyTable.dequeueReusableCell(withIdentifier: CellConfingName.LeveHistoryTV, for: indexPath) as? LeveHistoryTV else {
            return UITableViewCell()
        }

        let leave = filteredLeaveData[indexPath.row]
        let name = leave.student_name
        let fromDate = convertDate(leave.leave_from, toFormat: DateFormatString.StandardFormat) ?? "N/A"
        let toDate = convertDate(leave.leave_to, toFormat: DateFormatString.StandardFormat) ?? "N/A"
        cell.rejectBtn.isHidden = true
        cell.nameLbl.text = name
        cell.dateLbl.text = "\(fromDate) - \(toDate)"
        cell.resonLbl.text = leave.reason
        cell.durationLbl.text = daysBetweenLabel(start: leave.leave_from, end: leave.leave_to)
        cell.aproveBtn.setTitle(leave.status, for: .normal)

        cell.iconBtn.setTitle(name.first.map { String($0).uppercased() } ?? "", for: .normal)
        cell.iconBtn.tag = indexPath.row
        cell.editBtn.tag = indexPath.row
        cell.deleteBtn.tag = indexPath.row
        cell.delegate = self
        cell.aproveBtn.isUserInteractionEnabled = false
        cell.rejectBtn.isUserInteractionEnabled = false
        switch LeaveStatus.from(leave.status) {
        case .approved:
            cell.aproveBtn.backgroundColor = Colornames.AprovedClr
            cell.editClickBtn.isHidden = true
        case .rejected:
            cell.aproveBtn.backgroundColor = .red
            cell.editClickBtn.isHidden = true
        case .waiting:
            cell.aproveBtn.backgroundColor = Colornames.pendingClr
            cell.aproveBtn.setTitle("Waiting", for: .normal)
            cell.editClickBtn.isHidden = false
        }

        let isPopupOpen = openedPopupIndex == indexPath
        cell.showPopup.isHidden = !isPopupOpen
        cell.iconBtn.isSelected = isPopupOpen
        cell.aproveBtn.isHidden = isPopupOpen

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissPopup()
    }

    func daysBetweenLabel(start: String?, end: String?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let fromStr = start, let toStr = end,
              let fromDate = formatter.date(from: fromStr),
              let toDate = formatter.date(from: toStr) else {
            return "( Invalid date )"
        }

        let diff = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day ?? 0
        let totalDays = diff + 1
        return totalDays == 1 ? "( 1 day )" : "( \(totalDays) days )"
    }
}
