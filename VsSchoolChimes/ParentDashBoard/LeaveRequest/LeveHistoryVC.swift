//
//  LeveHistoryVC.swift
//  VsSchoolChimes
//

import UIKit


enum LeaveFilterType: String {
    case all = "All"
    case approved = "Approved"
    case rejected = "Rejected"
    case waiting = "Waiting for approval"
}


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

class LeveHistoryVC: UIViewController, EditDeleteDelegate {

    @IBOutlet weak var LeaveRequestsLbl: UILabel!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var waitingBtn: UIButton!
    @IBOutlet weak var historyTable: UITableView!
    @IBOutlet weak var NodataLbl: UILabel!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var TopInfoView: UIView!
    @IBOutlet weak var Backbtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var studentNameLbl: UILabel!
    
    let alert = CustomAlert()
    var leaveHistoryData: [LeaveMonth] = []
    var filteredLeaveData: [LeaveMonth] = []
    var SearchLeaveData: [LeaveMonth] = []
    var childDetails = UserDefaultFileManager.get_child_Details()
    var openedPopupIndex: IndexPath?
    var delegate: EditObject?
    var selectedFilter: LeaveFilterType = .all
    var searchText: String = ""
    var PushnotiMsg_id : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TopView.layer.cornerRadius = 20
        TopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        let name = childDetails?.name ?? ""
        let stanard = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        studentNameLbl.configureAsBackTitle(firstLine: name, secondLine: stanard)
        
        LeaveRequestsLbl.setFont(style: .header, size: 20)
        LeaveRequestsLbl.text = AttendanceString.leaveRequests
        
        allBtn.setTitle(CommonStringFile.all.translated(), for: .normal)
        rejectBtn.setTitle(AttendanceString.rejected.translated(), for: .normal)
        approveBtn.setTitle(AttendanceString.approved.translated(), for: .normal)
        waitingBtn.setTitle(AttendanceString.waiting.translated(), for: .normal)
        
        allBtn.titleLabel?.numberOfLines = 0
        allBtn.titleLabel?.lineBreakMode = .byWordWrapping
        rejectBtn.titleLabel?.numberOfLines = 0
        rejectBtn.titleLabel?.lineBreakMode = .byWordWrapping
        approveBtn.titleLabel?.numberOfLines = 0
        approveBtn.titleLabel?.lineBreakMode = .byWordWrapping
        waitingBtn.titleLabel?.numberOfLines = 0
        waitingBtn.titleLabel?.lineBreakMode = .byWordWrapping
        
        addUnderline(to: allBtn, unSelectedBtn: [rejectBtn, approveBtn, waitingBtn])
        NodataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        NodataLbl.text = CommonStringFile.No_data_found.translated()

        TopInfoView.isHidden = true
        NodataImage.isHidden = true
        NodataLbl.isHidden = true
        
        searchBar.isHidden = true
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.backgroundImage = UIImage()

