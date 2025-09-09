//
//  PtmHistoryVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 02/09/25.
//

struct SlotSection {
    let title: String
    var slots: [BookedSlotItem]
}

import UIKit

class PtmHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var PopupContainerview: UIView!
    @IBOutlet weak var PopupView: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var reasonTextfield: PaddedTextField!
    @IBOutlet weak var Popuptopview: UIView!
    @IBOutlet weak var cancelMeetingDefLbl: UILabel!
    @IBOutlet weak var reasonDefLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var NoDataImage: UIImageView!
    
    
    
    let childDetails = UserDefaultFileManager.get_child_Details()
    var slotData: [SlotCategory]?
    var AllSections : [SlotSection]?
    var FilteredSection : [SlotSection]?
    var cancelId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NoDataImage.isHidden = true
        NoDataLbl.isHidden = true
        searchBar.isHidden = true
        searchBar.placeholder = CommonStringFile.Search
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        NoDataLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        PopupContainerview.isHidden = true
        PopupContainerview.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        cancelMeetingDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        reasonDefLbl.setFont(style: .body, size: FontSize.TitleSize)
        continueBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        continueBtn.layer.cornerRadius = 8
    
        tv.register(UINib(nibName: CellConfingName.BookedSlotTV, bundle: nil), forCellReuseIdentifier: CellConfingName.BookedSlotTV)
        tv.delegate = self
        tv.dataSource = self
        
        get_meetings_api()
    }
    
    override func viewDidLayoutSubviews() {
        
        PopupView.layer.cornerRadius = 10
        Popuptopview.layer.cornerRadius = 10
        Popuptopview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        Popuptopview.clipsToBounds = true
    }
    
    func get_meetings_api(){
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_slot_history_for_student, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") { [weak self] (result: Result<SlotDetailsResponse,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    
                    self.slotData = success.data
                    self.AllSections = []
                    self.FilteredSection = []
                    
                    guard let data = success.data?.first else {
                        
                        self.NoDataLbl.text = success.message
                        self.NoDataLbl.isHidden = false
                        self.NoDataImage.isHidden = false
                        return
                    }
                    
                    if let today = data.today, !today.isEmpty {
                        self.AllSections?.append(SlotSection(title: PTMString.todayMeetings, slots: today))
                    }
                    
                    if let upcoming = data.upcoming, !upcoming.isEmpty {
                        self.AllSections?.append(SlotSection(title: PTMString.upcomingMeetings, slots: upcoming))
                    }
                    
                    if let completed = data.completed, !completed.isEmpty {
                        self.AllSections?.append(SlotSection(title: PTMString.completedMeetings, slots: completed))
                    }
                    
                    self.FilteredSection = self.AllSections
                    self.tv.reloadData()
                    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self) {
                        self.NoDataLbl.isHidden = false
                        self.NoDataImage.isHidden = false
                        self.NoDataLbl.text = failure.localizedDescription
                    }
                }
            }
        }
    }
    
    func Cancel_meeting_Api(){
        
        let param: [String:Any] = [PTMRequestStringFile.slot_id:cancelId ?? "", PTMRequestStringFile.cancelled_reason: reasonTextfield.text ?? ""]
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_cancel_slot_by_student, parameters: param, type: ApitTypeSringFile.PUT, token: childDetails?.access_token ?? "") {[weak self] (result:Result<CommonApiSuc,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    if success.status == true{
                        //self.get_meetings_api()
                        self.removeCancelledSlotFromUI(slotId: self.cancelId ?? "")
                        self.hidePopup()
                    }else{
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                }
            }
        }
    }
    
    private func removeCancelledSlotFromUI(slotId: String) {
        
        if let sectionIndex = FilteredSection?.firstIndex(where: { $0.slots.contains(where: { $0.id == slotId }) }),
           let rowIndex = FilteredSection?[sectionIndex].slots.firstIndex(where: { $0.id == slotId }) {
            
            FilteredSection?[sectionIndex].slots.remove(at: rowIndex)
            
            if FilteredSection?[sectionIndex].slots.isEmpty == true {
                FilteredSection?.remove(at: sectionIndex)
                tv.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            } else {
                tv.deleteRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .fade)
            }
        }

    }

    
    
    @IBAction func ClosePopupAct(_ sender: Any) {
        
        hidePopup()
    }
    
    @IBAction func ContinueCalncelationAct(_ sender: Any) {
        if reasonTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true{
            CustomAlert.showAlertWithOkAction(title: "Missing Information", message: "Please enter reson for cancelation", on: self)
        }else {
            Cancel_meeting_Api()
        }
    }
    
    func showPopup() {
        PopupContainerview.alpha = 0
        PopupContainerview.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.PopupContainerview.alpha = 1
        }
    }

    func hidePopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.PopupContainerview.alpha = 0
        }) { _ in
            self.PopupContainerview.isHidden = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        FilteredSection?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .clear  // Customize color

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFont(style: .title, size: FontSize.TitleSize)
        label.textColor = .darkGray
        label.text = FilteredSection?[section].title
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)])

        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FilteredSection?[section].slots.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.BookedSlotTV, for: indexPath) as! BookedSlotTV
        let slot = FilteredSection?[indexPath.section].slots[indexPath.row]
        
        cell.MeetingNameLbl.text = slot?.purpose
        cell.staffNameLbl.text = "with "  + (slot?.staff_name ?? "")
        cell.subjectLbl.text = slot?.subject_name
        cell.dateBtn.setTitle(slot?.date, for: .normal)
        cell.TimeBtn.setTitle(slot?.time, for: .normal)
        cell.DurationBtn.setTitle("15 min", for: .normal)
        cell.ModeBtn.setTitle(slot?.mode, for: .normal)
        cell.callBtn.isHidden = slot?.mode != "Phone Call"
        cell.cancelBtn.isHidden = slot?.status == "Completed"
        cell.statusBtn.setTitle(slot?.status, for: .normal)
        
        if slot?.status == "Upcoming"{
            cell.cancelStackTop.constant = 20
            cell.cancelStackHeight.constant = 35
            cell.statusBtn.backgroundColor = .systemBlue.withAlphaComponent(0.7)
            cell.statusBtn.setTitleColor(.white, for: .normal)
        }else{
            cell.cancelStackTop.constant = 0
            cell.cancelStackHeight.constant = 0
            cell.callBtn.isHidden = true
            cell.cancelBtn.isHidden = true
            cell.statusBtn.backgroundColor = .systemGreen.withAlphaComponent(0.7)
            cell.statusBtn.setTitleColor(.white, for: .normal)
        }
        
        cell.onCancel = { [weak self] in
            //self?.Cancel_meeting_Api()
            self?.cancelId = slot?.id
            self?.showPopup()
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}


extension PtmHistoryVC: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
                FilteredSection = AllSections
                tv.reloadData()
                return
            }
            
            let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
            
        FilteredSection = AllSections?.compactMap { section in
                let filteredSlots = section.slots.filter { slot in
                    (slot.purpose?.lowercased().contains(query) ?? false) ||
                    (slot.staff_name?.lowercased().contains(query) ?? false) ||
                    (slot.subject_name?.lowercased().contains(query) ?? false) ||
                    (slot.status?.lowercased().contains(query) ?? false) ||
                    (slot.date?.convertToTargetDateFormat()?.lowercased().contains(query) ?? false) ||
                    (slot.time?.lowercased().contains(query) ?? false)
                }
                return filteredSlots.isEmpty ? nil : SlotSection(title: section.title, slots: filteredSlots)
            }
            
            tv.reloadData()
        }
}
