//
//  EventHistoryVC.swift
//  VsSchoolChimes
//
//  Created by chandhru on 04/12/24.
//

import UIKit
import DropDown

@available(iOS 14.0, *)
class EventHistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, SelectedId {
    func selectId(id: String?, edit: Bool?) {
        if edit ?? false{
            if let selectedEvent = event(withId: id ?? "") {
                //                delegate?.editDta(edit: selectedEvent)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let vc = EventsVC()
                    
                    vc.editReport = selectedEvent
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
            
            
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.deleteEvent(id:id ?? "")
            }
        }
    }
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backBtn: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var schoolDropDown: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var nodataImg: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var historyTable: UITableView!
    var previousOffset: CGFloat = 0.0
    var selectedIndex:Int?
    var allEventSections: [EventDisplaySection] = []
    var filteredSections: [EventDisplaySection] = []
    var baseSection: [EventDisplaySection] = []
    let transitionDelegate = TransitioningDelegate()
    let alert = CustomAlert()
    var Scholldetails = UserDefaultFileManager.getUserDetails()
    var staffdetails = UserDefaultFileManager.get_staff_Details()
    var school_details = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var schoolList:[String]?
    var token : String?
    let dropDown = DropDown()
    var delegate:EditObjectDelegate?
    var SchoolId : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        backBtn
            .configureAsBackTitle(
                firstLine: MenuStringFile.selectedMenuName,
                secondLine: UserDefaultFileManager
                    .get_staff_Details()?.school_name ?? ""
            )
        historyTable.register(UINib(nibName: CellConfingName.EventTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.EventTVC)
        historyTable.register(UINib(nibName: "OngoingTVC", bundle: nil), forCellReuseIdentifier: "OngoingTVC")
        historyTable.register(UINib(nibName: "ReciverEventTVC", bundle: nil), forCellReuseIdentifier: "ReciverEventTVC")
        historyTable.delegate = self
        historyTable.dataSource = self
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.applyRightTxt()
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .clear
        searchBar.delegate = self
        searchBar.addDoneButton()
        searchBar.searchTextField.addDoneButton()
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        if #available(iOS 15.0, *) {
            historyTable.sectionHeaderTopPadding = 0
            historyTable.tableFooterView = nil
        }
        if let staffToken = staffdetails?.access_token {
            let matchedSchoolName = school_details?
                .first?
                .school_name
            token = staffToken
            schoolName.text = "All"
        }
        if checkMutipleSchool() {
            schoolDropDown.isHidden = true
            schoolList = school_details?.compactMap { $0.school_name }
            schoolList?.insert("All", at: 0)
            self.dropDown.dataSource = self.schoolList ?? []
        } else {
            schoolDropDown.isHidden = true
            searchView.isHidden = true
        }
        schoolDropDown.setShadow(cornerRadius: 4)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(catagoryTapped))
        schoolDropDown.isUserInteractionEnabled = true
        schoolDropDown.addGestureRecognizer(tapGesture)
        
    }
    @objc func catagoryTapped() {
        print("Category View Tapped")
        dropDown.anchorView = schoolDropDown
        dropDown.show()
        dropDown.bottomOffset = CGPoint(x: 0, y: schoolDropDown.bounds.height)
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            schoolName.text = item
            
            if item == "All" {
                filterUsingSchoolId("All")
            }else{
                if let selectedSchool = school_details?.first(where: { $0.school_name == item }) {
                    token = selectedSchool.access_token
                    localData.editToken = selectedSchool.access_token
                    filterUsingSchoolId(selectedSchool.school_id ?? "All")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        
                    }
                }
                
            }
        }
    }
    
    
    func filterUsingSchoolId(_ schoolId: String) {
        print("schoolIdschoolId",schoolId)
        if schoolId == "All" {
            filteredSections = allEventSections
            baseSection = filteredSections
        } else {
            filteredSections = allEventSections.compactMap { section in
                switch section {
                case .featured(let events):
                    let filtered = events.filter { $0.school_id == schoolId }
                    return filtered.isEmpty ? nil : .featured(filtered)
                case .categories(let categories):
                    return .categories(categories)
                case .upcoming(let events):
                    let filtered = events.filter { $0.school_id == schoolId }
                    return filtered.isEmpty ? nil : .upcoming(filtered)
                case .completed(let events):
                    let filtered = events.filter { $0.school_id == schoolId }
                    return filtered.isEmpty ? nil : .completed(filtered)
                case .nodata:
                    return nil
                }
            }
        }
        historyTable.reloadData()
    }
    
    func checkMutipleSchool() -> Bool {
        let staffCount = Scholldetails?.user_details?.staff_details?.count ?? 0
        if staffCount > 1 {
            switch Scholldetails?.user_details?.staff_details?.first?.priority_level {
            case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                return true
            default:
                return false
            }
        }
        return false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GetEvent()
    }
    func searchHide(hide: Bool) {
        searchBar?.isHidden = !hide
        searchView?.isHidden = !hide
        if hide {
            searchBar?.becomeFirstResponder()
            
        } else {
            searchBar?.resignFirstResponder()
        }
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        searchBar?.isHidden = !sender.isSelected
        searchView?.isHidden = !sender.isSelected && schoolDropDown.isHidden
        if sender.isSelected {
            searchBar?.becomeFirstResponder()
        } else {
            filteredSections = baseSection
            let hasData = !self.filteredSections.isEmpty
            self.noDataLbl.isHidden = hasData
            self.nodataImg.isHidden = hasData
            self.historyTable.reloadData()
            searchBar.searchTextField.text = ""
            searchBar?.resignFirstResponder()
        }
    }
    // MARK: - API Call
    func GetEvent() {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.admin_api_school_event_report,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if #available(iOS 15.0, *) {
                    self.hideActivityLoader()
                }
                
                switch result {
                case .success(let response):
                    self.allEventSections.removeAll()
                    if let section = response.data?.first {
                        if var categories = section.categories, !categories.isEmpty {
                            let allCategory = EventCategory(id: nil, name: "All", url: "")
                            categories.insert(allCategory, at: 0)
                            self.allEventSections.append(.categories(categories))
                        }
                        if let onGoing = section.on_going, !onGoing.isEmpty {
                            self.allEventSections.append(.featured(onGoing))
                        }
                        if let upcoming = section.up_coming, !upcoming.isEmpty {
                            self.allEventSections.append(.upcoming(upcoming))
                        }
                        if let completed = section.completed, !completed.isEmpty {
                            self.allEventSections.append(.completed(completed))
                        }
                    }
                    
                    self.filteredSections = self.allEventSections
                    let hasData = !self.allEventSections.isEmpty
                    self.noDataLbl.isHidden = hasData
                    self.noDataLbl.text = response.message
                    self.nodataImg.isHidden = hasData
                    self.searchBtn.isHidden = !hasData
                    self.historyTable.reloadData()
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    self.noDataLbl.text = error.localizedDescription
                    self.noDataLbl.isHidden = false
                    self.nodataImg.isHidden = false
                    self.searchBar.isHidden = true
                }
            }
        }
    }
    func loadFiles(into cell: ReciverEventTVC, files: [FilePath]) {
        [cell.img1, cell.img2, cell.img3].forEach { $0?.isHidden = true }
        cell.imgCount.isHidden = true
        
        for (index, item) in files.enumerated() {
            guard index < 3 else { break }
            
            guard let urlString = item.url, let url = URL(string: urlString) else { continue }
            
            let imageViews = [cell.img1, cell.img2, cell.img3]
            guard index < imageViews.count, let imageView = imageViews[index] else { continue }
            
            imageView.isHidden = false
            
            if item.type?.lowercased() != "image" {
                let iconName = getFileIconName(for: url)
                imageView.image = UIImage(named: iconName)
            } else {
                imageView.kf.setImage(with: url)
            }
        }
        
        if files.count > 3 {
            let extraCount = files.count - 3
            if let button = cell.imgCount as? UIButton {
                button.setTitle("+\(extraCount)", for: .normal)
                cell.imgCount.isHidden = false
            }
        }
    }
    func deleteEvent(id: String?) {
        guard let noticeId = id, !noticeId.isEmpty else {
            print("Invalid notice ID")
            return
        }
        
        alert.showAlertCancel(
            title: AlertstringFile.Confirm,
            message: AlertstringFile.deletemessage,
            actionLbl1: AlertstringFile.delete,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                APIService.shared.makeApi(
                    url: ServiceUrl.admin_api_school_event_delete,
                    parameters: ["id": noticeId],
                    type: ApitTypeSringFile.PUT,
                    token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
                ) { [weak self] (result: Result<ResetPasswordSuc, Error>) in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let successResponse):
                            if successResponse.status == true {
                                CustomAlert.showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: successResponse.message ?? "",
                                    on: self
                                ) {
                                    self.removeEvent(withId: noticeId)
                                }
                            } else {
                                self.alert.showAlert(
                                    title: AlertstringFile.Failed,
                                    message: successResponse.message ?? "",
                                    on: self
                                )
                            }
                            
                        case .failure(let error):
                            print("Error deleting notice: \(error.localizedDescription)")
                            self.alert.showAlert(title: "Error", message: error.localizedDescription, on: self)
                        }
                    }
                }
            },
            onNo: {
                print("User canceled deletion")
            }
        )
    }
    func removeEvent(withId eventId: String) {
        func removeEvent(from section: EventDisplaySection) -> EventDisplaySection? {
            switch section {
            case .upcoming(let events):
                let updated = events.filter { $0.id != eventId }
                return updated.isEmpty ? nil : .upcoming(updated)
            case .completed(let events):
                let updated = events.filter { $0.id != eventId }
                return updated.isEmpty ? nil : .completed(updated)
            default:
                return section
            }
        }
        
        // Remove from filteredSections
        filteredSections = filteredSections.compactMap { removeEvent(from: $0) }
        
        // Remove from allEventSections (for reset support)
        allEventSections = allEventSections.compactMap { removeEvent(from: $0) }
        let hasData = !self.allEventSections.isEmpty
        self.noDataLbl.isHidden = hasData
        self.nodataImg.isHidden = hasData
        self.searchBar.isHidden = !hasData
        historyTable.reloadData()
    }
    func event(withId eventId: String) -> EventList? {
        for section in allEventSections {
            switch section {
            case .upcoming(let events), .completed(let events):
                if let event = events.first(where: { $0.id == eventId }) {
                    return event
                }
            default:
                continue
            }
        }
        return nil
    }
    
    var noEventDataAvailable: Bool {
        let featured = filteredSections.first(where: { if case .featured(let e) = $0 { return !e.isEmpty } else { return false } })
        let upcoming = filteredSections.first(where: { if case .upcoming(let e) = $0 { return !e.isEmpty } else { return false } })
        let completed = filteredSections.first(where: { if case .completed(let e) = $0 { return !e.isEmpty } else { return false } })
        
        return featured == nil && upcoming == nil && completed == nil
    }
}

