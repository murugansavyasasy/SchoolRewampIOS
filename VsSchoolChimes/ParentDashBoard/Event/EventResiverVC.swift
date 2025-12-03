//
//  EventResiverVC.swift
//  VsSchoolChimes
//
//  Created by chandhru on 20/07/25.
//

import UIKit

// MARK: - Display Enum
enum EventDisplaySection {
    case featured([EventList])
    case categories([EventCategory])
    case upcoming([EventList])
    case completed([EventList])
    case nodata([String])
}

protocol FilterCatagories {
    func filterCatagories(name: String)
}

@available(iOS 14.0, *)
class EventResiverVC: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var searchStack: UIStackView!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var noDataImg: UIImageView!
    
    // MARK: - Properties
    var titleLbl = "Event"
    var button1 = "Event/Holidays".translated()
    var button2 = "Holiday".translated()
    var delegate: HistorySelectDelegate?
    let transitionDelegate = TransitioningDelegate()
    var allEventSections: [EventDisplaySection] = []
    var filteredSections: [EventDisplaySection] = []
    var baseSection: [EventDisplaySection] = []
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var clickedMessageId : String?
    var selectedIndex:Int?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            tableview.sectionHeaderTopPadding = 0
            tableview.tableFooterView = nil
        }
        setupStudentInfo()
        setupUI()
        registerTableView()
        GetEvent()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filteredSections = allEventSections
        tableview.reloadData()
    }
    
    // MARK: - Setup Methods
    private func setupStudentInfo() {
        
        let name = studentDetails?.name ?? ""
        let standard = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        
        studentNameLbl.configureAsBackTitle(firstLine: name, secondLine: standard)
    }
    
    private func setupUI() {
        searchBtn.isHidden = false
        searchbar.placeholder = CommonStringFile.Search.translated()
        searchbar.applyRightTxt()
        searchbar.backgroundImage = UIImage()
        searchbar.barTintColor = .clear
        searchbar.backgroundColor = .clear
        searchbar.delegate = self
        searchbar.searchTextField.addDoneButton()
    }
    
    private func registerTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: CellConfingName.EventTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.EventTVC)
        tableview.register(UINib(nibName: "OngoingTVC", bundle: nil), forCellReuseIdentifier: "OngoingTVC")
        tableview.register(UINib(nibName: "ReciverEventTVC", bundle: nil), forCellReuseIdentifier: "ReciverEventTVC")
        tableview.register(UINib(nibName: CellConfingName.VideoTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.VideoTVCell)
    }
    
    // MARK: - API Call
    func GetEvent() {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.api_school_event_get_event,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if response.status == true{
                        if user_inputs.clearTempData(){
                            let parms = [ "mobile_number": UserDefaultFileManager.get_child_Details()?.whatsapp_number ?? "",
                                          "activity": "VIEW_EVENTS",
                                          "user_type": 1,
                                          "menu_id": Menu_id.staffSelectedMenuId] as [String : Any]
                            self.paketApiCall(params:parms)
                        }
                    }
                    self.allEventSections = []
                    if let firstSection = response.data?.first {
                        if !(firstSection.categories?.isEmpty ?? false) {
                            var updatedCategories = firstSection.categories
                            let allCategory = EventCategory(id: nil, name: "All", url: "")
                            updatedCategories?.insert(allCategory, at: 0)
                            self.allEventSections.append(.categories(updatedCategories ?? []))
                        }
                        if !(firstSection.on_going?.isEmpty ?? false) {
                            self.allEventSections.append(.featured(firstSection.on_going ?? []))
                        }
                        
                        if !(firstSection.up_coming?.isEmpty ?? false) {
                            self.allEventSections.append(.upcoming(firstSection.up_coming ?? []))
                        }
                        if !(firstSection.completed?.isEmpty ?? false) {
                            self.allEventSections.append(.completed(firstSection.completed ?? []))
                        }
                    }
                    if #available(iOS 15.0, *) {
                        self.hideActivityLoader()
                    }
                    self.filteredSections = self.allEventSections
                    self.baseSection = self.allEventSections
                    self.noDataLbl.isHidden = self.filteredSections.count != 0
                    self.noDataLbl.text = response.message
                    self.noDataImg.isHidden = self.filteredSections.count != 0
                    self.tableview.isHidden = false
                    self.tableview.reloadData()
                    self.scrollToClickedMessage()
                case .failure(let error):
                    print(error.localizedDescription)
                    self.noDataLbl.text = error.localizedDescription
                    self.noDataLbl.isHidden = false
                    self.noDataImg.isHidden = false
                    self.tableview.isHidden = true
                    self.searchbar.isHidden = true
                    if #available(iOS 15.0, *) {
                        self.hideActivityLoader()
                    }
                }
            }
        }
    }
    
    func paketApiCall(params:[String:Any]){
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(response.message, duration: 2.0, position: .bottom)
                    }
                case .failure(let error):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func search(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        searchBtn.setImage(UIImage(systemName: icon), for: .normal)
        searchStack.isHidden = !sender.isSelected
        sender.setImage(UIImage(systemName: icon), for: .normal)
        if sender.isSelected {
            searchbar.becomeFirstResponder()
        } else {
            filteredSections = baseSection
            let hasData = !self.filteredSections.isEmpty
            self.tableview.reloadData()
            searchbar.searchTextField.text = ""
            searchbar?.resignFirstResponder()
        }
        
    }
    private func scrollToClickedMessage() {
        guard let id = clickedMessageId else { return }
        var targetIndexPath: IndexPath?
        for (sectionIndex, section) in filteredSections.enumerated() {
            switch section {
            case .featured(let events),
                 .upcoming(let events),
                 .completed(let events):

                if let rowIndex = events.firstIndex(where: { $0.id == id }) {
                    targetIndexPath = IndexPath(row: rowIndex, section: sectionIndex)
                }

            default:
                continue
            }
        }

        guard let indexPath = targetIndexPath else { return }
        DispatchQueue.main.async {
            self.tableview.scrollToRow(at: indexPath, at: .middle, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if let cell = self.tableview.cellForRow(at: indexPath) {
                    let originalColor = cell.contentView.backgroundColor ?? .clear
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.contentView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.35)
                    }) { _ in
                        UIView.animate(withDuration: 0.5, delay: 1.0, animations: {
                            cell.contentView.backgroundColor = originalColor
                        })
                    }
                }
            }
        }
    }

    func loadFiles(into cell: ReciverEventTVC, files: [FilePath]) {
        [cell.img1, cell.img2, cell.img3].forEach { $0?.isHidden = true }
        cell.imgCount.isHidden = true
        
        for (index, item) in files.enumerated() {
            // Only process first 3 files for display
            guard index < 3 else { break }
            
            guard let urlString = item.url, let url = URL(string: urlString) else { continue }
            
            // Safe array access
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
        
        // Handle extra files count display
        if files.count > 3 {
            let extraCount = files.count - 3
            if let button = cell.imgCount as? UIButton {
                button.setTitle("+\(extraCount)", for: .normal)
                cell.imgCount.isHidden = false
            }
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
@available(iOS 14.0, *)
extension EventResiverVC: UITableViewDelegate, UITableViewDataSource {
    
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
            cell.endUrl = ""
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
            cell.placeLbl.text = event.venue
            cell.descriptionLbl.text = event.description
            cell.date = event.date
            cell.time = event.time
            cell.reminderBtn.isHidden = true
            cell.outerView.backgroundColor = UIColor(hex: "#012E40")
            loadFiles(into: cell, files: event.file_path ?? [])
            cell.attacmentView.isHidden = event.file_path?.count ==  0
            return cell
        case .nodata(_):
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
        case .upcoming,.nodata, .completed: return UITableView.automaticDimension
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
        case .featured: label.text = "Ongoing Events".translated()
        case .categories: label.text = "Event Categories".translated()
        case .upcoming: label.text = "Upcoming Events".translated()
        case .completed: label.text = "Completed Events".translated()
        case .nodata:label.text = ""
        }
        
        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
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
extension EventResiverVC: UISearchBarDelegate, FilterCatagories {
    
    func filterCatagories(name: String) {
        if name != "All"{
            self.filteredSections = filterEventListsByTitle(searchText: name)
        }else{
            filteredSections = allEventSections
        }
        self.baseSection = self.filteredSections
        searchbar.searchTextField.text = ""
        searchbar?.resignFirstResponder()
        self.tableview.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        DispatchQueue.main.async {
            
            if searchText.isEmpty {
                self.filteredSections = self.baseSection
            } else {
                
                var hasMatchedData = false
                var newFilteredSections: [EventDisplaySection] = []
                for section in self.baseSection {
                    
                    switch section {
                        
                    case .featured(let events):
                        let matched = events.filter {
                            ($0.date?.convertToTargetDateFormat()?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                            $0.title?.localizedCaseInsensitiveContains(searchText) ?? false
                        }
                        if !matched.isEmpty {
                            hasMatchedData = true
                            newFilteredSections.append(.featured(matched))
                        }
                        
                    case .categories(let categories):
                        newFilteredSections.append(.categories(categories))
                        
                    case .upcoming(let events):
                        let matched = events.filter {
                            ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                            ($0.date?.convertToTargetDateFormat()?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                            ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
                        }
                        if !matched.isEmpty {
                            hasMatchedData = true
                            newFilteredSections.append(.upcoming(matched))
                        }
                        
                        
                    case .completed(let events):
                        let matched = events.filter {
                            ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                            ($0.date?.convertToTargetDateFormat()?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                            ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
                        }
                        if !matched.isEmpty {
                            hasMatchedData = true
                            newFilteredSections.append(.completed(matched))
                        }
                        
                    case .nodata:
                        continue
                    }
                }
                if !hasMatchedData {
                    newFilteredSections.append(.nodata(["Search Data Not Found"]))
                }
                
                self.filteredSections = newFilteredSections
            }
            
            self.tableview.reloadData()
        }
    }
    
    
    func filterEventListsByTitle(searchText: String) -> [EventDisplaySection] {
        var filteredSections: [EventDisplaySection] = []
        let lowercasedSearchText = searchText.lowercased()
        
        var hasMatchedData = false
        for section in allEventSections {
            switch section {
            case .featured(let events):
                let filteredEvents = events.filter {
                    ($0.title?.lowercased().contains(lowercasedSearchText) ?? false) ||
                    ($0.category?.lowercased().contains(lowercasedSearchText) ?? false)
                }
                if !filteredEvents.isEmpty {
                    filteredSections.append(.featured(filteredEvents))
                    hasMatchedData = true
                }
                
            case .categories(let categories):
                filteredSections.append(.categories(categories))
                
                if let index = categories.firstIndex(where: { $0.name?.lowercased() == lowercasedSearchText }) {
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
                    hasMatchedData = true
                }
                
            case .completed(let events):
                let filteredEvents = events.filter {
                    ($0.title?.lowercased().contains(lowercasedSearchText) ?? false) ||
                    ($0.category?.lowercased().contains(lowercasedSearchText) ?? false)
                }
                if !filteredEvents.isEmpty {
                    filteredSections.append(.completed(filteredEvents))
                    hasMatchedData = true
                }
                
            case .nodata:
                break
            }
        }
        if !hasMatchedData {
            filteredSections.append(.nodata(["nodata"]))
        }
        return filteredSections
    }
    
}