        historyTable.register(UINib(nibName: CellConfingName.LeaveHistoryTV, bundle: nil), forCellReuseIdentifier: CellConfingName.LeaveHistoryTV)
        historyTable.delegate = self
        historyTable.dataSource = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getLeaveRequestHistory()
    }

    @objc func dismissPopup() {
        guard let index = openedPopupIndex,
              let cell = historyTable.cellForRow(at: index) as? LeaveHistoryTV else { return }

        cell.hidePopup()
        openedPopupIndex = nil
    }
    
    func edit(edit: IndexPath?, delete: IndexPath?) {
        if let row = edit, delete?.row == -999 {
            // Handle popup show/hide
            if let previous = openedPopupIndex, previous != row,
               let prevCell = historyTable.cellForRow(at: previous) as? LeaveHistoryTV {
                prevCell.hidePopup()
            }

            if openedPopupIndex == row {
                if let cell = historyTable.cellForRow(at: row) as? LeaveHistoryTV {
                    cell.hidePopup()
                    openedPopupIndex = nil
                }
            } else {
                if let cell = historyTable.cellForRow(at: row) as? LeaveHistoryTV {
                    cell.popupView.isHidden = false
                    openedPopupIndex = row
                }
            }
            return
        }

        // EDIT action
        if let editIndexPath = edit {
            let leave = filteredLeaveData[editIndexPath.section].details?[editIndexPath.row]
                guard let leave = leave else { return }

            if #available(iOS 14.0, *) {
                let vc = LeveCreateVC(nibName: nil, bundle: nil)
                
                vc.editLeaveData = editLeave(
                        id: leave.id,
                        fromDate: leave.leave_from ?? "",
                        toDate: leave.leave_to ?? "",
                        reson: leave.reason ?? "",
                        fromSession: leave.from_session ?? "",
                        Tosession: leave.to_session ?? "",
                        NoOfDays: leave.no_of_days ?? "",
                        LeaveType: leave.leave_type ?? "",
                        LeaveTypeId: leave.leave_type_id ?? 0,
                    )
                
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            }

        // DELETE action
        if let deleteIndexPath = delete {
            if let idToDelete = filteredLeaveData[deleteIndexPath.section].details?[deleteIndexPath.row].id {
                deleteLeave(id: idToDelete, indexPath: deleteIndexPath)
            }
        }
    }
    
    
    func deleteLeave(id: String, indexPath: IndexPath) {
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

                                // Remove from originalData
                                if let originalSectionIndex = self.leaveHistoryData.firstIndex(where: { $0.month == self.filteredLeaveData[indexPath.section].month }),
                                   let originalRowIndex = self.leaveHistoryData[originalSectionIndex].details?.firstIndex(where: { $0.id == id }) {
                                    self.leaveHistoryData[originalSectionIndex].details?.remove(at: originalRowIndex)

                                    // Remove entire section if empty
                                    if self.leaveHistoryData[originalSectionIndex].details?.isEmpty ?? false {
                                        self.leaveHistoryData.remove(at: originalSectionIndex)
                                    }
                                }

                                // Remove from filteredData
                                self.filteredLeaveData[indexPath.section].details?.remove(at: indexPath.row)
                                if self.filteredLeaveData[indexPath.section].details?.isEmpty ?? false {
                                    self.filteredLeaveData.remove(at: indexPath.section)
                                }

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
            showActivityLoader()
        }
        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_list,
                                  parameters: [LeaveRequestStringFile.member_type: "STUDENT"],
                                  type: ApitTypeSringFile.GET,
                                  token: childDetails?.access_token ?? "") { [weak self] (result: Result<LeaveInfoResponse, Error>) in

            DispatchQueue.main.async {
                guard let self = self else { return }
                if #available(iOS 15.0, *) {  self.hideActivityLoader() }

                switch result {
                case .success(let response):
                    
                    if response.status == true{
                        self.leaveHistoryData = response.data ?? []
                        self.filteredLeaveData = self.leaveHistoryData
                        let isEmpty = self.leaveHistoryData.isEmpty
                        self.NodataLbl.text = response.message
                        self.NodataImage.isHidden = !isEmpty
                        self.NodataLbl.isHidden = !isEmpty
                        self.TopInfoView.isHidden = isEmpty
                        self.searchBtn.isHidden = isEmpty
                        self.applyFilter()
                        // self.historyTable.reloadData()
                        if self.PushnotiMsg_id != ""{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                self.scrollToLeave(with: self.PushnotiMsg_id ?? "")
                            }
                        }

                    }else{
                        self.NodataImage.isHidden = false
                        self.NodataLbl.isHidden = false
                        self.TopInfoView.isHidden = true
                        self.searchBtn.isHidden = true
                    }

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
    
    
    private func scrollToLeave(with id: String) {
        
        for (sectionIndex, month) in filteredLeaveData.enumerated() {
            if let rowIndex = month.details?.firstIndex(where: { $0.id == id }) {
                
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                
                historyTable.scrollToRow(at: indexPath, at: .middle, animated: true)
                
                highlightCell(at: indexPath)
                return
            }
        }
    }

    private func highlightCell(at indexPath: IndexPath) {
        guard let cell = historyTable.cellForRow(at: indexPath) else { return }

        UIView.animate(withDuration: 0.3, animations: {
            cell.contentView.backgroundColor = UIColor.lightGray
        }) { _ in
            UIView.animate(withDuration: 0.6, delay: 1.0, options: []) {
                cell.contentView.backgroundColor = .clear
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
    
    @IBAction func searchBtnAct(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected{
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
            searchBtn.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else{
            searchBar.isHidden = true
            view.endEditing(true)
            searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            searchBar.searchTextField.text = ""
            searchText = ""
            applyFilter()
        }
    }
    
    // MARK: - Filter Actions
    @IBAction func approveAct(_ sender: UIButton) {
        addUnderline(to: approveBtn, unSelectedBtn: [rejectBtn, allBtn, waitingBtn])
       // filteredLeaveData = leaveHistoryData.filter { LeaveStatus.from($0.status) == .approved }
//        historyTable.reloadData()
        selectedFilter = .approved
        applyFilter()
    }

    @IBAction func rejectAct(_ sender: UIButton) {
        addUnderline(to: rejectBtn, unSelectedBtn: [approveBtn, allBtn, waitingBtn])
       // filteredLeaveData = leaveHistoryData.filter { LeaveStatus.from($0.status) == .rejected }
       // historyTable.reloadData()
        selectedFilter = .rejected
            applyFilter()
    }

    @IBAction func waitingAct(_ sender: UIButton) {
        addUnderline(to: waitingBtn, unSelectedBtn: [rejectBtn, allBtn, approveBtn])
//        filteredLeaveData = leaveHistoryData.filter {
//            let status = LeaveStatus.from($0.status)
//            return status == .waiting
//        }
       // historyTable.reloadData()
        selectedFilter = .waiting
            applyFilter()
    }
    

    @IBAction func AllAct(_ sender: UIButton) {
        addUnderline(to: allBtn, unSelectedBtn: [rejectBtn, approveBtn, waitingBtn])
//        filteredLeaveData = leaveHistoryData
//        historyTable.reloadData()
        selectedFilter = .all
            applyFilter()
    }
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}

// MARK: - TableView Delegate & DataSource
extension LeveHistoryVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        filteredLeaveData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .clear  // Customize color

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFont(style: .title, size: FontSize.TitleSize)
        label.textColor = .darkGray
        label.text = filteredLeaveData[section].month
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)])

        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLeaveData[section].details?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = historyTable.dequeueReusableCell(withIdentifier: CellConfingName.LeaveHistoryTV, for: indexPath) as! LeaveHistoryTV
        
        let data = filteredLeaveData[indexPath.section].details?[indexPath.row]//filteredLeaveData[indexPath.row]
        
//        cell.DaysCountLbl.text = (data?.no_of_days ?? "") + " " + AttendanceString.dayApplication
        
        if let daysString = data?.no_of_days,
           let days = Double(daysString) {
            let unit = days > 1 ? "days" : "day"
            cell.DaysCountLbl.text = "\(daysString) \(unit) Application"
        } else {
            cell.DaysCountLbl.text = "0 day Application"
        }

        
        cell.DateLbl.text = "\(data?.leave_from?.convertToTargetDateFormat() ?? "") - \(data?.leave_to?.convertToTargetDateFormat() ?? "")"
        cell.TypeLbl.text = data?.leave_type
        cell.ReasonLbl.text = data?.reason
        
        switch LeaveStatus.from(data?.status ?? "") {
        
        case.approved:
            cell.StatusBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
            cell.StatusBtn.setTitleColor(.systemGreen, for: .normal)
            cell.StatusBtn.setTitle(AttendanceString.approved.translated(), for: .normal)
            cell.OptionsBtn.isHidden = true
            cell.GetOutpassBtn.isHidden = false
        case.rejected:
            cell.StatusBtn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            cell.StatusBtn.setTitleColor(.red, for: .normal)
            cell.StatusBtn.setTitle(AttendanceString.rejected.translated(), for: .normal)
            cell.OptionsBtn.isHidden = true
            cell.GetOutpassBtn.isHidden = true
        case.waiting:
            cell.StatusBtn.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
            cell.StatusBtn.setTitleColor(.brown, for: .normal)
            cell.StatusBtn.setTitle(AttendanceString.awaiting.translated(), for: .normal)
            cell.OptionsBtn.isHidden = false
            cell.GetOutpassBtn.isHidden = true
        }
        
        if let title = cell.StatusBtn.title(for: .normal),
           let font = cell.StatusBtn.titleLabel?.font {
            
            let textWidth = (title as NSString).size(withAttributes: [.font: font]).width
            cell.statusBtnWidth.constant = textWidth + 20
        }
        
        let isPopupOpen = openedPopupIndex == indexPath
        cell.popupView.isHidden = !isPopupOpen
        cell.OptionsBtn.isSelected = isPopupOpen
        cell.indexPath = indexPath
        cell.delegate = self
        
        cell.outpassAction = { [weak self] indexPath in
            self?.presentOutpassVC(for: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

//
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissPopup()
    }
    
//    func applyFilter() {
//        guard selectedFilter != .all else {
//            filteredLeaveData = leaveHistoryData
//            historyTable.reloadData()
//            return
//        }
//
//        filteredLeaveData = leaveHistoryData.compactMap { month in
//            let filteredDetails = month.details?.filter {
//                $0.status == selectedFilter.rawValue
//            }
//            if let details = filteredDetails, !details.isEmpty {
//                return LeaveMonth(month: month.month, details: details)
//            }
//            return nil
//        }
//        
//        historyTable.reloadData()
//    }
    
    func applyFilter() {
        // 1. Apply status filter first
        var baseData: [LeaveMonth]

        if selectedFilter == .all {
            baseData = leaveHistoryData
        } else {
            baseData = leaveHistoryData.compactMap { month in
                let filteredDetails = month.details?.filter {
                    $0.status == selectedFilter.rawValue
                }
                if let details = filteredDetails, !details.isEmpty {
                    return LeaveMonth(month: month.month, details: details)
                }
                return nil
            }
        }

        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let lowercasedQuery = searchText.lowercased()

            filteredLeaveData = baseData.compactMap { month in
                let filteredDetails = month.details?.filter { info in
                    // Convert leave_from & leave_to into display format
                    let fromDate = info.leave_from?.convertToTargetDateFormat()
                    let toDate   = info.leave_to?.convertToTargetDateFormat()

                    return
//                        (info.student_name?.lowercased().contains(lowercasedQuery) ?? false) ||
//                        (info.class_name?.lowercased().contains(lowercasedQuery) ?? false) ||
//                        (info.section_name?.lowercased().contains(lowercasedQuery) ?? false) ||
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
            filteredLeaveData = baseData
        }

        NodataLbl.text = CommonStringFile.No_data_found
        NodataLbl.isHidden = !filteredLeaveData.isEmpty
        NodataImage.isHidden = !filteredLeaveData.isEmpty
        historyTable.reloadData()
    }

    
    func presentOutpassVC(for indexPath: IndexPath) {
        guard let leave = filteredLeaveData[indexPath.section].details?[indexPath.row] else { return }

        let vc = OutpassVC(nibName: nil, bundle: nil)
        vc.leaveInfo = leave
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
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

extension LeveHistoryVC: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           self.searchText = searchText
           applyFilter()
       }

       // Optional: hide keyboard when user taps search button
       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()
       }
}