// MARK: - UITableViewDelegate & DataSource
@available(iOS 14.0, *)
extension EventHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch filteredSections[section] {
        case .featured, .categories: return 1
        case .upcoming(let events), .completed(let events): return events.count
        case .nodata(let nodata):
            return nodata.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = filteredSections[indexPath.section]
        
        switch sectionData {
        case .featured(let events):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OngoingTVC", for: indexPath) as! OngoingTVC
            cell.config(category: nil, onGoing: events, type: false, index: selectedIndex ?? 0)
            cell.pageController.numberOfPages = events.count
            cell.pageController.isHidden = events.count <= 1
            cell.endUrl =  ServiceUrl.event_target_details
            return cell
            
        case .categories(let categories):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OngoingTVC", for: indexPath) as! OngoingTVC
            cell.config(category: categories, onGoing: nil, type: true, index: selectedIndex ?? 0)
            cell.delegate = self
            return cell
            
        case .upcoming(let events):
            let event = events[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReciverEventTVC", for: indexPath) as! ReciverEventTVC
            cell.titleLbl.text = event.title
            cell.dateLbl.text = "\(event.category ?? "")  \(event.time ?? "") - \(event.date?.convertToTargetDateFormat() ?? "")"
            cell.placeLbl.text = event.venue
            cell.descriptionLbl.text = event.description
            cell.date = event.date
            cell.time = event.time
            cell.edit(edit: event.can_edit ?? false, delete:  event.can_delete ?? false, selectedId: event.id ?? "")
            cell.delegate = self
            //            cell.reminderBtn.isHidden = false
            cell.outerView.backgroundColor = UIColor(hex: "8000FF").withAlphaComponent(0.5)
            loadFiles(into: cell, files: event.file_path ?? [])
            cell.attacmentView.isHidden = event.file_path?.count ==  0
            return cell
        case .completed(let events):
            let event = events[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReciverEventTVC", for: indexPath) as! ReciverEventTVC
            cell.titleLbl.text = event.title
            cell.dateLbl.text = "\(event.category ?? "")  \(event.time ?? "") - \(event.date?.convertToTargetDateFormat() ?? "")"
            cell.outerView.backgroundColor = UIColor(hex: "#012E40")
            cell.placeLbl.text = event.venue
            cell.descriptionLbl.text = event.description
            cell.date = event.date
            cell.time = event.time
            cell.delegate = self
            cell.edit(edit: event.can_edit ?? false, delete:  event.can_delete ?? false, selectedId: event.id ?? "")
            loadFiles(into: cell, files: event.file_path ?? [])
            cell.attacmentView.isHidden = event.file_path?.count ==  0
            return cell
        case .nodata:
            return createNoDataCell(tableView)
        }
    }
    private func createNoDataCell(_ tableView: UITableView) -> UITableViewCell {
        let noDataCell = UITableViewCell(style: .default, reuseIdentifier: "NoDataCell")
        noDataCell.selectionStyle = .none
        noDataCell.backgroundColor = .clear
        
        let imageView = UIImageView(image: UIImage(named: "noSearchData"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "No Data Found"
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        noDataCell.contentView.addSubview(imageView)
        noDataCell.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: noDataCell.contentView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: noDataCell.contentView.topAnchor, constant: 30),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: noDataCell.contentView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: noDataCell.contentView.trailingAnchor, constant: -20)
        ])
        
