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
    var delegate: Searchable?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NoDataImage.isHidden = true
        NoDataLbl.isHidden = true
        searchBar.isHidden = true
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        searchBar.backgroundImage = UIImage()
        NoDataLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        PopupContainerview.isHidden = true
        PopupContainerview.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        cancelMeetingDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        reasonDefLbl.setFont(style: .body, size: FontSize.TitleSize)
        continueBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        reasonDefLbl.text = "Reason for Cancelation".translated()
        cancelMeetingDefLbl.text = "Cancel Meeting".translated()
        reasonTextfield.placeholder = CommonStringFile.EnterReason.translated()
        continueBtn.setTitle("Cancel Meeting".translated(), for: .normal)
        
        reasonTextfield.addDoneButton()
        
        continueBtn.layer.cornerRadius = 8
        tv.showsVerticalScrollIndicator = false
        tv.showsHorizontalScrollIndicator = false
        tv.register(UINib(nibName: CellConfingName.BookedSlotTV, bundle: nil), forCellReuseIdentifier: CellConfingName.BookedSlotTV)
        tv.delegate = self
        tv.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        
        PopupView.layer.cornerRadius = 10
        Popuptopview.layer.cornerRadius = 10
        Popuptopview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        Popuptopview.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.searchTextField.text = ""
        get_meetings_api()
    }
    
    func get_meetings_api(){
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_slot_history_for_student, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (result: Result<SlotDetailsResponse,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                if #available(iOS 15.0, *){ self.hideActivityLoader() }
                
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
                        self.AllSections?.append(SlotSection(title: PTMString.todayMeetings.translated(), slots: today))
                    }
                    
                    if let upcoming = data.upcoming, !upcoming.isEmpty {
                        self.AllSections?.append(SlotSection(title: PTMString.upcomingMeetings.translated(), slots: upcoming))
                    }
                    
                    if let completed = data.completed, !completed.isEmpty {
                        self.AllSections?.append(SlotSection(title: PTMString.completedMeetings.translated(), slots: completed))
                    }
                    
                    self.FilteredSection = self.AllSections
                    self.NoDataLbl.isHidden = !(self.FilteredSection?.isEmpty ?? false)
                    self.NoDataImage.isHidden = !(self.FilteredSection?.isEmpty ?? false)
                    self.delegate?.childViewController(self, didUpdateDataIsEmpty: self.FilteredSection?.isEmpty ?? false)
                    self.tv.reloadData()
                    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed.translated(), message: failure.localizedDescription, on: self) {
                        self.NoDataLbl.isHidden = false
                        self.NoDataImage.isHidden = false
                        self.NoDataLbl.text = failure.localizedDescription
                    }
                }
            }
        }
    }
    
    func Cancel_meeting_Api(){
        
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        let param: [String:Any] = [PTMRequestStringFile.slot_id:cancelId ?? "", PTMRequestStringFile.cancelled_reason: reasonTextfield.text ?? ""]
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_cancel_slot_by_student, parameters: param, type: ApitTypeSringFile.PUT, token: childDetails?.access_token ?? "", isBaseUrl: true) {[weak self] (result:Result<CommonApiSuc,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                if #available(iOS 15.0, *){ self.hideActivityLoader() }
                switch result {
                case .success(let success):
                    if success.status == true{
                        //self.get_meetings_api()
                        self.removeCancelledSlotFromUI(slotId: self.cancelId ?? "")
                        self.hidePopup()
                    }else{
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed.translated(), message: success.message ?? "", on: self)
                    }
                    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed.translated(), message: failure.localizedDescription, on: self)
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

        NoDataImage.isHidden = !(FilteredSection?.isEmpty ?? false)
        NoDataLbl.isHidden = !(FilteredSection?.isEmpty ?? false)
    }

    
    
    @IBAction func ClosePopupAct(_ sender: Any) {
        
        hidePopup()
    }
    
    @IBAction func ContinueCalncelationAct(_ sender: Any) {
        if reasonTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true{
            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Missing_Information.translated(), message: PTMString.Please_enter_reason_for_cancelation.translated(), on: self)
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
        reasonTextfield.text = ""
        reasonTextfield.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.PopupContainerview.alpha = 0
        }) { _ in
            self.PopupContainerview.isHidden = true
        }
    }
    
    func callButtonTapped(Mobile: String) {
           if let url = URL(string: "tel://\(Mobile)"),
              UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url)
           } else {
               print("This device cannot make phone calls.")
           }
       }
    
    func JoinButtonTapped(Link: String) {
        var fixedLink = Link
        if !fixedLink.lowercased().hasPrefix("http") {
            fixedLink = "https://" + fixedLink
        }
        
        if let url = URL(string: fixedLink) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot open meeting link")
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
        cell.subjectLbl.text = slot?.subject_name?.first
        cell.dateBtn.setTitle(slot?.date?.convertToTargetDateFormat(), for: .normal)
        cell.TimeBtn.setTitle(slot?.time, for: .normal)
        let duration = String(slot?.duration ?? 0) + " min"
        cell.DurationBtn.setTitle(duration, for: .normal)
        cell.ModeBtn.setTitle(slot?.mode, for: .normal)
        cell.callBtn.isHidden = slot?.mode != "Phone Call"
        cell.JoinBtn.isHidden = slot?.mode != "Virtual"
        cell.cancelBtn.isHidden = slot?.status == "Completed"
        cell.statusBtn.setTitle(slot?.status?.translated(), for: .normal)
        cell.DateLbl.text = slot?.date?.convertToTargetDateFormat()
        cell.TimeLbl.text = slot?.time
        
        if slot?.mode == "In Person"{
            cell.ModeBtn.setImage(UIImage(systemName: "person.2.fill"), for: .normal)
        }else if slot?.mode == "Phone Call"{
            cell.ModeBtn.setImage(UIImage(systemName: "phone"), for: .normal)
        }else if slot?.mode == "Virtual" {
            cell.ModeBtn.setImage(UIImage(systemName: "network"), for: .normal)
        }
        
        if slot?.is_cancelled_by_staff == true{
            cell.statusBtn.setTitle("Cancelled".translated(), for: .normal)
            cell.statusBtn.backgroundColor = .systemRed.withAlphaComponent(0.7)
            cell.statusBtn.setTitleColor(.white, for: .normal)
            cell.cancelStackTop.constant = 0
            cell.cancelStackHeight.constant = 0
            cell.callBtn.isHidden = true
            cell.cancelBtn.isHidden = true
            cell.JoinBtn.isHidden = true
        }else{
            
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
                cell.JoinBtn.isHidden = true
                cell.statusBtn.backgroundColor = .systemGreen.withAlphaComponent(0.7)
                cell.statusBtn.setTitleColor(.white, for: .normal)
            }
        }
        
        
        cell.onCancel = { [weak self] in
            //self?.Cancel_meeting_Api()
            self?.cancelId = slot?.id
            self?.showPopup()
            
        }
        
        cell.onCall = { [weak self] in
            self?.callButtonTapped(Mobile: slot?.staff_mobile_no ?? "")
        }
        
        cell.onJoin = {[weak self] in
            self?.JoinButtonTapped(Link: slot?.event_link ?? "")
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
    
    func searchBtnAct(selected:Bool){
        
        if selected{
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
        }else{
            searchBar.searchTextField.text = ""
            searchBar.isHidden = true
            searchBar.resignFirstResponder()
            FilteredSection = AllSections
            NoDataImage.isHidden = true
            NoDataLbl.isHidden = true
            tv.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        
        if query.isEmpty{
            FilteredSection = AllSections
        }else{
            
            FilteredSection = AllSections?.compactMap { section in
                let filteredSlots = section.slots.filter { slot in
                    (slot.purpose?.lowercased().contains(query) ?? false) ||
                    (slot.staff_name?.lowercased().contains(query) ?? false) ||
                    (slot.subject_name?.first?.lowercased().contains(query) ?? false) ||
                    (slot.status?.lowercased().contains(query) ?? false) ||
                    (slot.date?.convertToTargetDateFormat()?.lowercased().contains(query) ?? false) ||
                    (slot.time?.lowercased().contains(query) ?? false)
                }
                return filteredSlots.isEmpty ? nil : SlotSection(title: section.title, slots: filteredSlots)
            }
        }
        
        if  FilteredSection?.isEmpty == true{
            NoDataLbl.isHidden = false
            NoDataImage.isHidden = false
        }else{
            NoDataLbl.isHidden = true
            NoDataImage.isHidden = true
        }
        
        tv.reloadData()
    }
}
