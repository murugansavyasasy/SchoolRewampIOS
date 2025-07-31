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
}

protocol FilterCatagories {
    func filterCatagories(name: String)
}

@available(iOS 14.0, *)
class EventResiverVC: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var searchStack: UIStackView!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var sectionLbl: UILabel!
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
    var studentDetails = UserDefaultFileManager.get_child_Details()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

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
        studentNameLbl.setFont(style: .body, size: FontSize.BodySize)
        sectionLbl.setFont(style: .body, size: FontSize.BodySize)
        studentNameLbl.text = studentDetails?.name
        sectionLbl.text = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
    }

    private func setupUI() {
        searchBtn.isHidden = false
        searchbar.placeholder = CommonStringFile.Search.translated()
        searchbar.applyRightTxt()
        searchbar.backgroundImage = UIImage()
        searchbar.barTintColor = .clear
        searchbar.backgroundColor = .clear
        searchbar.delegate = self
        searchbar.addDoneButton()
    }

    private func registerTableView() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: CellConfingName.EventTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.EventTVC)
        tableview.register(UINib(nibName: "OngoingTVC", bundle: nil), forCellReuseIdentifier: "OngoingTVC")
        tableview.register(UINib(nibName: "ReciverEventTVC", bundle: nil), forCellReuseIdentifier: "ReciverEventTVC")
        tableview.register(UINib(nibName: CellConfingName.ReciverAttendReportTV, bundle: nil), forCellReuseIdentifier: CellConfingName.ReciverAttendReportTV)
        tableview.register(UINib(nibName: CellConfingName.VideoTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.VideoTVCell)
    }

    // MARK: - API Call
    func GetEvent() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }

        APIService.shared.makeApi(
            url: ServiceUrl.api_school_event_get_event,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self?.hideLottieProgressLoader()
                }

                guard let self = self else { return }

                switch result {
                case .success(let response):
                    self.allEventSections = []
                    if let firstSection = response.data?.first {
                        if !(firstSection.on_going?.isEmpty ?? false) {
                            self.allEventSections.append(.featured(firstSection.on_going ?? []))
                        }
                        if !(firstSection.categories?.isEmpty ?? false) {
                            var updatedCategories = firstSection.categories
                            let allCategory = EventCategory(id: nil, name: "All", url: "")
                            updatedCategories?.insert(allCategory, at: 0)
                            self.allEventSections.append(.categories(updatedCategories ?? []))
                        }
                        if !(firstSection.up_coming?.isEmpty ?? false) {
                            self.allEventSections.append(.upcoming(firstSection.up_coming ?? []))
                        }
                        if !(firstSection.completed?.isEmpty ?? false) {
                            self.allEventSections.append(.completed(firstSection.completed ?? []))
                        }
                    }
                    self.filteredSections = self.allEventSections
                    self.noDataLbl.isHidden = true
                    self.noDataImg.isHidden = true
                    self.searchbar.isHidden = false
                    self.tableview.isHidden = false
                    self.tableview.reloadData()

                case .failure(let error):
                    print(error.localizedDescription)
                    self.noDataLbl.text = error.localizedDescription
                    self.noDataLbl.isHidden = false
                    self.noDataImg.isHidden = false
                    self.tableview.isHidden = true
                    self.searchbar.isHidden = true
                }
            }
        }
    }

    // MARK: - Actions
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func search(_ sender: UIButton) {
        searchbar.becomeFirstResponder()
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        searchBtn.setImage(UIImage(systemName: icon), for: .normal)
        searchStack.isHidden = !sender.isSelected
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
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = filteredSections[indexPath.section]

        switch sectionData {
        case .featured(let events):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OngoingTVC", for: indexPath) as! OngoingTVC
            cell.config(category: nil, onGoing: events, type: false)
            cell.pageController.numberOfPages = events.count
            return cell

        case .categories(let categories):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OngoingTVC", for: indexPath) as! OngoingTVC
            cell.config(category: categories, onGoing: nil, type: true)
            cell.delegate = self
            return cell

        case .upcoming(let events):
            let event = events[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReciverEventTVC", for: indexPath) as! ReciverEventTVC
            cell.titleLbl.text = event.title
            cell.dateLbl.text = "\(event.category)  \(event.time) - \(event.date.convertToTargetDateFormat() ?? "")"
            cell.placeLbl.text = event.venue
            cell.descriptionLbl.text = event.description
            cell.date = event.date
            cell.time = event.time
            cell.reminderBtn.isHidden = false
            cell.outerView.backgroundColor = UIColor(hex: "8000FF").withAlphaComponent(0.5)
            loadFiles(into: cell, files: event.file_path)
            return cell
        case .completed(let events):
            let event = events[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReciverEventTVC", for: indexPath) as! ReciverEventTVC
            cell.titleLbl.text = event.title
            cell.dateLbl.text = "\(event.category)  \(event.time) - \(event.date.convertToTargetDateFormat() ?? "")"
            cell.placeLbl.text = event.venue
            cell.descriptionLbl.text = event.description
            cell.date = event.date
            cell.time = event.time
            cell.reminderBtn.isHidden = true
            cell.outerView.backgroundColor = .black
            loadFiles(into: cell, files: event.file_path)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch filteredSections[indexPath.section] {
        case .featured: return 220
        case .categories: return 130
        case .upcoming, .completed: return UITableView.automaticDimension
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
        case .featured: label.text = "Today's Events"
        case .categories: label.text = "Event Categories"
        case .upcoming: label.text = "Upcoming Events"
        case .completed: label.text = "Completed Events"
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
        return 40
    }
}

// MARK: - UISearchBarDelegate
@available(iOS 14.0, *)
extension EventResiverVC: UISearchBarDelegate, FilterCatagories {

    func filterCatagories(name: String) {
        self.filteredSections = filterEventListsByTitle(searchText: name)
        self.tableview.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.main.async {
            if searchText.isEmpty {
                self.filteredSections = self.allEventSections
            } else {
                self.filteredSections = self.allEventSections.compactMap { section in
                    switch section {
                    case .featured(let events):
                        let matched = events.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
                        return matched.isEmpty ? nil : .featured(matched)

                    case .categories(let categories):
                        let matched = categories.filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
                        return matched.isEmpty ? nil : .categories(matched)

                    case .upcoming(let events):
                        let matched = events.filter {
                            $0.title.localizedCaseInsensitiveContains(searchText) ||
                            $0.description.localizedCaseInsensitiveContains(searchText)
                        }
                        return matched.isEmpty ? nil : .upcoming(matched)

                    case .completed(let events):
                        let matched = events.filter {
                            $0.title.localizedCaseInsensitiveContains(searchText) ||
                            $0.description.localizedCaseInsensitiveContains(searchText)
                        }
                        return matched.isEmpty ? nil : .completed(matched)
                    }
                }
            }
            self.tableview.reloadData()
        }
    }

    func filterEventListsByTitle(searchText: String) -> [EventDisplaySection] {
        var filtered: [EventDisplaySection] = []

        let upcoming = allEventSections.compactMap { section -> [EventList]? in
            if case .upcoming(let events) = section {
                return events.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            }
            return nil
        }.flatMap { $0 }

        if !upcoming.isEmpty {
            filtered.append(.upcoming(upcoming))
        }

        let completed = allEventSections.compactMap { section -> [EventList]? in
            if case .completed(let events) = section {
                return events.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            }
            return nil
        }.flatMap { $0 }

        if !completed.isEmpty {
            filtered.append(.completed(completed))
        }

        return filtered
    }
}