        return noDataCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch filteredSections[indexPath.section] {
        case .featured: return 220
        case .categories: return 130
        case .upcoming,.nodata,.completed: return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionData = filteredSections[indexPath.section]
        var selectedEvent: EventList?
        
        switch sectionData {
        case .upcoming(let events), .completed(let events):
            selectedEvent = events[indexPath.row]
        default:
            return // Don't handle tap for featured/categories
        }
        
        guard let event = selectedEvent,
              let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let cellFrameInSuperview = tableView.convert(cell.frame, to: view)
        
        let detailVC = PrivewVc()
        detailVC.attachmetList = event.file_path
        detailVC.selectedDate = event.date
        detailVC.titleString = event.title
        detailVC.descriptionString = event.description
        detailVC.postedBy = event.sent_by
        detailVC.params = ["id": event.id ?? ""]
        detailVC.EndUrl = ServiceUrl.event_target_details
        detailVC.subject_name = "Event".translated()
        detailVC.modalPresentationStyle = .custom
        transitionDelegate.originFrame = cellFrameInSuperview
        detailVC.transitioningDelegate = transitionDelegate
        
        present(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        switch filteredSections[section] {
        case .featured: label.text = "Ongoing Events"
        case .categories: label.text = "Event Categories"
        case .upcoming: label.text = "Upcoming Events"
        case .completed: label.text = "Completed Events"
        case .nodata:label.text = ""
            
        }
        
        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0)
        ])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch filteredSections[section] {
        case .nodata:
            return 0
        default:
            return 40
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

// MARK: - UISearchBarDelegate
@available(iOS 14.0, *)
extension EventHistoryVC: UISearchBarDelegate, FilterCatagories {
    
    //    func filterCatagories(name: String) {
    //        self.filteredSections = filterEventListsByTitle(searchText: name)
    //        self.historyTable.reloadData()
    //    }
    func filterCatagories(name: String) {
        if name != "All"{
            self.filteredSections = filterEventListsByTitle(searchText: name)
            self.baseSection = self.filteredSections
        }else{
            filteredSections = allEventSections
            self.baseSection = self.filteredSections
            selectedIndex = 0
        }
        self.historyTable.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        DispatchQueue.main.async {
            
            if searchText.isEmpty {
                self.filteredSections = self.baseSection
            } else {
                
                var hasEventMatches = false
                var newFilteredSections: [EventDisplaySection] = []
                
                for section in self.baseSection {
                    switch section {
                        
                    case .featured(let events):
                        let filtered = events.filter {
                            $0.title?.localizedCaseInsensitiveContains(searchText) ?? false
                        }
                        if !filtered.isEmpty {
                            hasEventMatches = true
                            newFilteredSections.append(.featured(filtered))
                        }
                        
                    case .categories(let categories):
                        newFilteredSections.append(.categories(categories))
                        
                    case .upcoming(let events):
                        let filtered = events.filter {
                            ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                            ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
                        }
                        if !filtered.isEmpty {
                            hasEventMatches = true
                            newFilteredSections.append(.upcoming(filtered))
                        }
                        
                    case .completed(let events):
                        let filtered = events.filter {
                            ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                            ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
                        }
                        if !filtered.isEmpty {
                            hasEventMatches = true
                            newFilteredSections.append(.completed(filtered))
                        }
                        
                    case .nodata:
                        break
                    }
                }
                if !hasEventMatches {
                    newFilteredSections.append(.nodata(["Search Data Not Found"]))
                }
                
                self.filteredSections = newFilteredSections
            }
            
            self.historyTable.reloadData()
        }
    }
    
    func filterEventListsByTitle(searchText: String) -> [EventDisplaySection] {
        var filteredSections: [EventDisplaySection] = []
        let lowercasedSearchText = searchText.lowercased()
        
        var hasEventMatches = false   // --> track event matches (featured/upcoming/completed)
        
        for section in allEventSections {
            switch section {
                
            case .featured(let events):
                let filteredEvents = events.filter {
                    ($0.title?.lowercased().contains(lowercasedSearchText) ?? false) ||
                    ($0.category?.lowercased().contains(lowercasedSearchText) ?? false)
                }
                if !filteredEvents.isEmpty {
                    filteredSections.append(.featured(filteredEvents))
                    hasEventMatches = true
                }
                
            case .categories(let categories):
                // Category should always be shown, never filtered
                filteredSections.append(.categories(categories))
                
                if let index = categories.firstIndex(where: {
                    $0.name?.lowercased() == lowercasedSearchText
                }) {
                    selectedIndex = index
                } else {
                    selectedIndex = 0
                }
                
            case .upcoming(let events):
                let filteredEvents = events.filter {
                    ($0.title?.lowercased().contains(lowercasedSearchText) ?? false) ||
                    ($0.category?.lowercased().contains(lowercasedSearchText) ?? false)
                }
                if !filteredEvents.isEmpty {
                    filteredSections.append(.upcoming(filteredEvents))
                    hasEventMatches = true
                }
                
            case .completed(let events):
                let filteredEvents = events.filter {
                    ($0.title?.lowercased().contains(lowercasedSearchText) ?? false) ||
                    ($0.category?.lowercased().contains(lowercasedSearchText) ?? false)
                }
                if !filteredEvents.isEmpty {
                    filteredSections.append(.completed(filteredEvents))
                    hasEventMatches = true
                }
                
            case .nodata:
                break
            }
        }
        if !hasEventMatches {
            filteredSections.append(.nodata(["nodata"]))
        }
        
        return filteredSections
    }
    
}
